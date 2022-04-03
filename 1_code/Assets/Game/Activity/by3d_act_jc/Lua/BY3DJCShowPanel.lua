-- 创建时间:2020-06-16
-- Panel:BY3DJCShowPanel
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

BY3DJCShowPanel = basefunc.class()
local C = BY3DJCShowPanel
C.name = "BY3DJCShowPanel"
local M = BY3DJCManager

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
    self.lister["model_get_award_pool_num_msg"] = basefunc.handler(self, self.model_get_award_pool_num_msg)
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

function C:ctor(parm)
	local parent
	if parm and parm.parent then
		parent = parm.parent
	else
		parent = GameObject.Find("Canvas/LayerLv1").transform
	end
	local obj
	if parm and parm.cfg and (parm.cfg.parm[2] == "enter4" or parm.cfg.parm[2] == "enter5") then
		obj = newObject("BY3DJCShowPanel_lan", parent)
		if parm.cfg.parm[2] == "enter4" then
			self.game_id = 4
		else
			self.game_id = 5
		end
	else
		obj = newObject(C.name, parent)
	end
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	if parm and parm.cfg then
		local ys = parm.cfg.parm[2]
		if ys == "enter_hall" then
			self.transform.localPosition = Vector3.New(0, 294, 0)
		elseif ys ~= "enter_fish" then
			self.transform.localPosition = Vector3.New(10, 210, 0)
		end
	end
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:RunChange()
	if self.is_animing then
		return
	end
	if self.game_id then
		self.mb_num = M.GetAwardPoolByGameID(self.game_id)
	else
		self.mb_num = M.GetAwardPoolAll()
	end

	GameComAnimTool.stop_number_change_anim(self.anim_tab)
	if not self.cur_num or not self.mb_num or self.cur_num == self.mb_num then
		return
	end
	self.is_animing = true
	self.anim_tab = GameComAnimTool.play_number_change_anim(self.award_txt, self.cur_num, self.mb_num, 6, function ()
		self.cur_num = self.mb_num
		self.is_animing = false
		self:RunChange()
	end)
end

function C:model_get_award_pool_num_msg(data)
	if not self.cur_num then
		if self.game_id then
			self.cur_num = math.floor(M.GetAwardPoolByGameID(self.game_id) * 0.8)
		else
			self.cur_num = math.floor(M.GetAwardPoolAll() * 0.8)
		end
	end
	self:RunChange()
end
