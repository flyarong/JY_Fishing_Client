-- 创建时间:2020-04-26
-- Panel:CQGPanel
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

CQGPanel = basefunc.class()
local C = CQGPanel
local M = CQGManager
C.name = "CQGPanel"

C.instance = nil
function C.Create(parent, backcall)
	if C.instance then
		C.instance:MyRefresh()
		return
	end
	C.instance = C.New(parent, backcall)
	return C.instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}

    self.lister["model_cqg_data_change_msg"] = basefunc.handler(self,self.MyRefresh)
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["CQG_on_backgroundReturn_msg"] = basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.seq then
		self.seq:Kill()
	end

	if self.backcall then
		self.backcall()
	end
	M.update_time(false)
	self:RemoveListener()
	C.instance = nil
	destroy(self.gameObject)
end

function C:ctor(parent, backcall)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.backcall = backcall
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.transform.anchorMin = Vector2.New(0,0)
	self.transform.anchorMax = Vector2.New(1,1)
	self.transform.offsetMax = Vector2.New(0,0)
	self.transform.offsetMin = Vector2.New(0,0)
end

function C:InitUI()
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.back)
	EventTriggerListener.Get(self.help_btn.gameObject).onClick = basefunc.handler(self, self.help)
	EventTriggerListener.Get(self.get_btn.gameObject).onClick = basefunc.handler(self, self.get)
	EventTriggerListener.Get(self.ad_get_btn.gameObject).onClick = basefunc.handler(self, self.get)

	self.BG_vip_txt.text = "VIP"..MainModel.UserInfo.vip_level
	self.BG_text2_txt.text = "当前VIP存储上限:    "..M.ccdw_config.Info[MainModel.UserInfo.vip_level].save_max

	
	CQGManager.update_time(true)
	CQGManager.query_data(true)
	self:PlayDoTween()
end

function C:MyRefresh()
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "cjj_cqg_viplimit", is_on_hint = true}, "CheckCondition")
	if a and b then
		self.sm_txt.text = "领取"
		self.sm1_txt.text = "领取"
	else
		self.sm_txt.text = "vip1领取"
		self.sm1_txt.text = "vip1领取"
	end
	self.data = CQGManager.GetCurData()
	self.BG_jingbi_txt.text = StringHelper.ToCash(self.data.money)
	if self.data.state == 0 then--已领
		self.get_btn.gameObject:SetActive(false)
		self.ad_get_btn.gameObject:SetActive(false)
		self.already_get_img.gameObject:SetActive(true)
	else--可领
		self.already_get_img.gameObject:SetActive(false)
		if SYSQXManager.IsNeedWatchAD() and self.data.money >= 20000 then
			self.ad_get_btn.gameObject:SetActive(true)
			self.get_btn.gameObject:SetActive(false)
		else
			self.ad_get_btn.gameObject:SetActive(false)
			self.get_btn.gameObject:SetActive(true)
		end
	end
end

function C:back()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	Event.Brocast("Panel_back_cqg")
	self:MyExit()
end

function C:help()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:OpenHelpPanel()
end

function C:get()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "cjj_cqg_viplimit", is_on_hint = false}, "CheckCondition")
	if a and not b then
		return 
	end
	local call = function (b)
		dump(b, "<color=red>deposit_withdraw_money watch_ad</color>")
		Network.SendRequest("deposit_withdraw_money", {watch_ad=b}, "", function(data)
			if data.result == 0 then
				CQGManager.query_data(true)--获得今天的钱的数据
				Event.Brocast("sys_exit_ask_refresh_msg")
			else
				HintPanel.ErrorMsg(data.result)
			end
		end)--取钱
	end

	if SYSQXManager.IsNeedWatchAD() then
		if self.data.money >= 20000 then
			AdvertisingManager.RandPlay("cqg", nil, function ()
				call(1)
			end)
		else
			CQGGetHintPrefab.Create({money = self.data.money, call=function (b)
				if b == 1 then
					AdvertisingManager.RandPlay("cqg", nil, function ()
						call(1)
					end)
				else
					call(0)
				end
			end})
		end
	else
		call(0)
	end
end

local help_info_normal = {
"每次玩3D捕鱼和小游戏会自动储存一定的金币在存钱罐中",
"每日可领取前一日累计储存的金币",
"VIP1及以上玩家才可以取出存储的金币",
"每日可领取一次，每日8：00重置领取次数",
"		VIP0储存上限：300000 (30万)",
"		VIP1储存上限：600000 (60万)",
"		VIP2储存上限：1000000 (100万)",
"		VIP3储存上限：3000000 (300万)",
"		VIP4储存上限：5000000 (500万)",
"		VIP5储存上限：8000000 (800万)",
"		VIP6储存上限：10000000 (1000万)",
"		VIP7储存上限：20000000 (2000万)",
"		VIP8储存上限：30000000 (3000万)",
"		VIP9储存上限：40000000 (4000万)",
"		VIP10及以上储存上限：50000000 (5000万)",
--"		VIP11及以上储存上限：50000000 (5000万)",
}

local help_info_cjj = {
"每次玩龙王争霸和小游戏会自动储存一定的金币在存钱罐中",
"每日可领取前一日累计储存的金币",
"VIP1及以上玩家才可以取出存储的金币",
"每日可领取一次，每日8：00重置领取次数",
"		VIP0储存上限：300000 (30万)",
"		VIP1储存上限：600000 (60万)",
"		VIP2储存上限：1000000 (100万)",
"		VIP3储存上限：3000000 (300万)",
"		VIP4储存上限：5000000 (500万)",
"		VIP5储存上限：8000000 (800万)",
"		VIP6储存上限：10000000 (1000万)",
"		VIP7储存上限：20000000 (2000万)",
"		VIP8储存上限：30000000 (3000万)",
"		VIP9储存上限：40000000 (4000万)",
"		VIP10及以上储存上限：50000000 (5000万)",
--"		VIP11及以上储存上限：50000000 (5000万)",
}

function C:OpenHelpPanel()
	local help_info
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="cpl_cjj", is_on_hint = true}, "CheckCondition")
    if a and b then
    	help_info = help_info_cjj
    else
    	help_info = help_info_normal
    end
	local str = help_info[1]
	for i = 2, #help_info do
		str = str .. "\n" .. help_info[i]
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

--播放落钱动画
function C:PlayDoTween()
	self.t = math.random(3, 6)
	dump(self.t,"++++++++++++++落钱间隔秒数+++++++++++++++++")
	self.seq = DoTweenSequence.Create()
	self.seq:AppendInterval(0.967)
	self.seq:AppendCallback(function ()
		self.jingbi_diaoluo.gameObject:SetActive(false)
	end)
	self.seq:AppendInterval(self.t-0.967)
	self.seq:AppendCallback(function ()
		self.jingbi_diaoluo.gameObject:SetActive(true)
		self:PlayDoTween()
	end)
end