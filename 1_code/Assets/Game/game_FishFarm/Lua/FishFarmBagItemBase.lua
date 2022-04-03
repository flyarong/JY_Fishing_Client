-- 创建时间:2020-11-25
-- Panel:FishFarmBagItemBase
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

FishFarmBagItemBase = basefunc.class()
local C = FishFarmBagItemBase
C.name = "FishFarmBagItemBase"

function C.Create(panelSelf,parent,index,config,type)
	return C.New(panelSelf,parent,index,config,type)
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

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(panelSelf,parent,index,config,type)
	self.panelSelf = panelSelf
	self.index = index
	self.config = config
	self.type = type
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
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
	self.item_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnSeletClick()
	end)
	self.icon_img.sprite = GetTexture(self.config.config.icon)
	self.fragment.gameObject:SetActive(false)
	if self.type == "fragment" then
		self.num_txt.text = self.config.num .. "/" .. self.config.config.fragment_num
		self.fragment.gameObject:SetActive(true)
	else
		self.num_txt.text = "x"..self.config.num
	end

	self:MyRefresh()
end

function C:MyRefresh()

end

function C:OnSeletClick()
	self.panelSelf:Selet(self.index)
end

function C:RefreshUI(index)
	if index == self.index then
		self.xz_obj.gameObject:SetActive(true)
	else
		self.xz_obj.gameObject:SetActive(false)
	end
end

function C:GetInfo(index)
	if index == self.index then
		self.panelSelf:RefreshRightInfo(self.config)
	end
end