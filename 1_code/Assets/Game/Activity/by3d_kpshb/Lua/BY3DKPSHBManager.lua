local basefunc = require "Game/Common/basefunc"
BY3DKPSHBManager = {}
local M = BY3DKPSHBManager
M.key = "by3d_kpshb"

GameButtonManager.ExtLoadLua(M.key, "by3d_kpshbPrefabPanel")
GameButtonManager.ExtLoadLua(M.key, "by3d_ksshb_hallprefab")
GameButtonManager.ExtLoadLua(M.key, "BY3DKPSHBEnterPanel")
GameButtonManager.ExtLoadLua(M.key, "KPSHBSMPrefabPanel")
GameButtonManager.ExtLoadLua(M.key, "KPSHBTCPanel")
GameButtonManager.ExtLoadLua(M.key, "KPSHBLotteryPanel")
GameButtonManager.ExtLoadLua(M.key, "KPSHBLotteryPrefab")
GameButtonManager.ExtLoadLua(M.key, "KPSHBLotteryTopPrefab")
GameButtonManager.ExtLoadLua(M.key, "KPSHBLotteryGotoPanel")

local config = GameButtonManager.ExtLoadLua(M.key, "fishing3d_kpshb_config")
local this
local lister

BY3DKPSHBManager.GameType = {
    GT_3D = "3d",
    GT_JJ = "jj",
}

-- 是否有活动
function M.IsActive(condi_key)
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key = condi_key
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
    if tonumber(parm.goto_scene_parm) then
        return M.IsActive()
    end
    M.SetCurQXByConfig()
    -- 目前只有体验场没有
    if (MainModel.myLocation == "game_Fishing3D" and not this.UIConfig.game_task_map[FishingModel.game_id])
        or (MainModel.myLocation == "game_Fishing" and not this.UIConfig.jj_game_task_map[FishingModel.game_id]) then
        return false
    end

    -- 没有任务数据或者没有玩家数据
    if (MainModel.myLocation == "game_Fishing" or MainModel.myLocation == "game_Fishing3D") and ( not GameTaskModel.GetTaskDataByID(M.GetCurrTaskID( M.GetGameType() )) or not FishingModel.GetPlayerData() or not this.m_data.crr_level ) then
        return false
    end

    return M.IsActive(parm.condi_key)
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

    if parm.goto_scene_parm == "game" then
        return BY3DKPSHBEnterPanel.Create(parm)
    elseif tonumber(parm.goto_scene_parm) then
        return by3d_kpshbPrefabPanel.Create(parm)
    elseif parm.goto_scene_parm == "cj" then
        if MainModel.myLocation == "game_Fishing3D" then
            return KPSHBLotteryPanel.Create(parm, parm.parent, BY3DKPSHBManager.GameType.GT_3D)
        elseif MainModel.myLocation == "game_Fishing" then
            return KPSHBLotteryPanel.Create(parm, parm.parent, BY3DKPSHBManager.GameType.GT_JJ)
        else
            return KPSHBLotteryGotoPanel.Create(parm, parm.parent)
        end
    elseif parm.goto_scene_parm == "bytop_area" then
        return BY3DKPSHBEnterPanel.Create(parm, BY3DKPSHBManager.GameType.GT_3D)
    elseif parm.goto_scene_parm == "bytop_area1" then
        return BY3DKPSHBEnterPanel.Create(parm, BY3DKPSHBManager.GameType.GT_JJ)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>") 
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    if M.GetCurTaskFinishLv() > 0 then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
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
    lister["EnterScene"] = this.OnEnterScene

    lister["model_task_change_msg"] = this.model_task_change_msg
    lister["refresh_gun"] = this.on_refresh_gun
    lister["fishing_ready_finish"] = this.on_fishing_ready_finish
    lister["ui_byhall_select_msg"] = this.on_ui_byhall_select_msg
    lister["model_query_one_task_data_response"] = this.on_model_query_one_task_data_response
end

function M.Init()
    M.Exit()

    this = BY3DKPSHBManager
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
-- 设置权限对应的配置表
function M.SetCurQXByConfig(is_force)
    -- 强制执行
    if is_force then
        this.UIConfig.game_task_map = {}
        this.UIConfig.task_award_map = {}
        this.UIConfig.jj_game_task_map = {}
        this.UIConfig.jj_task_award_map = {}
    end
    if this.UIConfig.game_task_map and next(this.UIConfig.game_task_map) then
        return
    end

    -- 3D捕鱼
    this.UIConfig.game_task_map = {}
    this.UIConfig.task_award_map = {}
    for k,v in ipairs(config.config) do
        local a,b = GameButtonManager.RunFunExt("sys_qx", "CheckCondition", nil, {_permission_key=v.key, is_on_hint = true})
        if a and b then
            this.UIConfig.task_award_map[v.task_ids] = v.hb
            this.UIConfig.game_task_map[v.game_id] = v

            local hb_lv = {}
            local hb_show = v.hb_show
            local s1 = StringHelper.Split(hb_show, "#")
            for k1,v1 in ipairs(s1) do
                hb_lv[k1] = {}
                local s2 = StringHelper.Split(v1, ";")
                for k2,v2 in ipairs(s2) do
                    hb_lv[k1][k2] = v2
                end
            end
            local assets = {}
            for i = 1, 3 do
                local dd = {}
                for j = 1, 3 do
                    local jj = (i - 1) * 3 + j
                    dd[#dd + 1] = {value=v.asset_value[jj], type=v.asset_type[jj]}
                end
                assets[#assets + 1] = dd
            end
            this.UIConfig.game_task_map[v.game_id].hb_lv = hb_lv
            this.UIConfig.game_task_map[v.game_id].assets = assets
        end
    end

    -- 街机捕鱼
    this.UIConfig.jj_game_task_map = {}
    this.UIConfig.jj_task_award_map = {}
    for k,v in ipairs(config.jjconfig) do
        local a,b = GameButtonManager.RunFunExt("sys_qx", "CheckCondition", nil, {_permission_key=v.key, is_on_hint = true})
        if a and b then
            this.UIConfig.jj_task_award_map[v.task_ids] = v.hb
            this.UIConfig.jj_game_task_map[v.game_id] = v

            local hb_lv = {}
            local hb_show = v.hb_show
            local s1 = StringHelper.Split(hb_show, "#")
            for k1,v1 in ipairs(s1) do
                hb_lv[k1] = {}
                local s2 = StringHelper.Split(v1, ";")
                for k2,v2 in ipairs(s2) do
                    hb_lv[k1][k2] = v2
                end
            end
            local assets = {}
            for i = 1, 3 do
                local dd = {}
                for j = 1, 3 do
                    local jj = (i - 1) * 3 + j
                    dd[#dd + 1] = {value=v.asset_value[jj], type=v.asset_type[jj]}
                end
                assets[#assets + 1] = dd
            end
            this.UIConfig.jj_game_task_map[v.game_id].hb_lv = hb_lv
            this.UIConfig.jj_game_task_map[v.game_id].assets = assets
        end
    end

    dump(this.UIConfig.game_task_map, "<color=red><size=16>||||||||||  ddddddddd</size></color>")
end

function M.OnLoginResponse(result)
    if result == 0 then
        -- 数据初始化
    end
end
function M.OnReConnecteServerSucceed()
end

function M.OnEnterScene()
    if MainModel.myLocation == "game_Hall" then
        by3d_ksshb_hallprefab.Create()
    end
    if MainModel.myLocation == "game_Fishing3D" or MainModel.myLocation == "game_Fishing" then
        this.m_data.is_one_enter = true
    end

    if MainModel.myLocation == "game_FishingHall" and M.IsActive() then
        local old_obj = GameObject.Find("Canvas/LayerLv1/kpshb_byhall_hintobj")
        if IsEquals(old_obj) then
            destroy(old_obj)
        end
        byhall_rect = {}
        local parent = GameObject.Find("Canvas/LayerLv1").transform
        local obj = newObject("kpshb_byhall_hintobj", parent)
        LuaHelper.GeneratingVar(obj.transform, byhall_rect)

        for k=1,3 do
            byhall_rect["rect" .. k].gameObject:SetActive(true)
        end
        M.on_ui_byhall_select_msg(byhall_index)
    end
end

function M.on_model_query_one_task_data_response(data)
    if data and data.id and data.id == M.GetCurrTaskID( M.GetGameType() ) then
        Event.Brocast("ui_button_state_change_msg")
    end
end

-- 任务改变
function M.model_task_change_msg(data)
   if M.IsCareTaskID(data.id) then
        -- 阶段改变点
        if data.now_lv ~= this.m_data.crr_level or data.now_process == data.need_process then
            this.m_data.crr_level = data.now_lv
            Event.Brocast("crr_level_state_change_msg")
            Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
        end
        Event.Brocast("kpshb_model_task_change_msg")
   end
end

function M.on_fishing_ready_finish()
    if M.IsGameingAndExistTask() then
        local task = GameTaskModel.GetTaskDataByID( M.GetCurrTaskID( M.GetGameType() ) )
        if not task then
            return
        end
        this.m_data.crr_level = task.now_lv

        local user = FishingModel.GetPlayerData()
        local gun_config = FishingModel.GetGunCfg(user.index)
        local g_data = {seat_num = FishingModel.GetPlayerSeat(), gun_rate = gun_config.gun_rate}
        this.m_data.g_data = g_data

        Event.Brocast("ui_button_state_change_msg")
    end
    --12.1号运营活动 暂时屏蔽说明
    -- if this.m_data.is_one_enter and M.IsGameingAndExistTask() and MainModel.UserInfo.ui_config_id == 2 then
    --     if MainModel.myLocation == "game_Fishing3D" then
    --         if PlayerPrefs.GetInt("by3dkp"..MainModel.UserInfo.user_id, 0) + 1800 < os.time() then
    --             KPSHBSMPrefabPanel.Create(M.GameType.GT_3D)
    --             PlayerPrefs.SetInt("by3dkp"..MainModel.UserInfo.user_id, os.time())
    --         end        
    --     else
    --         if PlayerPrefs.GetInt("bykp"..MainModel.UserInfo.user_id, 0) + 1800 < os.time() then
    --             KPSHBSMPrefabPanel.Create(M.GameType.GT_JJ)
    --             PlayerPrefs.SetInt("bykp"..MainModel.UserInfo.user_id, os.time())
    --         end        
    --     end
    -- end
    this.m_data.is_one_enter = false
end
function M.GetGameType()
    if MainModel.myLocation == "game_Fishing3D" then
        return M.GameType.GT_3D
    elseif MainModel.myLocation == "game_Fishing" then
        return M.GameType.GT_JJ
    end
end

--判断是否是自己关心的任务
function M.IsCareTaskID(id)
    M.SetCurQXByConfig()
    if MainModel.myLocation == "game_Fishing3D" then
        if this.UIConfig.task_award_map[id] then
            return true 
        end
    elseif MainModel.myLocation == "game_Fishing" then
        if this.UIConfig.jj_task_award_map[id] then
            return true 
        end
    end
end
-- 是否在游戏并且当前场次存在任务
function M.IsGameingAndExistTask()
    M.SetCurQXByConfig()
    if MainModel.myLocation == "game_Fishing3D" and FishingModel and FishingModel.data and this.UIConfig.game_task_map[FishingModel.game_id] then
        return true
    end
    if MainModel.myLocation == "game_Fishing" and FishingModel and FishingModel.data and this.UIConfig.jj_game_task_map[FishingModel.game_id] then
        return true
    end
end

function M.GetTaskID(game_id, gameType)
    M.SetCurQXByConfig()
    if gameType == M.GameType.GT_3D then
        return this.UIConfig.game_task_map[ game_id ].task_ids
    else
        return this.UIConfig.jj_game_task_map[ game_id ].task_ids
    end
end
function M.GetCurrTaskID(gameType)
    if M.IsGameingAndExistTask() then
        return M.GetTaskID(FishingModel.game_id, gameType)
    end  
end

function M.GetTaskDataByID(task_ids)
    return GameTaskModel.GetTaskDataByID( task_ids )
end

function M.QuiteCreate()
    if M.IsGameingAndExistTask() then
        if MainModel.myLocation == "game_Fishing3D" then
            KPSHBTCPanel.Create(M.GameType.GT_3D)
        else
            KPSHBTCPanel.Create(M.GameType.GT_JJ)
        end
    else 
       FishingLogic.quit_game()
   end   
end

function M.on_refresh_gun(g_data)
    if g_data.seat_num == FishingModel.GetPlayerSeat() then
        this.m_data.g_data = g_data
        Event.Brocast("by3d_kpshb_refresh_gun")
    end
end

-- 
function M.GetConfigByGameID(game_id, gameType)
    M.SetCurQXByConfig()
    if gameType == M.GameType.GT_3D then
        return this.UIConfig.game_task_map[ game_id ]
    else
        return this.UIConfig.jj_game_task_map[ game_id ]
    end
end
-- 当前任务所在的阶段(等级)
function M.GetCurTaskLv(gameType)
    return this.m_data.crr_level
end
-- 当前任务完成的阶段(等级)
function M.GetCurTaskFinishLv(gameType)
    local wc_lv
    local lv = M.GetCurTaskLv(gameType)
    if not lv then
        return 0
    end
    if lv == 1 then
        wc_lv = 0
    elseif lv == 2 then
        wc_lv = 1
    else
        local task = GameTaskModel.GetTaskDataByID( M.GetCurrTaskID( M.GetGameType() ) )
        if task.now_process >= task.need_process then
            wc_lv = 3
        else
            wc_lv = 2
        end
    end
    return wc_lv
end

    
-- 
function M.GetTaskMaxNumByLv(lv, gameType)
    local cfg = M.GetConfigByGameID(FishingModel.game_id, gameType)
    return cfg.hb[#cfg.hb]
end
function M.GetGunData()
    return this.m_data.g_data
end
-- 是否可以抽奖
function M.IsCanGetAward()
    if this.m_data.crr_level and this.m_data.crr_level > 1 then
        return true
    end
end
-- 获取任务某阶段的剩余炮数
function M.GetGunRateSurNum(i, gameType)
    local cfg = M.GetConfigByGameID(FishingModel.game_id, gameType)
    local jd = cfg.jd[i] or 0
    local num
    local task_data = GameTaskModel.GetTaskDataByID(M.GetCurrTaskID( gameType ))
    if this.m_data.g_data and this.m_data.g_data.gun_rate and task_data then
        local re = basefunc.parse_activity_data(task_data.other_data_str)
        if tonumber(re.is_first_game) == 1
            and task_data.now_lv == 1
            and ( (gameType == M.GameType.GT_3D and FishingModel.game_id == 2) ) then
            num = math.ceil((jd - task_data.now_process) / (this.m_data.g_data.gun_rate*100))
            return  num
        else 
            num = math.ceil((jd - task_data.now_process) / this.m_data.g_data.gun_rate)
            return num
        end
    end    
    return 0
end

function M.GetHBRateConfigByIDIndex(game_id, i, gameType)
    M.SetCurQXByConfig()
    if gameType == M.GameType.GT_3D then
        return this.UIConfig.game_task_map[game_id].hb_lv[i]
    else
        return this.UIConfig.jj_game_task_map[game_id].hb_lv[i]
    end
end

function M.GetAssetByIDIndex(game_id, i, gameType)
    M.SetCurQXByConfig()
    if gameType == M.GameType.GT_3D then
        return this.UIConfig.game_task_map[game_id].assets[i]
    else
        return this.UIConfig.jj_game_task_map[game_id].assets[i]
    end
end

function M.GetFishCoinAndJingBi()
    if MainModel.UserInfo.jing_bi and MainModel.UserInfo.fish_coin then
        return MainModel.UserInfo.jing_bi + MainModel.UserInfo.fish_coin
    end
    return MainModel.UserInfo.jing_bi
end

-- 领取的红包券是否达到上限
function M.IsRedGetReachMax( game_id , gameType)
    local task = M.GetTaskDataByID( M.GetTaskID(game_id, gameType) )
    if task and task.other_data_str then
        local re = basefunc.parse_activity_data(task.other_data_str)
        if re.can_award_total and re.now_award and tonumber(re.can_award_total) <= tonumber(re.now_award) then
            return true
        end
    end
end

-- 推荐前往场次逻辑 引导玩家到高级场
function M.GuidePlayerGoGJC(is_havd, gameType)
    if FishingModel.data and FishingModel.data.is_close_goto then
        if is_havd then
            LittleTips.Create("积分赛中不可前往其他场景，请先完成比赛！")
        end
        return
    end
    -- 红包达到上限
    if M.IsRedGetReachMax(FishingModel.game_id, gameType) then
        local jb = M.GetFishCoinAndJingBi(gameType)
        if jb < 100000 then
            local pre1 = HintPanel.Create(2, "金币不足啦！<color=#EC4B13>赶紧前往商城补充吧！</color>", function ()
                Event.Brocast("show_gift_panel")
            end, function ()
                -- 点关闭显示上一个界面(达到上限的提示)
                M.GuidePlayerGoGJC(false, gameType)
            end)
            pre1:SetButtonText(nil, "前 往")
        else
            M.GotoGJC(true, gameType)
        end
    else
        M.GotoGJC(false, gameType)
    end
end

function M.GotoGJC(is_zj_goto, gameType)
    -- 推荐高级场
    local id = FishingModel.GetCanEnterID()

    if gameType == M.GameType.GT_3D then
        -- 特殊逻辑 (策划：身上金额不足以去3、4、5号场时，点击前往按钮后固定前往3号场)
        if is_zj_goto and id <= FishingModel.game_id then
            id = 3
        end
    else
        -- 特殊逻辑 (策划：身上金额不足以去2,3号场时，点击前往按钮后固定前往2号场)
        if is_zj_goto and id <= FishingModel.game_id then
            id = 2
        end
    end
    
    dump(id, "<color=red>EEEEEE GotoGJC id</color>")
    local user = FishingModel.GetPlayerData()
    if id > FishingModel.game_id and user then
        user.is_auto = false
        Event.Brocast("set_gun_auto_state", { seat_num=user.base.seat_num })
        if is_zj_goto then
            FishingModel.GotoFishingByID(id)
        else
            local cfg
            if gameType == M.GameType.GT_3D then
                cfg = GameFishing3DManager.GetGameIDToConfig(id)
            else
                cfg = FishingManager.GetPPIDToConfig(id)
            end

            local cc = M.GetConfigByGameID(id, gameType)
            local pre = HintPanel.Create(2, "您可以进入" .. cfg.name .. "进行游戏哦!\n爆率更高超爽体验开炮最高可获得<color=#FF0000>" .. cc.show_hb .. "</color>福利券!", function ()
                FishingModel.GotoFishingByID(id)
            end)
            pre:SetButtonText(nil, "立即前往")
        end
    end
end


-- 街机捕鱼大厅显示

local function set_ui(obj, b, index)
    local img1 = obj.transform:Find("byxrhb_hongbao/qipao/qipao"):GetComponent("Image")
    local img2 = obj.transform:Find("byxrhb_hongbao/qipao/Image1"):GetComponent("Image")
    local img3 = obj.transform:Find("byxrhb_hongbao/qipao/hongbao"):GetComponent("Image")
    local txt1 = obj.transform:Find("byxrhb_hongbao/qipao/hongbao/Text"):GetComponent("Text")

    local cfg = M.GetConfigByGameID(index, M.GameType.GT_JJ)
    if cfg then
        txt1.text = StringHelper.ToCash(cfg.show_hb)
    else
        txt1.text = "--"
    end

    local c = 1
    if b then
        c = 1
    else
        c = 0.7
    end
    img1.color = Color.New(c, c, c, 1)
    img2.color = Color.New(c, c, c, 1)
    img3.color = Color.New(c, c, c, 1)
end
function M.on_ui_byhall_select_msg(i)
    if not i then
        return
    end
    byhall_index = i
    print("<color=red>EEE on_ui_byhall_select_msg</color>")
    if byhall_rect then
        for k = 1, 3 do
            local key = "rect" .. k
            if byhall_rect[key] and IsEquals(byhall_rect[key]) then
                if i == k then
                    byhall_rect[key].transform.localScale = Vector3.one
                    set_ui(byhall_rect[key], true, k)
                else
                    byhall_rect[key].transform.localScale = Vector3.New(0.8, 0.8, 0.8)
                    set_ui(byhall_rect[key], false, k)
                end
            end
        end
    end
end
