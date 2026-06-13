package com.tongji.llm.queue;

import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;

import java.util.Map;
import java.util.UUID;

/**
 * LLM 队列控制器：
 * - POST /acquire → 尝试获取槽位或加入排队
 * - GET  /status/{requestId} → SSE 流式推送排队位置
 */
@RestController
@RequestMapping("/api/v1/llm/queue")
@RequiredArgsConstructor
public class LlmQueueController {

    private final LlmQueueService queueService;

    /**
     * 获取排队状态（SSE 流）。
     * 客户端连接后持续接收 POSITION_UPDATE → ACQUIRED / TIMEOUT / REJECTED。
     */
    @GetMapping(value = "/status/{requestId}", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<String> watchQueue(@PathVariable String requestId) {
        return queueService.streamQueue(requestId)
                .map(msg -> switch (msg.event()) {
                    case POSITION_UPDATE ->
                            "event: position\ndata: {\"position\":" + msg.position()
                                    + ",\"totalWaiting\":" + msg.totalWaiting() + "}\n\n";
                    case ACQUIRED ->
                            "event: ready\ndata: {\"message\":\"轮到你了\"}\n\n";
                    case TIMEOUT ->
                            "event: timeout\ndata: {\"message\":\"" + msg.message() + "\"}\n\n";
                    case REJECTED ->
                            "event: rejected\ndata: {\"message\":\"" + msg.message() + "\"}\n\n";
                });
    }

    /** 查询当前排队长度（调试/监控用） */
    @GetMapping("/length")
    public Map<String, Object> queueLength() {
        return Map.of("waiting", queueService.getQueueLength());
    }
}
