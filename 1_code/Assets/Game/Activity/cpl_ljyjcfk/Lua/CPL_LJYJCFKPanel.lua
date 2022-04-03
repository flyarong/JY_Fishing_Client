-- 创建时间:2020-06-18
-- Panel:CPL_LJYJCFKPanel
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

CPL_LJYJCFKPanel = basefunc.class()
local C = CPL_LJYJCFKPanel
C.name = "CPL_LJYJCFKPanel"
local M = CPL_LJYJCFKManager
--spcae + 物体宽度的一半 * 2
local item_space = 100 + 106.2
local head_space = 140
local process_W = 0
local Content_W = 0
local process_offset = (139.3 - 129.53)/2
local off_set = {}

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
	self.lister["close_CPL_LJYJCFK"] = basefunc.handler(self,self.MyExit)
	self.lister["AssetChange"] = basefunc.handler(self,self.OnAssetChange)
	self.lister["cpl_ljyjcfk_refresh"] = basefunc.handler(self,self.MyRefresh)
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

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.SV = self.transform:Find("Scroll View"):GetComponent("ScrollRect")

	self:MakeLister()
	self:AddMsgListener()
	off_set = {}
	Network.SendRequest("query_one_task_data",{task_id = M.task_id})
	for i = 1,M.task_c do
		if i == 1 then
			local data = {}
			data.min = 0
			data.max = 129
			off_set[#off_set + 1] = data
		elseif i >= 2 and i <= 14 then
			local data = {}
			data.min = off_set[i - 1].max
			data.max = off_set[i - 1].max + item_space
			off_set[#off_set + 1] = data
		else
			local data = {}
			data.min = off_set[i - 1].max
			data.max = off_set[i - 1].max + item_space
			off_set[#off_set + 1] = data
		end
	end
	self:InitUI()
	local AwardIndex = M.CanGetAwardIndex()
	if AwardIndex and AwardIndex < M.task_c + 1 then
		self:AutoGoCanGetAwardItem(AwardIndex)
	end
end

function C:InitUI()
	process_W = (M.task_c - 1) * item_space + head_space * 2
	Content_W = process_W + 60
	self.close_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	self.Content.transform.sizeDelta = {x = Content_W,y = 368}
	self.bg_process.transform.sizeDelta = {x = process_W,y = 56}
	self.temp_uis = {}
	for i = 1,M.task_c do
		local temp_ui = {}
		local b = GameObject.Instantiate(self.a_item,self.a_node)
		LuaHelper.GeneratingVar(b.transform,temp_ui)
		EventTriggerListener.Get(temp_ui.klj.gameObject).onClick = basefunc.handler(self,self.Lottery)
		b.gameObject:SetActive(true)
		self.temp_uis[#self.temp_uis + 1] = temp_ui
	end
	EventTriggerListener.Get(self.lottery_btn.gameObject).onClick = basefunc.handler(self, self.Lottery)
	self:MyRefresh()
end

function C:MyRefresh()
	if not IsEquals(self.gameObject) then return end
	local data = M.GetData()
	if data and IsEquals(self.gameObject) then
		local b = basefunc.decode_task_award_status(data.award_get_status)
		b = basefunc.decode_all_task_award_status2(b, data, M.task_c)
		for i = 1,M.task_c do
			if data.award_status == 1 then
				if data.now_process == data.need_process then
					self.temp_uis[i].klj.gameObject:SetActive(i == data.now_lv)
				else
					self.temp_uis[i].klj.gameObject:SetActive(i == data.now_lv - 1)
				end
			end
			self.temp_uis[i].yhd.gameObject:SetActive(false)
			self.temp_uis[i].ju_txt.text = StringHelper.ToCash(M.config.base[i].total)
			self.temp_uis[i].fk_txt.text = StringHelper.ToCash(M.config.base[i].show_hb) .. "福利券"
			self.temp_uis[i].award_img.sprite = GetTexture(M.config.base[i].hb_image or "ty_icon_flq2")
		end
		self:RefreshProcess()
		self.curr_txt.text = "再赢金<color=#d52e2bff>".. StringHelper.ToCash(data.need_process - data.now_process) .. "</color>，可抽取<color=#d52e2bff>" .. M.config.base[data.now_lv].show_hb .. "福利券！</color>"
		
		if data.now_process == data.need_process then
			self.lottery_txt.text = "抽取" .. M.config.base[data.now_lv].show_hb .. "福利券"
		else
			if data.now_lv == 1 then
				self.lottery_txt.text = "抽取" .. M.config.base[data.now_lv].show_hb .. "福利券"
			else
				self.lottery_txt.text = "抽取" .. M.config.base[data.now_lv-1].show_hb .. "福利券"
			end
		end
	end	
end

function C:RefreshProcess()
	local data = M.GetData()
	if not data then return end
	local now_max_level = M.CanGetNowLevel()
	for i = 1,M.task_c do
		if self.temp_uis then
			self.temp_uis[i].qipao.gameObject:SetActive(false)
			self.temp_uis[i].liang.gameObject:SetActive(false)
		end
	end
	for i = 1,now_max_level - 1 do
		if self.temp_uis then
			self.temp_uis[i].liang.gameObject:SetActive(true)
		end
	end
	if now_max_level <= M.task_c then
		self.process.transform.sizeDelta = {
			x = off_set[now_max_level].min + (off_set[now_max_level].max - off_set[now_max_level].min) * (data.now_process/data.need_process),
			y = 41.95
		}
		dump(off_set[now_max_level].min)
		-- self.temp_uis[now_max_level].qipao.gameObject:SetActive(true)
		self.temp_uis[now_max_level].qipao_txt.text = "再赢"..StringHelper.ToCash(data.need_process - data.now_process) .."可抽取" .. M.config.base[data.now_lv].show_hb .. "福利券"
	else
		self.process.transform.sizeDelta = {
			x = process_W - process_offset,
			y = 41.95
		}
	end
end

function C:Lottery()
	--[[local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="ljyjcflq_vip_limit", is_on_hint = true}, "CheckCondition")
    if a and b then
    	GameManager.GotoUI({gotoui = M.key,goto_scene_parm = "panel_not_vip"})
    else
		GameManager.GotoUI({gotoui = M.key,goto_scene_parm = "panel_lottery"})
		self:MyExit()
	end--]]
	GameManager.GotoUI({gotoui = M.key,goto_scene_parm = "panel_lottery"})
	self:MyExit()
end

function C:OnAssetChange(data)
    if data.change_type and data.change_type == "task_p_cpl_ljyjcfk" then
		self.award_data = data
    end
end

function C:AutoGoCanGetAwardItem(index)
	local go_anim = function(val)
		self.SV.horizontalNormalizedPosition = val
	end
	if index <= 5 then
		go_anim(0)
	elseif index >= 10 then
		go_anim(1)
	else
		go_anim(1/(M.task_c + 1) * (index) + 0.015)
	end
end