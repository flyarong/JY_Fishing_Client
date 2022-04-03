-- 创建时间:2021-10-12
-- Panel:Act_062_HGTQPanel
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

Act_062_HGTQPanel = basefunc.class()
local C = Act_062_HGTQPanel
C.name = "Act_062_HGTQPanel"
local M = Act_062_HGHDManager

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
	self:MyRefresh()
end


local tab = {
    [1] = {
        condi_key = "actp_own_task_p_come_back_task1",
        img = "3dby_icon_p3",
        name_img = "hgtq_imgf_jbsz",
    },
    [2] = {
        condi_key = "actp_own_task_p_come_back_task2",
        img = "3dby_icon_p5",
        name_img = "hgtq_imgf_slzg",
    },
    [3] = {
        condi_key = "actp_own_task_p_come_back_task3",
        img = "3dby_icon_p6",
        name_img = "hgtq_imgf_slzl",
    },
}
function C:MyRefresh()
    local vip = VIPManager.get_vip_level()
    for k,v in pairs(tab) do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = v.condi_key, is_on_hint = true}, "CheckCondition")
        if a and b then
            self.pt_img.sprite = GetTexture(v.img)
            self.pt_name_img.sprite = GetTexture(v.name_img)
            break
        end
    end
end
