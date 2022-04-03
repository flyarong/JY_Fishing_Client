-- 创建时间:2020-04-15
-- Panel:ByTouXiangKuangBagPanel
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

ByTouXiangKuangBagPanel = basefunc.class()
local C = ByTouXiangKuangBagPanel
C.name = "ByTouXiangKuangBagPanel"
local M = SYSByBagManager

function C.Create(parent, parm, panelSelf)
	return C.New(parent, parm, panelSelf)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["model_by_bag_gun_info_change"] = basefunc.handler(self,self.MyRefresh)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:StopTime()
	self:CloseCellList()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent, parm, panelSelf)
	self.parm = parm
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.panelSelf = panelSelf
	LuaHelper.GeneratingVar(self.transform, self)
	--稀有度表现
	self.rare_item = {
		[1] = {
			bg = self.bg_pt,
			icon = nil,
			name_txt = self.name_pt_txt
		},
		[2] = {
			bg = self.bg_ss,
			icon = self.icon_ss,
			name_txt = self.name_ss_txt
		},
		[3] = {
			bg = self.bg_cq,
			icon = self.icon_cq,
			name_txt = self.name_cq_txt
		}
	}

	self.use_btn.onClick:AddListener(function()
		self:OnUseButtonClick()
	end)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	M.QueryGunInfo()
end

function C:CheckCellList()
	local data = M.m_data.GunInfo
	dump(data,"<color=red>+++++++++++++++++66++++++++++++++</color>")
	dump(M.UIConfig.frame_list,"<color=red>+++++++++++++++++77++++++++++++++</color>")
	if not data then
		data = {}
		data.frame_list = {}
		data.bed_list = {}
		-- HintPanel.Create(1,"没有数据！",function()
		-- 	self.panelSelf:MyExit()
		-- end)
		-- return nil
	end
	self.frame_list = data.frame_list
	self.bed_list = data.bed_list
	local cell_data = {}

	local callSortGun = function(v1,v2)
		--排序
		if v1.is_get == 1 and v2.is_get ~= 1 then
			return false
		elseif v1.is_get ~= 1 and v2.is_get == 1 then
			return true
		end
		if v1.order and v2.order then
			if v1.order > v2.order then
				return true
			elseif v1.order < v2.order then
				return false
			end
		end
		if v1.id < v2.id then
			return false
		else return true end
	end

	for k,v in pairs (M.UIConfig.frame_list) do
		cell_data[#cell_data+1] = basefunc.deepcopy(v)
	end
	for k,v in pairs (self.frame_list) do
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

	MathExtend.SortListCom(cell_data,callSortGun)
	return cell_data
end


function C:MyRefresh()
	self.cell_data = self:CheckCellList()
	if not self.cell_data then return end
	self:RefreshCellList()


	if self.cell_data and #self.cell_data > 0 then
		if not self.select_index then
			for k,v in ipairs(self.cell_data) do
				if v.item_id == M.m_data.GunInfo.frame_id then
					self.select_index = k
					break
				end
			end
		end
	end
	dump(self.CellList,"<color=red>-----------11------------</color>")
	dump(self.select_index,"<color=red>------------22-----------</color>")
	self.CellList[self.select_index]:SetSelect(true)

	self:RefreshDesc()
end


-- 详情界面
function C:RefreshDesc()
	if self.select_index then
		local data = self.cell_data[self.select_index]
		-- 根据数据显示详细信息
		if data then
			self.desc_node.gameObject:SetActive(true)
			if data.type_colour and data.type_colour >= 1 then
				for k,v in pairs(self.rare_item) do
					if data.type_colour == k then
						if self.rare_item[k].bg then self.rare_item[k].bg.gameObject:SetActive(true) end
						if self.rare_item[k].icon then self.rare_item[k].icon.gameObject:SetActive(true) end
						v.name_txt.gameObject:SetActive(true)
						v.name_txt.text = data.name
					else
						if self.rare_item[k].bg then self.rare_item[k].bg.gameObject:SetActive(false) end
						if self.rare_item[k].icon then self.rare_item[k].icon.gameObject:SetActive(false) end
						v.name_txt.gameObject:SetActive(false)
					end
				end
			end
			self.desc_txt.text = data.desc
			self:RefreshTime(data.time)
			self.get_desc_txt.text = ""

			GetTextureExtend(self.icon_img, data.image, data.is_local_icon)
			self.icon_img:SetNativeSize()
			if data.is_get == 1 then
				self.use_img.sprite = GetTexture("bb_imgf_zb")
				if data.item_id == M.m_data.GunInfo.frame_id then
					self.use_btn.gameObject:SetActive(false)
				else
					self.use_btn.gameObject:SetActive(true)
				end
			else
				self.get_desc_txt.text = data.desc_get
				self.use_btn.gameObject:SetActive(true)
				self.use_img.sprite = GetTexture("bb_imgf_hq")
			end
		else
			self.desc_node.gameObject:SetActive(false)
		end
	end
end

function C:RefreshTime(tt)
	self:StopTime()
	tt = tonumber(tt)
	if tt and tt > 0 and tt > os.time() then
		self.down_time = tt - os.time()
		self.update_time = Timer.New(function ()
			self:UpdateTime()
		end, 1, -1, nil, true)
		self.update_time:Start()
		self:UpdateTime(true)
	else
		self.remain_txt.text = ""
	end
end
function C:UpdateTime(b)
	if not b then
		self.down_time = self.down_time - 1
	end
	if self.down_time <= 0 then
		self:StopTime()
	else
		self.remain_txt.text = "剩余时间:" .. StringHelper.formatTimeDHMS(self.down_time)
	end
end
function C:StopTime()
	if self.update_time then
		self.update_time:Stop()
	end
	self.update_time = nil
end

-- 道具
function C:RefreshCellList()
	self:CloseCellList()
	for k,v in pairs(self.cell_data) do
		local pre = ByGunItemPrefab.Create(self, v, self.Content, self.OnToggleClick, k)
		self.CellList[#self.CellList + 1] = pre
	end
end

function C:RefreshCell()
	for k,v in pairs(self.CellList) do
		v:MyRefresh()
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

function C:OnToggleClick(index)
	if self.select_index ~= index then
		self.CellList[self.select_index]:SetSelect(false)
	end
	self.select_index = index
	self.CellList[self.select_index]:SetSelect(true)
	self:RefreshDesc()
end


function C:OnUseButtonClick()
	local cfg = self.cell_data[self.select_index]
	local select_id = cfg.item_id
	if cfg.is_get == 1 then
		if select_id ~= M.m_data.GunInfo.frame_id then
			Network.SendRequest("set_fish_3d_head_frame",{id = select_id},"设置头像框",function(data)
				if data.result == 0 then
					M.m_data.GunInfo.frame_id = select_id
					self:RefreshCell()
					self:RefreshDesc()
					Event.Brocast("model_by_bag_gun_info_change", M.m_data.GunInfo.barrel_id, M.m_data.GunInfo.bed_id,M.m_data.GunInfo.frame_id)
					Event.Brocast("ByTouXiangKuangBagPanel_set_head_msg")
				else
					if data.result == 5911 then
						HintPanel.Create(1, "当前头像框处于活动中，不能更换")
					else
						HintPanel.ErrorMsg(data.result)
					end
				end
			end)
		else
			HintPanel.Create(1,"已装备该头像框")
		end
	else
		if cfg.use_parm then
			if cfg.buy_hint then
				BuyPTHintPanel.Create(cfg)
			else
				if cfg.use_parm[1] == "game_Fishing3DHall" and MainModel.myLocation == "game_Fishing3D" then
					LittleTips.Create("正在游戏中……")
				else
					GameManager.GuideExitScene({gotoui = cfg.use_parm[1],goto_scene_parm=cfg.use_parm[2]},self.panelSelf:MyExit())
				end
			end
		end
	end
end

