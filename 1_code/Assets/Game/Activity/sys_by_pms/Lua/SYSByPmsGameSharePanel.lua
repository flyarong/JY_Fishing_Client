-- 创建时间:2020-05-11
-- Panel:SYSByPmsGameSharePanel
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

SYSByPmsGameSharePanel = basefunc.class()
local C = SYSByPmsGameSharePanel
C.name = "SYSByPmsGameSharePanel"
local M = SYSByPmsManager
function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
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

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.BackButton = tran:Find("BackButton"):GetComponent("Button")
	self.HYButton = tran:Find("HYButton"):GetComponent("Button")
    self.PYQButton = tran:Find("PYQButton"):GetComponent("Button")
	self.BackButton.onClick:AddListener(function ()
        self:OnBackClick()
    end)
	self.HYButton.onClick:AddListener(function ()
        self:OnHYClick()
    end)
	self.PYQButton.onClick:AddListener(function ()
        self:OnPYQClick()
    end)

    self.HintImage = tran:Find("HintImage")
    self.HintImage.gameObject:SetActive(false)
    self.NameText = tran:Find("Image/NameText"):GetComponent("Text")
	self.HeadImage = tran:Find("Image/HeadImage"):GetComponent("Image")
    self.HeadFrame = tran:Find("Image/HeadFrame"):GetComponent("Image")
    self.head_vip_txt = tran:Find("Image/@head_vip_txt"):GetComponent("Text")
	self.EWMImage = tran:Find("Image/EWMImage"):GetComponent("Image")
    self.LogoImage = tran:Find("Image/EWMImage/LogoImage"):GetComponent("Image")
	self.node1 = tran:Find("Image/node1")
    self.node2 = tran:Find("Image/node2")
    self.camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")
    self.ExitTimeText = tran:Find("Image/ExitTimeText"):GetComponent("Text")
    self.RankText = tran:Find("Image/Text1/RankText"):GetComponent("Text")

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end
function C:ShowBack(b)
    if IsEquals(self.HYButton) then
	self.HYButton.gameObject:SetActive(b)
    end
    if IsEquals(self.BackButton) then
	self.BackButton.gameObject:SetActive(b)
    end
end

function C:InitUI()
	local bsdata = M.GetCurBSData()
	self.Game_name_txt.text = bsdata.game_name
	self.Score_txt.text = "比赛得分: "..M.GetCurScore()
	self.Rank_txt.text = "比赛排名: "..M.GetCurRank()
    self.award_config = SYSByPmsManager.GetPMSAwardByID(SYSByPmsManager.GetSignupData())--获取奖励config
    for i=1,#self.award_config do
        dump(self.award_config[i],"<color=red><size=20>+++++++++++++++++++++</size></color>")
        if SYSByPmsManager.GetCurScore() >= tonumber(self.award_config[i].min_score) then
            self.award.gameObject:SetActive(true)
            self.award_img.sprite = GetTexture(self.award_config[i].award_icon[1])
            self.award_txt.text = self.award_config[i].award_desc[1]
            return
        end
    end
	self.NameText.text = MainModel.UserInfo.name
	URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.HeadImage)
	URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.LogoImage)
	-- PersonalInfoManager.SetHeadFarme(self.HeadFrame)
    VIPManager.set_vip_text(self.head_vip_txt)
	self.ExitTimeText.text = os.date("%Y.%m.%d %H:%M", os.time())
    MainModel.GetFlauntStatus(function (data)
	    if IsEquals(self.HintImage) then
	    if data >= 1 then
	        self.HintImage.gameObject:SetActive(true)
	    else
	        self.HintImage.gameObject:SetActive(false)
	        end                
	    end            
	end)

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
    end,{share_type = "sysbypms"})
	self:MyRefresh()
end

function C:MyRefresh()
end


function C:UpdateUI()
	self:EWM(self.EWMImage.mainTexture, ewmTools.getEwmDataWithPixel(self.url, self.size))
end

function C:Close()
	GameObject.Destroy(self.gameObject)
end

function C:OnBackClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)

	self:Close()
end
function C:OnHYClick()
	self:WeChatShareImage(false)
end
function C:OnPYQClick()
	self:WeChatShareImage(true)
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