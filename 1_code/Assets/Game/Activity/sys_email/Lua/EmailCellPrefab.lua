-- 创建时间:2018-05-30

local basefunc = require "Game.Common.basefunc"

EmailCellPrefab = basefunc.class()

EmailCellPrefab.name = "EmailCellPrefab"

local colorXZ = "<color=#FFFFFF>"
local colorZC = "<color=#FFFFFF>"
local colorTimeXZ = "<color=#5C2D0A>"
local colorTimeZC = "<color=#5C2D0A>"
local colorEnd = "</color>"
function EmailCellPrefab.Create(parent_transform, emailId, call, panelSelf)
	return EmailCellPrefab.New(parent_transform, emailId, call, panelSelf)
end

function EmailCellPrefab:ctor(parent_transform, emailId, call, panelSelf)
	self.emailId = emailId
	self.call = call
	self.panelSelf = panelSelf
	local obj = newObject("EmailCellPrefab", parent_transform)
	self.gameObject = obj
	
	self.OpenButton = obj.transform:Find("OpenButton"):GetComponent("Button")
	self.OpenImage = obj.transform:Find("OpenButton"):GetComponent("Image")
	self.SelectEmail = obj.transform:Find("SelectEmail"):GetComponent("Image")
	self.StateImage = obj.transform:Find("StateImage"):GetComponent("Image")
	self.TitleText = obj.transform:Find("TitleText"):GetComponent("Text")
	self.TimeText = obj.transform:Find("TimeText"):GetComponent("Text")
	self.TitleText_outLine = self.TitleText.transform:GetComponent("Outline")

	self.AwardHintImage = obj.transform:Find("AwardHintImage").gameObject
	self.AwardHintImage:SetActive(false)

	self.OpenButton.onClick:AddListener(function ()
		self:OnOpenEmail()
	end)

	local ise = EmailModel.IsExistAward(self.emailId)
	self.AwardHintImage:SetActive(ise)

	self:UpdateEmailState()

	local loseTime = EmailModel.GetLoseTime(self.emailId)
	if loseTime > 0 then
		self.timerUpdate = Timer.New(function ()
			self:UpdateEmailState()
		end, loseTime, 1, false)
    	self.timerUpdate:Start()
	end
end
-- 设置选中
function EmailCellPrefab:SetSelectEmail(b)
	self.SelectEmail.gameObject:SetActive(b)
	local data = EmailModel.Emails[self.emailId]
	local desc,title = EmailModel.GetEmailDesc(data)
	if b or EmailModel.IsReadState(self.emailId) then
		self.TitleText.text = colorXZ .. title .. colorEnd
		if #title>=24 then
			self.TitleText.text= "<size=32>"..colorXZ .. title .. colorEnd.."</size>"
		end
		self.TimeText.text = "<color=#323232>" .. EmailModel.GetConvertTime(data.create_time) .. colorEnd
	else
		self.TitleText.text = colorZC .. title .. colorEnd
		if #title>=24 then
			self.TitleText.text= "<size=32>"..colorXZ .. title .. colorEnd.."</size>"
		end
		self.TimeText.text = "<color=#5C2D0A>" .. EmailModel.GetConvertTime(data.create_time) .. colorEnd
	end
	if not b and EmailModel.IsReadState(self.emailId) then
		self.TitleText_outLine.effectColor = Color.New(56/255,56/255,56/255,1)
	else
		self.TitleText_outLine.effectColor = Color.New(175/255,78/255,1/255,1)
	end
	self.OpenImage.gameObject:SetActive(not b)
end
function EmailCellPrefab:UpdateEmailState()
	self.EmailState,self.EmailStateName = EmailModel.GetState(self.emailId)
	local data = EmailModel.Emails[self.emailId]
	local desc,title = EmailModel.GetEmailDesc(data)

	if EmailModel.IsReadState(self.emailId) then
		self.TitleText_outLine.effectColor = Color.New(56/255,56/255,56/255,1)
		self.StateImage.sprite = GetTexture("yx_icon_dk")
		self.StateImage:SetNativeSize()
		self.AwardHintImage:SetActive(false)
		self.OpenImage.sprite = GetTexture("ty_btn_hui")
		self.TitleText.text = colorXZ .. title .. colorEnd
		if #title>=24 then
			self.TitleText.text= "<size=32>"..colorXZ .. title .. colorEnd.."</size>"
		end
		self.TimeText.text = "<color=#323232>" .. EmailModel.GetConvertTime(data.create_time) .. colorEnd
	else
		self.TitleText_outLine.effectColor = Color.New(175/255,78/255,1/255,1)
		self.StateImage.sprite = GetTexture("yx_icon_xf")
		self.StateImage:SetNativeSize()
		self.AwardHintImage:SetActive(true)
		self.OpenImage.sprite = GetTexture("ty_btn_huang2")
		self.TitleText.text = colorZC .. title .. colorEnd
		if #title>=24 then
			self.TitleText.text= "<size=32>"..colorXZ .. title .. colorEnd.."</size>"
		end
		self.TimeText.text = "<color=#5C2D0A>" .. EmailModel.GetConvertTime(data.create_time) .. colorEnd
	end
end
function EmailCellPrefab:OnOpenEmail()
	self.call(self.panelSelf, self.emailId)
end
function EmailCellPrefab:OnDestroy()
	if self.timerUpdate then
		self.timerUpdate:Stop()
	end
	destroy(self.gameObject)
end

