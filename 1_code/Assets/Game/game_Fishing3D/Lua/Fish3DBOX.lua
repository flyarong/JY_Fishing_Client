-- 创建时间:2019-05-23
-- Panel:Fish3DBOX

local basefunc = require "Game/Common/basefunc"
Fish3DBOX = basefunc.class()
local C = Fish3DBOX
C.name = "Fish3DBOX"

Fish3DBOX.FishState = 
{
	BS_Nor="正常",
	BS_Open1="微微打开",
	BS_Open2="打开",
	BS_Open3="全开",

	FS_Nor="正常",
	FS_Flee="逃离",
	FS_Hit="受击",
	FS_Dead="死亡",
	FS_FeignDead="假装死亡",
}

function C:FrameUpdate()
	
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
	self.transform.localPosition = Vector3.New(pos.x, pos.y, 0)
	if not (self.fish_cfg and self.fish_cfg.close_rota and self.fish_cfg.close_rota == 1) then
		self.transform.rotation = Quaternion.Euler(0, 0, r)
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
	self:RemoveListener()
	FishManager.RemoveFishByID(self.data.fish_id)

	for i = 1, #self.fish do
		self.fish[i].color = Color.New(1, 1, 1, 1)
	end
	self.anim_pay.speed = 1
	self.transform.localScale = Vector3.New(1, 1, 1)

	CachePrefabManager.Back(self.prefab)
	CachePrefabManager.Back(self.prefab_ui)
end

function C:ctor(parent, data)
	self.data = data

	self.panelSelf = FishingLogic.GetPanel()

	self.use_fish_cfg = FishingModel.Config.use_fish_map[data.fish_type]
	self.fish_cfg = FishingModel.Config.fish_map[self.use_fish_cfg.fish_id]

	-- UI表现
	self.prefab_ui = CachePrefabManager.Take("FishBK_UI")
    self.prefab_ui.prefab:SetParent(self.panelSelf.FXNode)
	local tran_ui = self.prefab_ui.prefab.prefabObj.transform
	self.transform_ui = tran_ui
	self.gameObject_ui = tran_ui.gameObject
	tran_ui.localRotation = Quaternion.Euler(0, 0, 0)
	if data then
		self.gameObject_ui.name = data.fish_id
	end
	self.RectImage = tran_ui:Find("Image/RectImage"):GetComponent("RectTransform")
	self.gameObject_ui:SetActive(false)

	self.prefab = CachePrefabManager.Take("Fish3DBOX")
    self.prefab.prefab:SetParent(parent)
	local tran = self.prefab.prefab.prefabObj.transform
	self.transform = tran
	self.gameObject = tran.gameObject
	tran.localRotation = Quaternion.Euler(0, 0, 0)
	if data then
		self.gameObject.name = data.fish_id
	end

	self.m_fish_state = Fish3DBOX.FishState.FS_Nor

	self.box2d = tran:GetComponent("BoxCollider2D")
	self.lock_node = tran:Find("lock_node")
	self.hang_node = tran:Find("hang_node")

	self.fish_list = {"fish3d/node/box1", "fish3d/node/box2", "fish3d/node/box3", "fish3d/node/box4", "fish3d/node/box5", "fish3d/node/jb1"}
	self.fish = {}
	for i = 1, #self.fish_list do
		self.fish[#self.fish + 1] = tran:Find(self.fish_list[i]):GetComponent("SpriteRenderer")
	end
	self.fish_tran = tran:Find("fish3d"):GetComponent("Transform")

	self.anim_pay = self.fish_tran:GetComponent("Animator")

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.max_ui_len = 134
	self:UpdateChangeData({data={self.data.ori_life}})
end

-- 设置层级
function C:SetLayer(order)
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
	self:SetBox2D(false)
	self.gameObject:SetActive(false)
	self.gameObject_ui:SetActive(false)
end

function C:MyRefresh()
end

-- 刷新数据改变
function C:UpdateChangeData(data)
	if not data or not data.data or #data.data ~= 1 then
		dump(data, "<color=red>贝壳鱼血量</color>")
		return
	end
	
	local rr = data.data[1]/self.data.ori_life
	if rr > 1 then
		rr = 1
	end
	local ww = self.max_ui_len * rr	
	self.RectImage.sizeDelta = {x=ww, y=26}
	local box_fish_anim = {0.6,0.2}
	local state = 3
	for i = 1, #box_fish_anim do
		if rr >= box_fish_anim[i] then
			state = i
			break
		end
	end
	if state == 1 then
		self:RefreshAnim(Fish3DBOX.FishState.BS_Nor)
	elseif state == 2 then
		self:RefreshAnim(Fish3DBOX.FishState.BS_Open1)
	else
		self:RefreshAnim(Fish3DBOX.FishState.BS_Open2)
	end
end
function C:RefreshAnim(state)
	if self.box_state and self.box_state == state then
		return
	end

	self.box_state = state
	if self.box_state == Fish3DBOX.FishState.BS_Nor then
		self.anim_pay:Play("Fish3DBOX_baoxiang_1", -1, 0)
	elseif self.box_state == Fish3DBOX.FishState.BS_Open1 then
		self.anim_pay:Play("Fish3DBOX_baoxiang_2", -1, 0)
	elseif self.box_state == Fish3DBOX.FishState.BS_Open2 then
		self.anim_pay:Play("Fish3DBOX_baoxiang_3", -1, 0)
	else
		self.anim_pay:Play("Fish3DBOX_baoxiang_4", -1, 0)
	end
end

function C:CreateFinish()
	print("<color=red>CreateFinishCreateFinishCreateFinish</color>")
	self:SetBox2D(true)
	self.gameObject:SetActive(true)
	self.gameObject_ui:SetActive(true)
	self.transform_ui.position = FishingModel.Get2DToUIPoint(self.transform.position)
end

function C:Print()
end

-- 是否在鱼池中
function C:CheckIsInPool()
	return true
end
-- 是否完全在鱼池中
function C:CheckIsInPool_Whole()
	if self.m_fish_state == Fish3DBOX.FishState.FS_Flee or
		self.m_fish_state == Fish3DBOX.FishState.FS_Dead or
		self.m_fish_state == Fish3DBOX.FishState.FS_FeignDead then
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
end
-- 冰冻解封
function C:SetIceDeblocking()
end

function C:SetBox2D(b)
	self.box2d.enabled = b
end

-- 标记鱼假死
function C:SetFeignDead(b)
	if self.m_fish_state == Fish3DBOX.FishState.FS_Dead or self.m_fish_state == Fish3DBOX.FishState.FS_Flee then
		return
	end
	if b then
		self.m_fish_state = Fish3DBOX.FishState.FS_FeignDead
		self:SetBox2D(false)
	else
		self.m_fish_state = Fish3DBOX.FishState.FS_Nor
		self:SetBox2D(true)
	end
end

function C:Flee()
	if self.m_fish_state ~= Fish3DBOX.FishState.FS_Dead and self.m_fish_state ~= Fish3DBOX.FishState.FS_Flee and
		self.m_fish_state ~= Fish3DBOX.FishState.FS_FeignDead then

		self.m_fish_state = Fish3DBOX.FishState.FS_Flee
		self.gameObject_ui:SetActive(false)
		self:SetBox2D(false)

		if self.anim_time then
			self.anim_time:Stop()
		end
		local a = 1
		local sa = 0.05
		self.anim_time = Timer.New(function ()
			self.fish.color = Color.New(1, 1, 1, a)
			a = a - sa
			if a <= 0 then
				if self.anim_time then
					self.anim_time:Stop()
					self.anim_time = nil
				end
				VehicleManager.RemoveVehicle(self.data.fish_id)
				self:MyExit()
			end
		end, 0.1, -1)
		self.anim_time:Start()
	end
end

function C:Hit()
	if self.m_fish_state ~= Fish3DBOX.FishState.FS_Dead and self.m_fish_state ~= Fish3DBOX.FishState.FS_Flee then
		self.m_fish_state = Fish3DBOX.FishState.FS_Hit
		if self.anim_time then
			self.anim_time:Stop()
		end

		for i = 1, #self.fish do
			self.fish[i].color = Color.New(1, 0.1, 0.2, 1)
		end
		self.anim_time = Timer.New(function ()
			for i = 1, #self.fish do
				self.fish[i].color = Color.New(1, 1, 1, 1)
			end
			self.anim_time = nil
			self.m_fish_state = Fish3DBOX.FishState.FS_Nor
		end, 0.1, 1)
		self.anim_time:Start()
	end
end

function C:Dead(_dead_index)
	self:ShowDead(_dead_index)
end

-- 死亡表现
function C:ShowDead(_dead_index)
	ExtendSoundManager.PlaySound(audio_config.by.bgm_by_beikejiangli.audio_name)
	self.gameObject_ui:SetActive(false)
	self:SetBox2D(false)
	self.m_fish_state = Fish3DBOX.FishState.FS_Dead
	if self.anim_time then
		self.anim_time:Stop()
	end

	if self.data.fish_id then
		VehicleManager.RemoveVehicle(self.data.fish_id)
	end
	for i = 1, #self.fish do
		self.fish[i].color = Color.New(1, 1, 1, 1)
	end
	local dead_index = 1
	if _dead_index then
		dead_index = _dead_index
	end

	self.anim_pay:Play("Fish3DBOX_baoxiang_4", -1, 0)

	local step_t = 0.1
	local all_t = 2
	local run_t = 0
	self.anim_time = Timer.New(function ()
		local a = (all_t-run_t) / all_t
		local b = run_t / all_t
		for i = 1, #self.fish do
			self.fish[i].color = Color.New(1, 1, 1, a)
		end

		run_t = run_t + step_t
		if run_t >= all_t then
			self.anim_time:Stop()
			self.anim_time = nil
			self:MyExit()
		end
	end, step_t, -1)
	self.anim_time:Start()

	if self.data.fish_id then
		Event.Brocast("fish_out_pool", "fish_out_pool", self.data.fish_id)
	end
end

--鱼的类型
function C:GetFishType()
	return "bk"
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
	return self.lock_node.transform.position
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
