-- 创建时间:2020-09-07
-- Act_Ty_LB1Manager 管理器

local basefunc = require "Game/Common/basefunc"
Act_Ty_LB1Manager = {}
local M = Act_Ty_LB1Manager
M.key = "act_ty_lb1"

GameButtonManager.ExtLoadLua(M.key,"Act_Ty_LB1Panel")
GameButtonManager.ExtLoadLua(M.key,"Act_Ty_LB1ItemPanel")
M.config = GameButtonManager.ExtLoadLua(M.key,"act_ty_lb1_config")
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
    dump(M.GetNowPerMiss(),"<color=red>抽奖礼包权限</color>")
    if M.GetNowPerMiss() then 
        return true
    end
end

function M.GetNowPerMiss()
    local cheak_fun = function (_config_infoitem)
        local cur_t=os.time()

        if cur_t>=_config_infoitem.sta_t and cur_t<=_config_infoitem.end_t then
            dump(_config_infoitem.permission,"满足时间条件！！！！！")
            if _config_infoitem.permission then
                local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_config_infoitem.permission, is_on_hint = true}, "CheckCondition")
                if a and not b then
                    return false
                end
                return true
            else
                return false
            end
        end
        return
    end


    if not this.UIConfig.config_info then 
        -- this.UIConfig.config_info=M.config.platform_channel
        M.InitUIConfig()
    end
        
   
    M.now_level = nil
    -- dump(this.UIConfig.config_info,"this.UIConfig.config_info:---->")
    for i = 1,#this.UIConfig.config_info do 
        if cheak_fun(this.UIConfig.config_info[i]) then
            dump(this.UIConfig.config_info[i],"符合条件的权限")
            M.now_level = i 
            M.cur_path=this.UIConfig.config_info[i].cur_path
            for k,v in pairs(M.config[M.config.platform_channel[M.now_level].config]) do
                this.UIConfig.shop_map_ui[v.shop_id] = v
            end

            for k,v in pairs(M.config[M.config.platform_channel[M.now_level].config]) do
                this.UIConfig.shop_id_list[k] = v.shop_id
            end 
            return i
        end
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
    if parm.goto_scene_parm == "panel"  then
        return Act_Ty_LB1Panel.Create(parm.parent)
    else
        -- dump(M.config.platform_channel,"M.config.platform_channel:  ")
        -- dump(M.now_level,"M.now_level:  ")
        if M.now_level==nil then
            HintPanel.Create(1, "物品已过期！")
            return
        end
        if not M.config.platform_channel[M.now_level].item_key or table_is_null(M.config.platform_channel[M.now_level].item_key) then return end
        for i=1,#M.config.platform_channel[M.now_level].item_key do
            if parm.goto_scene_parm == M.config.platform_channel[M.now_level].item_key[i] then
                Network.SendRequest("box_exchange",{id = M.config.platform_channel[M.now_level].box_exchange_id[i],num =  GameItemModel.GetItemCount(M.config.platform_channel[M.now_level].item_key[i]),is_merge_asset = 1 })
                return
            end
        end
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
     if parm and parm.gotoui == M.key then 
        local newtime = tonumber(os.date("%Y%m%d", os.time()))
        local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
        if oldtime ~= newtime then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Red
        end
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

    lister["query_send_list_fishing_msg"] = this.on_query_send_list_fishing_msg
end

function M.Init()
	M.Exit()

	this = Act_Ty_LB1Manager
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
    this.UIConfig.shop_id_list = {}
    this.UIConfig.shop_map_ui = {}
    this.UIConfig.config_info=M.config.platform_channel
    -- this.permisstions = {}
    -- for i=1,#M.config.platform_channel do
    --     this.permisstions[#this.permisstions + 1] = M.config.platform_channel[i].permission
    -- end 
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.GetConfigByID(id)
    return this.UIConfig.shop_map_ui[id]
end

--获取商品ID
function M.GetCurrShopID(i)
    return M.config[M.config.platform_channel[M.now_level].config][i].shop_id
end

function M.GetCurrConfig()
    return M.config[M.config.platform_channel[M.now_level].config]
end

function M.GetCurrShopIdList()
    return this.UIConfig.shop_id_list
end

function M.IsHaveItemCount()
    if M.config.platform_channel[M.now_level].item_key then
        for k,v in pairs(M.config.platform_channel[M.now_level].item_key) do
            if GameItemModel.GetItemCount(v) > 0 then
                return true
            end
        end
    end
    return false
end

function M.GetActStartTime()
    return M.config.platform_channel[M.now_level].sta_t
end

function M.GetActEndTime()
    return M.config.platform_channel[M.now_level].end_t
end

function M.QueryGiftData()
    local msg_list = {}
    local is_need_query = false
    for k,v in pairs(this.UIConfig.shop_id_list) do
        if not MainModel.GetGiftDataByID(v) or not MainModel.GetGiftDataByID(v).remain_time then
            msg_list[#msg_list + 1] = {msg="query_gift_bag_status", data = {gift_bag_id = v}}
            is_need_query = true
        end
    end
    if is_need_query then
        GameManager.SendMsgList("ty_lb1", msg_list)
    else
        Event.Brocast("ty_lb1_gift_data_had_got_msg")
    end
end

function M.on_query_send_list_fishing_msg(tag)
    if tag == "ty_lb1" then
        Event.Brocast("ty_lb1_gift_data_had_got_msg")
    end
end