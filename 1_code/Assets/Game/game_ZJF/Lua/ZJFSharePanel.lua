-- 创建时间:2018-10-18
local basefunc = require "Game.Common.basefunc"

FreeSharePanel = basefunc.class()

function FreeSharePanel.Create(shareType, parm, finishcall)
    return FreeSharePanel.New(shareType, parm, finishcall)
end

function FreeSharePanel:ctor(shareType, parm, finishcall)
    self.parm = parm
    self.shareType = shareType
    self.finishcall = finishcall

    self.parent = GameObject.Find("Canvas/LayerLv4")
    self.gameObject = newObject("FreeSharePanel", self.parent.transform)
    self.transform = self.gameObject.transform
    LuaHelper.GeneratingVar(self.gameObject.transform,  self)

    self.wx_btn.onClick:AddListener(function ()
        self:WeChatShareImage(false)
        self:OnBackClick()
    end)

    self.pyq_btn.onClick:AddListener(function ()
        self:WeChatShareImage(true)
        self:OnBackClick()
    end)
    
    self.close_btn.onClick:AddListener(function ()
        self:OnBackClick()
    end)

    self:InitUI()
    
    DOTweenManager.OpenPopupUIAnim(self.transform)
end

function FreeSharePanel:InitUI()

end

function FreeSharePanel:OnBackClick()
    GameObject.Destroy(self.gameObject)
end

function FreeSharePanel:WeChatShareImage(isCircleOfFriends)
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
                    local shareLink = "{\"type\": 7, \"imgFile\": \"" .. imageName .. "\", \"isCircleOfFriends\": " .. strOff .. "}"
                    ShareLogic.ShareGM(shareLink, function (str)
                        print("<color=red>分享完成....str = " .. str .. "</color>")
                        if str == "OK" then
                            if self.finishcall then
                                self.finishcall()
                            end
                        end
                    end)
                end

                local SI = ShareImage.Create(self.shareType, {msg=self.parm, name=name, url=url})
                local camera = SI:GetCamera()

                SI:MakeImage(imageName, function ()
                sendcall()
                end)
            else
                HintPanel.ErrorMsg(_data.result)
            end
    end )

end
