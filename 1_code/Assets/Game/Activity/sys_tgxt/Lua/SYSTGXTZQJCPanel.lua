-- 创建时间:2020-08-29
-- Panel:SYSTGXTZQJCPanel
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

SYSTGXTZQJCPanel = basefunc.class()
local C = SYSTGXTZQJCPanel
C.name = "SYSTGXTZQJCPanel"
local M = SYSTGXTManager
function C.Create()
	return C.New()
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

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	
	self.config = M.GetJCCfg()

	self:InitUI()
end

function C:InitUI()
	self.close_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:MyExit()
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	for i=1,#self.config do
		local pre = GameObject.Instantiate(self.item, self.Content.transform)
		pre.gameObject:SetActive(true)
		local bg1 = pre.transform:Find("bg1").gameObject
		local bg2 = pre.transform:Find("bg2").gameObject
		local title = pre.transform:Find("title").gameObject
		local content = pre.transform:Find("content").gameObject
		local title_txt = title.transform:GetComponent("Text")
		local content_txt = content.transform:GetComponent("Text")
		title_txt.text = self.config[i].title
		local str = self.config[i].content[1]
		for j=2,#self.config[i].content do
			str = str .. "\n" .. self.config[i].content[j]
		end
		content_txt.text = str
		local title_hight = title_txt.preferredHeight
		local content_hight = content_txt.preferredHeight
		local pre_rect = pre.gameObject:GetComponent("RectTransform")
		local bg1_rect = bg1.gameObject:GetComponent("RectTransform")
		local bg2_rect = bg2.gameObject:GetComponent("RectTransform")
		local title_rect = title.gameObject:GetComponent("RectTransform")
		local content_rect = content.gameObject:GetComponent("RectTransform")
		local h = 30 --空白(为了看上去更美观)
		bg1_rect.sizeDelta = Vector2.New(1250,title_hight + h)
		bg2_rect.sizeDelta = Vector2.New(1250,content_hight + h)
		title_rect.sizeDelta = Vector2.New(1250,title_hight + h)
		content_rect.sizeDelta = Vector2.New(1250,content_hight + h)
		bg2.transform.localPosition = Vector3.New(0, - (title_hight + h))
		content.transform.localPosition = Vector3.New(0, - (title_hight + h))
		pre_rect.sizeDelta = Vector2.New(1250,title_hight + content_hight + 2*h)
	end
end

