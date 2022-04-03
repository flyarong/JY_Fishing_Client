-- 创建时间:2020-11-23
-- Act_038_BY_AND_CJJ_CONDUCTManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_038_BY_AND_CJJ_CONDUCTManager = {}
local M = Act_038_BY_AND_CJJ_CONDUCTManager
M.key = "act_038_by_and_cjj_conduct"
GameButtonManager.ExtLoadLua(M.key,"Act_038_BY_AND_CJJ_CONDUCTPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_038_BY_AND_CJJ_CONDUCTEnter")
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
    --[[if this.m_data.is_download and this.m_data.is_download == 0 and M.IsInSevenDay() and M.ItsHightTime() and 
    (M.CheckPermission() == "normal" and MainModel.myLocation == "game_Hall") or (M.CheckPermission() == "cjj" and MainModel.myLocation == "game_MiniGame" or MainModel.myLocation == "game_Fishing3DHall") then
    else
        return false
    end--]]
    return M.IsActive() and M.ItsHightTime()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if not M.CheckIsShow(parm) then
        return
    end
    if parm.goto_scene_parm == "enter" then
        return Act_038_BY_AND_CJJ_CONDUCTEnter.Create(parm.parent, parm.cfg)
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
    lister["EnterScene"] = this.OnEnterScene

    --lister["ReceivePayOrderMsg"] = this.on_ReceivePayOrderMsg
    --lister["query_other_register_game_platfrom_response"] = this.on_query_other_register_game_platfrom_response
end

function M.Init()
	M.Exit()

	this = Act_038_BY_AND_CJJ_CONDUCTManager
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

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        --[[Timer.New(function ()
            M.QueryBaseData()
        end,1,1,false):Start()--]]
	end
end
function M.OnReConnecteServerSucceed()
end

function M.CheckPermission(name)
    if name == "normal" then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="hlby_type_plat", is_on_hint = true}, "CheckCondition")
        if a and b then
            return "normal"
        end
        return false
    end
    if name == "cjj" then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="cjj_type_plat", is_on_hint = true}, "CheckCondition")
        if a and b then
            return "cjj"
        end
        return false
    end
    return false
end

--[[function M.CheckPermission()
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="cjj_cpl_recharge_above", is_on_hint = true}, "CheckCondition")
    if a and b then
        return "normal"
    end
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="cpl_recharge_above", is_on_hint = true}, "CheckCondition")
    if a and b then
        return "cjj"
    end
end--]]

function M.OnEnterScene()
    M.CheckShowEnter()   
end

function M.CheckShowEnter()
    --[[dump(MainModel.cur_myLocation,"<color=blue><size=15>++++++++++88888888888888++++++++++</size></color>")

    dump(MainModel.myLocation,"<color=blue><size=15>++++++++++88888888888888++++++++++</size></color>")--]]

    if MainModel.cur_myLocation == "game_Hall" or MainModel.cur_myLocation == "game_MiniGame" or MainModel.cur_myLocation == "game_Fishing3DHall" then
        --dump({per=M.CheckIsShow(),is = this.m_data.is_download,seven = M.IsInSevenDay(),ishight = M.ItsHightTime()},"<color=green><size=15>++++++++++data++++++++++</size></color>")
        if M.CheckIsShow()--[[ and this.m_data.is_download and this.m_data.is_download == 0 --]] and M.IsInSevenDay() and M.ItsHightTime() then
            if M.CheckPermission("cjj") == "cjj" then
                if MainModel.cur_myLocation == "game_Hall" or MainModel.cur_myLocation == "game_MiniGame" then
                    this.m_data.pre = Act_038_BY_AND_CJJ_CONDUCTEnter.Create("cjj")
                end
            elseif M.CheckPermission("normal") == "normal" then
                if MainModel.cur_myLocation == "game_Hall" or MainModel.cur_myLocation == "game_MiniGame" or MainModel.cur_myLocation == "game_Fishing3DHall" then
                    this.m_data.pre = Act_038_BY_AND_CJJ_CONDUCTEnter.Create("normal")
                end
            end
        end
    end
end

function M.MarkTime()
    local d = os.date("%Y/%m/%d", now)
    local strs = {}
    string.gsub(d, "[^-/]+", function(s)
        strs[#strs + 1] = s
    end)
    local et = os.time({year = strs[1], month = strs[2], day = strs[3], hour = "23", min = "59", sec = "59"})
    et = et + 1
    PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."Conduct",et)
    if PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."Conduct_7") == 0 then
        PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."Conduct_7",os.time() + 604800)
    end
end

function M.MarkTimeEnter()
    if (PlayerPrefs.GetInt(MainModel.UserInfo.user_id .. "Conduct_one_hour",0) == 0) or (tonumber(os.date("%Y%m%d", os.time())) ~= tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetInt(MainModel.UserInfo.user_id .. "Conduct_one_hour", 0))))) then
        PlayerPrefs.SetInt(MainModel.UserInfo.user_id .. "Conduct_one_hour",os.time() + 3600)
    end
end

function M.ItsHightTime()
    if (os.time() >= PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."Conduct",0)) or (os.time() < PlayerPrefs.GetInt(MainModel.UserInfo.user_id .. "Conduct_one_hour",os.time() + 1)) then
        return true
    else
        return false
    end
end

function M.IsInSevenDay()
    if PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."Conduct_7") == 0 or os.time() < PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."Conduct_7") then
        return true
    else
        return false
    end
end

function M.on_ReceivePayOrderMsg(data)
    dump(data,"<color=blue><size=15>++++++++++data++++++++++</size></color>")
    if data and data.result == 0 then
        M.CheckShowEnter()
    end
end

--[[function M.QueryBaseData()
    dump(M.CheckPermission(),"<color=yellow><size=15>++++++++++on_query_other_register_game_platfrom_response++++++++++</size></color>")
    Network.SendRequest("query_other_register_game_platfrom",{platfrom = M.CheckPermission()})
end

function M.on_query_other_register_game_platfrom_response(_,data)
    dump(data,"<color=blue><size=15>++++++++++on_query_other_register_game_platfrom_response++++++++++</size></color>")
    if data and data.result == 0 then
        this.m_data.is_download = data.data
        M.CheckShowEnter()
    end
end--]]