local basefunc = require "Game/Common/basefunc"

VipShowTaskPanel2 = basefunc.class()
local C = VipShowTaskPanel2
C.name = "VipShowTaskPanel2"
local btn_image = "viptq_btn_8"
local btn_mask = "viptq_btn_9"
local Button_DataS = {
	{name = "VIP特权",goto_ui = "viptq",},
	{name = "至尊礼包",goto_ui = "vipzzlb",CheakFunc = "CheakViP_ZZLB_CanShow"},
	{name = "VIP富豪福利",goto_ui = "vipfhfl",CheakFunc = "CheakFHFL_CanShow"},
	-- [2] = {name = "VIP礼包",goto_ui = "viplb"},
	{name = "VIP每周福利",goto_ui = "vipmzfl"},
	-- [4] = {name = "VIP4回馈赛",goto_ui = "vipmxb"},
	{name = "VIP赢金挑战",goto_ui = "vipyjtz",CheakFunc = "CheakViP_YJTZ_CanShow"},
	-- [6] = {name = "千元赛挑战",goto_ui = "vipqys"},
	{name = "VIP钜惠礼包",goto_ui = "vipjhlb",CheakFunc = "CheakJHLB_CanShow"},
	{name = "VIP4回馈赛",goto_ui = "vip4hks"},
}

local Panel_DataS = {
	{name = "VipShowTQPanel",goto_ui = "viptq"},
	{name = "VipShowZZLBPanel",goto_ui = "vipzzlb",},
	{name = "VipShowLBPanel",goto_ui = "viplb"},
	{name = "VipShowMZFLPanel",goto_ui = "vipmzfl"},
	{name = "VipShowMXBPanel",goto_ui = "vipmxb"},
	{name = "VipShowYJTZPanel",goto_ui = "vipyjtz"},
	{name = "VipShowQYSPanel",goto_ui = "vipqys"},
	{name = "VipShowJHLBPanel",goto_ui = "vipjhlb"},
	{name = "VipShowFHFLPanel",goto_ui = "vipfhfl"},
	{name = "VipShowVIP4HKSPanel",goto_ui = "vip4hks"},
}
local Buttons_UI
local Panels
function C.Create(parent,cfg)
	DSM.PushAct({panel = C.name})
	return C.New(parent,cfg)
end

function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["VIP_CloseTHENOpen"] = basefunc.handler(self,self.on_VIP_CloseTHENOpen)
	self.lister["TRY_VIP_SHOW_TASK_COLSE"] = basefunc.handler(self,self.TRY_VIP_SHOW_TASK_COLSE)
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
	self.lister["model_vip_task_change_msg"] = basefunc.handler(self,self.Refresh_Button_Red)
	self.lister["player_hb_limit_over_msg"] = basefunc.handler(self,self.on_player_hb_limit_over_msg)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:TRY_VIP_SHOW_TASK_COLSE()
	self:MyExit()
end

function C:MyExit()
	self:RemoveListener()
	self:DestroyAllPanel()
	DSM.PopAct()
	destroy(self.gameObject)
end

function C:ctor(parent,cfg)
	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	Buttons_UI = {}
	Panels = {}

	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key= "cpl_cjj", is_on_hint = true}, "CheckCondition")
	if a and b then	
		Button_DataS = {
			{name = "VIP特权",goto_ui = "viptq",},
			{name = "VIP富豪福利",goto_ui = "vipfhfl",CheakFunc = "CheakFHFL_CanShow"},
			{name = "VIP每周福利",goto_ui = "vipmzfl"},
			{name = "VIP钜惠礼包",goto_ui = "vipjhlb",CheakFunc = "CheakJHLB_CanShow"},
			{name = "VIP赢金挑战",goto_ui = "vipyjtz",CheakFunc = "CheakViP_YJTZ_CanShow"},
		}
	end
	if MainModel.IsLowPlayer() then
		Button_DataS = {
			{name = "VIP富豪福利",goto_ui = "vipfhfl",CheakFunc = "CheakFHFL_CanShow"},
		}
	end

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:SetDefaultButton(cfg)
	self:Refresh_Button_Red()
end

function C:InitUI()
	Buttons_UI = self:InitAllButton(Button_DataS)
	self.close_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()  
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	
end

function C:OnButtonClick(Button_Data)
	self:SetAllButtonMask()
	self:HideAllPanel()
	self:SetButtonMaskAcive(Buttons_UI[Button_Data.name],true)
	self:Goto_UI(Button_Data.goto_ui)
end

function C:Goto_UI(goto_ui)
	local panelName = self:GetPanelByGoToUI(goto_ui)
	if panelName then
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name) 
		if Panels[goto_ui] then
			if IsEquals(Panels[goto_ui].gameObject) then 
				if Panels[goto_ui].OnShow then
					Panels[goto_ui]:OnShow()
				else
					Panels[goto_ui].gameObject:SetActive(true)
				end
			else
				Panels[goto_ui] = nil
				self:Goto_UI(goto_ui)
			end 
		else
			if _G[panelName] then
				if _G[panelName].Create then 
					Panels[goto_ui] = _G[panelName].Create(self.panelContent)
				else
					print("该脚本没有实现Create")
				end 
			else
				print("该脚本没有载入")
			end 
		end 
	else
		print("没有这个goto_ui 或者是没得这个goto_ui对应的panel，总之检查配置")
	end 
end

function C:HideAllPanel()
	for k,v in pairs(Panels) do
		if IsEquals(v.gameObject) then
			if v.OnHide then
				v:OnHide()
			else
				v.gameObject:SetActive(false)
			end
		else
			v = nil
		end 
	end 
end

function C:DestroyAllPanel()
	for k , v in pairs(Panels) do 
		if v.OnDestroy then 
			v:OnDestroy()
		end 
	end
end

function C:SetAllButtonMask()
	for k , v in pairs(Buttons_UI) do
		if IsEquals(v) then 
			self:SetButtonMaskAcive(v,false)
		end 
	end
end

function C:InitAllButton(Button_DataS)
	local buttons_ui = {}
	for i = 1,#Button_DataS do
		local is_qx = true
		if Button_DataS[i].CheakFunc then
			is_qx = C[Button_DataS[i].CheakFunc]()
		end
		if is_qx then
			local b = GameObject.Instantiate(self.buttonItem_btn,self.buttonContent)
			b.gameObject:SetActive(true)
			local temp_ui = {}
			LuaHelper.GeneratingVar(b.transform,temp_ui)
			temp_ui.buttonName_txt.text = Button_DataS[i].name
			temp_ui.buttonMaskName_txt.text =  Button_DataS[i].name

			temp_ui.buttonName_txt.gameObject:GetComponent("Text").color = COLOR_VIPHuiBS_Color
			temp_ui.buttonName_txt.gameObject:GetComponent("Shadow").effectColor = COLOR_VIPLanHS_Outline
			temp_ui.buttonMaskName_txt.gameObject:GetComponent("Text").color = COLOR_VIPDanLS_Color
			temp_ui.buttonMaskName_txt.gameObject:GetComponent("Shadow").effectColor = COLOR_LanS1_Outline

			b.onClick:AddListener(
				function ()
					self:OnButtonClick(Button_DataS[i])
					self:Refresh_Button_Red_ClickPage(Button_DataS[i].goto_ui)
					self:Refresh_Button_Red()
				end
			)
			buttons_ui[Button_DataS[i].name] = b
		end
	end
	return 	buttons_ui
end

function C:SetButtonMaskAcive(button_ui,active)
	local temp_ui = {}
	LuaHelper.GeneratingVar(button_ui.transform,temp_ui)
	temp_ui.buttonItemMask.gameObject:SetActive(active)
	temp_ui.buttonItemBG.gameObject:SetActive(not active)
end

function C:OnDestroy()
	self:MyExit()
end

function C:GetPanelByGoToUI(gotoui)
	for k ,v in pairs(Panel_DataS)	do
		if v.goto_ui == gotoui then 
			return v.name
		end 
	end 
end

function C:GetButtonDataByGotoUI(gotoui)
	for k,v in pairs(Button_DataS) do  
		if 	v.goto_ui == gotoui then 
			return v
		end 
	end
	print("无此分页，再次确认:::"..gotoui) 
end

function C:GetButtonDataByName(button_name)
	for k,v in pairs(Button_DataS) do  
		if 	v.name == button_name then 
			return v
		end 
	end
	print("无此分页，再次确认:::"..button_name) 
end

--设置默认打开的分页↓
--设置默认打开的分页↓
--设置默认打开的分页↓
--设置默认打开的分页↓
--设置默认打开的分页↓
function C:SetDefaultButton(cfg)
	local button_data
	if cfg and cfg.gotoui then 
		button_data = self:GetButtonDataByGotoUI(cfg.gotoui)
	end
	local index
	for i=1,#Button_DataS do
		if Button_DataS[i].CheakFunc then
			if C[Button_DataS[i].CheakFunc]() then
				index = i
				break
			end
		else
			index = i
			break
		end
	end
	if index then
		self:OnButtonClick(button_data or Button_DataS[index])
	end
end

--重新关闭页面再打开指定分页，相当于强制刷新
function C:on_VIP_CloseTHENOpen(gotoUI)
	self:MyExit()
	VipShowTaskPanel2.Create(nil,{gotoui = gotoUI})
end

function C:Refresh_Button_Red()
	local temp_ui = {}
	local temp_button_data 
	for k,v in pairs(Buttons_UI) do 
		LuaHelper.GeneratingVar(v.transform,temp_ui)
		temp_button_data = self:GetButtonDataByName(k)
		if temp_button_data then 
			temp_ui.red_img.gameObject:SetActive(VIPManager.CheakRed(temp_button_data.goto_ui))
		end 
	end
end
--4.21修改 某一类活动只对某一类玩家显示
function C:CheakViP_Upjmax_task()
	return VIPExtManager.IsCanUpLevel()
end

function C.CheakViP_YJTZ_CanShow()
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key= "vip_game_award", is_on_hint = true}, "CheckCondition")
	if a and b then
		return true
	end
	return false
end

function C.CheakViP_ZZLB_CanShow()
	return VIPManager.get_vip_level() >= 10
end

function C:CheakJHLB_CanShow()
	local count = 0
	local buyNum=0
	for k,v in pairs(VIPManager.GetJHLBData()) do
		if (MainModel.GetGiftShopStatusByID(v.gift_id) == 0) then
			if MainModel.UserInfo.vip_level >= v.index then
				buyNum=buyNum+1
			end
			count = count + 1
		end
	end
	-- dump(count,"锯惠礼包数量：  ")
	-- dump(buyNum,"已经购买的数量：  ")
	-- dump(#VIPManager.GetJHLBData(),"礼包数量------>")
	if buyNum>=#VIPManager.GetJHLBData() then
		return  false
	end
	if (count == 10) and (MainModel.UserInfo.vip_level >= 10) then
		return false
	else
		return true
	end
end

function C:CheakFHFL_CanShow()
	local data = GameTaskModel.GetTaskDataByID(VIPManager.GetFHFLTaskID())
	if not data then
		return false
	end
	local b = basefunc.decode_task_award_status(data.award_get_status)
	b = basefunc.decode_all_task_award_status(b, data, #VIPManager.GetFHFLData())
	for i=1,#b do
		if b[i] and b[i] ~= 2 then
			return true
		end
	end
	return false
end

--没点击到该分页就不关掉该分页按钮的红点(各个分页对红点的操作)
function C:Refresh_Button_Red_ClickPage(goto_ui)
	--dump(goto_ui,"<color=yellow>++++++++++///Refresh_Button_Red_ClickPage///++++++++</color>")
	if goto_ui then
	end
end

function C:on_player_hb_limit_over_msg()
	self:MyExit()
end