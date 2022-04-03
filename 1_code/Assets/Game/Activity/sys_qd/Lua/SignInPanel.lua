-- 创建时间:2019-09-18
-- Panel:New Lua
--[[ *      ┌─┐       ┌─┐
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

SignInPanel = basefunc.class()
local C = SignInPanel
C.name = "SignInPanel"

SignInPanel.IsLj = false
function C.Create()
	DSM.PushAct({panel = C.name})
    return C.New()
end

function C:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["query_sign_in_data_response"] = basefunc.handler(self, self.OnGetInfo)
	self.lister["model_vip_upgrade_change_msg"]=basefunc.handler(self,self.OnRefreshVipInfo)
	self.lister["get_sign_in_award_response"] = basefunc.handler(self, self.get_sign_in_award)
end

function C:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	DSM.PopAct()
	self:DestroyVipPre()
	self:RemoveListener()
    destroy(self.gameObject)
end

function C:ctor()

	ExtPanel.ExtMsg(self)

    local parent = GameObject.Find("Canvas/LayerLv4").transform
    if self:CheckIsCJJ() then
    	C.name = "SignInPanel_old"
    end
    local obj = newObject(C.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    self.MaxDay = self:get_month_day_count(tonumber(os.date("%Y", os.time())), tonumber(os.date("%m", os.time())))
    self:MakeLister()
    self:AddMsgListener()
    self.config = SYSQDManager.GetConfig()
    self:InitUI()
    self:OnClickButton()
    Network.SendRequest("query_sign_in_data")
end

function C:InitUI()
    self.VIPButton = self.transform:Find("VIPButton"):GetComponent("Button")
    self.CloseButton = self.transform:Find("CloseButton"):GetComponent("Button")
    self.SunDayItem = self.transform:Find("SunDay")
    self.WeekItem = self.transform:Find("WeekItem")
    self.MonthItem = self.transform:Find("MonthItem")
    self.WeekContent = self.transform:Find("WeekContent")
    self.MonthContent = self.transform:Find("MonthContent")
	self.InfoText = self.transform:Find("InfoText"):GetComponent("Text")
	self.TopText = self.transform:Find("TopText"):GetComponent("Text")
    self.GetAwardPanel = self.transform:Find("Canvas/GetAwardPanel")
	self.VipUpPanel = self.transform:Find("Canvas/VipUpPanel")
	self.VipButtonImage=self.transform:Find("VIPButton"):GetComponent("Image")
    self.WeekChilds = {}
    for i = 1, #self.config.week - 1 do
        local b = GameObject.Instantiate(self.WeekItem, self.WeekContent)
        b.gameObject:SetActive(true)
        b.gameObject.transform:Find("Day"):GetComponent("Text").text = "第" .. i .. "天"
        b.gameObject.transform:Find("AwardText"):GetComponent("Text").text = self.config.week[i].info
        b.gameObject.transform:Find("AwardImage"):GetComponent("Image").sprite = GetTexture(self.config.week[i].img)
        if self.config.week[i].vip_desc then
            b.gameObject.transform:Find("Tag").gameObject:SetActive(true)
            local TagText = b.gameObject.transform:Find("Tag/TagText"):GetComponent("Text")
            TagText.text = self.config.week[i].vip_desc
        else
            b.gameObject.transform:Find("Tag").gameObject:SetActive(false)
        end
        self.WeekChilds[i] = b
    end

    self.SunDayItem.gameObject.transform:Find("AwardImage"):GetComponent("Image").sprite = GetTexture(self.config.week[#self.config.week].img)
    self.SunDayItem.gameObject.transform:Find("AwardText"):GetComponent("Text").text = self.config.week[#self.config.week].info
    if self.config.week[#self.config.week].vip_desc then
	    self.SunDayItem.transform:Find("Tag").gameObject:SetActive(true)
	    self.SunDayItem.transform:Find("Tag/TagText"):GetComponent("Text").text = self.config.week[#self.config.week].vip_desc
    end
    self.WeekChilds[7] = self.SunDayItem

	for i = 1, #self.WeekChilds do
		self.WeekChilds[i].gameObject.transform:GetComponent("Button").onClick:AddListener(
			function ()
				self:GetWeekAward(self.config.week[i],i)
			end
		)
	end

    self.MonthChilds = {}
    for i = 1, #self.config.month do
        local b = GameObject.Instantiate(self.MonthItem, self.MonthContent)
        b.gameObject:SetActive(true)
		if self.config.month[i].day == "M" or self.config.month[i].day == self.MaxDay then 
			self.config.month[i].day = self.MaxDay
		end
        b.gameObject.transform:Find("Tag/Text"):GetComponent("Text").text = self.config.month[i].day .. "天"
        b.gameObject.transform:Find("AwardText"):GetComponent("Text").text = self.config.month[i].info
        b.gameObject.transform:Find("AwardImage"):GetComponent("Image").sprite = GetTexture(self.config.month[i].img)
		self.MonthChilds[i] = b
		b.gameObject.transform:GetComponent("Button").onClick:AddListener(
			function ()
				self:GetMonthAward(i)
			end
		)
    end
	self.MonthChilds[#self.MonthChilds].gameObject.transform:Find("Progress").gameObject:SetActive(false)

	if GLC.hide_qd_vip then
		self.VIPButton.gameObject:SetActive(false)
		self.InfoText.gameObject:SetActive(false)
	end

	
	self:RefreshVIP()
end

--注册按钮事件
function C:OnClickButton()
    self.VIPButton.onClick:AddListener(
		function()
			if MainModel.UserInfo.ui_config_id == 1 and MainModel.UserInfo.vip_level < 1 then
				GameManager.GotoUI({gotoui="hall_activity", goto_scene_parm="panel"})
			else
				PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
			end
		end
    )
    self.CloseButton.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	self.vip_no_btn.onClick:AddListener(
		function ()
			self.VipUpPanel.gameObject:SetActive(false)
		end
	)
	self.vip_close_btn.onClick:AddListener(
		function ()
			self.VipUpPanel.gameObject:SetActive(false)
		end
	)
	self.vip_yes_btn.onClick:AddListener(
		function ()
			self.VipUpPanel.gameObject:SetActive(false)
			PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
		end
	)
	self.getaward_close_btn.onClick:AddListener(
		function ()
			self.GetAwardPanel.gameObject:SetActive(false)
		end
	)
	if not self:CheckIsCJJ() then
		self.up_btn.onClick:AddListener(
			function ()
				self:OnUpClick()
			end
		)
		self.vip_enter_btn.onClick:AddListener(
			function ()
				self:OnVIPEnterClick()
			end
		)
	end
end

function C:get_month_day_count(year, month)
    local t
    if ((year % 4 == 0) and (year % 100 ~= 0)) or (year % 400 == 0) then
        t = { 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    else
        t = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    end
    return t[month]
end

function C:OnGetInfo(_, data)
	dump(data, "<color=red>每日签到信息</color>")
	if not IsEquals(self.gameObject) then return end  
	self:OnRefreshVipInfo()
    if data and data.result == 0 then
        for i = 1, #self.WeekChilds do
            self.WeekChilds[i].gameObject:GetComponent("Button").enabled = false
            self.WeekChilds[i].gameObject.transform:Find("TX").gameObject:SetActive(false)
            self.WeekChilds[i].gameObject.transform:Find("BG").transform:GetComponent("Image").sprite = GetTexture("mrqd_bg_wxzdb")
        end
        for i = 1, data.sign_in_day - 1 do
            self.WeekChilds[i].gameObject.transform:Find("Mask").gameObject:SetActive(true)
		end
		local toptext = data.sign_in_day - 1
        if data.sign_in_award == 1 then
            self.WeekChilds[data.sign_in_day].gameObject.transform:Find("TX").gameObject:SetActive(true)
            self.WeekChilds[data.sign_in_day].gameObject:GetComponent("Button").enabled = true
            self.WeekChilds[data.sign_in_day].gameObject.transform:Find("BG").transform:GetComponent("Image").sprite = GetTexture("mrqd_bg_xzdb")
			SignInPanel.IsLj = true
		else
			self.WeekChilds[data.sign_in_day].gameObject.transform:Find("Mask").gameObject:SetActive(true)
			toptext = toptext + 1
		end
		self.TopText.text = toptext

		self.InfoText.text = "VIP1及以上等级专属累计签到奖励（本月累计签到" .. data.acc_day  .. "天）"
		for i = 1, #self.config.month do
			self.MonthChilds[i].gameObject:GetComponent("Button").enabled = false
			if self.config.month[i].day == "M" then  self.config.month[i].day = self.MaxDay end
            if self.config.month[i].day <= data.acc_day  then
				self.MonthChilds[i].gameObject.transform:Find("Mask").gameObject:SetActive(true)
				self.MonthChilds[i].gameObject.transform:Find("TX").gameObject:SetActive(false)
				if i + 1 <= #self.config.month then 
					self.MonthChilds[i].gameObject.transform:Find("Progress/mask").sizeDelta={
						x = Mathf.Clamp((data.acc_day - self.config.month[i].day) / (self.config.month[i+1].day - self.config.month[i].day), 0, 1) * self.MonthChilds[i].gameObject.transform:Find("Progress/bg").sizeDelta.x,
						y = 20
					}					
				end
				
            end
        end
        if not table_is_null(data.acc_award) then
            SignInPanel.IsLj = true
            for i = 1, #data.acc_award do
				self.MonthChilds[data.acc_award[i]].gameObject.transform:Find("TX").gameObject:SetActive(true)
				self.MonthChilds[data.acc_award[i]].gameObject.transform:Find("Mask").gameObject:SetActive(false)
                self.MonthChilds[data.acc_award[i]].gameObject:GetComponent("Button").enabled = true
                self.MonthChilds[data.acc_award[i]].gameObject.transform:Find("BG2").gameObject:SetActive(true)
            end
        end
	end
	Event.Brocast("JYFLInfoChange")

	if data and data.result == 0 then
		Event.Brocast("trace_task_msg", {task_id = 10000, task_name = "signin", status = "1"})
	else
		Event.Brocast("trace_task_msg", {task_id = 10000, task_name = "signin", status = "2"})
	end
end

function C:GetWeekAward(config, _index)
	if VIPManager.get_vip_data() == nil then return end 
	if config.vip then
		if config.vip > VIPManager.get_vip_data().vip_level then
			self.GetAwardPanel.transform:Find("Award1"):GetComponent("Image").sprite=GetTexture(config.img)
			self.GetAwardPanel.transform:Find("Award1/Text"):GetComponent("Text").text=config.info
			self.GetAwardPanel.transform:Find("Award2"):GetComponent("Image").sprite=GetTexture(config.img)
			self.GetAwardPanel.transform:Find("Award2/Text"):GetComponent("Text").text=config.vipinfo
			self.award_yes_txt.text = "VIP"..config.vip.."领取"
			self.award_yes_btn.onClick:RemoveAllListeners()
			self.award_no_btn.onClick:RemoveAllListeners()
			self.award_yes_btn.onClick:AddListener(
				function ()
					if MainModel.UserInfo.ui_config_id == 1 and MainModel.UserInfo.vip_level < 1 then
						GameManager.GotoUI({gotoui="hall_activity", goto_scene_parm="panel"})
					elseif config.vip > VIPManager.get_vip_data().vip_level then
						PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
					else
						Network.SendRequest("get_sign_in_award", { type = "sign_in", index = _index }, "")
					end 
					self.GetAwardPanel.gameObject:SetActive(false)
				end
			)
			self.award_no_btn.onClick:AddListener(
				function ()
					Network.SendRequest("get_sign_in_award", { type = "sign_in", index = _index }, "")
					self.GetAwardPanel.gameObject:SetActive(false)	
				end
			)
			self.GetAwardPanel.gameObject:SetActive(true)
		else
			Network.SendRequest("get_sign_in_award", { type = "sign_in", index = _index }, "")	
			self.GetAwardPanel.gameObject:SetActive(false)		
		end		
    else
		Network.SendRequest("get_sign_in_award", { type = "sign_in", index = _index }, "")
		self.GetAwardPanel.gameObject:SetActive(false)
    end
end

function C:GetMonthAward(_index)
	if VIPManager.get_vip_data() and VIPManager.get_vip_data().vip_level>=1 then 
		Network.SendRequest("get_sign_in_award",{type = "acc", index = _index }, "")
	else
		self.VipUpPanel.gameObject:SetActive(true)
	end
end

function C:OnRefreshVipInfo()
	if VIPManager.get_vip_data() and VIPManager.get_vip_data().vip_level >= 1 then
		self.VipButtonImage.sprite = GetTexture("ty_btn_huang1")
	end 
	self:RefreshVIP()
end

function C:get_sign_in_award(_, data)
	if data.result == 0 then
		Network.SendRequest("query_sign_in_data")
	end
end


function C:OnUpClick()
	if MainModel.UserInfo.vip_level < 4 then
		local last_level = MainModel.UserInfo.vip_level
		GameManager.GotoUI({gotoui="hall_activity", goto_scene_parm="panel" , backcall = function ()
			if last_level == 0 and MainModel.GetGiftDataByID(10337).status == 0 then
			elseif last_level == 1 and MainModel.GetGiftDataByID(10254).status == 0 then
			elseif last_level == 2 and MainModel.GetGiftDataByID(10255).status == 0 then
			elseif last_level == 3 and MainModel.GetGiftDataByID(10256).status == 0 then
			else
				PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
			end
		end})
	--[[elseif VIPManager.get_vip_level() < 10 then
		PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
	else
		local gotoparm = {gotoui = "game_MiniGame"}
		GameManager.GuideExitScene(gotoparm)--]]
	else
		PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
	end
end

function C:RefreshVIP()
	if self:CheckIsCJJ() then return end
	self:DestroyVipPre()
	local cur_vip = VIPManager.get_vip_level()
	self.vip_txt.text = cur_vip
	local vip_cfg = VIPManager.GetVIPCfg()
	local data = VIPManager.get_vip_data()
	local str2 =""
	if data.vip_level < 10 then
		str2 = "还有" .. StringHelper.ToCash(vip_cfg.dangci[cur_vip + 1].total - data.now_charge_sum / 100) .. "元升级至<color=#ffae85>VIP" .. (cur_vip + 1) .. "</color>,\n升级后"
	elseif data.vip_level == 10 then
		str2 = "还有" .. StringHelper.ToCash(vip_cfg.dangci[cur_vip + 1].cfz - data.treasure_value) .. "财富值升级至VIP11，升级后"
	elseif data.vip_level == 11 then
		str2 = "还有" .. StringHelper.ToCash(vip_cfg.dangci[cur_vip + 1].cfz - data.treasure_value) .. "财富值升级至VIP12，升级后"
	elseif data.vip_level == VIPManager.GetUserMaxVipLevel() then
		str2 = "当前已达最高级，新等级特权敬请期待！"
	end
	local tab = {str2,}
	for i=1,#tab do
		local pre = GameObject.Instantiate(self.vip_dec1_txt, self.Content.transform)
		pre.gameObject:SetActive(true)
		pre.transform:GetComponent("Text").text = tab[i]
		self.vip_cell[#self.vip_cell + 1] = pre
	end
	self.up_btn.gameObject:SetActive(data.vip_level ~= VIPManager.GetUserMaxVipLevel())
	self.up_img.gameObject:SetActive(data.vip_level == VIPManager.GetUserMaxVipLevel())
	local config = self.config.vip_map[cur_vip]
	if not config then return end
	for i=1,#config.dec_txt do
		local pre = GameObject.Instantiate(self.vip_dec2_txt, self.Content.transform)
		pre.gameObject:SetActive(true)
		pre.transform:GetComponent("Text").text = config.dec_txt[i]
		self.vip_cell[#self.vip_cell + 1] = pre
	end
end

function C:DestroyVipPre()
	if not table_is_null(self.vip_cell) then
		for k,v in pairs(self.vip_cell) do
			if IsEquals(v.gameObject) then
				destroy(v.gameObject)
			end
		end
	end
	self.vip_cell = {}
end

function C:OnVIPEnterClick()
	VipShowTaskPanel2.Create()
end

function C:CheckIsCJJ()
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "cpl_cjj", is_on_hint = true}, "CheckCondition")
	if a and b then
		return true
	else
		return false
	end
end