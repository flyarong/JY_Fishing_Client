-- 创建时间:2021-05-06
-- Panel:sys_txz_awarditem_1
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

sys_txz_awarditem_1 = basefunc.class()
local C = sys_txz_awarditem_1
C.name = "sys_txz_awarditem_1"
local M=SYS_TXZ_Manager
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
	
	self.lister["refresh_txzaward_listitem"] = basefunc.handler(self,self.on_refresh_txzaward_listitem)

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
	local parent =parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.config=config
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	GetTextureExtend(self.icon_img,self.config.icon)
	self.icon_txt.text=self.config.num
	self.icon_img.gameObject:GetComponent("Button").onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnTaskItemClcik()
	end)
	
	self.animtor=self.icon_img.transform:GetComponent("Animator")
	self:MyRefresh()
end

function C:MyRefresh()
	self.award_state=M.GetAwardItemGotState(self.config.level,0)

	self.lock_img.gameObject:SetActive(self.config.speci==1)
	self.bg_img.gameObject:SetActive(self.award_state==1)
	self.have_got_img.gameObject:SetActive(self.award_state==2)
	self.mask.gameObject:SetActive(self.award_state==3)
	self.animtor.enabled = self.award_state==1;
end

function C:OnTaskItemClcik()
	if self.award_state==1 then
		dump(self.config.level,"领取一个奖励")
		Network.SendRequest("get_task_award_new", {id = self.config.task_id, award_progress_lv = self.config.level},function (data)
			if data.result == 0 then
				Event.Brocast("sys_exit_ask_refresh_msg")
			end
		end)
	end
end

function C:on_refresh_txzaward_listitem()
	self:MyRefresh()
end
