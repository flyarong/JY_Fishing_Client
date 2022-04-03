-- 创建时间:2019-06-10
-- 鱼的基类

local basefunc = require "Game/Common/basefunc"
FishFarm3DBase = basefunc.class()
local M = FishFarmManager

local C = FishFarm3DBase
C.name = "FishFarm3DBase"
-- 
local is_open_sjbx = true
FishFarm3DBase.FishState = 
{
	FS_Nor="正常",
	FS_Flee="逃离",
	FS_Hit="受击",
	FS_Dead="死亡",
	FS_FeignDead="假装死亡",
}

function C.Create(parent, fishui_node, data)
	return C.New(parent, fishui_node, data)
end

function C:FrameUpdate(time_elapsed)
	local rect = self.vehicle:GetCurRect()
	self:UpdateTransform(rect.pos, rect.r, time_elapsed)
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

function C:UpdateTransform(pos, r, time_elapsed)
	self.transform.localPosition = Vector3.New(pos.x+self.py_pos.x, pos.y+self.py_pos.y, self.cur_z_val)
	if self.fishui_pre then
		self.fishui_pre:UpdateTransform(self.transform.position)
	end

	if not (self.fish_cfg and self.fish_cfg.close_rota and self.fish_cfg.close_rota == 1) then
		self.transform.rotation = Quaternion.Euler(self.gd_r_x, 0, r)
	else
		self.transform.rotation = Quaternion.Euler(self.gd_r_x, 0, 0)
	end
end

function C:MyExit()
	if self.fishui_pre then
		self.fishui_pre:MyExit()
		self.fishui_pre = nil
	end

	if self.sale_seq then
		self.sale_seq:Kill()
	end
	if IsEquals(self.fish_mesh) then
		self.fish_mesh.material.shader = UnityEngine.Shader.Find("fish3d_opt_with_shadow")
	end
	CachePrefabManager.Back(self.prefab)
end

function C:ctor(parent, fishui_node, data)
	self.parent = parent
	self.fishui_node = fishui_node
	self.data = data
	self.py_pos = self.data.py_pos or {x=0,y=0}
	self.pos = self.data.pos or Vector3.zero
	self.fish_cfg = M.GetFishing3DConfig(data.id)

	local cfg = M.GetFishConfig(data.id)
	self.fish_scale = cfg.fish_scale or 1

	-- 深度值
	-- if self.fish_cfg.fish_stratum then
	-- 	self.cur_z_val = self.fish_cfg.fish_stratum + math.random(1, 100) - 50
	-- else
	-- 	self.cur_z_val = 10000 - self.fish_cfg.id * 200 + math.random(1, 100) - 50
	-- end
	-- if self.cur_z_val < 200 then
	-- 	self.cur_z_val = 200
	-- end
	self.cur_z_val = math.random(200, 9000)
	self.gd_r_x = 90
	if cfg.rotation then
		self.gd_r_x = cfg.rotation[1]
	end

	self.fishui_pre = FishFarm3DUI.Create(self.fishui_node, self.data)

	self:RefreshFish()

	self:MakeLister()
	self:AddMsgListener()

	-- 新投放的鱼
	if self.data.is_add then
		self.fishui_pre:PlayNewAddFish()
	end
end

function C:MyRefresh()
	if self.fishui_pre then
		self.fishui_pre:MyRefresh()
	end
end

function C:PlayCollect(data)
	if self.fishui_pre then
		self.fishui_pre:PlayCollect(data)
	end
end
function C:PlayFaceAnim(cfg)
	if self.fishui_pre then
		self.fishui_pre:PlayFaceAnim(cfg)
	end
end

function C:SetVehicle(_vehicle)
	self.vehicle = _vehicle
end

function C:DORotate(r, call)
	self.rot_seq = DoTweenSequence.Create()
	self.rot_seq:Append(self.transform:DORotate(Vector3.New(self.gd_r_x, 0, r), 0.1, DG.Tweening.RotateMode.FastBeyond360))
	self.rot_seq:OnKill(function ()
		if call then
			call()
		end
	end)
end

function C:RefreshFish()
	local old_pos
	local old_rat
	if self.prefab then
		old_pos = self.transform.localPosition
		old_rat = self.transform.localRotation
		CachePrefabManager.Back(self.prefab)
		self.prefab = nil
	end

	self.fish_cfg = M.GetFishing3DConfig(self.data.id)
	self.root_scale = self.fish_scale
	self.m_fish_name = self.fish_cfg.prefab

	self.prefab = CachePrefabManager.Take(self.m_fish_name)
    self.prefab.prefab:SetParent(self.parent)
	local tran = self.prefab.prefab.prefabObj.transform
	self.transform = tran
	self.gameObject = tran.gameObject
	tran.localRotation = Quaternion.Euler(self.gd_r_x, 0, 0)
	tran.localScale = Vector3.New(self.root_scale, self.root_scale, self.root_scale)

	if self.fish_cfg.animator_node then
		self.anim_pay = tran:Find(self.fish_cfg.animator_node):GetComponent("Animator")
	else
		self.anim_pay = tran:Find("fish3d"):GetComponent("Animator")
	end
	if self.fish_cfg.map_node then
		local obj = tran:Find(self.fish_cfg.map_node)
		if IsEquals(obj) then
			self.fish_mesh = obj:GetComponent("SkinnedMeshRenderer")
		end
	end
	if IsEquals(self.fish_mesh) then
		self.fish_mesh.material.shader = UnityEngine.Shader.Find("fish3d_opt_no_shadow")
	end

	if old_pos then
		self.transform.localPosition = old_pos
		self.transform.localRotation = old_rat
	else
		self.transform.localPosition = self.pos
	end
end

-- 升级
function C:UpdateFish(id)
	print("<color=red>UpdateFish</color>")
	dump(self.data.id)
	dump(id)
	self.data.id = id
	self:RefreshFish()
end
-- 售卖
function C:Sale()
	local targetScale = 0.3
	local rr = math.random(0, 360)
    local vec = Vector3(math.cos(rr * Deg2Rad), math.sin(rr * Deg2Rad), 0) * 2
	local endPos = self.transform.position + vec
	local fdScale = self.fish_cfg.dead_scale or 2

	self.sale_seq = DoTweenSequence.Create()
	self.sale_seq:Append(self.transform:DOMove(endPos, 0.3))
	self.sale_seq:Join(self.transform:DOScale(fdScale, 0.3))
	self.sale_seq:AppendCallback(function ()
		self.anim_pay:Play("die", 0, 0)
	end)
	self.sale_seq:AppendInterval(0.5)
	self.sale_seq:Append(self.transform:DOScale(targetScale, 1))
	self.sale_seq:OnKill(function ()
		self.sale_seq = nil
		self:MyExit()
	end)
	self.sale_seq:OnForceKill(function ()
		self.sale_seq = nil
	end)
end
