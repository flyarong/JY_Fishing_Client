-- 创建时间:2018-10-16
package.loaded["Game.game_Match.Lua.MatchModel"] = nil
require "Game.game_Match.Lua.MatchModel"
package.loaded["Game.game_Match.Lua.GameMatchHallPanel"] = nil
require "Game.game_Match.Lua.GameMatchHallPanel"
package.loaded["Game.game_Match.Lua.GameMatchHallDetailPanel"] = nil
require "Game.game_Match.Lua.GameMatchHallDetailPanel"

package.loaded["Game.game_Match.Lua.GameMatchHallRankPanel"] = nil
require "Game.game_Match.Lua.GameMatchHallRankPanel"

package.loaded["Game.game_Match.Lua.GameMatchHallMatchItem"] = nil
require "Game.game_Match.Lua.GameMatchHallMatchItem"

package.loaded["Game.game_Match.Lua.GameMatchHallTge"] = nil
require "Game.game_Match.Lua.GameMatchHallTge"
package.loaded["Game.game_Match.Lua.GameMatchHallTgeMini"] = nil
require "Game.game_Match.Lua.GameMatchHallTgeMini"
package.loaded["Game.game_Match.Lua.GameMatchHallContent"] = nil
require "Game.game_Match.Lua.GameMatchHallContent"

package.loaded["Game.normal_base_common.Lua.MatchComLogic"] = nil
require "Game.normal_base_common.Lua.MatchComLogic"

require "Game.normal_base_common.Lua.PayFastLogic"

local this
local lister
local cur_panel
local panelNameMap={
	hall="GameMatchHallPanel",
}
--view关心的事件
local viewLister={}

MatchLogic = {}

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

function MatchLogic.setViewMsgRegister(lister, registerName)
    --检测是否已经注册
    if not registerName or viewLister[registerName] then
        return false
    end
    viewLister[registerName] = lister
    ViewMsgRegister(registerName)
end

function MatchLogic.clearViewMsgRegister(registerName)
    if not registerName then
        return false
    end
    cancelViewMsgRegister(registerName)
    viewLister[registerName] = nil
end

function MatchLogic.change_panel(panelName)
	if cur_panel then
		if cur_panel.name==panelName then
			cur_panel.instance:MyRefresh()
		else
			DOTweenManager.KillAllStopTween()
			cur_panel.instance:MyClose()
			cur_panel=nil
		end
	end
	if not cur_panel then
		if panelName==panelNameMap.hall then
			cur_panel={name=panelName,instance=GameMatchHallPanel.Create()}
		end
	end
	--cur_panel=MatchPanel.Show(load_callback)
end

--初始化
function MatchLogic.Init(parm)
    ExtendSoundManager.PlaySceneBGM(audio_config.game.bgm_main_hall.audio_name)
    this = MatchLogic
    if parm and parm.match_type_id then
        GameMatchModel.SetCurMatchType(parm.match_type_id)
    end
    --初始化model
    local model = MatchModel.Init()
    MakeLister()
    AddMsgListener(lister)
    MatchLogic.change_panel(panelNameMap.hall)
end

function MatchLogic.Exit()
    if this then
        MatchModel.Exit()
        if cur_panel then
            cur_panel.instance:MyExit()
        end
        cur_panel = nil
        RemoveMsgListener(lister)
        clearAllViewMsgRegister()
        this = nil
    end
end

return MatchLogic
