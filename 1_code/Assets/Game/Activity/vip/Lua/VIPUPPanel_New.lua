-- 创建时间:2021-08-02
-- Panel:VIPUPPanel_New
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

VIPUPPanel_New = basefunc.class()
local C = VIPUPPanel_New
C.name = "VIPUPPanel_New"
local M = VIPManager

local instance
function C.Create(data)
    if not instance then
        instance = C.New(data)
    end
	return instance
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
    self:CloseItem()
    if instance then
        instance = nil
    end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(data)
	ExtPanel.ExtMsg(self)
    self.data = data
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
    EventTriggerListener.Get(self.yes_btn.gameObject).onClick = basefunc.handler(self, self.OnYesClick)
    self.temp_config = M.GetVIPCfg().vip_up
    self.map = {}
    for k,v in pairs(self.temp_config) do
        self.map[v.vip_level] = v
    end
    self.config = self.map[self.data.cur]
    self.vip_img.sprite = GetTexture("djts_imgf_" .. self.data.cur)
    self.vip_img:SetNativeSize()
	self:MyRefresh()
end

function C:MyRefresh()
    self:CreateItem()
end

function C:OnYesClick()
    self:MyExit()
end

function C:CreateItem()
    self:CloseItem()
    for i=1,#self.config.name_txt do
        local pre = VIPUPItemBase.Create(self.Content.transform,self.config,i)
        self.pre_cell[#self.pre_cell + 1] = pre
    end
end

function C:CloseItem()
    if self.pre_cell then
        for k,v in pairs(self.pre_cell) do
            v:MyExit()
        end
    end
    self.pre_cell = {}
end