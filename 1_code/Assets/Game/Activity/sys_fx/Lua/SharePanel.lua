
local basefunc = require "Game.Common.basefunc"

ShareType = {
    URL = 3,
    TEXT = 4,
    IMAGE = 7,
}

SharePanel = basefunc.class()
function SharePanel.Create(parm, finishcall)
    return SharePanel.New(parm, finishcall)
end

function SharePanel:ctor(parm, finishcall)
    self.parm = parm or {}
    self.finishcall = finishcall

	ExtPanel.ExtMsg(self)

    self.parent = GameObject.Find("Canvas/LayerLv5")
    self.gameObject = newObject("SharePanel", self.parent.transform)
    self.transform = self.gameObject.transform
    LuaHelper.GeneratingVar(self.gameObject.transform,  self)

    self.wx_btn.onClick:AddListener(function ()
        self:Share(false)
    end)

    self.pyq_btn.onClick:AddListener(function ()
        self:Share(true)
    end)
    
    self.close_btn.onClick:AddListener(function ()
        self:OnBackClick()
    end)

    self:InitUI()

    DOTweenManager.OpenPopupUIAnim(self.transform)
end

function SharePanel:InitUI()
    if not self.parm.fx_type then
        self.share_info_txt.text = "分享到微信群，就可以领取奖励哦！"
    else

    end
end

function SharePanel:MyExit()
    destroy(self.gameObject)
end

function SharePanel:OnBackClick()
    self:MyExit()
end

function SharePanel:Share(isCircleOfFriends)
    if self.parm.fx_type then
        if self.parm.fx_type == ShareType.URL then
            self:ShareUrl(isCircleOfFriends)
        elseif self.parm.fx_type == ShareType.IMAGE then
            self:WeChatShareImage(isCircleOfFriends)
        end
    else
        self:WeChatShareImage(isCircleOfFriends)
    end
end

function SharePanel:ShareUrl(toFCircle)
    local shareLink = string.format(SYSFXManager.GetShareLink(self.parm), toFCircle and "true" or "false")
    ShareLogic.ShareGM(
        shareLink,
        function(str)
            log("<color=red>分享完成....str = " .. str .. ", data:" .. shareLink .. "</color>")
            if str == "OK" then
                self:ShareFinish()
            end
        end
    )
end

function SharePanel:ShareFinish()
    if self.finishcall then
        self.finishcall()
    end
    self:MyExit()
end

function SharePanel:WeChatShareImage(isCircleOfFriends, is_share_link)
    -- 分享的埋点数据
    local curBgCoNfig = {"bossqsb_bg_2","hlqkdhb_bg_2","mrbxl_bg_1"}
    local index = math.random(1,#curBgCoNfig)
    GameButtonManager.RunFunExt("sys_fx", "TYShareImage", nil, {fx_type="hall", share_bg = curBgCoNfig[index]}, function (str)
    end)
    --[[local share_parm = {share_type = "tgr"}

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
                local url = MainModel.UserInfo.shareURL.share_url

                local imageName = ShareLogic.GetImagePath()

                local sendcall = function ()
                    -- 分享链接
                    local shareLink
                    if is_share_link then
                        shareLink = string.format(share_link_config.share_link[3].link[1], url, strOff)
                    else
                        shareLink = string.format(share_link_config.share_link[4].link[1], imageName, strOff )
                    end
                    ShareLogic.ShareGM(shareLink, function (str)
                        print("<color=red>分享完成....str = " .. str .. "</color>")
                        if str == "OK" then
                            self:ShareFinish()
                        end
                    end)
                end

                if is_share_link then
                    sendcall()
                else
                    local SI = TYShareImage.Create({msg=self.parm, url=url})
                    SI:RunMake(imageName, function ()
                        sendcall()
                    end)
                end
            else
                HintPanel.ErrorMsg(_data.result)
                self:MyExit()
            end
    end, share_parm)--]]
end
