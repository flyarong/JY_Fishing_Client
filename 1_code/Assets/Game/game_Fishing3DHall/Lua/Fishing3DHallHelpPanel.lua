-- 创建时间:2020-05-12
-- Panel:Fishing3DHallHelpPanel
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 --]]

local basefunc = require "Game/Common/basefunc"
local fish_map_config =HotUpdateConfig("Game.CommonPrefab.Lua.fish3d_map_config")

Fishing3DHallHelpPanel = basefunc.class()
local C = Fishing3DHallHelpPanel
C.name = "Fishing3DHallHelpPanel"

function C.Create(game_id)
	return C.New(game_id)
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

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end
function C:is_show(cfg)
    local game_id = self.game_id
    if cfg.game_id then
        for k,v in ipairs(cfg.game_id) do
            if game_id == v then
                return true
            end
        end
    end
end
function C:InitFishAllMap(cfg)
    if not cfg then return end
    table.sort(cfg, function(a, b)
        return a.order < b.order
    end)
    self.bk_config_list = {}

    for i,v in ipairs(cfg) do
        if self:is_show(v) then
        	self.bk_config_list[#self.bk_config_list + 1] = v
        end
    end
end

function C:ctor(game_id)
	self.game_id = game_id
	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.top.gameObject).onClick = basefunc.handler(self, self.OnTopClick)
    self.ts_config_map = {}
    self.ts_config_map[2] = {"Fish3D058", "Fish3D036", "Fish3D030", "Fish3D075"}
    self.ts_config_map[3] = {"Fish3D077", "Fish3D054", "Fish3D029", "Fish3D034"}
    self.ts_config_map[4] = {"Fish3D059", "Fish3D056", "Fish3D031", "Fish3D050"}
    self.ts_config_map[5] = {"Fish3D084", "Fish3D028", "Fish3D051", "Fish3D052"}

	self:MyRefresh()
end

function C:MyRefresh()
	self:InitFishAllMap(fish_map_config.config)
	local fish_map = {}
	for k,v in ipairs(self.ts_config_map[self.game_id]) do
		fish_map[v] = k
	end
	local num = 0
	self.ts_config_cfg = {}
	for k,v in ipairs(self.bk_config_list) do
		if fish_map[v.prefab] then
			self.ts_config_cfg[fish_map[v.prefab]] = v
			num = num + 1
		end
	end
	if #self.ts_config_map[self.game_id] ~= num then
		for i=1, 4 do
			self["item"..i].gameObject:SetActive(false)
		end
	else
		for i=1, 4 do
			if i <= #self.ts_config_cfg then
				self["item"..i].gameObject:SetActive(true)
				local ui = {}
				LuaHelper.GeneratingVar(self["item"..i].transform, ui)
				local cfg = self.ts_config_cfg[i]
				ui.icon_img.sprite = GetTexture(cfg.icon)
				ui.name_txt.text = cfg.name
				ui.rate_txt.text = cfg.rate
				ui.desc_txt.text = cfg.tips
			else
				self["item"..i].gameObject:SetActive(false)
			end
		end
	end

	for k,v in ipairs(self.bk_config_list) do
		if not fish_map[v.prefab] then
			self:CreateItem(v)
		end
	end
end

function C:CreateItem(data)
	local obj = GameObject.Instantiate(self.Cell, self.Content)
	obj.gameObject:SetActive(true)
	local ui = {}
	LuaHelper.GeneratingVar(self.transform, ui)
	ui.icon_img.sprite = GetTexture(data.icon)
end

function C:OnTopClick()
	self:MyExit()
end