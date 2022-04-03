-- 创建时间:2021-10-18
-- Panel:Act_063_XRHBItemBase
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

Act_063_XRHBItemBase = basefunc.class()
local C = Act_063_XRHBItemBase
C.name = "Act_063_XRHBItemBase"
local M = Act_063_XRHBManager

function C.Create(parent, config)
	return C.New(parent, config)
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

function C:ctor(parent, config)
	ExtPanel.ExtMsg(self)
    self.config = config
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
    self.slider = self.Slider.transform:GetComponent("Slider")

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
    EventTriggerListener.Get(self.get_btn.gameObject).onClick = basefunc.handler(self, self.OnGetClick)
    EventTriggerListener.Get(self.go_btn.gameObject).onClick = basefunc.handler(self, self.OnGoClick)
	self:MyRefresh()
end

function C:MyRefresh()
    for i=1,#self.config.award_img do
        self["award"..i.."_img"].sprite = GetTexture(self.config.award_img[i])
        self["award"..i.."_txt"].text = self.config.award_txt[i]
    end
    self.task_txt.text = self.config.task_txt
    local data = GameTaskModel.GetTaskDataByID(self.config.task_id)
    if data then
        self.slider.value = data.now_total_process / self.config.need
        self.process_txt.text = math.min(data.now_total_process,self.config.need) .. "/" .. self.config.need
        local b = basefunc.decode_task_award_status(data.award_get_status)
        b = basefunc.decode_all_task_award_status(b, data, M.get_count(self.config.task_id))
        self.get_btn.gameObject:SetActive(b[self.config.level] == 1)
        self.already_img.gameObject:SetActive(b[self.config.level] == 2)
        self.go_btn.gameObject:SetActive(b[self.config.level] == 0)
    end
end

function C:OnGetClick()
    Network.SendRequest("get_task_award_new",{id = self.config.task_id,award_progress_lv = self.config.level})
end

function C:OnGoClick()
    if MainModel.myLocation == "game_Fishing3D" then
        LittleTips.Create("您当前正在捕鱼场内~")
    else
        GameManager.CommonGotoScence({gotoui = self.config.gotoUI})
    end
end