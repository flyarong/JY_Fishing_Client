-- 创建时间:2020-10-11
-- Panel:SYSJJSLPanel
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

SYSJJSLPanel = basefunc.class()
local C = SYSJJSLPanel
C.name = "SYSJJSLPanel"
local M = SYSJJSLManager


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
    self.lister["sys_jjsl_data_msg"] = basefunc.handler(self,self.on_sys_jjsl_data_msg)
    self.lister["sys_jjsl_Refresh_djs_msg"] = basefunc.handler(self,self.on_sys_jjsl_Refresh_djs_msg)
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

function C:MyClose()
	self:MyExit()
end

function C:ctor()
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
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
	EventTriggerListener.Get(self.activation_btn.gameObject).onClick = basefunc.handler(self, self.OnActivationClick)
	EventTriggerListener.Get(self.get_btn.gameObject).onClick = basefunc.handler(self, self.OnGetClick)
	M.QueryData()
end

function C:MyRefresh()
	local status = M.GetStatus()
	local level = M.GetLevel()
	local award = M.GetAward()
	dump({status = status,level = level,award = award},"<color=yellow>+++++++++++++++</color>")
	if status == 1 then--立即激活
		self.award_txt.text = award
	elseif status == 2 then--立即领取
		self.award_txt.text = award
		if level < 1991 then
			self.level_txt.text = "Lv."..level
		elseif level == 1991 then
			self.level_txt.text = "满级"
		end
	elseif status == 3 then--倒计时
		self.award_txt.text = award
		if level < 1991 then
			self.level_txt.text = "Lv."..level
		elseif level == 1991 then
			self.level_txt.text = "满级"
		end
	end
	M.RunDownCount(status == 3)
	self:SetActive(status)
end

function C:OnBackClick()
	self:MyExit()
end

function C:on_sys_jjsl_data_msg()
	self:MyRefresh()
end

function C:SetActive(status)
	self.activation_btn.gameObject:SetActive(status == 1)
	self.get_btn.gameObject:SetActive(status == 2)
	self.djs.gameObject:SetActive(status == 3)
	self.before.gameObject:SetActive(status == 1)
	self.after.gameObject:SetActive(status == 2 or status == 3)
end

function C:OnActivationClick()
	PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
end

function C:OnGetClick()
	dump("领取奖励")
	if M.GetTodayIsPay() then
		-- body
		Network.SendRequest("get_jjsl_award")
	else
		LittleTips.Create("充值任意金额即可领奖")
	end
end

function C:RefreshDJS()
	local temp = 0
	local hour = 0
	local minute = 0
	local second = 0
	temp = self.remain_time
	hour = math.floor(temp/3600)
	minute = math.floor((temp - hour*3600)/60)
	second = temp - hour*3600 - minute*60
	if string.len(hour) == 1 then
		hour = "0"..hour
	end
	if string.len(minute) == 1 then
		minute = "0"..minute
	end
	if string.len(second) == 1 then
		second = "0"..second
	end
	self.djs_txt.text = hour..":"..minute..":"..second
end

function C:on_sys_jjsl_Refresh_djs_msg(time)
	self.remain_time = time
	self:RefreshDJS()
end
