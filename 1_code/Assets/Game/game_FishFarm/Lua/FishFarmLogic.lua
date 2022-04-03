-- 创建时间:2020-07-24
local cur_path = "Game.game_FishFarm.Lua."
ext_require(cur_path .. "FishFarmAnimManager")
ext_require(cur_path .. "FishFarmModel")
ext_require(cur_path .. "FishFarmGamePanel")
ext_require(cur_path .. "FishFarm3DBase")
ext_require(cur_path .. "FishTankMoveVehicle")
ext_require(cur_path .. "FishFarmEggPrefab")
ext_require(cur_path .. "FishFarmSalePanel")
ext_require(cur_path .. "FishFarm3DUI")
ext_require(cur_path .. "FishFarmReapPanel")
ext_require(cur_path .. "FishFarmInfoPanel")
ext_require(cur_path .. "FishFarmCollect")
ext_require(cur_path .. "FishFarmBagPanel")
ext_require(cur_path .. "FishFarmBagLeftPrefab")
ext_require(cur_path .. "FishFarmBagFryPanel")
ext_require(cur_path .. "FishFarmBagFishPanel")
ext_require(cur_path .. "FishFarmBagFryFragmentPanel")
ext_require(cur_path .. "FishFarmBagItemBase")
ext_require(cur_path .. "FishFarmBookPanel")
ext_require(cur_path .. "SwimManager")

FishFarmLogic = {}
local L = FishFarmLogic
L.panelNameMap = {
    game = "game",
    hall = "hall"
}

local cur_panel

local this
--自己关心的事件
local lister
--view关心的事件
local viewLister = {}

local function MakeLister()
    lister = {}

    lister["model_status_no_error_msg"] = this.on_status_error_msg
    -- 网络
    lister["EnterForeGround"] = this.on_backgroundReturn_msg
    lister["EnterBackGround"] = this.on_background_msg
    lister["ReConnecteServerSucceed"] = this.on_reconnect_msg
    lister["DisconnectServerConnect"] = this.on_network_error_msg
end
local function SendRequestAllInfo()
end

-- Logic
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
-- View 的消息处理相关方法
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

--状态错误处理
function L.on_status_error_msg()
    cancelViewMsgRegister()
    SendRequestAllInfo()
end
--游戏后台重进入消息
function L.on_backgroundReturn_msg()
    cancelViewMsgRegister()
    SendRequestAllInfo()
end
--游戏后台消息
function L.on_background_msg()
    cancelViewMsgRegister()
end
--游戏重新连接消息
function L.on_reconnect_msg()
    SendRequestAllInfo()
end
--游戏网络破损消息
function L.on_network_error_msg()
    cancelViewMsgRegister()
end

function L.setViewMsgRegister(lister, registerName)
    --检测是否已经注册
    if not registerName or viewLister[registerName] then
        return false
    end
    viewLister[registerName] = lister
    ViewMsgRegister(registerName)
end

function L.clearViewMsgRegister(registerName)
    if not registerName then
        return false
    end
    cancelViewMsgRegister(registerName)
    viewLister[registerName] = nil
end

--初始化
function L.Init(parm)
    this = L
    dump(parm, "<color=red>FishFarmLogic Init parm</color>")
    --初始化model
    local model = FishFarmModel.Init()
    MakeLister()
    AddMsgListener(lister)

    MainLogic.EnterGame()

    local size = GameObject.Find("Canvas"):GetComponent("RectTransform").sizeDelta
    local width = size.x/size.y * 5.4
    local height = 5.4
    FishFarmModel.WorldDimensionUnit = {xMin=-width, xMax=width, yMin=-height, yMax=height}

    SendRequestAllInfo()

    L.change_panel(L.panelNameMap.game)
end

function L.Exit()
    if this then
        print("<color=green>Exit  FishFarmLogic</color>")
        this = nil
        if cur_panel then
            cur_panel.instance:MyExit()
        end
        cur_panel = nil
        RemoveMsgListener(lister)
        clearAllViewMsgRegister()
        FishFarmModel.Exit()
    end
end

function L.change_panel(panelName)
    if cur_panel then
        if cur_panel.name == panelName then
            cur_panel.instance:MyRefresh()
        elseif panelName == L.panelNameMap.hall then
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
        if panelName == L.panelNameMap.hall then
            GameManager.GotoSceneName("game_Hall")
        elseif panelName == L.panelNameMap.game then
            cur_panel = {name = panelName, instance = FishFarmGamePanel.Create()}
        end
    end
end

function L.quit_game(call, quit_msg_call)
    Network.SendRequest("xxx发送退出协议", nil, "请求退出", function (data)
        if quit_msg_call then
            quit_msg_call(data.result)
        end
        if data.result == 0 then
            if not call then
                L.change_panel(L.panelNameMap.hall)
            else
                call()
            end
            Event.Brocast("quit_game_success")
        end
    end)
end


return FishFarmLogic