-- 创建时间:2021-03-04
-- Panel:SYSLWGPStoreItemBase
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

SYSLWGPStoreItemBase = basefunc.class()
local C = SYSLWGPStoreItemBase
C.name = "SYSLWGPStoreItemBase"
local M = SYSLWGPManager

function C.Create(parent,config)
	return C.New(parent,config)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["refresh_Lwgp_store_item_num"]=basefunc.handler(self,self.RefreshItemNum)


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

function C:ctor(parent,config)
	ExtPanel.ExtMsg(self)
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
	EventTriggerListener.Get(self.chose_btn.gameObject).onClick = basefunc.handler(self, self.OnChoseClick)
	self:MyRefresh()
end

function C:MyRefresh()
	self.icon_img.sprite = GetTexture(self.config.goods_icon)
	self.name_txt.text=self.config.name
end

function C:RefreshItemNum()
	self.num=M.GetLwgpBetItemData(self.config.id).bet_num
	self.num_txt.text = "拥有: " .. self.num

end

function C:OnChoseClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	SYSLWGPBuyPanel.Create(self.config)
end