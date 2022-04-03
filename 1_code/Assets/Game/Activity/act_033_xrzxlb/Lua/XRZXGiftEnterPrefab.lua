-- 创建时间:2020-10-11
-- Panel:XRZXGiftEnterPrefab
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

XRZXGiftEnterPrefab = basefunc.class()
local C = XRZXGiftEnterPrefab
C.name = "XRZXGiftEnterPrefab"

function C.Create(parm)
	return C.New(parm)
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

function C:ctor(parm)
	local parent =  parm.parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	self.enter_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		PlayerPrefs.SetString(XRZXGiftManager.key .. MainModel.UserInfo.user_id, os.date("%Y%m%d",os.time()))
		XRZXGiftPanel.Create()
		self:MyRefresh()
	end)
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	--local st = XRZXGiftManager.GetHintState({gotoui = XRZXGiftManager.key})

		--self.LFL.gameObject:SetActive(false)
		if PlayerPrefs.GetString(XRZXGiftManager.key .. MainModel.UserInfo.user_id,0) == os.date("%Y%m%d",os.time()) then 
			self.red_img.gameObject:SetActive(false)
		else
			self.red_img.gameObject:SetActive(true)
		end 
	--[[
	
	dump(st,"<color=red>+++++++++++++</color>")
    self.red_img.gameObject:SetActive(false)
    --self.get_img.gameObject:SetActive(false)
    if st == ACTIVITY_HINT_STATUS_ENUM.AT_Red then
        self.red_img.gameObject:SetActive(true)
    end--]]
end
