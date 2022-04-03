local basefunc = require "Game/Common/basefunc"

YCS_CSSLPanel = basefunc.class()
local C = YCS_CSSLPanel
C.name = "YCS_CSSLPanel"
local config = 	YCS_CSSLManager.config
local M = YCS_CSSLManager

function C.Create(parent)
	return C.New(parent)
end

local offset_data = {
	{min = 0,max = 45.12},
	{min = 10.88,max = 59.61},
	{min = 6.88,max = 58.96},
	{min = 9.35,max = 59.52},
	{min = 13.26,max = 62.52},
}

local max_size_x = 70
local max_size_y = 21.08
function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["box_exchange_new_response"] = basefunc.handler(self,self.on_box_exchange_new_response)
	self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
	self.lister["model_query_one_task_data_response"] = basefunc.handler(self,self.on_model_query_one_task_data_response)
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
	self.lister["query_fake_data_response"] = basefunc.handler(self, self.AddPMD)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	if self.timer then 
		self.timer:Stop()
	end
	if self.update_pmd then
        self.update_pmd:Stop()
    end
	if self.pmd_cont then
		self.pmd_cont:MyExit()
		self.pmd_cont = nil
	end
	if self.Award_Data then
		self.Award_Data = nil
	end
	self:StopTimer()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)

	ExtPanel.ExtMsg(self)

	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	for i=1,5 do
		self["can"..i.."_get_btn"].gameObject:SetActive(false)
		self["mask"..i].gameObject:SetActive(false)
	end
	Network.SendRequest("query_one_task_data", {task_id = 1000320})
end


function C:InitUI()
	self.number = GameItemModel.GetItemCount("prop_fish_drop_act_1")
	local _callback = function (num,_type,is_merge_asset)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			local num_1 = (num or 1) * 50
			if self.number and self.number >=  num_1 then
				Network.SendRequest("box_exchange_new",{id = 77,num = num,is_merge_asset= is_merge_asset})
			elseif MainModel.UserInfo.shop_gold_sum  >= num_1 and self.number < num_1 then
				Network.SendRequest("box_exchange_new",{id = 78,num = num, is_merge_asset = is_merge_asset})
			else
				HintPanel.Create(1,"您的道具不足！")
			end 
		end


	self.go_btn.onClick:AddListener(
		function()
			local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "cpl_cjj", is_on_hint = true}, "CheckCondition")
			if a and b then	
				GameManager.GuideExitScene({gotoui = "game_MiniGame"},function ()
			   		Event.Brocast("exit_fish_scene")
			   	end)
			else
				GameManager.GuideExitScene({gotoui = "game_Fishing3DHall"},function ()
			   		Event.Brocast("exit_fish_scene")
			   	end)
			end
		end
	)
	self.lottery1_btn.onClick:AddListener(
		function()
			_callback(1,1,0)

		end
	)
	self.lottery10_btn.onClick:AddListener(
		function()
			_callback(10,2,1)
		end
	)
	self.show_list_btn.onClick:AddListener(
		function ()
			YCS_CSSLListPanel.Create()
		end
	)
	self.close_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	self.more_gift_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			YCS_CSSLMorePanel.Create()
		end
	)
	for i=1, 5 do
		self["can"..i.."_get_btn"].onClick:AddListener(
			function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				Network.SendRequest("get_task_award_new", {id = 1000320, award_progress_lv = i})
				-- if config.TaskAward[i].real == 1 then 
				-- 	RealAwardPanel.Create({image = config.TaskAward[i].img,text = config.TaskAward[i].text})
				-- end 
			end
		)
	end
	for i=1,6 do
		self["tip"..i.."_btn"].onClick:AddListener(
			function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				PointerEventListener.Get(self["tip"..i.."_btn"].gameObject).onDown = function ()
					self["tip"..i].gameObject:SetActive(true)
					self["tip"..i.."_txt"].text = config.tips[i].icon_txt
	    		end
   			 	PointerEventListener.Get(self["tip"..i.."_btn"].gameObject).onUp = function ()
	    			self["tip"..i].gameObject:SetActive(false)
	   			 end
   			end)
	end

	self.help_btn.onClick:AddListener(
		function ()
			self:OpenHelpPanel()
		end
	)
	self:MyRefresh()
	self.pmd_cont = CommonPMDManager.Create(self, self.CreatePMD ,{ parent = self.pmd_node, speed = 18, space_time = 10, start_pos = 1000 })
	self:UpdatePMD()
	self:StartTimer()
	CommonTimeManager.GetCutDownTimer(1614009599,self.remain_time_txt)
end

function C:MyRefresh()
	self.number = GameItemModel.GetItemCount("prop_fish_drop_act_1")

	if MainModel.UserInfo.shop_gold_sum  >= 50 and self.number < 50 then
		self.type1_txt.text = "消耗50福利券"		
	else
		self.type1_txt.text = "消耗50金元宝"		
	end

	if MainModel.UserInfo.shop_gold_sum >= 500 and self.number < 500 then
		self.type2_txt.text = "消耗500福利券"	
	else
		self.type2_txt.text = "消耗500金元宝"	
	end

	self.number_txt.text = self.number == 0 and  self.number or "x"..self.number
end

function C:CreatePMD(data)
	local obj = GameObject.Instantiate(self.pmd_item, self.pmd_node.transform)
	local temp_ui = {}
    LuaHelper.GeneratingVar(obj.transform, temp_ui)
    temp_ui.t1_txt.text = "恭喜" .. data.player_name .. "鸿运当头，抽中了" .. data.award_data .. "奖品！"
	obj.gameObject:SetActive(true)
	return obj
end

function C:on_box_exchange_new_response(_,data)
	dump(data,"<color=red>----------抽奖数据-----------</color>")
	if data.result == 0 then
		--for k,v in pairs(data.award_data) do
			self.caoshen_jingbi.gameObject:SetActive(true)
			local real_list = self:GetRealInList(data.award_data)
			dump(real_list,"<color=red>-------实物奖励------</color>")
			-- if self:IsAllRealPop(data.award_data,real_list) then 
			-- 	RealAwardPanel.Create(self:GetShowData(real_list))
			-- else
				-- self.call = function ()
				-- 	--if not table_is_null(real_list) then 
				-- 		MixAwardPopManager.Create(self:GetShowData(real_list),nil,2)
				-- 	--end
				-- end 
			-- end
			self:TryToShow()
			self:AddMyPMD(data.award_data)
		--end
	
	end 
end

function C:on_model_task_change_msg(data)
	dump(data,"<color=red>----------任务改变-----------</color>")
	if data and data.id == 1000320 then
		--self.num_txt.text = data.now_total_process
		local b = basefunc.decode_task_award_status(data.award_get_status)
		b = basefunc.decode_all_task_award_status(b, data, 5)
		self:ReFreshProgress(data.now_total_process)
		self:ReFreshTaskButtons(b)
		self.total_times_txt.text = "当前抽奖次数："..data.now_total_process
	end 
end

function C:on_model_query_one_task_data_response(data)
	dump(data,"<color=red>----------任务信息获得-----------</color>")
	if data and data.id == 1000320 then
		--self.num_txt.text = data.now_total_process
		local b = basefunc.decode_task_award_status(data.award_get_status)
		b = basefunc.decode_all_task_award_status(b, data, 5)
		self:ReFreshProgress(data.now_total_process)
		self:ReFreshTaskButtons(b)
		self.total_times_txt.text = "当前抽奖次数："..data.now_total_process
	end 
end
--在奖励列表里面获取实物奖励的ID
function C:GetRealInList(award_id)
	local r_list = {}
	local temp
	dump(award_id,"<color=red>pppppppppppppppp</color>")
	for i=1,#award_id do
		temp = self:GetConfigByServerID(award_id[i].award_id)
		if temp.real == 1 then 
			r_list[#r_list + 1] = temp
		end
	end
	return r_list
end
--根据ID获取配置信息
function C:GetConfigByServerID(server_award_id)
	for i=1,#config.Award do
		if config.Award[i].server_award_id == server_award_id then 
			return config.Award[i]
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

function C:OnAssetChange(data)
	dump(data,"<color=red>----奖励类型-----</color>")
	if data.change_type and (data.change_type == "box_exchange_active_award_77" or data.change_type == "box_exchange_active_award_78") and not table_is_null(data.data) then
		self.number = GameItemModel.GetItemCount("prop_fish_drop_act_1")
		self.number_txt.text = self.number

		self.Award_Data = data
		self.pmd_data = data
		--self:TryToShow()
		self:MyRefresh()
	end
end

function C:TryToShow()
	if self.Award_Data then--and self.call then
		--self.call() 
		Event.Brocast("AssetGet",self.Award_Data)
		self.Award_Data = nil
		--self.call = nil 
	end 
end

function C:ReFreshTaskButtons(list)
	for i=1,#list do
		if list[i] == 0 then
			self["can"..i.."_get_btn"].gameObject:SetActive(false)
			self["mask"..i].gameObject:SetActive(false)
		end
		if list[i] == 1 then
			self["can"..i.."_get_btn"].gameObject:SetActive(true)
			self["mask"..i].gameObject:SetActive(false)
		end
		if list[i] == 2 then
			self["can"..i.."_get_btn"].gameObject:SetActive(false)
			self["mask"..i].gameObject:SetActive(true)
		end
	end
end

function C:ReFreshProgress(total)
	local nowlv = 1
	while config.TaskAward[nowlv].need <= total and nowlv < 5 do
		nowlv = nowlv + 1
	end
	for i = 1, 5 do
		if i > nowlv then 
			self["p"..i].sizeDelta = {x = 0,y = max_size_y}
		end
		if i < nowlv then 
			self["p"..i].sizeDelta = {x = max_size_x,y = max_size_y}
		end
		if i == nowlv then 
			self["p"..i].sizeDelta = {x = self:GetProgressX(self:GetCurrPercentage(nowlv,total),offset_data[i]),y = max_size_y}
		end
	end
end

function C:GetCurrPercentage(nowlv,total)
	local lastLevelNeed = nowlv > 1 and config.TaskAward[nowlv - 1].need or 0
	return (total - lastLevelNeed)/(config.TaskAward[nowlv].need - lastLevelNeed)
end

function C:GetProgressX(percentage,o_d)
	return ((o_d.max - o_d.min) * percentage) + o_d.min
end

function C:OpenHelpPanel()
	local str
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "cpl_cjj", is_on_hint = true}, "CheckCondition")
	if a and b then
	 	str = config.DESCRIBE_TEXT_CJJ[1].text
	 	for i = 2, #config.DESCRIBE_TEXT_CJJ do
			str = str .. "\n" .. config.DESCRIBE_TEXT_CJJ[i].text
		end
 	else
		str = config.DESCRIBE_TEXT[1].text
		for i = 2, #config.DESCRIBE_TEXT do
			str = str .. "\n" .. config.DESCRIBE_TEXT[i].text
		end
	end
	
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform,"IllustratePanel_New")
end

function C:OnDestroy()
	self:MyExit()
end


function C:UpdatePMD()
    if self.update_pmd then
        self.update_pmd:Stop()
	end
	
    Network.SendRequest("query_fake_data", { data_type = "caishen_gift" })
    self.update_pmd = Timer.New(
        function()
        	dump(data,"<color=yellow><size=15>++++++++++query_fake_data++++++++++</size></color>")
			Network.SendRequest("query_fake_data", { data_type = "caishen_gift" })
		end
    , 20, -1)
    self.update_pmd:Start()
end

function C:AddMyPMD(data)
	dump(data,"<color=red>JJJJJJJJJJJJJ</color>")
    if table_is_null(data) then return end
    local _data_info = self.pmd_data
    local _data = data
    dump(_data_info,"<colo=red>FFFFFFFFFFFFFFF</color>")
    dump(_data)
    for i = 1, #_data do
		local index = M.GetAwardIndex(data[1].award_id)
		dump(index)
        if index then
            local cur_data_pmd = {}
            cur_data_pmd["result"] = 0
            cur_data_pmd["player_name"] = MainModel.UserInfo.name 
			cur_data_pmd["award_data"] = _data_info.data[1].value .. tostring(config.Award[index].text)
			cur_data_pmd["data_type"] = "caishen_gif"
            self:AddPMD(0, cur_data_pmd)
        end
    end
end

function C:AddPMD(_, data)
    dump(data, "<color=red>PMD</color>")
    if not IsEquals(self.gameObject) then return end
    if data and data.result == 0 then
    	if data.ext_data then
    		data.award_data = data.ext_data[1]
    	end
        self.pmd_cont:AddPMDData(data)
    end
end


function C:StartTimer()
	self:StopTimer()
	self.main_timer = Timer.New(
        function ()
        	if self.caoshen_jingbi.gameObject.activeSelf then
        		self.caoshen_jingbi.gameObject:SetActive(false)
    		end 
        end
    ,5,-1)
   
    self.main_timer:Start()

end

function C:StopTimer()
	if self.main_timer then
        self.main_timer:Stop()
        self.main_timer = nil
    end
end