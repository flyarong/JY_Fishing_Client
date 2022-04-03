-- 创建时间:2020-02-21
-- BY3DActCaijinManager 管理器

local basefunc = require "Game/Common/basefunc"
BY3DActCaijinManager = {}
local M = BY3DActCaijinManager
M.key = "by3d_act_caijin"
GameButtonManager.ExtLoadLua(M.key, "Fishing3DActCaijinPanel")
GameButtonManager.ExtLoadLua(M.key, "Fishing3DActCaijinBoxPrefab")
GameButtonManager.ExtLoadLua(M.key, "Fishing3DActCaijinEnterPrefab")

local this
local lister
local send_data

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- if not this.m_caijin_data or not this.m_caijin_data.result or this.m_caijin_data.result ~= 0 then
    --     return false
    -- end
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
    if FishingModel and FishingModel.game_id and (FishingModel.game_id > 1 and FishingModel.game_id < 6) then--2-5彩金鱼
        return M.IsActive()
    end
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return Fishing3DActCaijinPanel.Create()
    elseif parm.goto_scene_parm == "enter" then
        return Fishing3DActCaijinEnterPrefab.Create(parm.parent)
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

    lister["nor_fishing_3d_caijin_all_info_response"] = this.on_nor_fishing_3d_caijin_all_info_response
    lister["nor_fishing_3d_caijin_lottery_response"] = this.on_nor_fishing_3d_caijin_lottery_response
    lister["nor_fishing_3d_caijin_change"] = this.on_nor_fishing_3d_caijin_change
end

function M.Init()
    print("3dcaijin init!")
	M.Exit()

	this = BY3DActCaijinManager

    this.initConfig()
    this.InitCaijinData()

	MakeLister()
    AddLister()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end


function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.QueryCaijinAllInfo()
    if this.m_caijin_data.game_id and this.m_caijin_data.game_id == FishingModel.game_id then
        Event.Brocast("model_by3d_act_caijin_all_info")
    else
        NetMsgSendManager.SendMsgQueue("nor_fishing_3d_caijin_all_info", nil, "进入彩金界面")
    end
end

function M.RequestLottery()
    Network.SendRequest("nor_fishing_3d_caijin_lottery", nil, "抽奖")
end

function M.on_nor_fishing_3d_caijin_all_info_response(_, data)
    this.m_caijin_data.all_info_result = data.result
    dump(data, "<color=red>on_nor_fishing_3d_caijin_all_info_response</color>")
    if data and data.result == 0 then
        this.m_caijin_data.result = data.result
        this.m_caijin_data.lottery_num = data.lottery_num
        this.m_caijin_data.lottery_time = data.lottery_time
        this.m_caijin_data.score = data.score
        this.m_caijin_data.kill_num = data.kill_num
        this.m_caijin_data.game_id = data.game_id
        Event.Brocast("model_by3d_act_caijin_all_info")
    else
        -- HintPanel.ErrorMsg(data.result)
    end
end

function M.on_nor_fishing_3d_caijin_lottery_response(_, data)
    dump(data, "<color=red>on_nor_fishing_3d_caijin_lottery_response</color>")
    this.m_caijin_data.result = data.result
    if data and data.result == 0 then
        this.m_caijin_data.award_index = data.award_index
        this.m_caijin_data.lottery_num = data.lottery_num
        this.m_caijin_data.lottery_time = data.lottery_time
        this.m_caijin_data.type = data.type
        this.m_caijin_data.score = data.score
        this.m_caijin_data.kill_num = data.kill_num
    else
        -- HintPanel.ErrorMsg(data.result)
    end
    Event.Brocast("model_by3d_act_caijin_lottery")
end

function M.on_nor_fishing_3d_caijin_change(_,data)
    dump(data, "<color=red>on_nor_fishing_caijin_change</color>")
    if data and data.result == 0 then
        this.m_caijin_data.result = data.result
        this.m_caijin_data.lottery_num = data.lottery_num
        this.m_caijin_data.lottery_time = data.lottery_time
        this.m_caijin_data.score_change = data.score_change
        this.m_caijin_data.score = data.score
        this.m_caijin_data.kill_num = data.kill_num

        if not this.m_caijin_data.game_id then
            this.m_caijin_data.game_id = FishingModel.game_id
        end

        Event.Brocast("model_by3d_act_caijin_change")
    else
        -- HintPanel.ErrorMsg(data.result)
    end
end

function M.GetCaijinData()
    --this.m_caijin_data.score = 110000
    return this.m_caijin_data
end

function M.InitCaijinData()
    this.m_caijin_data = {}

    -- this.m_caijin_data.result = 0
    -- this.m_caijin_data.award_index = 0
    -- this.m_caijin_data.lottery_num = 0
    -- this.m_caijin_data.lottery_time = 0
    -- this.m_caijin_data.type = 0
    -- this.m_caijin_data.score_change = 0
    -- this.m_caijin_data.score = 0
    -- this.m_caijin_data.kill_num = 0
    -- this.m_caijin_data.game_id = 1
end

function M.initConfig()
    local fish_3d_caijin_config = GameButtonManager.ExtLoadLua(M.key, "fish_3d_caijin_config")
    this.caijin_config = {}

    local _config = fish_3d_caijin_config
	local caijin_type_config = {}
	local load_award_config=function (award_id,cfg)
		for key, data in pairs(_config.award) do
			if data.config_id == award_id then
				cfg[#cfg + 1] = data
			end
        end
        
        table.sort(cfg, function (a,b)
            return a.index < b.index
        end)
	end

	for key, data in pairs(_config.lottery) do
		caijin_type_config[data.game_id] = caijin_type_config[data.game_id] or {}
        caijin_type_config[data.game_id][data.type] = data
		if data.award_config_id then
			data.award = {}

			load_award_config(data.award_config_id, data.award)

			if #data.award == 0 then
				print("error caibei award config")
			end
		end
	end

	local caijin_fishs_id = {}
	if _config.Common[1].caijin_fish_id then
		for idx, fishid in pairs(_config.Common[1].caijin_fish_id) do
			caijin_fishs_id[fishid] = idx
		end
	end
	

	this.caijin_config.caijin_type_config = caijin_type_config
	this.caijin_config.caijin_fishs_id = caijin_fishs_id
	this.caijin_config.caijin_common_config = _config.Common[1]
    dump(this.caijin_config,"<color=green>++++++++++++++_config.condition+++++++++++++++</color>")
end
