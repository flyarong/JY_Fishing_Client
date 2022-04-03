-- 创建时间:2020-05-11
-- Panel:Fishing3DHLDeadPrefab
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 --]]

local basefunc = require "Game/Common/basefunc"

Fishing3DHLDeadPrefab = basefunc.class()
local C = Fishing3DHLDeadPrefab
C.name = "Fishing3DHLDeadPrefab"

function C.Create(skill_data)
	return C.New(skill_data)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
    self.lister["EnterBackGround"] = basefunc.handler(self, self.on_background_msg)
    self.lister["skill_fish_explode_dead_msg"] = basefunc.handler(self, self.on_skill_fish_explode_dead_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.seq then
		self.seq:Kill()
		self.seq = nil
	end
	if IsEquals(self.sw1_obj) then
		destroy(self.sw1_obj)
		self.sw1_obj = nil
	end

	if self.fish and self.fish.MyExit then
		self.fish:MyExit()
	end
	self:RemoveListener()
end

function C:ctor(skill_data)
	self.skill_data = skill_data

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.seat_num = self.skill_data.seat_num
	self.score = self.skill_data.add_score or 0
	if self.skill_data and self.skill_data.id_list then
		self.id_map = {}
		for k,v in ipairs(self.skill_data.id_list) do
			self.id_map[v] = 1
		end
	end

	self:MyRefresh()
end

function C:MyRefresh()
	local fish_data = {}
	fish_data.fish_id = -1
	fish_data.path = 61
    fish_data.fish_type = 36
    local use_fish_cfg = FishingModel.Config.use_fish_map[fish_data.fish_type]
    local panel = FishingLogic.GetPanel()
    local node = panel:GetTSPathNode(fish_data.path, use_fish_cfg.fish_id)
    self.fish = Fish3DHYLong.Create(node, fish_data)
    self.fish.fish_speed = 1
    self.fish:SetBox2D(false)
    self.fish.anim_pay:Play("die", -1, 0)

    self.seq = DoTweenSequence.Create()
	self.seq:AppendInterval(3.3)
	self.seq:AppendCallback(function ()
		FishingAnimManager.PlayShowAndHideFX(panel.FlyGoldNode.transform, "Fish3D052_siwang_03", Vector3.zero, 2, nil, nil)
	end)
	self.seq:AppendInterval(2)
	self.seq:OnKill(function ()
		if self.fish and self.fish.MyExit then
			self.fish:MyExit()
			self.fish = nil
		end
		self:BeginAnim()
		self.seq = nil
	end)
end

function C:BeginAnim()
	Event.Brocast("ui_shake_screen_msg", 2, 0.6)
	local panel = FishingLogic.GetPanel()

	self.sw1_obj = newObject("Fish3D052_siwang_01", panel.FlyGoldNode.transform)
	local sw1_tran = self.sw1_obj.transform
	local call = function (skill_id)
		local data = {}
		data.msg_type = "activity"
		data.type = FishingSkillManager.FishDeadAppendType.Boom
		data.id = skill_id
		data.seat_num = self.seat_num
		data.status = 0
	    data.parm = "huolong"

		Event.Brocast("model_dispose_skill_data", data)
	end

	if self.skill_data.id_list then
		-- 发送技能
		call(self.skill_data.id_list[#self.skill_data.id_list])
	else
		self:MyExit()
	end
end
function C:PlayAnim()
	local panel = FishingLogic.GetPanel()

	FishingAnimManager.PlayHLJS(panel.FlyGoldNode.transform, self.moneys, self.seat_num, 36, "fishing3D_shayu_jiesuan_long")

	self.seq = DoTweenSequence.Create()
	self.seq:AppendInterval(10)
	self.seq:AppendCallback(function ()
		if IsEquals(self.sw1_obj) then
			destroy(self.sw1_obj)
			self.sw1_obj = nil
		end
		FishingAnimManager.PlayShowAndHideFX(panel.FlyGoldNode.transform, "Fish3D052_siwang_02", Vector3.zero, 1)
	end)
	self.seq:AppendInterval(1)
	self.seq:OnKill(function ()
		if self.fish_ids then
			for k,v in ipairs(self.fish_ids) do
				local fish = FishManager.GetFishByID(v)
				if fish then
	                fish:Dead()
	            end
			end
		end
		self.seq = nil
		self:MyExit()
	end)
	self.seq:OnForceKill(function ()
		if IsEquals(self.sw1_obj) then
			destroy(self.sw1_obj)
			self.sw1_obj = nil
		end
	end)
end

function C:OnExitScene()
	self:MyExit()
end
function C:on_skill_fish_explode_dead_msg(data)
	if self.id_map and self.id_map[data.id] then
		self.moneys = data.moneys
		self.moneys[#self.moneys + 1] = self.score
		self.fish_ids = data.fish_ids
		for k, v in ipairs(self.fish_ids) do
			local fish = FishManager.GetFishByID(v)
            if fish then
                fish:CloseFishID()
            end
		end
		self:PlayAnim()
	end
end

function C:on_background_msg()
	self:MyExit()
end