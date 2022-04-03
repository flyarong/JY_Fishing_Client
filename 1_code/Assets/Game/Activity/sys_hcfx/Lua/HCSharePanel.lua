-- 创建时间:2019-10-31
-- Panel:HCSharePanel
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

HCSharePanel = basefunc.class()
local C = HCSharePanel
C.name = "HCSharePanel"

function C.Create(shareType, parm, finishcall,parm1)
	return C.New(shareType, parm, finishcall,parm1)
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

function C:ctor(shareType, parm, finishcall,parm1)

	ExtPanel.ExtMsg(self)

    self.parm = parm
    self.shareType = shareType
    self.finishcall = finishcall
    self.parm1 = parm1

	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.back_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnBackClick()
	end)
	self.wx_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:WeChatShareImage(false)
		self:OnBackClick()
	end)
	self.pyq_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:WeChatShareImage(true)
		self:OnBackClick()
	end)

	self:MyRefresh()
end

function C:MyRefresh()
end

function C:OnBackClick()
    destroy(self.gameObject)
end
function C:WeChatShareImage(isCircleOfFriends)
    local is_share_link = false

    local share_parm = {}
    share_parm.share_type = "hcshare_1"

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
                    else
                        shareLink = string.format(share_link_config.share_link[4].link[1] ,imageName,strOff )
                    end
                    ShareLogic.ShareGM(shareLink, function (str)
                        print("<color=red>分享完成....str = " .. str .. "</color>")
                        if str == "OK" then
                            if self.finishcall then
                                self.finishcall()
                            end
                        end
                    end)
                end

                if is_share_link then
                    sendcall()
                else
                    local SI = HCShareImage.Create(self.shareType, {msg=self.parm, name=name, url=url})
                    SI:MakeImage(imageName, function ()
                        sendcall()
                    end)
                end
            else
                HintPanel.ErrorMsg(_data.result)
            end
    end, share_parm)
end
