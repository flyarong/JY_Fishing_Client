-- 创建时间:2019-05-29
-- Panel:FishingDRBCSRankPanel
local basefunc = require "Game/Common/basefunc"

FishingDRBCSRankPanel = basefunc.class()
local M = BYDRBCSManager
local C = FishingDRBCSRankPanel
C.name = "FishingDRBCSRankPanel"
local config
GameButtonManager.ExtLoadLua(M.key, "FishingDRBCSRankItem")


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
    
    self.lister["ExitScene"] = basefunc.handler(self, self.onExitScene)
    self.lister["AssetChange"] = basefunc.handler(self, self.onAssetChange)

    self.lister["by_drb_cs_base_info_get"] = basefunc.handler(self, self.on_by_drb_cs_base_info_get)
    self.lister["query_rank_data_response"] = basefunc.handler(self, self.on_query_rank_data)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	destroy(self.gameObject)
	self.data = nil
	self:RemoveListener()	 
end
function C:OnDestroy()
	self:MyExit()
end

function C:ctor(parent)

	ExtPanel.ExtMsg(self)

	config = BYDRBCSManager.GetConfig()
	parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	self.transform = obj.transform
	self.gameObject = obj
	self.data = {}
	self:MakeLister()
	self:AddMsgListener()
	LuaHelper.GeneratingVar(self.transform, self)

	self:InitUI()
end

function C:InitUI()
	self.page_index = 1
	self.curr_index = 1

	self.hint_close_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self.hint.gameObject:SetActive(false)
	end)

	self:CloseCellList()
	for k=1, 4 do
		local pre = FishingDRBCSRankItem.Create(self.content, nil, nil, self, k)
		self.CellList[#self.CellList + 1] = pre
	end

	Network.SendRequest("query_rank_base_info",{rank_type = M.rank_types[self.curr_index]}, "")
	Network.SendRequest("query_rank_data",{rank_type = M.rank_types[self.curr_index],page_index = self.page_index})
end

function C:MyRefresh()
end

function C:OnBackClick()
	self:MyExit()
end

function C:onAssetChange()
end

function C:onExitScene()
	self:MyExit()
end

function C:RefreshRankInfo(rank_data)
	for k, v in ipairs(rank_data) do
		if self.CellList[k] then
			local pre = self.CellList[k]
			pre:SetData(v)
		else
			local pre = FishingDRBCSRankItem.Create(self.content, v, nil, self, k)
			self.CellList[#self.CellList + 1] = pre
		end
	end
end
function C:CloseCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:OnDestroy()
		end
	end
	self.CellList = {}
end

function C:RefreshMyRankInfo()
	local data = M.GetMyRankData(M.rank_types[self.curr_index])
	self.my_name_txt.text = MainModel.UserInfo.name

	if data and data.result == 0 then
		local json_data = json2lua(data.other_data)
		dump(json_data, "<color=red>EEE json_data</color>")

		self.my_num_txt.text = StringHelper.ToCash(data.score or "0")
		self.my_not_rank_txt.text = ""
		self.my_ranking_img.gameObject:SetActive(false)
		if data.rank < 0 then
			self.my_not_rank_txt.text = "未上榜"
			self.my_ranking_img1.gameObject:SetActive(false)
		elseif data.rank < 4 then
			self.my_ranking_img.sprite = GetTexture("localpop_icon_" .. data.rank)
			self.my_ranking_img1.gameObject:SetActive(false)
			self.my_ranking_img.gameObject:SetActive(true)
		elseif data.rank < 100 then
			self.my_rank_txt.text = data.rank
			self.my_ranking_img1.gameObject:SetActive(true)
		else
			self.my_rank_txt.text = "99+"
			self.my_ranking_img1.gameObject:SetActive(true)
		end

		local award = M.GetAwardByRank(data.rank)
		if award ~= "" then
			self.my_award_txt.text = award
		else
			self.my_award_txt.text = "--"
		end
		dump(award, "<color=red>EEE award</color>")
	end 
end

function C:on_by_drb_cs_base_info_get()
	self:RefreshMyRankInfo()
end

function C:on_query_rank_data(_, data)
	dump(data, "<color=white>排名数据</color>")
	if data.result == 0 and data.rank_type == M.rank_types[self.curr_index] then
		self:RefreshRankInfo(data.rank_data)
	end
end

