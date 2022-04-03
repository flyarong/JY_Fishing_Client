-- 创建时间:2021-02-08
-- Panel:SYSJBZK_JYFLEnterPrefab
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

SYSJBZK_JYFLEnterPrefab = basefunc.class()
local C = SYSJBZK_JYFLEnterPrefab
C.name = "SYSJBZK_JYFLEnterPrefab"

function C.Create(parent,parm)
	return C.New(parent,parm)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["jbzk_enter_refresh"] = basefunc.handler(self, self.MyRefresh)

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

function C:ctor(parent,parm)
	self.parm=parm
	ExtPanel.ExtMsg(self)
	local obj = newObject("SYSJBZK_JYFLEnterPrefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	tran.name="SYSJBZK_JYFLEnterPrefab"
	LuaHelper.GeneratingVar(self.transform, self)
	self.get_img=self.get_btn.transform:GetComponent("Image")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.BG_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)
	self.get_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnGetClick()
	end)
	self.title_img.sprite = GetTexture("jbzk_icon_1")
	self.title_img:SetNativeSize()
	self:MyRefresh()
end

function C:OnEnterClick()
	GameManager.GotoUI({gotoui=Sys_Act_JBZKManager.key, goto_scene_parm="panel"})
end
function C:OnGetClick()
	GameManager.GotoUI({gotoui=Sys_Act_JBZKManager.key, goto_scene_parm="panel"})	
end
function C:MyRefresh()
	if not IsEquals(self.gameObject) then
		return
	end
	if Sys_Act_JBZKManager.GetIsOverTimeState() then
		self.gameObject:SetActive(false)
		return
	end
	self.title_txt.text = "金币周卡"
	self.info_txt.text = "连续7天，每天登陆免费领金币"
	if Sys_Act_JBZKManager.GetHintState() == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
		self.gameObject:SetActive(true)
	    self.get_txt.text = "前 往"
	    self.get_img.sprite = GetTexture("ty_btn_huang1")
    	local platformType= Sys_Act_JBZKManager.GetPlatformInfo()
	    self.LFL.gameObject:SetActive(platformType.unlockType==0)
	    self.RED.gameObject:SetActive(platformType.unlockType~=0)


	else
	   self.gameObject:SetActive(true)
	    self.get_txt.text = "前 往"
	    self.get_img.sprite = GetTexture("ty_btn_huang1")
	    self.LFL.gameObject:SetActive(false)
	    self.RED.gameObject:SetActive(false)
	end
end
