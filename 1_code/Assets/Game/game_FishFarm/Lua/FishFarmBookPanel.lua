-- 创建时间:2020-11-19
-- Panel:FishFarmBookPanel
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
ext_require("Game.game_FishFarm.Lua.FishFarmBookFishPrefab")
ext_require("Game.game_FishFarm.Lua.FishFarmBookLeftPrefab")

FishFarmBookPanel = basefunc.class()
local C = FishFarmBookPanel
C.name = "FishFarmBookPanel"

local jingdu_len = 888
local yuanqiu_w = 40

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
	self.lister["AssetChange"] = basefunc.handler(self, self.RefreshAsset)
	self.lister["model_fishbowl_task_data"] = basefunc.handler(self, self.on_model_fishbowl_task_data)
    self.lister["model_fishbowl_handbook"] = basefunc.handler(self, self.model_fishbowl_handbook)
    self.lister["ui_fishbowl_handbook_select_fish"] = basefunc.handler(self, self.ui_fishbowl_handbook_select_fish)
    self.lister["ui_fishbowl_handbook_select_tag"] = basefunc.handler(self, self.ui_fishbowl_handbook_select_tag)
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

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv1").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.percent_rect = self.percent_mask:GetComponent("RectTransform")
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:MyExit()
	end)
	self.jb_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
	end)
	self.sl_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		GameManager.GotoUI({gotoui = "sys_fishfarm_simplicity",goto_scene_parm = "panel_sl"})
	end)

	self.config = FishFarmManager.GetFishTypeList()
	self.book_config = FishFarmManager.GetBookConfig()
	self.select_tag = 0

	self.left_data = {}
	self.left_data[#self.left_data + 1] = {tag = 0, name="全   部", img1="szg_tj_btn_qbwxz", img2="szg_tj_btn_qbxz"}
	self.left_data[#self.left_data + 1] = {tag = 1, name="普通鱼", img1="szg_tj_btn_ptywxz", img2="szg_tj_btn_ptyxz"}
	self.left_data[#self.left_data + 1] = {tag = 2, name="珍惜鱼", img1="szg_tj_btn_zxywxz", img2="szg_tj_btn_zxyxz"}
	self.left_data[#self.left_data + 1] = {tag = 3, name="彩金鱼", img1="szg_tj_btn_cjywxz", img2="szg_tj_btn_cjyxz"}
	self.left_data[#self.left_data + 1] = {tag = 4, name="活动鱼", img1="szg_tj_btn_hdywxz", img2="szg_tj_btn_hdyxz"}
	self.left_data[#self.left_data + 1] = {tag = 5, name="海怪鱼", img1="szg_tj_btn_hgywxz", img2="szg_tj_btn_hgyxz"}

	self.tag_map = {}
	for k,v in ipairs(self.left_data) do
		self.tag_map[v.tag] = v.name
	end

    self.sv_r = self.ScrollViewR.transform:GetComponent("ScrollRect")

    self.percent_bili = {}
    local all_num = self.book_config[#self.book_config].active
	for k,v in ipairs(self.book_config) do
		local obj = GameObject.Instantiate(self.percent_cell1, self.percent_node1)
		local tran  = obj.transform
		obj.gameObject:SetActive(true)
		local yy = jingdu_len * v.active/all_num
		local ui = {}
		LuaHelper.GeneratingVar(tran, ui)
		ui.percent_num_txt.text = v.active
		tran.localPosition = Vector3.New(yy, 0, 0)
		ui.bx_btn.onClick:AddListener(function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:OnBoxClick(k)
		end)

		local obj2 = GameObject.Instantiate(self.percent_cell2, self.percent_node2)
		obj2.gameObject:SetActive(true)
		obj2.transform.localPosition = Vector3.New(yy, 0, 0)

		if k == 1 then
			self.percent_bili[#self.percent_bili + 1] = {num=v.active, jd=v.active/all_num - 0.5 * yuanqiu_w / jingdu_len, yuan_obj=obj2.gameObject}
		else
			self.percent_bili[#self.percent_bili + 1] = {num=v.active-self.book_config[k-1].active, jd=(v.active-self.book_config[k-1].active)/all_num - yuanqiu_w / jingdu_len, yuan_obj=obj2.gameObject}
		end
		self.percent_bili[#self.percent_bili].box_ui = ui
		self.percent_bili[#self.percent_bili].man_jd = self.percent_bili[#self.percent_bili].jd + yuanqiu_w / jingdu_len
	end

	FishFarmManager.QueryHandbooklInfo("")
	FishFarmManager.QueryBookTask()
end

function C:OnBoxClick(index)
	local award_state_list = FishFarmManager.GetBookTaskAwardData()

	if award_state_list and award_state_list[index] == 1 then
		Network.SendRequest("get_task_award_new", {id = FishFarmManager.GetBookTaskID(), award_progress_lv = index},"请求奖励",function(data)
			if data.result == 0 then
			else
				HintPanel.ErrorMsg(data.result)
			end
		end)
	else
		LittleTips.Create(self.book_config[index].award_tip)
	end
end

function C:MyRefresh()
	self.sv_r:StopMovement()
	self.content_right.transform.localPosition = Vector3.zero

	self:RefreshData()
	self.select_index = nil
	if #self.book_data > 0 then
		self.select_index = 1
	end

	self:RefreshAsset()
	self:RefreshLeft()
	self:RefreshRight()
	self:RefreshDesc()
end

function C:RefreshAsset()
	local xx = GameItemModel.GetItemCount("prop_fishbowl_stars")
	self.jb_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	self.xx_txt.text = xx
	self.sl_txt.text = GameItemModel.GetItemCount("prop_fishbowl_feed")
end

function C:RefreshProgressUI()
	local pp = 0

	local task = FishFarmManager.GetBookTaskData()
	local num = 0
	if task then
		num = task.now_total_process
	end
	for k,v in ipairs(self.percent_bili) do
		if num >= v.num then
			num = num-v.num
			pp = pp + v.man_jd
			v.yuan_obj:SetActive(true)
		elseif num > 0 then
			v.yuan_obj:SetActive(false)
			pp = pp + v.jd * num / v.num
			num = 0
		else
			v.yuan_obj:SetActive(false)			
		end
	end
	self.percent_rect.sizeDelta = Vector2.New(pp*jingdu_len, 48)
end
function C:RefreshTask()
	local award_state_list = FishFarmManager.GetBookTaskAwardData()
	dump(award_state_list)
	if award_state_list then
		for k,v in ipairs(award_state_list) do
			if v == 0 then
				self.percent_bili[k].box_ui.boxglow.gameObject:SetActive(false)
			elseif v == 1 then
				self.percent_bili[k].box_ui.boxglow.gameObject:SetActive(true)
			else
				self.percent_bili[k].box_ui.boxglow.gameObject:SetActive(false)
			end
		end
	end
end

function C:on_model_fishbowl_task_data()
	self:RefreshTask()
	self:RefreshProgressUI()
end

function C:model_fishbowl_handbook(data)
	if data.result == 0 then
		self:MyRefresh()
	else
		HintPanel.ErrorMsg(data.result)
		self:MyExit()
	end
end

function C:RefreshData()
	local list = {}
	if self.select_tag == 0 then
		for k,v in ipairs(self.config) do
			for kk,vv in ipairs(v.list) do
				list[#list + 1] = {tag=v.tag, id = vv}
			end
		end
	else
		if self.config[self.select_tag] then
			for k,v in ipairs(self.config[self.select_tag].list) do
				list[#list + 1] = {tag=self.config[self.select_tag].tag, id = v}
			end
		end
	end

	for k,v in ipairs(list) do
		v.is_get = FishFarmManager.IsGetHandbookByID(v.id)
	end
	local callSortGun = function(v1,v2)
		--排序
		if v1.is_get and not v2.is_get then
			return false
		elseif not v1.is_get and v2.is_get then
			return true
		else
			if v1.tag > v2.tag then
				return false
			elseif v1.tag < v2.tag then
				return true
			else
				if v1.id > v2.id then
					return true
				else
					return false
				end
			end
		end
	end
	MathExtend.SortListCom(list, callSortGun)

	self.book_data = list
end

function C:RefreshLeft()
	if not self.left_cell then
		self.left_cell = {}
		for k,v in ipairs(self.left_data) do
			local pre = FishFarmBookLeftPrefab.Create(self.content_left, v)
			self.left_cell[#self.left_cell + 1] = pre
		end
	end
	for k,v in ipairs(self.left_cell) do
		if v.data.tag == self.select_tag then
			v:SetSelect(true)
		else
			v:SetSelect(false)
		end
	end
end

function C:RefreshRight()
	self:CloseRight()
	
	for k,v in ipairs(self.book_data) do
		local pre = FishFarmBookFishPrefab.Create(self.content_right, v.id, k)
		self.right_cell[#self.right_cell + 1] = pre
		if self.select_index == k then
			pre:SetSelect(true)
		end
	end
end
function C:CloseRight()
	if self.right_cell then
		for k,v in ipairs(self.right_cell) do
			v:MyExit()
		end
	end
	self.right_cell = {}
end

function C:RefreshDesc()
	if self.select_index then
		local select_id = self.book_data[self.select_index].id
		self.desc_node.gameObject:SetActive(true)
		local cfg = FishFarmManager.GetFishConfig(select_id)
		local is_get = FishFarmManager.IsGetHandbookByID(select_id)
		self.icon_img.sprite = GetTexture(cfg.icon)
		self.name_txt.text = cfg.name
		if not is_get then
			self.icon_img.color = Color.black
			self.name_txt.text = "???"
		end

		local state = FishFarmManager.GetFishByState(cfg, 0)
		local state_cfg = cfg.sum_stage_list[state]

		self.desc_level_txt.text = self.tag_map[cfg.fish_type]
		self.desc_state_txt.text = cfg.sum_stage .. "阶段"
		self.desc_xx_txt.text = state_cfg.xx_produce_dec
		self.desc_jb_txt.text = state_cfg.jb_produce_dec
		self.desc_txt.text = cfg.tips or ""
		self.desc_dl_txt.text = cfg.produce or ""
	else
		self.desc_node.gameObject:SetActive(false)
	end
end

function C:ui_fishbowl_handbook_select_fish(data)
	if self.select_index ~= data.index then
		self.right_cell[self.select_index]:SetSelect(false)
		self.select_index = data.index
		self.right_cell[self.select_index]:SetSelect(true)
		self:RefreshDesc()
	end
end

function C:ui_fishbowl_handbook_select_tag(data)
	if self.select_tag ~= data.tag then
		self.select_tag = data.tag
		self:MyRefresh()
	end
end
