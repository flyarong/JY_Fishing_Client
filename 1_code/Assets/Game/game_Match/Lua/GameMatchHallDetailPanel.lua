local basefunc = require "Game.Common.basefunc"
GameMatchHallDetailPanel = basefunc.class()
local M = GameMatchHallDetailPanel

local req_signup_num_data = {
    req_signup_num_cb = nil,
    req_signup_num_cd = 3,
    req_signup_num_t_count = 3,
    update_dt = 1,
    status = false,
    data = {},
    id = nil
}

local function req_specified_signup_num_update()
    if req_signup_num_data.req_signup_num_cb then
        if req_signup_num_data.req_signup_num_t_count >= req_signup_num_data.req_signup_num_cd then
            req_signup_num_data.req_signup_num_cb()
            req_signup_num_data.req_signup_num_t_count = 0
        end
        req_signup_num_data.req_signup_num_t_count =
            req_signup_num_data.req_signup_num_t_count + req_signup_num_data.update_dt
    end
end

local instance
function M.Create(game_id, parent)
    if not instance then
        instance = M.New(game_id, parent)
    end
    return instance
end

-- isOpenType 打开方式 normal正常打开 其余是货币不足打开
function M:ctor(game_id, parent)

	ExtPanel.ExtMsg(self)

    self.game_id = game_id
    self.config = GameMatchModel.GetGameIDToConfig(self.game_id)
    self.award = GameMatchModel.GetGameIDToAward(self.game_id)
    dump(self.game_id, "<color=white>game_id:</color>")
    dump(self.config, "<color=white>self.config:</color>")
    dump(self.award, "<color=white>self.award:</color>")
    self.parent = parent or GameObject.Find("Canvas/LayerLv3")
    self.UIEntity = newObject("GameMatchHallDetailPanel", self.parent.transform)
    self.transform = self.UIEntity.transform
    self.gameObject = self.UIEntity
    LuaHelper.GeneratingVar(self.UIEntity.transform, self)
    self.rankItem = GetPrefab("GameMatchHallRankAwardItem")
    self.signup_img = self.signup_btn.transform:GetComponent("Image")
    self:Init()
    self:MakeLister()
    self:AddMsgListener()
    self:OnOff()

    self.req_specified_signup_num_update_timer = Timer.New(req_specified_signup_num_update, 1, -1,nil,true)
    self.req_specified_signup_num_update_timer:Start()

    if self.config.game_type == GameMatchModel.GameType.game_DdzMatchNaming or
        self.config.game_type == GameMatchModel.GameType.game_MjMatchNaming then
        --千元赛
        self.game_over_countdown = tonumber(self.config.over_time) - os.time()
        self.game_start_countdown = tonumber(self.config.start_time) - os.time()

        self.update_timer =Timer.New(function()
                self:UpdateCountdown()
        end,1,-1)
        self.update_timer:Start()
        self:UpdateCountdown()
    end
    DOTweenManager.OpenPopupUIAnim(self.transform)
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
    self.lister["nor_mg_req_specified_signup_num_response"] = basefunc.handler(self, self.nor_mg_req_specified_signup_num_response)

    if self.config.game_type == GameMatchModel.GameType.game_DdzMatch or
        self.config.game_type == GameMatchModel.GameType.game_DdzPDKMatch or
        self.config.game_type == GameMatchModel.GameType.game_MjXzMatch3D then
        self.lister["one_yuan_match_share_finsh"] = basefunc.handler(self, self.one_yuan_match_share_finsh)
    elseif self.config.game_type == GameMatchModel.GameType.game_DdzMatchNaming or
            self.config.game_type == GameMatchModel.GameType.game_MjMatchNaming then
        self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
        self.lister["finish_gift_shop_shopid_13"] = basefunc.handler(self, self.ShowTicketInfo)
    end 
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
    if instance then
        self:RemoveListener()
        if self.req_specified_signup_num_update_timer then
            self.req_specified_signup_num_update_timer:Stop()
            self.req_specified_signup_num_update_timer = nil
        end
        if self.update_timer then
            self.update_timer:Stop()
            self.update_timer = nil
        end
        for k, v in ipairs(self.rankTop3) do
            v:Close()
        end
        self.rankTop3 = nil
        self.rankItem = nil
        self.share_time = nil
        self:change_detail_ui_status(false)
        destroy(self.gameObject)
        instance = nil
    end	 
end

-- 关闭
function GameMatchHallDetailPanel.Close()
    if instance then
        instance:MyExit()
    end
end

function M:OnOff()
    if GameGlobalOnOff.CharityFund then
        self.public_welfare.gameObject:SetActive(true)
    else
        self.public_welfare.gameObject:SetActive(false)
    end
end

function M:change_detail_ui_status(status, m_id)
    req_signup_num_data.status = status
    if status then
        req_signup_num_data.id = m_id
        req_signup_num_data.req_signup_num_cb = function()
            --请求列表
            Network.SendRequest("nor_mg_req_specified_signup_num", {id = m_id})
            -- Network.SendRequest("nor_mg_query_match_active_player_num", {id = m_id})
        end
        --立即设置一次
        local num = req_signup_num_data.data[req_signup_num_data.id] or 0
        self.signup_num_txt.text = num
        self.signup_title_txt.text = ""
    else
        req_signup_num_data.id = nil
        req_signup_num_data.req_signup_num_cb = nil
    end
end

function M:nor_mg_req_specified_signup_num_response(_, data)
    if data.result == 0 then
        req_signup_num_data.data[data.id] = data.signup_num
    end
    if req_signup_num_data.status and req_signup_num_data.id then
        local num = req_signup_num_data.data[req_signup_num_data.id] or 0
        if IsEquals(self.signup_num_txt) then
            self.signup_num_txt.text = num
        end
    end
end

function M:nor_mg_query_match_active_player_num_response(_, data)
    if data.result == 0 and req_signup_num_data.id == data.id then
        self.signup_title_txt.text = "当前有" .. data.num .. "人在比赛"
    end
end

function M:Init()
    EventTriggerListener.Get(self.details_back_btn.gameObject).onClick = basefunc.handler(self, self.OnClickDetailsBack)
    EventTriggerListener.Get(self.signup_btn.gameObject).onClick = basefunc.handler(self, self.OnClickSignup)
    EventTriggerListener.Get(self.details_rule_btn.gameObject).onClick = basefunc.handler(self, self.OnClickRule)
    EventTriggerListener.Get(self.rule_back_btn.gameObject).onClick = basefunc.handler(self, self.OnClickRuleBack)

    --红包赛
    EventTriggerListener.Get(self.showList_btn.gameObject).onClick = basefunc.handler(self, self.ShowListBox)
    EventTriggerListener.Get(self.hideList_btn.gameObject).onClick = basefunc.handler(self, self.HideListBox)
    EventTriggerListener.Get(self.coin_btn.gameObject).onClick = basefunc.handler(self, self.SetUseCoin)
    EventTriggerListener.Get(self.ticket_btn.gameObject).onClick = basefunc.handler(self, self.SetUseTicket)

    --冠名赛
    -- 千元赛购买提示，服务于没有打过千元赛的玩家
    EventTriggerListener.Get(self.hint_pay_close_btn.gameObject).onClick = basefunc.handler(self, self.OnHintPayCloseClick)
    EventTriggerListener.Get(self.qys_share_btn.gameObject).onClick = basefunc.handler(self, self.OnHintPayShareClick)
    EventTriggerListener.Get(self.qys_pay_btn.gameObject).onClick = basefunc.handler(self, self.OnHintPayGotoClick)

    self:RefreshRankAward()
    self.condition_context_txt.text = self.config.enter_num 
    self.time_context_txt.text = self.config.match_time

    --区别
    --麻将规则
    if self.config.game_type == GameMatchModel.GameType.game_MjXzMatch3D or
        self.config.game_type == GameMatchModel.GameType.game_MjMatchNaming then
        self.mj_rule_txt.gameObject:SetActive(true)
    else
        self.mj_rule_txt.gameObject:SetActive(false)
    end
    if self.config.game_type == GameMatchModel.GameType.game_MjXzMatch3D then
        self.mj_rule_txt.text = "麻将比赛中，多人同分时随机排名"
    elseif self.config.game_type == GameMatchModel.GameType.game_MjMatchNaming then
        self.mj_rule_txt.text = "4番封顶"
    end

    --规则
    if self.config.game_tag == GameMatchModel.MatchType.hbs then
        self.rule_txt.text = string.format( "赛事规则：\n\n使用定局积分赛制。\n\n每轮比赛结束后，按积分排名决出晋级玩家，剩余玩家被淘汰。\n\n多副牌情况则完成规定牌局后按积分排名晋级。\n\n斗地主排名同分情况：发到手的手牌都会有隐藏分，手牌越大（如炸弹，王、2、A）那么隐藏分越高，排名同分情况下隐藏分大的玩家胜出。\n\n麻将同分情况：根据座位获得隐藏分，庄家4分，庄家逆时针座位为3分、2分、1分，排名同分情况下隐藏分大的玩家胜出。" )
    elseif self.config.game_tag == GameMatchModel.MatchType.gms then
        self.rule_txt.text = string.format( "赛事规则：\n\n预赛使用打立出局赛制。低于0分淘汰，底分随打立轮次不断增加。\n\n打立出局十轮后，如出局人数未满，强制进行排名晋级。打立出局阶段可复活三次，强制排名时不可复活。斗地主32倍封顶，麻将4番封顶。\n\n剩余人数小于或等于决赛人数后，剩余玩家进入决赛。\n\n决赛使用定局积分赛制。\n\n前三名请联系客服领取奖励。\n\n斗地主排名同分情况：发到手的手牌都会有隐藏分，手牌越大（如炸弹，王、2、A）那么隐藏分越高，排名同分情况下隐藏分大的玩家胜出。\n\n麻将同分情况：根据座位获得隐藏分，庄家4分，庄家逆时针座位为3分、2分、1分，排名同分情况下隐藏分大的玩家胜出。" )
    elseif self.config.game_tag == GameMatchModel.MatchType.mxb then
        self.rule_txt.text = string.format( "明星赛说明：\n\n预赛使用打立出局赛制。低于0分淘汰，底分随打立轮次不断增加。打立出局三轮后，如出局人数未满，强制排名晋级，前96名晋级。斗地主32倍封顶，麻将4番封顶。" )
    elseif self.config.game_tag == GameMatchModel.MatchType.ges then
        self.rule_txt.text = string.format( "赛事介绍：\n\n鲸鱼斗地主月末福利赛\n\n赛事规则：\n\n预赛使用打立出局赛制。低于0分淘汰，底分随打立轮次不断增加，最多12轮。打立出局三轮后，如出局人数未满，强制排名晋级，前258名晋级。斗地主32倍封顶，麻将4番封顶。" )
    end

    if self.config.game_type == GameMatchModel.GameType.game_DdzMatch or
        self.config.game_type == GameMatchModel.GameType.game_DdzPDKMatch or
        self.config.game_type == GameMatchModel.GameType.game_MjXzMatch3D then
        --红包赛
        self.signup_img.sprite = GetTexture("matchpop_btn_yello")
        self.expenses_context_txt.gameObject:SetActive(false)
        self.ticketCount_txt.text = ""
        if self.game_id == 10 then
            --一元免费红包赛
            Network.SendRequest("query_everyday_shared_award", {type="one_yuan_match"}, "查询请求", function (data)
                self.can_share_num = data.status or 0
                self:InitOneYuan()
            end)
        else
            self:InitListBox()
        end
    elseif self.config.game_type == GameMatchModel.GameType.game_DdzMatchNaming or
        self.config.game_type == GameMatchModel.GameType.game_MjMatchNaming then
        --千元赛
        self.signup_img.sprite = GetTexture("matchpop_btn_yellow3")
        if self.config.game_tag == GameMatchModel.MatchType.gms or 
            self.config.game_tag == GameMatchModel.MatchType.qys then
            if (not self.config.iswy or self.config.iswy == 0) and not GameMatchModel.CheckIsCanSignup(self.config) and
                (not self.game_start_countdown or self.game_start_countdown <= 0) then
                self.signup_img.sprite = GetTexture("matchpop_btn_yellow4")
            end
        end
        self:ShowTicketInfo()
    end

    if self.game_id then
        self:change_detail_ui_status(true, self.game_id)
    else
        self:change_detail_ui_status(false)
    end
end

function M:RefreshRankAward(  )
    if self.award then
        destroyChildren(self.rank_content.transform)
        for i, v in ipairs(self.award) do
            local go = GameObject.Instantiate(self.rankItem, self.rank_content)
            go.name = v.rank
            self:SetMatchRankItem(go, v)
        end
    else
        destroyChildren(self.rank_content.transform)
    end
    
    local rank
    for i=1, 3 do
        if i <= #self.award then
            rank = "rank" .. i
            self[rank].gameObject:SetActive(true)
            local icon = MatchComRankRewardItemIcon.Create(self.award[i], self[rank])
            self.rankTop3 = self.rankTop3 or {}
            self.rankTop3[#self.rankTop3 + 1] = icon
        else
            self[rank].gameObject:SetActive(false)
        end
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

function M:OnClickDetailsBack(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self:MyExit()
end

--[[报名]]
function M:OnClickSignup(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if self.config.game_type == GameMatchModel.GameType.game_DdzMatch or
        self.config.game_type == GameMatchModel.GameType.game_DdzPDKMatch or
        self.config.game_type == GameMatchModel.GameType.game_MjXzMatch3D then
        self:SignupHBS()
    elseif self.config.game_type == GameMatchModel.GameType.game_DdzMatchNaming or
        self.config.game_type == GameMatchModel.GameType.game_MjMatchNaming then
        self:SignupGMS()
    end
end

function M:OnClickRule(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self.rule_ui.gameObject:SetActive(true)
end

function M:OnClickRuleBack(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self.rule_ui.gameObject:SetActive(false)
end

--红包赛
--[[报名]]
function M:SignupHBS()
    local signup = function ()
        local request = {
            id = tonumber(self.config.game_id)
        }
        GameMatchModel.SetCurrGameID(self.config.game_id)
        local scene_id = GameMatchModel.GetGameIDToScene(self.config.game_id)
        GameManager.GotoSceneID(scene_id , true , nil , function() 
            if not Network.SendRequest("nor_mg_signup", request ,"正在报名") then
                HintPanel.Create(1, "网络异常", function()
                    GameManager.GotoSceneName("game_Match")
                end)
            end
        end)
        self:MyExit()
    end
    local itemkey, item_count = GameMatchModel.GetMatchCanUseTool(self.config.enter_condi_itemkey, self.config.enter_condi_item_count)
    if itemkey then
        signup()
    else
        if self.config.enter_condi_count <= MainModel.UserInfo.jing_bi then
            signup()
        else
            PayFastPanel.Create(self.config, signup)
        end 
    end
end

function M:InitListBox()
    self.listBox = self.transform:Find("ImgMatchingDetails/ImgGameInfo/ImgGameExpenses/ComboBox/ListBox")
    self.enterConditions = {}

    local conditions = 0
    local itemkey, item_count = GameMatchModel.GetMatchCanUseTool(self.config.enter_condi_itemkey, self.config.enter_condi_item_count)
    if itemkey then
        local item = GameItemModel.GetItemToKey(itemkey)
        self.selected_txt.text = item.name .. "x" .. StringHelper.ToCash(item_count)
    else
        if self.config.enter_condi_count > 0 then
            self.selected_txt.text = "金币x" .. StringHelper.ToCash(self.config.enter_condi_count)
        else
            self.selected_txt.text = "免费"
        end
    end
    self.showList_btn.gameObject:SetActive(false)
    Event.Brocast("global_sysqx_uichange_msg", {key="match_detail", panelSelf=self})
end

function M:ShowListBox()
    if self.listBox then
        self.listBox.gameObject:SetActive(true)
        self.showList_btn.gameObject:SetActive(false)
        self.hideList_btn.gameObject:SetActive(true)
    end
end

function M:HideListBox()
    if self.listBox then
        self.listBox.gameObject:SetActive(false)
        self.showList_btn.gameObject:SetActive(true)
        self.hideList_btn.gameObject:SetActive(false)
    end
end

function M:SetUseCoin()
    self.selected_txt.text = self.enterConditions[1]
    self:HideListBox()
end

function M:SetUseTicket()
    self.selected_txt.text = self.enterConditions[2]
    self:HideListBox()
end

function M:InitOneYuan()
    EventTriggerListener.Get(self.share_btn.gameObject).onClick = basefunc.handler(self, self.OnClickShareBtn)
    EventTriggerListener.Get(self.not_share_btn.gameObject).onClick = basefunc.handler(self, self.OnClickNotShareBtn)

    local itemkey, item_count = GameMatchModel.GetMatchCanUseTool(self.config.enter_condi_itemkey, self.config.enter_condi_item_count)
    self.not_share_btn.gameObject:SetActive(false)
    self.share_btn.gameObject:SetActive(false)
    dump(itemkey, "<color=white>itemkey</color>")
    if itemkey == "prop_5" then
        --有门票直接报名即可
        self.signup_btn.gameObject:SetActive(true)
    else
        self.signup_btn.gameObject:SetActive(false)
        self:SetOneYuanShareBtn()
    end
end

local max_share_num = 3
function M:SetOneYuanShareBtn()
    if GameGlobalOnOff.Share and self.can_share_num and self.can_share_num > 0 then
        if IsEquals(self.share_btn) and IsEquals(self.share_num_txt) then
            self.share_btn.gameObject:SetActive(true)
            self.share_num_txt.text = string.format( "每日最多分享3次（%d/"..max_share_num.."）", max_share_num - self.can_share_num )
        end
        local item = GameItemModel.GetItemToKey(self.config.enter_condi_itemkey[1])
        self.selected_txt.text = item.name .. "x" .. StringHelper.ToCash(self.config.enter_condi_item_count[1])
    else
        self.share_btn.gameObject:SetActive(false)
        self.signup_btn.gameObject:SetActive(true)
        self.selected_txt.text = "金币x" .. StringHelper.ToCash(self.config.enter_condi_count)
    end
    Event.Brocast("global_sysqx_uichange_msg", {key="match_detail", panelSelf=self})
end

function M:OneYuanShare()
    MainModel.GetShareUrl(function(_data)
        dump(_data, "<color=red>分享数据</color>")
        if _data.result == 0 then
            self.share_time = os.time()
            local strOff = "false"
            local userid = MainModel.UserInfo.user_id
            local name = MainModel.UserInfo.name
            local url = _data.share_url

            local imageName = ShareLogic.GetImagePath()

            local sendcall = function ()
                -- 分享链接
                local shareLink = "{\"type\": 7, \"imgFile\": \"" .. imageName .. "\", \"isCircleOfFriends\": " .. strOff .. "}"
                -- local shareLink = string.format(share_link_config.share_link[3].link[1] ,url,"true")
                ShareLogic.ShareGM(shareLink, function (str)
                    print("<color=red>分享完成....str = " .. str .. "</color>")
                    if str == "OK" then
                        if gameRuntimePlatform == "Ios" or gameRuntimePlatform == "Android" then
                            if self.share_time then
                                local _time = (os.time() - self.share_time)
                                if _time > 2 then
                                    MainModel.SendShareFinish("one_yuan_match")
                                else
                                    LittleTips.Create("分享被取消")
                                end
                                self.share_time = nil
                            else
                                LittleTips.Create("分享被取消")
                            end
                        else
                            MainModel.SendShareFinish("one_yuan_match")
                        end
                    else
                        LittleTips.Create("分享被取消")
                    end
                end)
            end

            -- 分享链接
            -- sendcall()

            -- 分享图片
            local SI = ShareImage.Create("one_yuan_match", {msg="", name=name, url=url})
            local camera = SI:GetCamera()

            SI:MakeImage(imageName, function ()
                sendcall()
            end)
        else
            HintPanel.ErrorMsg(_data.result)
            self.share_time = nil
        end
    end ,{share_type = "gysfree_1"})
end

function M:one_yuan_match_share_finsh()
    local request = {
        id = tonumber(self.config.game_id)
    }
    GameMatchModel.SetCurrGameID(self.config.game_id)
    local scene_id = GameMatchModel.GetGameIDToScene(self.config.game_id)
    GameManager.GotoSceneID(scene_id , true , nil , function() 
        if not Network.SendRequest("nor_mg_signup", request, "正在报名") then
            HintPanel.Create(1, "网络异常", function()
                GameManager.GotoSceneName("game_Match")
            end)
        end
    end)
    self:MyExit()
end

function M:OnClickShareBtn(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self:OneYuanShare()
end

function M:OnClickNotShareBtn(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    LittleTips.Create("今日分享次数已用尽，明天再来吧！")
end

--千元赛***********************************************
function M:OnHintPayCloseClick()
    self.hint_qys_pay.gameObject:SetActive(false)
end

function M:OnHintPayShareClick()
    self.hint_qys_pay.gameObject:SetActive(false)
    local link = share_link_config.share_link[2].link[1]
    if link then
        ShareLogic.ShareGM(link, function(str)
            MainModel.SendShareFinish("shared_qys")
        end)
    end
end

function M:OnHintPayGotoClick()
    self.hint_qys_pay.gameObject:SetActive(false)
    PopUp_QYS.CheckBuyTicket(self.config)
end

function M:ShowTicketInfo()
    local itemKey, count = GameMatchModel.GetMatchCanUseTool(self.config.enter_condi_itemkey, self.config.enter_condi_item_count)
    if not itemKey then
        if self.config.enter_condi_count then
            itemKey = "jing_bi"
        else
            itemKey = GameItemModel.GetTimeUnlimitedItemKey(self.config.enter_condi_itemkey)
        end
    end

    if itemKey then
        if IsEquals(self.expenses_context_txt) and IsEquals(self.ticketCount_txt) then
            local item = GameItemModel.GetItemToKey(itemKey)
            count = GameItemModel.GetItemTotalCount(self.config.enter_condi_itemkey)
            if itemKey == "jing_bi" then
                self.expenses_context_txt.text = self.config.enter_condi_count == 0 and "免费" or (item.name .. "x" .. StringHelper.ToCash(self.config.enter_condi_count))
                self.expenses_context_txt.gameObject:SetActive(true)
                self.ticketCount_txt.text = ""
                self.selected_txt.gameObject:SetActive(false)
            else
                local cost = GameItemModel.GetUseToolCount(itemKey, self.config.enter_condi_itemkey, self.config.enter_condi_item_count)
                self.expenses_context_txt.text = cost > 0 and (item.name .. "x" .. StringHelper.ToCash(cost)) or "免费"
                self.expenses_context_txt.gameObject:SetActive(true)
                self.ticketCount_txt.text = "持有门票：" .. count .. "张"
                self.selected_txt.gameObject:SetActive(false)
            end
            if self.config.game_tag == GameMatchModel.MatchType.mxb then
                self.expenses_context_txt.text = "VIP4及以上玩家免费参与"
            end
        end
    end

    Event.Brocast("global_sysqx_uichange_msg", {key="match_detail", panelSelf=self})
end

function M:OnAssetChange(data)
    self:ShowTicketInfo()
    if (not self.config.iswy or self.config.iswy == 0) and not GameMatchModel.CheckIsCanSignup(self.config) and
        (not self.game_start_countdown or self.game_start_countdown <= 0) then
        self.signup_img.sprite = GetTexture("matchpop_btn_yellow4")
    else
        self.signup_img.sprite = GetTexture("matchpop_btn_yellow3")
    end
end

function M:SignupGMS()
    if self.game_start_countdown > 0 then
        local str = "比赛" .. StringHelper.formatTimeDHMS(self.game_start_countdown) .. "后开始"
        LittleTips.Create(str)
        return   
    end
    if self.game_over_countdown <= 0 then
        HintPanel.Create(2,"该比赛已结束了，更多红包赛等你来，是否立刻前往红包赛？",function()
            --切换到红包赛
            self.Close()
            GameMatchHallPanel.SetTgeByID(1)
        end)
        return
    end
    local signup_callback = function()
        GameMatchModel.SetCurrGameID(self.config.game_id)
        local scene_id = GameMatchModel.GetGameIDToScene(self.config.game_id)
        GameManager.GotoSceneID(scene_id, false, nil)
        self:MyExit()
    end

    local signup_not_callback = function(  )
        HintPanel.Create(2,"您没有门票，更多红包赛等你来，是否立刻前往红包赛？",function()
                --切换到红包赛
                self.Close()
                GameMatchHallPanel.SetTgeByID(1)
            end
        )
    end

    local signup = function ()
        dump(self.config, "<color=yellow>冠名赛报名 config</color>")
        Network.SendRequest("nor_mg_signup", {id = self.config.game_id}, "正在报名",
            function(data)
                dump(data, "<color=yellow>nm_mg_signup</color>")
                if data.result == 0 then
                    signup_callback()
                elseif data.result == 3601 then
                    HintPanel.Create(2,"您已经参加过该比赛了，更多红包赛等你来，是否立刻前往红包赛？",function()
                        M.Close()
                        GameMatchHallPanel.SetTgeByID(1)
                    end)
                else
                    HintPanel.ErrorMsg(data.result)
                end
            end
        )
    end

    if GameMatchModel.CheckIsCanSignupByTicket(self.config) then
        --门票可以报名
        signup()
    else
        if GameMatchModel.CheckIsCanSignup(self.config) then
            --金币可以报名
            if self.config.game_tag == GameMatchModel.MatchType.gms then
                --万元赛可以拿金币报名
                if self.config.iswy and self.config.iswy == 1 then
                    signup()
                else
                    -- 是否参加过千元赛
                    MainModel.GetShareStatusQYS(function ()
                        if MainModel.UserInfo.shareQYSstatus == 1 then
                            -- 没有玩过千元赛并且是第一次分享的玩家特有
                            if IsEquals(self.hint_qys_pay) then
                                self.hint_qys_pay.gameObject:SetActive(true)
                            end
                        else
                            PopUp_QYS.CheckBuyTicket(self.config, signup, signup)
                        end
                    end)
                end
            else
                signup()
            end
        else
            --不能报名
            if self.config.game_tag == GameMatchModel.MatchType.gms then
                PayPanel.Create(GOODS_TYPE.jing_bi)
            elseif self.config.game_tag == GameMatchModel.MatchType.mxb then
                if VIPManager.get_vip_level() >= 4 then
                    signup()
                else
                    signup_not_callback()
                end
            elseif self.config.game_tag == GameMatchModel.MatchType.ges then
                signup_not_callback()
            elseif self.config.game_tag == GameMatchModel.MatchType.qys then
                signup_not_callback()
            end
        end
    end
end

function M:UpdateCountdown()
    if self.game_start_countdown and self.game_start_countdown > 0 then
        self.game_start_countdown = self.game_start_countdown - 1
        self.game_over_countdown = self.game_over_countdown - 1
        self.signup_title_txt.text = string.format("比赛开始报名还剩：%s", StringHelper.formatTimeDHMS(self.game_start_countdown))
    elseif self.game_start_countdown and self.game_start_countdown <= 0 then
        if self.game_over_countdown and self.game_over_countdown > 0 then
            self.game_over_countdown = self.game_over_countdown - 1
            self.signup_title_txt.text = string.format("比赛开始还剩：%s", StringHelper.formatTimeDHMS(self.game_over_countdown))
        elseif self.game_over_countdown and self.game_over_countdown <= 0 then
            -- self.signup_title_txt.text = string.format("比赛进行中")
            -- 排行榜分步请求
            local cur_index = 1
            local rank_list = {}
            local call
            call = function ()
                Network.SendRequest(
                    "nor_mg_query_all_rank",
                    {id = self.config.game_id, index = cur_index},
                    "正在请求排名",
                    function(data)
                        cur_index = cur_index + 1
                        if data.result == 0 then
                            for k,v in ipairs(data.rank_list) do  
                                rank_list[#rank_list + 1] = v
                            end
                            if #data.rank_list < 100 then
                                -- 排行榜请求完成
                                GameMatchHallRankPanel.Create(self.config, rank_list)
                                M.Close()
                            else
                                call()
                            end
                        elseif data.result == 1004 then
                            self.signup_title_txt.text = string.format("正在生成排行榜")
                        else
                            HintPanel.ErrorMsg(data.result)
                        end
                    end)
            end
            call()
        end
    end
end