-- 创建时间:2018-09-04
local basefunc = require "Game.Common.basefunc"


CityMatchSharePanel = basefunc.class()

function CityMatchSharePanel.Create(shareType, parm, finishcall)
    return CityMatchSharePanel.New(shareType, parm, finishcall)
end

function CityMatchSharePanel:ctor(shareType, parm, finishcall)

	ExtPanel.ExtMsg(self)

    self.parm = parm
	self.shareType = shareType
    self.finishcall = finishcall
	local parent = GameObject.Find("Canvas/LayerLv4")
    self.gameObject = newObject("CityMatchSharePanel", parent.transform)
    self.transform = self.gameObject.transform
    local tran = self.transform
    
    self.UIRoot = tran:Find("UIRoot")
    self.ShareRoot = tran:Find("ShareRoot")
    self.BackButton = tran:Find("UIRoot/BackButton"):GetComponent("Button")
    self.BackButton.onClick:AddListener(function ()
        self:OnBackClick()
    end)
    self.PYQButton = tran:Find("UIRoot/ImgPopupPanel/PYQButton"):GetComponent("Button")
	self.PYQButton.onClick:AddListener(function ()
        self:OnPYQClick()
    end)
    self.EWMImage = tran:Find("ShareRoot/EWMImage"):GetComponent("Image")

    self.node1 = tran:Find("ShareRoot/node1")
    self.node2 = tran:Find("ShareRoot/node2")
    self.camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")

    self.DescText = tran:Find("UIRoot/ImgPopupPanel/DescText"):GetComponent("Text")
    
    self:InitUI()
end
function CityMatchSharePanel:ShowShare(b)
	self.UIRoot.gameObject:SetActive(not b)
	self.ShareRoot.gameObject:SetActive(b)
end
function CityMatchSharePanel:InitUI()
	self:ShowShare(false)

    if self.parm == "share" then
        self.DescText.text = "您当前没有海选赛门票\n分享朋友圈可立即获得门票！\n(分享无次数限制)"
    else
		self.DescText.text = "很遗憾您在海选赛中被淘汰了\n分享朋友圈可立即获得门票再次参赛！\n(分享无次数限制)"
	end

	self.size = ShareLogic.size
    MainModel.GetShareUrl(function(_data)
        dump(_data, "<color=red>分享的URL</color>")
        if _data.result == 0 then
            self.url = _data.share_url
            self:UpdateUI()
        else
            HintPanel.ErrorMsg(_data.result)
        end
    end)
end
function CityMatchSharePanel:UpdateUI()
	self:EWM(self.EWMImage.mainTexture, ewmTools.getEwmDataWithPixel(self.url, self.size))
end

function CityMatchSharePanel:MyExit()
    destroy(self.gameObject)
end

function CityMatchSharePanel:Close()
	self:MyExit()
end

function CityMatchSharePanel:OnBackClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:Close()
end
function CityMatchSharePanel:OnPYQClick()
	self:WeChatShareImage(true)
end
function CityMatchSharePanel:WeChatShareImage(isCircleOfFriends)
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
                Network.SendRequest("shared_finish", {type="city"})
            end
        end)
    end

	self:ShowShare(true)
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
        self:ShowShare(false)
        Event.Brocast("ui_share_end")
        sendcall()
    end,false, GameGlobalOnOff.OpenInstall)
end

function CityMatchSharePanel:EWM(texture, data)    
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

