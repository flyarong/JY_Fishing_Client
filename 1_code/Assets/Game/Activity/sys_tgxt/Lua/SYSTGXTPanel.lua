-- 创建时间:2020-07-29
-- Panel:SYSTGXTPanel
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

SYSTGXTPanel = basefunc.class()
local C = SYSTGXTPanel
C.name = "SYSTGXTPanel"
local M = SYSTGXTManager
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
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["query_fake_data_response"] = basefunc.handler(self, self.on_query_fake_data_response)
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
	
	self.finger_mybutton = self.fingerbtn.transform:GetComponent("MyButton")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.finger_mybutton.gameObject).onClick = basefunc.handler(self, self.OnFingerClick)
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.on_BackClick)
	EventTriggerListener.Get(self.invite_btn.gameObject).onClick = basefunc.handler(self, self.on_InviteClick)
	EventTriggerListener.Get(self.copy_btn.gameObject).onClick = basefunc.handler(self, self.on_CopyClick)
	EventTriggerListener.Get(self.gain_btn.gameObject).onClick = basefunc.handler(self, self.on_GainClick)
	EventTriggerListener.Get(self.my_award_btn.gameObject).onClick = basefunc.handler(self, self.on_MyAwardClick)

	self.copy_btn.gameObject:SetActive(M.IsShowInviteCode())

	self.mycode_txt.text = M.GetMyInviteCode()
	if PlayerPrefs.GetInt(M.key..MainModel.UserInfo.user_id.."tgxt_finger",0) == 0 then
		self.finger.gameObject:SetActive(true)
	else
		self.finger.gameObject:SetActive(false)
	end

	self.pmd_pre = CommonPMDManager.Create(self, self.CreatePMD, {actvity_mode=2,time_scale=1,dotweenLayerKey = "systgxt"})
	self.pmd_t = Timer.New(function ()
		self:QueryPMD()
	end,3,-1)
	self.pmd_t:Start()
	self:QueryPMD()

	self:MyRefresh()
end

function C:MyRefresh()
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "cpl_notcjj", is_on_hint = true}, "CheckCondition")
	if a and b then
		self.t_txt.text = "好友兑换3元奖励金"
	else
		self.t_txt.text = "好友兑换1次奖励"
	end
end

function C:OnFingerClick()
	PlayerPrefs.SetInt(M.key..MainModel.UserInfo.user_id.."tgxt_finger",os.time())
	self.finger.gameObject:SetActive(false)
end

function C:on_BackClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:MyExit()
end

function C:on_InviteClick()
	
	if self.now_tiem and os.time() - self.now_tiem < 2   then
		LittleTips.Create("点击太过频繁")
		return
	end
	self.now_tiem = os.time()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local curBgCoNfig = M.GetShareCfg()
	local index = math.random(1,#curBgCoNfig)
	GameButtonManager.RunFunExt("sys_fx", "TYShareImage", nil, {fx_type="tgxt", share_bg = curBgCoNfig[index]}, function (str)
	end)
end

function C:on_CopyClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	UniClipboard.SetText( M.GetMyInviteCode() )
	LittleTips.Create("复制成功！")
end

function C:on_GainClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:OpenHelpPanel()
end

function C:on_MyAwardClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	SYSTGXTMyAwardPanel.Create()
end

function C:OpenHelpPanel()
	-- local str = M.config.help_info[1]
	-- for i = 2, #M.config.help_info do
	-- 	str = str .. "\n" .. M.config.help_info[i]
	-- end
	-- self.introduce_txt.text = str
	-- IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
	SYSTGXTZQJCPanel.Create()
end

-- 跑马灯
function C:on_query_fake_data_response(_, data)
	if data.result == 0 and data.data_type == "tgy_broadcast" then
		self.pmd_pre:AddPMDData(data)
	end
end

function C:QueryPMD()
	Network.SendRequest("query_fake_data", {data_type = "tgy_broadcast"})	
end

function C:CreatePMD(data)
	local obj = GameObject.Instantiate(self.pmd, self.pmd_node.transform)
	local text = obj.transform:Find("Text"):GetComponent("Text")
	text.text = "恭喜【 " .. data.player_name .. " 】成功提取推广收益<size=48><color=#EB4C34FF>" .. data.award_data .. "</color></size>元"
	obj.gameObject:SetActive(true)
	return obj
end