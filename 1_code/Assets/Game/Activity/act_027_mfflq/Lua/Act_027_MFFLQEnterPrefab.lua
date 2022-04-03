-- 创建时间:2020-04-09


local basefunc = require "Game/Common/basefunc"

Act_027_MFFLQEnterPrefab = basefunc.class()
local C = Act_027_MFFLQEnterPrefab
C.name = "Act_027_MFFLQEnterPrefab"
local  M = Act_027_MFFLQManager
function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["fishing_ready_finish"] = basefunc.handler(self,self.on_fishing_ready_finish)
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
	self.lister["global_hint_state_change_msg"] = basefunc.handler(self,self.on_global_hint_state_change_msg)
	self.lister["AssetChange"] = basefunc.handler(self,self.MyRefresh)
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
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject("Act_027_MFFLQEnterPrefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.click_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		PlayerPrefs.SetString(Act_027_MFFLQManager.key .. MainModel.UserInfo.user_id, os.date("%Y%m%d",os.time()))
		self:OnEnterClick()
		self:MyRefresh()
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	if Act_027_MFFLQManager.GetHintState({gotoui = Act_027_MFFLQManager.key}) == ACTIVITY_HINT_STATUS_ENUM.AT_Get then 
		self.LFL.gameObject:SetActive(true)
	else
		self.LFL.gameObject:SetActive(false)
		if PlayerPrefs.GetString(Act_027_MFFLQManager.key .. MainModel.UserInfo.user_id,0) == os.date("%Y%m%d",os.time()) then 
			self.Red.gameObject:SetActive(false)
		else
			self.Red.gameObject:SetActive(true)
		end 
	end
end

function C:OnEnterClick()
	Act_027_MFFLQPanel.Create()
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == Act_027_MFFLQManager.key then 
		self:MyRefresh()
	end 
end

function C:on_fishing_ready_finish()
    local check_can_create = function()
        return M.IsActive() and not M.IsLotteryed()
    end
    --[[if MainModel.myLocation == "game_MiniGame" then
        if check_can_create() then 
            Act_027_MFFLQPanel.Create()
        end 
    end
    if MainModel.myLocation == "game_Free" then
        if check_can_create() then 
            Act_027_MFFLQPanel.Create()
        end 
    end
    if MainModel.myLocation == "game_Match" then
        if check_can_create() then 
            Act_027_MFFLQPanel.Create()
        end 
    end--]]
    if MainModel.myLocation == "game_Fishing3D" then
        if check_can_create() then 
            Act_027_MFFLQPanel.Create()
        end 
    end
end