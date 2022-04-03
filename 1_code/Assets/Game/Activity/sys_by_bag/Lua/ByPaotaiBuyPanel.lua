-- 创建时间:2020-09-28
-- Panel:ByPaotaiBuyPanel
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

ByPaotaiBuyPanel = basefunc.class()
local C = ByPaotaiBuyPanel
C.name = "ByPaotaiBuyPanel"
local M = SYSByBagManager

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
    self.lister["model_by_bag_gun_info_change"] = basefunc.handler(self,self.MyRefresh)
    self.lister["finish_gift_shop"] = basefunc.handler(self,self.on_finish_gift_shop)--完成礼包购买
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["PayPanelClosed"] = basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:KillSeq()
	self:StopShowTimer()
	self:CloseCellList()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
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
	M.QueryGunInfo()
end

function C:MyRefresh()
	self.cell_data = self:CheckCellList()
	if not self.cell_data then return end
	self:RefreshCellList()
	if not self.select_index then
		self.select_index = 1
	end
	self.CellList[self.select_index]:SetSelect(true)
	self:RefreshDesc()
end

function C:CheckCellList()
	local data = M.m_data.GunInfo
	if not data then
		data = {}
		data.barrel_list = {}
		-- HintPanel.Create(1,"没有数据！",function()
		-- 	self.panelSelf:MyExit()
		-- end)
		-- return nil
	end
	dump(data.barrel_list,"<color=red>+++++++++55555+++++++++</color>")
	self.barrel_list = data.barrel_list
	local cell_data = {}

	local callSortGun = function(v1,v2)
		--排序
		if v1.is_get == 1 and v2.is_get ~= 1 then
			return true
		elseif v1.is_get ~= 1 and v2.is_get == 1 then
			return false
		end
		if MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, v1.gift_id).price and MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, v2.gift_id).price then
			if MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, v1.gift_id).price > MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, v2.gift_id).price then
				return false
			else
				return true
			end
		end
		--[[if v1.order and v2.order then
			if v1.order < v2.order then
				return true
			elseif v1.order > v2.order then
				return false
			end
		end
		if v1.id < v2.id then
			return false
		else return true end--]]
	end

	for k,v in pairs (M.UIConfig.barrel_config) do
		cell_data[#cell_data+1] = basefunc.deepcopy(v)
		if MainModel.IsLowPlayer() and cell_data[#cell_data].ext_buy_parm then
			cell_data[#cell_data].buy_parm = cell_data[#cell_data].ext_buy_parm
		end
	end
	for k,v in pairs (self.barrel_list) do
		--服务器数据
		if v.id and cell_data[v.id] then
			if tonumber(v.time) == 0 or tonumber(v.time) > os.time() then
				
				cell_data[v.id].is_get = 1
				cell_data[v.id].time = v.time
			else
				cell_data[v.id].is_get = 0
			end
		end
	end
	for i=#cell_data,1,-1 do
		if not cell_data[i].buy_parm then
			table.remove(cell_data,i)
		end
	end
	MathExtend.SortListCom(cell_data,callSortGun)
	return cell_data
end

function C:RefreshCellList()
	self:CloseCellList()
	dump(self.cell_data,"<color=yellow>+++++++++++++++++++++</color>")
	for k,v in pairs(self.cell_data) do
		local pre = ByGunItemBuyPrefab.Create(self, v, self.Content, self.OnToggleClick, k)
		self.CellList[#self.CellList + 1] = pre
	end
end

function C:CloseCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:MyExit()
		end
	end
	self.CellList = {}
end

function C:on_finish_gift_shop(id)	
	for k,v in pairs(self.cell_data) do
		if v.gift_id == id then
			M.QueryGunInfo()
			return
		end
	end
end

function C:OnToggleClick(index)
	if self.select_index ~= index then
		self.CellList[self.select_index]:SetSelect(false)
	end
	self.select_index = index
	self.CellList[self.select_index]:SetSelect(true)
	self:RefreshDesc()
end

function C:RefreshDesc()
	dump(self.CellList[self.select_index].data,"---刷新左邊的詳情界面---")
	if self.select_index then
		local data = self.CellList[self.select_index].data
		if data then
			self:DestroyAttributeListObj()
			self.name_pt_txt.text = data.name
			if data.type_colour == 1 then
				--普通炮台
				self.type_img.gameObject:SetActive(false)
			elseif data.type_colour == 2 then
				--史诗炮台
				self.type_img.gameObject:SetActive(true)
				self.type_img.sprite = GetTexture("bb_icon_ss")
				self.type_img.transform.localScale = Vector3.New(0.8,0.8,0.8)
				self.type_img:SetNativeSize()
			elseif data.type_colour == 3 then
				--传说炮台
				self.type_img.gameObject:SetActive(true)
				self.type_img.sprite = GetTexture("bb_icon_cq")
				self.type_img.transform.localScale = Vector3.New(1,1,1)
				self.type_img:SetNativeSize()
			end
			for i=1,#data.attribute do
				local obj = GameObject.Instantiate(self.desc_img, self.attribute_node)
				dump(data.attribute_img)
				if i == 1 then
					obj.transform:GetComponent("Image").sprite = GetTexture(data.attribute_img[i])
				else
					obj.transform:GetComponent("Image").enabled = false
				end
				local tab = {}
				LuaHelper.GeneratingVar(obj.transform, tab)
				tab.desc_txt.transform:GetComponent("Text").text = data.attribute[i]
				obj.gameObject:SetActive(true)
				self.AttributeList[#self.AttributeList + 1] = obj
			end
			self:DestroyPaotaiPre()
			self.paotai_pre = newObject(data.pre_name,self.paotai_node)
			self.anim = self.paotai_pre.transform:Find("Gun"):GetComponent("Animator")
		end
		self:UpdataShowTimer()
	end
end

function C:DestroyAttributeListObj()
	if self.AttributeList then
		for k,v in pairs(self.AttributeList) do
			Destroy(v.gameObject)
		end
	end
	self.AttributeList = {}
end

function C:DestroyPaotaiPre()
	if self.paotai_pre then
		Destroy(self.paotai_pre)
		self.paotai_pre = nil
	end
end

function C:UpdataShowTimer()
	self:StopShowTimer()
	self.show_timer = Timer.New(function ()
		self:Shoot()
	end,1.5,-1,false,true)
	self.show_timer:Start()
end

function C:StopShowTimer()
	if self.show_timer then
		self.show_timer:Stop()
		self.show_timer = nil
	end
end

function C:Shoot(skin_id)
	local cfg = self.CellList[self.select_index].data
	self:KillSeq()
	self.obj = GameObject.Instantiate(GetPrefab(cfg.bullet_prefab), self.paotai_pre.transform)
	self.obj.transform.localPosition = Vector3.New(0,150,0)
	self.anim:Play("gun_kp",-1,0)
	self.seq = DoTweenSequence.Create()
	self.seq:Append(self.obj.transform:DOLocalMove(Vector3.New(self.obj.transform.localPosition.x,self.obj.transform.localPosition.y+250,self.obj.transform.localPosition.z),0.3))
	self.seq:AppendCallback(function ()
		self.net_obj = GameObject.Instantiate(GetPrefab(cfg.net_prefab), self.paotai_pre.transform)
		self.net_obj.transform.localPosition = Vector3.New(self.obj.transform.localPosition.x,self.obj.transform.localPosition.y,self.obj.transform.localPosition.z)
		self.net_obj.transform.localScale = Vector3.New(1,1,1)
		destroy(self.obj.gameObject)
	end)
	self.seq:AppendInterval(1)
	self.seq:AppendCallback(function ()
		destroy(self.net_obj.gameObject)
	end)
end

function C:KillSeq()
	if IsEquals(self.obj) then
		destroy(self.obj.gameObject)
	end
	if IsEquals(self.net_obj) then
		destroy(self.net_obj.gameObject)
	end
	if self.seq then
		self.seq:Kill()
		self.seq = nil
	end
end