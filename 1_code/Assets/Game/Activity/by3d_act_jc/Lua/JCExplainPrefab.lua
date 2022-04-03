

local basefunc = require "Game/Common/basefunc"

JCExplainPrefab = basefunc.class()
local C = JCExplainPrefab
C.name = "JCExplainPrefab"

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
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
    self.lister["get_award_time_num_msg"] = basefunc.handler(self, self.get_award_time_num_msg)
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

function C:ctor()
	
	Network.SendRequest("fish_3d_query_geted_award_pool_num")
	local parent  = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:get_award_time_num_msg()

	self.BackButton = tran:Find("BackButton"):GetComponent("Button")

    self.BackButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnBackClick()
    end)

end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:OnBackClick(go)
    self:MyExit()
end

function C:get_award_time_num_msg()
	local  zmcj_time = BY3DJCManager.GetZMCJTime()
	if zmcj_time then
		for i=1,#zmcj_time do
			self["can_"..i.."_txt"].text = "持有：x"..zmcj_time[i]
		end
	else
		self.can_1_txt.text = "持有：x0"
		self.can_2_txt.text = "持有：x0"
	end
end