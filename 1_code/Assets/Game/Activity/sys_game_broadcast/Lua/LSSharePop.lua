-- 创建时间:2019-01-04

local basefunc = require "Game/Common/basefunc"

LSSharePop = basefunc.class()

LSSharePop.name = "LSSharePop"


local instance
function LSSharePop.Create(descTxt, winCount)
	if not instance then
		instance = LSSharePop.New(descTxt, winCount)
	end
	return instance
end

--启动事件--
function LSSharePop:ctor(descTxt, winCount)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	self.gameObject = newObject("LSSharePop", parent)
	LuaHelper.GeneratingVar(self.gameObject.transform, self)

	local isJingBi = string.find(descTxt, "金币") and true or false
	self.coin_img.gameObject:SetActive(isJingBi)
	self.cash_img.gameObject:SetActive(not isJingBi)
    self.desc_txt.text = descTxt
    self.WinCount_txt.text = winCount
    self.EWMImage = self.wc_code_img
    self.node1 = self.gameObject.transform:Find("node1")
    self.node2 = self.gameObject.transform:Find("node2")
    self.camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")

	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnShareBackBtnClicked)
	EventTriggerListener.Get(self.share2Friends_btn.gameObject).onClick = basefunc.handler(self, self.OnShare2FriendsBtnClicked)
	EventTriggerListener.Get(self.share2Circle_btn.gameObject).onClick = basefunc.handler(self, self.OnShare2CircleBtnClicked)

    -- 屏蔽分享朋友圈
    self.share2Circle_btn.gameObject:SetActive(false)
    self.share2Friends_btn.transform.localPosition = Vector3.New(0, -450, 0)

	self:Init()
end

function LSSharePop:Init()
	MainModel.GetShareUrl(function(_data)
        dump(_data, "<color=red>分享的URL</color>")
		self:SetButtonVisible(true)
		self.size = ShareLogic.size
        if _data.result == 0 then
        	self.url = _data.share_url
        	self:UpdateUI()
        else
        	HintPanel.ErrorMsg(_data.result)
        end
    end)
end

function LSSharePop:SetButtonVisible(visible)
	self.back_btn.gameObject:SetActive(visible)
	self.share2Friends_btn.gameObject:SetActive(visible)
	-- self.share2Circle_btn.gameObject:SetActive(visible)
end

function LSSharePop:UpdateUI()
	self:EWM(self.EWMImage.mainTexture, ewmTools.getEwmDataWithPixel(self.url, self.size))
end

function LSSharePop:WeChatShareImage(isCircleOfFriends)
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
            end
        end)
    end

	self:SetButtonVisible(false)
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
        Destroy(canvas)
        print("<color=red>部分截图完成</color>")
        self:SetButtonVisible(true)
        Event.Brocast("ui_share_end")
        sendcall()
    end,false, GameGlobalOnOff.OpenInstall)

end

function LSSharePop:EWM(texture, data)    
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

function LSSharePop:OnShareBackBtnClicked()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:Close()
end

function LSSharePop:OnShare2FriendsBtnClicked()
	self:WeChatShareImage(false)
end

function LSSharePop:OnShare2CircleBtnClicked()
	self:WeChatShareImage(true)
end

function LSSharePop:Close()
	instance = nil
	GameObject.Destroy(self.gameObject)
end
