-- 创建时间:2020-10-27
-- Panel:XRQTLDayBtnItemPrefab
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

XRQTLDayBtnItemPrefab = basefunc.class()
local C = XRQTLDayBtnItemPrefab
C.name = "XRQTLDayBtnItemPrefab"
local M = XRQTLManager


local Chinese = {"一","二","三","四","五","六","七",}
function C.Create(parent, parentPanel, index)
	return C.New(parent,  parentPanel, index)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    --self.lister["XRQTL_DownCount_msg_new"] = basefunc.handler(self,self.MyRefresh)

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

function C:ctor(parent,  parentPanel, index)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject("XRQTLDayBtnItemPrefab_"..index, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.parentPanel = parentPanel
	self.index = index or 1

	
	self.day_number = M.GetDayIndex()
	self.day_number = self.day_number > 7 and 7 or self.day_number
	dump(self.day_number,"<color=yellow><size=15>++++++++++data++++++++++</size></color>")

	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	self.day_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self.parentPanel:CreateRightPrefab(self.index)
		self.parentPanel:RefreshSelet(self.index)

	end)
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()

	self:RefreshLock(self.day_number)
	self.parentPanel:RefreshSelet()
	self.parentPanel:CreateRightPrefab(self.index)
	self.day_txt.text = "第"..Chinese[self.index].."天"
end

function C:RefreshSelet(index)

	--self.click.gameObject:SetActive(index == self.index)
	self.day_btn.gameObject:SetActive(index ~= self.index)
end


function C:RefreshLock(number)
	if  IsEquals(self.gameObject) then
		if number >= self.index then
			self.lock.gameObject:SetActive(false)
			self.lock_1.gameObject:SetActive(false)
			self.day_txt.color = Color.New(1,1,1,1)
			self.day_txt.gameObject:GetComponent("Outline").effectColor = Color.New(15/255,79/255,170/255,1)
		end
	end
end
