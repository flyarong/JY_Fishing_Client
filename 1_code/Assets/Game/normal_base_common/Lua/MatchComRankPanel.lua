-- 创建时间:2019-05-08
-- 比赛场公用结算界面

local basefunc = require "Game.Common.basefunc"

MatchComRankPanel = basefunc.class()
local C = MatchComRankPanel
C.name = "MatchComRankPanel"

local instance

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["one_yuan_match_share_finsh"] = basefunc.handler(self, self.on_one_yuan_match_share_finsh)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    self:RemoveListener()
    instance = nil

	 
end
function C:MyClose()
    self:RemoveListener()
    C.Close()
end

-- fianlResult={rank,award} game_id
function C.Create(parm, ClearMatchData)
    ExtendSoundManager.PlaySound(audio_config.game.bgm_bisai_jieshu.audio_name)
    SysInteractivePlayerManager.Close()
    SysInteractiveChatManager.Hide()

    if not instance then
        instance = C.New(parm, ClearMatchData)
    end
    return instance
end

function C:ctor(parm, ClearMatchData)

	ExtPanel.ExtMsg(self)

    dump(parm, "<color=white>MatchComRankPanel parm</color>")
    self.parm = parm
    self.config = GameMatchModel.GetGameIDToConfig(self.parm.game_id)
    self.ClearMatchData = ClearMatchData
    self.gameExitTime = os.time()
    self.parent = GameObject.Find("Canvas/LayerLv3").transform
    local obj = newObject(C.name, self.parent)

    self:MakeLister()
    self:AddMsgListener()
    
    self.game_type = GameMatchModel.GetGameIDToGameType()
    self.transform = obj.transform
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)

    self:SetNamingCopyWXBtn()
    self.AwardCellList = {}
    self.camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")
    self.confirm_img = self.win_one_more_btn.transform:GetComponent("Image")
    EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.OnClickClose)
    EventTriggerListener.Get(self.win_one_more_btn.gameObject).onClick = basefunc.handler(self, self.OnConfirmClick)
    EventTriggerListener.Get(self.share_btn.gameObject).onClick = basefunc.handler(self, self.OnClickShare)
    EventTriggerListener.Get(self.Share2Wx_btn.gameObject).onClick = function ()
        self:WeChatShareImage(false)
    end
    EventTriggerListener.Get(self.Share2Pyq_btn.gameObject).onClick = function ()
        self:WeChatShareImage(true)
    end
    self.CopyWX_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            LittleTips.Create("已复制QQ号请前往QQ进行添加")
            UniClipboard.SetText("4008882620")
        end
    )
    self.confirm_parm = "nor"
    self.share_btn.gameObject:SetActive(true)

    if not GameGlobalOnOff.ShowOff then
        self.share_btn.gameObject:SetActive(false)
        local pos = self.win_one_more_btn.transform.localPosition
        self.win_one_more_btn.transform.localPosition = Vector3.New(0, pos.y, 0)
    end

    self:InitUI()

    Event.Brocast("global_sysqx_uichange_msg", {key="match_js", panelSelf=self})
end

function C:MyRefresh()
end
--[[刷新功能，供Logic和model调用，重复性操作]]
function C:InitUI()
    self.win_root.gameObject:SetActive(true)
    self.lose_root.gameObject:SetActive(false)
    self.close_btn.gameObject:SetActive(false)
    self.win_one_more_btn.gameObject:SetActive(true)
    self.size = ShareLogic.size
    self.game_type = GameMatchModel.GetGameIDByType(self.parm.game_id)

    local share_parm = {}
    if self.game_type == GameMatchModel.MatchType.qys then
        share_parm.share_type = "qysfx_1"
    else
        share_parm.share_type = "gysmacthfx_1"
    end
    MainModel.GetShareUrl(function(_data)
        if _data.result == 0 then
            self.url = _data.share_url
            self:EWM(self.EWMImage_img.mainTexture, ewmTools.getEwmDataWithPixel(self.url, self.size))
        else
            HintPanel.ErrorMsg(_data.result)
        end
    end,share_parm)
    URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.HeadImage_img, function ()
        self.loadHeadFinish = true
        URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.IconImage_img)
    end, "share_head_url_nnn")
    self.NameText_txt.text = MainModel.UserInfo.name
    self.game_exit_time_txt.text = os.date("%Y.%m.%d %H:%M", self.gameExitTime)
    PersonalInfoManager.SetHeadFarme(self.HeadFrameImage_img)
    VIPManager.set_vip_text(self.head_vip_txt)

    if not self.parm.fianlResult then
    else
        self.close_btn.gameObject:SetActive(true)
        if self.parm.fianlResult.reward ~= nil then
            ExtendSoundManager.PlaySound(audio_config.ddz.sod_game_win.audio_name)
            self:RefreshWin()
        else
            ExtendSoundManager.PlaySound(audio_config.ddz.sod_game_lose.audio_name)
            self:RefreshWin()
        end
    end

    HandleLoadChannelLua(C.name, self)
end

function C:OnConfirmClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if not self.confirm_parm or self.confirm_parm == "nor" then
        self:OnClickGotoMatch()
    elseif self.confirm_parm == "next" then
        self:OnClickOneMore()
    elseif self.confirm_parm == "by" then
        self:OnClickGotoBY()
    elseif self.confirm_parm == "dh" then
        MainModel.OpenDH()
    end
end

function C:OnClickGotoBY()
    print("<color=yellow>跳转捕鱼</color>")
    local quit_game = function(data)
        if data.result == 0 then
            MainLogic.ExitGame()
            GameManager.GotoUI({gotoui="game_FishingHall"})
        else
            HintPanel.ErrorMsg(data.result)
        end
    end
    if Network.SendRequest("nor_mg_quit_game",nil,"退出报名",quit_game) then
        self.ClearMatchData(self.parm.game_id)
    else
        MjAnimation.Hint(2, Vector3.New(0, -350, 0), Vector3.New(0, 0, 0))
    end    
end
function C:OnClickGotoMatch()
    print("<color=yellow>跳转比赛场大厅</color>")
    local quit_game = function(data)
        if data.result == 0 then
            MainLogic.ExitGame()
            if self.game_type == GameMatchModel.MatchType.gms then
                GameManager.GotoUI({gotoui="match_hall", goto_scene_parm=GameMatchModel.MatchType.gms})
            elseif self.game_type == GameMatchModel.MatchType.qys or 
                    self.game_type == GameMatchModel.MatchType.mxb or
                    self.game_type == GameMatchModel.MatchType.ges or
		    self.game_type == GameMatchModel.MatchType.sws then
                GameManager.GotoUI({gotoui="match_hall", goto_scene_parm=GameMatchModel.MatchType.hbs})
            end
        else
            HintPanel.ErrorMsg(data.result)
        end
    end
    if Network.SendRequest("nor_mg_quit_game",nil,"退出报名",quit_game) then
        self.ClearMatchData(self.parm.game_id)
    else
        MjAnimation.Hint(2, Vector3.New(0, -350, 0), Vector3.New(0, 0, 0))
    end
end

function C:OnClickOneMore()
    local config = GameMatchModel.GetGameIDToConfig(self.parm.game_id)
    local call = function ()
        if Network.SendRequest("nor_mg_replay_game", {id = self.parm.game_id}, "请求报名") then
            self.ClearMatchData(self.parm.game_id)
        else
            MjAnimation.Hint(2, Vector3.New(0, -350, 0), Vector3.New(0, 0, 0))
        end
    end
    if config then
        if MainModel.GetLocalType(config.game_type) == "ddz" and self.parm.game_id == 10 then
            Network.SendRequest("query_everyday_shared_award", {type="one_yuan_match"}, "查询请求", function (data)
                self.can_share_num = data.status or 0
                if self.can_share_num <= 0 then
                    if config.enter_condi_count and config.enter_condi_count > MainModel.UserInfo.jing_bi then
                        PayFastPanel.Create(config, call)
                    else
                        call()
                    end                        
                else
                    self:OneYuanShare(call)
                end
            end)
        else
            local itemkey, item_count = GameMatchModel.GetMatchCanUseTool(config.enter_condi_itemkey, config.enter_condi_item_count)
            if itemkey then
                if itemkey == "jing_bi" then
                    local l = VIPManager.get_vip_level()
                    if (self.parm.game_id == 4 or self.parm.game_id == 7 or self.parm.game_id == 11 or self.parm.game_id == 12) and (not l or l < 1) then
                        LittleTips.Create("门票不足")
                    else
                        call()
                    end
                else
                    call()
                end
            else
                local l = VIPManager.get_vip_level()
                if (self.parm.game_id == 4 or self.parm.game_id == 7 or self.parm.game_id == 11 or self.parm.game_id == 12) and (not l or l < 1) then
                    LittleTips.Create("门票不足")
                else
                    if config.enter_condi_count and config.enter_condi_count > MainModel.UserInfo.jing_bi then
                        PayFastPanel.Create(config, call)
                    else
                        call()
                    end 
                end
            end 
        end
    else
        dump(self.parm, "<color=red>parm</color>")
    end
end

function C:OnClickComfort()
    SharePanel.Create("match", "comfort")
end
function C:ShowBack(b)
    self.close_btn.gameObject:SetActive(b)
    self.Share2Wx_btn.gameObject:SetActive(b)
    self.Share2Pyq_btn.gameObject:SetActive(b)
    if b then
        self:SetNamingCopyWXBtn()
    else
        self.CopyWX_btn.gameObject:SetActive(false)
    end

    self.ShareRect.gameObject:SetActive(not b)
end
function C:OnClickShare()
    self.is_shareing = true
    self.Share2Wx_btn.gameObject:SetActive(true)
    self.Share2Pyq_btn.gameObject:SetActive(true)
    self.win_one_more_btn.gameObject:SetActive(false)
    self.share_btn.gameObject:SetActive(false)
    self.confirm_hint_txt.gameObject:SetActive(false)
end
function C:WeChatShareImage(isCircleOfFriends)
    local strOff
    if isCircleOfFriends then
        strOff = "true"
    else
        strOff = "false"
    end

    local imageName = ShareLogic.GetImagePath()

    local sendcall = function ()
        -- 分享链接
        print("<color=red>[Share] sendcall</color>")
        local shareLink = "{\"type\": 7, \"imgFile\": \"" .. imageName .. "\", \"isCircleOfFriends\": " .. strOff .. "}"
        ShareLogic.ShareGM(shareLink, function (str)
            print("<color=red>分享完成....str = " .. str .. "</color>")
            if str == "OK" then
            end
        end)
    end

    self:ShowBack(false)
    Event.Brocast("ui_share_begin")

    local pos1 = self.share_node1.position
    local pos2 = self.share_node2.position
    local s1 = self.camera:WorldToScreenPoint(pos1)
    local s2 = self.camera:WorldToScreenPoint(pos2)
    local x = s1.x
    local y = s1.y
    local w = s2.x - s1.x
    local h = s2.y - s1.y
    local canvas = AddCanvasAndSetSort(self.gameObject, 100)
    panelMgr:MakeCameraImgAsync(x, y, w, h, imageName, function ()
        print("<color=red>[Share] MakeCameraImgAsync</color>")
        Destroy(canvas)
        self:ShowBack(true)
        Event.Brocast("ui_share_end")
        sendcall()
    end,false, GameGlobalOnOff.OpenInstall)
end

function C.Close()
    if instance and IsEquals(instance.transform) then
        GameObject.Destroy(instance.transform.gameObject)
    end
    instance = nil
end

function C:OnClickClose()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if self.is_shareing then
        self.is_shareing = false
        self.win_one_more_btn.gameObject:SetActive(true)
        self.share_btn.gameObject:SetActive(true)
        self.Share2Wx_btn.gameObject:SetActive(false)
        self.Share2Pyq_btn.gameObject:SetActive(false)
        self.confirm_hint_txt.gameObject:SetActive(true)
    else
        if Network.SendRequest("nor_mg_quit_game", nil, "") then
            self.ClearMatchData(self.parm.game_id)
        else
            MjAnimation.Hint(2, Vector3.New(0, -350, 0), Vector3.New(0, 0, 0))
        end
    end
end

function C:RefreshWin()
    self.win_root.gameObject:SetActive(true)
    self.lose_root.gameObject:SetActive(false)

    self.my_rank_txt.text = "第" .. self.parm.fianlResult.rank .. "名"
    self.tophint_txt.text = "恭喜  " .. MainModel.UserInfo.name .. "\n" .. "在【" .. self.parm.game_name .. "】中获得"
    self.my_rank_times_txt.gameObject:SetActive(false)

    local match_type = GameMatchModel.GetGameIDToGameType(self.parm.game_id)
    dump(match_type, "<color=white>match_type>>>></color>")
    if match_type == GameMatchModel.GameType.game_DdzMatch or match_type == GameMatchModel.GameType.game_DdzPDKMatch or match_type == GameMatchModel.GameType.game_MjXzMatch3D then
        dump(self.parm.fianlResult.detailRanknum,"<color=red>锦标赛结束----------------</color>")
        if self.parm.fianlResult.detailRanknum then 
            for i=1,#self.parm.fianlResult.detailRanknum do  
                if i == self.parm.fianlResult.rank then
                    self.my_rank_times_txt.text=self.parm.fianlResult.detailRanknum[i].."次"
                    self.my_rank_times_txt.gameObject:SetActive(true)
                end 
            end 
        end
    elseif match_type == GameMatchModel.GameType.game_DdzMatchNaming or match_type == GameMatchModel.GameType.game_MjMatchNaming then
        if self.parm.fianlResult.qys_top_rank then
            self.my_rank_times_txt.text= string.format( "历史最高第%s名",self.parm.fianlResult.qys_top_rank)
            self.my_rank_times_txt.gameObject:SetActive(true)
        end
    end

    self:CloseAwardCell()
    --根据当前名次显示对应信息
    local award_desc, award_icon, is_local_icons = GameMatchModel.GetAwardByRank(self.parm.game_id, self.parm.fianlResult.rank)
    if (self.parm.fianlResult.reward and next(self.parm.fianlResult.reward)) or (award_desc and #award_desc > 0) then
        self.my_rank_txt.transform.localPosition = Vector3.New(0, 312, 0)
        if award_desc and next(award_desc) then
            for i = 1, #award_desc do
                local v = {}
                v.desc = award_desc[i]
                v.icon = award_icon[i]
                if is_local_icons then
                    v.is_local_icon = is_local_icons[i]
                end
                self.AwardCellList[#self.AwardCellList + 1] = self:CreateItem(v)
            end
        else
            self.my_rank_txt.transform.localPosition = Vector3.New(0, 0, 0)
        end
    else
        self.my_rank_txt.transform.localPosition = Vector3.New(0, 0, 0)
    end

    if self.parm.fianlResult.rank < 4 then
        self:OnClickShare()
    end

    self.game_type = GameMatchModel.GetGameIDByType(self.parm.game_id)
    print("<color=red>self.game_type = " .. self.game_type .. "</color>")
    -- 实物赛需要的逻辑处理
    self.confirm_hint_txt.gameObject:SetActive(false)
    self.confirm_hint_txt.text = ""
    if self.game_type == "sws" then
        if self.parm.fianlResult.reward then
            local data = AwardManager.GetAwardList(self.parm.fianlResult.reward)
            local is_yb = false -- 是否有奖励鱼币
            local is_hb = false -- 是否有奖励红包
            local hb_value = 0 -- 奖励红包数量
            for k,v in ipairs(data) do
                if v.type == "fish_coin" then
                    is_yb = true
                end
                if v.type == "shop_gold_sum" then
                    is_hb = true
                    hb_value = v.value
                end
            end
            if is_yb and is_hb then
                self.confirm_parm = "nor"
                self.confirm_img.sprite = GetTexture("settlement_btn_gdbs")
                print("<color=red>奖励同时存在鱼币和红包</color>")
            else
                if is_yb then
                    self.confirm_parm = "by"
                    self.confirm_img.sprite = GetTexture("settlement_btn_qwby")
                    self.confirm_hint_txt.text = "街机打鱼专属道具，可转化为大量金币"
                    self.confirm_hint_txt.gameObject:SetActive(true)
                elseif is_yb then
                    self.confirm_parm = "dh"
                    self.confirm_img.sprite = GetTexture("settlement_btn_qwdh")
                    self.confirm_hint_txt.text = "恭喜您获得" .. hb_value .. "话费，已为您转换成等价值福利券"
                    self.confirm_hint_txt.gameObject:SetActive(true)
                else
                    self.confirm_parm = "nor"
                    self.confirm_img.sprite = GetTexture("settlement_btn_gdbs")
                    print("<color=red>奖励同时不存在鱼币和红包</color>")
                end
            end
        else
            self.confirm_parm = "nor"
            self.confirm_img.sprite = GetTexture("settlement_btn_gdbs")
        end
    else
        if self.game_type == "hbs" then
            self.confirm_parm = "next"
            self.confirm_img.sprite = GetTexture("settlement_btn_next")          
        else
            self.confirm_parm = "nor"
            self.confirm_img.sprite = GetTexture("settlement_btn_gdbs")
        end
    end
end

function C:CloseAwardCell()
    for i, v in ipairs(self.AwardCellList) do
        GameObject.Destroy(v.gameObject)
    end
    self.AwardCellList = {}
end
function C:CreateItem(data)
    local obj = GameObject.Instantiate(self.AwardPrefab)
    obj.transform:SetParent(self.AwardNode)
    obj.transform.localScale = Vector3.one
    local DescText = obj.transform:Find("DescText"):GetComponent("Text")
    DescText.text = data.desc
    local NameText = obj.transform:Find("AwardIcon/NameText"):GetComponent("Text")
    NameText.text = ""
    obj.gameObject:SetActive(true)
    local AwardIcon = obj.transform:Find("AwardIcon"):GetComponent("Image")
    GetTextureExtend(AwardIcon, data.icon, data.is_local_icon)
        
    return obj
end

function C:SetNamingCopyWXBtn()
    local award_desc, award_icon, is_local_icons = GameMatchModel.GetAwardByRank(self.parm.game_id, self.parm.fianlResult.rank)
    if not (self.parm.fianlResult.reward and next(self.parm.fianlResult.reward)) and (award_desc and #award_desc > 0) then
        self.CopyWX_btn.gameObject:SetActive(true)
    else
        self.CopyWX_btn.gameObject:SetActive(false)
    end
    self.game_type = GameMatchModel.GetGameIDByType(self.parm.game_id)
    -- if self.game_type == GameMatchModel.MatchType.ges then
    --     self.CopyWX_btn.gameObject:SetActive(true)
    -- end
end

function C:EWM(texture, data)    
    if not texture or not data then
        return
    end
    local w = data.width
    local scale = math.floor(self.size/w)
    local py = (self.size-w*scale)/2
    py = math.floor(py)
    print(py .. " " .. w .. " " .. scale)
    local dots = data.data
    for i = 1, w do
        for j = 1, w do
            if dots[(i-1)*w + j] == 1 then
                texture:SetPixel(i-1+py, j-1+py, Color.New(0,0,0,1))
            else
                texture:SetPixel(i-1+py, j-1+py, Color.New(1,1,1,1))
            end
        end
    end
    texture:Apply()
end

function C:OneYuanShare(call)
    self.share_finish_call = call
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
            local SI = ShareImage.Create("one_yuan_match", {msg="", name=name, url=url})
            local camera = SI:GetCamera()

            SI:MakeImage(imageName, function ()
                sendcall()
            end)
        else
            HintPanel.ErrorMsg(_data.result)
            self.share_time = nil
        end
    end )
end

function C:on_one_yuan_match_share_finsh()
    if self.share_finish_call then
        self.share_finish_call()
    end
end