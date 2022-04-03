-- 创建时间:2021-02-26
-- Panel:SGXXL_Tower_ClimbingPanel
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

SGXXL_Tower_ClimbingPanel = basefunc.class()
local C = SGXXL_Tower_ClimbingPanel
C.name = "SGXXL_Tower_ClimbingPanel"
local M = SGXXL_Tower_ClimbingManager

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
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["sgxxl_tower_climbing_cur_task_data_is_queried"] = basefunc.handler(self,self.on_sgxxl_tower_climbing_cur_task_data_is_queried)
    self.lister["sgxxl_tower_climbing_on_auto_response"] = basefunc.handler(self,self.on_sgxxl_tower_climbing_on_auto_response)
    self.lister["sgxxl_tower_climbing_cur_task_data_is_change"] = basefunc.handler(self,self.on_sgxxl_tower_climbing_cur_task_data_is_change)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:ClearAwardPre()
	self:ClearTaskIcon()
	self:ClearBXHuxi()
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
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.slider = self.Slider.transform:GetComponent("Slider")

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
	EventTriggerListener.Get(self.phb_btn.gameObject).onClick = basefunc.handler(self, self.OnPHBClick)
	EventTriggerListener.Get(self.wh_btn.gameObject).onClick = basefunc.handler(self, self.OnWHClick)
	EventTriggerListener.Get(self.auto_btn.gameObject).onClick = basefunc.handler(self, self.OnAutoClick)
	self.bx1_btn.onClick:AddListener(function ()
		self:OnBXClick(1)
	end)
	self.bx2_btn.onClick:AddListener(function ()
		self:OnBXClick(2)
	end)
	self.bx3_btn.onClick:AddListener(function ()
		self:OnBXClick(3)
	end)
	
	M.QueryCurLayerTaskId()
end

function C:MyRefresh()
	self:RefreshUI()
	self:RefreshLayerBX()
	self:RefreshAutoButton()
end

function C:OnBackClick()
	self:MyExit()
end

function C:OnPHBClick()
	self.phb_pre = BY3DPHBGamePanel.Create()
	self.phb_pre:Selet(3)--默认选中水果消消乐爬塔榜
end

function C:RefreshLayerBX()
	self:ClearBXHuxi()
	local data = GameTaskModel.GetTaskDataByID(M.layer_task_id)
	--[[if M.GetLastLayerTaskData() then
		data = M.GetLastLayerTaskData()
	end--]]
	local b = basefunc.decode_task_award_status(data.award_get_status)
	b = basefunc.decode_all_task_award_status(b, data, 3)
	for i=1,#b do
		if b[i] == 0 then
			if IsEquals(self["bx"..i.."_btn"]) then
				self["bx"..i.."_btn"].transform:GetComponent("Image").sprite = GetTexture("xxlpt_icon_bx"..i)
				self["bx"..i.."_btn"].transform:Find("xing").gameObject:SetActive(false)
			end
		elseif b[i] == 1 then
			if IsEquals(self["bx"..i.."_btn"]) then
				self.bx_huxi_cell[#self.bx_huxi_cell + 1] = CommonHuxiAnim.Start(self["bx"..i.."_btn"].gameObject)
				self["bx"..i.."_btn"].transform:GetComponent("Image").sprite = GetTexture("xxlpt_icon_bx"..i)
				self["bx"..i.."_btn"].transform:Find("xing").gameObject:SetActive(true)
			end
		elseif b[i] == 2 then
			if IsEquals(self["bx"..i.."_btn"]) then
				self["bx"..i.."_btn"].transform:GetComponent("Image").sprite = GetTexture("xxlcg_icon_bx"..i)
				self["bx"..i.."_btn"].transform:Find("xing").gameObject:SetActive(false)
			end
		end
	end
end

function C:ClearBXHuxi()
	if self.bx_huxi_cell then
		for k,v in pairs(self.bx_huxi_cell) do
			CommonHuxiAnim.Stop(v)
		end
	end
	self.bx_huxi_cell = {}
end

function C:OnBXClick(level)
	local data = GameTaskModel.GetTaskDataByID(M.layer_task_id)
	--[[if M.GetLastLayerTaskData() then
		data = M.GetLastLayerTaskData()
	end--]]
	local b = basefunc.decode_task_award_status(data.award_get_status)
	b = basefunc.decode_all_task_award_status(b, data, 3)
	for i=1,#b do
		if i == level then
			if b[i] == 0 then
				LittleTips.Create(M.layer_task_award[level])
			elseif b[i] == 1 then
				local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="sgxxl_tower_box", is_on_hint = false}, "CheckCondition")
				if a and b then
					M.GetLayerTaskAward(level)
				end
			elseif b[i] == 2 then
				--已领取
			end
		end
	end
end

function C:OnWHClick()
	SGXXL_Tower_ClimbingHelpPanel.Create()
end

function C:RefreshUI()
	local config = M.GetCurTaskConfig()
	if M.GetLastTaskCfg() then
		config = M.GetLastTaskCfg()
	end
	local data = M.GetCurTaskData()
	if M.GetLastTaskData() then
		data = M.GetLastTaskData()
	end
	if not data.other then
		local other = basefunc.parse_activity_data(data.other_data_str)
	    data.other = other
	end
	if IsEquals(self.layer_txt) then
		self.layer_txt.text = "第".. M.GetCurLayer() .."关"
	end
	if IsEquals(self.task_desc_txt) then
		self.task_desc_txt.text = config.text
	end
	if IsEquals(self.ms_txt) then
		self.ms_txt.text = "第".. M.GetCurLayer() .."关奖励"
	end
	self:ClearTaskIcon()
	if data.award_status == 1 then
		M.SetIsShow("panel",true)
	end
	dump(data,"<color=green><size=15>++++++++++data++++++++++</size></color>")
	dump(config,"<color=green><size=15>++++++++++config++++++++++</size></color>")
	if IsEquals(self.icon_node) and IsEquals(self.icon) then
		for i=1,#config.task_icon do
			local pre = GameObject.Instantiate(self.icon,self.icon_node.transform)
			pre.gameObject:SetActive(true)
			pre.transform:Find("icon_img").gameObject:GetComponent("Image").sprite = GetTexture(config.task_icon[i])
			pre.transform:Find("need_txt").gameObject:SetActive(false)
			pre.transform:Find("gou").gameObject:SetActive(false)
			if config.limit_num[i] ~= -1 then
				if table_is_null(data.other) then
					if data.award_status == 1 then
						pre.transform:Find("gou").gameObject:SetActive(true)
					else
						pre.transform:Find("need_txt").gameObject:SetActive(true)
						pre.transform:Find("need_txt").gameObject:GetComponent("Text").text = config.limit_num[i]
					end
				else
					for k,v in pairs(data.other) do
						pre.transform:Find("need_txt").gameObject:SetActive(true)
						if k == M.index_map[tonumber(string.sub(config.task_icon[i],-1))] then
							local num = config.limit_num[i] - data.other[M.index_map[tonumber(string.sub(config.task_icon[i],-1))]]		
							pre.transform:Find("need_txt").gameObject:GetComponent("Text").text = num
							pre.transform:Find("need_txt").gameObject:SetActive(num > 0)
							pre.transform:Find("gou").gameObject:SetActive(num <= 0)
							--dump(data,"<color=yellow><size=15>+++++++++6666666666+data++++++++++</size></color>")
							--dump(data.other[M.index_map[string.sub(config.task_icon[i],-1)]],"<color=yellow><size=15>+++++++++77777777+data++++++++++</size></color>")
							--dump(config.limit_num[i],"<color=yellow><size=15>++++++++++8888888config.limit_num[i]++++++++++</size></color>")
							--dump(num,"<color=yellow><size=15>++9999999999999++++++++data++++++++++</size></color>")
							break
						else
							pre.transform:Find("need_txt").gameObject:GetComponent("Text").text = config.limit_num[i]
						end
					end
				end
			end
			self.task_icon_cell[#self.task_icon_cell + 1] = pre
		end
	end
	self:ClearAwardPre()
	if IsEquals(self.award_node) and IsEquals(self.award) then
		for i=1,#config.award_img do
			local pre = GameObject.Instantiate(self.award,self.award_node.transform)
			pre.gameObject:SetActive(true)
			pre.transform:Find("award_img").gameObject:GetComponent("Image").sprite = GetTexture(config.award_img[i])
			pre.transform:Find("award_txt").gameObject:GetComponent("Text").text = config.award_txt[i]
			if data.award_status == 1 then
				pre.transform:Find("@tx").gameObject:SetActive(true)
			else
				pre.transform:Find("@tx").gameObject:SetActive(false)
			end
			local btn = pre.transform:Find("get_btn").gameObject:GetComponent("Button")
			btn.onClick:AddListener(function ()
				if data.award_status == 1 then
					M.GetAward()
				end
			end)
			self.award_cell[#self.award_cell + 1] = pre
		end
	end
	if IsEquals(self.slider) then
		self.slider.value = M.GetCurLayer()/80
	end
end

function C:ClearTaskIcon()
	if self.task_icon_cell then
		for k,v in pairs(self.task_icon_cell) do
			destroy(v.gameObject)
		end
	end
	self.task_icon_cell = {}
end

function C:ClearAwardPre()
	if self.award_cell then
		for k,v in pairs(self.award_cell) do
			destroy(v.gameObject)
		end
	end
	self.award_cell = {}
end

function C:OnAutoClick()
	if MainModel.UserInfo.vip_level >= 2 then
		M.SetAuto()
	else
		LittleTips.Create("Vip2及以上可开启自动领奖")
	end
end

function C:RefreshAutoButton()
	if IsEquals(self.gou) then
		self.gou.gameObject:SetActive(M.GetAuto())
	end
end

function C:on_sgxxl_tower_climbing_on_auto_response()
	self:RefreshAutoButton()
end

function C:on_sgxxl_tower_climbing_cur_task_data_is_queried()
	self:MyRefresh()
end

function C:on_sgxxl_tower_climbing_cur_task_data_is_change()
	if M.GetIsShow("panel") then
		--动画
		M.SetIsShow("panel",false)
		self.particle.gameObject:SetActive(true)
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(2)
		seq:OnForceKill(function ()
			if IsEquals(self.particle) then
				self.particle.gameObject:SetActive(false)
			end
			self:MyRefresh()
		end)
	else
		self:MyRefresh()
	end
end
