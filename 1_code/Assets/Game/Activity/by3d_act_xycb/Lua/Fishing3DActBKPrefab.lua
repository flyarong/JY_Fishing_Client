-- 创建时间:2020-02-19
-- Panel:Fishing3DActBKPrefab
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

Fishing3DActBKPrefab = basefunc.class()
local C = Fishing3DActBKPrefab
C.name = "Fishing3DActBKPrefab"
local M = BY3DActXYCBManager

local XYCB_State = {
	Not = "Not", -- 未获得
	NotLock = "NotLock", -- 未解锁
	WaitOpen = "WaitOpen", -- 待开启
	Opening = "Opening", -- 开启中
	OpenFinish = "Finish", -- 开启完成
}
function C.Create(panelSelf, parent, index)
	return C.New(panelSelf, parent, index)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["XYCB_BK_OnDJClick_msg"] = basefunc.handler(self,self.on_XYCB_BK_OnDJClick_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:StopDJS()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(panelSelf, parent, index)
	self.panelSelf = panelSelf
	self.index = index
	local obj = newObject("fish3d_act_bk_prefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	tran.localPosition = Vector3.zero
	
	self.cb_state = XYCB_State.Not
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.dj_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnDJClick()
    end)
    self.bg_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnBGClick()
    end)
    self.open_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self.bg_btn.gameObject:SetActive(false)
		M.OpenXYCB(self.index)
    end)
    self.open_now_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		if self.needjb and self.needjb <= MainModel.UserInfo.jing_bi then
			self.bg_btn.gameObject:SetActive(false)
		end
		M.FinishXYCB(self.index)
    end)
	self:MyRefresh()
end

function C:MyRefresh()
	local cb_da
	if M.m_data.caibei_all_info and M.m_data.caibei_all_info[self.index] then
		cb_da = M.m_data.caibei_all_info[self.index]
		if cb_da.state ~= 0 then
			self.cfg = M.GetIDConfig(cb_da.type)
		end
	end
	self:UpdateState()
	
	self.dj_btn.gameObject:SetActive(true)
	self.bk_img.gameObject:SetActive(true)
	self.bk_nil_img.gameObject:SetActive(false)
	self.wc_node.gameObject:SetActive(false)
	self.ing_node.gameObject:SetActive(false)
	self.lock_node.gameObject:SetActive(false)
	self.open_node.gameObject:SetActive(false)
	self.needtime_txt.gameObject:SetActive(false)
	self.open_btn.gameObject:SetActive(false)
	self.open_now_btn.gameObject:SetActive(false)

	self:StopDJS()
	dump(self.cb_state)
	if self.cb_state == XYCB_State.Not then
		self.dj_btn.gameObject:SetActive(false)
		self.bk_img.gameObject:SetActive(false)
		self.bk_nil_img.gameObject:SetActive(true)
	elseif self.cb_state == XYCB_State.NotLock then
		self.lock_node.gameObject:SetActive(true)
		self.bk_nil_img.gameObject:SetActive(true)
		self.bk_img.gameObject:SetActive(false)
		if self.index == 2 then
			self.js_desc_txt.text = "Lv10"
		elseif self.index == 3 then
			if VIPManager.get_vip_level() < 1 then
				self.js_desc_txt.text = "VIP1"
			else
				self.js_desc_txt.text = "Lv10"
			end
		elseif self.index == 4 then
			if VIPManager.get_vip_level() < 3 then
				self.js_desc_txt.text = "VIP3"
			else
				self.js_desc_txt.text = "Lv10"
			end
		elseif self.index == 5 then
			if VIPManager.get_vip_level() < 5 then
				self.js_desc_txt.text = "VIP5"
			else
				self.js_desc_txt.text = "Lv10"
			end
		end
		--[[if self.index == 5 then
			self.js_desc_txt.text = "VIP3"
		end--]]
	elseif self.cb_state == XYCB_State.WaitOpen then
		self.needtime_txt.gameObject:SetActive(true)
		self.needtime_txt.text = (self.cfg.cd/60).."分钟"
		self.bk_img.sprite = GetTexture(self.cfg.icon)
		if M.GetOpeningCBMax() > M.GetOpeningCBNum() then
			self.open_node.gameObject:SetActive(true)
		else
			self.open_node.gameObject:SetActive(false)
		end
	elseif self.cb_state == XYCB_State.Opening then
		self.needtime_txt.gameObject:SetActive(false)
		self.bk_img.sprite = GetTexture(self.cfg.icon)
		self.ing_node.gameObject:SetActive(true)
		self:RunDJS()
	elseif self.cb_state == XYCB_State.OpenFinish then
		self.bk_img.sprite = GetTexture(self.cfg.icon)
		self.wc_node.gameObject:SetActive(true)
		self.open_now_btn.gameObject:SetActive(false)
	else
		dump(self.cb_state)
	end
end

function C:UpdateState()
	--if (self.index == 5 and VIPManager.get_vip_level() < 3) then
	if (self.index == 2 and SYSBYLevelManager.GetData().level < 10) or ((self.index == 3 and VIPManager.get_vip_level() < 1) or (self.index == 3 and SYSBYLevelManager.GetData().level < 10)) or ((self.index == 4 and VIPManager.get_vip_level() < 3) or (self.index == 4 and SYSBYLevelManager.GetData().level < 10)) or ((self.index == 5 and VIPManager.get_vip_level() < 5) or (self.index == 5 and SYSBYLevelManager.GetData().level < 10)) then
		self.cb_state = XYCB_State.NotLock
	else
		if M.m_data.caibei_all_info and M.m_data.caibei_all_info[self.index] then
			local cb_da = M.m_data.caibei_all_info[self.index]
			if cb_da.state == 0 then
				self.cb_state = XYCB_State.Not
			elseif cb_da.state == 1 then
				self.cb_state = XYCB_State.WaitOpen
			else
				local tt = cb_da.start_time + self.cfg.cd - os.time()
				if tt > 0 then
					self.cb_state = XYCB_State.Opening
				else
					self.cb_state = XYCB_State.OpenFinish
				end
			end
		else
			self.cb_state = XYCB_State.Not
		end
	end
end

function C:OnDJClick()
	self.bg_btn.gameObject:SetActive(true)
	dump(self.cb_state, "<color=red>彩贝状态</color>")
	--self.panelSelf:OnBKClick(self.index)
	local bk_data = M.m_data.caibei_all_info[self.index]
	dump(bk_data, "<color=red>************彩贝状态</color>")
	if bk_data then
		if bk_data.state == 1 then
			if M.GetOpeningCBNum() < M.GetOpeningCBMax() then
				self.open_btn.gameObject:SetActive(true)
				self.open_now_btn.gameObject:SetActive(true)
				self.open_now_btn.transform.localPosition = Vector3.New(137,self.open_now_btn.transform.localPosition.y,self.open_now_btn.transform.localPosition.z)
				self.needjb_txt.text = "x" .. self.cfg.close_cd_hf[1]
				self.open_node.gameObject:SetActive(false)
			else
				self.open_btn.gameObject:SetActive(false)
				self.open_now_btn.gameObject:SetActive(true)
				self.needjb_txt.text = "x" .. self.cfg.close_cd_hf[1]
				self.open_node.gameObject:SetActive(false)
				self.open_now_btn.transform.localPosition = Vector3.New(0,self.open_now_btn.transform.localPosition.y,self.open_now_btn.transform.localPosition.z)
			end
		elseif bk_data.state == 2 then
			local cfg = M.GetIDConfig(bk_data.type)
			local tt = bk_data.start_time + cfg.cd - os.time()
			if tt > 0 then
				self.open_btn.gameObject:SetActive(false)
				self.open_now_btn.gameObject:SetActive(true)
				self.open_now_btn.transform.localPosition = Vector3.New(0,self.open_now_btn.transform.localPosition.y,self.open_now_btn.transform.localPosition.z)
			else
				M.AutoFinishXYCB(self.index)
			end
		end
	else
		LittleTips.Create("未解锁")
	end
	Event.Brocast("XYCB_BK_OnDJClick_msg",self.index)
end

function C:RunDJS()
	self:StopDJS()
	local cb_da = M.m_data.caibei_all_info[self.index]
	self.down_val = cb_da.start_time + self.cfg.cd - os.time()

	self.update_time = Timer.New(function ()
    	self:UpdateTime()
    end, 1, -1, nil, true)
    self:UpdateTime(true)
    self.update_time:Start()
end
function C:StopDJS()
	if self.update_time then
		self.update_time:Stop()
	end
	self.update_time = nil
end
function C:UpdateTime(b)
	if not b then
		if self.down_val then
			self.down_val = self.down_val - 1
		end
	end
	if not self.down_val or self.down_val <= 0 then
		self.djs_txt.text = "00:00:00"
		self:MyRefresh()
	else
		local hh = math.floor(self.down_val / 3600)
		local ff = math.floor((self.down_val % 3600) / 60)
		local mm = self.down_val % 60
		self.djs_txt.text = string.format("%02d:%02d:%02d", hh, ff, mm)
		local xx = self.down_val / self.cfg.close_cd_hf[2]
		xx = math.ceil(xx * self.cfg.close_cd_hf[1])
		self.needjb = xx
		self.needjb_txt.text = "x" .. StringHelper.ToCash(xx)
	end
end



function C:on_XYCB_BK_OnDJClick_msg(index)
	if self.index ~= index then
		self.open_btn.gameObject:SetActive(false)
		self.open_now_btn.gameObject:SetActive(false)
		if self.cb_state == XYCB_State.WaitOpen then
			self.open_node.gameObject:SetActive(true)
		end
	end
end

function C:OnBGClick()
	--dump("<color=green>++++++++++++++++++++++++++</color>")
	self.bg_btn.gameObject:SetActive(false)
	self.open_btn.gameObject:SetActive(false)
	self.open_now_btn.gameObject:SetActive(false)
	local bk_data = M.m_data.caibei_all_info[self.index]
	if bk_data and bk_data.state == 1 then
		self.open_node.gameObject:SetActive(true)
	end
end