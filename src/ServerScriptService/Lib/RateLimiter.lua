local RateLimiter = {}
-- simple token bucket per key
function RateLimiter.new(perSecond, burst)
    local self = { rate = perSecond, burst = burst or perSecond, buckets = {} }
    function self:allow(key)
        local now = os.clock()
        local b = self.buckets[key] or { tokens = self.burst, t = now }
        local elapsed = now - b.t
        b.tokens = math.min(self.burst, b.tokens + elapsed * self.rate)
        b.t = now
        if b.tokens >= 1 then b.tokens -= 1; self.buckets[key] = b; return true end
        self.buckets[key] = b; return false
    end
    return self
end
return RateLimiter