-- 创建时间:2018-08-20

local basefunc = require "Game.Common.basefunc"

DDZSharePrefab = basefunc.class()

local shareStyle=
{
    [1] = "%s倍，简直逆天啦！",
    [2] = "%s倍，牛逼不牛逼？",
    [3] = "%s倍，谁敢跟我比？",
}

-- parm={myseatno, dzseatno, bei, settlement}
function DDZSharePrefab.Create(game_id, parm, finishcall)
    return DDZSharePrefab.New(game_id, parm, finishcall)
end

function DDZSharePrefab:ctor(game_id, parm, finishcall)
    dump(parm, "<color=red>DDZSharePrefab parm</color>")
    self.parm = parm
	self.game_id = game_id
    self.finishcall = finishcall
	local parent = GameObject.Find("Canvas/LayerLv4")
    self.gameObject = newObject("DDZSharePrefab", parent.transform)
    self.transform = self.gameObject.transform
    local tran = self.transform

    self.BackButton = tran:Find("BackButton"):GetComponent("Button")
    self.BackButton.onClick:AddListener(function ()
        self:OnBackClick()
    end)
    self.HYButton = tran:Find("HYButton"):GetComponent("Button")
    self.PYQButton = tran:Find("PYQButton"):GetComponent("Button")
	self.HYButton.onClick:AddListener(function ()
        self:OnHYClick()
    end)
	self.PYQButton.onClick:AddListener(function ()
        self:OnPYQClick()
    end)
    self.HYButton.gameObject:SetActive(true)
    self.PYQButton.gameObject:SetActive(false)
    self.HYButton.transform.localPosition = Vector3.New(0, -455, 0)

    self.HintImage = tran:Find("HintImage")
    self.HintImage.gameObject:SetActive(false)
    self.BGImage = tran:Find("Image"):GetComponent("Image")
    self.HeadImage = tran:Find("Image/HeadImage"):GetComponent("Image")
    self.HeadFrame = tran:Find("Image/HeadFrame"):GetComponent("Image")
    self.head_vip_txt = tran:Find("Image/@head_vip_txt"):GetComponent("Text")
    self.NameText = tran:Find("Image/NameText"):GetComponent("Text")
    self.EWMImage = tran:Find("Image/EWMImage"):GetComponent("Image")
    self.LogoImage = tran:Find("Image/EWMImage/LogoImage"):GetComponent("Image")
	self.DescText = tran:Find("Image/Node/DescText"):GetComponent("Text")
    self.MoneyText = tran:Find("Image/Image/MoneyText"):GetComponent("Text")
    self.RedText = tran:Find("Image/Image/RedText"):GetComponent("Text")

    self.node1 = tran:Find("Image/node1")
    self.node2 = tran:Find("Image/node2")
    self.camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")

    self.GameText = tran:Find("Image/GameText"):GetComponent("Text")
    self.ExitTimeText = tran:Find("Image/ExitTimeText"):GetComponent("Text")
    self.YQImage = tran:Find("Image/YQImage"):GetComponent("RectTransform")
    self.JSImage = tran:Find("Image/JSImage"):GetComponent("RectTransform")
    self.GYImage = tran:Find("Image/GYImage"):GetComponent("RectTransform")

    self.YQText = tran:Find("Image/YQImage/YQText"):GetComponent("Text")
    self.JSText = tran:Find("Image/JSImage/JSText"):GetComponent("Text")
    self.GYText = tran:Find("Image/GYImage/GYText"):GetComponent("Text")
    self.RankText = tran:Find("Image/Text1/RankText"):GetComponent("Text")

    self:InitUI()
end
function DDZSharePrefab:ShowBack(b)
    if IsEquals(self.HYButton) then
	self.HYButton.gameObject:SetActive(b)
    end
    if IsEquals(self.BackButton) then
	self.BackButton.gameObject:SetActive(b)
    end
end
function DDZSharePrefab:InitUI()
	self:ShowBack(false)
    self.NameText.text = MainModel.UserInfo.name
    URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.HeadImage)
    URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.LogoImage)

    PersonalInfoManager.SetHeadFarme(self.HeadFrame)
    VIPManager.set_vip_text(self.head_vip_txt)
    
    MainModel.GetFlauntStatus(function (data)
        if IsEquals(self.HintImage) then
        if data >= 1 then
            self.HintImage.gameObject:SetActive(true)
        else
            self.HintImage.gameObject:SetActive(false)
            end                
        end            
    end)

    local v = GameFreeModel.GetGameIDToConfig(self.game_id)
    if v.game_type == "game_DdzFree" then
        self.GameText.text = "经典斗地主" .. v.game_name
    elseif v.game_type == "game_DdzLaizi" then
        self.GameText.text = "癞子斗地主" .. v.game_name
    elseif v.game_type == "game_DdzTy" then
        self.GameText.text = "听用斗地主" .. v.game_name
    elseif v.game_type == "game_DdzFreeER" then
        self.GameText.text = "经典斗地主二人场" .. v.game_name
    else
        self.GameText.text = ""
    end
    self.ExitTimeText.text = os.date("%Y.%m.%d %H:%M", self.parm.gameExitTime)
    self:RandomShareStyle()

    if self.parm.settlement.award and self.parm.myseatno and self.parm.settlement.award[self.parm.myseatno] then
        local mm = self.parm.settlement.award[self.parm.myseatno]
        self.MoneyText.text = StringHelper.ToCashSymbol(mm)
        self.RedText.text = StringHelper.ToRedNum(mm/10000) .. "元"
    else
        self.MoneyText.text = "+0"
        self.RedText.text = "0元"
    end

	self.size = ShareLogic.size
    MainModel.GetShareUrl(function(_data)
        dump(_data, "<color=red>分享的URL</color>")
    	self:ShowBack(true)
        if _data.result == 0 then
        	self.url = _data.share_url
        	self:UpdateUI()
        else
        	HintPanel.ErrorMsg(_data.result)
        end
    end,{share_type = "dzzgbfx_1"})
    self:CalcScore()
    self:RunAnim()

    HandleLoadChannelLua("DDZSharePrefab", self)
end
function DDZSharePrefab:RandomShareStyle()
    local t = 1
    self.DescText.text = string.format(shareStyle[t], tostring(self.parm.bei))
end
function DDZSharePrefab:ChangeUIFinish()
    if self.animTime then
        self.animTime:Stop()
    end
    self.animTime = nil
    if self.rankanimTime then
        self.rankanimTime:Stop()
    end
    self.rankanimTime = nil

    if IsEquals(self.YQImage) and  IsEquals(self.JSImage) and IsEquals(self.GYImage) and
        IsEquals(self.RankText) and IsEquals(self.YQText) and IsEquals(self.JSText) and IsEquals(self.GYText) then
        self.YQImage.sizeDelta = {x = 300 * self.shareScore.yq/10, y = 20}
        self.JSImage.sizeDelta = {x = 300 * self.shareScore.js/10, y = 20}
        self.GYImage.sizeDelta = {x = 300 * self.shareScore.gy/10, y = 20}

        self.RankText.text = math.floor(self.shareScore.rank) .. "%"
        self.YQText.text = StringHelper.ToCash(self.shareScore.yq)
        self.JSText.text = StringHelper.ToCash(self.shareScore.js)
        self.GYText.text = StringHelper.ToCash(self.shareScore.gy)
    end
end
function DDZSharePrefab:ChangeUIValue(v)
    local yq = self.shareScore.yq * v
    local js = self.shareScore.js * v
    local gy = self.shareScore.gy * v

    self.YQImage.sizeDelta = {x = 300 * yq/10, y = 20}
    self.JSImage.sizeDelta = {x = 300 * js/10, y = 20}
    self.GYImage.sizeDelta = {x = 300 * gy/10, y = 20}

    self.YQText.text = StringHelper.ToCash(yq)
    self.JSText.text = StringHelper.ToCash(js)
    self.GYText.text = StringHelper.ToCash(gy)
    if v > (self.maxtime - 0.001) then
        if self.animTime then
            self.animTime:Stop()
        end
        self.animTime = nil
        self:RunAnimRank()
    end
end
-- 变化的表现
function DDZSharePrefab:RunAnim()
    self.maxtime = 1 -- 1秒
    self.runtime = 0
    self.steptime = 1/30
    self.animTime = Timer.New(function ()
        self.runtime = self.runtime + self.steptime
        self:ChangeUIValue(self.runtime / self.maxtime)
    end, self.steptime, -1)
    self.animTime:Start()
end

function DDZSharePrefab:ChangeUIValueRank(v)
    local rank = self.shareScore.rank * v

    if IsEquals(self.RankText) then
        self.RankText.text = math.floor(rank) .. "%"
    end
    if v > (self.rankmaxtime - 0.001) then
        if self.rankanimTime then
            self.rankanimTime:Stop()
        end
        self.rankanimTime = nil
        self:ChangeUIFinish()
    end
end
-- 变化的排名
function DDZSharePrefab:RunAnimRank()
    self.rankmaxtime = 1 -- 1秒
    self.rankruntime = 0
    self.ranksteptime = 1/30
    self.rankanimTime = Timer.New(function ()
        self.rankruntime = self.rankruntime + self.ranksteptime
        self:ChangeUIValueRank(self.rankruntime / self.rankmaxtime)
    end, self.ranksteptime, -1)
    self.rankanimTime:Start()
end

function DDZSharePrefab:UpdateUI()
	self:EWM(self.EWMImage.mainTexture, ewmTools.getEwmDataWithPixel(self.url, self.size))
end

function DDZSharePrefab:Close()
    if self.animTime then
        self.animTime:Stop()
    end
    self.animTime = nil

    if self.rankanimTime then
        self.rankanimTime:Start()
    end
    self.rankanimTime = nil
	GameObject.Destroy(self.gameObject)
end

function DDZSharePrefab:OnBackClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)

	self:Close()
end
function DDZSharePrefab:OnHYClick()
	self:WeChatShareImage(false)
end
function DDZSharePrefab:OnPYQClick()
	self:WeChatShareImage(true)
end
function DDZSharePrefab:WeChatShareImage(isCircleOfFriends)
    self:ChangeUIFinish()
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
                if self.finishcall then
                    self.finishcall()
                end
                MainModel.SendShareFinish("flaunt")
                if IsEquals(self.HintImage) then
                    self.HintImage.gameObject:SetActive(false)
                end
            end
        end)
    end

	self:ShowBack(false)
    Event.Brocast("ui_share_begin")
    local pos1 = self.node1.position
    local pos2 = self.node2.position
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

function DDZSharePrefab:EWM(texture, data)    
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

function DDZSharePrefab:CalcScore()
    if self.shareScore then
        return
    end

    local settlement = self.parm.settlement
    dump(settlement, "<color=red>CalcScore</color>")
    local boom = settlement.bomb_count
    if not boom then
        boom = 0
    end
    local chuntian = 0
    if settlement.chuntian > 0 then
        chuntian = 1
    end

    local dzpainum = 0
    local nmpainum = 0
    if settlement.remain_pai then
        for k,v in pairs(settlement.remain_pai) do
            --其他玩家的牌
            if v.p == self.parm.dzseatno then
                dzpainum = dzpainum + #v.pai
            else
                nmpainum = nmpainum + #v.pai
            end
        end
    end
    local num = 0
    if self.parm.myseatno == self.parm.dzseatno then
        num = nmpainum * 0.1
    else
        num = dzpainum * 0.2
    end

    self.shareScore = {}
    local data = {}
    -- 运气指数
    data.yq = 8 + 0.2 * boom + 1 * chuntian
    if data.yq > 10 then
        data.yq = 10
    end

    -- 技术指数
    data.js = 7 + num
    if data.js > 10 then
        data.js = 10
    end

    -- 公益指数
    data.gy = 10 - (20 - data.yq - data.js)/2
    -- 领先比例
    data.rank = 100 - 2 * (30 - data.yq - data.js - data.gy)
    self.shareScore = data
end
