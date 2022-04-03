-- 创建时间:2020-07-09
-- Panel:SYSFLQCJPanel
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

SYSFLQCJPanel = basefunc.class()
local C = SYSFLQCJPanel
C.name = "SYSFLQCJPanel"

local instance
function C.Create(parm)
	if instance and IsEquals(instance.gameObject) then
		instance:MyExit()
	end
	instance = C.New(parm)
	return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["sys_flqcj_select_tag_msg"] = basefunc.handler(self, self.on_sys_flqcj_select_tag_msg)
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
    self.lister["kpshb_close_jl_msg"] = basefunc.handler(self, self.MyExit)

end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.pre_panel then
		if self.pre_panel.OnBackClick then
			self.pre_panel:OnBackClick()
		else
			self.pre_panel:MyExit()
		end
		self.pre_panel = nil
	end

	self:RemoveListener()
	destroy(self.gameObject)
	instance = nil
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parm)
	dump(parm,"<color=yellow>+++++++++++++/////+++++++</color>")
	self.parm = parm
	local parent = GameObject.Find("Canvas/LayerLv5").transform
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
	self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)
	self:MyRefresh()
	-- GuideLogic.CheckRunGuide("by3d")
	
	if self.parm and self.parm.type and self.parm.type == "vip" then
		for k,v in pairs(self.CellList) do
			--dump(v,"<color>-------------------------</color>")
			if v.config.gotoUI[2] == "vip_cj" then
				self:OnXZClick(v.index)
			end
		end
	end
end

function C:MyRefresh()
	self:CloseCell()

	local ll = SYSFLQCJManager.GetConfigList()
    self.list = {}
    for k,v in ipairs(ll) do
        self.list[#self.list + 1] = v
    end
    dump(self.list)

	for k,v in ipairs(self.list) do
		local pre = SYSFLQCJPrefab.Create(self.cell_node, v, self.OnXZClick, self, k)
		self.CellList[#self.CellList + 1] = pre
	end
	self.cur_xz_index = 1
	if self.parm and self.parm.type then
		for k,v in ipairs(self.list) do
			if v.id == self.parm.type then
				self.cur_xz_index = k
				break
			end
		end
	end
	self:RefreshSelect()
end
function C:CloseCell()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:OnDestroy()
		end
	end
	self.CellList = {}
end

function C:RefreshSelect()
	for k,v in ipairs(self.CellList) do
		if self.cur_xz_index == k then
			self.CellList[k]:SetSelect(true)
		else
			self.CellList[k]:SetSelect(false)
		end
	end

	if self.pre_panel then
		if self.pre_panel.OnBackClick then
			self.pre_panel:OnBackClick()
		else
			self.pre_panel:MyExit()
		end
		self.pre_panel = nil
	end


	local cfg = self.list[self.cur_xz_index]
	local parm = {}
	parm.gotoui = cfg.gotoUI[1]
	parm.goto_scene_parm = cfg.gotoUI[2]
	parm.parent = self.root
	self.pre_panel = GameManager.GotoUI(parm)
end

function C:OnXZClick(index)
	if self.cur_xz_index and self.cur_xz_index == index then
		return
	end

	self.cur_xz_index = index
	self:RefreshSelect()
end

function C:OnBackClick()
	self:MyExit()
end

function C:on_sys_flqcj_select_tag_msg(index)
	self:OnXZClick(index)
end
