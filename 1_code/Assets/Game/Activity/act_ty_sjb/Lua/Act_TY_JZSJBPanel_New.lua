-- 创建时间:2020-10-27
-- Panel:Act_TY_JZSJBPanel_New
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

Act_TY_JZSJBPanel_New = basefunc.class()
local C = Act_TY_JZSJBPanel_New
C.name = "Act_TY_JZSJBPanel_New"

local M = Act_TY_JZSJBManager

local HGList={
	[1] ="localpop_icon_1",
	[2] ="localpop_icon_2",
	[3] ="localpop_icon_3",
}

local image_item 
local image_reward_item
local image_ext_reward_item

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
	self.lister["act_jzsjb_base_info_get"] = basefunc.handler(self,self.act_jzsjb_base_info_get)
	self.lister["query_rank_data_response"] = basefunc.handler(self,self.on_query_rank_data_response)
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
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
    self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.award_config = M.GerCurAwardConfig()
	self.extra_award_config = M.GerCurExtraAwardConfig()
	image_item = M.GetCurItemImage(1)
	image_reward_item=M.GetCurItemImage(2)
	image_ext_reward_item=M.GetCurItemImage(3)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

end

function C:InitUI()
	EventTriggerListener.Get(self.ScrollView1.gameObject).onDown = basefunc.handler(self, self.OnBeginDrag)
	local config = M.GetConifg()
	if config.is_have_point == 1 then
		self.have_point = true
	else
		self.have_point = false
	end
	
	EventTriggerListener.Get(self.extra_btn.gameObject).onClick = basefunc.handler(self, self.OnExtraClick)
	if config.act_gift_key then
		self.go_btn.gameObject:SetActive(true)
	else
		self.go_btn.gameObject:SetActive(false)
	end
	EventTriggerListener.Get(self.my_jiacheng_tip_btn.gameObject).onClick = basefunc.handler(self, self.OnMyJiaChengClick)
	EventTriggerListener.Get(self.go_btn.gameObject).onClick = basefunc.handler(self, self.OnGoClick)
	self.goto_my_btn.gameObject:SetActive(config.gotoUI[1] ~= "nil")
	self.goto_my_btn.onClick:AddListener(function ()
		--GameManager.ExitSceneToFish3DGame()	
		--local id = GameFishing3DManager.GetTJGameID()
		-- GameManager.CommonGotoScence({gotoui = "game_Fishing3D",p_requset = {id = id,},goto_scene_parm={game_id = id}} , function()
		-- 	-- self:MyExit()
		-- 	Event.Brocast("exit_fish_scene")
		-- end)
		-- Event.Brocast("jump_to_index",config.gotoUI)
		GameManager.CommonGotoScence({gotoui = config.gotoUI[1]} , function()
			-- self:MyExit()
			Event.Brocast("exit_fish_scene")
		end)
	end)
	self.rule_btn.onClick:AddListener(function ()
		self:OpenHelpPanel()
	end)
	if config.show_time_type==1 then
		local sta_t = self:GetFortTime(config.s_time)
		local end_t = self:GetFortTime(config.e_time)
		self.cutdown_txt.text="活动时间：".. sta_t .."-".. end_t
	else
		local cutDownTime=M.GetActivityEndTime()
		self.cutdown_timer=CommonTimeManager.GetCutDownTimer(cutDownTime,self.cutdown_txt)
	end


	self:MyRefresh()
end
function C:GetFortTime(_time)
    return string.sub(os.date("%m月%d日%H:%M",_time),1,1) ~= "0" and os.date("%m月%d日%H:%M",_time) or string.sub(os.date("%m月%d日%H:%M",_time),2)
end
function C:ChangeUI()
	local path = M.GetCurSytleKey()
	-- dump(path,"<color=red>通用排行榜 path</color>")
	--背景
	SetTextureExtend(self.bg_img, path.."_xxsjb_bg_1")
	SetTextureExtend(self.I1_info1_img, path.."_xxsjb_bg_2")
	SetTextureExtend(self.I1_info2_img, path.."_xxsjb_bg_3")
	SetTextureExtend(self.top_img, path.."_xxsjb_bg_4")
	SetTextureExtend(self.btm_img, path.."_xxsjb_bg_5")
	-- SetTextureExtend(self.info1_img, path.."_xxsjb_bg_6")
	self.extra_img = self.extra_btn.transform:GetComponent("Image")
	SetTextureExtend(self.extra_img, path.."_phb_btn_ewjl")
end
function C:MyRefresh()
	self:ChangeUI()
	self:RefreshPanel()
	self.t3_txt.text = M.GetCurItemName(1).."总数"
	self.phb_img.sprite = GetTexture(image_item)
	self.my_img.sprite = GetTexture(image_item)
	self.my_award_img.sprite = GetTexture(image_reward_item)
	--self.my_extra_award_img.sprite = GetTexture(image_ext_reward_item)
	self.I_award_img.sprite = GetTexture(image_reward_item)
	--self.I_extra_award_img.sprite = GetTexture(image_ext_reward_item)
	self.goto_my_txt.text = "收集"..M.GetCurItemName(1)
	self.goto_txt.text = "收集"..M.GetCurItemName(1)
	self.my_name_txt.text = MainModel.UserInfo.name
end

function C:onMyInfoGet()
	local data = M.GetRankData(M.m_data.rank_type)
	if not data or data.result ~= 0 or not IsEquals(self.gameObject) then

		return
	end
	local json_data = json2lua(data.other_data)
	
	self.my_num_txt.text = data.score
	self.my_tip_name_txt.text = MainModel.UserInfo.name
	self.my_tip_all_txt.text = M.GetCurItemName(1) .. "总和:" .. data.score
	if table_is_null(json_data) then
		self.my_get_txt.text = 0
		self.my_tip_jiacheng_txt.text = "加成" .. M.GetCurItemName(1) .. ":0"
		self.my_tip_today_txt.text = "今日加成:0%"
	else
		self.my_get_txt.text = json_data.gun_rate
		self.my_tip_jiacheng_txt.text = "加成" .. M.GetCurItemName(1) .. ":" .. json_data.extra_score / M.GetCurTypeInfo()
		self.my_tip_today_txt.text = "今日加成:" .. json_data.extra_today_percent .. "%"
		self.my_part1.gameObject:SetActive(json_data.extra_today_percent == 10)
		self.my_part2.gameObject:SetActive(json_data.extra_today_percent == 30)
		self.my_part3.gameObject:SetActive(json_data.extra_today_percent == 50)
	end
	self.my_ranking_img.gameObject:SetActive(true)
	self.my_ranking_txt.text= " "
	if data.rank == -1 then
		self.my_ranking_img.gameObject:SetActive(false)
		self.my_rank2_txt.text="未上榜"		
		self.my_award_txt.text="- -"
		self.my_extra_award_txt.text = "- -"
	elseif data.rank < 4 then
		self.my_ranking_img.enabled = true
		self.my_ranking_img.sprite = GetTexture(HGList[data.rank])
		self.my_rank2_txt.text = " "
		self.my_ranking_img:SetNativeSize() 
	elseif data.rank <= 100 then 
		self.my_ranking_img.enabled = false
		self.my_ranking_txt.text = data.rank
		self.my_rank2_txt.text = " "
		self.my_ranking_img:SetNativeSize() 
	else
		self.my_ranking_img.gameObject:SetActive(false)
		self.my_rank2_txt.text = "未上榜"
	end 
		self:RefreshAward(data.rank)
end

function C:RefreshAward(rank)
	local data = M.GetRankData(M.m_data.rank_type)
	if not data or data.result ~= 0 or not IsEquals(self.gameObject) then
		return
	end
	for i=1,#self.award_config do
		if self.award_config[i].limit[1] <= rank and self.award_config[i].limit[2] >= rank then
			self.my_award_txt.text = self.award_config[i].award
			break
		end
	end
	local is_can = false
	for i=1,#self.extra_award_config do
		if self.extra_award_config[i].limit[1] <= rank and self.extra_award_config[i].limit[2] >= rank then
			for k=1,#self.extra_award_config[i].award do
				local pre = GameObject.Instantiate(self.my_ew,self.my_ew_node.transform)
				pre.gameObject:SetActive(true)
				local ui = {}
				LuaHelper.GeneratingVar(pre.transform, ui)
				ui.my_extra_award_txt.text = self.extra_award_config[i].award[k]
				ui.my_extra_award_hui_txt.text = self.extra_award_config[i].award[k]
				ui.my_extra_award_img.sprite = GetTexture(self.extra_award_config[i].award_img[k])
				if self.extra_award_config[i].need_num and (self.extra_award_config[i].need_num > tonumber(data.score)) then
					is_can = false
					ui.my_extra_award_txt.gameObject:SetActive(false)
					ui.my_extra_award_hui_txt.gameObject:SetActive(true)
				else
					is_can = true
					ui.my_extra_award_txt.gameObject:SetActive(true)
					ui.my_extra_award_hui_txt.gameObject:SetActive(false)
				end
				if is_can then
					ui.my_extra_award_img.color = Color.New(1,1,1,1)
				else
					ui.my_extra_award_img.color = Color.New(110/255,110/255,110/255,1)
				end
			end
			break
		end
	end
end

function C:onInfoGet(data)
	if data and data.result ==0 and IsEquals(self.gameObject) then 
		for i = 1, #data.rank_data do
			local json_data = json2lua(data.rank_data[i].other_data)
			local b = GameObject.Instantiate(self.info,self.content)
			local self_ = {}
			LuaHelper.GeneratingVar(b.transform, self_)
			b.gameObject:SetActive(true)
			self.info_cell = self.info_cell or {}
			self.info_cell[#self.info_cell + 1] = b
			self_.I_name_txt.text = data.rank_data[i].name
			for j=1,#self.award_config do
				if self.award_config[j].limit[1] <= data.rank_data[i].rank and self.award_config[j].limit[2] >= data.rank_data[i].rank then
					self_.I_award_txt.text = self.award_config[j].award
				end
			end
			for j=1,#self.extra_award_config do
				if self.extra_award_config[j].limit[1] <= data.rank_data[i].rank and self.extra_award_config[j].limit[2] >= data.rank_data[i].rank then
					for k=1,#self.extra_award_config[j].award do
						local pre = GameObject.Instantiate(self_.ew,self_.ew_node.transform)
						pre.gameObject:SetActive(true)
						local ui = {}
						LuaHelper.GeneratingVar(pre.transform, ui)
						ui.I_extra_award_txt.text = self.extra_award_config[j].award[k]
						ui.I_extra_award_hui_txt.text = self.extra_award_config[j].award[k]
						ui.I_extra_award_img.sprite = GetTexture(self.extra_award_config[j].award_img[k])
						if self.extra_award_config[j] and data.rank_data[i] and self.extra_award_config[j].need_num and data.rank_data[i].score and (self.extra_award_config[j].need_num > tonumber(data.rank_data[i].score)) then
							ui.I_extra_award_img.color = Color.New(110/255,110/255,110/255,1)
							ui.I_extra_award_txt.gameObject:SetActive(false)
							ui.I_extra_award_hui_txt.gameObject:SetActive(true)
						else
							ui.I_extra_award_img.color = Color.New(1,1,1,1)
							ui.I_extra_award_txt.gameObject:SetActive(true)
							ui.I_extra_award_hui_txt.gameObject:SetActive(false)
						end
					end
				end
			end
			self_.I_num_txt.text = data.rank_data[i].score
			self_.jiacheng_tip_btn.onClick:AddListener(function ()
				self_.jiacheng_tip.gameObject:SetActive(not self_.jiacheng_tip.gameObject.activeSelf)
			end)
			--根据玩家平台跳转不同场景
			self_.goto_btn.onClick:AddListener(
				function ()
					local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "cpl_cjj", is_on_hint = true}, "CheckCondition")
					local aa,bb = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "cpl_notcjj", is_on_hint = true}, "CheckCondition")
					if a and b then
				 		GameManager.GuideExitScene({gotoui="game_Eliminate", goto_scene_parm=true, enter_scene_call=function() 
				 				if not Network.SendRequest("xxl_enter_game", nil ,"正在进入") then
				                	HintPanel.Create(1, "网络异常")
				                	return
				            	end
				  		end})
					else
						if aa and bb then
							GameManager.GuideExitScene({gotoui = "game_Fishing3DHall"},function ()
								Event.Brocast("exit_fish_scene")
							end)
						else
							HintPanel.Create(1,"当前无法进行此操作")
						end
					end
				end
			)
			--self_.goto_btn.gameObject:SetActive(false)
			-- self_.num_txt.text = StringHelper.ToCash(json_data.bet_spend)
			self_.tip_name_txt.text = data.rank_data[i].name
			self_.tip_all_txt.text = M.GetCurItemName(1) .. "总和:" .. data.rank_data[i].score
			dump(json_data,"<color=yellow><size=15>++++++++++json_data++++++++++</size></color>")
			if not table_is_null(json_data) then
				self_.I_get_txt.text = json_data.gun_rate
				self_.tip_jiacheng_txt.text = "加成" .. M.GetCurItemName(1) .. ":" .. json_data.extra_score / M.GetCurTypeInfo()
				self_.tip_today_txt.text = "今日加成:" .. json_data.extra_today_percent .. "%"
				self_.part1.gameObject:SetActive(json_data.extra_today_percent == 10)
				self_.part2.gameObject:SetActive(json_data.extra_today_percent == 30)
				self_.part3.gameObject:SetActive(json_data.extra_today_percent == 50)
			else
				self_.tip_jiacheng_txt.text = "加成" .. M.GetCurItemName(1) .. ":0"
				self_.tip_today_txt.text = "今日加成:0%"
			end
			if data.rank_data[i].rank < 4 then
				self_.I_rank_img.enabled = true
				self_.I_rank_img.sprite = GetTexture(HGList[data.rank_data[i].rank])
				self_.I_rank_img:SetNativeSize()
				--self_.goto_btn.gameObject:SetActive(true)
			else
				self_.I_rank_img.enabled = false
				self_.I_rank_txt.text = data.rank_data[i].rank
			end
			-- if math.fmod(i,2) == 1 then
			-- 	self_["I"..curr_index.."_info1_img"].gameObject:SetActive(false)
			-- else
			-- 	self_["I"..curr_index.."_info1_img"].gameObject:SetActive(true)
			-- end
			if data.rank_data[i].player_id	== MainModel.UserInfo.user_id then
				--自己不一样
				self_.I1_info2_img.gameObject:SetActive(true)
			end
			if i == 20 then return end 			
		end
		if table_is_null(data.rank_data) then 
			LittleTips.Create("暂无新数据")
		end 
	end 
end

function C:act_jzsjb_base_info_get()	
	self:onMyInfoGet()
end

function C:on_query_rank_data_response(_,data)
	if data and data.result == 0 then
		if data.rank_type == M.m_data.rank_type then
			for i,v in ipairs(data.rank_data) do
				if self.have_point then 
					if math.floor(v.score/M.m_data.type_info) == (v.score/M.m_data.type_info) then
						v.score = v.score/M.m_data.type_info
					else
						v.score = string.format("%.1f", v.score/M.m_data.type_info)
					end
				else
					v.score = math.floor(v.score/M.m_data.type_info)
				end 
			end
			self:onInfoGet(data)
		end
	end
end

function C:RefreshPanel()
	self.page_index = 1
	--目前只需要有1页，20个
	destroyChildren(self.content)
	Network.SendRequest("query_rank_data",{rank_type = M.m_data.rank_type,page_index = self.page_index})
	M.QueryMyData(M.m_data.rank_type)
	self.node1.gameObject:SetActive(true)
	self.my_info.gameObject:SetActive(true)
end

function C:OnExtraClick()
	Act_TY_JZSJBEXTRAPanel.Create()
end

function C:OpenHelpPanel()
	local name = M.GetCurItemName()
	local str = {
		"1.活动时间：5月18日8:00-5月24日23:59:59。",
		"2.活动期间，在祈福好礼活动中抽奖所获得的"..name.."值进行排名，每抽奖1次获得10"..name.."。",
		"3.以获得的"..name.."总数进行排名，数量越多排名越靠前，数量相同时上榜时间越早排名越靠前。",
		"4.排行榜每180秒刷新一次。",
		"5.活动结束后，排行榜奖励通过邮件发放，请注意查收。"
	}
	local sta_t = self:GetStart_t()
    local end_t = self:GetEnd_t()
	str[1]= "1.活动时间：".. sta_t .."-".. end_t

	local str2 = str[1] 
	for i=2,#str do
		str2 = str2 .. "\n" .. str[i]
	end
	self.introduce_txt.text = str2
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:GetStart_t()
	local startTime=M.GetActivityStartTime()
    return string.sub(os.date("%m月%d日%H:%M",startTime),1,1) ~= "0" and os.date("%m月%d日%H:%M",startTime) or string.sub(os.date("%m月%d日%H:%M",startTime),2)
end

function C:GetEnd_t()
	local endTime=M.GetActivityEndTime()
    return string.sub(os.date("%m月%d日%H:%M:%S",endTime),1,1) ~= "0" and os.date("%m月%d日%H:%M:%S",endTime) or string.sub(os.date("%m月%d日%H:%M:%S",endTime),2)
end

function C:OnGoClick()
	local config = M.GetConifg()
	GameManager.CommonGotoScence({gotoui = "act_ty_gifts",goto_scene_parm = "panel",goto_type = config.act_gift_key})
end

function C:OnBeginDrag()
	if self.info_cell then
		for k,v in pairs(self.info_cell) do
			v.transform:Find("@I_num_txt/@jiacheng_tip").gameObject:SetActive(false)
		end
	end
end

function C:OnMyJiaChengClick()
	self.my_jiacheng_tip.gameObject:SetActive(not self.my_jiacheng_tip.gameObject.activeSelf)
end