local basefunc = require "Game.Common.basefunc"

GameMatchHallRankPanel = basefunc.class()
local rank_data = nil
local M = GameMatchHallRankPanel
local instance
function M.Create(config, rank_data, parent)
    if not instance then
        instance = M.New(config, rank_data, parent)
    end
    return instance
end

function M:ctor(config, rank_data, parent)

	ExtPanel.ExtMsg(self)

    self.config = config
    self.rank_data = rank_data
    self.award = GameMatchModel.GetGameIDToAward(self.config.game_id)

    self.parent = parent or GameObject.Find("Canvas/LayerLv4")
    self.UIEntity = newObject("GameMatchHallRankPanel", self.parent.transform)
    self.transform = self.UIEntity.transform
    self.gameObject = self.UIEntity
    LuaHelper.GeneratingVar(self.UIEntity.transform, self)
    self.rankItem = GetPrefab("GameMatchHallRankPlayerItem")

    self:InitUI()
    self:MakeLister()
    DOTweenManager.OpenPopupUIAnim(self.transform)
end

function M:MakeLister()
end

function M:RemoveListener()
end

function M:MyExit()
    if instance then
        if self.rankTop3 then
            for k, v in ipairs(self.rankTop3) do
                v:Close()
            end
        end
        self.rankTop3 = nil
        self.rankItem = nil
        self:RemoveListener()
        rank_data = nil
        destroy(self.gameObject)
        instance = nil
    end

	 
end

-- 关闭
function GameMatchHallRankPanel.Close()
    if instance then
        instance:MyExit()
    end
end

function M:InitUI()
    EventTriggerListener.Get(self.rank_back_btn.gameObject).onClick = basefunc.handler(self, self.OnClickRankBack)
    if self.rank_data then
        self:SetMatchRankItem(self.rank_data)
        self:SetMatchMyRank(self.rank_data)
        self:SetMatchRankTop(self.rank_data)
    else
        self:SetMatchMyRank()
        self:SetMatchRankTop()
    end
end

function M:SetRankItem(item,data)
    local childs = {}
    LuaHelper.GeneratingVar(item.transform, childs)
    if data.rank >= 1 and data.rank <= 3 then
        childs.ranking_img.sprite = GetTexture("localpop_icon_" .. data.rank)
        childs.ranking_img.gameObject:SetActive(true)
        childs.bg_img.sprite = GetTexture("hds_pop_bg_" .. data.rank)
        childs.bg_img.gameObject:SetActive(true)
    elseif data.rank >= 4 then
        childs.ranking_txt.text = data.rank
        childs.ranking_txt.gameObject:SetActive(true)
        childs.bg_img.gameObject:SetActive(false)
    else
        print("<color=red>排名数据错误</color>")
    end
    childs.name_txt.text = basefunc.deal_hide_player_name(data.player_name)
    if data.player_name == MainModel.UserInfo.name then
        childs.name_txt.text = data.player_name or ""
    end
    URLImageManager.UpdateHeadImage(data.head_link, childs.head_img)
    childs.head_frome.gameObject:SetActive(true)
end

function M:SetMatchRankItem(rank_data)
    --根据配置数量设置玩家排名
    for i = 1, self.config.rank_num do
        local data = rank_data[i]
        if data then
            local item = GameObject.Instantiate(self.rankItem, self.rank_content)
            self:SetRankItem(item,data)
        end
    end
end

function M:SetMatchRankTop(rank_data)
    if self.award then
        for i=1, 3 do
            if i <= #self.award then
                self["rank" .. i].gameObject:SetActive(true)
                local icon = MatchComRankRewardItemIcon.Create(self.award[i], self["rank" .. i])
                self.rankTop3 = self.rankTop3 or {}
                self.rankTop3[#self.rankTop3 + 1] = icon
            else
                self["rank" .. i].gameObject:SetActive(false)
            end
        end 
    end

    self.game_over_time_txt.text = string.format("比赛开始时间: %s",os.date("%Y/%m/%d %H:%M:%S", self.config.over_time))
end

function M:SetMatchMyRank(rank_data)
    --根据配置数量设置玩家排名
    local my_rank_data = nil
    if rank_data then
        for i,v in ipairs(rank_data) do
            if v.player_id == MainModel.UserInfo.user_id then
                my_rank_data = v
                break
            end
        end
    end

    if my_rank_data then
        self:SetRankItem(self.GameMatchHallGMRankItem,my_rank_data)
    else
        local item = self.GameMatchHallGMRankItem
        local childs = {}
        LuaHelper.GeneratingVar(item.transform, childs)
        childs.ranking_txt.text = "未上榜"
        childs.name_txt.text = MainModel.UserInfo.name
        URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, childs.head_img)
        childs.head_frome.gameObject:SetActive(true)
    end
end

function M:OnClickRankBack(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self:MyExit()
end