-- 创建时间:2021-01-11
-- Panel:Act_Ty_QJD1HammerItemBase
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

Act_Ty_QJD1HammerItemBase = basefunc.class()
local C = Act_Ty_QJD1HammerItemBase
C.name = "Act_Ty_QJD1HammerItemBase"
local M = Act_Ty_QJD1Manager

function C.Create(parent,panelSelf,index,config)
	return C.New(parent,panelSelf,index,config)
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

function C:ctor(parent,panelSelf,index,config)
	self.panelSelf = panelSelf
	self.index = index
	self.config = config
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
	EventTriggerListener.Get(self.selet_btn.gameObject).onClick = basefunc.handler(self, self.OnSeletClick)
	self.icon_img.sprite = GetTexture(GameItemModel.GetItemToKey(self.config.item_key).image)
	self.num_txt.text = GameItemModel.GetItemCount(self.config.item_key)
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:OnSeletClick()
	self.panelSelf:Selet(self.index,"selet_hammer")
end

function C:SeletRefresh(index)
	self.on_selet.gameObject:SetActive(self.index == index)
	self.selet_btn.gameObject:SetActive(self.index ~= index)
end