-- 创建时间:2018-12-04

local basefunc = require "Game.Common.basefunc"

GameMatchHallTgeMini = basefunc.class()

local C = GameMatchHallTgeMini
C.name = "GameMatchHallTgeMini"
local instance
function C.Create(parent, config)
    if instance then
        instance:MyExit()
    end
    instance = C.New(parent, config)
	return instance
end

function C.Close()
    if instance then
        instance:MyExit()
    end
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:ctor(parent, config)
    self.config = config
	local obj = newObject(C.name, parent)
	self.gameObject = obj
	self:MakeLister()
    self:AddMsgListener()

    LuaHelper.GeneratingVar(obj.transform, self)
    self:Init()
end

function C:MyExit()
    self.tge_obj_list = {}
    self:RemoveListener()
    GameObject.Destroy(self.gameObject)
end

function C:Init()
    self.tge_obj_list = {}
    local TG = self.switch_content.transform:GetComponent("ToggleGroup")
    if type(self.config.game_type) == "table" then
        for i=1,#self.config.game_type do
            local cfg = {}
            cfg.game_type = self.config.game_type[i]
            cfg.game_desc = self.config.tge_mini_desc[i]
            cfg.tge_prefab = self.config.tge_mini_prefab
            self:SetMatchTgeItem(cfg,TG)
        end
    end
    TG.allowSwitchOff = true
end

function GameMatchHallTgeMini:SetMatchTgeItem(config,TG)
    local go = GameObject.Instantiate(GetPrefab(config.tge_prefab), self.switch_content)
    go.name = config.game_type
    local ui_table = {}
    LuaHelper.GeneratingVar(go.transform, ui_table)
    ui_table.item_tge = go.transform:GetComponent("Toggle")
    ui_table.item_tge.group = TG
    ui_table.item_tge.onValueChanged:AddListener(
        function(val)
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if val then
                GameMatchHallContent.RefreshSwitch(config.game_type)
            end
        end
    )
    ui_table.desc_txt.text = config.game_desc
    self.tge_obj_list[config.game_type] = ui_table
end

function GameMatchHallTgeMini.SetTgeIsOn(game_type)
    if instance and instance.tge_obj_list[game_type] then
        instance.tge_obj_list[game_type].item_tge.isOn = true
    end
end