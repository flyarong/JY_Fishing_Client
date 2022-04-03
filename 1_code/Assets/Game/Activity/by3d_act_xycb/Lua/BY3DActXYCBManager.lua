-- 创建时间:2020-02-21
-- BY3DActXYCBManager 管理器

local basefunc = require "Game/Common/basefunc"
BY3DActXYCBManager = {}
local M = BY3DActXYCBManager
M.key = "by3d_act_xycb"
GameButtonManager.ExtLoadLua(M.key, "Fishing3DActXYCBPanel")
GameButtonManager.ExtLoadLua(M.key, "Fishing3DActBKPrefab")
GameButtonManager.ExtLoadLua(M.key, "Fishing3DActXYCBOpenPrefab")
GameButtonManager.ExtLoadLua(M.key, "Fishing3DActXYCBHelpPanel")
GameButtonManager.ExtLoadLua(M.key, "Fishing3DActBKEnterPrefab")
local fish3d_caibei_config = GameButtonManager.ExtLoadLua(M.key, "fish3d_caibei_config")

local this
local lister

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    else
        return true
    end
end
-- 创建入口按钮时调用
function M.CheckIsShow()
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        if M.CheckIsShow() then
            return Fishing3DActXYCBPanel.Create()
        end 
    elseif parm.goto_scene_parm == "enter" then
        if M.CheckIsShow() then
            return Fishing3DActBKEnterPrefab.Create(parm.parent)
        end 
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    if not this then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
    end

    if parm and parm.gotoui == M.key then 
        if this.m_data.is_can_get--[[((M.GetFreeGetCD() == 0 and dd and dd.obtain_num < this.UIConfig.free_get_max_num)) or (((M.GetOpeningCBMax() > M.GetOpeningCBNum()) and ((M.GetCurCBNum() - M.GetOpeningCBNum()) > 0)) or ((M.GetCurCBNum() > 0) and this.m_data.countdown <= 0))--]] then
    	    return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
    end
end

function M.on_XYCBManager_enter_lfl_msg(b)
    this.m_data.is_can_get = b
end

function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
end


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
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg

    lister["nor_fishing_3d_caibei_all_info_response"] = this.on_nor_fishing_3d_caibei_all_info_response
    lister["nor_fishing_3d_free_caibei_obtain_response"] = this.on_nor_fishing_3d_free_caibei_obtain_response
    lister["nor_fishing_3d_caibei_start_response"] = this.on_nor_fishing_3d_caibei_start_response
    lister["nor_fishing_3d_caibei_complete_use_jingbi_response"] = this.on_nor_fishing_3d_caibei_complete_use_jingbi_response
    lister["nor_fishing_3d_caibei_complete_response"] = this.on_nor_fishing_3d_caibei_complete_response

    lister["XYCB_CountDown_msg"] = this.CountDownTimer

    lister["XYCBManager_enter_lfl_msg"] = this.on_XYCBManager_enter_lfl_msg
end

function M.Init()
	M.Exit()

	this = BY3DActXYCBManager
	this.m_data = {}
    this.m_data.countdown = 99999999999999999999999
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
    M.StopMFLQUpdataTimer()
    M.StopCountDownTimer()
    M.StopEnterCountDownTimer()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}

    this.UIConfig.free_get_cd = {900, 1800, 1800} -- 免费领取海贝的CD间隔
    this.UIConfig.free_get_max_num = 3 -- 免费领取的最大数
    this.UIConfig.caibei_list = {}
    for k,v in ipairs(fish3d_caibei_config.config) do
        this.UIConfig.caibei_list[k] = v
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.QueryAllInfo()
    Network.SendRequest("nor_fishing_3d_caibei_all_info", nil, "请求数据")
end
function M.on_nor_fishing_3d_caibei_all_info_response(_, data)
    dump(data, "<color=red>on_nor_fishing_3d_caibei_all_info_response</color>")
    this.m_data.caibei_all_info = data.caibei_all_info
    this.m_data.free_caibei_obtain_info = data.free_caibei_obtain_info
    M.CheackDJS()
    Event.Brocast("model_by3d_act_xycb_all_info")
end
function M.on_nor_fishing_3d_free_caibei_obtain_response(_, data)
    dump(data, "<color=red>on_nor_fishing_3d_free_caibei_obtain_response</color>")
    if data.result == 0 then
        local pos = M.GetLastNullPos()
        if pos then
            this.m_data.caibei_all_info[pos].state = 1
            this.m_data.caibei_all_info[pos].type = data.type
            this.m_data.free_caibei_obtain_info = data.obtain_info
            Event.Brocast("model_nor_fishing_3d_free_caibei_obtain", {index = pos, type=data.type})
            M.CheckLFL()
        else
            print("<color=red>没有空的彩贝</color>")
        end
    else
        HintPanel.ErrorMsg(data.result)
    end
end

-- Fun
-- 获取开启中的彩贝数
function M.GetOpeningCBNum()
    local num = 0
    if this.m_data.caibei_all_info then
        local cur_t = os.time()
        for k,v in ipairs(this.m_data.caibei_all_info) do
            local cfg = this.UIConfig.caibei_list[v.index]
            if v.state == 2 then
                num = num + 1
            end
        end
    end
    return num
end
-- 开启彩贝的最大数
function M.GetOpeningCBMax()
    local max_open_bk_num = 1
    if VIPManager.get_vip_level() >= 5 then
        max_open_bk_num = 2
    end
    return max_open_bk_num
end
-- 当前拥有的彩贝数
function M.GetCurCBNum()
    local num = 0
    if this.m_data.caibei_all_info then
        for k,v in ipairs(this.m_data.caibei_all_info) do
            if v.state ~= 0 then
                num = num + 1
            end
        end
    end
    return num
end
-- 可拥有的彩贝最大数
function M.GetCBMaxNum()
    if VIPManager.get_vip_level() >= 3 then
        return 5
    else
        return 4
    end
end
-- 获取免费领取的CD
function M.GetFreeGetCD()
    local dd = this.m_data.free_caibei_obtain_info
    local cd = 0
    if dd then
        if dd.obtain_num > 0 and dd.obtain_num < this.UIConfig.free_get_max_num then
            local cur_t = os.time()
            local n = this.UIConfig.free_get_cd[dd.obtain_num]
            local tt = dd.last_obtain_time + n
            if tt > cur_t then
                return tt - cur_t
            end
        end
    end
    --dump({cd =cd,dd= dd},"<color=green>++++++++++++++++///++++++++++++++++</color>")
    return cd
end
-- 最近的一个空位置
function M.GetLastNullPos()
    for k,v in ipairs(this.m_data.caibei_all_info) do
        if v.state == 0 then
            return k
        end
    end
end

function M.GetIDConfig(id)
    return this.UIConfig.caibei_list[id]
end

function M.OpenXYCB(index)
    local send_data = {index=index}
    Network.SendRequest("nor_fishing_3d_caibei_start", send_data, "打开")
end
function M.on_nor_fishing_3d_caibei_start_response(_, data)
    dump(data, "<color=red>on_nor_fishing_3d_caibei_start_response</color>")
    if data.result == 0 then
        local index = data.index
        this.m_data.caibei_all_info[index].state = 2
        this.m_data.caibei_all_info[index].start_time = os.time()
        local cb_da = M.m_data.caibei_all_info[index]
        local cfg = M.GetIDConfig(cb_da.type)
        if cb_da.start_time ~= 0 then
            Event.Brocast("XYCB_CountDown_msg",cb_da.start_time + cfg.cd - os.time())
        end
        Event.Brocast("model_nor_fishing_3d_caibei_start", {index = index})
        M.CheckLFL()
        M.CheackDJS()
    else
        HintPanel.ErrorMsg(data.result)
    end
end
function M.FinishXYCB(index)
    local send_data = {index=index}
    Network.SendRequest("nor_fishing_3d_caibei_complete_use_jingbi", send_data, "完成")
end
function M.on_nor_fishing_3d_caibei_complete_use_jingbi_response(_, data)
    dump(data, "<color=red>on_nor_fishing_3d_caibei_complete_use_jingbi_response</color>")
    if data.result == 0 then
        local index = data.index
        this.m_data.caibei_all_info[index].state = 0
        this.m_data.caibei_all_info[index].start_time = 0
        this.m_data.caibei_all_info[index].type = 0
        Event.Brocast("XYCBManager_enter_lfl_msg",false)
        Event.Brocast("model_nor_fishing_3d_caibei_complete_use_jingbi", {index = index})
        M.CheckLFL()
        M.CheackDJS()
    else
        HintPanel.ErrorMsg(data.result)
    end
end
function M.AutoFinishXYCB(index)
    local send_data = {index=index}
    Network.SendRequest("nor_fishing_3d_caibei_complete", send_data, "完成")
end
function M.on_nor_fishing_3d_caibei_complete_response(_, data)
    dump(data, "<color=red>on_nor_fishing_3d_caibei_complete_response</color>")
    if data.result == 0 then
        local index = data.index
        this.m_data.caibei_all_info[index].state = 0
        this.m_data.caibei_all_info[index].start_time = 0
        this.m_data.caibei_all_info[index].type = 0
        this.m_data.countdown = 99999999999999999999999
        Event.Brocast("model_nor_fishing_3d_caibei_complete", {index = index})
        M.CheackDJS()
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function M.CheckLFL()
    local dd = this.m_data.free_caibei_obtain_info
    -- dump(dd,"<color=yellow>.............................</color>")
    --dump(this.m_data.countdown,"<color=green>++++++++++++++Manager++++++++++++</color>")
    if (M.GetFreeGetCD() == 0 and dd and dd.obtain_num < this.UIConfig.free_get_max_num) then
        Event.Brocast("XYCBManager_enter_lfl_msg",true,"lcb")
    elseif ((M.GetOpeningCBMax() > M.GetOpeningCBNum()) and ((M.GetCurCBNum() - M.GetOpeningCBNum()) > 0)) or ((M.GetCurCBNum() > 0) and this.m_data.countdown <= 0) then
        --dump(((M.GetOpeningCBMax() > M.GetOpeningCBNum()) and ((M.GetCurCBNum() - M.GetOpeningCBNum()) > 0)),"<color=yellow>..............11...............</color>")
        --dump(((M.GetCurCBNum() > 0) and this.m_data.countdown <= 0),"<color=yellow>..............22...............</color>")
        Event.Brocast("XYCBManager_enter_lfl_msg",true,"lfl")
    else
        Event.Brocast("XYCBManager_enter_lfl_msg",false)
    end
end

function M.MFLQUpdataTimer()   
    M.StopMFLQUpdataTimer()
    M.CheckLFL()
    this.m_data.mflqtimer = Timer.New(function ()
        M.CheckLFL()
    end,3,-1,true)
    this.m_data.mflqtimer:Start()
end

function M.StopMFLQUpdataTimer()
    if this and this.m_data.mflqtimer then
        this.m_data.mflqtimer:Stop()
        this.m_data.mflqtimer = nil
    end
end


function M.CountDownTimer(time)
    if time < this.m_data.countdown then
        this.m_data.countdown = time
    end
    M.StopCountDownTimer()
    this.m_data.CountDownTimer = Timer.New(function ()
        this.m_data.countdown = this.m_data.countdown - 1
    end,1,-1,true)
    this.m_data.CountDownTimer:Start()
end

function M.StopCountDownTimer()
    if this and this.m_data.CountDownTimer then
        this.m_data.CountDownTimer:Stop()
        this.m_data.CountDownTimer = nil
    end
end


local time_tab = {}
local timer_tab = {}
function M.CheackDJS()
    local cb_da = {}
    local cfg = {}
    local time = 0
    --dump(this.m_data.caibei_all_info,"<color=yellow>++++++++++/////+++++++++++++</color>")
    for i=1,#this.m_data.caibei_all_info do
        cb_da = this.m_data.caibei_all_info[i]
        cfg = M.GetIDConfig(cb_da.type)
        if cfg then
            time = cb_da.start_time + cfg.cd - os.time()
            time_tab[cb_da.index] = time
        else
            time_tab[cb_da.index] = 0
        end
    end
    M.EnterCountDownTimer()
end


function M.EnterCountDownTimer()
    M.StopEnterCountDownTimer()
    for k,v in pairs(time_tab) do
        if (v > 0) then            
            Event.Brocast("fishing3d_xycb_djs_msg",v)
        else
            Event.Brocast("fishing3d_xycb_djs_msg",nil) 
            if timer_tab[k] then
                timer_tab[k]:Stop()
                timer_tab[k] = nil 
            end
        end
        v = v - 1
        local pre = Timer.New(function ()
            if (v > 0) then            
                Event.Brocast("fishing3d_xycb_djs_msg",v)
            else
                Event.Brocast("fishing3d_xycb_djs_msg",nil) 
                if timer_tab[k] then
                    timer_tab[k]:Stop()
                    timer_tab[k] = nil 
                end
            end
            v = v - 1
            --dump({v=v,timer_tab= timer_tab,time_tab = time_tab},"<color=red>++++++++++/////+++++++++++++</color>")
        end,1,-1,true)
        pre:Start()
        timer_tab[k] = pre
    end
end

function M.StopEnterCountDownTimer()
    if not table_is_null(timer_tab) then
        for k,v in pairs(timer_tab) do
            v:Stop()
            v = nil
        end
    end
end