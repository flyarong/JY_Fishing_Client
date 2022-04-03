-- 创建时间:2020-09-01
-- Panel:SYSBYLevelPTPanel
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

SYSBYLevelPTPanel = basefunc.class()
local C = SYSBYLevelPTPanel
C.name = "SYSBYLevelPTPanel"
local M = SYSBYLevelManager


function C.Create(level)
	return C.New(level)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
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

function C:ctor(level)
	self.level = level
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	

	self.config = M.GetPTConfig()
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.on_BackClick)
	self:MyRefresh()
	self:RefreshUI()
end

function C:MyRefresh()
end

function C:on_BackClick()
	self:MyExit()
end

function C:RefreshUI()
	for i=1,#self.config do
		if self.config[i].level == self.level then
			self.title_txt.text = self.config[i].title_txt
			self.pt_name_txt.text = self.config[i].gun_name
			if self.config[i].gun_img then
				self.pt_img.gameObject:SetActive(true)
				self.pt_img.sprite = GetTexture(self.config[i].gun_img)
			else
				self.pt_img.gameObject:SetActive(false)
			end
			if self.config[i].bullet_img then
				self.bullet1_img.gameObject:SetActive(true)
				self.bullet1_img.sprite = GetTexture(self.config[i].bullet_img)
			else
				self.bullet1_img.gameObject:SetActive(false)
			end
			if self.config[i].net_img then
				self.bullet2_img.gameObject:SetActive(true)
				self.bullet2_img.sprite = GetTexture(self.config[i].net_img)
			else
				self.bullet2_img.gameObject:SetActive(false)
			end
			self:CreateItemPrefab(i)
		end
	end
end

function C:CreateItemPrefab(index)
	local len = 0
	local tran
	if not table_is_null(self.config[index].url) then
		len = len + #self.config[index].url
	end
	if not table_is_null(self.config[index].head_frame_img) then
		len = len + #self.config[index].head_frame_img
	end
	if len == 1 then
		self.ScrollView1.gameObject:SetActive(true)
		self.ScrollView2.gameObject:SetActive(false)
		self.ScrollView3.gameObject:SetActive(false)
		tran = self.Content1.transform
	elseif len == 2 then
		self.ScrollView1.gameObject:SetActive(false)
		self.ScrollView2.gameObject:SetActive(true)
		self.ScrollView3.gameObject:SetActive(false)
		tran = self.Content2.transform
	else
		self.ScrollView1.gameObject:SetActive(false)
		self.ScrollView2.gameObject:SetActive(false)
		self.ScrollView3.gameObject:SetActive(true)
		tran = self.Content3.transform
	end

	self:CloseItemPrefab()
	if not table_is_null(self.config[index].url) then
		for i=1,#self.config[index].url do
			local pre = SYSBYLevelPTItemBase.Create(tran,self.config[index].url[i],"url")
			if pre then
				self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
			end
		end
	end
	if not table_is_null(self.config[index].head_frame_img) then
		for i=1,#self.config[index].head_frame_img do
			local pre = SYSBYLevelPTItemBase.Create(tran,self.config[index].head_frame_img[i],"img",self.config[index].head_frame_name[i])
			if pre then
				self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
			end
		end
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