-- acquire.lua: 原子获取 LLM 调用槽位或加入排队
-- KEYS[1]: llm:queue     (ZSET)
-- KEYS[2]: llm:semaphore (String)
-- ARGV[1]: requestId
-- ARGV[2]: maxConcurrency
-- ARGV[3]: maxWaitSeconds
-- ARGV[4]: now (epoch millis)

local queue_key     = KEYS[1]
local semaphore_key = KEYS[2]
local request_id    = ARGV[1]
local max_conc      = tonumber(ARGV[2])
local max_wait      = tonumber(ARGV[3])
local now           = tonumber(ARGV[4])

-- 清理超时条目
local expire_before = now - (max_wait * 1000)
redis.call('ZREMRANGEBYSCORE', queue_key, '-inf', expire_before)

-- 当前并发数
local current = tonumber(redis.call('GET', semaphore_key) or '0')

if current < max_conc then
    redis.call('INCR', semaphore_key)
    return {'acquired', current + 1}
end

-- 检查总排队人数是否已满（硬上限 500）
local q_len = redis.call('ZCARD', queue_key)
if q_len >= 500 then
    return {'rejected', '队列繁忙，请稍后重试'}
end

-- 加入队列
redis.call('ZADD', queue_key, now, request_id)
local position = redis.call('ZRANK', queue_key, request_id) + 1
return {'queued', position}
