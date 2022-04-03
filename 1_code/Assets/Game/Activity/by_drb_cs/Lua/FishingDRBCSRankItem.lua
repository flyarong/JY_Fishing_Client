-- 创建时间:2020-06-03
-- Panel:FishingDRBCSRankItem
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

FishingDRBCSRankItem = basefunc.class()
local C = FishingDRBCSRankItem
C.name = "FishingDRBCSRankItem"

function C.Create(parent_transform, data, call, panelSelf, index)
	return C.New(parent_transform, data, call, panelSelf, index)
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

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent_transform, data, call, panelSelf, index)
	self.data = data
	self.call = call
	self.panelSelf = panelSelf
	self.index = index
	local obj = newObject(C.name, parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	if self.data then
		self.info.gameObject:SetActive(true)
		if self.data.rank < 4 then
			self.ranking_img.sprite = GetTexture("localpop_icon_" .. self.data.rank)
			self.ranking_img.gameObject:SetActive(true)
			self.ranking_img1.gameObject:SetActive(false)
			self.rank_txt.text = ""
		else
			self.ranking_img.gameObject:SetActive(false)
			self.ranking_img1.gameObject:SetActive(true)
			self.rank_txt.text = self.data.rank
		end
		
		self.name_txt.text = self.data.name
		self.num_txt.text = StringHelper.ToCash(self.data.score)
		local award = BYDRBCSManager.GetAwardByRank(self.data.rank)
		if award ~= "" then
			self.award_txt.text = award
		else
			self.award_txt.text = "--"
		end

		if self.index % 2 == 0 then
			self.bg_img.sprite = GetTexture("byphb_sls_dk")
		end
	else
		self.info.gameObject:SetActive(false)
		if self.index % 2 == 0 then
			self.bg_img.sprite = GetTexture("byphb_sls_dk")
		end
	end
end

function C:SetData(data)
	self.data = data

	self:MyRefresh()
end
