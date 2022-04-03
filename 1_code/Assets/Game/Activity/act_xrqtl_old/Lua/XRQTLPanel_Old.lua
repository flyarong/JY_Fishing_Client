-- 创建时间:2020-01-15
-- Panel:XRQTLPanel_Old
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

XRQTLPanel_Old = basefunc.class()
local C = XRQTLPanel_Old
C.name = "XRQTLPanel_Old"
local config = XRQTLManager_Old.config
local M = XRQTLManager_Old
local Chinese = {"一","二","三","四","五","六","七","八","九","十","零"}
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
	self.lister["act_xrqtl_query_model_msg"] = basefunc.handler(self,self.MyRefresh)
	self.lister["global_hint_state_set_msg"] = basefunc.handler(self,self.on_global_hint_state_set_msg)
	self.lister["XRQTL_BX_Show_msg"] = basefunc.handler(self,self.on_XRQTL_BX_Show_msg)
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
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent,backcall)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.backcall = backcall
	LuaHelper.GeneratingVar(self.transform, self)
	self.btn_image = self.get_btn.gameObject.transform:GetComponent("Image")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.close_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:MyExit()
	end)

	local temp_ui = {}
	self.award_items = {}
	for i=1,#config.Info do
		local b = GameObject.Instantiate(self.award_item,self["node_" .. i])
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform, temp_ui)
		temp_ui.award_txt.text = config.Info[i].task_award_text
		temp_ui.award_day_txt.text = "第"..Chinese[i].."天"
		temp_ui.award_img.sprite = GetTexture(config.Info[i].task_award_image)
		local btn = temp_ui.bg2_img.transform:GetComponent("Button")
		btn.onClick:AddListener(function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:OnGetClick()
		end)
		
		temp_ui.bg2_img.gameObject:SetActive(false)
		self.award_items[i] = b
	end
	M.QueryData(true)
end

function C:MyRefresh()
	local temp_ui = {}
	local d = M.GetDayIndex()
	self.day_txt.text = "第"..Chinese[d].."天"
	self.get_btn.onClick:RemoveAllListeners()
	local task_data = M.GetCurrTaskData()
	dump(task_data,"<color=red>新人七天乐任务数据=====</color>")
	if d <= 7 and task_data then

		if task_data.award_status == 2 then
			self:RefreshTomorrow(true)
		else
			self:RefreshTomorrow(false)
		end

		self.tips_txt.text = config.Info[d].task_info
		local full_size_x = 694.32
		local full_size_y = 38
		local lgh = full_size_x * task_data.now_process/task_data.need_process
		if task_data.id == 21140 then
			self.p_txt.text = (task_data.now_process/100).."/"..(task_data.need_process/100)
		else
			self.p_txt.text = task_data.now_process.."/"..task_data.need_process
		end
		self.p_lengh.transform.sizeDelta = {
			x = lgh > full_size_x and  full_size_x or lgh,
			y = full_size_y
		}
		
		self.liuguang.gameObject:SetActive(false)
		if task_data.award_status == 1 then
			self.get_txt.text = "领 取"
			self.btn_image.sprite = GetTexture("ty_btn_huang1")
			self.liuguang.gameObject:SetActive(true)
			self.get_txt.gameObject:GetComponent("Outline").effectColor = Color.New(149/255,77/255,33/255,255)
			self.get_btn.onClick:AddListener(
				function ()
					ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
					self:OnGetClick()
				end
			)
		elseif task_data.award_status == 2 then 
			self.get_txt.text = "已领取"
			self.btn_image.sprite = GetTexture("ty_btn_ywc")
			self.get_txt.gameObject:GetComponent("Outline").effectColor = Color.New(89/255,91/255,94/255,255)
		else
			self.get_txt.text = "前 往"
			self.btn_image.sprite = GetTexture("ty_btn_huang1")
			self.get_txt.gameObject:GetComponent("Outline").effectColor = Color.New(149/255,77/255,33/255,255)
			self.get_btn.onClick:AddListener(
				function ()
					if d == 2 then
						--跳转到活动栏3元福利礼包
						local pre = GameManager.GuideExitScene({gotoui = "sys_act_base",goto_scene_parm = "panel",goto_type = "normal"}, function ()
				            self:MyExit()
				        end)
				        pre:jump_to_index("gift_one_yuan")
					elseif d == 6 then
						local gotoparm = {gotoui = "game_MiniGame"}
						GameManager.GuideExitScene(gotoparm, function ()
				            self:MyExit()
				        end)
					elseif d == 7 then
						PayPanel.Create("jing_bi")
						self:MyExit()
					else
						local gotoparm = {gotoui = "game_Fishing3DHall"}
						GameManager.GuideExitScene(gotoparm, function ()
				            self:MyExit()
				        end)
					end	        
				end
			)
		end
		for i=1,#config.Info do
			local task_data = M.GetTaskDataByDay(i)
			-- dump(task_data,"任务")
			LuaHelper.GeneratingVar(self.award_items[i],temp_ui)
			if task_data then
				if i < d then 
					if task_data.award_status == 2 then 
						temp_ui.lq.gameObject:SetActive(true)
					else
						temp_ui.gq.gameObject:SetActive(true)
					end
				elseif  i == d then 
					if task_data.award_status == 2 then 
						temp_ui.lq.gameObject:SetActive(true)
						temp_ui.bg2_img.gameObject:SetActive(false)
					elseif task_data.award_status == 1 then 
						temp_ui.lq.gameObject:SetActive(false)
						temp_ui.bg2_img.gameObject:SetActive(true)
					else
						temp_ui.bg2_img.gameObject:SetActive(true)
					end
				elseif d > 1 then
					
				end
			end 
		end
	end
end

function C:on_global_hint_state_set_msg(data)
	if data and data.gotoui == M.key and IsEquals(self.gameObject) then 
		self:MyRefresh()
	end 
end

function C:on_XRQTL_BX_Show_msg()
	self:RefreshTomorrow(true)
end

function C:OnGetClick()
	local task_data = M.GetCurrTaskData()
	if task_data and task_data.award_status == 1 then
		Network.SendRequest("get_task_award", {id = task_data.id}, "")
	end
end

function C:RefreshTomorrow(bool)
	if bool then
		local ii = M.GetDayIndex()+1
		if M.config.Info[ii] then
			self.Tomorrow.gameObject:SetActive(true)
			self.Tomorrow_txt.text = M.config.Info[ii].task_award_text
			self.Tomorrow_img.sprite = GetTexture(M.config.Info[ii].task_award_image)
			self.tom.gameObject:SetActive(true)
		end
	else
		local ii = M.GetDayIndex()
		if M.config.Info[ii] then
			self.Tomorrow.gameObject:SetActive(true)
			self.Tomorrow_txt.text = M.config.Info[ii].task_award_text
			self.Tomorrow_img.sprite = GetTexture(M.config.Info[ii].task_award_image)
			self.tom.gameObject:SetActive(false)
		end
	end
end