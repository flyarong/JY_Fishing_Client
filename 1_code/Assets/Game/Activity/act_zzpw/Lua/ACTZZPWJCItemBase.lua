-- 创建时间:2021-09-15
-- Panel:ACTZZPWJCItemBase
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

ACTZZPWJCItemBase = basefunc.class()
local C = ACTZZPWJCItemBase
C.name = "ACTZZPWJCItemBase"
local M = ACTZZPWManager

function C.Create(parent,index,config)
	return C.New(parent,index,config)
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

function C:ctor(parent,index,config)
	ExtPanel.ExtMsg(self)
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

local imgs = {
	"kscj_bg_hymm",
	"kscj_bg_yybf",
	"kscj_bg_cygg",
	"kscj_bg_tjhy",
}

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	-- dump(imgs[self.index], "<color=white>666666666666666666666<>/color")
	local dicData = M.GetDicData()
    self.bg_img.sprite = GetTexture(imgs[self.index])
    self.num_txt.text = math.floor((self.config / 100) * (M.GetCurJC() + dicData.take_pool))
end
