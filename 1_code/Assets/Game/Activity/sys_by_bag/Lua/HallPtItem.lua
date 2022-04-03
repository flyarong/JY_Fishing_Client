-- 创建时间:2020-06-05
-- Panel:HallPtItem
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

HallPtItem = basefunc.class()
local C = HallPtItem
C.name = "HallPtItem"

function C.Create(panelSelf, data, parent_transform, call, index)
	return C.New(panelSelf, data, parent_transform, call, index)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(data, parent_transform)
	self.data = data
	local obj = newObject(C.name, parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.pt_btn.onClick:AddListener(function ()	
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:on_Shoot_Up()
	end)
	self.pt_img.sprite = GetTexture(self.data.image)
	self.pt_img:SetNativeSize()
	if self.data.is_get == 1 then
		self.pt_img.color = Color.New(1, 1, 1, 1)
	else
		self.pt_img.color = Color.New(0.65, 0.65, 0.65, 1)
	end
	self:MyRefresh()
end

function C:MyRefresh()
end


function C:on_Shoot_Up()
	Event.Brocast("sys_by_choose_change_msg",self.data)
end