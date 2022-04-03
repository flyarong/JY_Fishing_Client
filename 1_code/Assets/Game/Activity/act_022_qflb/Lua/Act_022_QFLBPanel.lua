-- 创建时间:2020-07-17
-- Panel:Act_022_QFLBPanel
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

Act_022_QFLBPanel = basefunc.class()
local C = Act_022_QFLBPanel
C.name = "Act_022_QFLBPanel"
local M = Act_022_QFLBManager

local Page_Status = {
	Week = "Week",
	Month = "Month",
	Quarter = "Quarter",
}

function C.Create(parm)
	return C.New(parm)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["QFLBManager_on_gift_bag_status_change_msg"] = basefunc.handler(self,self.on_QFLBManager_on_gift_bag_status_change_msg)
    self.lister["QFLBManager_on_model_task_change_msg"] = basefunc.handler(self,self.on_QFLBManager_on_model_task_change_msg)
    self.lister["QFLBManager_on_query_all_return_lb_info_msg"] = basefunc.handler(self,self.on_QFLBManager_on_query_all_return_lb_info_msg)
    self.lister["qflb_task_msg_finish_msg"] = basefunc.handler(self,self.on_qflb_task_msg_finish_msg)
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

function C:ctor(parm)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	dump(M.GetConfig(),"<color=red>xxxxxxxxxxx</color>")
	self.week_config = M.GetConfig().week_return
	self.month_config = M.GetConfig().month_return
	self.quarter_config = M.GetConfig().quarter_return
	self.Page_Status = Page_Status.Week
	self.slider = self.Slider.gameObject:GetComponent("Slider")
	self.week_rect = self.week_return_img.gameObject:GetComponent("RectTransform")
	self.month_rect = self.month_return_img.gameObject:GetComponent("RectTransform")
	self.quarter_rect = self.quarter_return_img.gameObject:GetComponent("RectTransform")
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	if parm and parm.chooseData and parm.chooseData=="Quarter" then
		self:Refresh_Quarter()
	end
end

function C:InitUI()
	EventTriggerListener.Get(self.week_return_btn.gameObject).onClick = basefunc.handler(self, self.Refresh_Week)
	EventTriggerListener.Get(self.month_return_btn.gameObject).onClick = basefunc.handler(self, self.Refresh_Month)
	EventTriggerListener.Get(self.quarter_return_btn.gameObject).onClick = basefunc.handler(self, self.Refresh_Quarter)
	EventTriggerListener.Get(self.buy_btn.gameObject).onClick = basefunc.handler(self, self.on_BuyClick)
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.on_BackClick)
	EventTriggerListener.Get(self.help_btn.gameObject).onClick = basefunc.handler(self, self.on_HelpClick)
	EventTriggerListener.Get(self.go_btn.gameObject).onClick = basefunc.handler(self, self.on_GoClick)
	EventTriggerListener.Get(self.get_btn.gameObject).onClick = basefunc.handler(self, self.on_GetClick)
	EventTriggerListener.Get(self.again_buy_btn.gameObject).onClick = basefunc.handler(self, self.on_AgainBuyClick)
	
	--MainModel.GetGiftShopStatusByID(self.data.gift_id)
	

	M.QueryData(true)
	M.QueryAllGiftInfo()
	self:MyRefresh()
end

function C:on_qflb_task_msg_finish_msg()
	self.data = M.GetGiftAllInfo()
	if not self.data then
		return
	end
	dump(self.data,"<color=yellow>++++++++/////++++GetGiftAllInfo++++++++++++</color>")
	if self.data["all_return_lb_1"].is_buy == 1 and self.data["all_return_lb_1"].remain_num <= 0 then
		self:Refresh_Month()
		self.week_return_btn.gameObject:SetActive(false)
	else
		self:Refresh_Week()
	end
	self:Refresh_lfl()
end

function C:MyRefresh()
end

function C:on_BackClick()
	self:MyExit()
end

function C:on_HelpClick()
	Act_022_QFLBHelpPanel.Create()
end


function C:on_BuyClick()
	self:SetBuyClick()
end

function C:on_AgainBuyClick()
	self:SetBuyClick()
end

function C:BuyShop(shopid)
	dump(shopid)
    local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
    dump(MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid))
    if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
        ServiceGzhPrefab.Create({desc="请前往公众号获取"})
    else
        PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
    end
end

function C:on_GoClick()
	if self.Page_Status == Page_Status.Week then
		GameManager.CommonGotoScence({gotoui = self.week_config.gotoui,})
	elseif self.Page_Status == Page_Status.Month then
		GameManager.CommonGotoScence({gotoui = self.month_config.gotoui})
	elseif self.Page_Status == Page_Status.Quarter then
		GameManager.CommonGotoScence({gotoui = self.quarter_config.gotoui})
	end
end

function C:on_GetClick()
	if self.Page_Status == Page_Status.Week then
		M.GetTaskAward(self.week_config.task_id)
	elseif self.Page_Status == Page_Status.Month then
		M.GetTaskAward(self.month_config.task_id)
	elseif self.Page_Status == Page_Status.Quarter then
		M.GetTaskAward(self.quarter_config.task_id)
	end
end

function C:Refresh_Week()
	self.Page_Status = Page_Status.Week
	self:RefreshPageBtnImg()
	--local task_data = GameTaskModel.GetTaskDataByID(self.week_config.task_id)
	self.data = M.GetGiftAllInfo()
	local data = self.data["all_return_lb_1"]
	dump(data,"<color=yellow>++++++++/////++++week++++++++++++</color>")
	if data.remain_num < 1 then
		self:Refresh_Week_gift()
	else
		self:Refresh_Week_task()
	end
end

function C:Refresh_Month()
	self.Page_Status = Page_Status.Month
	self:RefreshPageBtnImg()
	--local task_data = GameTaskModel.GetTaskDataByID(self.month_config.task_id)
	self.data = M.GetGiftAllInfo()
	local data = self.data["all_return_lb_2"]
	dump(data,"<color=yellow>++++++++/////++++month++++++++++++</color>")
	if data.remain_num < 1 then
		self:Refresh_Month_gift()
	else
		self:Refresh_Month_task()
	end
end

function C:Refresh_Quarter()
	self.Page_Status = Page_Status.Quarter
	self:RefreshPageBtnImg()
	--local task_data = GameTaskModel.GetTaskDataByID(self.quarter_config.task_id)
	self.data = M.GetGiftAllInfo()
	local data = self.data["all_return_lb_3"]
	dump(data,"<color=yellow>++++++++/////++++quarter++++++++++++</color>")
	if data.remain_num < 1 then
		self:Refresh_Quarter_gift()
	else
		self:Refresh_Quarter_task()
	end
end

function C:Refresh_Week_gift()
	self:SetNodeActive(true)
	if IsEquals(self.just_one) and IsEquals(self.day_num_txt) and IsEquals(self.below_title_txt) and IsEquals(self.get_award_now_txt) then
		self.just_one.gameObject:SetActive(true)
		self.day_num_txt.text = "连续"..self.week_config.day_num.."天每日领:"
		self.below_title_txt.text = "共领<color=#FFF950>"..StringHelper.ToCash(self.week_config.below_title[1]).."</color>金币+<color=#FFF950>"..StringHelper.ToCash(self.week_config.below_title[2]).."</color>福利券"
		self.get_award_now_txt.text = StringHelper.ToCash(self.week_config.get_award_now).."金币"
	end
	for i=1,#self.week_config.day_award_desc do
		if IsEquals(self["award"..i]) and IsEquals(self["get_award"..i.."_now_img"]) and IsEquals(self["get_award"..i.."_now_txt"]) then
			self["award"..i].gameObject:SetActive(true)
			self["get_award"..i.."_now_img"].sprite = GetTexture(self.week_config.day_award_img[i])
			self["get_award"..i.."_now_txt"].text = self.week_config.day_award_desc[i]
		end
	end
	self:AwardIs2or3(#self.week_config.day_award_desc)
	if IsEquals(self.award3) then
		self.award3.gameObject:SetActive(false)
	end
	if IsEquals(self.price_txt) then
		self.price_txt.text = self.week_config.price.."元购买"
	end
	self:TeShuChuLi(false)
	self:CheckIsSuperValid(true)
end

function C:Refresh_Month_gift()
	self:SetNodeActive(true)
	if IsEquals(self.just_one) and IsEquals(self.day_num_txt) and IsEquals(self.below_title_txt) and IsEquals(self.get_award_now_txt) then
		self.just_one.gameObject:SetActive(false)
		self.day_num_txt.text = "连续"..self.month_config.day_num.."天每日领:"
		self.below_title_txt.text = "共领<color=#FFF950>"..StringHelper.ToCash(self.month_config.below_title[1]).."</color>金币+<color=#FFF950>"..StringHelper.ToCash(self.month_config.below_title[2]).."</color>福利券"
		self.get_award_now_txt.text = StringHelper.ToCash(self.month_config.get_award_now).."金币"
	end
	for i=1,#self.month_config.day_award_desc do
		if IsEquals(self["award"..i]) and IsEquals(self["get_award"..i.."_now_img"]) and IsEquals(self["get_award"..i.."_now_txt"]) then
			self["award"..i].gameObject:SetActive(true)
			self["get_award"..i.."_now_img"].sprite = GetTexture(self.month_config.day_award_img[i])
			self["get_award"..i.."_now_txt"].text = self.month_config.day_award_desc[i]
		end
	end
	self:AwardIs2or3(#self.month_config.day_award_desc)
	if IsEquals(self.price_txt) then
		self.price_txt.text = self.month_config.price.."元购买"
	end
	self:TeShuChuLi(true)
	self:CheckIsSuperValid(false)
end

function C:Refresh_Quarter_gift()
	self:SetNodeActive(true)
	if IsEquals(self.just_one) and IsEquals(self.day_num_txt) and IsEquals(self.below_title_txt) and IsEquals(self.get_award_now_txt) then
		self.just_one.gameObject:SetActive(false)
		self.day_num_txt.text = "连续"..self.quarter_config.day_num.."天每日领:"
		self.below_title_txt.text = "共领<color=#FFF950>"..StringHelper.ToCash(self.quarter_config.below_title[1]).."</color>金币+<color=#FFF950>"..StringHelper.ToCash(self.quarter_config.below_title[2]).."</color>福利券"
		self.get_award_now_txt.text = StringHelper.ToCash(self.quarter_config.get_award_now).."金币"
	end
	for i=1,#self.quarter_config.day_award_desc do
		if IsEquals(self["award"..i]) and IsEquals(self["get_award"..i.."_now_img"]) and IsEquals(self["get_award"..i.."_now_txt"]) then
			self["award"..i].gameObject:SetActive(true)
			self["get_award"..i.."_now_img"].sprite = GetTexture(self.quarter_config.day_award_img[i])
			self["get_award"..i.."_now_txt"].text = self.quarter_config.day_award_desc[i]
		end
	end
	self:AwardIs2or3(#self.quarter_config.day_award_desc)
	if IsEquals(self.price_txt) then
		self.price_txt.text = self.quarter_config.price.."元购买"
	end
	self:TeShuChuLi(true)
	self:CheckIsSuperValid(false)
end

function C:Refresh_Week_task()
	self:SetNodeActive(false)
	local data = GameTaskModel.GetTaskDataByID(self.week_config.task_id)
	if not data then
		M.QueryTaskData()
		return
	end
	self.task_desc_txt.text = self.week_config.task_desc
	self.award_txt.text = "  "..self.week_config.day_award_desc[1].."、"..self.week_config.day_award_desc[2]
	self.slider.value = data.now_process / data.need_process
	self.progress_txt.text = StringHelper.ToCash(data.now_process).." / "..StringHelper.ToCash(data.need_process)
	self.remain_txt.text = "剩余领取天数:  "..self.data["all_return_lb_1"].remain_num.."天"
	self:SetBtnActive(data,self.data["all_return_lb_1"])
	self:InitTaskAwardDay(self.week_config)
end

function C:Refresh_Month_task()
	self:SetNodeActive(false)
	local data = GameTaskModel.GetTaskDataByID(self.month_config.task_id)
	if not data then
		M.QueryTaskData()
		return
	end
	self.task_desc_txt.text = self.month_config.task_desc
	self.award_txt.text = "  "..self.month_config.day_award_desc[1].."、"..self.month_config.day_award_desc[2].."、"..self.month_config.day_award_desc[3]
	self.slider.value = data.now_process / data.need_process
	self.progress_txt.text = StringHelper.ToCash(data.now_process).." / "..StringHelper.ToCash(data.need_process)
	self.remain_txt.text = "剩余领取天数:  "..self.data["all_return_lb_2"].remain_num.."天"
	self:SetBtnActive(data,self.data["all_return_lb_2"])
	self:InitTaskAwardDay(self.month_config)
end

function C:Refresh_Quarter_task()
	self:SetNodeActive(false)
	local data = GameTaskModel.GetTaskDataByID(self.quarter_config.task_id)
	if not data then
		M.QueryTaskData()
		return
	end
	self.task_desc_txt.text = self.quarter_config.task_desc
	self.award_txt.text = "  "..self.quarter_config.day_award_desc[1].."、"..self.quarter_config.day_award_desc[2].."、"..self.quarter_config.day_award_desc[3]
	self.slider.value = data.now_process / data.need_process
	self.progress_txt.text = StringHelper.ToCash(data.now_process).." / "..StringHelper.ToCash(data.need_process)
	self.remain_txt.text = "剩余领取天数:  "..self.data["all_return_lb_3"].remain_num.."天"
	self:SetBtnActive(data,self.data["all_return_lb_3"])
	self:InitTaskAwardDay(self.quarter_config)
end

function C:TeShuChuLi(bool)
	if bool then
		self.get_award_now_node.transform.localPosition = Vector3.New(-463,119,0)
		self.get_award_now.transform.localScale = Vector3.New(0.8,0.8,1)
		self.get_award_now.transform.localPosition = Vector3.New(0,-42,0)
		self.bg1.transform.localPosition = Vector3.New(-463,119,0)
		self.xian.transform.localPosition = Vector3.New(-325,-20.5,0)
		self.award1.transform.localScale = Vector3.New(0.8,0.8,1)
		self.award2.transform.localScale = Vector3.New(0.8,0.8,1)
		self.award3.transform.localScale = Vector3.New(0.8,0.8,1)
		self.award1.transform.localPosition = Vector3.New(-300,-176,0)
		self.award2.transform.localPosition = Vector3.New(0,-176,0)
		self.award3.transform.localPosition = Vector3.New(300,-176,0)
	else
		self.get_award_now_node.transform.localPosition = Vector3.New(-407.4,119,0)
		self.get_award_now.transform.localScale = Vector3.New(1,1,1)
		self.get_award_now.transform.localPosition = Vector3.New(0,0,0)
		self.bg1.transform.localPosition = Vector3.New(-407.4,119,0)
		self.xian.transform.localPosition = Vector3.New(-238,-20.5,0)
	end
end

function C:SetNodeActive(bool)
	if IsEquals(self.Gift_node) then
		self.Gift_node.gameObject:SetActive(bool)
	end
	if IsEquals(self.Task_node) then
		self.Task_node.gameObject:SetActive(not bool)
	end
end

function C:SetBtnActive(task_data,return_data)
	local status = task_data.award_status
	local is_buy = return_data.is_buy
	local remain_num = return_data.remain_num
	self.go_btn.gameObject:SetActive((status == 0) and (is_buy == 1) and (remain_num >= 1))
	self.get_btn.gameObject:SetActive((status == 1) and (is_buy == 1) and (remain_num >= 1))
	self.already.gameObject:SetActive((status == 2) and (is_buy == 1) and (remain_num >= 1))
	--self.over_time.gameObject:SetActive(not bool)
	self.again_buy_btn.gameObject:SetActive((is_buy == 1) and (remain_num < 1))
end

function C:on_QFLBManager_on_gift_bag_status_change_msg()
	self:Refresh()
end

function C:on_QFLBManager_on_model_task_change_msg()
	self:Refresh()
end

function C:Refresh()
	if not self.data then
		return
	end
	if self.Page_Status == Page_Status.Week then
		dump(self.data,"<color=yellow>++++++++/////++++GetGiftAllInfo++++++++++++</color>")
		if self.data["all_return_lb_1"].is_buy == 1 and self.data["all_return_lb_1"].remain_num <= 0 then
			self:Refresh_Month()
			self.week_return_btn.gameObject:SetActive(false)
		else
			self:Refresh_Week()
		end
	elseif self.Page_Status == Page_Status.Month then
		self:Refresh_Month()
	elseif self.Page_Status == Page_Status.Quarter then
		self:Refresh_Quarter()
	end
	self:Refresh_lfl()
end

function C:SetBuyClick()
	if self.Page_Status == Page_Status.Week then
		self:BuyShop(self.week_config.gift_id)
	elseif self.Page_Status == Page_Status.Month then
		self:BuyShop(self.month_config.gift_id)
	elseif self.Page_Status == Page_Status.Quarter then
		self:BuyShop(self.quarter_config.gift_id)
	end
end

function C:RefreshPageBtnImg()
	if IsEquals(self.week_hs_txt) and IsEquals(self.week_lan_txt) and IsEquals(self.week_return_img) and IsEquals(self.week_return_btn)
	and IsEquals(self.month_hs_txt) and IsEquals(self.month_lan_txt) and IsEquals(self.quarter_hs_txt) and IsEquals(self.quarter_lan_txt)
	and IsEquals(self.month_return_img) and IsEquals(self.quarter_return_img) and IsEquals(self.month_return_btn) and IsEquals(self.quarter_return_btn) then
		if self.Page_Status == Page_Status.Week then
			self.week_hs_txt.gameObject:SetActive(true)
			self.week_lan_txt.gameObject:SetActive(false)
			self.week_return_img.sprite = GetTexture("qflb_btn_hs")
			self.week_return_img:SetNativeSize()
			self.week_return_btn.transform.localPosition = Vector3.New(-727,self.week_return_btn.transform.localPosition.y,self.week_return_btn.transform.localPosition.z)

			self.month_hs_txt.gameObject:SetActive(false)
			self.month_lan_txt.gameObject:SetActive(true)
			self.quarter_hs_txt.gameObject:SetActive(false)
			self.quarter_lan_txt.gameObject:SetActive(true)
			self.month_return_img.sprite = GetTexture("qflb_btn_lan")
			self.quarter_return_img.sprite = GetTexture("qflb_btn_lan")
			self.month_rect.sizeDelta = Vector2.New(179.9,117)
			self.quarter_rect.sizeDelta = Vector2.New(179.9,117)
			self.month_return_btn.transform.localPosition = Vector3.New(-736,self.month_return_btn.transform.localPosition.y,self.month_return_btn.transform.localPosition.z)
			self.quarter_return_btn.transform.localPosition = Vector3.New(-736,self.quarter_return_btn.transform.localPosition.y,self.quarter_return_btn.transform.localPosition.z)
		elseif self.Page_Status == Page_Status.Month then
			self.month_hs_txt.gameObject:SetActive(true)
			self.month_lan_txt.gameObject:SetActive(false)
			self.month_return_img.sprite = GetTexture("qflb_btn_hs")
			self.month_return_img:SetNativeSize()
			self.month_return_btn.transform.localPosition = Vector3.New(-727,self.month_return_btn.transform.localPosition.y,self.month_return_btn.transform.localPosition.z)

			self.week_hs_txt.gameObject:SetActive(false)
			self.week_lan_txt.gameObject:SetActive(true)
			self.quarter_hs_txt.gameObject:SetActive(false)
			self.quarter_lan_txt.gameObject:SetActive(true)
			self.week_return_img.sprite = GetTexture("qflb_btn_lan")
			self.quarter_return_img.sprite = GetTexture("qflb_btn_lan")
			self.week_rect.sizeDelta = Vector2.New(179.9,117)
			self.quarter_rect.sizeDelta = Vector2.New(179.9,117)
			self.week_return_btn.transform.localPosition = Vector3.New(-736,self.week_return_btn.transform.localPosition.y,self.week_return_btn.transform.localPosition.z)
			self.quarter_return_btn.transform.localPosition = Vector3.New(-736,self.quarter_return_btn.transform.localPosition.y,self.quarter_return_btn.transform.localPosition.z)
		elseif self.Page_Status == Page_Status.Quarter then
			self.quarter_hs_txt.gameObject:SetActive(true)
			self.quarter_lan_txt.gameObject:SetActive(false)
			self.quarter_return_img.sprite = GetTexture("qflb_btn_hs")
			self.quarter_return_img:SetNativeSize()
			self.quarter_return_btn.transform.localPosition = Vector3.New(-727,self.quarter_return_btn.transform.localPosition.y,self.quarter_return_btn.transform.localPosition.z)

			self.week_hs_txt.gameObject:SetActive(false)
			self.week_lan_txt.gameObject:SetActive(true)
			self.month_hs_txt.gameObject:SetActive(false)
			self.month_lan_txt.gameObject:SetActive(true)
			self.month_return_img.sprite = GetTexture("qflb_btn_lan")
			self.week_return_img.sprite = GetTexture("qflb_btn_lan")
			self.month_rect.sizeDelta = Vector2.New(179.9,117)
			self.week_rect.sizeDelta = Vector2.New(179.9,117)
			self.month_return_btn.transform.localPosition = Vector3.New(-736,self.month_return_btn.transform.localPosition.y,self.month_return_btn.transform.localPosition.z)
			self.week_return_btn.transform.localPosition = Vector3.New(-736,self.week_return_btn.transform.localPosition.y,self.week_return_btn.transform.localPosition.z)
		end
	end
end


function C:AwardIs2or3(len)
	if len == 2 then
		self.award1.transform.localScale = Vector3.New(1,1,1)
		self.award2.transform.localScale = Vector3.New(1,1,1)
		self.award1.transform.localPosition = Vector3.New(-187,-177,0)
		self.award2.transform.localPosition = Vector3.New(190,-177,0)
	elseif len == 3 then
		self.award1.transform.localScale = Vector3.New(0.65,0.65,1)
		self.award2.transform.localScale = Vector3.New(0.65,0.65,1)
		self.award3.transform.localScale = Vector3.New(0.65,0.65,1)
		self.award1.transform.localPosition = Vector3.New(-241,-177,0)
		self.award2.transform.localPosition = Vector3.New(0,-177,0)
		self.award3.transform.localPosition = Vector3.New(240,-177,0)
	end
end

function C:on_QFLBManager_on_query_all_return_lb_info_msg()
	self:Refresh()
end


function C:Refresh_lfl()
	local data1 = GameTaskModel.GetTaskDataByID(self.week_config.task_id)
	local data2 = GameTaskModel.GetTaskDataByID(self.month_config.task_id)
	local data3 = GameTaskModel.GetTaskDataByID(self.quarter_config.task_id)
	self.week_lfl.gameObject:SetActive(data1 and (data1.award_status == 1))
	self.month_lfl.gameObject:SetActive(data2 and (data2.award_status == 1))
	self.quarter_lfl.gameObject:SetActive(data3 and (data3.award_status == 1))
end

function C:InitTaskAwardDay(config)
	for i=1,#config.day_award_desc do
		self["award_day"..i].gameObject:SetActive(true)
		self["award_day"..i.."_img"].sprite = GetTexture(config.day_award_img[i])
		self["award_day"..i.."_txt"].text = config.day_award_desc[i]
	end
	if #config.day_award_desc == 2 then
		self.award_day3.gameObject:SetActive(false)
	end
end

--是否显示超值标签
function C:CheckIsSuperValid(b)
	self.supervalid.gameObject:SetActive(b)
end