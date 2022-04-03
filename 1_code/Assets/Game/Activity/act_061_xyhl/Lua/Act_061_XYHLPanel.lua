-- 创建时间:2021-09-26
-- Panel:Act_061_XYHLPanel
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

Act_061_XYHLPanel = basefunc.class()
local C = Act_061_XYHLPanel
C.name = "Act_061_XYHLPanel"
local M = Act_061_XYHLManager

function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["061_xyhl_maindata_had_got_msg"] = basefunc.handler(self,self.on_061_xyhl_maindata_had_got_msg)
    self.lister["act_061_xyhl_is_overtime_msg"] = basefunc.handler(self,self.on_act_061_xyhl_is_overtime_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    self:DeletRight_pre()
    self:CloseLeftPrefab()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
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
    EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
    M.QueryMainData()
end

function C:MyRefresh()
    self.page_config = basefunc.deepcopy(M.GetPageConfig())
    self:CreateLeftPrefab()
    self:RefreshSelet()
    self:CreateRightPrefab()
end

function C:CreateLeftPrefab()
    self:CloseLeftPrefab()

    if M.GetWasDownLoad() then
        for i=2,#self.page_config do
            local pre = Act_061_XYHLPageItemBase.Create(self.Content.transform,self,i,self.page_config[i])
            self.left_cell[#self.left_cell + 1] = pre
        end
        for i=1,1 do
            local pre = Act_061_XYHLPageItemBase.Create(self.Content.transform,self,i,self.page_config[i])
            self.left_cell[#self.left_cell + 1] = pre
        end
    else
        for i=1,#self.page_config do
            local pre = Act_061_XYHLPageItemBase.Create(self.Content.transform,self,i,self.page_config[i])
            self.left_cell[#self.left_cell + 1] = pre
        end
    end
end

function C:CloseLeftPrefab()
    if self.left_cell then
        for k,v in pairs(self.left_cell) do
            v:MyExit()
        end
    end
    self.left_cell = {}
end

function C:Selet(index)
    if index > #self.page_config then
        index = 1
    end
    self:RefreshSelet(index)
    self:CreateRightPrefab(index)
end

function C:RefreshSelet(index)
    local index = index or (M.GetWasDownLoad() and 2 or 1)
    for k,v in pairs(self.left_cell) do
        v:RefreshSelet(index)
    end
end

function C:CreateRightPrefab(index)
    self:DeletRight_pre()
    local index = index or (M.GetWasDownLoad() and 2 or 1)
    local panelName = self.page_config[index].right
    if _G[panelName] then
        if _G[panelName].Create then 
            self.Right_pre = _G[panelName].Create(self.right_node.transform, index)
        else
            dump("<color=red>该脚本没有实现Create</color>")
        end
    else
        dump(panelName,"<color=red>该脚本没有载入</color>")
    end
end

function C:DeletRight_pre()
    if self.Right_pre then
        self.Right_pre:MyExit()
        self.Right_pre = nil
    end
end

function C:OnBackClick()
    self:MyExit()
end

function C:on_061_xyhl_maindata_had_got_msg()
    self:MyRefresh()
end

function C:on_act_061_xyhl_is_overtime_msg()
    self:MyExit()
end