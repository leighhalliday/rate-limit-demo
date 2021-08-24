-- Keys used for Redis lookup
local tokens_key = KEYS[1]
local timestamp_key = KEYS[2]

-- Arguments passed when executing script
local rate = tonumber(ARGV[1])
local capacity = tonumber(ARGV[2])
local now = tonumber(ARGV[3])
local requested = tonumber(ARGV[4])

-- Time to fill bucket and how long we need to keep data around for
local fill_time = capacity/rate
local ttl = math.floor(fill_time*2)

-- How full was bucket the last time user made request?
local last_tokens = tonumber(redis.call("get", tokens_key))
if last_tokens == nil then
  last_tokens = capacity
end

-- When did the user make the last request?
local last_refreshed = tonumber(redis.call("get", timestamp_key))
if last_refreshed == nil then
  last_refreshed = 0
end

-- Calculate time between now and last refresh (in seconds)
local delta = math.max(0, now-last_refreshed)
-- Given seconds that have passed, how full is bucket at this moment
local filled_tokens = math.min(capacity, last_tokens+(delta*rate))
-- Will we allow this request?
local allowed = filled_tokens >= requested
-- After this request, how full will bucket be?
local new_tokens = filled_tokens
if allowed then
  new_tokens = filled_tokens - requested
end

-- Update values in Redis
redis.call("setex", tokens_key, ttl, new_tokens)
redis.call("setex", timestamp_key, ttl, now)

-- Return response
return { allowed, new_tokens }