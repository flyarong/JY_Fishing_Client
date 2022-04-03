-- 创建时间:2020-04-15
-- SYSByBagManager 管理器

local basefunc = require "Game/Common/basefunc"
SYSByBagManager = {}
local M = SYSByBagManager
M.key = "sys_by_bag"
GameButtonManager.ExtLoadLua(M.key, "ByBagPanel")
GameButtonManager.ExtLoadLua(M.key, "ByToolBagPanel")
GameButtonManager.ExtLoadLua(M.key, "ByPaotaiBagPanel")
GameButtonManager.ExtLoadLua(M.key, "ByItemPrefab")
GameButtonManager.ExtLoadLua(M.key, "ByGunItemPrefab")
GameButtonManager.ExtLoadLua(M.key, "HallPtPanel")
GameButtonManager.ExtLoadLua(M.key, "HallPtItem")
GameButtonManager.ExtLoadLua(M.key, "HallPtShowPanel")
GameButtonManager.ExtLoadLua(M.key, "BuyPTHintPanel")
GameButtonManager.ExtLoadLua(M.key, "ByTouXiangKuangBagPanel")
GameButtonManager.ExtLoadLua(M.key, "ByPaotaiBuyPanel")
GameButtonManager.ExtLoadLua(M.key, "ByGunItemBuyPrefab")

M.item_gun_config = GameButtonManager.ExtLoadLua(M.key, "item_gun_config")


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
        return ByBagPanel.Create(parm)
    elseif parm.goto_scene_parm == "panel2" then
        return HallPtPanel.Create(parm.parent)   
    elseif parm.goto_scene_parm == "panel3" then
        return  HallPtShowPanel.Create(parm.parent)
    elseif parm.goto_scene_parm == "panel_buy" then
        return  ByPaotaiBuyPanel.Create(parm.parent)
    else
        dump(parm, "<color=red>鎵剧瓥鍒掔‘璁よ繖涓€艰璺宠浆鍒板摢閲/color>")
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
    lister["query_fish_3d_gun_info_response"] = this.on_gun_all_info_response

    lister["fish_3d_gun_change_msg"] = this.on_fish_3d_gun_change_msg

end

function M.Init()
	M.Exit()

	this = SYSByBagManager
	this.m_data = {}

	MakeLister()
    AddLister()
	M.InitUIConfig()
    M.InitRed()
end
function M.Exit()
	if this then
        M.StopTime()
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
    --炮本地配置
    this.UIConfig.barrel_config = {}
    --基座本地配置
    this.UIConfig.bed_config = {}
    --头像框本地配置
    this.UIConfig.frame_list = {}

    this.UIConfig.config_map = {}
    for k,v in pairs (M.item_gun_config.config) do
        v.is_get = 0
        if v.type == 1 then
            this.UIConfig.barrel_config[v.item_id] = v
        elseif v.type == 2 then
            this.UIConfig.bed_config[v.item_id] = v
        elseif v.type == 3 then
            this.UIConfig.frame_list[v.item_id] = v
        end
        this.UIConfig.config_map[v.item_key] = v
    end
end
-- 根据道具Key获取道具
function M.GetItemToKey_G(parm)
   return M.GetItemToKey(parm.key) 
end
function M.GetItemToKey(key)
    if this and this.UIConfig and this.UIConfig.config_map then
       return this.UIConfig.config_map[key] 
    end
end

function M.OnLoginResponse(result)
    if result == 0 then
        dump("<color=red>开始请求背包数据</color>")
        this.m_data.is_query = false
        NetMsgSendManager.SendMsgQueue("query_fish_3d_gun_info",nil)

        M.StopTime()
        this.update_time = Timer.New(function ()
            M.CheckGunUseTime()
        end, 5, -1, nil, true)
        this.update_time:Start()
	end
end
function M.OnReConnecteServerSucceed()
end

function M.QueryGunInfo()
    -- if this.m_data.is_query then
    --     return
    -- end
    if this.m_data.GunInfo and this.m_data.GunInfo.barrel_id then
        Event.Brocast("model_by_bag_gun_info_change", this.m_data.GunInfo.barrel_id, this.m_data.GunInfo.bed_id,this.m_data.GunInfo.frame_id)
    else
        this.m_data.is_query = true
        NetMsgSendManager.SendMsgQueue("query_fish_3d_gun_info",nil,"请求数据")
    end
end

function M.StopTime()
    if this.update_time then
        this.update_time:Stop()
        this.update_time = nil
    end
end
function M.CheckGunUseTime()
    if this.m_data.GunInfo and this.m_data.GunInfo.barrel_id then
        if this.m_data.GunInfo.barrel_list then
            for k,v in ipairs(this.m_data.GunInfo.barrel_list) do
                if v.id == this.m_data.GunInfo.barrel_id then
                    local t = tonumber(v.time)
                    if t ~= 0 and t < os.time() then
                        this.m_data.GunInfo.barrel_id = M.GetCanUseMaxLevelGun()
                        Event.Brocast("model_by_bag_gun_info_change", this.m_data.GunInfo.barrel_id, this.m_data.GunInfo.bed_id,this.m_data.GunInfo.frame_id)
                    end
                    break
                end
            end
        end
    end
end

function M.on_gun_all_info_response(_,data)
    this.m_data.is_query = false
    if data.result == 0 then
        dump(data,"<color=red>背包数据</color>")
        this.m_data.GunInfo = {}
        this.m_data.GunInfo.barrel_id = data.barrel_id or 1
        this.m_data.GunInfo.bed_id = data.bed_id or 1
        this.m_data.GunInfo.barrel_list = data.barrel_list
        this.m_data.GunInfo.bed_list = data.bed_list
        this.m_data.GunInfo.frame_id = data.frame_id or 1
        this.m_data.GunInfo.frame_list = data.frame_list
        Event.Brocast("model_by_bag_gun_info_change", this.m_data.GunInfo.barrel_id, this.m_data.GunInfo.bed_id,this.m_data.GunInfo.frame_id)
    end
end


function M.GetItemGunConfig()
end

function M.InitRed()
    this.m_data.item_red_data = {[1]={}, [2]={}, [3]={}}

    for k,v in ipairs(this.UIConfig.barrel_config) do
        local a = PlayerPrefs.GetInt("by_bag_not_item_" .. v.type .. "_" .. v.item_id .. "_" .. MainModel.UserInfo.user_id, 0)
        if a == 1 then
            this.m_data.item_red_data[v.type][v.item_id] = 1
        end
    end
    for k,v in ipairs(this.UIConfig.bed_config) do
        local a = PlayerPrefs.GetInt("by_bag_not_item_" .. v.type .. "_" .. v.item_id .. "_" .. MainModel.UserInfo.user_id, 0)
        if a == 1 then
            this.m_data.item_red_data[v.type][v.item_id] = 1
        end
    end
    for k,v in ipairs(this.UIConfig.frame_list) do
        local a = PlayerPrefs.GetInt("by_bag_not_item_" .. v.type .. "_" .. v.item_id .. "_" .. MainModel.UserInfo.user_id, 0)
        if a == 1 then
            this.m_data.item_red_data[v.type][v.item_id] = 1
        end
    end
end
function M.IsHaveRad(tag)
    if tag then
        if this.m_data.item_red_data and this.m_data.item_red_data[tag] and next(this.m_data.item_red_data[tag]) then
            return true
        end
        return false
    else
        if this.m_data.item_red_data then
            for k,v in pairs(this.m_data.item_red_data) do
                if M.IsHaveRad(k) then
                    return true
                end
            end
            return false
        else
            return false
        end
    end
end
function M.GetRed(type, id)
    if this.m_data.item_red_data[type] and this.m_data.item_red_data[type][id] then
        return true
    end
    return false
end
function M.DelRed(type, id)
    PlayerPrefs.SetInt("by_bag_not_item_" .. type .. "_" .. id .. "_" .. MainModel.UserInfo.user_id, 0)
    this.m_data.item_red_data[type][id] = nil
    Event.Brocast("UpdateHallBagRedHint")
end
function M.SetRed(data)
    if this.m_data.GunInfo
        and this.m_data.GunInfo.barrel_list
        and this.m_data.GunInfo.bed_list
        and this.m_data.GunInfo.frame_list then

        local old_item = {{},{},{}}
        for k,v in ipairs(this.m_data.GunInfo.barrel_list) do
            old_item[1][v.id] = 1
        end
        for k,v in ipairs(this.m_data.GunInfo.bed_list) do
            old_item[2][v.id] = 1
        end
        for k,v in ipairs(this.m_data.GunInfo.frame_list) do
            old_item[3][v.id] = 1
        end

        local b = false
        for k,v in ipairs(data) do
            local cfg = SYSByBagManager.GetItemToKey(v.type)
            if cfg and not old_item[cfg.type][cfg.item_id] then
                PlayerPrefs.SetInt("by_bag_not_item_" .. cfg.type .. "_" .. cfg.item_id .. "_" .. MainModel.UserInfo.user_id, 1)
                this.m_data.item_red_data[cfg.type][cfg.item_id] = 1
                b = true
            end
        end
        if b then
            Event.Brocast("UpdateHallBagRedHint")
        end
    end
end

function M.on_fish_3d_gun_change_msg(_, data)
    M.SetRed(data.data)
    dump(data,"<color=red>捕鱼背包数据改变</color>")
    this.m_data.GunInfo = this.m_data.GunInfo or {}
    local b
    local asset_list = {}
    if not table_is_null(data.data) then
        for k,v in ipairs(data.data) do
            local cfg = SYSByBagManager.GetItemToKey(v.type)
            if cfg then
                b = true
                asset_list[#asset_list + 1] = {asset_type=cfg.item_key, value=1}
                if cfg.type == 1 then
                    dump(this.m_data,"<color=yellow>+++++++++++++++++++++</color>")
                    this.m_data.GunInfo.barrel_list = this.m_data.GunInfo.barrel_list or {}
                    this.m_data.GunInfo.barrel_list[#this.m_data.GunInfo.barrel_list + 1] = {id=cfg.item_id, time=v.time}
                elseif cfg.type == 2 then
                    this.m_data.GunInfo.bed_list = this.m_data.GunInfo.bed_list or {}
                    this.m_data.GunInfo.bed_list[#this.m_data.GunInfo.bed_list + 1] = {id=cfg.item_id, time=v.time}
                elseif cfg.type == 3 then
                    this.m_data.GunInfo.frame_list = this.m_data.GunInfo.frame_list or {}
                    this.m_data.GunInfo.frame_list[#this.m_data.GunInfo.frame_list + 1] = {id = cfg.item_id , time = v.time}
                end
            end
        end
    end

    if b then
        dump(asset_list,"<color=yellow>+++++++++++++++++++++</color>")
        if asset_list[1].asset_type and string.sub(asset_list[1].asset_type,1,11) == "gun_barrel_" then
            dump("++++++++++++++++++++++++++++++++++++++++++++")
            PlayerPrefs.SetInt("NewGunGet_bagPanel"..MainModel.UserInfo.user_id, os.time())
            PlayerPrefs.SetInt("NewGunGet_hallPanel"..MainModel.UserInfo.user_id, os.time())
        end

        if asset_list[1].asset_type == "gun_bed_2" or 
        asset_list[1].asset_type == "gun_bed_3" or
        asset_list[1].asset_type == "gun_barrel_3" or
        asset_list[1].asset_type == "gun_barrel_4" then--2021.8.17版本运营需求欢乐天天捕鱼&捕鱼奥秘小优化-余洪铭
        else
            Event.Brocast("AssetGet", {data = asset_list})
        end

        Event.Brocast("model_by_bag_gun_info_change", this.m_data.GunInfo.barrel_id, this.m_data.GunInfo.bed_id)
    end
end

-- 返回可以使用的最高等级的炮
function M.GetCanUseMaxLevelGun()
    local id = 1
    local cur_t = os.time()
    for k,v in ipairs(this.m_data.GunInfo.barrel_list) do
        local tt = tonumber(v.time)
        if tt == 0 or tt > cur_t and id < v.id then
            id = v.id
        end
    end
    return id
end

function M.GetData()
    return this.m_data.GunInfo
end


function M.GetGunNum()
    if this.m_data.GunInfo and this.m_data.GunInfo.barrel_list then
        return #this.m_data.GunInfo.barrel_list
    else
        M.QueryGunInfo()
        return 1
    end
end

function M.GetGunMaxNum()
    return #this.UIConfig.barrel_config
end


function M.GetCurChosePtID()
    if this.m_data.GunInfo and this.m_data.GunInfo.barrel_id then
        return this.m_data.GunInfo.barrel_id
    else
        M.QueryGunInfo()
        return 1
    end
end

function M.GetCurChosePtName()
    if this.m_data.GunInfo and this.m_data.GunInfo.barrel_id then
        for i=1,#this.UIConfig.barrel_config do
            if this.UIConfig.barrel_config[i].id == this.m_data.GunInfo.barrel_id then
                return this.UIConfig.barrel_config[i].name
            end
        end
    else
        return this.UIConfig.barrel_config[1].name
    end
end


function M.GetCurChoseBedID()
    if this.m_data.GunInfo and this.m_data.GunInfo.bed_id then
        return this.m_data.GunInfo.bed_id
    else
        M.QueryGunInfo()
        return 1
    end
end



function M.GetCurChoseFrameID()
    if this.m_data.GunInfo and this.m_data.GunInfo.frame_id then
        return this.m_data.GunInfo.frame_id
    else
        M.QueryGunInfo()
        return 1
    end
end

function M.SetHeadFrame(img, id)
    if not id then
        name = M.DefineFrame()
    else
        name = M.GetFrameImg(id)
    end
    img.sprite = GetTexture(name)
end

function M.DefineFrame()
    local x = SYSByBagManager.item_gun_config.config
    local frame_id_temp = SYSByBagManager.GetCurChoseFrameID()
    local frame_temp_config = {}
    for i=1,#x do
        if x[i].type == 3 then
            frame_temp_config[#frame_temp_config + 1] = x[i]
        end
    end
    local frame = "dt_tx_bg1"
    for i=1,#frame_temp_config do
        if frame_temp_config[i].item_id == frame_id_temp then
            frame = frame_temp_config[i].image
            break
        end
    end
    return frame
end

function M.GetFrameImg(id)
    local x = SYSByBagManager.item_gun_config.config
    local frame_temp_config = {}
    for i=1,#x do
        if x[i].type == 3 then
            frame_temp_config[#frame_temp_config + 1] = x[i]
        end
    end
    local frame = 0
    for i=1,#frame_temp_config do
        if frame_temp_config[i].item_id == id then
            frame = frame_temp_config[i].image
            break
        end
    end
    return frame
end