-- 创建时间:2020-07-08
-- Panel:SYSBYLevelEnterPrefab
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

SYSBYLevelEnterPrefab = basefunc.class()
local C = SYSBYLevelEnterPrefab
C.name = "SYSBYLevelEnterPrefab"
local M = SYSBYLevelManager
local EnterState = {
	on = "on",
	off = "off",
}

local AwardState = {
	Is = "Is",
	No = "No",
}
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
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["level_info_got"] = basefunc.handler(self,self.on_level_info_got)
    self.lister["sys_by_level_task_data_msg"] = basefunc.handler(self,self.on_sys_by_level_task_data_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	--self:StopTimer()
	self:KillDotween()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.mask.gameObject:SetActive(false);
	-- self.canvas_group = self.mask.transform:GetComponent("CanvasGroup")
	self.slider = self.Slider.gameObject:GetComponent("Slider")
	self.slider_boss = self.Slider_boss.gameObject:GetComponent("Slider")
	self.slider2 = self.Slider2.gameObject:GetComponent("Slider")
	self.bg_rect = self.bg.gameObject:GetComponent("RectTransform")
	self.lv_anim = self.gift_icon.transform:GetComponent("Animator")
	--self.off_panel = self.off_panel.transform:GetComponent("MyButton")
	self.AwardState = AwardState.No
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.enter10_btn.gameObject).onClick = basefunc.handler(self, self.on_Enter3Click)
	EventTriggerListener.Get(self.enter1_btn.gameObject).onClick = basefunc.handler(self, self.on_Enter1Click)
	EventTriggerListener.Get(self.enter2_btn.gameObject).onClick = basefunc.handler(self, self.on_Enter2Click)
	EventTriggerListener.Get(self.enter3_btn.gameObject).onClick = basefunc.handler(self, self.on_Enter1Click)
	EventTriggerListener.Get(self.enter4_btn.gameObject).onClick = basefunc.handler(self, self.on_Enter2Click)
	--EventTriggerListener.Get(self.off_panel.gameObject).onClick = basefunc.handler(self, self.OnOFFClick)
	self.lv_anim:Play("null", -1, 0)
	self.last_lv = M.GetLevel()
	self.EnterState = EnterState.off
	--print("<color=red>进游戏000000000</color>")
	local should_index = M.GetShouldIndex()
	local unlock_tab = M.GetUnlockConfig()
	if should_index and unlock_tab[should_index] and  M.GetLevel() < unlock_tab[should_index].level then
		local data = SYSBYLevelManager.GetData()
		self.slider2.value = data.cur_rate / data.max_rate
	else
		self.slider2.value = 1
	end
	if should_index and unlock_tab[should_index] then
		local pos_X
		if self.slider2.value == 1 then
			pos_X = -30
		else
			pos_X = -480
		end
		-- if unlock_tab[should_index].unlock_gun then
		-- 	-- self.pt_icon_img.gameObject:SetActive(true)
		-- 	self.pb_txt.text = unlock_tab[should_index].unlock_gun.."倍"
		-- 	-- self.new_pt_icon_img.gameObject:SetActive(false)
		-- 	self.award.transform.localPosition = Vector3.New(-168,self.award.transform.localPosition.y,self.award.transform.localPosition.z)
		-- 	self.bg.transform.localPosition = Vector3.New(pos_X,self.bg.transform.localPosition.y,self.bg.transform.localPosition.z)
		-- 	self.bg_rect.sizeDelta = Vector2.New(710,100)
		-- elseif unlock_tab[should_index].tips then
		-- 	-- self.pt_icon_img.gameObject:SetActive(false)
		-- 	-- self.new_pt_icon_img.gameObject:SetActive(true)
		-- 	self.new_pb_txt.text = unlock_tab[should_index].gunlv_tips
		-- 	self.new_pt_img.sprite = GetTexture(unlock_tab[should_index].gun_img)
		-- 	self.award.transform.localPosition = Vector3.New(-168,self.award.transform.localPosition.y,self.award.transform.localPosition.z)
		-- 	self.bg.transform.localPosition = Vector3.New(pos_X,self.bg.transform.localPosition.y,self.bg.transform.localPosition.z)
		-- 	self.bg_rect.sizeDelta = Vector2.New(710,100)
		-- else
		-- 	-- self.pt_icon_img.gameObject:SetActive(false)
		-- 	-- self.new_pt_icon_img.gameObject:SetActive(false)
		-- 	if self:RefreshImgBool() then
		-- 		self:RefreshImg()
		-- 		self.award.transform.localPosition = Vector3.New(-168,self.award.transform.localPosition.y,self.award.transform.localPosition.z)
		-- 		self.bg.transform.localPosition = Vector3.New(pos_X,self.bg.transform.localPosition.y,self.bg.transform.localPosition.z)
		-- 		self.bg_rect.sizeDelta = Vector2.New(710,100)
		-- 	else
		-- 		self.award.transform.localPosition = Vector3.New(-248,self.award.transform.localPosition.y,self.award.transform.localPosition.z)
		-- 		self.bg.transform.localPosition = Vector3.New(-40,self.bg.transform.localPosition.y,self.bg.transform.localPosition.z)
		-- 		self.bg_rect.sizeDelta = Vector2.New(600,100)
		-- 	end
		-- end
		--dump(should_index,"<color=green>---------//////-----------------</color>")
		self.lv_award_txt.text = unlock_tab[should_index].level.."级礼包"
		self:RefreshAward()
	end
	self:RefreshNewPTtips()
end

function C:MyRefresh()
	local should_index = M.GetShouldIndex()
	local unlock_tab = M.GetUnlockConfig()
	if should_index and unlock_tab[should_index] and M.GetLevel() >= unlock_tab[should_index].level then
		self:on()
		self.lv_anim:Play("lv_breath_ani",-1,0)
		self.texiao.gameObject:SetActive(true)
		self.lfl.gameObject:SetActive(true)
		self.AwardState = AwardState.Is
	else
		self:off()
		self.lv_anim:Play("null",-1,0)
		self.texiao.gameObject:SetActive(false)
		self.lfl.gameObject:SetActive(false)
		self.AwardState = AwardState.No
	end
	if should_index and unlock_tab[should_index] then
		if unlock_tab[should_index].unlock_gun then
			-- self.pt_icon_img.gameObject:SetActive(true)
			self.pb_txt.text = unlock_tab[should_index].unlock_gun.."倍"
			-- self.new_pt_icon_img.gameObject:SetActive(false)
			self.award.transform.localPosition = Vector3.New(-168,self.award.transform.localPosition.y,self.award.transform.localPosition.z)
			--self.bg.transform.localPosition = Vector3.New(-40,self.bg.transform.localPosition.y,self.bg.transform.localPosition.z)
			self.bg_rect.sizeDelta = Vector2.New(710,100)
		elseif unlock_tab[should_index].tips then
			-- self.pt_icon_img.gameObject:SetActive(false)
			-- self.new_pt_icon_img.gameObject:SetActive(true)
			self.new_pb_txt.text = unlock_tab[should_index].gunlv_tips
			self.new_pt_img.sprite = GetTexture(unlock_tab[should_index].gun_img)
			self.award.transform.localPosition = Vector3.New(-168,self.award.transform.localPosition.y,self.award.transform.localPosition.z)
			--self.bg.transform.localPosition = Vector3.New(-40,self.bg.transform.localPosition.y,self.bg.transform.localPosition.z)
			self.bg_rect.sizeDelta = Vector2.New(710,100)
		else
			-- self.pt_icon_img.gameObject:SetActive(false)
			-- self.new_pt_icon_img.gameObject:SetActive(false)
			if self:RefreshImgBool() then
				self:RefreshImg()
				self.award.transform.localPosition = Vector3.New(-168,self.award.transform.localPosition.y,self.award.transform.localPosition.z)
				self.bg_rect.sizeDelta = Vector2.New(710,100)
			else
				self.award.transform.localPosition = Vector3.New(-248,self.award.transform.localPosition.y,self.award.transform.localPosition.z)
				--self.bg.transform.localPosition = Vector3.New(-40,self.bg.transform.localPosition.y,self.bg.transform.localPosition.z)
				self.bg_rect.sizeDelta = Vector2.New(600,100)
			end
		end
		--dump(should_index,"<color=green>---------//////-----------------</color>")
		self.lv_award_txt.text = unlock_tab[should_index].level.."级礼包"
		self:RefreshSlider2(true)
		self:RefreshAward()
	end

	local should_index = M.GetShouldIndex()
	local unlock_tab = M.GetUnlockConfig()
	--print("<color=red>领奖000000000</color>")
	if should_index and unlock_tab[should_index] and M.GetLevel() < unlock_tab[should_index].level then
		local data = SYSBYLevelManager.GetData()
		self.slider2.value = 0
		self:DoProAnim(data.cur_rate / data.max_rate,self.slider2,0.6)
	else
		self.slider2.value = 1
	end
	self:RefreshNewPTtips()
end

function C:on_Enter1Click()
	local should_index = M.GetShouldIndex()
	local unlock_tab = M.GetUnlockConfig()
	if should_index and unlock_tab[should_index] then
		if M.GetLevel() >= unlock_tab[should_index].level then
			self:on_Enter2Click()
		else
			if self.EnterState == EnterState.off then		
				self:on()
				--self.off_panel.gameObject:SetActive(true)
			elseif self.EnterState == EnterState.on then
				self:off()
			end
		end
	end
end

function C:on()
	self.EnterState = EnterState.on
	self:KillDotween()
	self.seq1 = DoTweenSequence.Create()
	local should_index = M.GetShouldIndex()
	local unlock_tab = M.GetUnlockConfig()
	if unlock_tab[should_index].unlock_gun or unlock_tab[should_index].tips or self:RefreshImgBool() then
		self.seq1:Append(self.bg.transform:DOLocalMoveX(20,0.3))
	else
		self.seq1:Append(self.bg.transform:DOLocalMoveX(-40,0.3))
	end
	-- self.seq1:Join(self.canvas_group:DOFade(1,0.3))
	-- self.seq1:AppendCallback(function ()
	-- 	self.enter10_btn.gameObject:SetActive(true)
	-- end)
	-- self.seq1:AppendInterval(3)
	-- self.seq1:AppendCallback(function ()
	-- 		if self.AwardState == AwardState.No then
	-- 			self:off()
	-- 		end
	-- 	end)
end

function C:off()
	self.EnterState = EnterState.off
	self:KillDotween()
	-- self.seq1 = DoTweenSequence.Create()
	-- self.seq1:Append(self.bg.transform:DOLocalMoveX(-480,0.3))
	-- self.seq1:Join(self.canvas_group:DOFade(0,0.3))
	self.enter10_btn.gameObject:SetActive(false)
end

function C:on_Enter2Click()
	M.GetAwardPB()
	--self:on()
	local should_index = M.GetShouldIndex()
	local unlock_tab = M.GetUnlockConfig()
	if unlock_tab[should_index] and unlock_tab[should_index].unlock_award_nums then
		local money = unlock_tab[should_index].unlock_award_nums[1]
		Event.Brocast("sys_by_level_get_award_msg",{pos = self.transform.position,money = money})
	end
end

function C:on_level_info_got()
	local should_index = M.GetShouldIndex()
	local unlock_tab = M.GetUnlockConfig()
	if should_index and unlock_tab[should_index] and M.GetLevel() >= unlock_tab[should_index].level then
		self:on()
		self.lv_anim:Play("lv_breath_ani",-1,0)
		self.texiao.gameObject:SetActive(true)
		self.lfl.gameObject:SetActive(true)
		self.AwardState = AwardState.Is
	else
		self.lv_anim:Play("null",-1,0)
		self.texiao.gameObject:SetActive(false)
		self.lfl.gameObject:SetActive(false)
		self.AwardState = AwardState.No
	end
	--self:RefreshSlider2(false)
	if self.last_lv < M.GetLevel() then
		M.Query_Task_Data()
		self.last_lv = M.GetLevel()
		--self:on()
		local t = {}
    	local gun_index = 1
		local unlock_tab = M.GetUnlockConfig()
		for k,v in pairs(unlock_tab) do
			if v.game_id and v.level and v.game_id == FishingModel.game_id and v.level <= M.GetLevel() then
				t[#t + 1] = v.gun_index
        	end
		end
		--dump(t,"<color=blue>////////////...........//////////////</color>")
		for i=1,#t do
	        gun_index = math.max(t[i],gun_index)
	    end
	    --dump(gun_index,"<color=blue>////////////...........//////////////</color>")
        Event.Brocast("by3d_level_lock_rate_change", {is_hand=false, index=gun_index})
	else	
		self.lv_txt.text = "Lv"..M.GetLevel().." / Lv"..(M.GetLevel() + 1)
		local data = SYSBYLevelManager.GetData()
		self.slider.value = data.cur_rate / data.max_rate
	end

	local should_index = M.GetShouldIndex()
	local unlock_tab = M.GetUnlockConfig()
	if should_index and unlock_tab[should_index] and M.GetLevel() < unlock_tab[should_index].level then
		local data = SYSBYLevelManager.GetData()
		self:DoProAnim(data.cur_rate / data.max_rate,self.slider2,0.6)
	else	
		self:DoProAnim(1,self.slider2,0.6)
	end
	self:RefreshNewPTtips()
end


function C:KillDotween()
	if self.seq1 then
		self.seq1:Kill()
		self.seq1 = nil
	end
end

function C:on_sys_by_level_task_data_msg()
	self:MyRefresh()
end


function C:RefreshSlider2(bool)
	
end

function C:SetValue_Now()
	local data = SYSBYLevelManager.GetData()
	self.slider2.value = data.cur_rate / data.max_rate
end

function C:SetValue_Hua()
	local data = SYSBYLevelManager.GetData()
	self:StopAnimTimers()
	local val = data.cur_rate / data.max_rate
	self:DoProAnim(val,self.slider2,0.3)
end

function C:RefreshAward()
	-- local should_index = M.GetShouldIndex()
	-- local unlock_tab = M.GetUnlockConfig()
	for i=1,3 do
		self["award"..i.."_node"].gameObject:SetActive(false)
	end
	-- for i=1,#unlock_tab[should_index].unlock_award_types do
	-- 	self["award"..i.."_node"].gameObject:SetActive(true)
	-- 	self["award"..i.."_img"].sprite = GetTexture(GameItemModel.GetItemToKey(unlock_tab[should_index].unlock_award_types[i]).image)
	-- 	self["award"..i.."_txt"].text = "X"..unlock_tab[should_index].unlock_award_nums[i]
	-- end
end

local AnimTimers = {}
function C:DoProAnim(val,P_G,DurTime,CallUpdateCall,OverCall)
	self:StopAnimTimers()
	local c_v = P_G.value
	local dur_time = DurTime -- 总持续时间
	local performs = 3 --顺滑度
	local each_time = 0.016 * performs -- 单帧时间(可以根据性能减少帧数，性能越差，performs越大)
	local run_times = dur_time / each_time --执行次数
	local s = val - c_v -- 总路程
	local each_s = s / run_times -- 单帧路程
	local get_check_func = function (a1,a2) --返回一个检查是否到终点得函数，不用math.abs是因为不平滑
		if a1 > a2 then
			return function (a1,a2)
				if a2 >= a1 then
					return true
				end
			end
		else
			return function (a1,a2)
				if a2 <= a1 then
					return true
				end
			end
		end
	end
	local is_over = get_check_func(val,c_v)
	local change_timer
	change_timer = Timer.New(function()
		if is_over(val,P_G.value) then 
			P_G.value = val
			if OverCall then
				OverCall()
				OverCall = nil
			end
			if change_timer then
				change_timer:Stop()
			end
		else
			P_G.value = P_G.value + each_s
			if CallUpdateCall then
				CallUpdateCall(P_G.value)
			end
		end
	end ,each_time,run_times)
	change_timer:Start()
	AnimTimers[#AnimTimers + 1] = change_timer
end

function C:StopAnimTimers()
	for i = 1,#AnimTimers do
		AnimTimers[i]:Stop()
		AnimTimers[i] = nil
	end
	AnimTimers = {}
end

function C:on_sys_by_level_task_data_got()
	
end
--直接进入游戏,进度条当前没有领奖等级的百分比


--游戏过程中,有奖励没有领,进度条满的

--游戏过程种,没有奖励可以领,当前等级的百分比

--按下领奖按钮,开始检测下一个等级是否是满状态
	--如果是满状态,直接满进度不做动画
	--如果不是满状态,做动画

function C:OnOFFClick()
	--self.off_panel.gameObject:SetActive(false)
	self:off()
end

function C:RefreshNewPTtips()
	local should_index = M.GetShouldIndex()
	local unlock_tab = M.GetUnlockConfig()
	for i=1,#unlock_tab do
		if unlock_tab[i].tips and should_index and unlock_tab[should_index] and unlock_tab[should_index].level <= unlock_tab[i].level and not self.lfl.gameObject.activeSelf and self:IsNoGunUp() then
			self.new_pt.gameObject:SetActive(true)
			self.new_pt_txt.text = unlock_tab[i].tips
			return
		end
	end
	self.new_pt.gameObject:SetActive(false)
end

function C:on_Enter3Click()
	local should_index = M.GetShouldIndex()
	local unlock_tab = M.GetUnlockConfig()
	if should_index and unlock_tab[should_index] then
		if self:IsNoGunUp() and self.AwardState == AwardState.No and (unlock_tab[should_index].tips and unlock_tab[should_index].gun_type == 1 and M.GetLevel() < unlock_tab[should_index].level) then
			SYSBYLevelPTPanel.Create(unlock_tab[should_index].level)
		elseif self:IsNoGunUp() and self.AwardState == AwardState.No and self:RefreshImgBool() and self:RefreshImgGunType() then
			SYSBYLevelPTPanel.Create(self:RefreshImgLevel())
		elseif M.GetLevel() >= unlock_tab[should_index].level then
			self:on_Enter2Click()
		else
			if self.EnterState == EnterState.off then		
				self:on()
				--self.off_panel.gameObject:SetActive(true)
			elseif self.EnterState == EnterState.on then
				self:off()
			end
		end
	end
end

function C:RefreshImg()
	local should_index = M.GetShouldIndex()
	local unlock_tab = M.GetUnlockConfig()
	for i=1,#unlock_tab do
		if unlock_tab[i].tips and should_index and unlock_tab[should_index] and unlock_tab[should_index].level <= unlock_tab[i].level and unlock_tab[should_index].level ~= 7 then
			-- self.new_pt_icon_img.gameObject:SetActive(true)
			self.new_pb_txt.text = unlock_tab[i].gunlv_tips
			self.new_pt_img.sprite = GetTexture(unlock_tab[i].gun_img)
			return
		end
	end
end
function C:RefreshImgBool()
	local should_index = M.GetShouldIndex()
	local unlock_tab = M.GetUnlockConfig()
	for i=1,#unlock_tab do
		if unlock_tab[i].tips and should_index and unlock_tab[should_index] and unlock_tab[should_index].level <= unlock_tab[i].level and unlock_tab[should_index].level ~= 7 then
			return true
		end
	end
	return false
end

function C:RefreshImgLevel()
	local should_index = M.GetShouldIndex()
	local unlock_tab = M.GetUnlockConfig()
	for i=1,#unlock_tab do
		if unlock_tab[i].tips and should_index and unlock_tab[should_index] and unlock_tab[should_index].level <= unlock_tab[i].level and unlock_tab[should_index].level ~= 7 then
			return unlock_tab[i].level
		end
	end
end

function C:RefreshImgGunType()
	local unlock_tab = M.GetUnlockConfig()
	for i=1,#unlock_tab do
		if unlock_tab[i].level == self:RefreshImgLevel() then
			if unlock_tab[i].gun_type == 1 then
				return true
			end
		end
	end	
	return false
end

--在再也沒有炮倍提升奖励之后,才判断要不要显示"XX级领炮台"的tips
function C:IsNoGunUp()
	local should_index = M.GetShouldIndex()
	local unlock_tab = M.GetUnlockConfig()
	local level = unlock_tab[#unlock_tab].level
	for i=#unlock_tab,1,-1 do
		if not unlock_tab[i].unlock_gun then
			if level > unlock_tab[i].level then
				level = unlock_tab[i].level
			end
		else
			break
		end
	end
	if should_index and unlock_tab[should_index] and unlock_tab[should_index].level then
		if unlock_tab[should_index].level < level then
			return false
		else
			return true
		end
	end
	return false
end

