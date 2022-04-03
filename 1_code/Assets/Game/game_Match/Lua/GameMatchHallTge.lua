-- 创建时间:2018-12-04

local basefunc = require "Game.Common.basefunc"

GameMatchHallTge = basefunc.class()

local C = GameMatchHallTge
C.name = "GameMatchHallTge"
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
    self:RemoveListener()
    GameObject.Destroy(self.gameObject)
end

function C:Init()
    local list = {}
    for k, v in pairs(self.config) do
        list[#list + 1] = v
    end
    table.sort(list,function(a, b)
        return a.order < b.order
    end)
    self.tge_obj_list = {}
    local TG = self.SV.transform:GetComponent("ToggleGroup")
    for k, v in ipairs(list) do
        if v.is_show and v.is_show == 1 then
            self:SetMatchTgeItem(self.config[v.id],TG)
        end
    end
    TG.allowSwitchOff = false
end

function GameMatchHallTge:SetMatchTgeItem(config,TG)
    local go = GameObject.Instantiate(GetPrefab(config.tge_prefab), self.switch_content)
    go.gameObject:SetActive(config.is_show == 1)
    go.name = config.id
    local ui_table = {}
    LuaHelper.GeneratingVar(go.transform, ui_table)
    ui_table.item_tge = go.transform:GetComponent("Toggle")
    ui_table.item_tge.group = TG
    ui_table.item_tge.onValueChanged:AddListener(
        function(val)

            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            ui_table.tge_txt.gameObject:SetActive(not val)
            ui_table.check_mark_txt.gameObject:SetActive(val)

            if val then
                if self.selectConfig and self.selectConfig.game_tag == config.game_tag then
                    return
                end
                self.selectConfig = config
                GameMatchHallPanel.UpdateRightUI(config)
            end
        end
    )
    ui_table.tge_txt.text = config.game_name
    ui_table.check_mark_txt.text = config.game_name
    self.tge_obj_list[config.id] = ui_table

    if config.is_tj and config.is_tj == 1 then
        ui_table.hint_node.gameObject:SetActive(true)
    else
        ui_table.hint_node.gameObject:SetActive(false)
    end

    if type(config.game_type) == "table" then
        for i,v in ipairs(config.game_type) do
            GameMatchHallPanel.HandleEnterGameClick(
                v,
                function()
                    ui_table.loadown_img.gameObject:SetActive(true)
                end,
                function()
                    ui_table.loadown_img.gameObject:SetActive(false)
                end
            )
            if ui_table.loadown_img.gameObject.activeSelf then
                break
            end
        end
    else
        GameMatchHallPanel.HandleEnterGameClick(
            config.game_type,
            function()
                ui_table.loadown_img.gameObject:SetActive(true)
            end,
            function()
                ui_table.loadown_img.gameObject:SetActive(false)
            end
        )
    end
    
        --权限
    if config.game_tag == GameMatchModel.MatchType.qys then
        local parm = {_permission_key="match_game_8888", is_on_hint = true}
        local a = SYSQXManager.CheckCondition(parm)
        if a then
            go.gameObject:SetActive(config.is_show == 1)
        else
            go.gameObject:SetActive(false)
        end
    end
end

function GameMatchHallTge.SetTgeIsOn(id)
    if instance and instance.tge_obj_list[id] then
        local tge_item = instance.tge_obj_list[id]
        tge_item.item_tge.isOn = true
    end
end

function GameMatchHallTge.SetLoadownIsShow(id,bool)
    if instance and instance.tge_obj_list[id] then
        local tge_item = instance.tge_obj_list[id]
        tge_item.loadown_img.gameObject:SetActive(bool)
    end
end