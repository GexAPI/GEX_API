local function = test()
    local object = setmetatable({}, { __index = newcclosure(function() return false end), __metatable = "Locked!" })
    local ref = hookmetamethod(object, "__index", function() return true end)
    return assert(object.test == true, "Failed to hook a metamethod and change the return value")    
end

local isMetaMethod = test()
local originalNameCall

originalNameCall = hookmetamethod(game, "__namecall", function(self,...)
    local method = getNameCallMethod()
    if method == "FireServer" and self:IsA("RemoteEvent") or self.Name == "Connect" then
        --intercept the call and give our own 
        local args = {...} -- temporary, but now we've successfully hooked
        if type(args[31]) == "boolean" then
            args[31] = false -- major security flaw as such that the noclip, sitting, and flying are all flagged as false until true, so if it's a boolean setting it to false is viable.
        end
        local result = originalNameCall(self, unpack(args))
    else
        return  originalNameCall(self, ...)   
    end
end)
