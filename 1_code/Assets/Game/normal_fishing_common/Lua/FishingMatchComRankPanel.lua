-- 创建时间:2019-05-08
-- 比赛场公用结算界面

local basefunc = require "Game.Common.basefunc"

FishingMatchComRankPanel = basefunc.class()
local C = FishingMatchComRankPanel
C.name = "FishingMatchComRankPanel"

local instance

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["fsmg_quit_game_response"] = basefunc.handler(self, self.on_fsmg_quit_game_response)
    self.lister["fsqmg_quit_game_response"] = basefunc.handler(self, self.on_fsmg_quit_game_response)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    destroy(self.gameObject)
    self:RemoveListener()
    instance = nil

	 
end
function C:MyClose()
    self:RemoveListener()
    C.Close()
end
--退出游戏
function C:on_fsmg_quit_game_response(_, data)
    dump(data, "<color=yellow>on_fsmg_quit_game_response</color>")
    if data.result == 0 then
        MainLogic.ExitGame()
        GameManager.GotoUI({gotoui="game_FishingHall"})
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function C.Create(parm, ClearMatchData)
    ExtendSoundManager.PlaySound(audio_config.game.bgm_bisai_jieshu.audio_name)
    if not instance then
        instance = C.New(parm, ClearMatchData)
    end
    return instance
end

function C:ctor(parm, ClearMatchData)

	ExtPanel.ExtMsg(self)

    dump(parm, "<color=white>FishingMatchComRankPanel parm</color>")
    if not parm then return end
    self.parm = parm
    if self.parm.game_type == "qys" then
        self.config = FishingManager.GetLastQysToConfig()
    else
        self.config = FishingManager.GetLastDjsToConfig()
    end
    self.ClearMatchData = ClearMatchData
    self.gameExitTime = os.time()
    if self.parm.is_old_rank then
        self.parent = GameObject.Find("Canvas/LayerLv5").transform
    else
        self.parent = GameObject.Find("Canvas/LayerLv3").transform
    end
    local obj = newObject(C.name, self.parent)

    self:MakeLister()
    self:AddMsgListener()

    self.transform = obj.transform
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)


    self:SetNamingCopyWXBtn()
    self.AwardCellList = {}
    self.camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")

    self.confirm_img = self.goto_fishing_btn.transform:GetComponent("Image")
    EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.OnClickClose)
    EventTriggerListener.Get(self.goto_fishing_btn.gameObject).onClick = basefunc.handler(self, self.OnConfirmClick)
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
    self.share_btn.gameObject:SetActive(true)

    if not GameGlobalOnOff.ShowOff then
        self.share_btn.gameObject:SetActive(false)
        local pos = self.goto_fishing_btn.transform.localPosition
        self.goto_fishing_btn.transform.localPosition = Vector3.New(0, pos.y, 0)
    end
    -- 上期排名打开界面不显示前往捕鱼按钮
    if self.parm.is_old_rank then
        self.goto_fishing_btn.gameObject:SetActive(false)
    end

    self:InitUI()

    DOTweenManager.OpenPopupUIAnim(self.transform)
end

function C:MyRefresh()
end

function C:InitUI()
    self.win_root.gameObject:SetActive(true)
    self.lose_root.gameObject:SetActive(false)
    self.close_btn.gameObject:SetActive(false)
    self.size = ShareLogic.size

    local share_parm = {}
    share_parm.share_type = "bymatchfx_1"
    MainModel.GetShareUrl(function(_data)
        if _data.result == 0 then
            self.url = _data.share_url
            self:EWM(self.EWMImage_img.mainTexture, ewmTools.getEwmDataWithPixel(self.url, self.size))
        else
            HintPanel.ErrorMsg(_data.result)
        end
    end, share_parm)
    URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.HeadImage_img, function ()
        self.loadHeadFinish = true
        URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.IconImage_img)
    end, "share_head_url_nnn")
    self.NameText_txt.text = MainModel.UserInfo.name
    self.game_exit_time_txt.text = os.date("%Y.%m.%d %H:%M", self.gameExitTime)
    PersonalInfoManager.SetHeadFarme(self.HeadFrameImage_img)
    VIPManager.set_vip_text(self.head_vip_txt)

    self.yingfen_txt.text = StringHelper.ToCash(self.parm.grades or 0)
    if self.parm.game_type == "djs" then
        if self.parm.fianlResult then
            self.close_btn.gameObject:SetActive(true)
            -- 注意这里的判断 reward的第一个是额外奖励，如果有固定奖励就还有第二个值
            local reward = self.parm.fianlResult.reward
            if reward and #reward > 0 and (reward[1].value > 0 or (reward[2] and reward[2].value > 0)) then
                ExtendSoundManager.PlaySound(audio_config.ddz.sod_game_win.audio_name)
                self:RefreshWin()
            else
                ExtendSoundManager.PlaySound(audio_config.ddz.sod_game_lose.audio_name)
                self:RefreshLose()
            end
        end
    else
        self.close_btn.gameObject:SetActive(true)
        local cfg = FishingManager.GetQYSCfgByRank(self.parm.fianlResult.game_id, self.parm.fianlResult.rank)
        if cfg.award_desc and #cfg.award_desc > 0 then
            ExtendSoundManager.PlaySound(audio_config.ddz.sod_game_win.audio_name)
            self:RefreshWin()
        else
            ExtendSoundManager.PlaySound(audio_config.ddz.sod_game_lose.audio_name)
            self:RefreshLose()
        end
    end

    HandleLoadChannelLua(C.name, self)
end

function C:OnConfirmClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self:OnClickGotoBY()
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
    if self.parm.is_old_rank then
        quit_game()
    else
        local xy
        if self.parm.game_type == "qys" then
            xy = "fsqmg_quit_game"
        else
            xy = "fsmg_quit_game"
        end
        if Network.SendRequest(xy, nil, "退出报名", quit_game) then
            self.ClearMatchData(self.parm.game_id)
        else
            MjAnimation.Hint(2, Vector3.New(0, -350, 0), Vector3.New(0, 0, 0))
        end    
    end
end
function C:ShowBack(b)
    self.close_btn.gameObject:SetActive(b)
    self.Share2Wx_btn.gameObject:SetActive(b)
    self.Share2Pyq_btn.gameObject:SetActive(false)
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
    self.Share2Wx_btn.transform.localPosition = Vector3.New(0, -455, 0)
    self.Share2Pyq_btn.gameObject:SetActive(false)
    self.share_btn.gameObject:SetActive(false)
    self.confirm_hint_txt.gameObject:SetActive(false)
    if not self.parm.is_old_rank then
        self.goto_fishing_btn.gameObject:SetActive(false)
    end
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
        print("<color=red>部分截图完成</color>")
        Destroy(canvas)
        self:ShowBack(true)
        Event.Brocast("ui_share_end")
        sendcall()
    end,false, GameGlobalOnOff.OpenInstall)
end

function C.Close()
    if instance then
        instance:MyExit()
    end
end

function C:OnClickClose()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if self.is_shareing then
        self.is_shareing = false

        self.share_btn.gameObject:SetActive(true)
        self.Share2Wx_btn.gameObject:SetActive(false)
        self.Share2Pyq_btn.gameObject:SetActive(false)
        self.confirm_hint_txt.gameObject:SetActive(true)
        if not self.parm.is_old_rank then
            self.goto_fishing_btn.gameObject:SetActive(true)
        end
    else
        if self.parm.is_old_rank then
            C.Close()
        else
            FishingMatchLogic.quit_game()
            self.ClearMatchData(self.parm.game_id)
        end
    end
end

function C:RefreshLose()
    self.win_root.gameObject:SetActive(false)
    self.lose_root.gameObject:SetActive(true)
    self.losehint4_txt.text = self.parm.fianlResult.rank
end

function C:RefreshWin()
    self.win_root.gameObject:SetActive(true)
    self.lose_root.gameObject:SetActive(false)

    self.my_rank_txt.text = self.parm.fianlResult.rank

    self:CloseAwardCell()
    --根据当前名次显示对应信息
    local award_desc, award_icon, is_local_icons
    if self.parm.game_type == "qys" then
        award_desc, award_icon, is_local_icons = FishingManager.GetQYSAwardByRank(self.parm.game_id, self.parm.fianlResult.rank)
    else
        award_desc, award_icon, is_local_icons = FishingManager.GetAwardByRank(self.parm.game_id, self.parm.fianlResult.rank)
    end
    if not award_desc then
        award_desc = {}
        award_icon = {}
    end
    local ey_award_desc = {}
    local ey_award_icon = {}
    if self.parm.game_type == "djs" then
        if self.parm.fianlResult.reward and #self.parm.fianlResult.reward > 0 then
            -- 第一个是额外奖励
            local v = self.parm.fianlResult.reward[1]
            if v.value and v.value > 0 then
                ey_award_desc[#ey_award_desc + 1] = "福利券x" .. StringHelper.ToRedNum(v.value)
                ey_award_icon[#ey_award_icon + 1] = "ty_icon_flq3"
            end
        end
    end
    if award_desc and next(award_desc) then
        for i = 1, #award_desc do
            if award_desc[i] ~= "" then
                local v = {}
                v.desc = award_desc[i]
                v.icon = award_icon[i]
                if is_local_icons then
                    v.is_local_icon = is_local_icons[i]
                end
                self.AwardCellList[#self.AwardCellList + 1] = self:CreateItem(v)
            end
        end
    end
    if ey_award_desc and next(ey_award_desc) then
        for i = 1, #ey_award_desc do
            if ey_award_desc[i] ~= "" then
                local v = {}
                v.desc = ey_award_desc[i]
                v.icon = ey_award_icon[i]
                if is_local_icons then
                    v.is_local_icon = is_local_icons[i]
                end
                self.AwardCellList[#self.AwardCellList + 1] = self:CreateItem(v)
            end
        end
    end

    if self.parm.fianlResult.rank < 4 then
        self:OnClickShare()
    end
end

function C:CloseAwardCell()
    for i, v in ipairs(self.AwardCellList) do
        destroy(v.gameObject)
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
    if self.parm and self.parm.fianlResult and self.parm.fianlResult.rank < 4 then
        self.CopyWX_btn.gameObject:SetActive(true)
    else
        self.CopyWX_btn.gameObject:SetActive(false)
    end
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



