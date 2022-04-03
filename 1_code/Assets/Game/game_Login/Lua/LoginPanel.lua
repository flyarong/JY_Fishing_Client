local basefunc = require "Game.Common.basefunc"

package.loaded["Game.game_Login.Lua.NoticeConfig"] = nil
require "Game.game_Login.Lua.NoticeConfig"

package.loaded["Game.game_Login.Lua.LoginNotice"] = nil
require "Game.game_Login.Lua.LoginNotice"

package.loaded["Game.game_Login.Lua.LoginPhonePanel"] = nil
require "Game.game_Login.Lua.LoginPhonePanel"

local NeedJumpSystems = {
	"Ios"
}

local NeedJumpPlatforms = {
	"cjj"
}

local NeedJumpChannels = {
	"cjj_juxiangpc"
}

local function IsContain(key, tbl)
	tbl = tbl or {}
	if #tbl <= 0 then return false end
	for _, v in pairs(tbl) do
		if v == "" or v == key then return true end
	end
	return false
end

local function IsNeedReinstall()
	local system = gameRuntimePlatform
	local platform = gameMgr:getMarketPlatform()
	local channel = gameMgr:getMarketChannel()

	if not IsContain(system, NeedJumpSystems) then return false end
	if not IsContain(platform, NeedJumpPlatforms) then return false end
	if not IsContain(channel, NeedJumpChannels) then return false end

	local url = MainLogic.GetSYSUpURL()

	return true, url
end

-- require "Game.CommonPrefab.Lua.ParticleManager" --特效
LoginPanel = basefunc.class()

LoginPanel.name = "LoginPanel"

local instance
function LoginPanel.Create()
	DSM.PushAct({panel = "LoginPanel"})
	instance=LoginPanel.New()
	return createPanel(instance,LoginPanel.name)
end
function LoginPanel.Bind()
	local _in=instance
	instance=nil
	return _in
end

--启动事件--
function LoginPanel:Awake()
	ExtPanel.ExtMsg(self)

	LuaHelper.GeneratingVar(self.transform, self)
end

function LoginPanel:Start()
	local tran = self.transform
	self.XYButtonImage = tran:Find("TopUI/XYButtonImage")
	self.XYBack = tran:Find("TopUI/XYNode/BackImage")
	self.XYNode = tran:Find("TopUI/XYNode")
	self.Content = tran:Find("TopUI/XYNode/ScrollView/Viewport/Content"):GetComponent("RectTransform")
	self.GameXYText = tran:Find("TopUI/XYNode/ScrollView/Viewport/Content/GameXYText"):GetComponent("Text")
	self.GameXYText.text = LoginLogic.GameXY

	self.behaviour:AddClick(self.login_phone_btn.gameObject, LoginPanel.OnLoginPhoneClick, self)
	self.behaviour:AddClick(self.login_phone_close_btn.gameObject, LoginPanel.OnLoginPhoneCloseClick, self)
	if GameGlobalOnOff.WXLoginChangeToYK then
		self.behaviour:AddClick(self.login_wx_btn.gameObject, LoginPanel.OnLoginYKClick, self)
	else
		self.behaviour:AddClick(self.login_wx_btn.gameObject, LoginPanel.OnLoginWXClick, self)
	end
	self.behaviour:AddClick(self.login_wx_close_btn.gameObject, LoginPanel.OnLoginWXCloseClick, self)
	self.behaviour:AddClick(self.login_btn.gameObject, LoginPanel.OnLoginYKClick, self)
	self.behaviour:AddClick(self.delete_visitor_btn.gameObject, LoginPanel.OnBtnDeleteVisitorClick, self)
	self.behaviour:AddClick(self.login_ipf_btn.gameObject, LoginPanel.OnLoginIpfClick, self)
	self.behaviour:AddClick(self.XYButtonImage.gameObject, LoginPanel.OnXYClick, self)
	self.behaviour:AddClick(self.XYBack.gameObject, LoginPanel.OnXYBackClick, self)
	self.behaviour:AddClick(self.GXK_btn.gameObject, LoginPanel.OnGXKClick, self)
	self.behaviour:AddClick(self.repair_btn.gameObject, LoginPanel.OnRepairClick, self)
	self.behaviour:AddClick(self.service_btn.gameObject, LoginPanel.OnServiceClick, self)

	self.Cheat = tran:Find("Cheat")

	--version
	local vf = resMgr.DataPath .. "udf.txt"
	if File.Exists(vf) then
		local luaTbl = json2lua(File.ReadAllText(vf))
		if luaTbl then
			local versionTxt = tran:Find("Version_txt"):GetComponent("Text")
			versionTxt.text = "Ver:" .. luaTbl.version .. " " .. gameMgr:getMarketChannel()
		end
	end

	self.BG = tran:Find("com_jz_prefab/BG")
	MainModel.SetGameBGScale(self.BG)

	-- RectJH.Create(self.login_wx_btn.gameObject,1,{x=0,y=20},0.7)
	local needReinstall, url = IsNeedReinstall()
	if needReinstall then
		print("need reinstall:" .. url)
		HintPanel.Create(1, "下载最新版本，全新体验升级", function()
			Event.Brocast("sys_quit", url)
			return false
		end)
	else
		self:OnStart()
	end

	self:OnOff()

	HandleLoadChannelLua("LoginPanel", self)
end

function LoginPanel:CheatButtonClick(key)
	self.cheatPwd = self.cheatPwd .. key
	--print("key:" .. key .. ", " .. self.cheatPwd)
	if self.cheatPwd == "264153" then
		self.cheatPwd = ""
		LoginLogic.checkServerStatus = false
		package.loaded["Game.game_Login.Lua.CheatPanel"] = nil
		require "Game.game_Login.Lua.CheatPanel"
		CheatPanel.Create()

		self.login_btn.gameObject:SetActive(true)
		self.login_btn.transform.localPosition = Vector3.New(366, 0, 0)
	end
end

function LoginPanel:CheatCtrlButtonClick()
	local tran = self.transform

	self.cheatCtrlCount = self.cheatCtrlCount + 1
	if self.cheatCtrlCount >= 6 then
		self.cheatCtrlCount = 0

		for i = 1, 6, 1 do
			local btn = self.Cheat.transform:Find("cbtn_" .. i)
			btn.gameObject:SetActive(true)
		end
	end

	for i = 1, 6, 1 do
		local img = self.Cheat.transform:Find("cbtn_" .. i):GetComponent("Image")
		img.color = Color.New(1, 1, 1, 0.5)
	end
	self.cheatPwd = ""
end

function LoginPanel:OnOff()
	local way = LoginModel.GetLastLoginWay()
	if way and way == "phone" then
		self.login_btn.gameObject:SetActive(false)
		self.login_phone_btn.gameObject:SetActive(true)
	else
		self.login_btn.gameObject:SetActive(true)
		self.login_phone_btn.gameObject:SetActive(true)
	end


    local channel_type = gameMgr:getMarketPlatform()
	if channel_type == "cjj" then
		self.login_btn.gameObject:SetActive(false)
		self.login_wx_btn.gameObject:SetActive(true)
		self.login_phone_btn.gameObject:SetActive(false)
	else
		self.login_wx_btn.gameObject:SetActive(GameGlobalOnOff.WXLogin)
	end

	-- 官方关闭游客登录 2021/03/02 8:00 开启微信登陆
	local market_channel = gameMgr:getMarketChannel()
	if channel_type == "normal" then
		self.login_btn.gameObject:SetActive(false)
		self.login_wx_btn.gameObject:SetActive(true)
		local sj_img = self.login_phone_btn.transform:GetComponent("Image")
		sj_img.sprite = GetTexture("zr_btn_sjdl")
		sj_img:SetNativeSize()
		self.login_wx_btn.transform.localPosition = Vector3.New(0, -318, 0)
		self.login_phone_btn.transform.localPosition = Vector3.New(366, -324, 0)
	end


	-- 测试需求 打开
	if AppDefine.IsEDITOR() and AppDefine.IsForceOpenYK then
		self.login_btn.gameObject:SetActive(true)
		self.login_btn.transform.localPosition = Vector3.New(366, 0, 0)
	end

	self.delete_visitor_btn.gameObject:SetActive(GameGlobalOnOff.FPS)
	self.login_wx_close_btn.gameObject:SetActive(GameGlobalOnOff.FPS)
	self.login_phone_close_btn.gameObject:SetActive(GameGlobalOnOff.FPS)
end
function LoginPanel:OnStart()
	local tran = self.transform

	if gameMgr:HasUpdated() and gameMgr:NeedRestart() then
		print("Has Update need restart ....")
		HintPanel.Create(1, "更新完毕，请重启游戏", function ()
			--UnityEngine.Application.Quit()
			gameMgr:QuitAll()
		end)
		return
	end

	self:MakeLister()
	self:AddMsgListener()
	self.privacy = true
	self.service = true
	local ClauseHintNode = tran:Find("ClauseHintNode")
	if ClauseHintNode then
		ClauseHintPanel.Create(ClauseHintNode)
	end

	--cheatbtn
	self.cheatPwd = ""
	local cheatNode = self.Cheat
	for i = 1, 6, 1 do
		local btn = cheatNode:Find("cbtn_" .. i):GetComponent("Button")
		btn.onClick:AddListener(function ()
			local img = cheatNode:Find("cbtn_" .. i):GetComponent("Image")
			img.color = Color.red

			self:CheatButtonClick(tostring(i))
		end)
	end
	self.cheatCtrlCount = 0
	local cheatBtn = cheatNode:Find("cheat_btn"):GetComponent("Button")
	cheatBtn.onClick:AddListener(function ()
		self:CheatCtrlButtonClick()
	end)

	--redir server ip:port
	local ip = LoginLogic.TryGetIP()
	if ip and ip ~= "" then
		AppConst.SocketAddress = ip

		print("[Debug] net redir:" .. ip)
	end

	self:AutoLogin()
end

function LoginPanel:AutoLogin()
	
	if MainModel.GetIsAutoLogin() then
		LoginLogic.AutoLogin()
	end

end

--移到ClauseHintPanel
--[[
function LoginPanel:UpdateNotice()
	if gameMgr:IsFirstRun() or gameMgr:HasUpdated() then
		print("UpdateNotice update....")
		PlayerPrefs.DeleteKey("NoticeCnt")
		PlayerPrefs.DeleteKey("NoticeTime")
	end

	if not NoticeConfig then return end

	local PlayerPrefs = UnityEngine.PlayerPrefs

	local NoticeType = NoticeConfig.NoticeType or 0
	print("UpdateNotice noticeType: " .. NoticeType)
	dump(NoticeConfig)

	if NoticeType <= 0 or NoticeType > MaxNoticeType then
		PlayerPrefs.DeleteKey("NoticeCnt")
		PlayerPrefs.DeleteKey("NoticeTime")
		return
	end

	--
	--		最大次数	起始时间	截止时间	间隔
	--每次               *               *                *             *
	--每天一次           *               *                *
	--只提示一次                         *                *
	--

	local currTime = os.time()
	local currCnt = 1

	local Condition = NoticeConfig.Condition or {}

	--check time
	local StartStamp = Condition.StartStamp or 0
	local EndStamp = Condition.EndStamp or 0
	if StartStamp > 0 and currTime < StartStamp then
		print(string.format("LoginPanel:UpdateNotice currStamp(%u) not reach StartStamp(%u)", currTime, StartStamp))
		return
	end
	if EndStamp > 0 and currTime > EndStamp then
		print(string.format("LoginPanel:UpdateNotice currStamp(%u) has pass EndStamp(%u)", currTime, EndStamp))
		return
	end

	--check 只提示一次
	if NoticeType == NoticeOnce and PlayerPrefs.HasKey("NoticeTime") then
		print("LoginPanel:UpdateNotice NoticeOnce was Happen")
		return
	end

	if NoticeType == NoticeEverytime or NoticeType == NoticeEveryday then
		--check MaxCnt
		local MaxCnt = Condition.MaxCnt or 0
		if MaxCnt > 0 and PlayerPrefs.HasKey("NoticeCnt") then
			currCnt = PlayerPrefs.GetInt("NoticeCnt")
			currCnt = currCnt + 1
			if currCnt > MaxCnt then
				print(string.format("LoginPanel:UpdateNotice currCnt(%d) > MaxCnt(%d)", currCnt, MaxCnt))
				return
			end
		end

		--check IntervalStamp
		if NoticeType == NoticeEverytime then
			--check IntervalStamp
			local IntervalStamp = Condition.IntervalStamp or 0
			if IntervalStamp > 0 and PlayerPrefs.HasKey("NoticeTime") then
				local lastTime = tonumber(PlayerPrefs.GetString("NoticeTime"))
				if currTime - lastTime < IntervalStamp then
					print(string.format("LoginPanel:UpdateNotice currTime(%u) - lastTime(%u) < IntervalStamp(%d)", currTime, lastTime, IntervalStamp))
					return
				end
			end
		end

		--check 每天一次
		if NoticeType == NoticeEveryday then
			if PlayerPrefs.HasKey("NoticeTime") then
				local lastTime = tonumber(PlayerPrefs.GetString("NoticeTime"))

				local lastDate = os.date("!*t", lastTime)
				local currDate = os.date("!*t", currTime)
				if lastDate.day == currDate.day then
					print(string.format("LoginPanel:UpdateNotice currDate(%d) == lastDate(%d)", currDate.day, lastDate.day))
					return
				end
			end
		end

	end

	PlayerPrefs.SetInt("NoticeCnt", currCnt)
	PlayerPrefs.SetString("NoticeTime", tostring(currTime))

	LoginNotice.Create(LoginNoticeText)
end
]]--

--游客登录
function LoginPanel:OnLoginYKClick(go)
	LoginModel.loginData.cur_channel = "youke"
	DSM.PushAct({button = "yk_btn"})
	Event.Brocast("bsds_send_power",{key = "click_login_youke"})
	--local b = self.gxImage.gameObject.activeInHierarchy
	if self.privacy == true and self.service == true then
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		LoginLogic.YoukeLogin()
	else
		LittleTips.Create("勾选同意下方协议才能进入游戏")
	end
end

--微信登录
function LoginPanel:OnLoginWXClick(go)
	LoginModel.loginData.cur_channel = "wechat"
	DSM.PushAct({button = "wx_btn"})
	Event.Brocast("bsds_send_power",{key = "click_login_wechat"})
	--local b = self.gxImage.gameObject.activeInHierarchy
	if self.privacy == true and self.service == true then
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		LoginLogic.WechatLogin()
	else
		LittleTips.Create("勾选同意下方协议才能进入游戏")
	end
end

--手机登录
function LoginPanel:OnLoginPhoneClick(go)
	LoginModel.loginData.cur_channel = "phone"
	DSM.PushAct({button = "phone_btn"})
	Event.Brocast("bsds_send_power",{key = "click_login_phone"})
	--local b = self.gxImage.gameObject.activeInHierarchy
	if self.privacy == true and self.service == true then
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		LoginLogic.PhoneLogin()
	else
		LittleTips.Create("勾选同意下方协议才能进入游戏")
	end
end

--测试的输入登录
function LoginPanel:OnLoginIpfClick(go)
	LoginLogic.testLogin(self.user_name_ipf.text)
end

function LoginPanel:OnXYClick(go)
	self:ShowXY()
end
function LoginPanel:OnGXKClick()
	local b = self.gxImage.gameObject.activeInHierarchy
	self.gxImage.gameObject:SetActive(not b)
end
function LoginPanel:OnXYBackClick(go)
	self.XYNode.gameObject:SetActive(false)
end
function LoginPanel:ShowXY()
	self.Content.localPosition = Vector3.zero
	self.XYNode.gameObject:SetActive(true)
end

function LoginPanel:OnBtnDeleteVisitorClick(go)
	LoginLogic.clearYoukeData()
end


function LoginPanel:OnLoginWXCloseClick(go)
	LoginLogic.clearWechatData()
end

function LoginPanel:OnLoginPhoneCloseClick(go)
	LoginLogic.clearPhoneData()
end

function LoginPanel:OnRepairClick()
	if Directory.Exists(resMgr.DataPath) then
		Directory.Delete(resMgr.DataPath, true)
	end
	local web_caches = {"_shop_"}
	-- for _, v in pairs(web_caches) do
	-- 	gameWeb:ClearCookies(v)
	-- end
	UniWebViewMgr.CleanCookies()
	UniWebViewMgr.CleanCacheAll()
	HintPanel.Create(1, "修复完毕，请重新运行游戏", function ()
		--UnityEngine.Application.Quit()
		gameMgr:QuitAll()
	end)
	Event.Brocast("bsds_send_power",{key = "click_repair"})
end

function LoginPanel:OnServiceClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	--sdkMgr:CallUp("400-8882620")
	--self.service_btn.gameObject:SetActive(false)
	Event.Brocast("callup_service_center", "0592-3337189")
	Event.Brocast("bsds_send_power",{key = "click_service"})
end

function LoginPanel:MyExit()
	if self.spine then
		self.spine:Stop()
	end
	self.spine = nil

	ClauseHintPanel.Close()
	self:RemoveListener()

	destroy(self.gameObject)
end

function LoginPanel:OnDestroy()
	self:MyExit()
end

function LoginPanel:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function LoginPanel:MakeLister()
	self.lister = {}
	self.lister["upd_privacy_setting"] = basefunc.handler(self, self.upd_privacy_setting)
	self.lister["upd_service_setting"] = basefunc.handler(self, self.upd_service_setting)
	self.lister["model_phone_login_ui"] = basefunc.handler(self, self.on_model_phone_login_ui)
end

function LoginPanel:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function LoginPanel:upd_privacy_setting(value)
	self.privacy = value
end
function LoginPanel:upd_service_setting(value)
	self.service = value
end
function LoginPanel:on_model_phone_login_ui()
	if not GameGlobalOnOff.PhoneLogin then return end
	LoginPhonePanel.Create()
end

--强制大版本更新
--更次更新为Android平台升级为新广告版本,包含鲸鱼斗地主（主渠道，pc蛋蛋，闲玩，英雄鸡）
function LoginPanel:get_upgrade_url()
	local url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V1/Android/jyddz.apk"
	local marketChannel = gameMgr:getMarketChannel()
	if marketChannel == "pceggs" then
		url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V1/Android/jyddz_pceggs.apk"
	elseif marketChannel == "xianwan" then
		url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V1/Android/jyddz_xianwan.apk"
	elseif marketChannel == "yingxiongji" then
		url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V1/Android/jyddz_yingxiongji.apk"
	end
	return url
end
function LoginPanel:force_upgrade()
	HintPanel.Create(1, "请卸载旧版本，下载最新版本，全新体验升级", function()
		Event.Brocast("sys_quit", self:get_upgrade_url())
	end)
end
