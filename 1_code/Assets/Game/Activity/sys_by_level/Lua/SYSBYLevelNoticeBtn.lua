-- 创建时间:2020-05-22
-- Panel:SYSBYLevelNoticeBtn
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

SYSBYLevelNoticeBtn = basefunc.class()
local C = SYSBYLevelNoticeBtn
C.name = "SYSBYLevelNoticeBtn"
local M = SYSBYLevelManager
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
	self.lister["level_info_got"] = basefunc.handler(self,self.on_level_info_got)
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
	self.slider = self.transform:Find("Slider"):GetComponent("Slider")

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.click_btn.onClick:AddListener(function ()
		M.ShowNextLevelPanel()
	end)
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:on_level_info_got()
	if not IsEquals(self.gameObject) then return end
	local data = SYSBYLevelManager.GetData()
	if data.level < #M.config.level_data then
		local d = data.cur_rate / data.max_rate
		self.slider.value = d
		--self.progress_txt.text = math.floor( d*100 ) .. "%"
	else
		self.slider.value = 1
		--self.progress_txt.text = "MAX"
		self.gameObject:SetActive(false)
	end
	self.btn_txt.text = (data.level + 1).."级礼包"
end