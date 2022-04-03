-- 创建时间:2020-04-23

FishingMatchHallLogic = {}
local _path = "Game.game_FishingMatchHall.Lua."
-- 
ext_require(_path .. "FishingMatchHallModel")
ext_require(_path .. "FishingMatchHallPanel")
ext_require(_path .. "FishingMatchHallTagPrefab")
ext_require(_path .. "FishingMatchHallQYSPanel")
ext_require(_path .. "FishingMatchHallDJSPanel")

require "Game.normal_fishing_common.Lua.FishingMatchAwardPanel"
require "Game.normal_fishing_common.Lua.FishingMatchOldRankPanel"
require "Game.normal_fishing_common.Lua.FishingBKPanel"
require "Game.normal_fishing_common.Lua.FishingMatchQYSAwardPanel"

local this
local lister
local cur_panel
local panelNameMap={
	hall="hall",
}
--view关心的事件
local viewLister={}
local function MakeLister()
    lister = {}
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
        if viewLister and viewLister[registerName] then
            AddMsgListener(viewLister[registerName])
        end
    else
        if viewLister then
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

function FishingMatchHallLogic.setViewMsgRegister(lister, registerName)
    --检测是否已经注册
    if not registerName or viewLister[registerName] then
        return false
    end
    viewLister[registerName] = lister
    ViewMsgRegister(registerName)
end

function FishingMatchHallLogic.clearViewMsgRegister(registerName)
    if not registerName then
        return false
    end
    cancelViewMsgRegister(registerName)
    viewLister[registerName] = nil
end

function FishingMatchHallLogic.change_panel(panelName, parm)
	if cur_panel then
		if cur_panel.name==panelName then
			cur_panel.instance:MyRefresh(parm)
		else
			DOTweenManager.KillAllStopTween()
			cur_panel.instance:MyClose()
			cur_panel=nil
		end
	end
	if not cur_panel then
		if panelName==panelNameMap.hall then
			cur_panel={name=panelName,instance=FishingMatchHallPanel.Create(parm)}
		end
	end
end

--初始化
function FishingMatchHallLogic.Init(parm)
    ExtendSoundManager.PlaySceneBGM(audio_config.game.bgm_main_hall.audio_name)
    this = FishingMatchHallLogic
    --初始化model
    local model = FishingMatchHallModel.Init()
    MakeLister()
    AddMsgListener(lister)
    FishingMatchHallLogic.change_panel(panelNameMap.hall, parm)
end

function FishingMatchHallLogic.Exit()
    if this then
        FishingMatchHallModel.Exit()
        if cur_panel then
            cur_panel.instance:MyExit()
        end
        cur_panel = nil
        RemoveMsgListener(lister)
        clearAllViewMsgRegister()
        this = nil
    end
end

return FishingMatchHallLogic
