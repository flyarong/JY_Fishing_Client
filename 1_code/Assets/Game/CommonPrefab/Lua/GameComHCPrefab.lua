-- 创建时间:2020-12-04

local basefunc = require "Game/Common/basefunc"

GameComHCPrefab = basefunc.class()
local C = GameComHCPrefab
C.name = "GameComHCPrefab"
local M = BY3DHDManager

function C.Create(data, hc_call, back_call)
	return C.New(data, hc_call, back_call)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
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

function C:ctor(data, hc_call, back_call)
	self.data = data
	self.hc_call = hc_call
	self.back_call = back_call

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
	self.back_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnBackClick()
    end)
    self.hc_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnHCClick()
    end)
    self.jian_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnJianClick()
    end)
    self.jia_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnJiaClick()
    end)
    self.hc_num_max = math.floor(self.data.sp_num/self.data.hc_num)
    self.hc_num = self.hc_num_max
	self:MyRefresh()
end

function C:MyRefresh()
	self.sp_img.sprite = GetTexture(self.data.sp_image)
	self.hc_img.sprite = GetTexture(self.data.hc_image)
	self.sp_num_txt.text = self.data.sp_num .. "/" .. self.data.hc_num
	self:RefreshHC()
end

function C:RefreshHC()
	self.hc_num_txt.text = self.hc_num
	self.num_txt.text = self.hc_num

	if self.hc_num < 2 then
		self.jian_btn.gameObject:SetActive(false)
		self.no_jian.gameObject:SetActive(true)
	else
		self.jian_btn.gameObject:SetActive(true)
		self.no_jian.gameObject:SetActive(false)
	end

	if self.hc_num_max == 0 or self.hc_num == self.hc_num_max then
		self.jia_btn.gameObject:SetActive(false)
		self.no_jia.gameObject:SetActive(true)
	else
		self.jia_btn.gameObject:SetActive(true)
		self.no_jia.gameObject:SetActive(false)
	end
end

function C:OnBackClick()
	if self.back_call then
		self.back_call()
	end
	self:MyExit()
end
function C:OnHCClick()
	if self.hc_call then
		self.hc_call(self.hc_num)
	end
	self:MyExit()
end

function C:OnJianClick()
	self.hc_num = self.hc_num - 1
	self:RefreshHC()
end
function C:OnJiaClick()
	self.hc_num = self.hc_num + 1
	self:RefreshHC()
end
