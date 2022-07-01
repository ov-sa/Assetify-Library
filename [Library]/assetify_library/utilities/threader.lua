----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: threader.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Threader Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    tonumber = tonumber,
    coroutine = coroutine,
    math = math
}


-----------------------
--[[ Class: Thread ]]--
-----------------------

local thread = class:create("thread")

function thread.public:create(exec)
    if not exec or (imports.type(exec) ~= "function") then return false end
    local cThread = self:createInstance()
    if cThread then
        cThread.syncRate = {}
        cThread.thread = imports.coroutine.create(exec)
    end
    return cThread
end

function thread.public:createHeartbeat(conditionExec, exec, rate)
    if self ~= thread.public then return false end
    if not conditionExec or not exec or (imports.type(conditionExec) ~= "function") or (imports.type(exec) ~= "function") then return false end
    rate = imports.math.max(imports.tonumber(rate) or 0, 1)
    local cThread = thread.public:create(function(self)
        while(conditionExec()) do
            self:pause()
        end
        exec()
        conditionExec, exec = nil, nil
    end)
    cThread:resume({
        executions = 1,
        frames = rate
    })
    return cThread
end

function thread.public:destroy()
    if not thread.public:isInstance(self) then return false end
    if self.timer then self.timer:destroy() end
    self:destroyInstance()
    return true
end

function thread.public:status()
    if not thread.public:isInstance(self) then return false end
    if not self.thread then
        return "dead"
    else
        return imports.coroutine.status(self.thread)
    end
end

function thread.public:pause()
    return imports.coroutine.yield()
end

function thread.public:resume(syncRate)
    if not thread.public:isInstance(self) then return false end
    self.syncRate.executions = (syncRate and imports.tonumber(syncRate.executions)) or false
    self.syncRate.frames = (self.syncRate.executions and syncRate and imports.tonumber(syncRate.frames)) or false
    if self.syncRate.executions and self.syncRate.frames then
        self.timer = timer:create(function()
            if self.isAwaiting then return false end
            if self:status() == "suspended" then
                for i = 1, self.syncRate.executions, 1 do
                    if self.isAwaiting then return false end
                    if self:status() == "dead" then return self:destroy() end
                    imports.coroutine.resume(self.thread, self)
                end
            end
            if self:status() == "dead" then self:destroy() end
        end, self.syncRate.frames, 0)
    else
        if self.isAwaiting then return false end
        if self.timer then self.timer:destroy() end
        if self:status() == "suspended" then
            imports.coroutine.resume(self.thread, self)
        end
        if self:status() == "dead" then self:destroy() end
    end
    return true
end

function thread.public:sleep(duration)
    duration = imports.math.max(0, imports.tonumber(duration) or 0)
    if not thread.public:isInstance(self) then return false end
    if self.timer and timer:isInstance(self.timer) then return false end
    self.isAwaiting = "sleep"
    self.timer = timer:create(function()
        self.isAwaiting = nil
        self:resume()
    end, duration, 1)
    self:pause()
    return true
end

function thread.public:await(exec)
    if not thread.public:isInstance(self) then return false end
    if not exec or imports.type(exec) ~= "function" then return self:resolve(exec) end
    self.isAwaiting = "promise"
    exec(self)
    thread.public:pause()
    local resolvedValues = self.awaitingValues
    self.awaitingValues = nil
    return table:unpack(resolvedValues)
end

function thread.public:resolve(...)
    if not thread.public:isInstance(self) then return false end
    if not self.isAwaiting or (self.isAwaiting ~= "promise") then return false end
    self.isAwaiting = nil
    self.awaitingValues = table:pack(...)
    timer:create(function()
        self:resume()
    end, 1, 1)
    return true
end

function async(...) return thread.public:create(...) end