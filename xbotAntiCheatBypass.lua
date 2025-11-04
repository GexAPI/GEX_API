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
            args[31] = false
        end
        local result = originalNameCall(self, unpack(args))
    else
        return  originalNameCall(self, ...)   
    end
end)
