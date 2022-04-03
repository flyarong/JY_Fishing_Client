-- 创建时间:2018-12-20

local basefunc = require "Game.Common.basefunc"

GameMoneyCenterTGEWMPanel = basefunc.class()

local C = GameMoneyCenterTGEWMPanel

C.name = "GameMoneyCenterTGEWMPanel"

function C.Create(parent)
	return C.New(parent)
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

function C:MyClose()
	self:MyExit()
end

function C:MyExit()
    destroy(self.gameObject)
	self:RemoveListener()
end

function C:ctor(parent)

	ExtPanel.ExtMsg(self)

	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()
    LuaHelper.GeneratingVar(self.transform, self)

    self.HYButton_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:WeChatShareImage(false)
    end)
    self.PYQButton_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:WeChatShareImage(true)
    end)

	self.shareType = "moneycenter"
    self:InitUI()
end

function C:InitUI()
    local share_parm = {}
    share_parm.share_type = "tgfx_" .. ShareImage.CreateRandomImgId()
    MainModel.GetShareUrl(function(data)
        self.url = data.share_url
        self:EWM(self.EWM_img.mainTexture,ewmTools.getEwmDataWithPixel(self.url, ShareLogic.size))
    end,share_parm)
    URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.head_img)
end

function C:UpdateUI()

end

function C:MyRefresh()

end

function C:WeChatShareImage(isCircleOfFriends)
    local is_share_link
    if isCircleOfFriends then
        is_share_link = true
    else
        is_share_link = false
    end
    local share_parm = {}
    share_parm.share_type = "tgfx_" .. ShareImage.CreateRandomImgId()
    MainModel.GetShareUrl(function(_data)
            dump(_data, "<color=red>分享数据</color>")
            if _data.result == 0 then
                local strOff
                if isCircleOfFriends then
                    strOff = "true"
                else
                    strOff = "false"
                end

                local userid = MainModel.UserInfo.user_id
                local name = MainModel.UserInfo.name
                local url = _data.share_url

                local imageName = ShareLogic.GetImagePath()

                local sendcall = function ()
                    -- 分享链接
                    local shareLink
                    if is_share_link then
                        shareLink = string.format(share_link_config.share_link[3].link[1] ,url,strOff)
                        -- shareLink = '{"type": 3, ' .. 
                        --                     '"title": "最好玩的斗地主，只要胆子大，满手都是炸！", ' .. 
                        --                     '"description": "如果你连1元都不想充，那就来玩鲸鱼斗地主吧！", ' .. 
                        --                     '"url": "' .. url .. '", ' .. 
                        --                     '"isCircleOfFriends": ' .. strOff .. '}'
                    else
                        shareLink = string.format(share_link_config.share_link[4].link[1] ,imageName,strOff)
                        -- shareLink = "{\"type\": 7, \"imgFile\": \"" .. imageName .. "\", \"isCircleOfFriends\": " .. strOff .. "}"
                    end
                    ShareLogic.ShareGM(shareLink, function (str)
                        print("<color=red>分享完成....str = " .. str .. "</color>")
                        if str == "OK" then
                            if self.finishcall then
                                self.finishcall()
                            end
                            if self.shareType == "hall" then
                                if isCircleOfFriends then
                                    MainModel.SendShareFinish("shared_pyq")
                                else
                                    MainModel.SendShareFinish("shared_hy")
                                end
                            end
                        end
                    end)
                end

                if is_share_link then
                    sendcall()
                else
                    local SI = ShareImage.Create(self.shareType, {msg=self.parm, name=name, url=url})
                    local camera = SI:GetCamera()
                    SI:MakeImage(imageName, function ()
                        sendcall()
                    end)
                end
            else
                HintPanel.ErrorMsg(_data.result)
            end
    end,share_parm)
end

function C:EWM(texture, data)    
    if not texture or not data then
        return
    end
    local w = data.width
    local scale = math.floor(ShareLogic.size/w)
    local py = (ShareLogic.size-w*scale)/2
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


