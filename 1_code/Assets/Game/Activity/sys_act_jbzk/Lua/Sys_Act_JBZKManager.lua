-- 创建时间:2021-02-08
-- Sys_Act_JBZKManager 管理器

local basefunc = require "Game/Common/basefunc"
Sys_Act_JBZKManager = {}
local M = Sys_Act_JBZKManager
M.key = "sys_act_jbzk"

GameButtonManager.ExtLoadLua(M.key,"Sys_Act_JBZKPanel")
GameButtonManager.ExtLoadLua(M.key,"SYSJBZK_JYFLEnterPrefab")
local jbzk_cfg = GameButtonManager.ExtLoadLua(M.key,"sys_act_jbzk_cfg")

local this
local lister

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间

    -- local e_time
    -- local s_time
    -- if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
    --     return false
    -- end

    -- 对应权限的key
    if not this.m_data.is_active then
        return false
    end
    if this.m_data and this.m_data.s_data and this.GetIsOverTimeState() then
        return false
    end
    local platformInfo = 
    {
        [1]={
            condiy_key = "cpl_notcjj",
            unlockType=0,
        },
        [2]={
            condiy_key="cpl_cjj",
            unlockType=1,
        },
    }
    for i,v in ipairs(platformInfo) do
        local _permission_key=v.condiy_key
        if _permission_key then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
            if a and  b then
              this.platformInfo=v
            return true
            end
        
        else
            return true
        end
    end
    
end
-- 创建入口按钮时调用
function M.CheckIsShow(parm, type)
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end


local firstOpenPanel = false
-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.first_open then
        dump(this.m_data,"新人限时福利激活时第一次打开弹窗")
        if  this.m_data.s_data.active_time==0 then
            firstOpenPanel=true
            Network.SendRequest("activate_jbzk")
            return
        end
    end
    if not M.CheckIsShow(parm) then
        dump(parm, "<color=red>不满足条件</color>")
        return
    end
    if parm.goto_scene_parm == "jyfl_enter" then
        return SYSJBZK_JYFLEnterPrefab.Create(parm.parent, parm)
    elseif parm.goto_scene_parm=="panel" then   
    
        return Sys_Act_JBZKPanel.Create()
    end

    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)   
    -- dump(this.m_data,"获取红点信息： ")
    if this.m_data.is_active then
        if this.m_data.s_data.can_award==1 and not this.m_data.issameday and not this.m_data.is_Over_Active then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
    else
        return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
    end
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

    lister["activate_jbzk_response"]=this.activate_jbzk_response
    lister["query_jbzk_info_response"]=this.query_jbzk_info_response

end

function M.Init()
	M.Exit()

	this = Sys_Act_JBZKManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
    this.UIConfig.config=jbzk_cfg.config
    this.UIConfig.platform=jbzk_cfg.platform
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        -- dump(1,"<color=yellow>发送获取当前服务端金币周卡数据申请！！！！</color>")
        Network.SendRequest("query_jbzk_info") 
	end
end
function M.OnReConnecteServerSucceed()
end

function M.GetJbzkCfg()
    -- body

    return this.UIConfig.config
end

function M.GetJbzkMdataInfo( ... )
    -- body
    if this.m_data then
        -- dump(this.m_data,"获取初始化pannel 信息")
        return this.m_data.s_data.can_award==1,this.m_data.s_data.award_day_num,this.m_data.issameday
    else
        dump(this.m_data,"<color=red>获取当前服务端数据出错！！！！！！！！！</color>")
    end
end

function M.GetJbzkActivationState( ... )
    -- body
    if this.m_data and this.m_data.is_active then
        return this.m_data.is_active
    else
        return false
    end
end
function M.GetPlatformInfo( ... )
    -- body
    if this.platformInfo then
        return this.platformInfo
    else
        M.CheckIsShow()
        return this.platformInfo
    end

end

function M.activate_jbzk_response(_,data)
    -- body
    -- dump("金币周卡激活成功！！！！")
    if data and data.result==0 then
        Network.SendRequest("query_jbzk_info") 
    end
end
function  M.query_jbzk_info_response(_,data)
    -- body
    dump(data,"<color=yellow> 当前金币周卡服务端数据</color>")
    if data and data.result==0 then
        this.m_data={}
        this.m_data.s_data=data
         local lastGotTime = this.m_data.s_data.last_award_time;
        local issameday = this.JudgeIsSameDay(lastGotTime,os.time())
        -- local issameday = this.JudgeIsSameDay(1613951030,1613900630)
        this.m_data.issameday=issameday

        local acttiveTime = this.m_data.s_data.active_time 
        if acttiveTime>0 then
            this.m_data.is_active=true
            local activeZeroTime = acttiveTime-(acttiveTime+8*3600)%86400
            -- dump(activeZeroTime,"激活当天零点的时间戳是：   ")
            this.m_data.activeEndtime = activeZeroTime+60*60*24*7-1
            -- dump(this.m_data.activeEndtime,"激活七天后的时间戳是：   ")
            local  remaiday = this.GetCurRemainTime()
            this.m_data.is_Over_Active=this.m_data.activeEndtime<os.time() or (remaiday==0 and issameday )
        else
            this.m_data.is_active=false
        end

       
        -- dump(this.m_data,"金币周卡manager_m_data:")
        Event.Brocast("global_hint_state_change_msg", {gotoui=M.key})
        Event.Brocast("jbzk_enter_refresh")
        if firstOpenPanel then
            -- dump(firstOpenPanel,"第一次打开弹窗！！！！")
            Sys_Act_JBZKPanel.Create()
            firstOpenPanel=false
        end

    else
        dump(data,"<color=red>获取当前服务端数据出错！！！！！！！！！</color>")
    end
end

function  M.GetCurRemainTime( ... )
    -- body
    if this.m_data and this.m_data.activeEndtime then
        local restTime=this.m_data.activeEndtime - os.time()
        local day =math.floor( restTime/60/60/24)
        local hour = math.floor(restTime%(60*60*24)/60/60)
        local min=math.floor(restTime % 3600 / 60)
        -- local  timestr = StringHelper.formatTimeDHMS(restTime)
        -- print(day.."   "..hour.."  "..min)
        return day,hour,min
    else
        dump(this.m_data,"<color=red>this.m_data 参数未初始化！！！！</color>")
        return 0,0,0
    end

end

function M.GetIsOverTimeState()
    -- body
    if this.m_data and this.m_data.is_Over_Active then
        return true
    else
        return false
    end
end
function M.JudgeIsSameDay(last_reset_time,cur_time)
    -- body
    local isSame = false
    local daily_reset_time = 0

    function BetweenDays(time1,time2)
        local time_zone = 8
        return math.floor((time1 + time_zone *3600)/3600/24) - math.floor((time2 + time_zone *3600)/3600/24);
    end

    return BetweenDays(cur_time - 3600 * daily_reset_time, last_reset_time - 3600 * daily_reset_time) == 0;
end
