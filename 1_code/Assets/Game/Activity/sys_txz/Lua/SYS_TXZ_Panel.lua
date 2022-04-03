-- 创建时间:2021-05-06
-- Panel:SYS_TXZ_Panel
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

SYS_TXZ_Panel = basefunc.class()
local C = SYS_TXZ_Panel
C.name = "SYS_TXZ_Panel"
local M=SYS_TXZ_Manager
function C.Create(parent,backcall)
	return C.New(parent,backcall)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["refresh_txztask_red"] = basefunc.handler(self,self.RefreshTaskRedState)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
	

end

function C:MyExit()
	if self.backcall then
		self.backcall()
	end
	self:DeletNodePre()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent,backcall)
	ExtPanel.ExtMsg(self)
	self.backcall = backcall
	local parent =parent or GameObject.Find("Canvas/LayerLv4").transform
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
	M.InitTxzTaskInfo()
	EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.OnCloseBtnClick)
	EventTriggerListener.Get(self.txz_btn.gameObject).onClick = basefunc.handler(self, self.OnTXZBtnClick)
	EventTriggerListener.Get(self.task_btn.gameObject).onClick = basefunc.handler(self, self.OnTaskBtnClick)
	
	self:OnTXZBtnClick()
	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshTaskRedState()
end
function C:OnTXZBtnClick()
	if self.chooseIndex==1 then
		return
	end
	if self.node_pre_2 then
		self.node_pre_2.gameObject:SetActive(false)
	end
	self.chooseIndex=1
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self.txz_normal_img.gameObject:SetActive(false)
	self.task_normal_img.gameObject:SetActive(true)
	self.txz_choose_img.gameObject:SetActive(true)
	self.task_choose_img.gameObject:SetActive(false)
	GetTextureExtend(self.txz_btn:GetComponent("Image"),"hwtxz_btn_h")
	GetTextureExtend(self.task_btn:GetComponent("Image"),"hwtxz_btn_lan")
	GetTextureExtend(self.toptask_img,"hwtxz_icon_txz")
	self.toptask_img:SetNativeSize()
	-- self:DeletNodePre()
	if self.node_pre_1 then
		self.node_pre_1:MyRefresh()
		self.node_pre_1.gameObject:SetActive(true)
	else
		self.node_pre_1=SYS_TXZ_NodePanel.Create(self.center_node.transform)
	end
end

function C:OnTaskBtnClick()
	if self.chooseIndex==2 then
		return
	end
	if self.node_pre_1 then
		self.node_pre_1.gameObject:SetActive(false)
	end
	self.chooseIndex=2
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self.txz_normal_img.gameObject:SetActive(true)
	self.task_normal_img.gameObject:SetActive(false)
	self.txz_choose_img.gameObject:SetActive(false)
	self.task_choose_img.gameObject:SetActive(true)
	
	GetTextureExtend(self.txz_btn:GetComponent("Image"),"hwtxz_btn_lan")
	GetTextureExtend(self.task_btn:GetComponent("Image"),"hwtxz_btn_h")
	GetTextureExtend(self.toptask_img,"rw_icon_rw")
	self.toptask_img:SetNativeSize()

	-- self:DeletNodePre()
	if self.node_pre_2 then
		self.node_pre_2:MyRefresh()
		self.node_pre_2.gameObject:SetActive(true)
	else
		self.node_pre_2=SYS_TXZ_TaskPanel.Create(self.center_node.transform)
	end
end
function C:RefreshTaskRedState()
	local _state=M.GetTaskRedState()
	-- dump(_state,"<color=red>通行证任务红点：  </color>")
	self.task_red_img.gameObject:SetActive(_state)
end
function C:OnCloseBtnClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:MyExit()
end

function C:DeletNodePre()
	if self.node_pre_1 then
		self.node_pre_1:MyExit()
		self.node_pre_1 = nil
	end
	if self.node_pre_2 then
		self.node_pre_2:MyExit()
		self.node_pre_2 = nil
	end
end

