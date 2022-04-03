-- 创建时间:2020-11-12
-- Panel:SYSFishFarmSimplicityOneKeySaleItemBase
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

SYSFishFarmSimplicityOneKeySaleItemBase = basefunc.class()
local C = SYSFishFarmSimplicityOneKeySaleItemBase
C.name = "SYSFishFarmSimplicityOneKeySaleItemBase"
local M = SYSFishFarmSimplicityManager
function C.Create(panelSelf,parent,index,data)
	return C.New(panelSelf,parent,index,data)
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

function C:ctor(panelSelf,parent,index,data)
	self.panelSelf = panelSelf
	self.index = index
	self.data = data
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
	self:MyRefresh()
end

function C:MyRefresh()
	local cfg = FishFarmManager.GetPLConfig(self.index)
	--self.fish_img.sprite = GetTexture("")
	self.fish_txt.text = cfg.name
	self.num_txt.text = self.data.count
end

function C:OnSeletClick()
	if self.data.count > 0 then
		self.panelSelf:RefreshJingBi(self.index,not self.gou.gameObject.activeSelf)
		self.gou.gameObject:SetActive(not self.gou.gameObject.activeSelf)
	else
		LittleTips.Create("您没有此类型的鱼苗")
	end
end