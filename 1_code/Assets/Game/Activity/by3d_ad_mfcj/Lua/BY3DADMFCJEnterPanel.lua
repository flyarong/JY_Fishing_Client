-- 创建时间:2020-08-03
-- Panel:BY3DADMFCJEnterPanel
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

BY3DADMFCJEnterPanel = basefunc.class()
local C = BY3DADMFCJEnterPanel
C.name = "BY3DADMFCJEnterPanel"
local M = BY3DADMFCJManager

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
    self.lister["level_info_got"] = basefunc.handler(self,self.on_level_info_got)
    self.lister["by3d_ad_mfcj_fsg_3d_query_free_lottery"] = basefunc.handler(self,self.by3d_ad_mfcj_fsg_3d_query_free_lottery)
    self.lister["by3d_ad_mfcj_fsg_3d_use_free_lottery"] = basefunc.handler(self,self.by3d_ad_mfcj_fsg_3d_use_free_lottery)

end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:StopTime()
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
	self.enter_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)
	self.lock_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		LittleTips.Create("等级3开启，在3D捕鱼中开炮可提升等级！")
	end)
	M.QueryInfoData()
	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshLock()
	self:RefreshTime()
end
function C:RefreshLock()
	local a,b = GameButtonManager.RunFun({gotoui="sys_by_level"}, "GetLevel")
	if a and b < M.m_data.lock_level then
		self.is_lock = true
		self.enter_btn.gameObject:SetActive(false)
		self.lock_btn.gameObject:SetActive(true)
	else
		self.is_lock = false
		self.enter_btn.gameObject:SetActive(true)
		self.lock_btn.gameObject:SetActive(false)
	end
end
function C:RefreshTime()
	self.count = M.GetNum()
	self.time_num = M.GetCDTime()
	if self.count > 0 then
		if self.time_num > 0 then
			self.LFL.gameObject:SetActive(false)
			self:StartTime()
		else
			if self.is_lock then
				self.LFL.gameObject:SetActive(false)
			else
				self.LFL.gameObject:SetActive(true)
			end
		end
	else
		self.LFL.gameObject:SetActive(false)
	end
end
function C:OnEnterClick()
	if M.m_data.is_query_wc then
		BY3DADMFCJPanel.Create()
	else
		if M.m_data.result and M.m_data.result ~= 0 then
			self.is_click_open = true
			Network.SendRequest("fsg_3d_query_free_lottery", nil, "")
		else
			LittleTips.Create("数据查询还未完成")
		end
	end
end

function C:on_level_info_got()
	local a,b = GameButtonManager.RunFun({gotoui="sys_by_level"}, "GetLevel")
	if self.is_lock and (not a or b >= M.m_data.lock_level)then
		M.QueryInfoData()
	end
end

function C:by3d_ad_mfcj_fsg_3d_query_free_lottery()
	if self.is_click_open then
		self.is_click_open = false
		BY3DADMFCJPanel.Create()
	end

	self:MyRefresh()
end
function C:by3d_ad_mfcj_fsg_3d_use_free_lottery()
	self:MyRefresh()
end

function C:StartTime()
	self:StopTime()
	self.update_time = Timer.New(function ()
		self:UpdateUI(true)
	end, 1, -1)
	self.update_time:Start()
	self:UpdateUI()
end

function C:StopTime()
	if self.update_time then
		self.update_time:Stop()
		self.update_time = nil
	end
end
function C:UpdateUI(b)
	if b then
		self.time_num = self.time_num - 1
	end

	if self.time_num <= 0 then
		self:StopTime()
		self:RefreshTime()
		return
	end
end