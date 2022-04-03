-- 创建时间:2020-05-11
-- Panel:Act_040_MSLBPanel
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

Act_040_MSLBPanel = basefunc.class()
local C = Act_040_MSLBPanel
C.name = "Act_040_MSLBPanel"
C.instance = nil
local M = Act_040_MSLBManager
function C.Create()
	if C.instance then
		C.instance:MyRefresh()
		return
	end
	C.instance = C.New()
	return C.instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_mslb_data_change_msg"] = basefunc.handler(self,self.MyRefresh)
    self.lister["model_mslb_qfxl_num_change_msg"] = basefunc.handler(self,self.MyRefresh)
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["model_mslb_receive_award_change_msg"] = basefunc.handler(self,self.on_model_mslb_receive_award_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	M.update_time_benefits(false)
	if self.cutdown_timer then
		self.cutdown_timer:Stop()
	end
	self:Exit()
	self:RemoveListener()
	C.instance = nil
	destroy(self.gameObject)
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv5").transform
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
	dump(11,"<color=red>初始化秒杀礼包！！！！</color>")
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
	M.QueryData()
	M.update_time_benefits(true)
	local config=M.GetActivityConfig()
	if config.act_time and config.act_time~=""then
		local sta_t = self:GetFortTime(config.start_time)
		local end_t = self:GetFortTime(config.seven_time)
		self.cutdown_txt.text=sta_t .."-".. end_t
	else
		self.cutdown_timer=CommonTimeManager.GetCutDownTimer(config.seven_time,self.sale_time_txt)
	end

end
function C:GetFortTime(_time)
    return string.sub(os.date("%m月%d日%H:%M",_time),1,1) ~= "0" and os.date("%m月%d日%H:%M",_time) or string.sub(os.date("%m月%d日%H:%M",_time),2)
end
function C:MyRefresh()
	if not self.Act_040_MSLBLotteryPanel_pre then
		self.Act_040_MSLBLotteryPanel_pre = Act_040_MSLBLotteryPanel.Create(self.left_node.transform)
	end
	if M.GetBuyTime() == 0 then
		self.sale_time_txt.gameObject:SetActive(true)
		--self.sale_bg_img.gameObject:SetActive(true)

		if not self.Act_040_MSLBBeforeBuyPanel_pre then
			self.Act_040_MSLBBeforeBuyPanel_pre = Act_040_MSLBBeforeBuyPanel.Create(self.right_node.transform)
		end
		if self.Act_040_MSLBAfterBuyPanel_pre then
			self.Act_040_MSLBAfterBuyPanel_pre:MyExit()
			self.Act_040_MSLBAfterBuyPanel_pre = nil
		end
	else
		self.sale_time_txt.gameObject:SetActive(false)
		--self.sale_bg_img.gameObject:SetActive(false)

		if not self.Act_040_MSLBAfterBuyPanel_pre then
			self.Act_040_MSLBAfterBuyPanel_pre = Act_040_MSLBAfterBuyPanel.Create(self.right_node.transform)
		end
		if self.Act_040_MSLBBeforeBuyPanel_pre then
			self.Act_040_MSLBBeforeBuyPanel_pre:MyExit()
			self.Act_040_MSLBBeforeBuyPanel_pre = nil
		end
	end
end

function C:Exit()
	if self.Act_040_MSLBLotteryPanel_pre then
		self.Act_040_MSLBLotteryPanel_pre:MyExit()
		self.Act_040_MSLBLotteryPanel_pre = nil
	end
	if self.Act_040_MSLBAfterBuyPanel_pre then
		self.Act_040_MSLBAfterBuyPanel_pre:MyExit()
		self.Act_040_MSLBAfterBuyPanel_pre = nil
	end
	if self.Act_040_MSLBBeforeBuyPanel_pre then
		self.Act_040_MSLBBeforeBuyPanel_pre:MyExit()
		self.Act_040_MSLBBeforeBuyPanel_pre = nil
	end
end

function C:OnBackClick()
	Event.Brocast("Panel_back_mslb")
	self:MyExit()
end

function C:on_model_mslb_receive_award_change_msg()
	if M.GetLoginDay() == 7 then
		--播放抽奖次数增加的特效
		newObject("Act_040_MSLB_lxdl",self.transform)
	end
end