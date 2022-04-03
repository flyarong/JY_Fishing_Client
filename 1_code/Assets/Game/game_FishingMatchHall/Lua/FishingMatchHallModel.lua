-- 创建时间:2020-04-23

FishingMatchHallModel = {}
local M = FishingMatchHallModel

local this
local lister
local m_data

local function MakeLister()
    lister = {}
end

function M.AddMsgListener()
    for proto_name, call in pairs(lister) do
        Event.AddListener(proto_name, call)
    end
end

function M.RemoveMsgListener()
    for proto_name, call in pairs(lister) do
        Event.RemoveListener(proto_name, call)
    end
end

function M.Init()
    this = M
    MakeLister()
    this.AddMsgListener()
    return this
end

function M.Exit()
    if this then
        M.RemoveMsgListener()
        this = nil
        lister = nil
    end
end
