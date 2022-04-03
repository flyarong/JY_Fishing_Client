

local basefunc = require "Game/Common/basefunc"

KPSHBSMPrefabPanel = basefunc.class()
local C = KPSHBSMPrefabPanel
C.name = "KPSHBSMPrefabPanel"

function C.Create(gameType)
	return C.New(gameType)
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

function C:ctor(gameType)
	self.gameType = gameType
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	self.BackButton = tran:Find("root/BackButton"):GetComponent("Button")
	self.BackButton.onClick:AddListener(function ()
        self:OnBackClick()
    end)
end

function C:InitUI()
	self:ShowAwardById()
	self:MyRefresh()
end

function C:MyRefresh()
	if self.gameType == BY3DKPSHBManager.GameType.GT_JJ then
		self.toptext_txt.text = "在街机打鱼中发射子弹即可积攒福利券能量条，积攒能量可冲刺更高等级福利券，领取福利券后能量条清零！炮倍越高，能量积攒越快！"
	end
end

function C:OnBackClick()
    self:MyExit()
end

function C:ShowAwardById()
	local get_str_func =function (table)
		return "<color=#F97D22>"..table[1].."</color>、<color=#F97D22>"..table[2].."</color>、<color=#F97D22>"..table[3].."</color>"
	end
	for i = 1,3 do	
		local t = BY3DKPSHBManager.GetHBRateConfigByIDIndex(FishingModel.game_id, i, self.gameType)
		self["Text"..i.."_txt"].text = "<color=#1DA5FD>可获得</color>"..get_str_func(t).."<color=#1DA5FD>三种奖励，概率各为</color><color=#F97D22>33.3%</color>"
	end
end