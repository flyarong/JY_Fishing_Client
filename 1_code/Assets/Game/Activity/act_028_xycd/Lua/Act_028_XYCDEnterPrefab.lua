-- 创建时间:2020-05-18
-- Panel:Act_028_XYCDEnterPrefab
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

Act_028_XYCDEnterPrefab = basefunc.class()
local C = Act_028_XYCDEnterPrefab
C.name = "Act_028_XYCDEnterPrefab"
local M = Act_028_XYCDManager
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
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
	self.lister["global_hint_state_change_msg"] = basefunc.handler(self,self.on_global_hint_state_change_msg)
	self.lister["Panel_back_2_refreshEnterPre_xycd"] = basefunc.handler(self,self.on_panel_back_refresh_EnterPre)

	self.lister["xycdManager_CreateSunItemInGame"]=basefunc.handler(self,self.CreateSunItemInGame)

	self.lister["XYCD_on_backgroundReturn_msg"] = basefunc.handler(self,self.XYCD_on_backgroundReturn_msg)

	self.lister["fishing_ready_finish"] = basefunc.handler(self,self.on_fishing_ready_finish)
	self.lister["EnterScene"] = basefunc.handler(self,self.OnEnterScene)
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

function C:ctor(parent)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
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
	EventTriggerListener.Get(self.enter_btn.gameObject).onClick = basefunc.handler(self, self.OnEnterClick)
	self:MyRefresh()
end

function C:MyRefresh()
	if Act_028_XYCDManager.GetHintState({gotoui = Act_028_XYCDManager.key}) == ACTIVITY_HINT_STATUS_ENUM.AT_Get then 
		self.LFL.gameObject:SetActive(true)
	else
		self.LFL.gameObject:SetActive(false)
		if PlayerPrefs.GetString(Act_028_XYCDManager.key .. MainModel.UserInfo.user_id,0) == os.date("%Y%m%d",os.time()) then 
			self.Red.gameObject:SetActive(false)
		else
			self.Red.gameObject:SetActive(true)
		end 
	end
end


function C:OnEnterClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	PlayerPrefs.SetString(Act_028_XYCDManager.key .. MainModel.UserInfo.user_id, os.date("%Y%m%d",os.time()))
	Act_028_XYCDPanel.Create()
	self:MyRefresh()
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == Act_028_XYCDManager.key then 
		self:MyRefresh()
	end 
end


function C:on_panel_back_refresh_EnterPre()
	self:MyRefresh()
end


function C:CreateSunItemInGame(score)
	dump(score,"<color>============================</color>")
	local pre = Act_028_XYCDIconInGame.Create(score,self.transform)
	if self.spawn_cell_list == nil then
		self.spawn_cell_list = {}
	end
	self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
end

function C:CloseItemPrefab()
	if self.spawn_cell_list then
		for k,v in ipairs(self.spawn_cell_list) do
			v:MyExit()
		end
	end
	self.spawn_cell_list = {}
end

function C:XYCD_on_backgroundReturn_msg()
	self:CloseItemPrefab()
end

function C:on_fishing_ready_finish()
    local check_can_create = function()
        return M.IsActive() and M.IsHaveRemainTime()
    end
    if MainModel.myLocation == "game_Fishing3D" or MainModel.myLocation == "game_Fishing" then
        if check_can_create() then 
            Act_028_XYCDPanel.Create()
        end 
    end
end


local mini_game_map = {"game_Eliminate","game_EliminateCS","game_EliminateSH","game_TTL","game_ZPG","game_Zjd","game_FishingDR"}

function C:OnEnterScene()
	local check_can_create = function()
        return M.IsActive() and M.IsHaveRemainTime()
    end
	for i=1,#mini_game_map do
		if MainModel.myLocation == mini_game_map[i] then
			if check_can_create() then 
	            Act_028_XYCDPanel.Create()
	        end 
		end
	end
end