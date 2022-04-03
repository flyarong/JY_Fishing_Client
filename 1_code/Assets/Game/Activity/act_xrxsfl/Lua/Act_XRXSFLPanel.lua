-- 创建时间:2021-02-08
-- Panel:Act_XRXSFLPanel
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

Act_XRXSFLPanel = basefunc.class()
local C = Act_XRXSFLPanel
C.name = "Act_XRXSFLPanel"
local M = Act_XRXSFLManager
local Status = {
	None = "none",
	Lottery = "lottery",
}
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
    self.lister["xrxsfl_task_had_got_msg"] = basefunc.handler(self,self.on_xrxsfl_task_had_got_msg)
    self.lister["query_fake_data_response"] = basefunc.handler(self, self.AddPMD)
    self.lister["xrxsfl_jbzk_is_active_msg"] = basefunc.handler(self,self.on_xrxsfl_jbzk_is_active_msg)
    self.lister["xrxsfl_cj_award_had_got_msg"] = basefunc.handler(self,self.on_xrxsfl_cj_award_had_got_msg)
    self.lister["xrxsfl_task_change_smg"] = basefunc.handler(self,self.on_xrxsfl_task_change_smg)
    self.lister["xrxsfl_box_exchange_new_msg"] = basefunc.handler(self,self.on_xrxsfl_box_exchange_new_msg)
    self.lister["jbzk_enter_refresh"] = basefunc.handler(self,self.on_jbzk_enter_refresh)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.huxi_index then
		CommonHuxiAnim.Stop(self.huxi_index)
		self.huxi_index = nil
	end
	self:StopFakeTimer()
	if self.pmd_cont then
		self.pmd_cont:MyExit()
		self.pmd_cont = nil
	end
	self:KillSeq()
	self:CloseTaskItemPre()
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
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
	EventTriggerListener.Get(self.cj_btn.gameObject).onClick = basefunc.handler(self, self.OnCJClick)
	self.pj = 45 -- 平均角度
	self.status = Status.None
	if os.time() > MainModel.UserInfo.first_login_time + 259200 then
		self.time_txt.gameObject:SetActive(false)
	else
		self.time_txt.gameObject:SetActive(true)
		CommonTimeManager.GetCutDownTimer(MainModel.UserInfo.first_login_time + 259200 , self.time_txt)
	end
	self.pmd_cont = CommonPMDManager.Create(self, self.CreatePMD ,{ parent = self.pmd_node, speed = 18, space_time = 10, start_pos = 1000 ,dotweenLayerKey = "xrxsfl"})
	self:TimerToQueryFakeData(true)

	if GameGlobalOnOff.IsOpenGuide and MainModel.UserInfo.xsyd_status ~= -1 then
		self.xsyd_ing = true
	end
	self:MyRefresh()
end

function C:CreatePMD(data)
	local obj = GameObject.Instantiate(self.pmd_item, self.pmd_node.transform)
	local temp_ui = {}
    LuaHelper.GeneratingVar(obj.transform, temp_ui)
    temp_ui.t1_txt.text = "恭喜玩家[" .. data.player_name .. "]在" .. data.award_where .. "中拆出" .. data.award_data 
	obj.gameObject:SetActive(true)
	return obj
end

function C:MyRefresh()
	self:CreateCJAwardItem()
	self:CreateTaskItemPre()
	self:RefreshRemainCjTimes()
	self:InitButtomUI()
	self:RefreshCjHuxi()
end

function C:OnBackClick()
	--[[if self.xsyd_ing and FishingModel and GameFishing3DManager.CheckCanBeginGameIDByGold(2) == 0 then
		FishingModel.GotoFishingByID(2)
		Network.SendRequest("set_xsyd_status", {status = -1, xsyd_type="xsyd"},function (data)
            if data and data.result == 0 then
                MainModel.UserInfo.xsyd_status = -1
            end
        end)
	end--]]
	self:MyExit()
end

function C:CreateTaskItemPre()
	self:CloseTaskItemPre()
	local tab = M.GetTaskConfig()
	MathExtend.SortListCom(tab, function (v1,v2)
		if (GameTaskModel.GetTaskDataByID(v1.task_id).award_status == 1) and (GameTaskModel.GetTaskDataByID(v2.task_id).award_status ~= 1) then
			return false
		elseif (GameTaskModel.GetTaskDataByID(v1.task_id).award_status ~= 1) and (GameTaskModel.GetTaskDataByID(v2.task_id).award_status == 1) then
			return true
		elseif (GameTaskModel.GetTaskDataByID(v1.task_id).award_status == 2) and (GameTaskModel.GetTaskDataByID(v2.task_id).award_status ~= 2) then
			return true
		elseif (GameTaskModel.GetTaskDataByID(v1.task_id).award_status ~= 2) and (GameTaskModel.GetTaskDataByID(v2.task_id).award_status == 2) then
			return false
		else
			if v1.ID > v2.ID then
				return true
			else
				return false	
			end
		end
	end)	
	for i=1,#tab do
		local pre = Act_XRXSFLTaskItemBase.Create(self.content.transform,tab[i],self)
		self.task_cell[#self.task_cell + 1] = pre
	end
	Event.Brocast("xrxsfl_taskitem_had_create_msg")
end

function C:CloseTaskItemPre()
	if self.task_cell then
		for k,v in pairs(self.task_cell) do
			v:MyExit()
		end
	end
	self.task_cell = {}
end

function C:RefreshRemainCjTimes()
	self.remain_txt.text = "剩余抽奖次数: " .. "<color=#ff0000>" ..  M.GetCjTimes() .. "</color>"
end

function C:OnCJClick()
	if M.GetCjTimes() < 1 then
		LittleTips.Create("抽奖次数不足～")
		return
	end
	if self.status == Status.Lottery then
		LittleTips.Create("当前正在抽奖中～")
		return
	end
	if M.CheckIsOverdue() then
		LittleTips.Create("活动已结束～")
		return
	end
	Network.SendRequest("activity_exchange",{ type = M.GetExchangeType() , id = 0 }, "请求数据",function (data)
		dump(data,"<color=yellow><size=15>++++++++++data++++++++++</size></color>")
		if data.result == 0 then
			self.status = Status.Lottery
			data.id = data.id + 1
			self.last_selectIndex = self.selectIndex
			self.selectIndex = data.id
			local tab = M.GetCjConfig()
			if tab[data.id].prop_key then
				self.cur_award = {data = {{asset_type = tab[data.id].prop_key,value = tab[data.id].value}}, change_type = "activity_exchange_"..data.type}
			elseif tab[data.id].obj_key then
				if tab[data.id].obj_key == "obj_jbzk" then
					self.cur_award = {data = {{asset_type = tab[data.id].obj_key,value = tab[data.id].value}}, change_type = "activity_exchange_"..data.type,confirm_text = "激活",callback = function () 
						GameManager.GotoUI({gotoui="sys_act_jbzk", goto_scene_parm = "panel",first_open=true})
						--打开金币周卡页面
					end}
				else
					self.cur_award = {data = {{asset_type = tab[data.id].obj_key,value = tab[data.id].value}}, change_type = "activity_exchange_"..data.type}
				end
			end
			self:RunAnim()
			self:RefreshRemainCjTimes()
			self:RefreshCjHuxi()
		else
			HintPanel.ErrorMsg(data.result)
		end
	end)
end

function C:RunAnim(delay)
	self:KillSeq()

	self:CloseAnimSound()
	self.curSoundKey = ExtendSoundManager.PlaySound(audio_config.game.bgm_duijihongbao.audio_name, 1, function ()
		self.curSoundKey = nil
	end)
	local rota = -360 * 18 - self.pj * (self.selectIndex-1)
	self.zzt.gameObject:SetActive(true)
	self.seq = DoTweenSequence.Create()
	if delay and delay > 0 then
		self.seq:AppendInterval(delay)
	end
	self.seq:Append(self.zz_node:DORotate( Vector3.New(0, 0 , rota), 6, DG.Tweening.RotateMode.FastBeyond360):SetEase(DG.Tweening.Ease.InOutCubic))
	self.seq:OnForceKill(function (is_force)
		self.seq = nil
		if IsEquals(self.gameObject) then
			self.zz_node.localRotation = Quaternion:SetEuler(0, 0, rota)
			self.g_node.localRotation = Quaternion:SetEuler(0, 0, rota)	
			self:RunAnimG()
		end
		if is_force then
			self:RunAnimFinish()
		end
	end)
end

function C:RunAnimG()
	self:KillSeq()
	self.zzt.gameObject:SetActive(false)
	self.g_node.gameObject:SetActive(true)
	self.seq = DoTweenSequence.Create()
	self.seq:AppendInterval(1)
	self.seq:OnKill(function ()
		self.seq = nil
		self.g_node.gameObject:SetActive(false)
		self:RunAnimFinish()
	end)
	self.seq:OnForceKill(function (is_force)
		if is_force then
			self:RunAnimFinish()
		end
	end)	
end

function C:RunAnimFinish()

	self:CloseAnimSound()
	
	self:ShowAwardBrocast()
end

function C:KillSeq()
	if self.seq then
		self.seq:Kill()
	end
	self.seq = nil
end

function C:CloseAnimSound()
	if self.curSoundKey then
		soundMgr:CloseLoopSound(self.curSoundKey)
		self.curSoundKey = nil
	end
end

function C:ShowAwardBrocast()
	dump(self.cur_award, "<color=red>EEE cur_award</color>")
	if self.cur_award then
		Event.Brocast("AssetGet", self.cur_award)
		self.cur_award = nil
		self:MyRefresh()
		self.status = Status.None
	end
end

function C:InitButtomUI()
	print(debug.traceback())
	self:ClearButtomCell()
	local obj_table = M.GetObjKeyTab()
	--dump(obj_table,"<color=yellow><size=15>++++++++++obj_table++++++++++</size></color>")
	for i=1,#obj_table do
		local data = MainModel.GetObjInfoByKey(obj_table[i])[1]
		--dump(data,"<color=yellow><size=15>++++++++++GetObjInfoByKey++++++++++</size></color>")
		if not table_is_null(data) then
			local pre = GameObject.Instantiate(self.extra, self.extra_node)
			pre.gameObject:SetActive(true)
			local item_data = GameItemModel.GetItemToKey(obj_table[i])
			pre.transform:Find("jbzk").gameObject:SetActive(false)
			pre.transform:Find("extra_img").gameObject:GetComponent("Image").sprite = GetTexture(item_data.image) 
			pre.transform:Find("extra_txt").gameObject:GetComponent("Text").text = item_data.name
			local btn = pre.transform:Find("@btn").gameObject:GetComponent("Button")
			if obj_table[i] ~= "obj_jbzk" then
				if os.time() < data.enable_time then
					pre.transform:Find("extra_time_txt").gameObject:SetActive(true)
					CommonTimeManager.GetCutDownTimer2(data.enable_time , pre.transform:Find("extra_time_txt").gameObject:GetComponent("Text"))
				else
					pre.transform:Find("extra_time_txt").gameObject:SetActive(false)
				end
				btn.onClick:AddListener(function ()
					ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
					if os.time() >= data.enable_time then
						GameManager.GotoUI({gotoui="act_xrxsfl", goto_scene_parm = obj_table[i]})
					else
						LittleTips.Create(pre.transform:Find("extra_time_txt").gameObject:GetComponent("Text").text.."后可开启礼包")
					end
				end)
				pre.transform:Find("extra_img/liuguang").gameObject:SetActive(false)
			else
				pre.transform:Find("extra_img/liuguang").gameObject:SetActive(true)
				if Sys_Act_JBZKManager and Sys_Act_JBZKManager.GetJbzkActivationState() then
					pre.transform:Find("jbzk").gameObject:SetActive(false)
				else
					pre.transform:Find("jbzk").gameObject:SetActive(true)
				end
				pre.transform:Find("extra_time_txt").gameObject:SetActive(false)
				btn.onClick:AddListener(function ()
					GameManager.GotoUI({gotoui="sys_act_jbzk", goto_scene_parm = "panel"})
				end)
				--[[if M.CheckJBZKIsActive() then
					
					--打开金币周卡页面
				else
					GameManager.GotoUI({gotoui="sys_act_jbzk", goto_scene_parm = "panel"})
					--打开金币周卡页面
					--btn.onClick:AddListener(function () M.ActivieJBZK() end)					
				end--]]
			end
			self.buttom_cell[#self.buttom_cell + 1] = pre
		end
	end
	Event.Brocast("xrxsfl_buttomui_had_create_msg")
end

function C:ClearButtomCell()
	if self.buttom_cell then
		for k,v in pairs(self.buttom_cell) do
			destroy(v.gameObject)
		end
	end
	self.buttom_cell = {}
end

function C:CreateCJAwardItem()
	local award_list = M.GetAwardConfig()
	for i=1,#award_list do
		local obj = GameObject.Instantiate(self.cwlb_jp_prefab, self["jp_node"..i])
		obj.gameObject:SetActive(true)
		local tran = obj.transform
		tran.localPosition = Vector3.zero
		local JPImage = tran:Find("JPImage"):GetComponent("Image")
		local JPText = tran:Find("JPText"):GetComponent("Text")
		local big = tran:Find("big").gameObject
		big.gameObject:SetActive(i == 1)
		JPImage.sprite = GetTexture(award_list[i].award_img)
		JPText.text = award_list[i].award_desc
	end
end

function C:QueryFakeData()
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="cpl_notcjj", is_on_hint = true}, "CheckCondition")
    if a and b then
    	Network.SendRequest("query_fake_data", { data_type = "xrfl_broadcast" })
    else
    	Network.SendRequest("query_fake_data", { data_type = "xrfl_cjj_broadcast" })
    end
end

function C:AddPMD(_, data)
    dump(data, "<color=red>PMD</color>")
    if not IsEquals(self.gameObject) then return end
    if data and data.result == 0 then
    	if data.ext_data then
    		data.award_where = data.ext_data[1]
    		data.award_data = data.ext_data[2]
    	end
        self.pmd_cont:AddPMDData(data)
    end
end

function C:TimerToQueryFakeData(b)
	self:StopFakeTimer()
	if b then
		self.fake_timer = Timer.New(function ()
			self:QueryFakeData()
		end,2,-1,false)
		self.fake_timer:Start()
	end
end

function C:StopFakeTimer()
	if self.fake_timer then
		self.fake_timer:Stop()
		self.fake_timer = nil
	end
end

function C:on_xrxsfl_jbzk_is_active_msg()
	self:InitButtomUI()
end

function C:on_xrxsfl_cj_award_had_got_msg()
	self:CreateCJAwardItem()
	self:CreateTaskItemPre()
	self:RefreshRemainCjTimes()
	self:RefreshCjHuxi()
end

function C:on_xrxsfl_task_had_got_msg()
	self:CreateCJAwardItem()
	self:CreateTaskItemPre()
	self:RefreshRemainCjTimes()
	self:RefreshCjHuxi()
end

function C:on_xrxsfl_task_change_smg()
	self:CreateTaskItemPre()
end

function C:on_xrxsfl_box_exchange_new_msg()
	self:InitButtomUI()
end

function C:on_jbzk_enter_refresh()
	self:InitButtomUI()
end

function C:RefreshCjHuxi()
	if M.GetCjTimes() >= 1 then
		if self.huxi_index then
			CommonHuxiAnim.Stop(self.huxi_index)
			self.huxi_index = nil
		end
		self.huxi_index = CommonHuxiAnim.Start(self.cj_btn.gameObject,1,0.9,1.1)
	else
		CommonHuxiAnim.Stop(self.huxi_index)
	end
end