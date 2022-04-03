-- 创建时间:2020-10-27
-- Panel:Act_TY_JZSJBPanel
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

Act_TY_JZSJBPanel = basefunc.class()
local C = Act_TY_JZSJBPanel
C.name = "Act_TY_JZSJBPanel"

local M = Act_TY_JZSJBManager

local HGList={
	[1] ="localpop_icon_1",
	[2] ="localpop_icon_2",
	[3] ="localpop_icon_3",
}

local image_item 

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
	image_item = M.GetCurItemImage()
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

end

function C:InitUI()
	self.goto_my_btn.onClick:AddListener(
		function ()
			local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "cpl_cjj", is_on_hint = true}, "CheckCondition")
			local aa,bb = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "cpl_notcjj", is_on_hint = true}, "CheckCondition")
			if a and b then
		  		GameManager.CommonGotoScence({gotoui="game_Eliminate"})
			else
				if aa and bb then
					GameManager.CommonGotoScence({gotoui = "game_Fishing3DHall"},function ()
						Event.Brocast("exit_fish_scene")
					end)
				else
					HintPanel.Create(1,"当前无法进行此操作")
				end
			end
		end
	)
	self:MyRefresh()
end
function C:ChangeUI()
	local path = M.GetCurSytleKey()
	dump(path,"<color=red>通用排行榜 path</color>")
	--背景
	SetTextureExtend(self.bg_img, path.."_xxsjb_bg_1")
	SetTextureExtend(self.I1_info1_img, path.."_xxsjb_bg_2")
	SetTextureExtend(self.I1_info2_img, path.."_xxsjb_bg_3")
	SetTextureExtend(self.top_img, path.."_xxsjb_bg_4")
	SetTextureExtend(self.btm_img, path.."_xxsjb_bg_5")
	SetTextureExtend(self.info1_img, path.."_xxsjb_bg_6")
end
function C:MyRefresh()
	self:ChangeUI()
	self:RefreshPanel()
	self.t3_txt.text = M.GetCurItemName().."总数"
	self.phb_img.sprite = GetTexture(image_item)
	self.my_img.sprite = GetTexture(image_item)
	self.goto_my_txt.text = "收集"..M.GetCurItemName()
	self.goto_txt.text = "收集"..M.GetCurItemName()
	self.my_name_txt.text = MainModel.UserInfo.name
end

function C:onMyInfoGet()
	local data = M.GetRankData(M.m_data.rank_type)
	dump(data,"<color=red>GetRankData</color>")
	if not data or data.result ~= 0 or not IsEquals(self.gameObject) then

		return
	end
	local json_data = json2lua(data.other_data)
	dump(json_data,"<color=red>sjb json_data</color>")
	
	self.my_num_txt.text = data.score
	if not json_data then
		self.my_get_txt.text = 0
	else
		self.my_get_txt.text = json_data.gun_rate
	end
	self.my_ranking_img.gameObject:SetActive(true)
	self.my_ranking_txt.text= " "
	if data.rank == -1 then
		self.my_ranking_img.gameObject:SetActive(false)
		self.my_rank2_txt.text="未上榜"		
		self.my_award_txt.text="- -"
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
	for i=1,#self.award_config do
		if self.award_config[i].limit[1] <= rank and self.award_config[i].limit[2] >= rank then
			self.my_award_txt.text = self.award_config[i].award
			break
		end
	end
end

function C:onInfoGet(data)
	if data and data.result ==0 and IsEquals(self.gameObject) then 
		for i = 1, #data.rank_data do
			local json_data = json2lua(data.rank_data[i].other_data)
			dump(json_data,"<color=red>other_data</color>")
			local b = GameObject.Instantiate(self.info,self.content)
			LuaHelper.GeneratingVar(b.transform, self)
			b.gameObject:SetActive(true)
			self.I_name_txt.text = data.rank_data[i].name
			for j=1,#self.award_config do
				if self.award_config[j].limit[1] <= data.rank_data[i].rank and self.award_config[j].limit[2] >= data.rank_data[i].rank then
					self.I_award_txt.text = self.award_config[j].award
				end
			end
			self.I_num_txt.text = data.rank_data[i].score
			--根据玩家平台跳转不同场景
			self.goto_btn.onClick:AddListener(
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
			self.goto_btn.gameObject:SetActive(false)
			-- self.num_txt.text = StringHelper.ToCash(json_data.bet_spend)
			if json_data then
				self.I_get_txt.text = json_data.gun_rate
			end
			if data.rank_data[i].rank < 4 then
				self.I_rank_img.enabled = true
				self.I_rank_img.sprite = GetTexture(HGList[data.rank_data[i].rank])
				self.I_rank_img:SetNativeSize()
				self.goto_btn.gameObject:SetActive(true)
			else
				self.I_rank_img.enabled = false
				self.I_rank_txt.text = data.rank_data[i].rank
			end
			-- if math.fmod(i,2) == 1 then
			-- 	self["I"..curr_index.."_info1_img"].gameObject:SetActive(false)
			-- else
			-- 	self["I"..curr_index.."_info1_img"].gameObject:SetActive(true)
			-- end
			if data.rank_data[i].player_id	== MainModel.UserInfo.user_id then
				--自己不一样
				self.I1_info2_img.gameObject:SetActive(true)
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
