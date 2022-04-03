-- 创建时间:2021-01-27
-- Panel:Act_048_XNSMTPanel
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

Act_048_XNSMTPanel = basefunc.class()
local M = Act_048_XNSMTManager
local C = Act_048_XNSMTPanel
C.name = "Act_048_XNSMTPanel"

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
	self.lister["model_xnsmt_collect_refresh"] = basefunc.handler(self,self.on_model_xnsmt_collect_refresh)
	self.lister["model_xnsmt_task_refresh"] = basefunc.handler(self,self.on_model_xnsmt_task_refresh)
    self.lister["query_fake_data_response"] = basefunc.handler(self, self.AddPMD)
    self.lister["UpdateHallShareRedHint"] = basefunc.handler(self, self.on_UpdateHallShareRedHint)
	self.lister["model_xnsmt_share_refresh"] = basefunc.handler(self, self.on_model_xnsmt_share_refresh)
	self.lister["box_exchange_response"] = basefunc.handler(self, self.on_box_exchange_response)
	self.lister["AssetChange"] = basefunc.handler(self, self.on_asset_change)
	self.lister["get_task_award_new_response"] = basefunc.handler(self,self.on_get_task_award_new_response)
	
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.pmd_cont then
		self.pmd_cont:MyExit()
		self.pmd_cont = nil
	end
	self:RemoveListener()
	if self.LTTipsPrefab then
		self.LTTipsPrefab:MyExit()
		self.LTTipsPrefab = nil
	end
	if self.award_show_data then
        Event.Brocast("AssetGet", self.award_show_data)
        self.award_show_data = nil
    end

	if self.update_pmd then
        self.update_pmd:Stop()
    end
    if self.update_pmd_0 then
		self.update_pmd_0:Stop()
	end
	if self.delay_timer then
		self.delay_timer:Stop()
		self.delay_timer = nil
	end
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
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	self:AddMsgListener()
	self:InitCfg()
	self:InitUI()
end

function C:InitCfg()
	self.tasks_cfg = M.GetTaskCfg()
	self.lottery_rds_cfg = M.GetLotteryRdCfg()
	self.questions_cfg = M.GetQuestionCfg()
	self.collect_rds_cfg = M.GetCollectRdCfg()

    M.QueryCollectTaskData()
    M.QueryTaskData()
end

function C:UpdateTaskData()
	self.task_data = M.GetTaskData()
end

function C:UpdateCollectTaskData()
	self.collect_data = M.GetCollectTaskData()
end

function C:InitUI()
	self:InitLotteryUI()
	self:InitTaskUI()
	self:InitCollectRdUI()
	self:InitZhiZhenUI()
	self:MyRefresh()
	self:RefreshTip()
	self.back_btn.onClick:AddListener(function ()
		self:MyExit()
	end)

	self.share_btn.onClick:AddListener(function ()
		self:OpenSharePanel()
	end)

	self.rule_btn.onClick:AddListener(function ()
		self:OpenRulePanel()
	end)
	CommonTimeManager.GetCutDownTimer(M.end_time,self.remain_time_txt)
    self.pmd_cont = CommonPMDManager.Create(self, self.CreatePMD ,{ parent = self.pmd_node, speed = 18, space_time = 10, start_pos = 1000 ,dotweenLayerKey = "xnsmt"})
	self:UpdatePMD()
end

function C:CreatePMD(data)
	local obj = GameObject.Instantiate(self.pmd_item, self.pmd_node.transform)
	local temp_ui = {}
    LuaHelper.GeneratingVar(obj.transform, temp_ui)
    temp_ui.t1_txt.text = "恭喜玩家" .. data.player_name .. "获得" .. data.award_data .. "，离飞天茅台更近一步！"
	obj.gameObject:SetActive(true)
	return obj
end

function C:InitLotteryUI()
	self.lottery_rd_ui = self:InitListUI(self.lottery_content.transform)
	local init_lottery_rd_ui = function (item,item_ui,index)
		local item_cfg = self.lottery_rds_cfg[index]
		item_ui.l_item_img.sprite = GetTexture(item_cfg.icon)
		item_ui.l_item_txt.text = item_cfg.name
		item.transform:GetComponent("Button").onClick:AddListener(function ()
			self.LTTipsPrefab = LTTipsPrefab.Show2(item.transform,item_cfg.tips[1],item_cfg.tips[2])
		end)
	end
	self:InitLisItemUI(self.lottery_rd_ui,init_lottery_rd_ui)
	self.lottery_btn.onClick:AddListener(function ()
		if not self.is_during_anim then
			self:Lottery()
		else
			LittleTips.Create("正在抽奖...")
		end
	end)
end

function C:InitTaskUI()
	self.task_lis_ui = {}
	for i = 1,#self.tasks_cfg do
		local cur_task = newObject("Act_048_XNSMTTaskItem", self.content)
		cur_task.transform:Find("goto_btn"):GetComponent("Button").onClick:AddListener(function ()
			self:OpenFAQPanel()
		end)
		self.task_lis_ui[i] = cur_task.transform
	end
end

function C:InitCollectRdUI()
	self.collect_lis_ui = self:InitListUI(self.collect_rds.transform)
	local init_collect_ui =  function (item,item_ui,index)
		item_ui.rd_icon_img.sprite = GetTexture(self.collect_rds_cfg[index].icon)
		item_ui.rd_num_txt.text = self.collect_rds_cfg[index].reward
	end
	self:InitLisItemUI(self.collect_lis_ui,init_collect_ui)
end

function C:InitListUI(items_trans)
	local re_list = {}
	for i = 1, items_trans.childCount do
		local child = items_trans:GetChild(i - 1)
		re_list[#re_list + 1] = child
	end
	return re_list
end

function C:InitLisItemUI(item_lis , func)
	for i = 1, #item_lis do
		local item = item_lis[i]
		local item_ui = {}
		LuaHelper.GeneratingVar(item,item_ui)
		if func then
			func(item,item_ui,i)
		end
	end
end

function C:InitZhiZhenUI()
	self.zhizhenAnim = self.zhizhen.transform:GetComponent("Animator")
	self.zhizhenAnim.speed = 0
	--[[if PlayerPrefs.GetInt(M.key ..MainModel.UserInfo.user_id.. "_award_index", 0) ~= 0 then
        local index = PlayerPrefs.GetInt(M.key ..MainModel.UserInfo.user_id.. "_award_index")
        self.zhizhen.localRotation = Quaternion:SetEuler( 0, 0, - 45 * index)
    end--]]
end

function C:MyRefresh()
	self:RefreshTaskUI()
	self:RefreshCollectRdUI()
	self:RefreshItemCountUI(true)
end

function C:RefreshTaskUI()
	if not self.task_data then
		return 
	end
	local tab = self:SortedTaskLis()
	dump(self.task_data,"<color=red>+++++++++++task_data+++++++++</color>")
	dump(tab,"<color=red>+++++++++++tab+++++++++</color>")

	local refresh_task_ui = function (item,item_ui,index)
		local _index = tab[index]
		local progress_ui
		local state = self.task_data[_index].state  --0=不能领取 1=可领取 2=已领取 3=跳转
		item_ui.get_btn.onClick:RemoveAllListeners()

		if not self.tasks_cfg[_index].level then
			if state == 0 and self.tasks_cfg[_index].is_goto_faq then
				state = 3
			end
			progress_ui = "(" .. self.task_data[_index].now_total_process .."/"..self.task_data[_index].need_process ..")"
			item_ui.get_btn.onClick:AddListener(function ()
				Network.SendRequest("get_task_award",{id = self.tasks_cfg[_index].task_id })
			end)
		else
			progress_ui = "(" .. self.task_data[_index].now_total_process .."/".. self.tasks_cfg[_index].total ..")" 
			item_ui.get_btn.onClick:AddListener(function ()
				Network.SendRequest("get_task_award_new",{id = self.tasks_cfg[_index].task_id ,award_progress_lv = self.tasks_cfg[_index].level})
			end)
		end

		item_ui.no_get.gameObject:SetActive(true)
		item_ui.get_btn.gameObject:SetActive(true)

		if state == 0 then
			item_ui.no_get_txt.text = "未领取"
		elseif state == 1 then
			item_ui.no_get.gameObject:SetActive(false)
		elseif state == 3 then
			item_ui.no_get.gameObject:SetActive(false)
			item_ui.get_btn.gameObject:SetActive(false)
		else
			item_ui.no_get_txt.text = "已领取"
		end

		item_ui.task_tit_txt.text = self.tasks_cfg[_index].content .. "\n"..progress_ui
		item_ui.task_icon_img.sprite = GetTexture(self.tasks_cfg[_index].reward_icon)
		item_ui.task_rd_txt.text = self.tasks_cfg[_index].reward_txt
	end
	self:InitLisItemUI(self.task_lis_ui,refresh_task_ui)
end

function C:SortedTaskLis()
	local tab = {}
	for i = 1, #self.tasks_cfg do
		tab[i] = i
	end
	local tab1 = {}
	local tab2 = {}
	local tab3 = {}
	for i = 1, #tab do
		if self.task_data[i].state == 1 then
			tab1[#tab1 + 1] = i
		elseif self.task_data[i].state == 0 then
			tab2[#tab2 + 1] = i
		else
			tab3[#tab3 + 1] = i
		end
	end
	tab = {}
	local handle_tab = function(_tab)
		for i = 1, #_tab do
			tab[#tab+1] = _tab[i]
		end
	end
	handle_tab(tab1)
	handle_tab(tab2)
	handle_tab(tab3)
	return tab
end

--add_task_progress "105682",21677,1000
function C:RefreshCollectRdUI()

	if not self.collect_data then
		return 
	end
	dump(self.collect_data,"<color=red>+++++++++++collect_data+++++++++</color>")
	local refresh_collect_ui =  function (item,item_ui,index)
		item_ui.pg_txt.text = self.collect_data.now_total_process .. "/" .. self.collect_rds_cfg[index].collect_num
		item_ui.rd_geted_btn.gameObject:SetActive(false)
		item_ui.TX.gameObject:SetActive(false)
		if self.collect_data.get_state[index] == 1 then
			item_ui.rd_get_btn.gameObject:SetActive(true)
			item_ui.rd_geted_btn.gameObject:SetActive(false)
			item_ui.TX.gameObject:SetActive(true)
		elseif self.collect_data.get_state[index] == 2 then
			item_ui.rd_geted_btn.gameObject:SetActive(true)
			item_ui.rd_get_btn.gameObject:SetActive(false)
		end

		item_ui.rd_get_btn.onClick:RemoveAllListeners()
		item_ui.rd_get_btn.onClick:AddListener(function ()
			if self.collect_data.get_state[index] == 1 then
				Network.SendRequest("get_task_award_new",{id = M.collect_task_id ,award_progress_lv = index})
			else
				if self.collect_rds_cfg[index].tips and self.collect_rds_cfg[index].tips[1] and self.collect_rds_cfg[index].tips[2] then
					self.LTTipsPrefab = LTTipsPrefab.Show2(item.transform,self.collect_rds_cfg[index].tips[1],self.collect_rds_cfg[index].tips[2])
				end
			end
		end)
		item_ui.rd_geted_btn.onClick:AddListener(function ()
			if self.collect_rds_cfg[index].tips and self.collect_rds_cfg[index].tips[1] and self.collect_rds_cfg[index].tips[2] then
				self.LTTipsPrefab = LTTipsPrefab.Show2(item.transform,self.collect_rds_cfg[index].tips[1],self.collect_rds_cfg[index].tips[2])
			end
		end)
	end
	self:InitLisItemUI(self.collect_lis_ui,refresh_collect_ui)
	self:RefreshProgressUI()
end

function C:RefreshProgressUI()
	local len = {
        [1] = { min = 0, max = 95.63 },
        [2] = { min = 197.29, max = 301.37 },
        [3] = { min = 402.66, max = 498.13 },
        [4] = { min = 601.5, max = 704.76 },
        [5] = { min = 805.56, max = 905.75 },
	}
	local cur_level =  self.collect_data.now_lv
	local max = len[cur_level].max
	local min = len[cur_level].min
	local x_len = min + (max - min) *( self.collect_data.now_process / self.collect_data.need_process)  
	self.progress.sizeDelta = {x = x_len , y = 29.62}
end

function C:RefreshItemCountUI(b)
	if b then
		self.item_num_txt.text = "x"..M.GetItemCount()
	end
	self.cjq_num_txt.text = "x" ..  MainModel.GetItemCount(M.lottery_item_key)
	self.item_icon_img.sprite = GetTexture("activity_icon_mtsp")
end

--抽奖
function C:Lottery()
	--self:AnimaStart(3)
	dump(MainModel.GetItemCount(M.lottery_item_key), "<color=white>抽奖券数量</color>")
	if MainModel.GetItemCount(M.lottery_item_key) < 3 then
		HintPanel.Create(1, "抽奖券不足！")
	end

	dump(M.box_exchange_id,"<color=white>茅台抽奖</color>")
	Network.SendRequest("box_exchange", { id = M.box_exchange_id, num = 1 })
end

function C:on_model_xnsmt_collect_refresh()
	self:UpdateCollectTaskData()
	self:RefreshCollectRdUI()
end

function C:on_model_xnsmt_task_refresh()
	self:UpdateTaskData()
	self:RefreshTaskUI()
end

function C:on_box_exchange_response(_, data)
	dump(data,"<color=white>+++++on_box_exchange_response+++++</color>")
	if data and data.result == 0 and data.id == M.box_exchange_id then
		if self.delay_timer then
			self.delay_timer:Stop()
			self.delay_timer = nil
		end
		self.delay_timer = Timer.New(function ()
			self:AddMyPMD(data.award_id)
		end,6,1,false)
		self.delay_timer:Start()
		
		local index = M.GetAwardIndex(data.award_id[1])
        if index then
            PlayerPrefs.SetInt(M.key ..MainModel.UserInfo.user_id.. "_award_index", index)
            self:AnimaStart(index)
		end
    end
end

function C:on_asset_change(_data)
	dump(_data,"<color=white>+++++on_asset_change+++++</color>")
	if _data.change_type and (_data.change_type == "box_exchange_active_award_"..M.box_exchange_id) then
		if table_is_null(_data.data) then
			return 
		end
        self.award_show_data = _data
		--self:TryToShow()
    end
    self:RefreshItemCountUI()
end

function C:on_get_task_award_new_response(_,data)
	dump(data,"<color=white>+++++on_get_task_award_new_response+++++</color>")
	if not data then
		return 
	end

	if data.id ~= M.collect_task_id then
		return 
	end

	--实物奖励：茅台
	if data.award_list[1].award_name == tostring(self.collect_rds_cfg[5].reward) then
		local string1
	    string1 = "实物奖励请关注公众号《"..Global_GZH.."》联系在线客服领取。"
		print(debug.traceback())
		local pre = HintCopyPanel.Create({desc=string1, isQQ=false,copy_value = Global_GZH})
		pre:SetCopyBtnText("复制公众号")
	end

	Event.Brocast("xnsmt_task_award_new_refresh")
end

--打开调查问卷
function C:OpenFAQPanel()
	Act_048_XNSMTFAQPanel.Create()
end
--------------------------------PMD---------------------------------
function C:UpdatePMD()
    if self.update_pmd then
        self.update_pmd:Stop()
	end
	if self.update_pmd_0 then
		self.update_pmd_0:Stop()
	end
	
	self.update_pmd_0 = Timer.New(
        function()
        	dump(data,"<color=yellow><size=15>++++++++++query_fake_data++++++++++</size></color>")
			Network.SendRequest("query_fake_data", { data_type = "new_year_maotai" })
		end
    , 3, 1,false)
    self.update_pmd_0:Start()
    self.update_pmd = Timer.New(
        function()
        	dump(data,"<color=yellow><size=15>++++++++++query_fake_data++++++++++</size></color>")
			Network.SendRequest("query_fake_data", { data_type = "new_year_maotai" })
		end
    , 20, -1,false)
    self.update_pmd:Start()
end

function C:AddMyPMD(data)
    if table_is_null(data) then return end
    local index = M.GetAwardIndex(data[1])
    if (self.lottery_rds_cfg[index + 1].icon ~= "activity_icon_mtsp") or (self.lottery_rds_cfg[index + 1].icon == "activity_icon_mtsp" and self.award_show_data.data[1].value < 30) then return end
    local _data_info = self.award_show_data.data
    local _data = data
    for i = 1, #_data do
        if index then
            local cur_data_pmd = {}
            cur_data_pmd["result"] = 0
            cur_data_pmd["player_name"] = MainModel.UserInfo.name
			cur_data_pmd["award_data"] = _data_info[i].value .. tostring(self.lottery_rds_cfg[index + 1].name)
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

---------------------------分享--------------------------
function C:OpenSharePanel()
	GameButtonManager.RunFunExt("sys_fx", "TYShareImage", nil, {fx_type="xnsmt"}, function (str)
		Network.SendRequest("shared_finish", {type="shared_friend_no_award"}, "",function (data)
			if GameTaskModel.GetTaskDataByID(M.fx_task_id) and GameTaskModel.GetTaskDataByID(M.fx_task_id).award_status and GameTaskModel.GetTaskDataByID(M.fx_task_id).award_status == 1 then
				Network.SendRequest("get_task_award",{id = M.fx_task_id})
			end
		end)
	end)
end

function C:RefreshTip()
	self.share_hint.gameObject:SetActive(GameTaskModel.GetTaskDataByID(M.fx_task_id) and GameTaskModel.GetTaskDataByID(M.fx_task_id).award_status and GameTaskModel.GetTaskDataByID(M.fx_task_id).award_status ~= 2)
end

function C:on_model_xnsmt_share_refresh()
	self:RefreshTip()
end

---------------------------转盘-------------------------
function C:AnimaStart(index)

    if not self.is_during_anim then
        self.curSoundKey = ExtendSoundManager.PlaySound(audio_config.game.bgm_duijihongbao.audio_name, 1, function()
            self.curSoundKey = nil
        end)
        self.is_during_anim = true
        self.zhizhenAnim:Play("act_004JIKAPanel_zhizhen", -1,0);
        self.zhizhenAnim.speed = 0
        self.zhizhen.gameObject:SetActive(true)
        local rota = -360 * 16 - 45 * index 
        local seq = DoTweenSequence.Create()
        seq:Append(self.zhizhen:DORotate(Vector3.New(0, 0, rota), 6, DG.Tweening.RotateMode.FastBeyond360):SetEase(DG.Tweening.Ease.InOutCubic))
        seq:OnKill(function()
            if IsEquals(self.gameObject) then
                self.zhizhen.localRotation = Quaternion:SetEuler(0, 0, rota)
                self:CloseAnimSound()
                self:AnimaEnd()
            end
        end)
    else
        LittleTips.Create("正在抽奖...")
    end
end

function C:AnimaEnd()
    self.zhizhenAnim.speed = 1
    self.de_timer = Timer.New(function()
        self.zhizhenAnim:Play("act_004JIKAPanel_zhizhen", -1,0);
        self.zhizhenAnim:Update(0)
        self.zhizhenAnim.speed = 0
        if self.award_show_data then
            Event.Brocast("AssetGet", self.award_show_data)
            self.award_show_data = nil
            self:RefreshItemCountUI(true)
        end
        self.is_during_anim = false
    end, 1.4, 1)
    self.de_timer:Start()
end

function C:CloseAnimSound()
    if self.curSoundKey then
        soundMgr:CloseLoopSound(self.curSoundKey)
        self.curSoundKey = nil
    end
end

-----------------------活动规则------------------------
function C:OpenRulePanel()
	local str =""
    for i = 1, #M.help_info do
        str = str .. "\n" .. M.help_info[i]
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:on_UpdateHallShareRedHint()
	M.QueryShareData()
end