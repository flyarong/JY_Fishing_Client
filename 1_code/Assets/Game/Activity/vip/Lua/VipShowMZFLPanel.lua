-- 创建时间:2019-12-28
-- Panel:VipShowMZFLPanel
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

VipShowMZFLPanel = basefunc.class()
local C = VipShowMZFLPanel
C.name = "VipShowMZFLPanel"

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
	self.lister["model_vip_task_change_msg"] = basefunc.handler(self, self.RefreshTask)
    self.lister["model_vip_upgrade_change_msg"] = basefunc.handler(self, self.RefreshTask)
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

	ExtPanel.ExtMsg(self)

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
    self.help_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        VIPMZFLHelpPanel.Create(self.transform)
    end)

    self.config = VIPManager.GetVIPMzflConfig()
    dump(self.config,"<color=yellow>+++++++++vipmzfl+++++++++++++</color>")
    self:MyRefresh()
end

function C:MyRefresh()
    self.cell_map = {}
    self:SpecialHandling()
    for k,v in ipairs(self.config) do
        local pre = VIPMZFLChildPrefab.Create(self.content, k)
        self.cell_map[v.task_id] = {pre = pre, index = k}
    end
    self:RefreshTask()
    self:RefreshVIP()
end

function C:RefreshVIP()
    local vip_data = VIPManager.get_vip_data()
    if vip_data then
        self.cur_vip_txt.text = "VIP"..vip_data.vip_level
    end
end

function C:RefreshTask()
    self.task_sort_list = VIPManager.GetMZFLTaskDataAndSort()
    for k,v in ipairs(self.task_sort_list) do
        if self.cell_map[v] then
            self.cell_map[v].pre:UpdateData(k)
        end
    end
end


--新游豪礼的特殊处理
function C:SpecialHandling()
    if Act_061_XYHLManager and Act_061_XYHLManager.CheckIsShow() then
        local pre = VIPMZFLChildPrefab.Create(self.content, nil, "xyhl")
    end
end