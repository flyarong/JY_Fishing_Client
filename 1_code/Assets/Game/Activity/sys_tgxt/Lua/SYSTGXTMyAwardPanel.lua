-- 创建时间:2020-07-29
-- Panel:SYSTGXTMyAwardPanel
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

SYSTGXTMyAwardPanel = basefunc.class()
local C = SYSTGXTMyAwardPanel
C.name = "SYSTGXTMyAwardPanel"
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
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
	self.lister["query_my_son_main_info_response"] = basefunc.handler(self,self.on_query_my_son_main_info)
    self.lister["sys_tgxt_red_state_change_msg"] = basefunc.handler(self,self.sys_tgxt_red_state_change_msg) 
    self.lister["AssetChange"] = basefunc.handler(self,self.on_AssetChange) 
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:CloseItemPrefab()
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
	
	self.can_show_red = true
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.on_BackClick)
	EventTriggerListener.Get(self.binding_btn.gameObject).onClick = basefunc.handler(self, self.on_BindingClick)
	EventTriggerListener.Get(self.get_btn.gameObject).onClick = basefunc.handler(self, self.on_GetClick)
	EventTriggerListener.Get(self.award_data_btn.gameObject).onClick = basefunc.handler(self, self.on_AwardDataClick)

	self.page_index = 1
	self.sv = self.ScrollView:GetComponent("ScrollRect")
	EventTriggerListener.Get(self.sv.gameObject).onEndDrag = function()
	    local VNP = self.sv.verticalNormalizedPosition  
	    if VNP <= 0 then 
			Network.SendRequest("query_my_son_main_info",{page_index = self.page_index, sort_type=4})
	    end
	end

	self:MyRefresh()
	self:RefreshMoney()
end

function C:MyRefresh()
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "cpl_notcjj", is_on_hint = true}, "CheckCondition")
	if a and b then
		self.t_txt.text = "兑换3元"
	else
		self.t_txt.text = "兑换1次"
	end
	self:RefreshRed()
	self.spawn_cell_list = {}
	Network.SendRequest("query_my_son_main_info",{page_index = self.page_index, sort_type=4}, "")
end

function C:on_BackClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:MyExit()
end

function C:on_BindingClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	GameManager.GotoUI({gotoui = "sys_binding_zfb",goto_scene_parm = "panel"})
end

function C:on_GetClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    --检查支付宝
    MainModel.GetBindZFB(function(  )
        if table_is_null(MainModel.UserInfo.zfbData) or MainModel.UserInfo.zfbData.name == "" then
            LittleTips.Create("请先绑定支付宝")
            GameManager.GotoUI({gotoui = "sys_binding_zfb",goto_scene_parm = "panel"})
        else
            MainLogic.Withdraw(self:RefreshMoney())
        end
    end)
end

function C:RefreshMoney()
	self.my_award_txt.text = "<color=#1b62a0>我的收益: </color><color=#ea5d19><size=72>"..
				StringHelper.ToRedNum(MainModel.UserInfo.cash/100).."</size>元</color>"
end

function C:on_AwardDataClick()
	M.SetLocalData("red2", 1)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	SYSTGXTInComePanel.Create()
end

function C:on_query_my_son_main_info(_, data)
	dump(data, "HHHHHHHHHHHHHHHHHHHHHH")
	if data.result == 0 then
		if data.is_clear_old_data and data.is_clear_old_data == 1 then
			self.page_index = 1
			self:CloseItemPrefab()
		end
		if data.son_main_infos then
			self:CreateItemPrefab(data.son_main_infos)
			self.page_index = self.page_index + 1
		end
		if not data.son_main_infos or #data.son_main_infos <= 0 then
			LittleTips.Create("暂无新数据")
		end
	end
end
function C:CreateItemPrefab(data)
	local begin_index = (self.page_index - 1) * 20 + 1
	for k,v in ipairs(data) do
		local pre = SYSTGXTMyAwardItemBase.Create(self.Content.transform, v, begin_index)
		self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
		begin_index = begin_index + 1
	end
end

function C:CloseItemPrefab()
	if self.spawn_cell_list then
		for k,v in ipairs(self.spawn_cell_list) do
			v:MyExit()
		end
	end
	self.spawn_cell_list = {}
end

function C:RefreshRed()
	if M.GetLocalData("red2") == 0 then	
		self.red.gameObject:SetActive(true)				
	else
		self.red.gameObject:SetActive(false)	
	end
end

function C:sys_tgxt_red_state_change_msg()
	self:RefreshRed()
end

function C:on_AssetChange()
	self:RefreshMoney()
end