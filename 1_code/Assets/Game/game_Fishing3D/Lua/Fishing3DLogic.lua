-- 创建时间:2019-03-06

ext_require ("Game.game_Fishing3D.Lua.Fishing3DModel")
ext_require ("Game.game_Fishing3D.Lua.Fishing3DGamePanel")
ext_require("Game.game_Fishing3D.Lua.Fishing3DHallGuideSessionPanel")

ext_require ("Game.CommonPrefab.Lua.FishingLoadingPanel")
ext_require ("Game.CommonPrefab.Lua.FishingUninstallPanel")

ext_require ("Game.game_Fishing3D.Lua.Fishing3DNorSKillPrefab")
ext_require ("Game.game_Fishing3D.Lua.Fishing3DOperPrefab")
ext_require ("Game.game_Fishing3D.Lua.Fish3DBase")
ext_require ("Game.game_Fishing3D.Lua.Fish3D")

ext_require ("Game.CommonPrefab.Lua.Vehicle")
ext_require ("Game.CommonPrefab.Lua.FishManager")
ext_require ("Game.CommonPrefab.Lua.BulletManager")
ext_require ("Game.CommonPrefab.Lua.FishingSkillManager")

ext_require ("Game.CommonPrefab.Lua.BulletPrefab")
ext_require ("Game.CommonPrefab.Lua.FishExtManager")
ext_require ("Game.CommonPrefab.Lua.FishNetPrefab")
ext_require ("Game.CommonPrefab.Lua.BulletPrefabZT")
--机器人
ext_require ("Game.CommonPrefab.Lua.FishingPlayerAIManager")
ext_require ("Game.CommonPrefab.Lua.FishingActivityManager")


ext_require ("Game.game_Fishing3D.Lua.Fish3DDeadManager")
ext_require ("Game.game_Fishing3D.Lua.Fishing3DPlayer")
ext_require ("Game.game_Fishing3D.Lua.Fishing3DGun")
ext_require ("Game.CommonPrefab.Lua.VehicleManager")
ext_require("Game.game_Fishing3D.Lua.Fishing3DZPCJPrefab")
ext_require("Game.game_Fishing3D.Lua.Fishing3DZPCJZPPrefab")
ext_require("Game.normal_fishing3d_common.Lua.Fishing3DBKPanel")
ext_require("Game.game_Fishing3D.Lua.Fishing3DAnimManager")
ext_require("Game.game_Fishing3D.Lua.Fishing3DSceneAnim")
ext_require("Game.game_Fishing3D.Lua.Fish3DTeam")
ext_require("Game.game_Fishing3D.Lua.Fishing3DFZ_HF")
ext_require("Game.game_Fishing3D.Lua.Fish3DBOX")
ext_require("Game.game_Fishing3D.Lua.Fish3DZYCS")
ext_require("Game.game_Fishing3D.Lua.Fish3DJLong")
ext_require("Game.game_Fishing3D.Lua.Fish3DHYLong")
ext_require("Game.game_Fishing3D.Lua.Fishing3DHLDeadPrefab")
ext_require("Game.normal_base_common.Lua.FishingComPlayerAI")

FishingLogic = {}

FishingLogic.panelNameMap = {
    hall = "hall",
    game = "game"
}

local cur_panel

local this
--自己关心的事件
local lister

local is_allow_forward = false
--view关心的事件
local viewLister = {}
local have_Jh
local jh_name = "ddz_free_game"

--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister = {}

    lister["ReConnecteServerSucceed"] = this.on_reconnect_msg
    lister["DisconnectServerConnect"] = this.on_network_error_msg
    lister["EnterForeGround"] = this.on_backgroundReturn_msg
    lister["EnterBackGround"] = this.on_background_msg

end

local function SendRequestAllInfo()
    if FishingModel.data and FishingModel.data.model_status == FishingModel.Model_Status.gameover then
    else
        --限制处理消息  此时只处理指定的消息
        FishingModel.data.limitDealMsg = {fsg_3d_all_info_test_response = true}
        FishingModel.SendAllInfo()
    end
end

local function AddMsgListener(lister)
    for proto_name, func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end

local function RemoveMsgListener(lister)
    for proto_name, func in pairs(lister) do
        Event.RemoveListener(proto_name, func)
    end
end

local function ViewMsgRegister(registerName)
    if registerName then
        if viewLister and viewLister[registerName] and is_allow_forward then
            AddMsgListener(viewLister[registerName])
        end
    else
        if viewLister and is_allow_forward then
            for k, lister in pairs(viewLister) do
                AddMsgListener(lister)
            end
        end
    end
end

local function cancelViewMsgRegister(registerName)
    if registerName then
        if viewLister and viewLister[registerName] then
            RemoveMsgListener(viewLister[registerName])
        end
    else
        if viewLister then
            for k, lister in pairs(viewLister) do
                RemoveMsgListener(lister)
            end
        end
    end
    DOTweenManager.KillAllStopTween()
end

local function clearAllViewMsgRegister()
    cancelViewMsgRegister()
    viewLister = {}
end

function FishingLogic.setViewMsgRegister(lister, registerName)
    --检测是否已经注册
    if not registerName or viewLister[registerName] then
        return false
    end
    viewLister[registerName] = lister
    ViewMsgRegister(registerName)
end

function FishingLogic.clearViewMsgRegister(registerName)
    if not registerName then
        return false
    end
    cancelViewMsgRegister(registerName)
    viewLister[registerName] = nil
end

function FishingLogic.refresh_panel()
    if cur_panel then
        cur_panel.instance:MyRefresh()
    end
end
function FishingLogic.GetPanel()
    return cur_panel.instance
end

function FishingLogic.change_panel(panelName, pram)
    if have_Jh then
        FullSceneJH.RemoveByTag(have_Jh)
        have_Jh = nil
    end
    if cur_panel then
        if cur_panel.name == panelName then
            cur_panel.instance:MyRefresh()
        elseif panelName == FishingLogic.panelNameMap.hall then
            DOTweenManager.KillAllStopTween()
            cur_panel.instance:MyExit()
            cur_panel = nil
        else
            DOTweenManager.KillAllStopTween()
            cur_panel.instance:MyClose()
            cur_panel = nil
        end
    end
    if not cur_panel then
        if panelName == FishingLogic.panelNameMap.hall then
            if FishingModel.game_id >= 6 and FishingModel.game_id <= 8 then
                GameManager.GotoSceneName("game_Fishing3DBossHall")
            else
                GameManager.GotoSceneName("game_Fishing3DHall")
            end
        elseif panelName == FishingLogic.panelNameMap.game then
            cur_panel = {name = panelName, instance = FishingGamePanel.Create(pram)}
        end
    end
end

--游戏前台消息
function FishingLogic.on_backgroundReturn_msg()
    if FishingLogic.is_quit then
        FishingLogic.quit_game()
    else
        if not FishingModel.IsLoadRes then
            if cur_panel then
                cur_panel.instance:on_backgroundReturn_msg()
            end
            -- FishingModel.SetUpdateFrame(true)
            SendRequestAllInfo()
            print("<color=red>XXX 游戏前台消息 XXX</color>")
        end
    end
end
--游戏后台消息
function FishingLogic.on_background_msg()
    if FishingLogic.is_quit then
    else
        if not FishingModel.IsLoadRes then
            DOTweenManager.KillAllStopTween()
            if cur_panel then
                cur_panel.instance:on_background_msg()
            end
            FishingModel.SetUpdateFrame(false)
            print("<color=red>XXX 游戏后台消息 XXX</color>")
        end
    end
end
--游戏网络破损消息
function FishingLogic.on_network_error_msg()
    if FishingLogic.is_quit then
    else
        FishingModel.SetUpdateFrame(false)
        if cur_panel and cur_panel.instance.update_time then
            cur_panel.instance.update_time:Stop()
        end
        cancelViewMsgRegister()
        print("<color=red>XXX 游戏网络破损消息 XXX</color>")
        FishingModel.IsRecoverRet = true
    end
end
--游戏网络状态差
function FishingLogic.on_network_poor_msg()
    print("<color=red>XXX 游戏网络状态差 XXX</color>")
end
--游戏重新连接消息
function FishingLogic.on_reconnect_msg()
    if FishingLogic.is_quit then
        FishingLogic.quit_game()
    else
        print("<color=red>XXX 游戏重新连接消息 XXX</color>")
        FishingModel.SetUpdateFrame(false)
        if cur_panel and cur_panel.instance.update_time then
            cur_panel.instance.update_time:Stop()
        end

        SendRequestAllInfo()
    end
end
--断线重连相关**************

--初始化
function FishingLogic.Init(pram)
    this = FishingLogic
    --初始化model
    local model = FishingModel.Init()
    if pram then
        FishingModel.game_id = pram.game_id
    else
        FishingModel.game_id = MainModel.game_id
    end

    MakeLister()
    AddMsgListener(lister)

    FishingSkillManager.Init("by3d")
    MainLogic.EnterGame()

    local size = GameObject.Find("Canvas"):GetComponent("RectTransform").sizeDelta
    local width = size.x/size.y * 5.4
    local height = 5.4
    FishingModel.Defines.WorldDimensionUnit = {xMin=-width, xMax=width, yMin=-height, yMax=height}
    FishingModel.IsRecoverRet = true
    FishingModel.IsLoadRes = true
    dump(FishingModel.Defines.WorldDimensionUnit, "<color=white>屏幕适配尺寸</color>")

    FishingModel.data.limitDealMsg = {fsg_3d_all_info_test_response = true}

    FishingLogic.change_panel(FishingLogic.panelNameMap.game, pram)
end

function FishingLogic.Exit()
    if this then
        this = nil
        FishingModel.Exit()
        if cur_panel then
            cur_panel.instance:MyExit()
        end
        FishingSkillManager.MyExit()
        -- for k,v in ipairs(FishingModel.Config.fish_cache_list) do
        --     CachePrefabManager.DelCachePrefab(v.prefab)
        -- end
        soundMgr:CloseSound()
        cur_panel = nil
        RemoveMsgListener(lister)
        clearAllViewMsgRegister()
    end
end

function FishingLogic.quit_game(call, quit_msg_call)
    -- 排名赛屏蔽跳转
    if FishingModel.data.is_close_goto then
        LittleTips.Create("积分赛中不可前往其他场景，请先完成比赛！")
        return
    end

    if not FishingLogic.is_quiting then
        --------------------------------------------------
        -- 排名赛进入后后台10分钟回来，再次后台回来点退出会断线，导致退出不了
        --------------------------------------------------
        --[[
        MainLogic.ExitGame()
        Event.Brocast("ui_fsg_quit_game")
        
        if cur_panel.name == "game" then
            cur_panel.instance:MyExit()
        end
        DOTweenManager.KillAllStopTween()
        DOTweenManager.KillAllExitTween()
        DOTweenManager.CloseAllSequence()
        --]]     
        FishingLogic.is_quiting = true

        FishingLogic.is_quit = true
        Network.SendRequest("fsg_3d_quit_game", nil, "请求退出", function (data)
            if quit_msg_call then
                quit_msg_call(data.result)
            end
            if data.result == 0 then

                MainLogic.ExitGame()
                Event.Brocast("ui_fsg_quit_game")
                
                if cur_panel.name == "game" then
                    cur_panel.instance:MyExit()
                end
                DOTweenManager.KillAllStopTween()
                DOTweenManager.KillAllExitTween()
                DOTweenManager.CloseAllSequence()

                FishingUninstallPanel.Create(function()
                    if not call then
                        FishingLogic.change_panel("hall")
                    else
                        call()
                    end
                    Event.Brocast("quit_game_success")
                end, "by3d")
            end
        end)
    end
end

return FishingLogic