

local basefunc = require "Game/Common/basefunc"

BY3DJsEnterPrefab = basefunc.class()
local C = BY3DJsEnterPrefab
C.name = "BY3DJsEnterPrefab"
local c_data = {}
local M = BY3DJCManager

function C.Create(parm)
	return C.New(parm)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["enter_model_get_award_pool_num_msg"]=basefunc.handler(self, self.enter_model_get_award_pool_num_msg)
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

function C:ctor(parm)
	self.parm = parm
	local parent = parm.parent
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	EventTriggerListener.Get(self.explain_btn.gameObject).onClick = basefunc.handler(self, self.OnPlayerExplainClick)
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	if M.IsCreateZMCJPanel() then
		self.glow_01.gameObject:SetActive(true)	
	else
		self.glow_01.gameObject:SetActive(false)	
	end
end


function C:enter_model_get_award_pool_num_msg(data)
    self.score_txt.text=math.floor(BY3DJCManager.GetAwardPoolAll()/10000) .."万"
end

function C:OnPlayerExplainClick()
	BY3DJCZMCDJPanel.Create()
end