-- 创建时间:2020-10-22
-- Panel:BY3DPHBRightItemBase_sgxxlb
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

BY3DPHBRightItemBase_sgxxlb = basefunc.class()
local C = BY3DPHBRightItemBase_sgxxlb
C.name = "BY3DPHBRightItemBase_sgxxlb"
local M = BY3DPHBManager
function C.Create(panelSelf,parent,config,data)
	return C.New(panelSelf,parent,config,data)
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
	if self.head_pre then
		self.head_pre:MyExit()
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(panelSelf,parent,config,data)
	self.panelSelf = panelSelf
	self.config = config
	self.data = data
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.jl_img_btn = self.jl_img.transform:GetComponent("Button")

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.jl_img_btn.gameObject).onDown = basefunc.handler(self, self.On_JLClickDown)
	EventTriggerListener.Get(self.jl_img_btn.gameObject).onUp = basefunc.handler(self, self.On_JLClickUp)

	dump(self.data.rank)
	self.player_name_txt.text = self.data.name
	self.player_best_score_txt.text = StringHelper.ToCash(self.data.score)
	if self.data.rank == 1 then
		self.rank_txt.gameObject:SetActive(false)
		self.rank_img.gameObject:SetActive(true)
		self.rank_img.sprite = GetTexture("localpop_icon_1")
		self.tips_txt.text = ""
	elseif self.data.rank == 2 then
		self.rank_txt.gameObject:SetActive(false)
		self.rank_img.gameObject:SetActive(true)
		self.rank_img.sprite = GetTexture("localpop_icon_2")
		self.tips_txt.text = ""
	elseif self.data.rank == 3 then
		self.rank_txt.gameObject:SetActive(false)
		self.rank_img.gameObject:SetActive(true)
		self.rank_img.sprite = GetTexture("localpop_icon_3")
		self.tips_txt.text = ""
	else
		self.rank_txt.gameObject:SetActive(true)
		self.rank_img.gameObject:SetActive(true)
		self.rank_img.sprite = GetTexture("localpop_icon_ranking")
		self.rank_txt.text = self.data.rank
		self.tips_txt.text = ""
	end
	self.rank_img:SetNativeSize()
	for i=1,#self.config.rank_list do
		if self.data.rank >= self.config.rank_list[i].rank[1] and self.data.rank <= self.config.rank_list[i].rank[2] then
			self.award_txt.text = self.config.rank_list[i].award_txt[1]
			self.jl_img.sprite =  GetTexture(self.config.rank_list[i].award_img[1])
		end
	end
	self.head_pre = CommonHeadInstancePrafab.Create({type = 1,
							parent = self.headBG.transform,
							style = 3,
							head_url = self.data.head_image,
							--scale = 1.2, 
							not_self = true,
							head_frame_id = self.data.head_frame,
							})
	self:CheckWhoIsI()
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:CheckWhoIsI()
	if self.data.player_id == MainModel.UserInfo.user_id then
		self.BG1_img.sprite = GetTexture("phb_bg_5_1")
		self.BG2_img.sprite = GetTexture("phb_bg_5")
		self.rank_txt.gameObject:GetComponent("Outline").effectColor = Color.New(83/255,29/255,129/255,255)
		self.player_best_score_txt.gameObject:GetComponent("Outline").effectColor = Color.New(106/255,16/255,169/255,255)
		self.player_name_txt.color = Color.New(1, 1, 1, 1)
	end
end

function C:On_JLClickDown()
	--self.tip.gameObject:SetActive(true)
end

function C:On_JLClickUp()
	--self.tip.gameObject:SetActive(false)
end