-- 创建时间:2020-08-21
-- Panel:BY3DPHBRulesLeftPrefab
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

BY3DPHBRulesLeftPrefab = basefunc.class()
local C = BY3DPHBRulesLeftPrefab
C.name = "BY3DPHBRulesLeftPrefab"

function C.Create(parent,config,index,panelSelf)
	return C.New(parent,config,index,panelSelf)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
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

function C:ctor(parent,config,index,panelSelf)
	self.config = config
	self.index = index
	self.panelSelf = panelSelf
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
	self.title1_txt.text = self.config.LeftName
	self.title2_txt.text = self.config.LeftName
	
	if self.config.RightPrefab=="by3dphb_rules_drb_pre1" then
		-- body
		if not self:CheckIsCjjPlatform() then
			-- body
			self.title1_txt.text = "排名奖励"
			self.title2_txt.text = "排名奖励"
		end
	end
	self.SelectButton_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self.panelSelf:Selet(self.index)
	end)
	self:MyRefresh()
end

function C:CheckIsCjjPlatform()
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="cpl_cjj", is_on_hint = true}, "CheckCondition")
	if a and  b then
		return true
	end
end
function C:MyRefresh()
end

function C:RefreshSelet(index)
	self.HiImage.gameObject:SetActive(index == self.index)
end