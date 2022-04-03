-- 创建时间:2020-09-14
-- Panel:Act_Ty_ZP1EnterPrefab
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

Act_Ty_ZP1EnterPrefab = basefunc.class()
local C = Act_Ty_ZP1EnterPrefab
C.name = "Act_Ty_ZP1EnterPrefab"
local M = Act_Ty_ZP1Manager

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
    self.lister["global_hint_state_change_msg"]=basefunc.handler(self,self.MyRefresh)

end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    CommonHuxiAnim.Stop(1,Vector3.New(1, 1, 1))
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
    local cur_path=M.GetActCurPath()
	if cur_path then
		SetTextureExtend(self.enter_btn.image,cur_path.."_icon_img")
	end
    self.enter_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnEnterClick()
    end)
    CommonHuxiAnim.Start(self.gameObject)

	self:MyRefresh()
end

function C:MyRefresh()
    local st = M.GetHintState()
    self.red_img.gameObject:SetActive(false)
    self.get_img.gameObject:SetActive(false)
    if st == ACTIVITY_HINT_STATUS_ENUM.AT_Red then
        self.red_img.gameObject:SetActive(true)
    elseif st == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
        self.get_img.gameObject:SetActive(true)    	
    end
end

function C:OnEnterClick()
	Act_Ty_ZP1Panel.Create()
end