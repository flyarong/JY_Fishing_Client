-- 创建时间:2020-08-29
-- Panel:SYSTGXTInComePanel
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

SYSTGXTInComePanel = basefunc.class()
local C = SYSTGXTInComePanel
C.name = "SYSTGXTInComePanel"

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
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
	self.lister["query_my_sczd_income_details_response"] = basefunc.handler(self,self.on_query_my_sczd_income_details)
	self.lister["query_my_sczd_spending_details_response"] = basefunc.handler(self,self.on_query_my_sczd_spending_details)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:CloseItemPrefab()
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
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.on_BackClick)
end

function C:InitUI()
	self.select_tag = 1

	self.page_index = 1
	self.sv = self.ScrollView:GetComponent("ScrollRect")
	EventTriggerListener.Get(self.sv.gameObject).onEndDrag = function()
	    local VNP = self.sv.verticalNormalizedPosition  
	    if VNP <= 0 then 
	    end
	end

	self.dj_on_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnSelectClick(1)
	end)
	self.pt_on_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnSelectClick(2)
	end)

	self:MyRefresh()
end

function C:QueryPageData()
	if self.select_tag == 1 then
		Network.SendRequest("query_my_sczd_income_details",{page_index = self.page_index, sort_type=3})	
	else
		Network.SendRequest("query_my_sczd_spending_details",{page_index = self.page_index, sort_type=3})	
	end
end

function C:MyRefresh()
	self:RefreshTag()
end

function C:RefreshTag()
	self.page_index = 1
	self:CloseItemPrefab()
	if self.select_tag == 1 then
		self.dj_on_btn.gameObject:SetActive(false)
		self.dj_xz_obj.gameObject:SetActive(true)
		self.pt_on_btn.gameObject:SetActive(true)
		self.pt_xz_obj.gameObject:SetActive(false)
	else
		self.dj_on_btn.gameObject:SetActive(true)
		self.dj_xz_obj.gameObject:SetActive(false)
		self.pt_on_btn.gameObject:SetActive(false)
		self.pt_xz_obj.gameObject:SetActive(true)
	end
	self:QueryPageData()
end

function C:on_BackClick()
	self:MyExit()
end

function C:CreateItemPrefab(data)
	for k,v in ipairs(data) do
		local pre = SYSTGXHistoryItemBase.Create(self.Content.transform, v)
		self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
	end
end

function C:CloseItemPrefab()
	if self.spawn_cell_list then
		for k,v in ipairs(self.spawn_cell_list) do
			v:MyExit()
		end
	end
	self.spawn_cell_list = {}
end

function C:OnSelectClick(index)
	if self.select_tag ~= index then
		self.select_tag = index
		self:RefreshTag()
	end
end

function C:on_query_my_sczd_income_details(_, data)
	dump(data, "on_query_my_sczd_income_details")
	if data.result == 0 then
		if data.is_clear_old_data and data.is_clear_old_data == 1 then
			self.page_index = 1
			self:CloseItemPrefab()
		end
		if data.detail_infos then
			self:CreateItemPrefab(data.detail_infos)
			self.page_index = self.page_index + 1
		end
		if not data.detail_infos or #data.detail_infos <= 0 then
			LittleTips.Create("暂无新数据")
		end
	end
end
function C:on_query_my_sczd_spending_details(_, data)
	dump(data, "on_query_my_sczd_spending_details")
	if data.result == 0 then
		if data.is_clear_old_data and data.is_clear_old_data == 1 then
			self.page_index = 1
			self:CloseItemPrefab()
		end
		if data.extract_infos then
			self:CreateItemPrefab(data.extract_infos)
			self.page_index = self.page_index + 1
		end
		if not data.extract_infos or #data.extract_infos <= 0 then
			LittleTips.Create("暂无新数据")
		end
	end
end