-- 创建时间:2019-04-25

TimerManager = {}
local M = TimerManager
local this
local timer_map = {}
local global_timer_map = {}

local autoKey = 1
local function CreateKey ()
    local key = "TimerKey_" .. autoKey
    autoKey = autoKey + 1
    if autoKey > 10000000 then
        autoKey = 1
    end
    return key
end

local lister
local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg,cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister=nil
end
local function MakeLister()
    lister = {}
    lister["ExitScene"] = this.OnExitScene
end
function M.StopTT()
	if this.tt then
		this.tt:Stop()
		this.tt = nil
	end
end
function M.Init()
	if not this then
		this = M
	    MakeLister()
	    AddLister()

	    M.StopTT()
	    -- this.tt = Timer.New(function (_,t)
	    -- 	M.Update(_,t)
	    -- end, 0, -1)
	    -- this.tt:Start()
	end
end
function M.Exit()
	if this then
		M.StopTT()
		M.CloseAllTimer()
		RemoveLister()
		this = nil
	end
end

function M.OnExitScene()
	M.CloseAllTimer()	
end

function M.Update(_, t)
	-- print(t)
end

function M.AddTimer(_timer)
	local key = CreateKey()
	timer_map[key] = _timer
	return key
end
function M.RemoveTimer(key)
	if key and timer_map[key] then
		timer_map[key]:Stop()
		timer_map[key] = nil
	end
end
-- 清除时间
function M.CloseAllTimer()
	if timer_map and next(timer_map) then
		print("<color=red>TimerManager timer没有正确关闭 请查看</color>")
	end
	for k,v in pairs(timer_map) do
		v:Stop()
		v:ShowDebug()
	end
	timer_map = {}
end


