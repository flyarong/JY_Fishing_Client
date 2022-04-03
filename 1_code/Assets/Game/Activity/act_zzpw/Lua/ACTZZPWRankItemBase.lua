-- 创建时间:2021-09-13
-- Panel:ACTZZPWRankItemBase
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

ACTZZPWRankItemBase = basefunc.class()
local C = ACTZZPWRankItemBase
C.name = "ACTZZPWRankItemBase"
local M = ACTZZPWManager

function C.Create(parent,data)
	return C.New(parent,data)
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
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent,data)
	ExtPanel.ExtMsg(self)
    self.data = data
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
    self.outline = self.dw_txt.transform:GetComponent("Outline")

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
    local bg_img = ""
    self.data.ranking = tonumber(self.data.rank)
    if self.data.player_id == MainModel.UserInfo.user_id then
        bg_img = "dw_bg_7"
    else
        if self.data.ranking % 2 == 0 then
            bg_img = "dw_bg_3"
        else
            bg_img = "dw_bg_5"
        end
    end
    self.bg_img.sprite = GetTexture(bg_img)
    if self.data.ranking <= 3 then
        self.rank_img.gameObject:SetActive(true)
        self.rank_txt.gameObject:SetActive(false)
        self.rank_img.sprite = GetTexture("localpop_icon_" .. self.data.ranking)
    else
        self.rank_img.gameObject:SetActive(false)
        self.rank_txt.gameObject:SetActive(true)
        self.rank_txt.text = self.data.ranking
    end
    self.name_txt.text = self.data.name
    local config = M.GetConfig()
    local rankIndex = M.GetIndexFromScore(self.data.score)
    self.dw_txt.text = config[rankIndex].rank_name
    -- local outline = {{94,202,106},{43,48,169},{202,155,80},{146,71,71},{97,20,136},{145,29,36}}
    -- local index1 = math.ceil(self.data.rank / 3)
    -- self.outline.effectColor = Color.New(outline[index1][1]/255,outline[index1][2]/255,outline[index1][3]/255,1)
    local config = M.GetConfig()
    self.award_txt.text = config[rankIndex].rank_award
end
