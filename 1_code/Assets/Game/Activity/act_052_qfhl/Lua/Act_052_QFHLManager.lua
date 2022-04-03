-- 创建时间:2020-12-07
-- Act_052_QFHLManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_052_QFHLManager = {}
local M = Act_052_QFHLManager
M.key = "act_052_qfhl"
M.task_id = 0

M.config = GameButtonManager.ExtLoadLua(M.key,"activity_052_qfhl_config")
GameButtonManager.ExtLoadLua(M.key,"Act_052_QFHLPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_052_QFHLBeforePanel")
M.ItemName = "灯笼"
M.ChooseIndex=0
local this
local lister

 ---获取配置信息id类型
 function M.GetCurID()
    for i,v in ipairs(M.config.cfg) do
        if os.time() < v.e_time and os.time() >= v.s_time then
            local _permission_key=v.condiy_key
            if _permission_key then
                local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = _permission_key, is_on_hint = true}, "CheckCondition")
                if a and  b then
                   return v.ID
                end
            else
                return v.ID
            end
        end
    end 
end


-- 是否有活动
function M.IsActive()
    local cfg_id = M.GetCurID()
    if cfg_id then
        this.m_data.PerNeed = M.config.cfg[cfg_id].PerNeed[1]
        this.m_data.base_award_num = M.config.cfg[cfg_id].PerNeed[2]
        this.m_data.lottery_key = M.config.cfg[cfg_id].pay_item_key[1]
        this.m_data.base_award_key = M.config.cfg[cfg_id].pay_item_key[2]
        this.m_data.activeStratTime = M.config.cfg[cfg_id].s_time
        this.m_data.activeEndTime = M.config.cfg[cfg_id].e_time
        this.m_data.data_type = M.config.cfg[cfg_id].data_type
        this.m_data.data_other_type = M.config.cfg[cfg_id].data_other_type
        return true
    end
    dump("<color=red><size=18>+++++Error 错误！！！未获取到配置的 id ++++++++++</size></color>")
    dump("<color=red><size=18>+++++Error 错误！！！未获取到配置的 id ++++++++++</size></color>")
    return false
end
-- 创建入口按钮时调用
function M.CheckIsShow()
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end
function M.GetActivityTime()
    return this.m_data.activeStratTime,this.m_data.activeEndTime
end
function M.GetDataType()
    return this.m_data.data_type
end
function M.GetDataOtherType()
    return this.m_data.data_other_type
end
-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        if M.IsActive() then
            return Act_052_QFHLPanel.Create(parm.parent)
        end
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if M.GetNowTaskType()==0 then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get   
    end
    local task_data = GameTaskModel.GetTaskDataByID(M.task_id)
    if (task_data and task_data.award_status == 1) or GameItemModel.GetItemCount(this.m_data.lottery_key) >= this.m_data.PerNeed*10 then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get   
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
    lister["AssetChange"] = this.on_AssetChange
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["query_xsyd_status_response"] = this.on_query_xsyd_status_response
    
    lister["set_xsyd_status_response"] = this.on_set_xsyd_status_response 
end

function M.Init()
	M.Exit()

	this = Act_052_QFHLManager
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
    this.UIConfig.award_map = {}   
    for k,v in ipairs(M.config.Award1) do
        if v.server_award_id then
            this.UIConfig.award_map[v.server_award_id] = v
        end
    end
end

function M.GetCurrIndex(times)
    local num = GameItemModel.GetItemCount(this.m_data.lottery_key)
    if num >= times * 4 then
        return 1
    else
        return 2
    end
end
function M.query_xsyd_status()
    dump(1,"<color=yellow>请求获取选择状态：</color>")
	Network.SendRequest("query_xsyd_status", { xsyd_type = "qfhl_lottery"})
end
function M.on_query_xsyd_status_response(_,data)
    dump(data,"<color=yellow>服务器返回的祈福豪礼选择:  </color>")
    if data and data.result==0 and data.xsyd_type=="qfhl_lottery" then
        -- body
        if data.status and this.m_data.activeStratTime and data.time > this.m_data.activeStratTime then
            this.m_data.qfhl_lottery=data.status
            if data.status~=0 then
                -- body
                M.task_id=M.config.All_Task[data.status].task_id
                dump(M.task_id,"task_id---->")
            end
        else
            this.m_data.qfhl_lottery=0
        end
    end
end
function M.on_set_xsyd_status_response(_,data)
    dump(data,"<color=yellow>设置任务类型结束:  </color>")
    if data and data.result==0 then
        if M.ChooseIndex~=0 then
            this.m_data.qfhl_lottery=M.ChooseIndex
            Event.Brocast("set_qfhl_lottery_success")
            Event.Brocast("global_hint_state_set_msg",{ gotoui = M.key })
            M.task_id=M.config.All_Task[M.ChooseIndex].task_id
            dump(M.task_id,"task_id---->")

            Network.SendRequest("query_one_task_data", { task_id =M.task_id})
        end
       
    end
end
function M.GetNowTaskType()
    dump(this.m_data.qfhl_lottery,"祈福好礼难度：  ")
    return this.m_data.qfhl_lottery
end

function M.GetAwardSwInfo(index)
    if index and index <= #M.config.Award_sw then
        return  M.config.Award_sw[index]
    end
    local  type = this.m_data.qfhl_lottery or 0
    if type>0 then
        return  M.config.Award_sw[type]
    end
end
function M.GetBoxExchangID(index)
    if index and index <= #M.config.All_Task then
        return  M.config.All_Task[index].change_type
    end
    local  type = this.m_data.qfhl_lottery
    if type>0 then
        return  M.config.All_Task[type].box_exchange_id
    end
end
--获取奖励config
function M.GetAwardConfigByAwardID(award_id)
    return this.UIConfig.award_map[award_id]
end
function M.ChooseIndexBuff(_index)
    M.ChooseIndex=_index
end
function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        M.IsActive()
        M.query_xsyd_status()
	end
end

function M.OnReConnecteServerSucceed()
end

function M.on_AssetChange()
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
end


function M.SetCurSWData(_sw_data)
    this.m_data.sw_data=_sw_data
end
function M.ShowSWHintPannel()
	dump( this.m_data.sw_data," this.m_data.sw_data-->")
	if  this.m_data.sw_data and  # this.m_data.sw_data>0 then
		M.SWAwardTipIndex=1
		M.ShowOneSWHintPanel()
	end
end

function M:ShowOneSWHintPanel()
	dump(M.SWAwardTipIndex,"ShowOneSWHintPanel:  ")

	if M.SWAwardTipIndex>#this.m_data.sw_data then
		return
	end
	local swdataItem=this.m_data.sw_data[M.SWAwardTipIndex]
	local key=swdataItem.desc
	local num=swdataItem.num

	local string1
	if num>1 then
		string1 = "恭喜您刚刚抽中【"..key .."】*".. num ..",请联系客服QQ号4008882620领取"
	else
		string1 = "恭喜您刚刚抽中【"..key .."】,请联系客服QQ号4008882620领取"
	end
	local pre = HintCopyPanel.Create({desc=string1, isQQ=true,copy_value = "4008882620",callback=function ()
		M.SWAwardTipIndex=M.SWAwardTipIndex+1
		dump(M.SWAwardTipIndex,"CALLBACKindex:  ")
		M.ShowOneSWHintPanel()
	end})
	pre:SetCopyBtnText("复制QQ号")
end

function M.GetCurItemImage(type)    
    if type==1 then
        return GameItemModel.GetItemToKey(this.m_data.lottery_key).image
    elseif type==2 then
        return GameItemModel.GetItemToKey(this.m_data.base_award_key).image
    end
end
function M.GetCurItemDec(type)
    if type==1 then
        return GameItemModel.GetItemToKey(this.m_data.lottery_key).name
    elseif type==2 then
        return GameItemModel.GetItemToKey(this.m_data.base_award_key).name,this.m_data.base_award_num
    end
end