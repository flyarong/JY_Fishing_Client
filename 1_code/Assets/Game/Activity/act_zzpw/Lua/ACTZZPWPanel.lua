-- 创建时间:2021-05-17
-- Panel:ACTZZPWPanel
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

ACTZZPWPanel = basefunc.class()
local C = ACTZZPWPanel
C.name = "ACTZZPWPanel"
local M = ACTZZPWManager

local instance 

function C.Create(parent, backcall)
	if not instance then
		instance = C.New(parent, backcall)
	end
	return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["query_fake_data_response"] = basefunc.handler(self, self.on_query_fake_data_response)
    self.lister["cjdb_add_fake_data"] = basefunc.handler(self, self.on_add_fake_data)

    -- self.lister["model_super_treasure_query_base_info_msg"] = basefunc.handler(self, self.on_model_super_treasure_query_base_info_msg)
    -- self.lister["model_super_treasure_use_dice_msg"] = basefunc.handler(self, self.on_model_super_treasure_use_dice_msg)

	self.lister["model_zhizhun_rank_get_data_msg"] = basefunc.handler(self, self.on_model_zhizhun_rank_get_data_msg)
	self.lister["model_zhizhun_rank_dice_msg"] = basefunc.handler(self, self.on_model_zhizhun_rank_dice_msg)

	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)

	self.lister["EnterForeGround"] = basefunc.handler(self, self.on_backgroundReturn_msg)
    self.lister["EnterBackGround"] = basefunc.handler(self, self.on_background_msg)
    self.lister["view_zzpy_jc_panel_close"] = basefunc.handler(self, self.on_view_zzpy_jc_panel_close)


    self.lister["model_zhizhun_exp_change_msg"] = basefunc.handler(self, self.on_model_zhizhun_exp_change_msg)
    self.lister["model_zhizhun_task_change_msg"] = basefunc.handler(self, self.on_model_zhizhun_task_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.pmd_pre then
		self.pmd_pre:MyExit()
		self.pmd_pre = nil
	end
	
	if self.pmd_t then
		self.pmd_t:Stop()
		self.pmd_t = nil
	end
	if self.cutdown_timer then
		self.cutdown_timer:Stop()
	end

	if self.jcRefreshTimer then
		self.jcRefreshTimer:Stop()
		self.jcRefreshTimer = nil
	end

	if self.pre then
		self.pre = nil
	end
	instance = nil
	self:RemoveListener()
	destroy(self.gameObject)
	if self.backcall then
		self.backcall()
	end
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent, backcall)
	self.backcall = backcall
	ExtPanel.ExtMsg(self)
	self.parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, self.parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.back_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if self.is_anim_runing then
        	LittleTips.Create("财神移动中...")
        	return
        end
		self:MyExit()
    end)
    self.ysz_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if self.is_anim_runing then
        	LittleTips.Create("财神移动中...")
        	return
        end
		self:OnYSZClick()
    end)
    self.help_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if self.is_anim_runing then
        	LittleTips.Create("财神移动中...")
        	return
        end
		self:OnHelpClick()
    end)
    self.AddGold_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnAddGoldClick()
    end)
    self.task_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnTaskClick()
    end)
    self.rank_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnRankClick()
    end)

    self.tzsz_anim = self.sz_anim:GetComponent("Animator")
    self.player_anim = self.player_node:GetComponent("Animator")
    self.rank_slider = self.Slider:GetComponent("Slider")

	self.cur_pos = 1

	self.cutdown_timer = CommonTimeManager.GetCutDownTimer(M.GetActEndtime(), self.djs_txt)

	self.pmd_pre = CommonPMDManager.Create(self, self.CreatePMD, {actvity_mode=1, start_pos=555, end_pos=-555, time_scale=1.5})
	self.pmd_t = Timer.New(function () 
		self:QueryPMD()
	end,5,-1)

	self:RefreshAsset()
	M.QueryBaseData()
end
function C:DelPathObj()
	if self.cur_path then
		for k,v in ipairs(self.cur_path) do
			v.pre:MyExit()
		end
	end
	self.cur_path = {}
end

function C:RefreshPath()
	self:DelPathObj()
	for i = 1, 26 do
		local data = {}
		data.pre = ACTZZPWPathPrefab.Create(self["pre_node" .. i], i, self.map_config[i])
		data.pos = data.pre:GetPos()
		self.cur_path[i] = data
	end
end

function C:MyRefresh()
	self.baseData = M.GetBaseData()
	self.map_config = M.GetMapConfigByGroup()

	self.cur_pos = self.baseData.position + 1

	self:RefreshPath()
	self:RefreshRank()
	self:RefreshTask()
	self:RefreshJcPool()
	self.sz_num_txt.text = "x" .. M.GetCurDiceNum()
	--self.player_node.localPosition = self.cur_path[self.cur_pos].pos
	self:SetPlayerNodePos(self.cur_pos)
	self.pmd_t:Start()
	self:QueryPMD()
	self.cur_path[self.cur_pos].pre:SetSelect(true)
end

function C:RefreshAsset()
	self.shop_gold_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	self.sz_num_txt.text = "x" .. M.GetCurDiceNum()
end

function C:SetPlayerNodePos(posIndex)
	if posIndex == 1 then
		self.player_node.localPosition = self.cur_path[self.cur_pos].pos - Vector3.New(0, 50, 0)
	else
		self.player_node.localPosition = self.cur_path[self.cur_pos].pos
	end
end

-- function C:on_model_super_treasure_query_base_info_msg(result)
-- 	if result == 0 then
-- 		self:MyRefresh()
-- 	else
-- 		HintPanel.ErrorMsg(result)
-- 	end
-- end

-- function C:on_model_super_treasure_use_dice_msg(data)
-- 	self.is_anim_runing = true
-- 	self.cur_pos = self.base_info.location + data.dot
-- 	if self.cur_pos > #self.cur_path then
-- 		self.cur_pos = self.cur_pos - #self.cur_path
-- 	end

-- 	local run = function ()
-- 		self.tzsz_anim:SetBool("sz"..data.dot, true)
-- 		self.tzsz_anim:Play("run", -1, 0)
-- 		self.move_seq = DoTweenSequence.Create()
-- 		self.move_seq:AppendInterval(1)
-- 		self.move_seq:OnKill(function ()
-- 			self.move_seq = nil
-- 			self:PlayMove()
-- 		end)
-- 	end	
-- 	if self.cur_pos ~= data.location then
-- 		LittleTips.Create("0点位置重置～")
-- 		self.move_seq = DoTweenSequence.Create()
-- 		self.move_seq:AppendInterval(0.5)
-- 		self.move_seq:OnKill(function ()
-- 			self.cur_path[self.base_info.location].pre:SetSelect(false)
-- 			self.player_node.localPosition = self.cur_path[1].pos
-- 			self.base_info.location = 1
-- 			self.cur_pos = data.location

-- 			self.move_seq = nil
-- 			run()
-- 		end)
-- 	else
-- 		run()
-- 	end
-- end

--基础数据获取返回
function C:on_model_zhizhun_rank_get_data_msg()
	if not self.is_anim_runing then
		self:MyRefresh()
	end
end

--摇骰子返回
function C:on_model_zhizhun_rank_dice_msg(data)
    dump(data,"<color=yellow>+++至尊排位:摇骰子结果 on_zhizhun_rank_dice+++</color>")
	self.is_anim_runing = true
	self.baseData = M.GetBaseData()
	self.dicData = M.GetDicData()
	self.dot = M.GetDotData(self.cur_pos - 1)
	local run = function ()
		self.tzsz_anim:SetBool("sz".. self.dot, true)
		self.tzsz_anim:Play("run", -1, 0)
		self.move_seq = DoTweenSequence.Create()
		self.move_seq:AppendInterval(1)
		self.move_seq:OnKill(function ()
			self.move_seq = nil
			self:PlayMove()
		end)
	end	
	run()
	
	-- if self.cur_pos ~= self.baseData.position + 1 then
	-- 	LittleTips.Create("0点位置重置～")
	-- 	self.move_seq = DoTweenSequence.Create()
	-- 	self.move_seq:AppendInterval(0.5)
	-- 	self.move_seq:OnKill(function ()
	-- 		self.cur_path[self.base_info.location].pre:SetSelect(false)
	-- 		self.player_node.localPosition = self.cur_path[1].pos
	-- 		self.base_info.location = 1
	-- 		self.cur_pos = data.location

	-- 		self.move_seq = nil
	-- 		run()
	-- 	end)
	-- else
	-- 	run()
	-- end

end

function C:OnAssetChange(data)
    if data.change_type
    	and (data.change_type == "zhizhun_dice_award")
    	and not table_is_null(data.data) then
        self.Award_Data = data
    end
    if data.change_type
    	and (data.change_type == "zhizhun_dice_take_pool")
    	and not table_is_null(data.data) then
        self.awardPoolData = data
    end

    self:RefreshAsset()
end

function C:on_backgroundReturn_msg()
	if self.is_anim_runing then
		self.cur_path[self.cur_pos].pre:SetSelect(false)
		self.cur_pos = self.baseData.position + 1
		--local endPos = self.cur_path[self.cur_pos].pos
		--self.player_node.transform.localPosition = endPos
		self:SetPlayerNodePos(self.cur_pos)
		if self.move_seq then
			self.move_seq = nil
		end
		if self.awardPoolData then
			Event.Brocast("AssetGet", self.awardPoolData)
			self.awardPoolData = nil
		end
		self:MoveFinish()
	end
end
function C:on_background_msg()

end

function C:on_view_zzpy_jc_panel_close()
	self:RefreshJcPool()
end

--段位和经验发生改变
function C:on_model_zhizhun_exp_change_msg()
	self.map_config = M.GetMapConfigByGroup()
	self:RefreshPath()
	self:RefreshRank()
	self:RefreshJcPool()
end

--任务信息发生改变
function C:on_model_zhizhun_task_change_msg()
	self:RefreshTask()
end

-- 跑马灯
function C:CreatePMD(data)
	-- dump(data, "<color=white> ++++++DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD</color>")
	local obj = GameObject.Instantiate(self.pmd, self.pmd_node.transform)
	local text = obj.transform:GetComponent("Text")
	-- text.text = "<color=#F364F8FF>恭喜【" .. data.player_name .. "】 在超级夺宝中获得 【<color=#F8F364FF>" .. data.ext_data[1] .. "</color>】奖励！</color>"
	text.text = "<color=#F364F8FF>" .. data.ext_data[1] .. "</color>"
	obj.gameObject:SetActive(true)
	return obj
end
function C:QueryPMD()
	self.pmd_count = self.pmd_count or 0
	self.pmd_count = self.pmd_count + 1
	-- local jc = 0
	-- if jc >= 100000 then
		if self.pmd_count % 2 == 0 then
			Network.SendRequest("query_fake_data", {data_type = "zhizhun_duanwei_up"})
		else
			Network.SendRequest("query_fake_data", {data_type = "zhizhun_take_award_pool"})
		end
	-- else
		-- Network.SendRequest("query_fake_data", {data_type = "yyyyy"})
	-- end
end
function C:on_query_fake_data_response(_, data)
	-- dump(data, "<color=white>+++++on_query_fake_data_response+++++</color>")
	if data.result == 0 and (data.data_type == "zhizhun_duanwei_up" or data.data_type == "zhizhun_take_award_pool") then
		self.pmd_pre:AddPMDData(data)
	end
end
function C:on_add_fake_data(data)
	self.pmd_pre:AddPMDData(data, true)	
end

function C:PlayMove()
	-- dump(self.baseData.position, "self.baseData.position")
	-- dump(self.cur_pos, "self.cur_pos")
	if self.baseData.position + 1 ~= self.cur_pos then
		self.cur_path[self.cur_pos].pre:SetSelect(false)
		local index = self.cur_pos + 1
		if index > #self.cur_path then
			index = 1
		end
		local endPos = self.cur_path[index].pos
		if index == 1 then
			endPos = self.cur_path[index].pos - Vector3.New(0, 50, 0)
		else
			endPos = self.cur_path[index].pos
		end

		self.player_anim:Play("run", -1, 0)
		self.move_seq = DoTweenSequence.Create()
		self.move_seq:AppendInterval(0.1)
		self.move_seq:Append(self.player_node:DOLocalMove(endPos, 0.2))
		self.move_seq:AppendInterval(0.2)
		self.move_seq:OnKill(function ()
			self.move_seq = nil
			self.cur_pos = index
			self:PlayMove()
		end)
	else
		self.move_seq = DoTweenSequence.Create()
		self.move_seq:AppendInterval(0.1)
		self.move_seq:OnKill(function ()
			self.move_seq = nil
			self:MoveFinish()
		end)
	end
end

function C:MoveFinish()
	self.is_anim_runing = false
	local data = self.cur_path[self.cur_pos]

	self.cur_path[self.cur_pos].pre:SetSelect(true)

	if self.Award_Data then
		Event.Brocast("AssetGet", self.Award_Data)
		self.Award_Data = nil
	end

	if self.dicData.new_round == 1 then
		ACTZZPWJCPanel.Create(self.awardPoolData)
	else
		self:RefreshJcPool(true)
	end
end

function C:OnYSZClick()
	local num = M.GetCurDiceNum()
	if num > 0 then
		dump("<color=white>摇骰子</color>")
		Network.SendRequest("zhizhun_rank_dice")
	else
		local pre = HintPanel.Create(1,"骰子数量不足,完成任务可获得更多骰子!",function ()
			ACTZZPWTaskPanel.Create()
		end)
		pre:SetButtonText(nil,"查看更多任务")
	end
end

function C:OnHelpClick()
	ACTZZPWHelpPrefab.Create()
end

function C:OnAddGoldClick(go)
	PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
end


function C:OnTaskClick()
	ACTZZPWTaskPanel.Create()
end

function C:RefreshTask()
	local config = M.GetCurTaskConfig()
	local task_config = M.GetTaskConfig()
	for i=1,#config.task_group do
		local data = GameTaskModel.GetTaskDataByID(task_config[config.task_group[i]].task_id)
		if data then
		  	if data.award_status == 0 or i == #config.task_group then
				if task_config[config.task_group[i]].is_cz then
					self.task_txt.text = task_config[config.task_group[i]].task_desc .. "(" .. data.now_process/100 .. "/" .. data.need_process/100 .. ")"
				else
					self.task_txt.text = task_config[config.task_group[i]].task_desc .. "(" .. data.now_process .. "/" .. data.need_process .. ")"
				end
				self.award_txt.text = "+" .. task_config[config.task_group[i]].award[1] .. "  点数+" .. task_config[config.task_group[i]].award[2]
				break
			end
		end
	end
end

function C:OnRankClick()
	ACTZZPWRankPanel.Create()
end

function C:RefreshRank()
	local cur_num = M.GetCurScore()
	local need_num = M.GetCurNeedScore()
	self.rank_slider.value = cur_num / need_num
	local cur_rank = M.GetCurRank()
	local tab = {"zzpw_icon_qt","zzpw_icon_by","zzpw_icon_hj","zzpw_icon_bj","zzpw_icon_zs","zzpw_icon_zz"}
	local index1 = math.ceil(cur_rank / 3)
	local index2 = cur_rank % 3
	if index2 == 0 then
		index2 = 3
	end
	self.xx_node.gameObject:SetActive(cur_rank ~= 16)
	self.rank_img.sprite = GetTexture(tab[index1])
	for i=1,3 do
		self["xx" .. i].gameObject:SetActive(false)
	end
	for i=1,index2 do
		self["xx" .. i].gameObject:SetActive(true)
	end
end

function C:RefreshJcPool(isMoveFinish)
	local curNum = tonumber(self.jc_txt.text)
	local endNum = M.GetCurJC()
	local changeNum = endNum - curNum
	self.jcRefreshTimer = Timer.New(function()
		curNum = curNum + changeNum / 25
		self.jc_txt.text = curNum
		if curNum >= endNum * 0.99 then
			curNum = endNum
			self.jc_txt.text = M.GetCurJC()
			if self.jcRefreshTimer then
				self.jcRefreshTimer:Stop()
				self.jcRefreshTimer = nil
			end
		end
	end, 0.02, -1)

	if changeNum > 0 and isMoveFinish then
		local data = {data = {[1] = {} }}
		data.data[1].desc = "" 
		data.data[1].image = "zzpw_icon_jcsj" 
		data.data[1].name = "奖池提升" 
		Event.Brocast("AssetGet", data)
	end
	self.jcRefreshTimer:Start()
end