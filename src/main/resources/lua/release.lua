-- release.lua: 原子释放 LLM 调用槽位，通知下一个等待者
-- KEYS[1]: llm:queue     (ZSET)
-- KEYS[2]: llm:semaphore (String)
-- KEYS[3]: llm:channel   (Pub/Sub channel)
-- ARGV[1]: requestId

local queue_key     = KEYS[1]
local semaphore_key = KEYS[2]
local channel       = KEYS[3]
local request_id    = ARGV[1]

-- 从队列移除（可能根本没在排队）
redis.call('ZREM', queue_key, request_id)

-- 释放槽位
local current = tonumber(redis.call('DECR', semaphore_key) or '0')
if current < 0 then
    redis.call('SET', semaphore_key, '0')
    current = 0
end

-- 取出下一个等待者
local next_req = redis.call('ZPOPMIN', queue_key)
if next_req and #next_req > 0 then
    redis.call('INCR', semaphore_key)
    redis.call('PUBLISH', channel, next_req[1])
    return {next_req[1]}
end

return {}
