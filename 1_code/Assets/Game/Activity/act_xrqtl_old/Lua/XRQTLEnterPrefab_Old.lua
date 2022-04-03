local basefunc = require "Game/Common/basefunc"

XRQTLEnterPrefab_Old = basefunc.class()
local C = XRQTLEnterPrefab_Old
C.name = "XRQTLEnterPrefab_Old"
local M = XRQTLManager_Old
function C.Create(parent)
	return C.New(parent)
end
function C:AddMsgListener()
	for proto_name, func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["global_hint_state_change_msg"] = basefunc.handler(self, self.on_global_hint_state_change_msg)
	self.lister["XRQTL_DownCount_msg"] = basefunc.handler(self,self.on_XRQTL_DownCount_msg)
	self.lister["get_task_award_response"] = basefunc.handler(self,self.on_get_task_award_response)
end

function C:RemoveListener()
	for proto_name, func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	self:StopTimer()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end


function C:ctor(parent)
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self) 
	self.transform.localPosition = Vector3.zero
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.transform:GetComponent("Button").onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)
	self.xsyd_btn.transform:GetComponent("Button").onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)
	local next_time = PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."XRQTL")
	if os.time() >= next_time then
		PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."XRQTL",0)
	end

	self:RefreshTime()
	self:MyRefresh()
end

function C:OnEnterClick()
	self.xsyd_node.gameObject:SetActive(false)
	XRQTLPanel_Old.Create()
	PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
	self:MyRefresh()
end

function C:MyRefresh()
	if not IsEquals(self.Red) then
		return
	end
	local s = M.GetHintState({gotoui= M.key})
	self.LFL.gameObject:SetActive(false)
	self.Red.gameObject:SetActive(false)
	if s == ACTIVITY_HINT_STATUS_ENUM.AT_Get then 
		self.LFL.gameObject:SetActive(true)
	end 
	if s == ACTIVITY_HINT_STATUS_ENUM.AT_Red then 
		self.Red.gameObject:SetActive(true)
	end 
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == M.key then
		self:MyRefresh()
	end
end

function C:SetTimeTXT()
	local next_time = PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."XRQTL")
	if os.time() >= next_time then
		self:StopTimer()
		self.down_count.gameObject:SetActive(false)
		PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."XRQTL",0)
	end
	local temp = 0
	local hour = 0
	local minute = 0
	temp = next_time - os.time()
	hour = math.floor(temp/3600)
	minute = math.floor((temp - hour*3600)/60)
	second = temp - hour*3600 - minute*60
	--dump({temp = temp,hour = hour, minute = minute},"<color=red>--------////-----------</color>")
	self.time_txt.text = hour.."时"..minute.."分"..second.."秒"
end

function C:DownCountTimer()
	self:StopTimer()
	self:SetTimeTXT()
	self.down_count_timer = Timer.New(function ()
		self:SetTimeTXT()
	end,1,-1,false)
	self.down_count_timer:Start()
end

function C:StopTimer()
	if self.down_count_timer then
		self.down_count_timer:Stop()
		self.down_count_timer = nil
	end
end

function C:RefreshTime()
	if PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."XRQTL") == 0 then
		--倒计时setactive(false)
		if IsEquals(self.down_count) then
			self.down_count.gameObject:SetActive(false)
		end
		self.main_icon_img.sprite = GetTexture("xrqtl_icon_1")
		self.main_icon_img:SetNativeSize()
	else
		--倒计时setactive(true)
		if IsEquals(self.down_count) then
			self.down_count.gameObject:SetActive(true)
		end
		self:DownCountTimer()
		self.main_icon_img.sprite = GetTexture("mrlq_icon_1")
		self.main_icon_img:SetNativeSize()
	end
end

function C:on_XRQTL_DownCount_msg()
	self:RefreshTime()
end

function C:on_get_task_award_response(_,data)
	if data and data.result == 0 then
		if data.id == 30021 then
			self.xsyd_node.gameObject:SetActive(true)
		end
	end
end