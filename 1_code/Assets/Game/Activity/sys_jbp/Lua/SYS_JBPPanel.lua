-- 创建时间:2021-01-04
-- Panel:SYS_JBPPanel
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

SYS_JBPPanel = basefunc.class()
local C = SYS_JBPPanel
C.name = "SYS_JBPPanel"
local M = SYS_JBPManager

function C.Create()
	if C.instance then
		C.instance:MyRefresh()
		return
	end
	C.instance = C.New()
	return C.instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["jbp_data_has_come_msg"] = basefunc.handler(self,self.on_jbp_data_has_come_msg)
    self.lister["jbp_award_had_got_msg"] = basefunc.handler(self,self.on_jbp_award_had_got_msg)
    self.lister["jbp_award_had_change_msg"] = basefunc.handler(self,self.on_jbp_award_had_change_msg)
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
	C.instance = nil
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv3").transform
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
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.On_BackClick)
	EventTriggerListener.Get(self.unlock_btn.gameObject).onClick = basefunc.handler(self, self.On_UnLockClick)
	M.QueryJBPData()
	CommonHuxiAnim.Start(self.unlock_btn.gameObject,nil,1,1.1)
end

function C:MyRefresh()
	self.cur_jing_bi_txt.text = M.GetCurJBPJing_bi()
end

function C:On_BackClick()
	self:MyExit()
end

function C:On_UnLockClick()
	if VIPManager.get_vip_level() > 0 then
		if M.GetCurJBPJing_bi() > 0 then
			M.GetJBPAward()
		else
			LittleTips.Create("无金币可领")
		end
	else
		SYSACTBASEManager.CreateHallAct(nil,nil,{ID = 9})
	end
end


function C:on_jbp_data_has_come_msg()
	self:MyRefresh()
end

function C:on_jbp_award_had_got_msg()
	self.unlock_btn.gameObject:SetActive(false)
	self:MyRefresh()
end

function C:on_jbp_award_had_change_msg()
	self:MyRefresh()
end