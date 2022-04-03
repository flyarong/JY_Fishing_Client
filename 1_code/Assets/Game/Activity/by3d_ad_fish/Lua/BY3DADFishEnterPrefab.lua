-- 创建时间:2019-06-10
-- 鱼的基类

local basefunc = require "Game/Common/basefunc"
require "Game/CommonPrefab/Lua/GameComFishMove"

BY3DADFishEnterPrefab = basefunc.class()
local M = FishFarmModel

local C = BY3DADFishEnterPrefab
C.name = "BY3DADFishEnterPrefab"
-- 
local is_open_sjbx = true
BY3DADFishEnterPrefab.FishState = 
{
	FS_Nor="正常",
	FS_Flee="逃离",
	FS_Hit="受击",
	FS_Dead="死亡",
	FS_FeignDead="假装死亡",
}

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
    self.lister["fishing_gameui_exit"] = basefunc.handler(self, self.MyExit)
    self.lister["by3d_ad_fish_close_msg"] = basefunc.handler(self, self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.update_time then
		self.update_time:Stop()
		self.update_time = nil
	end
	if self.move_pre then
		self.move_pre:MyExit()
		self.move_pre = nil
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor()
	local parent
	local pp = FishingLogic.GetPanel()
	if pp and IsEquals(pp.FishNetNode) then
		parent = pp.FishNetNode.transform
	else
		parent = GameObject.Find("Canvas/LayerLv2").transform
	end
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
	self.move_pre = GameComFishMove.Create({ map={xMin=-960, xMax=960, yMin=-540, yMax=540}, init_speed=100 })
	self.move_pre:Start()
	self.move_pre:SetEntity(self)

	self.update_time = Timer.New(function (_, time_elapsed)
        self:FrameUpdate(time_elapsed)
    end, 0.033, -1, nil, true)
	self.update_time:Start()

	self.ad_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnADClick()
	end)

	self.down_t = BY3DADFishManager.GetADFishTime()

	self:MyRefresh()
end

function C:MyRefresh()

end

function C:FrameUpdate(time_elapsed)
	self.move_pre:FrameUpdate(time_elapsed)
	self.down_t = self.down_t - time_elapsed
	if self.down_t < 0 then
		self:MyExit()
	end
end

function C:UpdateTransform(pos, r, time_elapsed)
	self.transform.localPosition = Vector3.New(pos.x, pos.y, 0)
	-- self.transform.rotation = Quaternion.Euler(0, 0, r)
end

function C:OnADClick()
	BY3DADFishPanel.Create()
end
