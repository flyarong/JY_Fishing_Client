-- 创建时间:2020-07-27
-- Act_023_VIPZTLBManager 管理器

local basefunc = require "Game/Common/basefunc"
Sys_Act_CZZKManager = {}
local M = Sys_Act_CZZKManager
M.key = "sys_act_czzk"

GameButtonManager.ExtLoadLua(M.key, "Sys_Act_CZZKPanel")

local this
local lister
M.gift_id = 10436

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
    if parm.goto_scene_parm == "panel" then
        return Sys_Act_CZZKPanel.Create(parm.parent, parm.backcall,false)
    elseif parm.goto_scene_parm == "panel2" then  --主动弹出界面有关闭按钮
        return Sys_Act_CZZKPanel.Create(parm.parent, parm.backcall,true)
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
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
    lister["finish_gift_shop"] = this.on_finish_gift_shop--完成礼包购买
    lister["AssetChange"] = this.on_AssetChange
end

function M.Init()
    M.Exit()

    this = Sys_Act_CZZKManager
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
    end
end
function M.OnReConnecteServerSucceed()
end

function M.GetConfig()
    return M.config
end

--检查是否在周卡有效期内
function M.CheckIsBoughtZK()
    if table_is_null(MainModel.GetObjInfoByKey("obj_week_card")) then
        return false
    else
        local tab = MainModel.GetObjInfoByKey("obj_week_card")
        for i=1,#tab do
            if M.GetTrueTime(tab[i].valid_time) > os.time() then
                return true
            end
        end
        return false
    end
end

function M.on_finish_gift_shop(id)
    if id and id == M.gift_id then
        Event.Brocast("czzk_gift_has_buy_msg")
    end
end


--获取当前剩余天数
function M.GetCurRemainDay()
    local tab = MainModel.GetObjInfoByKey("obj_week_card")
    if not table_is_null(tab) then
        local cur_t = os.time()
        for i=1,#tab do
            if M.GetTrueTime(tab[i].valid_time) > cur_t then
                local num = math.ceil((M.GetTrueTime(tab[i].valid_time) - cur_t) / 86400)
                if tab[i].used_time and os.date("%d",cur_t) == os.date("%d",tab[i].used_time) then
                    num = num - 1
                end
                return num
            end
        end
    end
    return 7
end

function M.on_AssetChange(data)
    if data and data.change_type == "buy_gift_bag_10436" then
        for i=1,#data.data do
            if data.data[i].asset_type == "obj_week_card" then
                table.remove(data.data,i)
            end
        end
        Event.Brocast("AssetGet", data)
    end
end

function M.GetTrueTime(valid_time)
    local ct = valid_time - 7*86400  --12点
    local y = os.date("%Y", ct)
    local m = os.date("%m", ct)
    local d = os.date("%d", ct)
    local t = os.time({year=tostring(y), month=tostring(m), day=tostring(d), hour ="24", min = "0", sec = "0"})-- 24点
    return t + 6*86400
end

