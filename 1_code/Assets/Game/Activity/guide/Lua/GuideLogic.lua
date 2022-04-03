-- 创建时间:2018-07-23
GuideLogic = {}
local this -- 单例
local guideModel

local lister
local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg,cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister=nil
end
local function MakeLister()
    lister = {}
    lister["EnterScene"] = this.OnEnterScene
    lister["ExitScene"] = this.OnExitScene
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["will_kick_reason"] = this.on_will_kick_reason
    lister["DisconnectServerConnect"] = this.on_network_error_msg
end

function GuideLogic.Init()
    if not GameGlobalOnOff.IsOpenGuide or GLC.IsCloseGuide then
        return
    end
    GuideLogic.Exit()
    this = GuideLogic
    MakeLister()
    AddLister()
    return this
end
function GuideLogic.Exit()
	if this then
		guideModel.Exit()
        GuidePanel.Exit()
        this.cur_guide_cfg = nil
		guideModel = nil
		RemoveLister()
		this = nil
	end
end

function GuideLogic.on_network_error_msg(proto_name, data)
    GuidePanel.Exit()
end

--断线重连后登录成功
function GuideLogic.OnReConnecteServerSucceed(result)
    coroutine.start(function ( )
        Yield(0)
        dump(guideModel, "<color=green>断线重连后登录成功</color>")
        -- if guideModel then
        --     guideModel.Exit()
        -- end
        -- guideModel = GuideModel.Init()
        -- GuideLogic.RunGuide()
        if this.cur_guide_cfg then
            GuidePanel.Show(this.cur_guide_cfg)
        end
    end)
end

function GuideLogic.on_will_kick_reason(proto_name, data)
    if data.reason == "relogin" then
        -- 挤号关闭引导界面
        GuidePanel.Exit()
    end
end

--正常登录成功
function GuideLogic.OnLoginResponse(result)
    if result ~= 0 then return end
    coroutine.start(function ( )
        Yield(0)
        print("<color=red>GuideLogic:正常登录成功</color>")
        if result==0 then
            if guideModel then
                guideModel.Exit()
            end
            guideModel = GuideModel.Init()
        else
        end    
    end)
end

-- 进入场景
function GuideLogic.OnEnterScene()
end
-- 退出场景
function GuideLogic.OnExitScene()
end

function GuideLogic.CheckRunGuide(uiname, call)
    GuideLogic.cur_guide_cfg = nil

    GuideLogic.uiname = uiname
    local b = false
    if GuideModel.data and GameGlobalOnOff.IsOpenGuide and GuideModel.data.currGuideId and GuideModel.data.currGuideId > 0 then
        if GuideModel.is_guide_ing then
            GuideLogic.RunGuide()
            b = true
        else
            if GuideModel.IsMeetCondition() and GuideModel.Trigger(GuideModel.data.currGuideId, uiname) then
                GuideLogic.RunGuide()
                b = true
            end
        end
    else
        dump(uiname, "<color=red>新手引导 uiname</color>")
    end
    if not b and call then
        call()
    end
end

-- 执行引导(判断是否有引导，引导的步骤) isAuto-一个引导的连续执行
function GuideLogic.RunGuide(isAuto)
    local b = false
	if GameGlobalOnOff.IsOpenGuide then
        GuideLogic.Print(GuideModel.data)
        if GuideModel.data.currGuideId > 0
            and (GuideModel.data.currGuideStep ~= 1 or GuideModel.IsMeetCondition() )then
            local vv = GuideModel.GetCurStepConfig()
            GuideLogic.Print(vv)
            if vv and not isAuto or (isAuto and vv and vv.auto) then
                GuideModel.is_guide_ing = true
                b = true
                dump(GuideModel.data, "<color=red>新手引导 GuideModel</color>")
                dump(vv, "<color=red>新手引导 cfg</color>")
                this.cur_guide_cfg = vv
                GuidePanel.Show(vv)
            end
        end
    else
        print("<color=red>新手引导开关 = 关闭</color>")
	end
    if not b and not isAuto then
        print("<color=white><size=20>is_guide_ing false</size></color>")
        print("<color=white><size=20>is_guide_ing false</size></color>")

        GuideModel.is_guide_ing = false
    end
end
function GuideLogic.StepFinish()
    GuideModel.StepFinish()
    GuideLogic.RunGuide(true)
end

function GuideLogic.GuideSkip()
    GuideModel.GuideFinishOrSkip()
    GuideLogic.RunGuide(true)
end

-- 是否是比赛场的特定引导
function GuideLogic.IsMatchNewButton()
    -- 弃用
    return false
end
-- 是否是匹配场的特定引导
function GuideLogic.IsFreeBattle()
    -- 弃用
    return false
end

-- 是否有新手引导
function GuideLogic.IsHaveGuide(uiname)
    return GuideModel.is_guide_ing
end

function GuideLogic.Print(data)
     --print(debug.traceback())
     --print("<color=white><size=20>EEE Guide</size></color>")
     --dump(data)
end