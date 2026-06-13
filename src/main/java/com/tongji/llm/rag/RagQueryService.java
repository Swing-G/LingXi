package com.tongji.llm.rag;

import com.tongji.llm.queue.LlmQueueService;
import com.tongji.llm.queue.LlmQueueService.QueueEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.deepseek.DeepSeekChatOptions;
import org.springframework.ai.document.Document;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.http.codec.ServerSentEvent;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;

import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * RAG 问答查询服务：
 * - 接入分布式队列限流，排队期间 SSE 推送位置更新
 * - 获取槽位后检索上下文并流式输出模型回答
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class RagQueryService {

    private final VectorStore vectorStore;
    private final ChatClient chatClient;
    private final RagIndexService indexService;
    private final LlmQueueService queueService;

    /**
     * 流式问答（接入排队限流）。
     * 排队期间推送 queue 事件，获取槽位后推送 answer 内容。
     */
    public Flux<ServerSentEvent<String>> streamAnswerFlux(long postId, String question, int topK, int maxTokens) {
        String requestId = UUID.randomUUID().toString();

        LlmQueueService.QueueMessage firstAttempt = queueService.tryAcquire(requestId);

        if (firstAttempt.event() == QueueEvent.ACQUIRED) {
            return doStreamAnswer(postId, question, topK, maxTokens, requestId);
        }

        if (firstAttempt.event() == QueueEvent.REJECTED) {
            return Flux.just(
                    ServerSentEvent.<String>builder()
                            .event("error")
                            .data("系统繁忙，当前排队人数过多，请稍后重试")
                            .build()
            );
        }

        int startPosition = firstAttempt.position();

        return Flux.concat(
                // 排队通知
                Flux.just(ServerSentEvent.<String>builder()
                        .event("queued")
                        .data("{\"position\":" + startPosition + "}")
                        .build()),
                // 排队等待 + 位置更新
                queueService.streamQueue(requestId)
                        .map(msg -> switch (msg.event()) {
                            case POSITION_UPDATE -> ServerSentEvent.<String>builder()
                                    .event("position")
                                    .data("{\"position\":" + msg.position()
                                            + ",\"totalWaiting\":" + msg.totalWaiting() + "}")
                                    .build();
                            case ACQUIRED -> ServerSentEvent.<String>builder()
                                    .event("ready")
                                    .data("{}")
                                    .build();
                            case TIMEOUT -> ServerSentEvent.<String>builder()
                                    .event("timeout")
                                    .data("{\"message\":\"排队超时，请稍后重试\"}")
                                    .build();
                            case REJECTED -> ServerSentEvent.<String>builder()
                                    .event("error")
                                    .data("{\"message\":\"" + msg.message() + "\"}")
                                    .build();
                        }),
                // 获取槽位后流式输出答案
                Flux.defer(() -> doStreamAnswerRaw(postId, question, topK, maxTokens)
                        .map(chunk -> ServerSentEvent.<String>builder().data(chunk).build()))
                        .doFinally(signal -> queueService.release(requestId))
        );
    }

    private Flux<ServerSentEvent<String>> doStreamAnswer(long postId, String question, int topK, int maxTokens, String requestId) {
        return doStreamAnswerRaw(postId, question, topK, maxTokens)
                .map(chunk -> ServerSentEvent.<String>builder().data(chunk).build())
                .doFinally(signal -> queueService.release(requestId));
    }

    /** 返回原始文本流（不包装 SSE），供内部组合用 */
    private Flux<String> doStreamAnswerRaw(long postId, String question, int topK, int maxTokens) {
        return Flux.defer(() -> {
            try {
                indexService.ensureIndexed(postId);
            } catch (Exception e) {
                log.error("RAG ensureIndexed failed for post {}: {}", postId, e.getMessage(), e);
                return Flux.just("索引构建失败，请稍后重试。");
            }

            List<String> contexts = searchContexts(String.valueOf(postId), question, Math.max(1, topK));
            log.info("RAG query: postId={}, question={}, topK={}, contextsFound={}",
                    postId, question.substring(0, Math.min(30, question.length())), topK, contexts.size());

            if (contexts.isEmpty()) {
                return Flux.just("未找到相关内容，可能文章正文暂不可读。");
            }

            String context = String.join("\n\n---\n\n", contexts);

            String system = "你是中文知识助手。只能依据提供的知文上下文回答；无法确定的请说明不确定。";
            String user = "问题：" + question + "\n\n上下文如下（可能不完整）：\n" + context + "\n\n请基于以上上下文作答。";

            return chatClient
                    .prompt()
                    .system(system)
                    .user(user)
                    .options(DeepSeekChatOptions.builder()
                            .model("deepseek-chat")
                            .temperature(0.2)
                            .maxTokens(maxTokens)
                            .build())
                    .stream()
                    .content()
                    .timeout(Duration.ofSeconds(120))
                    .doOnError(e -> log.error("RAG DeepSeek call failed: {}", e.getMessage(), e))
                    .onErrorResume(e -> {
                        String msg = e.getMessage();
                        log.error("RAG stream error (full): {}", msg, e);
                        if (msg != null && msg.contains("429")) {
                            return Flux.just("请求过于频繁，请稍等几秒再试。");
                        }
                        if (msg != null && (msg.contains("timeout") || msg.contains("Timeout"))) {
                            return Flux.just("回答生成超时，请简化问题后重试。");
                        }
                        if (msg != null && msg.contains("401")) {
                            return Flux.just("AI 服务认证失败，请检查 API Key 配置。");
                        }
                        if (msg != null && msg.contains("402")) {
                            return Flux.just("AI 服务余额不足，请充值后重试。");
                        }
                        return Flux.just("生成失败：" + (msg != null ? msg.substring(0, Math.min(100, msg.length())) : "未知错误"));
                    });
        });
    }

    private List<String> searchContexts(String postId, String query, int topK) {
        int fetchK = Math.max(topK * 3, 20);
        List<Document> docs = vectorStore.similaritySearch(
                SearchRequest.builder().query(query).topK(fetchK).build()
        );
        List<String> out = new ArrayList<>(topK);
        for (Document d : docs) {
            Object pid = d.getMetadata().get("postId");
            if (pid != null && postId.equals(String.valueOf(pid))) {
                String txt = d.getText();
                if (txt != null && !txt.isEmpty()) {
                    out.add(txt);
                    if (out.size() >= topK) break;
                }
            }
        }
        return out;
    }
}
