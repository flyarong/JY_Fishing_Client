-- 创建时间:2020-11-17
-- Panel:CJJMFCJ_JYFLEnterPrefab
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

CJJMFCJ_JYFLEnterPrefab = basefunc.class()
local C = CJJMFCJ_JYFLEnterPrefab
C.name = "CJJMFCJ_JYFLEnterPrefab"
local M = BY3DADMFCJManager

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
    self.lister["by3d_ad_mfcj_fsg_3d_query_free_lottery"] = basefunc.handler(self, self.MyRefresh)
    self.lister["by3d_ad_mfcj_fsg_3d_use_free_lottery"] = basefunc.handler(self, self.MyRefresh)    
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

function C:ctor(parent, cfg)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	self.get_btn.onClick:AddListener(function ()
   		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    	self:OnGetClick()
	end)
end

function C:InitUI()
	M.QueryInfoData()
	self:MyRefresh()
end

function C:MyRefresh()
	self.count =  M.GetNum()
	if self.count then
		self.time_txt.text = "还可领"..self.count.."次"
		self.HBSlider.gameObject:GetComponent("Slider").value = (5- self.count)/5
		self.rate_txt.text = tostring(5- self.count).."/5"
	end
end

function C:OnGetClick()
	BY3DADMFCJPanel.Create()
end