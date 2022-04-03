-- 创建时间:2020-12-07
-- Panel:Template_NAME
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

Act_052_QFHLPanel = basefunc.class()
local C = Act_052_QFHLPanel
C.name = "Act_052_QFHLPanel"
local M = Act_052_QFHLManager

local map = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}
local offset = {}

function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
	self.lister["model_task_change_msg"] = basefunc.handler(self, self.on_model_task_change_msg)
	self.lister["model_query_one_task_data_response"] = basefunc.handler(self, self.on_model_query_one_task_data_response)
	self.lister["box_exchange_response"] = basefunc.handler(self,self.on_box_exchange_response)
	self.lister["AssetChange"] = basefunc.handler(self,self.on_AssetChange)
	self.lister["query_fake_data_response"] = basefunc.handler(self, self.AddPMD)
	self.lister["set_qfhl_lottery_success"] = basefunc.handler(self, self.on_set_qfhl_lottery_success)
	self.lister["get_task_award_new_response"] = basefunc.handler(self,self.on_get_task_award_new_response)

end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	if self.cutdown_timer then
		self.cutdown_timer:Stop()
	end
	if self.UpdatePMD then
		self.UpdatePMD:Stop()
	end
	if self.pmd_cont then
		self.pmd_cont:MyExit()
		self.pmd_cont = nil
	end
	if self.beforeChosePre then
		self.beforeChosePre:MyExit()
		self.beforeChosePre=nil
	end
	self.MainAnim:MyExit()
	self:TryToShow()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	Network.SendRequest("query_one_task_data", { task_id = M.task_id })
	self:MakeLister()
	self:AddMsgListener()
	self.begainTime,self.CutDownEndTime=M.GetActivityTime()

	self:InitUI()
    self.cutdown_timer=CommonTimeManager.GetCutDownTimer(self.CutDownEndTime,self.cut_txt)
end

local TaskAwardShowTips_1={"2~8万金币","10~20万金币","10~20万金币",}
local TaskAwardShowTips_2={"10~15万金币","30~50万金币","30~50万金币",}
local TaskAwardShowTips_3={"15~30万金币","40~60万金币","40~60万金币",}
local TaskAwardShowTips_4={"30~50万金币","50~150万金币","100~300万金币",}
local TaskAwardShowTips_5={M.config.Award_sw[1].tex,M.config.Award_sw[2].tex,M.config.Award_sw[3].tex,}

function C:InitUI()
	local temp_items = {}
	for i = 1,15 do
		temp_items[#temp_items + 1] = self["lottery_item"..i]
	end
	local create_anim_func = function()
		self.MainAnim = CommonLotteryAnim.Create(temp_items, function (obj,pos)
			for i = 1,#temp_items do
				local show = temp_items[i].transform:Find("fqj_kuang")
				show.gameObject:SetActive(false)
			end
			local show = obj.transform:Find("fqj_kuang")
			show.gameObject:SetActive(true)
		end)
	end
	create_anim_func()
	self.lottery_img.sprite = GetTexture(M.GetCurItemImage(1))
	self.paygoods_name =M.GetCurItemDec(1)
	local name2,num =  M.GetCurItemDec(2)
	self.info_txt.text="所有游戏随机掉落"..self.paygoods_name.."，每次抽奖消耗"..num..name2
	self.skip_btn.onClick:AddListener(
		function()
			self.MainAnim:MyExit()			
			create_anim_func()
		end
	)
	self.help_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:OpenHelpPanel()
		end
	)
	self.Anims = {}
	for i = 1,5 do
		self.Anims[#self.Anims + 1] = CommonHuxiAnim.Go(self["task_award"..i.."_img"].gameObject,0.9,1,1.3)
		self["task_award"..i.."_btn"].onClick:AddListener(
			function()
				local data = GameTaskModel.GetTaskDataByID(M.task_id)
				if data then
					local b = basefunc.decode_task_award_status(data.award_get_status)
					b = basefunc.decode_all_task_award_status(b, data, 5)
					if b[i] == 1 then
						Network.SendRequest("get_task_award_new", { id = M.task_id, award_progress_lv = i })
					end
				end
			end
		)
	end
	
	self.lottery1_btn.onClick:AddListener(
		function ()
			if self.lock then return end
			if GameItemModel.GetItemCount(M.m_data.lottery_key) >= M.m_data.PerNeed then
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				self.lock = true
				Network.SendRequest("box_exchange",{id = M.GetBoxExchangID(),num = 1})
			else
				LittleTips.Create("您的"..self.paygoods_name.."不足")
			end
		end
	)
	self.lottery10_btn.onClick:AddListener(
		function ()
			if self.lock then return end
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self.lock = true
			Network.SendRequest("box_exchange",{id =M.GetBoxExchangID() ,num = 10})	
		end
	)
	self.lottery50_btn.onClick:AddListener(
		function ()
			if self.lock then return end
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self.lock = true
			Network.SendRequest("box_exchange",{id = M.GetBoxExchangID(),num = 50})	
		end
	)
	
	self:InitMainUI()
	self:MyRefresh()
	self.pmd_cont = CommonPMDManager.Create(self,self.CreatePMD,{ parent = self.pmd_node, time_scale = 1.5, speed = 18, space_time = 10, start_pos = 1000 ,dotweenLayerKey = "qfhl_after"})
	self:UpDatePMD()

	EventTriggerListener.Get(self.task_award1_btn.gameObject).onClick = function()
		local nowTaskType=M.GetNowTaskType()
		self:CreateTips(self.task_award1_btn.gameObject.transform,"金币宝箱：","随机获得"..TaskAwardShowTips_1[nowTaskType])
	end
	EventTriggerListener.Get(self.task_award1_img.gameObject).onClick = function()
		local nowTaskType=M.GetNowTaskType()
		self:CreateTips(self.task_award1_btn.gameObject.transform,"金币宝箱：","随机获得"..TaskAwardShowTips_1[nowTaskType])
	end

	EventTriggerListener.Get(self.task_award2_btn.gameObject).onClick = function()
		local nowTaskType=M.GetNowTaskType()
		self:CreateTips(self.task_award2_btn.gameObject.transform,"金币宝箱：","随机获得"..TaskAwardShowTips_2[nowTaskType])
	end
	EventTriggerListener.Get(self.task_award2_img.gameObject).onClick = function()
		local nowTaskType=M.GetNowTaskType()
		self:CreateTips(self.task_award2_img.gameObject.transform,"金币宝箱：","随机获得"..TaskAwardShowTips_2[nowTaskType])
	end

	EventTriggerListener.Get(self.task_award3_btn.gameObject).onClick = function()
		local nowTaskType=M.GetNowTaskType()
		self:CreateTips(self.task_award3_btn.gameObject.transform,"金币宝箱：","随机获得"..TaskAwardShowTips_3[nowTaskType])
	end
	EventTriggerListener.Get(self.task_award3_img.gameObject).onClick = function()
		local nowTaskType=M.GetNowTaskType()
		self:CreateTips(self.task_award3_img.gameObject.transform,"金币宝箱：","随机获得"..TaskAwardShowTips_3[nowTaskType])
	end

	EventTriggerListener.Get(self.task_award4_btn.gameObject).onClick = function()
		local nowTaskType=M.GetNowTaskType()
		self:CreateTips(self.task_award4_btn.gameObject.transform,"金币宝箱：","随机获得"..TaskAwardShowTips_4[nowTaskType])
	end
	EventTriggerListener.Get(self.task_award4_img.gameObject).onClick = function()
		local nowTaskType=M.GetNowTaskType()
		self:CreateTips(self.task_award4_img.gameObject.transform,"金币宝箱：","随机获得"..TaskAwardShowTips_4[nowTaskType])
	end

	EventTriggerListener.Get(self.task_award5_btn.gameObject).onClick = function()
		local nowTaskType=M.GetNowTaskType()
		self:CreateTips(self.task_award5_btn.gameObject.transform,"实物奖励：","获得"..TaskAwardShowTips_5[nowTaskType])
	end
	EventTriggerListener.Get(self.task_award5_img.gameObject).onClick = function()
		local nowTaskType=M.GetNowTaskType()
		self:CreateTips(self.task_award5_img.gameObject.transform,"实物奖励：","获得"..TaskAwardShowTips_5[nowTaskType])
	end

end

function C:CreatePMD(data)
	local obj = GameObject.Instantiate(self.pmd_item, self.pmd_node.transform)
	local text = obj.transform:Find("@t1_txt"):GetComponent("Text")
	text.text = "恭喜【 " .. data.player_name .. " 】鸿运当头抽中了" .. data.ext_data[1] .. "奖品！"
	obj.gameObject:SetActive(true)
	return obj
end
function C:InitMainUI()
	local chosedType=M.GetNowTaskType()
	if chosedType==0 then
		-- body
		self.beforeChosePre=Act_052_QFHLBeforePanel.Create(self.beforeroot)
		self.afterChoose.gameObject:SetActive(false)
	else
		self.afterChoose.gameObject:SetActive(true)
	end
	local lotteryitems={self.lottery_item1}
	for i = 1,#M.config.Award1 do
		-- EventTriggerListener.Get(self["lottery_item"..i].gameObject).onDown = function()
		-- 	self:CreateTips(self["lottery_item"..i].gameObject.transform,tips_1[map[i]],tips_2[map[i]])
		-- end
		-- EventTriggerListener.Get(self["lottery_item"..i].gameObject).onUp = function()
		-- 	self.tip_item.transform.gameObject:SetActive(false)
		-- end
		-- self["lottery_item"..i].gameObject.transform.localScale = Vector3.New(0.8,0.8,0.8)
		local item_mapui={}
		LuaHelper.GeneratingVar(self["lottery_item"..i], item_mapui)

		item_mapui.item_img.sprite= GetTexture(M.config.Award1[map[i]].img)
		item_mapui.des_txt.text=M.config.Award1[map[i]].text
	end
end

function C:CreateTips(transform,title,desc)
	local str = title..":" .. "\n--------------".."\n"..desc
	LTTipsPrefab.Show2(transform,title,desc)
	-- self.tips_tit_txt.text = title
	-- self.tips_desc_txt.text = desc
	-- self.tip_item.transform.parent = transform
	-- self.tip_item.transform.localPosition = Vector3.zero
	-- self.tip_item.transform.gameObject:SetActive(true)
end

function C:MyRefresh(ispmd)
	local dropNum=GameItemModel.GetItemCount(M.m_data.lottery_key)
	self.lottery_num_txt.text = "x"..dropNum
	--使用抽奖券
	if dropNum < 10*M.m_data.PerNeed then
		self.lottery1_btn.gameObject:SetActive(true)
		self.lottery10_btn.gameObject:SetActive(false)
		self.lottery50_btn.gameObject:SetActive(false)
	elseif dropNum>=10*M.m_data.PerNeed and dropNum<50*M.m_data.PerNeed then
		self.lottery1_btn.gameObject:SetActive(false)
		self.lottery10_btn.gameObject:SetActive(true)
		self.lottery50_btn.gameObject:SetActive(false)
	else
		self.lottery1_btn.gameObject:SetActive(false)
		self.lottery10_btn.gameObject:SetActive(false)
		self.lottery50_btn.gameObject:SetActive(true)
	end
	self.fuqi1_txt.gameObject:SetActive(false)
	self.fuqi10_txt.gameObject:SetActive(false)

	local swinfo=M.GetAwardSwInfo()
	if swinfo then
		SetTextureExtend(self.task_award5_btn.image,swinfo.image)
		SetTextureExtend(self.task_award5_img,swinfo.image)
		SetTextureExtend(self.mask5_img,swinfo.image)
	end

	self.lottery1_txt.text = "消耗<color=yellow>".. M.m_data.PerNeed .."</color>" .. self.paygoods_name
	self.lottery10_txt.text = "消耗<color=yellow>".. M.m_data.PerNeed*10 .."</color>" .. self.paygoods_name
	self.lottery50_txt.text = "消耗<color=yellow>".. M.m_data.PerNeed*50 .."</color>" .. self.paygoods_name
	-- if M.task_id~=0 or ispmd then
	-- 	if self.pmd_cont then
	-- 		self.pmd_cont:MyExit()
	-- 		self.pmd_cont = nil
	-- 	end
	
	-- end
end

--在奖励列表里面获取实物奖励的ID
function C:GetRealInList(award_id)
	local r_list = {}
	-- local temp
	-- for i=1,#award_id do
	-- 	temp = self:GetConfigByServerID(award_id[i])
	-- 	if temp.real == 1 then 
	-- 		r_list[#r_list + 1] = temp
	-- 	end
	-- end
	return r_list
end
--根据ID获取配置信息
function C:GetConfigByServerID(server_award_id)
	local config = M.config
	for i=1,#config.Award1 do
		if config.Award1[i].server_award_id == server_award_id then 
			return config.Award1[i]
		end 
	end
end
--如果全都是实物奖励，就直接用 realawardpanel
function C:IsAllRealPop(award_id,real_list)
	if #real_list >= #award_id then 
		return true
	else
		return false
	end 
end
--把配置数据转换为奖励展示面板所需要的数据格式
function C:GetShowData(real_list)
	local data = {}
	data.text = {}
	data.image = {}
	for i=1,#real_list do
		data.text[#data.text + 1] = real_list[i].text
		data.image[#data.image + 1] = real_list[i].img
	end
	return data
end

function C:RefreshNum(total)
	offset=M.GetAwardSwInfo().offset
	for i = 1,5 do
		local num = total >= offset[i + 1] and  offset[i + 1] or total
		self["task"..i.."_txt"].text = num.."/"..offset[i + 1]
	end
end

function C:ReFreshTaskButtons(list)
	for i = 1,#list do
		if list[i] == 1 then
			self.Anims[i].Start()
		else
			self.Anims[i].Stop()
		end
		self["task_award"..i.."_img"].gameObject:SetActive(list[i] ~= 2)
		self["mask"..i .."_img"].gameObject:SetActive(list[i] == 2)
	end
end

function C:ReFreshProgress(total)
	local len = {
		[1] = {min = 0,max = 46.19},
		[2] = {min = 134.06,max = 247.93},
		[3] = {min = 338.1,max = 442.8},
		[4] = {min = 524.37,max = 643.84},
		[5] = {min = 730.49,max = 938.9},
	}
	local now_level = 1
	if not M.GetAwardSwInfo() then
		return
	end
	offset=M.GetAwardSwInfo().offset
	for i = #offset,1,-1 do
		if total >= offset[i] then
			now_level = i
			break
		end
	end
	if now_level > 5 then
		self.progress.sizeDelta={x = len[#len].max,y = 29.78}
	else
		local now_need = offset[now_level + 1] - offset[now_level]
		local now_have = total - offset[now_level]
		local l = (now_have/now_need) * (len[now_level].max - len[now_level].min) + len[now_level].min
		self.progress.sizeDelta={x = l,y = 20.8}
	end
	self:RefreshNum(total)
end

function C:on_AssetChange(data)
	if data.change_type and (data.change_type == M.GetBoxExchangID(1) or 
							data.change_type == M.GetBoxExchangID(2) or
							data.change_type == M.GetBoxExchangID(3)) and 
		not table_is_null(data.data) then
		self.Award_Data = data
		self:SetAwardIcon()
	end
	self:MyRefresh()
end

function C:TryToShow()
	dump(self.Award_Data,"ShowAwardData:  ")
	if self.Award_Data then
		self:SetSWAwardData(self.Award_IDs)
		if #self.Award_IDs==50 then
			-- body
			local pre = AssetsGet50Panel.Create(self.cur_award.showData, function ()
				M.ShowSWHintPannel()
			end,nil,nil,false)
			pre.info_desc_txt.transform.localPosition = Vector3.New(0, -325, 0)
		elseif #self.Award_IDs==10 then
			---10连抽
			local pre = AssetsGet10Panel_by.Create(self.cur_award.showData, function ()
				M.ShowSWHintPannel()
			end,nil,nil,false)
			pre.info_desc_txt.transform.localPosition = Vector3.New(0, -325, 0)
		elseif #self.Award_IDs==1 then
			if not self.cur_award.showData[1].asset_type then
				local string1
				string1 = "恭喜获得"..self.cur_award.showData[1].desc.."请联系客服QQ号4008882620领取！"
				local pre = HintCopyPanel.Create({desc=string1, isQQ=true,copy_value = "4008882620"})
				pre:SetCopyBtnText("复制QQ号")
			else
				Event.Brocast("AssetGet",self.Award_Data)
			end
			
		end
		self.Award_Data = nil
	end
end
function C:SetAwardIcon()
	for i=1,#self.Award_Data.data do
		local itemInfo=GameItemModel.GetItemToKey(self.Award_Data.data[i].asset_type)
		self.Award_Data.data[i].icon=itemInfo.image
	end
end
function C:SetSWAwardData(dataList)
	self.cur_award={}
	---用于奖励显示
	self.cur_award.sw_data={}
	---用于实物弹窗显示
	self.cur_award.showData={}
	local isContain= function (list,desc)
		for index, value in ipairs(list) do
			if value.desc==desc then
				return index
			end
		end
		return -1
	end
	for i=1,#dataList do
		local  cfg = M.GetAwardConfigByAwardID(dataList[i])
		if cfg  then
			
			self.cur_award.showData[#self.cur_award.showData + 1] = {image=cfg.img, desc=cfg.text,asset_type=cfg.asset_type,shiwu=cfg.real==1}
			
			if cfg.real==1  then
				local containIndex=isContain(self.cur_award.sw_data,cfg.text)
				if containIndex==-1 then
					self.cur_award.sw_data[#self.cur_award.sw_data + 1] = {num=1, desc=cfg.text}
				else
					local num=self.cur_award.sw_data[containIndex].num
					self.cur_award.sw_data[containIndex].num=num+1
				end
			end
		
		end
	end
	self:AddFuQiShowData()
	M.SetCurSWData(self.cur_award.sw_data)
end
function C:AddFuQiShowData()
	for index, value in ipairs(self.Award_Data.data) do
		if value.asset_type=="prop_grade" then
			self.cur_award.showData[#self.cur_award.showData + 1] = {image="com_award_icon_f", desc= M.ItemName .. "x" .. value.value,asset_type=value.asset_type}
		end
	end
end

function C:GetCurHelpInfor()
    local help_desc = {
		"1.活动期间",
		"2.所有游戏中随机掉落"..self.paygoods_name.."，收集"..self.paygoods_name.."可祈福抽奖。",
		"3.活动结束后，未使用的"..self.paygoods_name.."道具将全部被清除，请及时使用。",
		"4.实物奖励请在活动结束后7个工作日内联系客服QQ《4008882620》领取，否则视为自动放弃奖励。",
		"5.奖励图片仅供参考，请以实际发出的奖励为准。",
		"6.实物奖励将在活动结束后7个工作日内统一发放。",}
    local sta_t = self:GetStart_t()
    local end_t = self:GetEnd_t()
    help_desc[1] = "1.活动时间：".. sta_t .."-".. end_t
    return help_desc
end

function C:GetStart_t()
    return string.sub(os.date("%m月%d日%H:%M",self.begainTime),1,1) ~= "0" and os.date("%m月%d日%H:%M",self.begainTime) or string.sub(os.date("%m月%d日%H:%M",self.begainTime),2)
end

function C:GetEnd_t()
    return string.sub(os.date("%m月%d日%H:%M:%S",self.CutDownEndTime),1,1) ~= "0" and os.date("%m月%d日%H:%M:%S",self.CutDownEndTime) or string.sub(os.date("%m月%d日%H:%M:%S",self.CutDownEndTime),2)
end
function C:OpenHelpPanel()
	-- local DESCRIBE_TEXT = M.config.DESCRIBE_TEXT
	-- local str = DESCRIBE_TEXT[1].text
	-- for i = 2, #DESCRIBE_TEXT do
	-- 	str = str .. "\n" .. DESCRIBE_TEXT[i].text
	-- end
	local str
	local help_info=self:GetCurHelpInfor()
	str = help_info[1]
	for i = 2, #help_info do
		str = str .. "\n" .. help_info[i]
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:on_box_exchange_response(_,data)
	dump(data,"<color=red>返回</color>")
	if data.result == 0 then
		self.skip_btn.gameObject:SetActive(true)
		--PMD Self
		-- local real_list = self:GetRealInList(data.award_id)
		-- dump(real_list,"<color=red>-------实物奖励------</color>")
		-- if self:IsAllRealPop(data.award_id,real_list) then 
		-- 	RealAwardPanel.Create(self:GetShowData(real_list))
		-- else
		-- 	self.call = function ()
		-- 		if not table_is_null(real_list) then 
		-- 			MixAwardPopManager.Create(self:GetShowData(real_list),nil,2)
		-- 		end
		-- 	end 
		-- end
		local award_index = self:GetAwardIndexInUI(data.award_id[1])
		dump(award_index,"award_idex:   ")
		self.Award_IDs = data.award_id
		self.MainAnim:StartLottery(award_index,function ()
			self.lock = false
			self.skip_btn.gameObject:SetActive(false)
			self:AddMyPMD(data.award_id) 
			self:TryToShow()
		end,self.MainAnim:GetMapping(#M.config.Award1))
	else
		self.lock = false
		HintPanel.Create(1,"服务器返回报错： "..data.result)
	end 
end

function C:GetAwardIndexInUI(award_id)
	local config_index
	for i = 1,#M.config.Award1 do
		if M.config.Award1[i].server_award_id == award_id then
			config_index = i
			break
		end
	end
	for i = 1,#map do
		if map[i] == config_index then
			return i
		end
	end
end
function C:on_model_task_change_msg(data)
	dump(data, "<color=red>----------任务改变-----------</color>")
	if data and data.id == M.task_id then
		--self.num_txt.text = data.now_total_process
		local b = basefunc.decode_task_award_status(data.award_get_status)
		b = basefunc.decode_all_task_award_status(b, data, 5)
		dump(b,"b----->")
		self:ReFreshProgress(data.now_total_process)
		self:ReFreshTaskButtons(b)
	end
end

function C:on_model_query_one_task_data_response(data)
	dump(data, "<color=red>----------任务信息获得-----------</color>")
	if data and data.id == M.task_id then
		--self.num_txt.text = data.now_total_process
		local b = basefunc.decode_task_award_status(data.award_get_status)
		b = basefunc.decode_all_task_award_status(b, data, 5)
		dump(b,"b----->")
		self:ReFreshProgress(data.now_total_process)
		self:ReFreshTaskButtons(b)
	end
end

function C:on_set_qfhl_lottery_success()
	self.beforeroot.gameObject:SetActive(false)
	if self.beforeChosePre then
		self.beforeChosePre:MyExit()
	end
	self.afterChoose.gameObject:SetActive(true)
	self:MyRefresh(true)
end
function C:UpDatePMD()
	if self.UpdatePMD then
		self.UpdatePMD:Stop()
	end

	local type = M.GetDataType()
	Network.SendRequest("query_fake_data", { data_type = type })
	self.UpdatePMD = Timer.New(
		function()
			--dump("<color=red>-------------------------------------------   query_fake_data-------------------------------------------------</color>")
			Network.SendRequest("query_fake_data", { data_type = type })
		end
	, 10, -1)
	self.UpdatePMD:Start()
end


function C:AddMyPMD(data)
	if table_is_null(data) then return end
	if not self.Award_Data then return end
	local _data_info = self.Award_Data.data
	local _data = data
	local type2str = {
		shop_gold_sum = "福卡",
		prop_50y = ""
	}
	for i = 1, #_data_info do
		local cur_data_info = self:GetConfigByServerID(_data[i])
		if cur_data_info ~= nil then
			local cur_data_pmd = {}
			cur_data_pmd["result"] = 0
			cur_data_pmd["player_name"] = MainModel.UserInfo.name
			cur_data_pmd["data_type"] = M.GetDataType()
			cur_data_pmd["ext_data"] = {}
			if cur_data_info.real == 1 then
				cur_data_pmd["ext_data"][#cur_data_pmd["ext_data"] + 1] = tostring(cur_data_info.text)
			else
				if _data_info[i].asset_type == "shop_gold_sum" then
					cur_data_pmd["ext_data"][#cur_data_pmd["ext_data"] + 1] = _data_info[i].value .. tostring(GameItemModel.GetItemToKey(_data_info[i].asset_type).name)
				else
					cur_data_pmd["ext_data"][#cur_data_pmd["ext_data"] + 1] = _data_info[i].value .. tostring(GameItemModel.GetItemToKey(_data_info[i].asset_type).name)
				end
			end
			self:AddPMD(0, cur_data_pmd)
		end
	end
end

function C:AddPMD(_, data)
	-- dump(data, "<color=red>PMD</color>")
	if not IsEquals(self.gameObject) then return end
	if data and data.result == 0 and data.data_type and data.data_type==M.GetDataType() then
		self.pmd_cont:AddPMDData(data)
	end
end

function C:GetLBBeiShu()
	local num = Act_Ty_GiftsManager.GetBuyGiftsNum("gift_ltlb")
	local config = {
		1.1,1.3,1.5
	}
	return config[num] or 1
end

function C:on_get_task_award_new_response(_,data)
	dump(data,"<color=white>+++++on_get_task_award_new_response+++++</color>")
	if not data then
		return 
	end

	if data.id ~= M.task_id then
		return 
	end
	--实物奖励
	 if data.award_list[1].award_name == M.GetAwardSwInfo(1).tex or data.award_list[1].award_name == M.GetAwardSwInfo(2).tex 
	 	or data.award_list[1].award_name ==M.GetAwardSwInfo(3).tex then
		local string1
	    string1 = "实物奖励请添加客服QQ4008882620领取。"
		local pre = HintCopyPanel.Create({desc=string1, isQQ=true,copy_value = "4008882620"})
		pre:SetCopyBtnText("复制QQ")
	end
end