-- 创建时间:2018-07-23

GuideModel = {}

local this
local m_data
local lister
local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end
local function MakeLister()
    lister={}
    lister["task_change_msg"] = this.on_task_change_msg
    lister["get_task_award_response"] = this.on_get_task_award_response
    lister["ExitScene"] = this.on_ExitScene
    lister["AssetChange"] = this.AssetChange
end

-- 初始化Data
local function InitMatchData()
    GuideModel.data={}
    m_data = GuideModel.data
end

function GuideModel.Init()
    if not GameGlobalOnOff.IsOpenGuide then
        return
    end
    this = GuideModel
    InitMatchData()
    MakeLister()
    AddLister()

    m_data.currGuideId = this.GetRunGuideID()
    m_data.currGuideStep = 1
    this.is_guide_ing = false
    return this
end
function GuideModel.Exit()
    if this then
        RemoveLister()
        lister=nil
        this=nil
    end
end

-- 第一个引导的ID
local OneGuideId = 1
function GuideModel.GetRunGuideID()
    if MainModel.UserInfo.xsyd_status == 0 then
        return 1
    else
        m_data.currGuideId = -1
        MainModel.UserInfo.xsyd_status = -1
        Network.SendRequest("set_xsyd_status", {status = -1, xsyd_type="xsyd"})
        return -1
    end
end

function GuideModel.Trigger(id, cfPos)
    if GuideConfig[id] then
        for k,v in ipairs(GuideConfig[id].stepList) do
            if v.cfPos == cfPos then
                GuideModel.trigger_pos = k
                GuideModel.data.currGuideStep = 1
                return true
            end
        end
    end
end
function GuideModel.GetCurStepConfig()
    local cfg = GuideConfig[GuideModel.data.currGuideId]
    if cfg then
        local index = cfg.stepList[GuideModel.trigger_pos].step[GuideModel.data.currGuideStep]
        return GuideNorStepConfig[index]
    end
end

function GuideModel.GetCurStepList()
    local cfg = GuideConfig[GuideModel.data.currGuideId]
    if cfg and cfg.stepList and cfg.stepList[GuideModel.trigger_pos] and cfg.stepList[GuideModel.trigger_pos].step then
        return cfg.stepList[GuideModel.trigger_pos].step
    end
    return {}
end
-- 引导保存点
function GuideModel.GuideSavePos(id)
    dump(m_data, "<color=white><size=20>GuideSavePos</size></color>")
    Network.SendRequest("set_xsyd_status", {status = id, xsyd_type="xsyd"})
end
-- 引导完成或点击跳过
function GuideModel.GuideFinishOrSkip()
    GuideModel.is_guide_ing = false
    m_data.currGuideId = GuideConfig[m_data.currGuideId].next
    if m_data.currGuideId == -1 then
        MainModel.UserInfo.xsyd_status = -1
        Event.Brocast("newplayer_guide_finish")
    end 
    m_data.currGuideStep = 1
    print("<color=white><size=20>is_guide_ing false</size></color>")
    print("<color=white><size=20>is_guide_ing false</size></color>")
end

function GuideModel.StepFinish()
    local cfg = GuideModel.GetCurStepConfig()
    GuideLogic.Print(cfg)
    if cfg and cfg.isSave then
        GuideModel.GuideSavePos(m_data.currGuideId)
    end
    m_data.currGuideStep = m_data.currGuideStep + 1
    local stepList = GuideModel.GetCurStepList()
    if m_data.currGuideId > 0 and GuideConfig[m_data.currGuideId] and m_data.currGuideStep > #stepList then
        GuideModel.GuideFinishOrSkip()
    end
end

-- 条件是否满足
function GuideModel.CheckCondition(id)
    -- 登录到大厅提示在某某游戏中，屏蔽引导
    if MainModel.myLocation == "game_Hall" and MainModel.Location then
        return false
    end
    return true
end
-- 条件是否满足
function GuideModel.IsMeetCondition()
    return GuideModel.CheckCondition(m_data.currGuideId)
end

function GuideModel.GetGuide3Condition()
    
end


function GuideModel.on_task_change_msg(_,data)
    if data and data.task_item.id == 30019 then
        dump(data,"<color=yellow><size=15>++++++++++on_task_change_msg++++++++++</size></color>")
    end
    dump({currGuideId = m_data.currGuideId,is_touch_3guide = m_data.is_touch_3guide}, "||||||||||||||||||||||||||||||||||||||||")
    if data and data.task_item.id == 30019 and data.task_item.task_type == "p_new_player_task" 
        and data.task_item.award_status == 1 and MainModel.myLocation == "game_Fishing3D" 
        and m_data.currGuideId == 3 and not m_data.is_touch_3guide then
            m_data.is_touch_3guide = true
            GuideLogic.CheckRunGuide("by3d")
    end
end


function GuideModel.on_get_task_award_response(_,data)
    --[[dump(data,"<color=yellow><size=15>++++++++++data++++++++++</size></color>")
    if data and data.result == 0 then
        if data.id == 30021 then
            if MainModel.myLocation == "game_Fishing3D" and m_data.currGuideId == 4 and not m_data.is_touch_4guide then
                m_data.is_touch_4guide = true
                GuideLogic.CheckRunGuide("by3d")
            end
        elseif data.id == 30023 then
            if MainModel.myLocation == "game_Fishing3D" and m_data.currGuideId == 5 and not m_data.is_touch_5guide then
                m_data.is_touch_5guide = true
                GuideLogic.CheckRunGuide("by3d")
            end
        end
    end--]]
end


function GuideModel.on_ExitScene()
    if MainModel.myLocation == "game_Fishing3D" then
        m_data.currGuideId = -1
        MainModel.UserInfo.xsyd_status = -1
        Network.SendRequest("set_xsyd_status", {status = -1, xsyd_type="xsyd"})
    end
end

function GuideModel.AssetChange(data)
    --dump(data,"<color=yellow><size=15>++++++++++AssetChange++++++++++</size></color>")
    if data then
        if data.change_type == "task_p_new_player_task_1" 
            and MainModel.myLocation == "game_Fishing3D" 
            and m_data.currGuideId == 4 and not m_data.is_touch_4guide then
                m_data.is_touch_4guide = true
                GuideLogic.CheckRunGuide("by3d")
        elseif data.change_type == "task_p_new_player_task_2" 
            and MainModel.myLocation == "game_Fishing3D" 
            and m_data.currGuideId == 5 and not m_data.is_touch_5guide then
                m_data.is_touch_5guide = true
                GuideLogic.CheckRunGuide("by3d")
        end
    end
end