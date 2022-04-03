-- 创建时间:2019-09-25
-- Panel:VIPEnterPrefab
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

VIPEnterPrefab = basefunc.class()
local C = VIPEnterPrefab
C.name = "VIPEnterPrefab"
local M = VIPManager
function C.Create(parent, cfg)
	return C.New(parent, cfg)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
    self.lister["model_vip_upgrade_change_msg"] = basefunc.handler(self,self.on_model_vip_upgrade_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	RedHintManager.RemoveRed(RedHintManager.RedHintKey.RHK_VIP2, self.vip2_red.gameObject)
	
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent, cfg)
	self.config = cfg

	local obj = newObject("vip2_btn", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	self.transform.localPosition = Vector3.zero

	self:InitUI()
end

function C:InitUI()
	self.enter_btn = self.transform:GetComponent("Button")
	self.enter_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)
	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_VIP2, self.vip2_red.gameObject)

	self:MyRefresh()
	self:Refresh()
end

function C:MyRefresh()
	
end

function C:OnEnterClick()
	if self:CheckAward_LFL() then
		PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
	end
	self:Refresh()
	VipShowTaskPanel2.Create()
end

function C:OnDestroy()
	self:MyExit()
end


function C:CheckAward_LFL()
	local data = GameTaskModel.GetTaskDataByID(VIPManager.GetFHFLTaskID())
	if data then -- 有为空的情况 todo
		local b = basefunc.decode_task_award_status(data.award_get_status)
		b = basefunc.decode_all_task_award_status(b, data, #M.GetFHFLData())
		--dump(b,"<color=yellow>+++++++++++//WWWWWWWWWW///++++++++++++</color>")
		for i=1,#b do
			if b[i] and b[i] == 1 then
				return true
			end
		end
	end
end

function C:Refresh()
	dump(M.get_vip_level())
	if self:CheckAward_LFL() then
		self.lfl.gameObject:SetActive(true)
	else
		self.lfl.gameObject:SetActive(false)
	end
	local newtime = tonumber(os.date("%Y%m%d", os.time()))
    local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
	if self:CheckAward_LFL() and (oldtime ~= newtime) then
		if IsEquals(self.red) then
			self.red.gameObject:SetActive(true)
		end
	else
		if IsEquals(self.red) then
			self.red.gameObject:SetActive(false)
		end
	end
end

function C:on_model_task_change_msg(data)
	if data and data.id and data.id == VIPManager.GetFHFLTaskID() then
		--dump(data,"<color=yellow>+++++++++++//222///++++++++++++</color>")
		self:Refresh()
	end
end

function C:on_model_vip_upgrade_change_msg()
	self:Refresh()
end