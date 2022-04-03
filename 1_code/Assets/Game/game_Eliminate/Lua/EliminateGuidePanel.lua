-- 创建时间:2020-01-15
-- Panel:EliminateGuidePanel
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

EliminateGuidePanel = basefunc.class()
local C = EliminateGuidePanel
C.name = "EliminateGuidePanel"  

-- 引导步骤
local GuideStepConfig = {
    --[[[1] = {
        id = 1,
        type="button",
        isHideBG=false, 
        isHideSZ = false,
        szPos={x=38, y=11, z=0},
        desc="点击这里可以降低投入档次",
        descRot={x=0, y=0, z=180},
        descPos={x=10, y=84, z=0},
        headPos={x=0, y=0},
    },--]]
    [1] = {
        id = 1,
        type="button",
        isHideBG=false, 
        isHideSZ = false,
        szPos={x=-26, y=-26, z=0},
        desc="点击这里开始消除",
        descRot={x=0, y=0, z=180},
        descPos={x=0, y=80, z=0},
        headPos={x=0, y=0},
    },
}

function C.Create(panelSelf)
    return C.New(panelSelf)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["sgxxl_guide_check"] = basefunc.handler(self, self.CheckGuide)
    self.lister["EnterBackGround"] = basefunc.handler(self, self.OnEnterBackGround)
    self.lister["com_guide_step"] = basefunc.handler(self,self.SetEliminateAutoButton)
end
function C:OnEnterBackGround()
    self:StopRunTime()
end
function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    if self.com_guide then
        self.com_guide:MyExit()
        self.com_guide = nil
    end
    self:RemoveListener()
end

function C:ctor(panelSelf)  
    self:MakeLister()
    self:AddMsgListener()

    -- 游戏面板
    self.panelSelf = panelSelf
    self:InitUI()
end

function C:InitUI()
    self.com_guide = ComGuideToolPanel.Create()
    self.com_guide:SetSkipButtonActive(false)
    self.step = 1
end
function C:StopRunTime()
    if self.guide_t then
        self.guide_t:Stop()
    end
    self.guide_t = nil
end

function C:CheckGuide()
    --[[if self.step == 1 then
        self.step = 2
        self.com_guide:RunGuide(GuideStepConfig[1], self.panelSelf.money_pre.transform:Find("AddMoney/ReduButton").gameObject)
    elseif self.step == 2 then
        self.step = 3
        self.com_guide:RunGuide(GuideStepConfig[2], self.panelSelf.lottery_btn.gameObject)
    end--]]
    if self.step == 1 then
        self.step = 2
        self.com_guide:RunGuide(GuideStepConfig[1], self.panelSelf.lottery_btn.gameObject)
    end
end


function C:SetEliminateAutoButton(data)
    if data and data.key == "finish" then
        PlayerPrefs.SetInt("guide"..MainModel.UserInfo.user_id.."sgxxl",1)
        Event.Brocast("eliminate_guide_refresh_msg")
    end
end