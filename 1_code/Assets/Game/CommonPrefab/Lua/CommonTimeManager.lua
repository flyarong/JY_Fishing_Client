local basefunc = require "Game/Common/basefunc"
CommonTimeManager = {}
local M = CommonTimeManager
local this
local lister
local timers = {}
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
	lister["ExitScene"] = M.ExitScene
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
end

function M.Init()
	M.Exit()
	this = CommonTimeManager
	MakeLister()
    AddLister()
end

function M.Exit()
	if this then
		RemoveLister()
		if this.DayCheck_Timer then
			this.DayCheck_Timer:Stop()
        end
        this = nil
	end
end

function M.OnLoginResponse(result)
	if result == 0 then
		-- 数据初始化
		M.DayCheck()
	end
end

function M.OnReConnecteServerSucceed()

end

function M.ExitScene()
	if timers then
        for i = 1,#timers do
            if timers[i] then
                timers[i]:Stop()
            end
        end
    end
    timers = {}
end

--callback在倒计时结束时执行的回调
--callback2在倒计时过程中要执行的回调,内含两个参数,一个是还剩多少秒的时候,一个是回调方法
--suffix后缀
--prefix前缀
function M.GetCutDownTimer(end_time,text_obj,hide_remain,callback,callback2,suffix,prefix)
    timers = timers or {}
    local now_t = os.time()
    end_time = end_time - now_t
    local str = ""
    if hide_remain then
        str = StringHelper.formatTimeDHMS(end_time)
    else
        str = "剩余时间: "..StringHelper.formatTimeDHMS(end_time)
    end
    if suffix then
        str = str .. suffix
    end
    if prefix then
        str = prefix .. str
    end
    text_obj.text = str
    local timer = Timer.New(function()
        if IsEquals(text_obj) then
            end_time = end_time - 1
            if end_time >= 0 then
                local str = ""
                if hide_remain then
                    str = StringHelper.formatTimeDHMS(end_time)
                else
                    str = "剩余时间: "..StringHelper.formatTimeDHMS(end_time)
                end
                if suffix then
                    str = str .. suffix
                end
                if prefix then
                    str = prefix .. str
                end
                text_obj.text = str
                if callback2 and end_time == callback2.remain_second and callback2.fun then
                    callback2.fun()
                end
            else
                if callback then
                    callback()
                end
            end
        end
    end,1,-1)
    timers[#timers + 1] = timer
    timer:Start()
    return timer
end

function M.DayCheck()
	local last_t = os.date("%w",os.time())
	if this.DayCheck_Timer then
		this.DayCheck_Timer:Stop()
    end
    this.DayCheck_Timer = Timer.New(
			function()
				if os.date("%w",os.time()) ~= last_t then
					Event.Brocast("new_day")
				end
			end
	,20,-1)
	this.DayCheck_Timer:Start()
end

--用于活动入口显示
function M.GetCutDownTimer2(end_time,text_obj)
    timers = timers or {}
    local now_t = os.time()
    end_time = end_time - now_t
    local str = StringHelper.formatTimeDHMS5(end_time)
    text_obj.text = str
    local timer = Timer.New(function()
        if IsEquals(text_obj) then
            end_time = end_time - 1
                if end_time >= 0 then
                local str = StringHelper.formatTimeDHMS5(end_time)
                text_obj.text = str
            end
        end
    end,1,-1)
    timers[#timers + 1] = timer
    timer:Start()
    return timer
end