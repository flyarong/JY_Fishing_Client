-- 创建时间:2020-05-06
-- 章鱼触手

local basefunc = require "Game/Common/basefunc"
Fish3DZYCS = basefunc.class()
local C = Fish3DZYCS
C.name = "Fish3DZYCS"

Fish3DZYCS.FishState = 
{
	FS_Nor="正常",
	FS_Flee="逃离",
	FS_Hit="受击",
	FS_Dead="死亡",
	FS_FeignDead="假装死亡",
}

function C:FrameUpdate()
	self.transform_ui.position = FishingModel.Get2DToUIPoint(self:GetLockPos())
end
function C.Create(parent, data)
	return C.New(parent, data)
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
function C:UpdateTransform(pos, r)
	self.transform.localPosition = Vector3.zero
	if not (self.fish_cfg and self.fish_cfg.close_rota and self.fish_cfg.close_rota == 1) then
		self.transform.rotation = Quaternion.Euler(0, 0, 0)
	end
end

function C:MyExit()
	if self.anim_time then
		self.anim_time:Stop()
		self.anim_time = nil
	end
	if self.flee_seq then
		self.flee_seq:Kill()
		self.flee_seq = nil
	end
	self:Back_iceobj()
	self:RemoveListener()
	FishManager.RemoveFishByID(self.data.fish_id)
	CachePrefabManager.Back(self.prefab_ui)

	self.anim_pay.speed = 1
	self.fish_mesh.material:SetColor("_Color", self.base_color)

	local seq = DoTweenSequence.Create()
	seq:Append(self.transform:DOScale(0, 0.5))
	seq:OnForceKill(function ()
		CachePrefabManager.Back(self.prefab)	
	end)
end

function C:ctor(parent, data)
	self.data = data

	self.panelSelf = FishingLogic.GetPanel()

	self.use_fish_cfg = FishingModel.Config.use_fish_map[data.fish_type]
	self.fish_cfg = FishingModel.Config.fish_map[self.use_fish_cfg.fish_id]

	-- 瞄准器UI
	self.prefab_ui = CachePrefabManager.Take("Fish3D084_miaozhun")
    self.prefab_ui.prefab:SetParent(self.panelSelf.FXNode)
	local tran_ui = self.prefab_ui.prefab.prefabObj.transform
	self.transform_ui = tran_ui
	self.gameObject_ui = tran_ui.gameObject
	tran_ui.localRotation = Quaternion.Euler(0, 0, 0)
	if data then
		self.gameObject_ui.name = data.fish_id
	end

	self.root_scale = 1
	self.prefab = CachePrefabManager.Take(self.fish_cfg.prefab)
    self.prefab.prefab:SetParent(parent)
	local tran = self.prefab.prefab.prefabObj.transform
	self.transform = tran
	self.gameObject = tran.gameObject
	tran.localRotation = Quaternion.Euler(0, 0, 0)
	tran.localScale = Vector3.New(1, 1, 1)
	if data then
		self.gameObject.name = data.fish_id
	end

	

	self.m_fish_state = Fish3DZYCS.FishState.FS_Nor

	self.box2d = tran:Find("box"):GetComponent("BoxCollider2D")
	self.box2d.gameObject.name = data.fish_id
	self.lock_node = tran:Find("fish3d/xb_0007_skill/Bone001/Bone003/Bone004/Bone005/Bone006")
	self.hang_node = tran:Find("hang_node")

	self.fish_tran = tran:Find("fish3d"):GetComponent("Transform")

	self.fish_mesh = tran:Find(self.fish_cfg.map_node):GetComponent("SkinnedMeshRenderer")
	local col = self.fish_mesh.material.color
	self.base_color = Color.New(col.r, col.g, col.b, col.a)

	self.anim_pay = self.fish_tran:GetComponent("Animator")

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

-- 设置层级
function C:SetLayer(order)
end
function C:Back_iceobj()
	if self.IceCubePrefab then
		local ps = self.IceCubePrefab.prefab.prefabObj:GetComponentsInChildren(typeof(UnityEngine.ParticleSystem), true)
		for i = 0, ps.Length - 1 do
			local _s = ps[i].transform.localScale
			ps[i].transform.localScale = Vector3.New(_s.x / self.ice_scale, _s.y / self.ice_scale, _s.z / self.ice_scale)
		end

		CachePrefabManager.Back(self.IceCubePrefab)
		self.IceCubePrefab = nil
		self.IceCubeAnim = nil
	end	
end

-- 修改鱼身上的特效层级
function C:ChangeLayer(obj, scale, isUp)
	local vec_scale = Vector3.New(scale, scale, scale)

	local meshs = obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.SpriteRenderer))
	local ps = obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.Renderer), true)
	obj.transform.localScale = vec_scale
	local min = 9999999
	local max = -9999999
	for i = 0, ps.Length - 1 do
		ps[i].sortingLayerName = "1"
		local _s = ps[i].transform.localScale
		ps[i].transform.localScale = Vector3.New(_s.x * scale, _s.y * scale, _s.z * scale)
		if max < ps[i].sortingOrder then
			max = ps[i].sortingOrder
		end
		if min > ps[i].sortingOrder then
			min = ps[i].sortingOrder
		end
	end
	for i = 0, meshs.Length - 1 do
		local _s = meshs[i].transform.localScale
		meshs[i].transform.localScale = Vector3.New(_s.x / scale, _s.y / scale, _s.z / scale)
	end

	for i = 0, ps.Length - 1 do
		ps[i].sortingOrder = ps[i].sortingOrder + max
	end
end
function C:InitUI()
	self.transform.localScale = Vector3.New(0.1, 0.1, 0.1)
	
	self.flee_seq = DoTweenSequence.Create()
	self.flee_seq:Append(self.transform:DOScale(1, 1))
	self.flee_seq:OnKill(function ()
		self.flee_seq = nil
	end)
end

function C:MyRefresh()
end

function C:Print()
end

-- 是否在鱼池中
function C:CheckIsInPool()
	if self.m_fish_state == Fish3DZYCS.FishState.FS_Flee or
		self.m_fish_state == Fish3DZYCS.FishState.FS_Dead or
		self.m_fish_state == Fish3DZYCS.FishState.FS_FeignDead then
		return false
	end
	return true
end
-- 是否完全在鱼池中
function C:CheckIsInPool_Whole()
	if self.m_fish_state == Fish3DZYCS.FishState.FS_Flee or
		self.m_fish_state == Fish3DZYCS.FishState.FS_Dead or
		self.m_fish_state == Fish3DZYCS.FishState.FS_FeignDead then
		return false
	end
	return true
end

-- 是否完全在鱼池外
function C:CheckIsOutPool_Whole()
	return false
end
-- 设置冰冻状态
function C:SetIceState(isIce)
	if self.m_fish_state == FishBase.FishState.FS_Dead or self.m_fish_state == FishBase.FishState.FS_Flee then
		return
	end
	self.isIce = isIce
	if isIce then
		self.anim_pay.speed = 0
		if not self:CheckIsOutPool_Whole() then
			if self.fish_cfg.ice_type == "bytx_cool1" then
				self.IceCubePrefab = CachePrefabManager.Take("IceCubePrefab1")
				self.IceCubePrefab.prefab:SetParent(self.hang_node)
			else
				self.IceCubePrefab = CachePrefabManager.Take("IceCubePrefab2")
				self.IceCubePrefab.prefab:SetParent(self.hang_node)
			end
			local tran = self.IceCubePrefab.prefab.prefabObj.transform
			tran.localPosition = Vector3.zero
			tran.localRotation = Quaternion.Euler(0, 0, 0)
			local scale = self.fish_cfg.ice_scale / self.root_scale
			self.ice_scale = scale
			self:ChangeLayer(self.IceCubePrefab.prefab.prefabObj, scale, true)
			self.IceCubeAnim = self.IceCubePrefab.prefab.prefabObj.transform:GetComponent("Animator")
			self.IceCubeAnim:Play("binrongjie_nor_anim", -1, 0)
		end
	else
		self.anim_pay.speed = 1
		self:Back_iceobj()
	end

end
-- 冰冻解封
function C:SetIceDeblocking()
end

function C:SetBox2D(b)
	self.box2d.enabled = b
end

-- 标记鱼假死
function C:SetFeignDead(b)
	if self.m_fish_state == Fish3DZYCS.FishState.FS_Dead or self.m_fish_state == Fish3DZYCS.FishState.FS_Flee then
		return
	end
	if b then
		self.m_fish_state = Fish3DZYCS.FishState.FS_FeignDead
		self:SetBox2D(false)
	else
		self.m_fish_state = Fish3DZYCS.FishState.FS_Nor
		self:SetBox2D(true)
	end
end

function C:Flee()
	if self.m_fish_state ~= Fish3DZYCS.FishState.FS_Dead and self.m_fish_state ~= Fish3DZYCS.FishState.FS_Flee and
		self.m_fish_state ~= Fish3DZYCS.FishState.FS_FeignDead then

		self.m_fish_state = Fish3DZYCS.FishState.FS_Flee
		self:SetBox2D(false)
		self:Back_iceobj()

		self.flee_seq = DoTweenSequence.Create()
		self.flee_seq:Append(self.transform:DOScale(0, 1))
		self.flee_seq:OnKill(function ()
			self.flee_seq = nil
			VehicleManager.RemoveVehicle(self.data.fish_id)
			self:MyExit()
		end)
	end
end

function C:Hit()
	if self.m_fish_state ~= Fish3DZYCS.FishState.FS_Dead and self.m_fish_state ~= Fish3DZYCS.FishState.FS_Flee then
		self.m_fish_state = Fish3DZYCS.FishState.FS_Hit
		if self.anim_time then
			self.anim_time:Stop()
		end

		self.fish_mesh.material:SetColor("_Color", Color.New(255/255, 154/255, 164/255))
		self.anim_time = Timer.New(function ()
			self.fish_mesh.material:SetColor("_Color", self.base_color)
			self.anim_time = nil
			self.m_fish_state = Fish3DZYCS.FishState.FS_Nor
		end, 0.1, 1)
		self.anim_time:Start()
	end
end

function C:Dead(_dead_index, ZZ, parm)
	self:ShowDead(_dead_index, ZZ, parm)
end

-- 死亡表现
function C:ShowDead(_dead_index, ZZ, parm)
	dump(parm, "<color=red>章鱼触手 死亡表现/color>")
	ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_bossDjisha.audio_name)
	self:SetBox2D(false)
	self.m_fish_state = Fish3DZYCS.FishState.FS_Dead
	if self.anim_time then
		self.anim_time:Stop()
	end

	VehicleManager.RemoveVehicle(self.data.fish_id)
	self.fish_mesh.material:SetColor("_Color", self.base_color)

	self:Back_iceobj()
	self.anim_pay.speed = 2
	Event.Brocast("ui_play_scene_anim_msg", "anim3")

	local call = function (skill_id)
		local data = {}
		data.msg_type = "activity"
		data.type = FishingSkillManager.FishDeadAppendType.Boom
		data.id = skill_id
		data.seat_num = parm.seat_num
		data.status = 0
	    data.parm = "zypd"

		Event.Brocast("model_dispose_skill_data", data)
	end

	local seq = DoTweenSequence.Create()
	for k,v in ipairs(parm.id_list) do
		seq:AppendCallback(function ()
			self.anim_pay:Play("skill", -1, 0)
		end)
		seq:AppendInterval(0.5)
		seq:AppendCallback(function ()
			ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_bossDpaida.audio_name)
			Event.Brocast("ui_shake_screen_msg", 0.2, 0.3)
			call(v)
		end)
		seq:AppendInterval(1)
	end
	seq:AppendCallback(function ()
		self.anim_pay.speed = 1
		self.anim_pay:Play("swim", -1, 0)
	end)
	seq:OnKill(function ()
		Event.Brocast("ui_play_scene_anim_msg", "anim2")
		self:MyExit()
	end)

	if self.data.fish_id then
		Event.Brocast("fish_out_pool", "fish_out_pool", self.data.fish_id)
	end
end

--鱼的类型
function C:GetFishType()
	return "zycs"
end

--鱼的特殊奖励？？？
function C:GetFishAward()
	return nil
end
-- 鱼的组别
function C:GetFishGroup()
	return self.data.group_id
end

-- 鱼的额外属性
function C:GetFishAttr()
	return self.use_fish_cfg.attr_id
end
-- 鱼是否是敢死队
function C:GetFishTeam()
	return self.data.isTeam
end

-- 鱼的倍率
function C:GetFishRate()
	return self.fish_cfg.rate
end
-- 锁定点
function C:GetLockPos()
	local pos = self.lock_node.transform.position
	return Vector3.New(pos.x, pos.y, 0)
end
-- 鱼的名字 图片
function C:GetFishNameToSprite()
	return self.fish_cfg.name_image
end

-- 爆炸表现 pos是爆炸鱼的坐标
function C:BoomHit(pos)
end
function C:GetPos()
	local tpos = self.transform.position
	return Vector3.New(tpos.x, tpos.y, 0)
end

function C:CloseFishID()
	if self.data.fish_id then
		self.data.fish_id = nil
	end
end
