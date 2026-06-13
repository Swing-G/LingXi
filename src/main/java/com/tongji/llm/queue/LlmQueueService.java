package com.tongji.llm.queue;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.redisson.api.RScript;
import org.redisson.api.RedissonClient;
import org.redisson.client.codec.StringCodec;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.core.scheduler.Schedulers;

import java.time.Duration;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
@Service
@RequiredArgsConstructor
public class LlmQueueService {

    private final RedissonClient redisson;
    private final QueueConfig config;

    private static final String QUEUE_KEY     = "llm:queue";
    private static final String SEMAPHORE_KEY = "llm:semaphore";
    private static final String CHANNEL       = "llm:channel:slot";

    private final ConcurrentHashMap<String, Long> acquiredSet = new ConcurrentHashMap<>();

    /** 队列事件类型 */
    public enum QueueEvent {
        /** 已获取槽位，可以开始调用 */
        ACQUIRED,
        /** 排队中，附带当前位置 */
        POSITION_UPDATE,
        /** 队列满或系统繁忙，直接拒绝 */
        REJECTED,
        /** 排队超时 */
        TIMEOUT
    }

    /** 队列事件 */
    public record QueueMessage(QueueEvent event, int position, int totalWaiting, String message) {
        public static QueueMessage acquired() {
            return new QueueMessage(QueueEvent.ACQUIRED, 0, 0, null);
        }
        public static QueueMessage position(int pos, int total) {
            return new QueueMessage(QueueEvent.POSITION_UPDATE, pos, total, null);
        }
        public static QueueMessage rejected(String msg) {
            return new QueueMessage(QueueEvent.REJECTED, 0, 0, msg);
        }
        public static QueueMessage timeout() {
            return new QueueMessage(QueueEvent.TIMEOUT, 0, 0, "排队超时，请稍后重试");
        }
    }

    // ────────────── 核心 Lua 脚本（内联，避免文件加载） ──────────────

    private static final String ACQUIRE_LUA = """
            local queue_key     = KEYS[1]
            local sem_key       = KEYS[2]
            local request_id    = ARGV[1]
            local max_conc      = tonumber(ARGV[2])
            local max_wait      = tonumber(ARGV[3])
            local now           = tonumber(ARGV[4])

            redis.call('ZREMRANGEBYSCORE', queue_key, '-inf', now - max_wait * 1000)

            local current = tonumber(redis.call('GET', sem_key) or '0')
            if current < max_conc then
                redis.call('INCR', sem_key)
                return {'acquired', current + 1}
            end

            local q_len = redis.call('ZCARD', queue_key)
            if q_len >= 500 then
                return {'rejected', '队列繁忙，请稍后重试'}
            end

            redis.call('ZADD', queue_key, now, request_id)
            local position = redis.call('ZRANK', queue_key, request_id) + 1
            return {'queued', position}
            """;

    private static final String RELEASE_LUA = """
            local queue_key  = KEYS[1]
            local sem_key    = KEYS[2]
            local channel    = KEYS[3]
            local request_id = ARGV[1]

            redis.call('ZREM', queue_key, request_id)
            local current = tonumber(redis.call('DECR', sem_key) or '0')
            if current < 0 then
                redis.call('SET', sem_key, '0')
                current = 0
            end

            local next_req = redis.call('ZPOPMIN', queue_key)
            if next_req and #next_req > 0 then
                redis.call('INCR', sem_key)
                redis.call('PUBLISH', channel, next_req[1])
                return {next_req[1]}
            end
            return {}
            """;

    // ────────────── 公有方法 ──────────────

    /**
     * 尝试获取调用槽位（同步，供 Controller / Service 调用）。
     * @return QueueMessage
     */
    public QueueMessage tryAcquire(String requestId) {
        long now = System.currentTimeMillis();
        List<Object> result = redisson.getScript(StringCodec.INSTANCE)
                .eval(RScript.Mode.READ_WRITE,
                        ACQUIRE_LUA,
                        RScript.ReturnType.MULTI,
                        List.of(QUEUE_KEY, SEMAPHORE_KEY),
                        requestId,
                        String.valueOf(config.getMaxConcurrency()),
                        String.valueOf(config.getMaxWaitSeconds()),
                        String.valueOf(now));
        String status = result.getFirst().toString();
        return switch (status) {
            case "acquired" -> QueueMessage.acquired();
            case "rejected" -> QueueMessage.rejected(result.get(1).toString());
            default -> QueueMessage.position(Integer.parseInt(result.get(1).toString()), 0);
        };
    }

    /** 释放槽位 */
    public void release(String requestId) {
        try {
            redisson.getScript(StringCodec.INSTANCE)
                    .eval(RScript.Mode.READ_WRITE,
                            RELEASE_LUA,
                            RScript.ReturnType.MULTI,
                            List.of(QUEUE_KEY, SEMAPHORE_KEY, CHANNEL),
                            requestId);
        } catch (Exception e) {
            log.warn("Release slot failed for {}: {}", requestId, e.getMessage());
        }
    }

    /** 当前排队人数 */
    public long getQueueLength() {
        return redisson.getScoredSortedSet(QUEUE_KEY).size();
    }

    /**
     * 流式排队：轮询等待槽位，期间推送位置更新。
     * 获取槽位后流结束，调用方负责 release。
     */
    public Flux<QueueMessage> streamQueue(String requestId) {
        long deadline = System.currentTimeMillis() + config.getMaxWaitSeconds() * 1000L;

        return Flux.interval(Duration.ofMillis(config.getPollIntervalMs()))
                .concatMap(tick -> Mono.fromCallable(() -> {
                    if (System.currentTimeMillis() > deadline) {
                        release(requestId);
                        return QueueMessage.timeout();
                    }
                    QueueMessage msg = tryAcquire(requestId);
                    if (msg.event() == QueueEvent.ACQUIRED || msg.event() == QueueEvent.REJECTED) {
                        return msg;
                    }
                    long total = getQueueLength();
                    return QueueMessage.position(msg.position(), (int) total);
                }).subscribeOn(Schedulers.boundedElastic()))
                .takeUntil(msg -> msg.event() == QueueEvent.ACQUIRED
                        || msg.event() == QueueEvent.TIMEOUT
                        || msg.event() == QueueEvent.REJECTED)
                .doOnNext(msg -> log.debug("Queue status for {}: {} pos={}", requestId, msg.event(), msg.position()));
    }
}
