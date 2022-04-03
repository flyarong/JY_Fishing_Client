-- 创建时间:2020-10-26
-- Act_TY_JZSJBManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_TY_JZSJBManager = {}
local M = Act_TY_JZSJBManager
M.key = "act_ty_sjb"
GameButtonManager.ExtLoadLua(M.key, "Act_TY_JZSJBPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_TY_JZSJBPanel_New")
GameButtonManager.ExtLoadLua(M.key, "Act_TY_JZSJBEXTRAPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_TY_JZSJBEXTRAItemBase")
GameButtonManager.ExtLoadLua(M.key, "Act_TY_JZSJBPopupPanel")

M.config_all = GameButtonManager.ExtLoadLua(M.key, "act_ty_phb_config")
M.config = M.config_all.config
local this
local lister


 ---获取排行榜类型
function M.GetCurID()
    for i,v in ipairs(M.config) do
        if os.time() < v.e_time and os.time() >= v.s_time and v.is_on_off == 1 then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = v.condiy_key, is_on_hint = true}, "CheckCondition")
            if a and b then
               return v.ID
            end
        end
    end 
end

-- 是否有活动
function M.IsActive()
    local rank_id = M.GetCurID()
    if rank_id then
        this.m_data.rank_id = rank_id
        this.m_data.rank_type = M.config[rank_id].rank_type --排行榜类型
        this.m_data.extra_award = M.config[rank_id].extra_award
        this.m_data.activeStartTime=M.config[rank_id].s_time
        this.m_data.activeEndTime=M.config[rank_id].e_time
        this.m_data.type_info = M.config[rank_id].type_info
        this.have_point = M.config[rank_id].is_have_point
        return true
    end
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
function M.GetActivityStartTime()
    return this.m_data.activeStartTime
end
function M.GetActivityEndTime()
    return this.m_data.activeEndTime
end
-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if not M.CheckIsShow(parm) then
        return
    end
    if parm.goto_scene_parm == "panel" then
        if this.m_data.extra_award then
            return Act_TY_JZSJBPanel_New.Create(parm.parent, "sjb")
        else
            return Act_TY_JZSJBPanel.Create(parm.parent, "sjb")
        end
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
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
    lister["year_btn_created"] = this.on_year_btn_created
    lister["EnterScene"] = M.EnterScene
    lister["ExitScene"] = M.ExitScene
    lister["query_rank_base_info_response"] = this.query_rank_base_info_response
    lister["ActivityYearPanel_had_exit_msg"] = this.on_ActivityYearPanel_had_exit_msg
end

function M.Init()
	M.Exit()

	this = Act_TY_JZSJBManager
    this.m_data = {}
    this.m_data.mydata = {}
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
    this.UIConfig.rank_type_map = {}
    this.UIConfig.award_map = {}

    for k,v in pairs(M.config) do
        this.UIConfig.rank_type_map[k] = v
    end
    this.UIConfig.award_map = M.config_all.award_config
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        if M.IsActive() then
            Network.SendRequest("query_rank_base_info",{rank_type = this.m_data.rank_type})
        end
	end
end
function M.OnReConnecteServerSucceed()
end

function M.GetRankData(rank_type)
    local temp = {}
    temp = basefunc.deepcopy(this.m_data.mydata)
    if this.have_point == 1 then
        if  this.m_data.mydata and this.m_data.mydata[rank_type] then
            if math.floor(this.m_data.mydata[rank_type].score/this.m_data.type_info) == (this.m_data.mydata[rank_type].score/this.m_data.type_info) then
                temp[rank_type].score = this.m_data.mydata[rank_type].score/this.m_data.type_info
            else
                temp[rank_type].score=string.format("%.1f", this.m_data.mydata[rank_type].score/this.m_data.type_info) 
            end
        end
        if temp[rank_type].score == "0.0" then
            temp[rank_type].score=0
        end
    else
        if this.m_data.mydata and this.m_data.mydata[rank_type] then
            temp[rank_type].score = math.floor(this.m_data.mydata[rank_type].score/this.m_data.type_info)
        end 
    end
    return temp[rank_type]
end

function M.GetCurTypeInfo()
    return this.m_data.type_info
end

function M.QueryMyData(rank_type)
    Network.SendRequest("query_rank_base_info",{rank_type = rank_type})
end


function M.query_rank_base_info_response(_,data)
    if data and data.result == 0 and this.m_data.rank_type and (this.m_data.rank_type == data.rank_type) then
        this.m_data.mydata[data.rank_type] = data
        Event.Brocast("act_jzsjb_base_info_get",{rank_type = data.rank_type})
    end
end

function M.EnterScene()
  
end
function M.ExitScene()
   
end

function M.GetBestRank()
    local best_rank = 100000
    for k,v in pairs(this.m_data.mydata) do
        if v.rank > 0 and v.rank < best_rank then
            best_rank = v.rank
        end
    end
    return best_rank
end

function M.GerCurAwardConfig()
    local _award_table = {}
    for k,v in pairs(this.UIConfig.rank_type_map[this.m_data.rank_id].award) do
        _award_table[#_award_table + 1] = this.UIConfig.award_map[v]
    end
    return _award_table
end

function M.GerCurExtraAwardConfig()
    local _award_table = {}
    for k,v in pairs(this.UIConfig.rank_type_map[this.m_data.rank_id].extra_award) do
        _award_table[#_award_table + 1] = this.UIConfig.award_map[v]
    end
    return _award_table
end

--type=1 是掉落的图标key，等于2是 奖励奖励的图标key    3是 额外奖励的图标key
function M.GetCurItemImage(type)    
    if type==1 then
        return GameItemModel.GetItemToKey(this.UIConfig.rank_type_map[this.m_data.rank_id].item_key).image
    elseif type==2 then
        return GameItemModel.GetItemToKey(this.UIConfig.rank_type_map[this.m_data.rank_id].reward_item_key).image
    elseif type==3 then
        return GameItemModel.GetItemToKey(this.UIConfig.rank_type_map[this.m_data.rank_id].ext_reward_item_key).image
    end
end

function M.GetCurSytleKey()
    return this.UIConfig.rank_type_map[this.m_data.rank_id].path
end
--type 同上
function M.GetCurItemName(type)
    if type==1 then
        return GameItemModel.GetItemToKey(this.UIConfig.rank_type_map[this.m_data.rank_id].item_key).name
    elseif type==2 then
        return GameItemModel.GetItemToKey(this.UIConfig.rank_type_map[this.m_data.rank_id].reward_item_key).name
    elseif type==3 then
        return GameItemModel.GetItemToKey(this.UIConfig.rank_type_map[this.m_data.rank_id].ext_reward_item_key).name
    end
end
function M.GetConifg()
    return  M.config_all.config[M.GetCurID()]
end


function M.on_ActivityYearPanel_had_exit_msg(goto_type)
    if goto_type == "weekly" and M.IsActive() then
        local config = M.GetConifg()
        if config and config.act_gift_name then
            local newtime = tonumber(os.date("%Y%m%d", os.time()))
            local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetInt(M.key .. MainModel.UserInfo.user_id, 0))))
            if oldtime ~= newtime then
                local data = M.GetRankData(M.m_data.rank_type)
                if data and data.rank >= 2 and data.rank <= 20 then
                    PlayerPrefs.SetInt(M.key .. MainModel.UserInfo.user_id, os.time())
                    Act_TY_JZSJBPopupPanel.Create()
                end
            end
        end
    end
end