-- 创建时间:2021-09-15
-- Panel:ACTZZPWJCPanel
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

ACTZZPWJCPanel = basefunc.class()
local C = ACTZZPWJCPanel
C.name = "ACTZZPWJCPanel"
local M = ACTZZPWManager

function C.Create(awardData)
	return C.New(awardData)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["getjc"] = basefunc.handler(self,self.on_getjc)

    self.lister["EnterForeGround"] = basefunc.handler(self, self.on_backgroundReturn_msg)
    self.lister["EnterBackGround"] = basefunc.handler(self, self.on_background_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()

    if self.seq then
        self.seq = nil
    end
    if self.awardData then
        Event.Brocast("AssetGet", self.awardData)
    end
    self:StopTimer()
    self:DeletItemPre()
	self:RemoveListener()
    Event.Brocast("view_zzpy_jc_panel_close")
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(awardData)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
    self.awardData = awardData
    self.isLottery = false
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
    self.dicData = M.GetDicData()

    self.get_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnGetClick()
        self.get_btn.enabled = false
    end)
    self.back_btn.onClick:AddListener(function()
        self:MyExit()
    end)
    self.count = 0
	self:MyRefresh()
end

function C:MyRefresh()
    self.jc_txt.text = M.GetCurJC() + self.dicData.take_pool
    self:CreateItemPre()
end

function C:OnGetClick()
    -- M.GetJCAward()
    local idnex = 1
    local config = M.GetJCConfigByGroup()
    for i = 1, #config.proportion do
        if config.proportion[i] == tonumber(self.dicData.take_pool_percent) then
            idnex = i
        end
    end
    self:on_getjc(idnex)
end

function C:CreateItemPre()
    self:DeletItemPre()
    local config = M.GetJCConfigByGroup()
    for j=1,3 do
        for i=1,#config.proportion do
            local pre = ACTZZPWJCItemBase.Create(self.Content_2.transform,i,config.proportion[i])
            self.pre_cell[#self.pre_cell + 1] = pre
        end
    end

end

function C:DeletItemPre()
    if self.pre_cell then
        for k,v in pairs(self.pre_cell) do
            v:MyExit()
        end
    end
    self.pre_cell = {}
end

function C:on_getjc(data)
    dump(data,"<color=yellow><size=15>++++++++++data++++++++++</size></color>")
    self.isLottery = true
    self.index = data
    self:Scroll()
end

function C:Scroll()
    self:MoveTimer()
    self:StopTween()
    local high = 100
    local orign_index = 2
    local _count = 20
    local config = M.GetJCConfigByGroup()
    local y = (self.index - orign_index) * high + #config.proportion * _count * high
    self.seq = DoTweenSequence.Create()
    self.seq:Append(self.Content_2.transform:DOLocalMoveY(y,_count/4):SetEase(DG.Tweening.Ease.InOutExpo))
    self.seq:AppendInterval(1)
    self.seq:OnForceKill(function ()
        dump("<color=yellow><size=15>+++++++成功++++++++</size></color>")
        if self.awardData then
            Event.Brocast("AssetGet", self.awardData)
            self.awardData = nil
        end
        self:MyExit()
    end)
end

function C:MoveTimer()
    self:StopTimer()
    self.count = 0
    self.move_timer = Timer.New(function ()
        self.c1 = self.c1 or 500
        self.c2 = self.c2 or -400
        self._count = self._count or 0
        if self.Content_2.transform.localPosition.y >= self.c1 and self.count == self._count then
            self._count = self._count + 1
            self.Content_1.transform.localPosition = Vector3.New(self.Content_1.transform.localPosition.x,self.c2,0)
            self.c1 = self.c1 + 400
            self.c2 = self.c2 - 400
            self.count = self.count + 1
        end
    end,0.02,-1)
    self.move_timer:Start()
end

function C:StopTimer()
    if self.move_timer then
        self.move_timer:Stop()
        self.move_timer = nil
    end
end

function C:StopTween()
    if self.seq then
        self.seq:Kill()
        self.seq = nil
    end
end

function C:on_backgroundReturn_msg()
    self:MyExit()
end

function C:on_background_msg()

end