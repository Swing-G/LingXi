package com.tongji.llm.queue;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Data
@Component
@ConfigurationProperties(prefix = "llm.queue")
public class QueueConfig {
    /** 最大并发调用数 */
    private int maxConcurrency = 3;
    /** 排队最大等待秒数，超时拒绝 */
    private int maxWaitSeconds = 60;
    /** 轮询间隔毫秒（SSE 推送位置变化用） */
    private long pollIntervalMs = 1500;
}
