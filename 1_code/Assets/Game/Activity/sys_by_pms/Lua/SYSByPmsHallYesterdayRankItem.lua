-- 创建时间:2020-05-15
-- Panel:SYSByPmsHallYesterdayRankItem
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

SYSByPmsHallYesterdayRankItem = basefunc.class()
local C = SYSByPmsHallYesterdayRankItem
C.name = "SYSByPmsHallYesterdayRankItem"

function C.Create(parent,data,id)
	return C.New(parent,data,id)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self.head_pre:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent,data,id)
	self.data = data
	self.id = id
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
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

	self.rank_txt.text = "第 "..self.data.rank.." 名"
	self.player_name_txt.text = self.data.player_name
	self.player_best_score_txt.text = "最佳分数:"..self.data.score
	if self.data.head_image then
		URLImageManager.WWWImage(self.data.head_image,self.head_img)
	else
		self.head_img.sprite = GetTexture("com_head")
	end
	--VIPManager.set_vip_text_new(self.vip_txt,self.data.vip_level)

	self:SetHead()
	local award_list = SYSByPmsManager.GetPMSAwardCfgByRank(self.id,self.data.rank,"pms")
	if table_is_null(award_list) then
		return
	end
	if #award_list == 1 then
		self.rank_award_icon1.gameObject:SetActive(true)
		self.rank_award1_img.sprite = GetTexture(award_list[1].icon)
		local item1 = GameItemModel.GetItemToKey(award_list[1].type)
		self.rank_award1_txt.text = item1.name..StringHelper.ToCash(award_list[1].num)
	elseif #award_list == 2 then
		self.rank_award_icon1.gameObject:SetActive(true)
		self.rank_award1_img.sprite = GetTexture(award_list[1].icon)
		local item1 = GameItemModel.GetItemToKey(award_list[1].type)
		self.rank_award1_txt.text = item1.name..StringHelper.ToCash(award_list[1].num)
		self.rank_award_icon2.gameObject:SetActive(true)
		self.rank_award2_img.sprite = GetTexture(award_list[2].icon)
		local item2 = GameItemModel.GetItemToKey(award_list[2].type)
		self.rank_award2_txt.text = item2.name..StringHelper.ToCash(award_list[2].num)
	end

	
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:SetHead()
	if self.data.head_image then
		self.head_pre = CommonHeadInstancePrafab.Create({type = 1,
									parent = self.headBG.transform,
									style = 3,
									head_url = self.data.head_image,
									--scale = 1.2, 
									not_self = true,
									head_frame_id = self.data.dressed_head_frame_id,
									})
	else
		self.head_pre = CommonHeadInstancePrafab.Create({type = 1,
									parent = self.headBG.transform,
									style = 3,
									head_img = "com_head",
									--scale = 1.2, 
									not_self = true,
									head_frame_id = self.data.dressed_head_frame_id,
									})
	end
end