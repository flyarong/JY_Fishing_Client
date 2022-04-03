-- 创建时间:2020-04-09
-- Panel:Act_028_MFHFPanel
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

Act_028_MFHFPanel = basefunc.class()
local C = Act_028_MFHFPanel
C.name = "Act_028_MFHFPanel"
local M = Act_028_MFHFManager
local Timers = {}
local Anim_Data = {
	step1_time = 1.4,
	step2_time = 3.0,
	step3_time = 1.6,
}

C.can_buy_gift = true
C.can_lottery = false

function C.Create(parent,isOut)
	return C.New(parent,isOut)
end

function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
	self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
	self.lister["box_exchange_response"] = basefunc.handler(self,self.on_box_exchange_response)
	self.lister["028MFHF_query_gift_bag_status_msg"] = basefunc.handler(self,self.on_028MFHF_query_gift_bag_status_msg)
	self.lister["main_query_gift_bag_data_msg"] = basefunc.handler(self,self.on_028MFHF_query_gift_bag_status_msg)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end


function C:ctor(parent,isOut)

	ExtPanel.ExtMsg(self)

	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.NoStart_By_Anim = true -- 通过动画判断是不是能够启动抽奖
	self.Mapping = {1,2,3,4,5,6}
	self:MakeLister()
	self:AddMsgListener()
	self:Idle_Anim(1)
	self:InitUI()
	self.BG.gameObject:SetActive(not isOut)
	self.close_btn.gameObject:SetActive(not isOut)
	self.time_txt.text = M.config.act_time
	self.BG_img.sprite = GetTexture(M.config.BG)
	for i=1,#M.config.cj_award_txt do
		self["award"..i.."_txt"].text = M.config.cj_award_txt[i]
	end
	self.buy_award_img.sprite = GetTexture(M.config.buy_award_img)
	self.cost_txt.text = M.config.cost_txt
	for i=1,#M.config.tips do
		self["tip"..i.."_txt"].text = M.config.tips[i]
	end
end

function C:InitUI()
	self:AddButtonOnClick()
	M.Timer_to_refresh(true)
end

function C:AddButtonOnClick()
	self.lottery_btn.onClick:AddListener(function()
		if self.can_lottery then
			if self.NoStart_By_Anim then 
				Network.SendRequest("box_exchange",{id = M.box_exchange_id,num = 1})
			end
		elseif self.can_buy_gift then
			HintPanel.Create(1,"领取金币宝箱后才可以抽奖")
		end
	end)
	self.lottery_gray_btn.onClick:AddListener(function()
		if self.shop_btn.gameObject.activeSelf then
			LittleTips.Create("领取金币宝箱后才可以抽奖")
		else
			LittleTips.Create("今日已抽奖，明日领取礼包后再来")
		end
	end)
	self.shop_btn.onClick:AddListener(function()
		M.BuyShop()
	end)
	self.close_btn.onClick:AddListener(function()
		self:MyExit()
	end)
end

function C:MyRefresh()
	local shopid = M.shopid
	local status = M.GetShopStatus()
	if status ~= 1 then
		self.shop_btn_gray.gameObject:SetActive(true)
		self.shop_btn.gameObject:SetActive(false)
		self.can_buy_gift = false
	else
		if IsEquals(self.shop_btn_gray) then
			self.shop_btn_gray.gameObject:SetActive(false)
		end
		if IsEquals(self.shop_btn) then
			self.shop_btn.gameObject:SetActive(true)
		end
		self.can_buy_gift = true
	end
	
	if GameItemModel.GetItemCount("prop_mfcjq") > 0 then
		--呼吸效果
		self.can_lottery = true
		self.lottery_gray_btn.gameObject:SetActive(false)
		if not self.anim_index then 
			self.anim_index = CommonHuxiAnim.Start(self.lottery_btn.gameObject,1)
		end
	else
		self.can_lottery = false
		self.lottery_gray_btn.gameObject:SetActive(true)
		CommonHuxiAnim.Stop(self.anim_index)
	end

	self:RefreshGetIcon()
	dump(self:CheckLotteriedToday(),"<color=yellow>++++++++++++++////+++++++++++++++</color>")
end

function C:RefreshGetIcon()
	self.is_lotteryed_today = false
	local award_index = self:CheckLotteriedToday()
	if award_index ~= 0 then
		self.is_lotteryed_today = true
	end
end

local anim_way = {
	1,2,3,4,5,6
}

function C:Step1_Anim(startPos, Step, maxStep)
	local AnimationName = "Step1"
	startPos = startPos or 1
	maxStep = maxStep or #anim_way
	local _End = 0
	local Time = self:TimerCreator(function()	
		self:ShakeLotteryPraticSys(anim_way[startPos])
		startPos = startPos + 1
		_End = _End + 1
		while startPos > maxStep do startPos = startPos - maxStep end
		if _End >= Step then
			self:OnFinshName(AnimationName, startPos)
		end
	end, Anim_Data.step1_time / Step, -1, AnimationName)
	Time:Start()

end

function C:Step2_Anim(startPos, Step, maxStep)
	local AnimationName = "Step2"
	startPos = startPos or 1
	maxStep = maxStep or #anim_way
	local _End = 0
	local Time = self:TimerCreator(function()
		self:ShakeLotteryPraticSys(anim_way[startPos])
		startPos = startPos + 1
		_End = _End + 1
		while startPos > maxStep do startPos = startPos - maxStep end
		if _End >= Step then
			self:OnFinshName(AnimationName, startPos)
		end
	end, Anim_Data.step2_time / Step, -1, AnimationName)
	Time:Start()
end

function C:Step3_Anim(startPos, Step, maxStep)
	local AnimationName = "Step3"
	startPos = startPos or 1
	maxStep = maxStep or #anim_way
	local _End = 0
	local Time = self:TimerCreator(function()
		self:ShakeLotteryPraticSys(anim_way[startPos])
		startPos = startPos + 1
		_End = _End + 1
		while startPos > maxStep do startPos = startPos - maxStep end
		if _End >= Step then
			self:OnFinshName(AnimationName, startPos)
		end
	end, Anim_Data.step3_time / Step, -1, AnimationName)
	Time:Start()
end

function C:Idle_Anim(startPos, maxStep)
	local AnimationName = "Idle"
	startPos = startPos or 1
	maxStep = maxStep or #anim_way
	local constant_sec = 1
	local sec = 1
	local time_space = 0.1
	local During_Times = 10
	local Time = self:TimerCreator(function()
		if sec <= 0 then 
			self:ShakeLotteryPraticSys(anim_way[startPos])
			startPos = startPos + 1
			while startPos > maxStep do startPos = startPos - maxStep end
			sec = constant_sec 
		end
		sec = sec - time_space 
		if  not self.NoStart_By_Anim then
			self:OnFinshName(AnimationName, startPos)
		end
	end, time_space, -1, AnimationName)
	Time:Start()
end

function C:Twinkle_Anim(startPos, Step, maxStep)
	local AnimationName = "Twinkle"
	maxStep = maxStep or #anim_way
	local _End = 0
	local Time = self:TimerCreator(function()
		self:ShakeLotteryPraticSys(anim_way[startPos])
		_End = _End + 1
		while startPos > maxStep do startPos = startPos - maxStep end
		if _End >= Step then
			self:OnFinshName(AnimationName, startPos)
		end
	end, 0.33, Step, AnimationName)
	Time:Start()
end

function C:ShakeLotteryPraticSys(pos)
	for i = 1,#anim_way do
		self["Lottery_" .. i]:Find("@highlight").gameObject:SetActive(false)
	end
	self["Lottery_" .. pos]:Find("@highlight").gameObject:SetActive(true)
end

function C:StopAllAnim()
	for k, v in pairs(Timers) do
		if v then
			v:Stop()
		end
	end
end

function C:GetMapping(max, disturb)
	local temp_list = {}
	local List = {}
	for i = 1, max do
		List[i] = i
	end
	math.randomseed(MainModel.UserInfo.user_id)
	while #temp_list < max do
		local R = math.random(1, max)
		if List[R] ~= nil then
			temp_list[#temp_list + 1] = List[R]
			table.remove(List, R)
		end
	end
	return temp_list
end

function C:LotteryType2Str(Num, type)
	if type == "jing_bi" then
		return Num .. "金币"
	elseif type == "jipaiqi" then
		return Num .. "记牌器"
	elseif type == "fish_coin" then
		return Num .. "鱼币"
	elseif type == "shop_gold_sum" then
		return Num/100 .. "福利券"
	else
		return type
	end
end
function C:OnFinshName(animationName, startPos)
	if animationName == "Idle" then
		self:StopAllAnim()
		self:Step1_Anim(startPos, 7)
		self.curSoundKey = ExtendSoundManager.PlaySound(audio_config.game.bgm_duijihongbao.audio_name, 1, function()
			self.curSoundKey = nil
		end)
	end
	if animationName == "Twinkle" then
		self.NoStart_By_Anim = true
		self:StopAllAnim()
		self:EndLottery()
		self:Idle_Anim(startPos)
	end
	if animationName == "Step1" then
		self:StopAllAnim()
		self:Step2_Anim(startPos, 65)
	end
	if animationName == "Step2" then
		self:StopAllAnim()
		local award_index = self.award_id - M.award_index + #self.Mapping - 4
		local step = self:GetStopStep(self.Mapping, award_index, startPos)
		self:Step3_Anim(startPos, step)
	end
	if animationName == "Step3" then
		self:StopAllAnim()
		self:CloseAnimSound()
		self:Twinkle_Anim(startPos, 6)
	end
end

function C:GetStopStep(mapping, award_index, startPos)
	dump(mapping,"<color=red>mapping</color>")
	dump(award_index,"<color=red>award_index</color>")
	dump(startPos,"<color=red>startPos</color>")
	for i = 1, #mapping do
		if mapping[i] == award_index then
			return 2 * #anim_way + i - startPos
		end
	end
end
function C:TimerCreator(func, duration, loop, animationName,scale,durfix)
	local timer = Timer.New(func, duration, loop)
	if Timers[animationName] then
		Timers[animationName]:Stop()
		Timers[animationName] = nil
	end
	Timers[animationName] = timer
	return timer
end

function C:CloseAnimSound()
	if self.curSoundKey then
		soundMgr:CloseLoopSound(self.curSoundKey)
		self.curSoundKey = nil
	end
end

function C:on_model_task_change_msg()

end

function C:on_box_exchange_response(_,data)
	dump(data,"<color=red>开奖数据-------------</color>")
	if data.result == 0 then
		if data.id == M.box_exchange_id then
			if #data.award_id == 1 then 
				self.award_id = data.award_id[1]
				local award_index = self.award_id - M.award_index + #self.Mapping - 4
				if self.is_lotteryed_today then
					--dump(self:CheckLotteriedToday(),"<color=yellow>++++++++++++++////+++++++++++++++</color>")
					local before_index = self:CheckLotteriedToday()
					--PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id .. "award" .. before_index,0)
				end
				--dump(award_index,"<color=yellow>++++++++++++++//award_index//+++++++++++++++</color>")
				PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id .. "award" .. award_index,os.time())
				dump(award_index,"<color=red>award_index</color>")
				dump(tonumber(os.date("%Y%m%d", os.time())),"<color=red>now</color>")
				self.NoStart_By_Anim = false
			end 
		end 
	else
		HintPanel.ErrorMsg(data.result)
	end 
end

function C:EndLottery()
	if self.Award_Data then 
		Event.Brocast("AssetGet",self.Award_Data)
		self.Award_Data = nil
		self:RefreshGetIcon()
	end
end

function C:OnAssetChange(data)
	dump(data, "<color=red>----奖励类型-----</color>")
	if not IsEquals(self.gameObject) then return end
	if data.change_type and data.change_type == "box_exchange_active_award_"..M.box_exchange_id and not table_is_null(data.data) then
		self.Award_Data = data
	elseif  data.change_type and data.change_type == "buy_gift_bag_"..M.shopid and not table_is_null(data.data) then
		--just_buy_gift = true
		M.QueryShopData()
	end
	self:MyRefresh()
end

function C:CheckLotteriedToday()
	local newtime = tonumber(os.date("%Y%m%d", os.time()))
	local award_index = 0
	dump(newtime,"<color=red>newtime</color>")
	for i = 1,6 do
		local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id .. "award" .. i, 0))))
		dump(oldtime,"<color=red>oldtime</color>")
		if oldtime == newtime then
			self["Lottery_" .. self.Mapping[i]].transform:Find("icon_get").gameObject:SetActive(true)
			award_index = i
		else
			self["Lottery_" .. self.Mapping[i]].transform:Find("icon_get").gameObject:SetActive(false)
		end
	end
	return award_index
end

function C:MyExit()
	CommonHuxiAnim.Stop(self.anim_index)
	M.Timer_to_refresh(false)
	if self.backcall then 
		self.backcall()
	end 

	if self.SlowUP_Timer then
		self.SlowUP_Timer:Stop()
	end
	if self.CountTimer then 
		self.CountTimer:Stop()
	end  
	self:StopAllAnim()
	self:EndLottery()
	self:RemoveListener()
	destroy(self.gameObject)	
end

function C:OnDestroy()
	self:MyExit()
end

function C:on_028MFHF_query_gift_bag_status_msg()
	self:MyRefresh()
end

