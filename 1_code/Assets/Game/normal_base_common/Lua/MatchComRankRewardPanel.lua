local basefunc = require "Game.Common.basefunc"
MatchComRankRewardPanel = basefunc.class()
local M = MatchComRankRewardPanel
M.name = "MatchComRankRewardPanel"

local config
local award
local instance
function M.Create(gameCfg, awardCfg, parent)
    if not instance then
        instance = M.New(gameCfg, awardCfg, parent)
    end
    return instance
end

function M:ctor(gameCfg, awardCfg, parent)

	ExtPanel.ExtMsg(self)

    dump(gameCfg, "<color=yellow>gameCfg</color>")
    dump(awardCfg, "<color=yellow>awardCfg</color>")
    if gameCfg and awardCfg then
        config = gameCfg
        award = awardCfg
        if award then
            self.parent = parent or GameObject.Find("Canvas/LayerLv4")
            self.UIEntity = newObject("MatchComRankRewardPanel", self.parent.transform)
            self.transform = self.UIEntity.transform
            self.gameObject = self.UIEntity
            LuaHelper.GeneratingVar(self.UIEntity.transform, self)
            self.gameName_txt.text = config.game_name
            self.rankItem = GetPrefab("MatchComRankRewardItem")
            self.rankTop3 = {}
            if self.rankItem then
                self:InitUI()
            end
            --DOTweenManager.OpenPopupUIAnim(self.transform)
        end
    else
        self:Close()
    end
end

function M:MyExit()
    if instance then
        if self.rankTop3 then
            for k, v in pairs(self.rankTop3) do
                v:Close()
            end
        end
        self.rankTop3 = nil

        self.rankItem = nil
        destroy(self.gameObject)
        instance = nil
    end
    closePanel(M.name)

	 
end

-- 关闭
function M.Close()
    if instance then
        instance:MyExit()
    end
end

function M:InitUI()
    --奖励
    if award then
        destroyChildren(self.rank_content.transform)
        for i, v in ipairs(award) do
            if v.is_show and v.is_show > 0 then
                local go = GameObject.Instantiate(self.rankItem, self.rank_content)
                go.name = v.rank
                self:SetMatchRankItem(go, v)
            end
        end
    else
        destroyChildren(self.rank_content.transform)
    end
    
    --前三名
    local awardNum = #award
    if awardNum > 3 then
        awardNum = 3
    end

    for i = 1, awardNum do
        local anchor = self.Top3:Find("rank" .. i)
        local icon = MatchComRankRewardItemIcon.Create(award[i], anchor)
        self.rankTop3["rank" .. i] = icon
    end
end

function M:SetMatchRankItem(item, data)
    local childs = {}
    LuaHelper.GeneratingVar(item.transform, childs)
    childs.rank_item_bg_img.gameObject:SetActive(false)
    childs.rank_txt.text = data.rank
    childs.award_txt.text = data.award
    local index = item.transform:GetSiblingIndex()
    if index % 2 == 0 then
        childs.rank_item_bg_img.gameObject:SetActive(true)
    end
end
