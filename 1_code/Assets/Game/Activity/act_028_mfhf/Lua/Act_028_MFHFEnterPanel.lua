-- 创建时间:2020-08-25
-- Panel:Act_028_MFHFEnterPanel
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

Act_028_MFHFEnterPanel = basefunc.class()
local C = Act_028_MFHFEnterPanel
C.name = "Act_028_MFHFEnterPanel"
local M = Act_028_MFHFManager
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
    self.lister["fishing_ready_finish"] = basefunc.handler(self,self.on_fishing_ready_finish)
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["global_hint_state_change_msg"] = basefunc.handler(self,self.on_global_hint_state_change_msg)

    self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
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
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
    self.is_one = true
    self.enter_btn.transform:GetComponent("Image").sprite = GetTexture(M.config.enter_img)
	self:InitUI()
end

function C:InitUI()
	self.enter_btn.onClick:AddListener(function()
		Act_028_MFHFPanel.Create()
	end)
	self:MyRefresh()
end

function C:MyRefresh()
    if M.GetHintState({gotoui = M.key}) == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
        self.lfl.gameObject:SetActive(true)
    else
        self.lfl.gameObject:SetActive(false)
    end
end

function C:on_fishing_ready_finish()
    local check_can_create = function()
        return M.IsActive() and ((GameItemModel.GetItemCount("prop_mfcjq") >= 1) or (M.GetShopStatus() and M.GetShopStatus() == 1))
    end
    if MainModel.myLocation == "game_Fishing3D" and self.is_one then
        self.is_one = false
        if check_can_create() then 
            Act_028_MFHFPanel.Create()
        end 
    end
end

function C:on_global_hint_state_change_msg(parm)
    if parm.gotoui == Act_028_MFHFManager.key then 
        self:MyRefresh()
    end 
end

function C:OnAssetChange()
    self:MyRefresh()
end