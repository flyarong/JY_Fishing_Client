-- 创建时间:2021-01-25
-- Panel:Act_049_XYHLPanel
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

Act_049_XYHLPanel = basefunc.class()
local C = Act_049_XYHLPanel
C.name = "Act_049_XYHLPanel"
local M = Act_049_XYHLManager
function C.Create(parent)
	return C.New(parent)
end
local str = "金币"
function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["AssetChange"] = basefunc.handler(self,self.MyRefresh)
	self.lister["new_game_gift_get_cdk_response"] = basefunc.handler(self,self.on_new_game_gift_get_cdk_response)
	self.lister["new_game_gift_query_cdk_changed"] = basefunc.handler(self,self.new_game_gift_query_cdk_changed)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:StopCutDownTimer()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	Network.SendRequest("new_game_gift_query_cdk")
end

function C:InitUI()
	self.exchange_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			if GameItemModel.GetItemCount(M.JudgeType) >= M.judgeNum then
				Network.SendRequest("new_game_gift_get_cdk")
			else
				LittleTips.Create(str.."不足~")
			end
		end
	)
	self.copy_btn.onClick:AddListener(
		function()
			UniClipboard.SetText(M.cdk)
			LittleTips.Create("复制成功~")
			SYSACTBASEManager.ForceToChangeIndex(M.key,100)
		end
	)
	self.download_btn.onClick:AddListener(
		function()
			if gameRuntimePlatform == "Ios"  then
				UnityEngine.Application.OpenURL("itms-services://?action=download-manifest&url=https://cdndownload.game3396.com/install/ios/qiye/byam/byam_byam_aibianxian.plist")
				--UnityEngine.Application.OpenURL("itms-services://?action=download-manifest&url=https://cdndownload.jyhd919.cn/install/ios/qiye/cymj/normal_normal.plist")
			elseif gameRuntimePlatform == "Android" then
				UnityEngine.Application.OpenURL("http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/byam_byam.apk")
				--UnityEngine.Application.OpenURL("http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/jyddz.apk")
			else
				UnityEngine.Application.OpenURL("http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/byam_byam.apk")
				--UnityEngine.Application.OpenURL("http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/jyddz.apk")
			end
		end
	)
	self:CutDownTimer(true)
	self:MyRefresh()
end

function C:MyRefresh()
	self.prop_txt.text = M.judgeNum
	self.cur_txt.text = "x" .. StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	self:RefreshNode()
end

function C:new_game_gift_query_cdk_changed()
	self:RefreshNode()
end

function C:RefreshNode()
	if M.cdk then
		self.cdk_txt.text = "礼包码:"..M.cdk
		--self.cut_down_txt.transform.localPosition = Vector3.New(0,318,0)
		self["1_node"].gameObject:SetActive(false)
		self["2_node"].gameObject:SetActive(true)
	else
		--self.cut_down_txt.transform.localPosition = Vector3.New(17,203,0)
		self["1_node"].gameObject:SetActive(true)
		self["2_node"].gameObject:SetActive(false)
	end
end

function C:CutDownTimer(b)
	self:StopCutDownTimer()
	if b then
		self:RefreshCutDown()
		self.cut_down_timer = Timer.New(function ()
			self:RefreshCutDown()
		end,1,-1,false)
		self.cut_down_timer:Start()
	end
end

function C:StopCutDownTimer()
	if self.cut_down_timer then
		self.cut_down_timer:Stop()
		self.cut_down_timer = nil
	end
end

function C:RefreshCutDown()
	self.cutdown_timer=CommonTimeManager.GetCutDownTimer(M.end_time,self.cut_down_txt)
	-- local temp = M.end_time - os.time()
	-- local str = os.date("%d天%H小时%M分%S秒",temp)
	--self.cut_down_txt.text = "剩余时间:"..str
end

function C:on_new_game_gift_get_cdk_response(_,data)
	if data and data.result == 0 then
		Act_049_XYHLHintPanel.Create()
	end
end