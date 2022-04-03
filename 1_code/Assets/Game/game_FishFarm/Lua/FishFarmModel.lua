-- 创建时间:2020-07-24

FishFarmModel = {}

FishFarmModel.IsEDITOR = AppDefine.IsEDITOR()
local M = FishFarmModel

local this
local game_lister
local lister
local m_data
local update
local updateDt = 0.1

function M.MakeLister()
    lister = {}
    lister["fishbowl_info_response"] = this.on_fishbowl_info
    lister["fishbowl_feed_response"] = this.on_fishbowl_feed
    lister["fishbowl_sale_response"] = this.on_fishbowl_sale
    lister["fishbowl_upgrade_response"] = this.on_fishbowl_upgrade
    lister["fishbowl_award_response"] = this.on_fishbowl_award
    lister["fishbowl_open_response"] = this.on_fishbowl_open
end
--注册斗地主正常逻辑的消息事件
function M.AddMsgListener()
    for proto_name, _ in pairs(lister) do
        Event.AddListener(proto_name, _)
    end
end

--删除斗地主正常逻辑的消息事件
function M.RemoveMsgListener()
    for proto_name, _ in pairs(lister) do
        Event.RemoveListener(proto_name, _)
    end
end

local function InitData()
    M.data = {}
    m_data = M.data
end
function M.Init()
    this = M
    InitData()
    M.InitUIConfig()
    M.MakeLister()
    M.AddMsgListener()

    return this
end

function M.Exit()
    if this then
        M.RemoveMsgListener()
        this = nil
        game_lister = nil
        lister = nil
        m_data = nil
        M.data = nil
    end
end

function M.InitUIConfig()
    this.UIConfig = {}
end

-- msg
function M.on_fishbowl_info(_, data)
    dump(data, "<color=red>EEE fishbowl_info </color>")
    if data.result == 0 then
        m_data.eggs = data.eggs
        m_data.gain_time = data.gain_time
        m_data.bowl_level = data.bowl_level
        Event.Brocast("model_fishbowl_info_msg")
    else
        HintPanel.ErrorMsg(data.result)
    end
end
function M.on_fishbowl_feed(_, data)
    dump(data, "<color=red>EEE fishbowl_feed </color>")
    if data.result == 0 then
        -- 监听资产改变
        Event.Brocast("model_fishbowl_feed_msg")
    else
        HintPanel.ErrorMsg(data.result)
    end
end
function M.on_fishbowl_sale(_, data)
    dump(data, "<color=red>EEE fishbowl_sale </color>")
    if data.result == 0 then
        m_data.sale_time = data.time
        Event.Brocast("model_fishbowl_sale_msg")
    else
        HintPanel.ErrorMsg(data.result)
    end
end
function M.on_fishbowl_upgrade(_, data)
    dump(data, "<color=red>EEE fishbowl_upgrade </color>")
    if data.result == 0 then
        m_data.bowl_level = m_data.bowl_level + 1
        Event.Brocast("model_fishbowl_upgrade_msg")
    else
        HintPanel.ErrorMsg(data.result)
    end
end
function M.on_fishbowl_award(_, data)
    dump(data, "<color=red>EEE fishbowl_award </color>")
    if data.result == 0 then
        local i
        for k,v in ipairs(m_data.eggs) do
            if v.type == 0 then
                v.type = data.type
                v.time = data.egg_time
                i = k
                break
            end
        end
        m_data.gain_time = data.award_time
        Event.Brocast("model_fishbowl_award_msg", {index = i})
    else
        HintPanel.ErrorMsg(data.result)
    end
end
function M.on_fishbowl_open(_, data)
    dump(data, "<color=red>EEE fishbowl_open </color>")
    if data.result == 0 then
        m_data.eggs[data.index].type = 0
        m_data.eggs[data.index].time = nil
        Event.Brocast("model_fishbowl_open_msg", {index = data.index})
    else
        HintPanel.ErrorMsg(data.result)
    end
end

-- 摄像机 用于坐标转化
function M.SetCamera(camera2d, camera)
    M.camera2d = camera2d
    M.camera = camera
end
-- 2D坐标转UI坐标
function M.Get2DToUIPoint(vec)
    vec = M.camera2d:WorldToScreenPoint(vec)
    vec = M.camera:ScreenToWorldPoint(vec)
    return vec
end
-- UI坐标转2D坐标
function M.GetUITo2DPoint(vec)
    vec = M.camera:WorldToScreenPoint(vec)
    vec = M.camera2d:ScreenToWorldPoint(vec)
    return vec
end


--function


