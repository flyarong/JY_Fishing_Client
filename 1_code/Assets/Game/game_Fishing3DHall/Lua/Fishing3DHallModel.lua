-- 创建时间:2019-03-18

Fishing3DHallModel = {}

local this
local lister
local m_data

--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister = {}
end
--注册斗地主正常逻辑的消息事件
function Fishing3DHallModel.AddMsgListener()
    for proto_name, call in pairs(lister) do
        Event.AddListener(proto_name, call)
    end
end

--删除斗地主正常逻辑的消息事件
function Fishing3DHallModel.RemoveMsgListener()
    for proto_name, call in pairs(lister) do
        Event.RemoveListener(proto_name, call)
    end
end

function Fishing3DHallModel.Init()
    this = Fishing3DHallModel
    MakeLister()
    this.AddMsgListener()
    Fishing3DHallModel.InitConfig()
    return this
end

function Fishing3DHallModel.Exit()
    if this then
        Fishing3DHallModel.RemoveMsgListener()
        this = nil
        lister = nil
    end
end

function Fishing3DHallModel.InitConfig()
    this.UIConfig = {}

    -- 地图相关配置
    this.UIConfig.map = {width=3800, height=888}
    -- 入口配置
    local tt
    this.UIConfig.hall_list = {}
    tt = {}
    tt.prefab = "by3d_hall_prefab1"
    tt.pos = {x=360, y=-64, z=0}
    tt.zs_pos_x = 0
    tt.game_id = 2
    tt.icon_img = {"3dby_icon_yu4","3dby_icon_yu52","3dby_icon_yu14"}
    this.UIConfig.hall_list[#this.UIConfig.hall_list + 1] = tt

    tt = {}
    tt.prefab = "by3d_hall_prefab2"
    tt.pos = {x=1056, y=148, z=0}
    tt.zs_pos_x = -600
    tt.game_id = 3
    tt.icon_img = {"3dby_icon_yu12","3dby_icon_yu56","3dby_icon_yu54"}
    this.UIConfig.hall_list[#this.UIConfig.hall_list + 1] = tt

    tt = {}
    tt.prefab = "by3d_hall_prefab3"
    tt.pos = {x=1724, y=-64, z=0}
    tt.zs_pos_x = -1296
    tt.game_id = 4
    tt.icon_img = {"3dby_icon_yu37","3dby_icon_yu55","3dby_icon_yu15"}
    this.UIConfig.hall_list[#this.UIConfig.hall_list + 1] = tt

    tt = {}
    tt.prefab = "by3d_hall_prefab4"
    tt.pos = {x=2480, y=148, z=0}
    tt.zs_pos_x = -1296
    tt.game_id = 5
    tt.icon_img = {"3dby_icon_yu42","3dby_icon_yu18","3dby_icon_yu49"}
    this.UIConfig.hall_list[#this.UIConfig.hall_list + 1] = tt

    tt = {}
    tt.prefab = "by3d_hall_prefab5"
    tt.pos = {x=490, y=340, z=0}
    tt.zs_pos_x = -1296
    tt.game_id = 1--体验场入口
    --tt.icon_img = {"3dby_icon_yu42","3dby_icon_yu18","3dby_icon_yu49"}
    this.UIConfig.hall_list[#this.UIConfig.hall_list + 1] = tt

    -- 装饰配置
    this.UIConfig.zs_list = {}

    --[[tt = {}
    tt.prefab = "by3d_hall_zs_prefab1"
    tt.pos = {x=490, y=284, z=0}
    this.UIConfig.zs_list[#this.UIConfig.zs_list + 1] = tt--]]

    tt = {}
    tt.prefab = "by3d_hall_zs_prefab2"
    tt.pos = {x=1248, y=-282, z=0}
    this.UIConfig.zs_list[#this.UIConfig.zs_list + 1] = tt

    tt = {}
    tt.prefab = "by3d_hall_zs_prefab2"
    tt.pos = {x=1608, y=326, z=0}
    this.UIConfig.zs_list[#this.UIConfig.zs_list + 1] = tt

    tt = {}
    tt.prefab = "by3d_hall_zs_prefab2"
    tt.pos = {x=2695, y=-242, z=0}
    this.UIConfig.zs_list[#this.UIConfig.zs_list + 1] = tt
end

function Fishing3DHallModel.GetHallList()
    return this.UIConfig.hall_list
end
function Fishing3DHallModel.GetHallZSList()
    return this.UIConfig.zs_list
end
function Fishing3DHallModel.GetConfigByGameID(id)
    for k,v in ipairs(this.UIConfig.hall_list) do
        if v.game_id == id then
            return v
        end
    end
end
