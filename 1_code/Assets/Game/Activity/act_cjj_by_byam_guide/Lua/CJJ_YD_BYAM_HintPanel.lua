-- 创建时间:2021-04-16
-- Panel:CJJ_YD_BYAM_HintPanel
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

CJJ_YD_BYAM_HintPanel = basefunc.class()
local C = CJJ_YD_BYAM_HintPanel
C.name = "CJJ_YD_BYAM_HintPanel"

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

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
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
	self.back_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:MyExit()
    end)
	self.copy_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnCopyClick()
    end)
	self.down_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnDownClick()
    end)

	self:MyRefresh()
end

function C:MyRefresh()
	self.gzh = "鲸鱼初纪元"
	self.ios_url = "itms-services://?action=download-manifest&url=https://cdndownload.game3396.com/install/ios/qiye/byam/byam_byam_aibianxian.plist"

	self.hint1_info_txt.text = "亲爱的玩家您好，\
冲金鸡将升级为全新版本，需要重新下载游戏进行体验，\
下载新版本后可联系客服公众号<color=#f26d32>" .. self.gzh .. "</color>\
<size=46>免费领取<color=#f26d32>20万金币礼包！</color></size>"
	self.hint2_info_txt.text = "领取条件：\
需提供您在冲金鸡的游戏ID<color=#f26d32>（请记录您的ID：" .. MainModel.UserInfo.user_id .. "）</color>\
在冲金鸡中有过充值的玩家，可将剩余的金币和福利券转入新的游戏版本中！"
end

function C:OnCopyClick()
	UniClipboard.SetText(self.gzh)
	LittleTips.Create("已复制微信号请前往微信进行添加")
end
function C:OnDownClick()
	UnityEngine.Application.OpenURL(self.ios_url)
end