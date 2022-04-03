-- 创建时间:2020-07-27
-- Panel:VipShowFHFLItemBase
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

VipShowFHFLItemBase = basefunc.class()
local C = VipShowFHFLItemBase
C.name = "VipShowFHFLItemBase"
local M = VIPManager
function C.Create(parent,config,panelSelf)
	return C.New(parent,config,panelSelf)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
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

function C:ctor(parent,config,panelSelf)
	self.config = config
	self.panelSelf = panelSelf
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.slider = self.slider.transform:GetComponent("Slider")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.get_btn.gameObject).onClick = basefunc.handler(self, self.on_GetClick)

	self.title1_txt.text = self.config.title
	for i=1,#self.config.award_img do
		self["award"..i].gameObject:SetActive(true)
		self["award"..i.."_img"].sprite = GetTexture(self.config.award_img[i])
		self["award"..i.."_txt"].text = self.config.award_txt[i]
	end
	self:MyRefresh()
end

function C:MyRefresh()
	local data = GameTaskModel.GetTaskDataByID(self.config.task_id)
	if not data then
		return
	end
	local b = basefunc.decode_task_award_status(data.award_get_status)
	--dump({data=data,b=b},"<color=yellow>+++++++++++//3333///++++++++++++</color>")
	b = basefunc.decode_all_task_award_status(b, data, #M.GetFHFLData())
	--dump({data=data,b=b},"<color=yellow>+++++++++++//444///++++++++++++</color>")
	if b[self.config.index] then
		if b[self.config.index] == 0 then
			self.lock_btn.gameObject:SetActive(true)
			self.get_btn.gameObject:SetActive(false)
			self.already.gameObject:SetActive(false)
		elseif b[self.config.index] == 1 then
			self.lock_btn.gameObject:SetActive(false)
			self.get_btn.gameObject:SetActive(true)
			self.already.gameObject:SetActive(false)
		elseif b[self.config.index] == 2 then
			self.lock_btn.gameObject:SetActive(false)
			self.get_btn.gameObject:SetActive(false)
			self.already.gameObject:SetActive(true)
		end
	end
	self.progress_txt.text = StringHelper.ToCash(data.now_total_process).."/"..StringHelper.ToCash(self.config.condition)
	if data.now_total_process > self.config.condition then
		self.slider.value = 1
	else
		self.slider.value = data.now_total_process/self.config.condition
	end
end

function C:on_GetClick()
	if M.get_vip_level() >= 2 then
		Network.SendRequest("get_task_award_new",{id = self.config.task_id,award_progress_lv = self.config.award_progress_lv})
	else
		LittleTips.Create("达到VIP2才能参与哦～")
	end
end

