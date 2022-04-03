-- 创建时间:2021-05-06
-- SYS_TXZ_Manager 管理器

local basefunc = require "Game/Common/basefunc"
SYS_TXZ_Manager = {}
local M = SYS_TXZ_Manager
M.key = "sys_txz"

GameButtonManager.ExtLoadLua(M.key,"SYS_TXZ_Enter")
GameButtonManager.ExtLoadLua(M.key,"SYS_TXZ_Panel")
GameButtonManager.ExtLoadLua(M.key,"sys_txz_listitem")
GameButtonManager.ExtLoadLua(M.key,"sys_txz_awarditem_1")
GameButtonManager.ExtLoadLua(M.key,"sys_txz_awarditem_2")
GameButtonManager.ExtLoadLua(M.key,"sys_txz_taskitem")
GameButtonManager.ExtLoadLua(M.key,"SYS_TXZ_NodePanel")
GameButtonManager.ExtLoadLua(M.key,"SYS_TXZ_TaskPanel")
GameButtonManager.ExtLoadLua(M.key,"SYS_TXZ_ProgresPanel")
GameButtonManager.ExtLoadLua(M.key,"SYS_TXZ_ChoosePanel")
GameButtonManager.ExtLoadLua(M.key,"SYS_TXZ_AwardGetPanel")
GameButtonManager.ExtLoadLua(M.key,"SYS_TXZ_TipPanel")
GameButtonManager.ExtLoadLua(M.key,"sys_txz_leveluptip_pannel")
GameButtonManager.ExtLoadLua(M.key,"SYSTXZ_JYFLEnterPrefab")

M.txz_config=GameButtonManager.ExtLoadLua(M.key,"sys_txz_config")
M.MaxLevel=197

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
function M.CheckIsShow(parm, type)
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if not M.CheckIsShow(parm) then
        dump(parm, "<color=red>不满足条件</color>")
        return
    end
    if parm.goto_scene_parm=="enter" then
        return SYS_TXZ_Enter.Create(parm.parent)
    elseif parm.goto_scene_parm=="panel" then
        return SYS_TXZ_Panel.Create()
    elseif parm.goto_scene_parm=="panel_open" then
        local isopen=PlayerPrefs.GetInt("txzbaner_open" .. MainModel.UserInfo.user_id, 0)
        if isopen==0 then
            PlayerPrefs.SetInt("txzbaner_open" .. MainModel.UserInfo.user_id, 1)
            return SYS_TXZ_Panel.Create(nil,parm.backcall)
        end
    elseif parm.goto_scene_parm=="choose" then
        return SYS_TXZ_ChoosePanel.Create()
    elseif parm.goto_scene_parm == "jyfl_enter" then
        return SYSTXZ_JYFLEnterPrefab.Create(parm.parent, parm)
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if parm.gotoui==M.key then
        if M.IsHaveFL() then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        end
    end
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
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
    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["finish_gift_shop"] = M.on_finish_gift_shop
    
    lister["AssetChange"]=this.OnAssetChange
end

function M.Init()
	M.Exit()

	this = SYS_TXZ_Manager
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
end
----获取通行证等级奖励任务信息
function M.InitTxzTaskInfo()
    M.RefreshLevelTaskData()
    -- dump(this.m_data,"<color=yellow>通行证任务信息：  </color>")
    Event.Brocast("refresh_txz_level_task_data")
end
function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        M.DalayTimer=Timer.New(function ()
            M.RefreshLevelTaskData()
            M.DalayTimer:Stop()
        end,2,-1)
        M.DalayTimer:Start()
	end
end

function M.OnReConnecteServerSucceed()
end

function M.IsHaveFL()
    return this.m_data.redState==ACTIVITY_HINT_STATUS_ENUM.AT_Get
end
---是否购买礼包
function M.IsHaveBuyBag()
    local buytxztype=M.GetBuyBagType()
    return  buytxztype>0
end

function M.GetTXZProgressInfo()
    local nowtxztype=M.GetBuyBagType()
    return this.m_data.levelAward[nowtxztype+1]
end
function M.GetBuyBagLevelTaskInfo(buytxztype)
    return this.m_data.levelAward[buytxztype+1]
end
function M.GetTXZAwardConfigInfo()
    return M.txz_config.commonAward
end
function M.GetTXZTaskConfigInfo()
    local taskData={}
    for index, value in ipairs(M.txz_config.TXZ_Task) do
        local isShow=true
        if value.condi_key then
            -- dump(M.JudgeCondition(value.condi_key),value.condi_key.."----->")
            isShow=M.JudgeCondition(value.condi_key)
        end
        if isShow then
            taskData[#taskData+1] = value
        end
    end
    return taskData
end

---获取任务状态信息（进度，是否可以领取）
function M.GetTXZTaskStateInfo()
    
end
----获取通行证倒计时
function M.GetTXZActEndTime()
    local buytxztype=M.GetBuyBagType()
    if buytxztype==0 then
        return  nil
    else
        if this.m_data.levelAward[buytxztype+1].other_data_str then
            local other = basefunc.parse_activity_data(this.m_data.levelAward[buytxztype+1].other_data_str)
            return other.end_time
        end
    end
    return nil
end
M.buytxztypebuff=-1
function M.GetBuyBagType()
    if not this.m_data.levelAward then
        return 0
    end
    if this.m_data.buytxztype then
        return this.m_data.buytxztype
    end
    local buytxztype=0
    -- local shopids=M.txz_config.shopIDs[1]
  
    -- if MainModel.GetGiftShopStatusByID(shopids.haiwang) == 0 then
    --     buytxztype=1
    -- elseif  MainModel.GetGiftShopStatusByID(shopids.haiwangSpe) == 0  then
    --     buytxztype=2
    -- end
    -- dump(MainModel.GetGiftShopStatusByID(10563),"礼包购买状态1：  ")
    -- dump(MainModel.GetGiftShopStatusByID(10564),"礼包购买状态2：  ")
    
    
    if this.m_data.levelAward[2] and this.m_data.levelAward[2].other_data_str then
        local temp_tab2 = basefunc.parse_activity_data(this.m_data.levelAward[2].other_data_str)
        if not table_is_null(temp_tab2) then
            buytxztype=1
        end
    end
    if this.m_data.levelAward[3] and this.m_data.levelAward[3].other_data_str then
        local temp_tab3 = basefunc.parse_activity_data(this.m_data.levelAward[3].other_data_str)
        if not table_is_null(temp_tab3) then
            buytxztype=2
        end
    end

    -- dump(buytxztype,"通行证礼包购买状态：  ")
    this.m_data.buytxztype=buytxztype

    if M.buytxztypebuff==-1 then
        M.buytxztypebuff=buytxztype
    else
       if  M.buytxztypebuff~=buytxztype then
           M.buytxztypebuff=buytxztype
           Event.Brocast("refresh_txz_buytype")
       end 
    end
    
    return buytxztype
end
----获取普通等级奖励
function M.OnAssetChange(data)
    if data.change_type and data.change_type == "task_aquaman_passport_base" then
        if #data.data==1 and M.GetBuyBagType()==0 then
            SYS_TXZ_AwardGetPanel.Create(data.data)
        else
            M.Award_Data = data
            M.SetAwardIcon()
            
            local pre = AssetsGet50Panel.Create(M.Award_Data.data, function ()
            end,nil,nil,false)
            pre.info_desc_txt.transform.localPosition = Vector3.New(0, -325, 0)
        end
	end
end
function M.SetAwardIcon()
	for i=1,#M.Award_Data.data do
		local itemInfo=GameItemModel.GetItemToKey(M.Award_Data.data[i].asset_type)
		M.Award_Data.data[i].icon=itemInfo.image
        local value=StringHelper.ToCash(M.Award_Data.data[i].value) 
        M.Award_Data.data[i].desc=itemInfo.name.."x"..value
        -- M.Award_Data.data[i].desc_extra=itemInfo.desc_extra
	end
end
----监听任务 通行证符合升级条件时
function M.on_model_task_change_msg(data)
    local isRefresh=false
    if data.id==M.txz_config.TXZ_buytask[1].task_id or data.id==M.txz_config.TXZ_buytask[2].task_id
        or data.id==M.txz_config.TXZ_buytask[3].task_id  then
        isRefresh=true
        M.RefreshLevelTaskData()
    end
   
    for index, value in ipairs(M.txz_config.TXZ_Task) do
        if value.task==data.id then
            -- dump(data,"通行证任务刷新： ")
            if not isRefresh then
                M.ChargeNowAndCanGetLevel()
            end
            Event.Brocast("refresh_txz_taskitem")
            break
        end
    end
end

function M.RefreshLevelTaskData()
    local taskIds=M.txz_config.TXZ_buytask
    this.m_data={}
    this.m_data.levelAward={}
    this.m_data.AwardStateTab={}
    this.m_data.redState=ACTIVITY_HINT_STATUS_ENUM.AT_Nor
    for index, value in ipairs(taskIds) do
        local isShow=true
        if value.condi_key then
            isShow=M.JudgeCondition(value.condi_key)
        end
        if isShow then
            local taskData= GameTaskModel.GetTaskDataByID(value.task_id)
            if taskData then
                this.m_data.levelAward[#this.m_data.levelAward+1] =taskData
                local b = basefunc.decode_task_award_status(taskData.award_get_status)
                this.m_data.AwardStateTab[#this.m_data.AwardStateTab+1] = basefunc.decode_all_task_award_status(b, taskData, M.MaxLevel)
                if index==1 or (taskData.other_data_str) then
                        if  taskData.award_status==1 and this.m_data.redState~=ACTIVITY_HINT_STATUS_ENUM.AT_Get then
                            this.m_data.redState=ACTIVITY_HINT_STATUS_ENUM.AT_Get
                        end
                end 
            end
        end
       
     
    end
    
    M.SetHintState()
    Event.Brocast("refresh_txz_level_task_data")
    Event.Brocast("refresh_txzaward_listitem")

    -- dump(this.m_data.AwardStateTab,"this.m_data.AwardStateTab:  ")
    -- dump(this.m_data.levelAward,"通行证等级任务刷新：  ")

    M.ChargeNowAndCanGetLevel()

end

function M.JudgeCondition(_permission_key)
	if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and  b then    
            return true
        end
        return false
    else
        return false
    end
end
local showTipsLevel=0
function M.ChargeNowAndCanGetLevel()
    if not this.m_data or not this.m_data.levelAward or not this.m_data.levelAward[1] then
        return
    end
    local commonLevelData = this.m_data.levelAward[1]
    if (this.m_last_data and commonLevelData.now_lv ~= 1 and this.m_last_data.now_lv ~= commonLevelData.now_lv) then
        --sys_txz_leveluptip_pannel.Create(commonLevelData.now_lv - 1)
    end
    this.m_last_data = commonLevelData

end

----获取每个奖励领取状态
function M.GetAwardItemGotState(level,_type)
    if _type then
        if this.m_data.AwardStateTab and this.m_data.AwardStateTab[_type+1] then
            return this.m_data.AwardStateTab[_type+1][level]
        end
    else
        if this.m_data.AwardStateTab and this.m_data.AwardStateTab[1] then
            return this.m_data.AwardStateTab[1][level]
        end
    end
    return 2
end

function M.GetShopIDs()
    return M.txz_config.shopIDs[1]
end
function M.GetNowLevel()
    if this.m_data.levelAward[1].now_lv==M.MaxLevel and this.m_data.levelAward[1].now_process==this.m_data.levelAward[1].need_process then
        return this.m_data.levelAward[1].now_lv
    end
    return this.m_data.levelAward[1].now_lv-1
end
function M.GetOneLevelInfo(level)
    local offset=level%10
    if offset==0 then
        return M.txz_config.commonAward[10]
    else
        return M.txz_config.commonAward[offset]
    end
end
function M.GetNextTenLevelInfo()
    local now_Level=this.m_data.levelAward[1].now_lv
    local nexttenLevel=math.floor(now_Level/10+1)*10
    if nexttenLevel>M.MaxLevel then
        nexttenLevel=M.MaxLevel
        return M.GetOneLevelInfo(M.MaxLevel%10),nexttenLevel
    end
    return M.GetOneLevelInfo(10),nexttenLevel 
end
function M.GetNextLevelInfo()
    local levelData=M.GetTXZProgressInfo()
    local now_Level=levelData.now_lv
    local info=nil
    if now_Level<M.MaxLevel then
        local nextLevel=now_Level
        info=M.GetOneLevelInfo(nextLevel)
    else
        info=M.GetOneLevelInfo(M.MaxLevel)
    end
    return info
    
end
function M.GetMinCanGetAwardLevel()
    local location_value=0
    local gotMaxLevel=0
    local buytxztype=M.GetBuyBagType()
    dump(this.m_data.AwardStateTab,"AwardStateTab:  ")
    for index, value in ipairs(this.m_data.AwardStateTab[buytxztype+1]) do
        if value==1 then
            location_value=index
            break
        end
        if value==2 then
            gotMaxLevel=index
        end
    end
    
    if location_value~=0 then
        return location_value
    else
        if gotMaxLevel==0 then
            return 1
        end
        return gotMaxLevel+1
    end
end
function M.GetCommonLevelTaskID()
    return M.txz_config.TXZ_buytask[1].task_id
end
function M.GetHaiWangLevelTaskID()
    local buytxztype=M.GetBuyBagType()
    return M.txz_config.TXZ_buytask[buytxztype+1].task_id
end
function M.GetTaskRedState()
    if this.m_data.taskRedState then
        return this.m_data.taskRedState
    end
    return false
end

function M.on_finish_gift_shop(id)
    local tab = M.GetShopIDs()
    if id == tab.haiwang or id == tab.haiwangSpe then
        local task_data = GameTaskModel.GetTaskDataByID(30004)
        if task_data and task_data.award_status == 1 then
            Network.SendRequest("get_task_award",{id = 30004})
        end
    end
end
--@dump(SYS_TXZ_Manager.GetCurCanGetAwardCount())
function M.GetCurCanGetAwardCount()
    local count = 0
    for i=1,M.MaxLevel do
        for j=1,3 do
            if (j == 1) or ((j - 1) == M.GetBuyBagType()) then
                local state = M.GetAwardItemGotState(i,j - 1)
                if state == 1 then
                    count = count + 1
                end
            end
        end
    end
    return count
end

function M.CheckShowExitAsk()
    local data1 = M.IsHaveFL()
    local data2 = M.GetCurCanGetAwardCount() .. "项奖励可领"
    local data3 = function ()
        SYS_TXZ_Panel.Create()   
    end
    return data1,data2,data3
end