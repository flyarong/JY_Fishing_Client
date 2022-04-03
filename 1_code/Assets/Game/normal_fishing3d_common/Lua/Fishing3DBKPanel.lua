-- 创建时间:2020-03-05
local basefunc = require "Game.Common.basefunc"

Fishing3DBKPanel = basefunc.class()
local C = Fishing3DBKPanel
C.name = "Fishing3DBKPanel"
require "Game.normal_fishing3d_common.Lua.Fishing3DBKItem"
require "Game.normal_fishing3d_common.Lua.Fishing3DBKTipsPanel"

local fish_map_config =HotUpdateConfig("Game.CommonPrefab.Lua.fish3d_map_config")

local tag_list = {
	[1] = {
		tag = 3,
		name = "活动鱼",
	},
	[2] = {
		tag = 2,
		name = "彩金鱼",
	},
	[3] = {
		tag = 1,
		name = "普通鱼",
	},
}
function C.Create(parm)
	return C.New(parm)
end
function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.onExitScene)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:ctor(parm)
    self.parm = parm
	ExtPanel.ExtMsg(self)

    local parent = GameObject.Find("Canvas/LayerLv4")
    local obj = newObject(C.name, parent.transform)
    self.transform = obj.transform
    self.gameObject = obj.gameObject
    LuaHelper.GeneratingVar(self.transform, self)
    self:MakeLister()
    self:AddMsgListener()

    self.back_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnBackClick()
    end)
    self.by3d_bk_fgx_prefab = GetPrefab("by3d_bk_fgx_prefab")
    self.by3d_bk_yu_group_prefab = GetPrefab("by3d_bk_yu_group_prefab")
    self.by3d_bk_yu_prefab = GetPrefab("by3d_bk_yu_prefab")
    self:InitUI()
end

function C:MyExit()
    self:RemoveListener()
end
function C:onExitScene()
    self:MyExit()
end

function C:InitUI()
    self:InitFishAllMap(fish_map_config.config)

    self:CloseCell()
    self.fgx_map = {}
    for k,v in ipairs(tag_list) do
    	local cfg = self.bk_config_map[v.tag]
    	if cfg and #cfg > 0 then
	    	local fgx_obj = GameObject.Instantiate(self.by3d_bk_fgx_prefab, self.content)
            self.fgx_map[v.tag] = fgx_obj
	    	local fgx_ui = {}
	    	LuaHelper.GeneratingVar(self.transform, fgx_ui)
	    	fgx_ui.name_txt.text = v.name

	    	local group_obj = GameObject.Instantiate(self.by3d_bk_yu_group_prefab, self.content)
	    	group_obj.gameObject.name = v.tag
	    	local pp_tran = group_obj.transform
	    	for kk, vv in ipairs(cfg) do
	    		Fishing3DBKItem.Create(pp_tran, vv, self.OnEnterClick, self)
	    	end
    	end
    end
    self.sv = self.transform:Find("@center/ScrollView"):GetComponent("ScrollRect")

    if self.parm then
        if self.parm.type and self.fgx_map[self.parm.type] then
            coroutine.start(function ( )
                Yield(0)
                Yield(0)--间隔一帧不得行
                if IsEquals(self.content) then
                    self.sv:StopMovement()
                    self.content.transform.localPosition = Vector3.New(0, -1 * self.fgx_map[self.parm.type].transform.localPosition.y, 0)        
                end
            end)
        end
    end
end
function C:CloseCell()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:OnDestroy()
		end
	end
	self.CellList = {}
end
function C:is_show(cfg)
    if not FishingModel or not FishingModel.data or not FishingModel.data.game_id then
        return true
    end
    local game_id = FishingModel.data.game_id
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
    self.bk_config_map = {}

    for i,v in ipairs(cfg) do
        if self:is_show(v) then
        	self.bk_config_map[v.tag] = self.bk_config_map[v.tag] or {}
        	self.bk_config_map[v.tag][#self.bk_config_map[v.tag] + 1] = v
        end
    end
end

function C:OnBackClick()
    self:MyExit()
    destroy(self.gameObject)
end

function C:OnEnterClick(cfg)
	if cfg then
		Fishing3DBKTipsPanel.Create(cfg)
	end
end
