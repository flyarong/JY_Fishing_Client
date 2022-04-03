-- 创建时间:2021-04-21
-- Panel:Fishing3DHallGuideSessionPanel
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

Fishing3DHallGuideSessionPanel = basefunc.class()
local C = Fishing3DHallGuideSessionPanel
C.name = "Fishing3DHallGuideSessionPanel"

function C.Create(bossFishId,bossInfo,gotogameid)
	return C.New(bossFishId,bossInfo,gotogameid)
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
	PlayerPrefs.SetString("hall_guide"..MainModel.UserInfo.user_id,os.time())
	Event.Brocast("close_finshing_guide_panel")
	self:MyExit()
end

function C:ctor(bossFishId,bossInfo,gotogameid)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.bossFishId=bossFishId
	self.bossInfo=bossInfo
	self.gotogameid=gotogameid
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end
local iconNameImageMap={"3dby_imgf_shksboss","3dby_imgf_bzeyboss","3dby_imgf_bzhmboss",}
function C:InitUI()
	EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.MyClose)
	EventTriggerListener.Get(self.close2_btn.gameObject).onClick = basefunc.handler(self, self.MyClose)
	EventTriggerListener.Get(self.goto_btn.gameObject).onClick = basefunc.handler(self, self.OnGoToBtnClick)
	dump(self.bossInfo.icon,"----->")
	GetTextureExtend(self.fishIcon_img,self.bossInfo.icon)
	if self.bossFishId==47 then
		GetTextureExtend(self.name_img,iconNameImageMap[1])
	elseif self.bossFishId==48 then
		GetTextureExtend(self.name_img,iconNameImageMap[2])
	elseif self.bossFishId==49 then
		GetTextureExtend(self.name_img,iconNameImageMap[3])
	end
	self.time_txt.text=self.bossInfo.rate
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:OnGoToBtnClick()
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="fishing3d_"..self.gotogameid, is_on_hint=true}, "CheckCondition")
	if not a or b then
		FishingModel.GotoFishingByID(self.gotogameid)
	else
		LittleTips.Create("该场次还未解锁！")
	end
	self:MyClose()
end

