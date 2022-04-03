-- 创建时间:2018-07-31

local basefunc = require "Game.Common.basefunc"

BannerPanel = basefunc.class()

BannerPanel.instance = nil

function BannerPanel.Show(id)
	if BannerPanel.instance then
		BannerPanel.instance:ShowUI(id)
		return
	end
	BannerPanel.Create(id)
end
function BannerPanel.Close()
	if BannerPanel.instance then
		BannerPanel.instance:HideUI()
	end
end
-- 显示
function BannerPanel:ShowUI(id)
	local parent = GameObject.Find("Canvas/LayerLv3").transform
	self.transform:SetParent(parent)
	self.id = id
	self:InitRect()
end
-- 显示
function BannerPanel:HideUI()
	self:MyExit()
end
function BannerPanel:MyExit()
	self:RemoveListener()
	DSM.PopAct()
	BannerPanel.instance = nil
    destroy(self.gameObject)
end

function BannerPanel.Create(id)
	DSM.PushAct({panel = "BannerPanel"})
	BannerPanel.instance = BannerPanel.New(id)
    return BannerPanel.instance
end

function BannerPanel:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function BannerPanel:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end

function BannerPanel:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function BannerPanel:ctor(id)

	ExtPanel.ExtMsg(self)

	self:MakeLister()
	self:AddMsgListener()
	self.id = id
    self.parent = GameObject.Find("Canvas/LayerLv3")
    self.gameObject = newObject("BannerPanel", self.parent.transform)
    self.transform = self.gameObject.transform
    local tran = self.transform

	self:InitRect()
end
function BannerPanel:InitRect()
	if self.id then
		self:CreateBanner(self.id)
		basefunc.handler(self, self.OnBackClick)
	else
		self.showIndex = 1
		self:NextCall()
	end
end
function BannerPanel:CreateBanner(id)
	if not IsEquals(self.transform) then
		self:OnBackClick()
		return
	end
	local config = BannerModel.UIConfig.upconfigMap[id]
	if config.gotoUI and self:SpecialHandling(config) then
		local parm = {}
		SetTempParm(parm, config.gotoUI, "panel")
		parm.parent = self.transform
		parm.backcall = basefunc.handler(self, self.NextCall)
		parm.condi_key = config.condi_key
		local b,c = GameButtonManager.RunFunExt(parm.gotoui, "CheckIsShow", nil, parm)
		if b and c then
			GameManager.GotoUI(parm)
		else
			self:NextCall()
		end
	else
		dump(config, "<color=red>banner配置缺少gotoUI</color>")
		self:NextCall()
	end
end
function BannerPanel:NextCall()
	coroutine.start(function ( )
        Yield(0)
		if BannerModel.data.bannerList and self.showIndex and self.showIndex <= #BannerModel.data.bannerList then
			local id = BannerModel.data.bannerList[self.showIndex]
			PlayerPrefs.SetString("BannerRecentlyRunTime" .. id, os.time())
			self.showIndex = self.showIndex + 1
			self:CreateBanner(id)
		else
			self:OnBackClick()
		end
    end)
end

function BannerPanel:OnClick(gotoUI)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	if gotoUI and gotoUI ~= "" then
		GameManager.GotoUI({gotoui=gotoUI})
		self:HideUI()
	else
	end
end
function BannerPanel:OnBackClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	self:HideUI()
end

function BannerPanel:OnExitScene()
	self.showIndex = 999
end


-----------特殊处理
function BannerPanel:SpecialHandling(config)
	return true
	--[[if config.gotoUI[1] == "sys_act_base" and config.gotoUI[2] == "weekly" and config.gotoUI[3] == "panel" then
		--运营类活动弹窗,新玩家首次登录不弹
		if (MainModel.UserInfo.ui_config_id == 2) and (PlayerPrefs.GetInt(config.gotoUI[1]..config.gotoUI[2]..config.gotoUI[3]..config.model..MainModel.UserInfo.user_id) == 0) then
			PlayerPrefs.SetInt(config.gotoUI[1]..config.gotoUI[2]..config.gotoUI[3]..config.model..MainModel.UserInfo.user_id, 1)
			return false
		else
			return true
		end
	else
		return true
	end--]]
end