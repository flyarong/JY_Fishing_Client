-- 创建时间:2020-10-22
-- Panel:BY3DPHBRightItemBase_hgb
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

BY3DPHBRightItemBase_hgb = basefunc.class()
local C = BY3DPHBRightItemBase_hgb
C.name = "BY3DPHBRightItemBase_hgb"
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
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	dump(self.data.rank)
	self.player_name_txt.text = self.data.name
	self.player_best_score_txt.text = StringHelper.ToCash(self.data.score)
	if self.data.rank == 1 then
		self.rank_txt.gameObject:SetActive(false)
		self.rank_img.gameObject:SetActive(true)
		self.rank_img.sprite = GetTexture("localpop_icon_1")
	elseif self.data.rank == 2 then
		self.rank_txt.gameObject:SetActive(false)
		self.rank_img.gameObject:SetActive(true)
		self.rank_img.sprite = GetTexture("localpop_icon_2")
	elseif self.data.rank == 3 then
		self.rank_txt.gameObject:SetActive(false)
		self.rank_img.gameObject:SetActive(true)
		self.rank_img.sprite = GetTexture("localpop_icon_3")
	else
		self.rank_txt.gameObject:SetActive(true)
		self.rank_img.gameObject:SetActive(false)
		self.rank_txt.text = "第"..self.data.rank.."名"
	end
	self.rank_img:SetNativeSize()
	for i=1,#self.config.rank_list do
		if self.data.rank >= self.config.rank_list[i].rank[1] and self.data.rank <= self.config.rank_list[i].rank[2] then
			for j=1,#self.config.rank_list[i].award_img do
				self["rank_award_icon"..j.."_img"].gameObject:SetActive(true)
				self["rank_award"..j.."_img"].sprite = GetTexture(self.config.rank_list[i].award_img[j])
				self["rank_award"..j.."_txt"].text = self.config.rank_list[i].award_txt[j]
			end
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
		self.rank_award1_txt.gameObject:GetComponent("Outline").effectColor = Color.New(84/255,16/255,169/255,255)
		self.rank_award2_txt.gameObject:GetComponent("Outline").effectColor = Color.New(84/255,16/255,169/255,255)
		self.rank_award_icon1_img.sprite = GetTexture("phb_bg_3")
		self.rank_award_icon2_img.sprite = GetTexture("phb_bg_3")
		self.down1_img.sprite = GetTexture("phb_bg_3_1")
		self.down2_img.sprite = GetTexture("phb_bg_3_1")
	end
end