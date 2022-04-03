-- 创建时间:2021-01-11
-- Panel:Act_Ty_QJD1Panel
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

Act_Ty_QJD1Panel = basefunc.class()
local C = Act_Ty_QJD1Panel
C.name = "Act_Ty_QJD1Panel"
local M = Act_Ty_QJD1Manager

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
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    self:CloseGiftItem()
    self:CloseKnockPanel()
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
	local parent = GameObject.Find("Canvas/LayerLv4").transform
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
    EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
    EventTriggerListener.Get(self.help_btn.gameObject).onClick = basefunc.handler(self, self.OnHelpClick)
    local sta_t = M.GetStart_t()
    local end_t = M.GetEnd_t()
    self.act_time_txt.text = "活动时间：".. sta_t .."-".. end_t
    self.act_explain_txt.text = M.GetBtmTxt()
	self:MyRefresh()
end

function C:MyRefresh()
    self:CreateGiftItem()
    self:CreatKnockPanel()
end

function C:OnBackClick()
    self:MyExit()
end

function C:OnHelpClick()
    local help_info = M.GetHelpInfo()
    local sta_t = M.GetStart_t()
    local end_t = M.GetEnd_t()
    help_info[1] = "1.活动时间：".. sta_t .."-".. end_t
    local str = help_info[1]
    for i = 2, #help_info do
        str = str .. "\n" .. help_info[i]
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:CreateGiftItem()
    self:CloseGiftItem()
    local cfg = M.GetGiftCfg()
    for i=1,#cfg do
        local pre = Act_Ty_QJD1GiftItemBase.Create(self.gift_node.transform,i,cfg[i])
        self.gift_pre_list[#self.gift_pre_list + 1] = pre
    end
end

function C:CloseGiftItem()
    if self.gift_pre_list then
        for k,v in pairs(self.gift_pre_list) do
            v:MyExit()
        end
    end
    self.gift_pre_list = {}
end

function C:CreatKnockPanel()
    self:CloseKnockPanel()
    self.knock_pre = Act_Ty_QJD1KnockPanel.Create(self.knock_node.transform)
end

function C:CloseKnockPanel()
    if self.knock_pre then
        self.knock_pre:MyExit()
        self.knock_pre = nil
    end
end