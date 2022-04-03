-- 创建时间:2020-04-27
-- Panel:SYSByPmsGameRankItem_jf
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

SYSByPmsGameRankItem_jf = basefunc.class()
local C = SYSByPmsGameRankItem_jf
C.name = "SYSByPmsGameRankItem_jf"

function C.Create(parent_transform, config, call, panelSelf, index)
	return C.New(parent_transform, config, call, panelSelf, index)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}

    self.lister["model_sys_by_pms_score_change"] = basefunc.handler(self,self.model_sys_by_pms_score_change)
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

function C:ctor(parent_transform,index)
	self.index = index
	dump(parent_transform,"<color=red>++++++++++++++++++</color>")
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
	self.award_config = SYSByPmsManager.GetPMSAwardByID(SYSByPmsManager.GetSignupData())--获取奖励config

	if self.index == 1 then--玩家自己
		self.myself.gameObject:SetActive(true)
		URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image,self.head_img)
		self.name_txt.text = MainModel.UserInfo.name
		dump(SYSByPmsManager.GetCurScore(),"<color=red>IIIIIIIIIIIIIIIIIIIIIIIIIIIIII</color>")
		self.score_txt.text = "积分:"..(SYSByPmsManager.GetCurScore() or "")
	else
		self.rank.gameObject:SetActive(true)
		self.rank_name_txt.text = self.award_config[self.index-1].rank_name
		self.rank_img.sprite = GetTexture(self.award_config[self.index-1].icon)
		if self.award_config[self.index-1].max_score == -1 then
			self.rank_score_txt.text = self.award_config[self.index-1].min_score.."以上"
		else	
			self.rank_score_txt.text = self.award_config[self.index-1].min_score.."~"..self.award_config[self.index-1].max_score
		end
		self.rank_award_img.sprite = GetTexture(self.award_config[self.index-1].award_icon[1])
		self.rank_award_txt.text = self.award_config[self.index-1].award_desc[1]
		self.rank_award_txt.fontSize = 21
	end
	self:SetHead()
	self:MyRefresh()
end

function C:MyRefresh()
	self.people_num_txt.text = self.cur_num or "0"
end

function C:SetData(num)
	dump(num,"<color=green>MMMMMMMMMMMMMMMMMMMMMM</color>")
	if num == 0 then
		self.cur_num = num
	else
		self.cur_num = num.num
	end
	self:MyRefresh()
end


function C:model_sys_by_pms_score_change()
	if self.index == 1 then
		self.score_txt.text = "积分:"..(SYSByPmsManager.GetCurScore() or "")
		for i=1,#self.award_config do
			if SYSByPmsManager.GetCurScore() >= tonumber(self.award_config[i].min_score) then
				self.award_icon_img.gameObject:SetActive(true)
				self.award_icon_img.sprite = GetTexture(self.award_config[i].icon)
				return
			end
		end
	end
end


function C:Refresh(data)
	self.people_num_txt.text = data.num
end

function C:SetHead()
	self.head_pre = CommonHeadInstancePrafab.Create({type = 1,
									parent = self.head.transform,
									style = 3,
									})
end