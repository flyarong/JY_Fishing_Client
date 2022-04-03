-- 创建时间:2020-05-18
-- Panel:SYSBYLevelHallInfoPanel
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

SYSBYLevelHallInfoPanel = basefunc.class()
local C = SYSBYLevelHallInfoPanel
C.name = "SYSBYLevelHallInfoPanel"
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

function C:ctor(parent)
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.transform.localPosition = Vector3.zero
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end
 
function C:InitUI()
    self.slider = self.transform:Find("Slider"):GetComponent("Slider")
    --[[self.level_btn.onClick:AddListener(function()
		self:OnLevelClick()
	end)--]]
	self:MyRefresh()
end

function C:MyRefresh()
	local data = SYSBYLevelManager.GetData()
	--dump({cur = data.cur_rate,max = data.max_rate},"<color=yellow>+++++++++++++++</color>")
	if data.level < #M.config.level_data then
		local d = data.cur_rate / data.max_rate
		self.slider.value = d
		--self.progress_txt.text = math.floor( d*100 ) .. "%"
		self.progress_txt.text= StringHelper.ToCash(data.cur_rate).."/"..StringHelper.ToCash(data.max_rate)
	else
		self.slider.value = 1
		self.progress_txt.text = "MAX"
	end
	self.level_txt.text = "LV." .. data.level
end

function C:OnLevelClick()
	
end
