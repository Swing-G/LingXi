package com.tongji.knowpost.api;

import com.tongji.llm.rag.RagIndexService;
import com.tongji.llm.rag.RagQueryService;
import com.tongji.search.index.SearchIndexService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.codec.ServerSentEvent;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;

@Slf4j
@RestController
@RequestMapping("/api/v1/knowposts")
@Validated
@RequiredArgsConstructor
public class KnowPostRagController {

    private final RagIndexService indexService;
    private final RagQueryService ragQueryService;
    private final SearchIndexService searchIndexService;

    /**
     * 单篇知文 RAG 问答（WebFlux + Flux 流式输出）。
     * 示例：GET /api/v1/knowposts/{id}/qa/stream?question=...&topK=5&maxTokens=1024
     */
    @GetMapping(value = "/{id}/qa/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<ServerSentEvent<String>> qaStream(@PathVariable("id") long id,
                                 @RequestParam("question") String question,
                                 @RequestParam(value = "topK", defaultValue = "5") int topK,
                                 @RequestParam(value = "maxTokens", defaultValue = "1024") int maxTokens) {
        return ragQueryService.streamAnswerFlux(id, question, topK, maxTokens);
    }

    /**
     * 手动触发单篇索引重建（返回重建的切片数）。
     * 传 force=true 可强制重建（即使指纹未变化，如修复编码问题后）。
     */
    @PostMapping("/{id}/rag/reindex")
    public int reindex(@PathVariable("id") long id,
                       @RequestParam(value = "force", defaultValue = "false") boolean force) {
        log.info("RAG reindex requested: postId={}, force={}", id, force);
        int result = indexService.reindexSinglePost(id, force);
        log.info("RAG reindex result: postId={}, chunks={}", id, result);
        return result;
    }

    /**
     * 手动触发搜索索引重建（同步写入 ES，用于 Canal 未运行时补数据）。
     */
    @PostMapping("/{id}/search/reindex")
    public String searchReindex(@PathVariable("id") long id) {
        searchIndexService.upsertKnowPost(id);
        return "ok";
    }
}