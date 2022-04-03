-- 创建时间:2020-06-15
-- Act_ty_HLQJDManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_ty_HLQJDManager = {}
local M = Act_ty_HLQJDManager
M.key = "act_ty_hlqjd"
GameButtonManager.ExtLoadLua(M.key, "Act_ty_HLQJDPrefab")
GameButtonManager.ExtLoadLua(M.key, "Act_ty_HLQJDPanel")
local config = GameButtonManager.ExtLoadLua(M.key, "act_ty_hlqjd_config")

local this
local lister

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间

    local e_time = this.UIConfig.endTime --1615823999
    local s_time = this.UIConfig.beginTime --1615248000
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    local _permission_key = "actp_own_task_p_029_hlqjd_hammer"
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
    -- dump(ss.sss.sss,"<color=yellow>欢乐敲金蛋入口！！！！！</color>")
    if not M.IsActive() then
        return
    end
    if parm.goto_scene_parm == "panel" then
        return Act_ty_HLQJDPanel.Create(parm.parent,parm.backcall)
    elseif parm.goto_scene_parm == "enter"  then
        if parm.parent.parent.gameObject.name == "ActivityYearPanel" then
            local b = Act_ty_HLQJDPrefab.Create(parm.parent)
            CommonHuxiAnim.Start(b.gameObject)
            return b
        else
            return Act_ty_HLQJDPrefab.Create(parm.parent)
        end
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    for i = 1,3 do
        if  M.GetCzNum(i) > 0 then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        end
    end
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
        Event.Brocast("global_hint_state_change_msg", parm)
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    Event.Brocast("global_hint_state_change_msg", parm)
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

    lister["fishing_ready_finish"] = this.on_fishing_ready_finish
end

function M.GetTimeData()
    return config
end

function M.Init()
	M.Exit()

	this = Act_ty_HLQJDManager
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
function M.GetCurConfig()
    local cur_t = os.time()
    for i,v in ipairs(config.config_info) do
        if cur_t >= v.beginTime and cur_t <= v.endTime then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = v.condiy_key, is_on_hint = true}, "CheckCondition")
            if a and b then
                return v
            end
        end
    end
    return config.config_info[1] -- 
end

function M.InitUIConfig()
    this.UIConfig = {}

    local info_cfg = M.GetCurConfig()
    if not info_cfg then
        this.UIConfig.beginTime = 0
        this.UIConfig.endTime = 0
        return
    end
    this.UIConfig.beginTime = info_cfg.beginTime
    this.UIConfig.endTime = info_cfg.endTime

    local shop_map = {}
    for k,v in ipairs(config.shop) do
        shop_map[v.shop_id] = v
    end
    local egg_award_map = {}
    for k,v in ipairs(config.egg_award) do
        egg_award_map[v.id] = v
    end

    this.UIConfig.task_map = {}

    this.UIConfig.config = {}
    for k,vv in ipairs(info_cfg.config) do
        local v = config.config[vv]
        local d = {}
        this.UIConfig.config[#this.UIConfig.config + 1] = d
        d.condi_key = v.condi_key
        d.task_id = v.task_id
        d.item = v.item
        d.shop_list = {}
        for kk,vv in ipairs(v.task_id) do
            this.UIConfig.task_map[vv] = 1
        end

        for kk,vv in ipairs(v.shop_ids) do
            local dd = {}
            d.shop_list[#d.shop_list + 1] = dd
            dd.shop_id = vv
            dd.icon = shop_map[vv].icon
        end

        d.egg_award_list = {}
        for kk,vv in ipairs(v.egg_award_ids) do
            d.egg_award_list[#d.egg_award_list + 1] = egg_award_map[vv]
        end
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        M.SetLevel()
	end
end
function M.OnReConnecteServerSucceed()
end

function M.SetLevel()
    local func = function (_permission_key)
        if _permission_key then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
            if a and not b then
                return false
            end
            return true
        end
    end
    for k,v in ipairs(this.UIConfig.config) do
        if func(v.condi_key) then
            this.m_data.level = k
            break
        end        
    end
    dump(this.m_data.level, "<color=red>|||||||||||||||||||||</color>")
    if not this.m_data.level then
        this.m_data.level = 1
    end
end


function M.GetBaseData()
    return this.UIConfig.config[this.m_data.level].egg_award_list
    -- return base_data[this.m_data.level]
end

function M.GetCzNum(index)
    local key = this.UIConfig.config[this.m_data.level].item[index]
    local num = GameItemModel.GetItemCount(key)
    return num
end

function M.GetShopIDs()
    -- New:礼包根据价格从高到底展示
    local cfg = this.UIConfig.config[this.m_data.level].shop_list
    local list = {}
    for i=#cfg, 1, -1 do
        list[#list + 1] = cfg[i].shop_id
    end
    return list
end

function M.GetShopImg()
    return this.UIConfig.config[this.m_data.level].shop_list
    -- return shop_img
end

function M.GetTaskIDs()
    return this.UIConfig.config[this.m_data.level].task_id
end

function M.IsExistTaskID(id)
    if this.UIConfig.task_map[id] then
        return true
    else
        return false
    end
end

function M.on_fishing_ready_finish()
    if M.IsActive() and MainModel.myLocation == "game_Fishing3D" then
       -- Act_ty_HLQJDPanel.Create()
    end
end
