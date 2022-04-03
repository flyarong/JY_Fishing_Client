-- 创建时间:2020-10-22
-- BY3DPHBManager 管理器

local basefunc = require "Game/Common/basefunc"
BY3DPHBManager = {}
local M = BY3DPHBManager
M.key = "by3d_phb"
GameButtonManager.ExtLoadLua(M.key,"BY3DPHBEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"BY3DPHBGamePanel")
GameButtonManager.ExtLoadLua(M.key,"BY3DPHBLeftPage")
GameButtonManager.ExtLoadLua(M.key,"BY3DPHBRulesLeftPrefab")
GameButtonManager.ExtLoadLua(M.key,"BY3DPHBRulesPanel")
BY3DPHBManager.config = GameButtonManager.ExtLoadLua(M.key,"by3dphb_config")
GameButtonManager.ExtLoadLua(M.key,"BY3DPHBRightItemBase_yjb")
GameButtonManager.ExtLoadLua(M.key,"BY3DPHBRightPanel_yjb")--赢金榜
GameButtonManager.ExtLoadLua(M.key,"BY3DPHBRightItemBase_drb")
GameButtonManager.ExtLoadLua(M.key,"BY3DPHBRightPanel_drb")--达人榜
GameButtonManager.ExtLoadLua(M.key,"BY3DPHBRightItemBase_hgb")
GameButtonManager.ExtLoadLua(M.key,"BY3DPHBRightPanel_hgb")--海怪榜
GameButtonManager.ExtLoadLua(M.key,"BY3DPHBRightItemBase_pms")
GameButtonManager.ExtLoadLua(M.key,"BY3DPHBRightPanel_pms")--排名赛
GameButtonManager.ExtLoadLua(M.key,"BY3DPHBRightItemBase_qys")
GameButtonManager.ExtLoadLua(M.key,"BY3DPHBRightPanel_qys")--千元赛
GameButtonManager.ExtLoadLua(M.key,"BY3DPHBRightItemBase_djs")
GameButtonManager.ExtLoadLua(M.key,"BY3DPHBRightPanel_djs")--大奖赛
GameButtonManager.ExtLoadLua(M.key,"BY3DPHBRightItemBase_shtxb")
GameButtonManager.ExtLoadLua(M.key,"BY3DPHBRightPanel_shtxb")--深海探险榜
GameButtonManager.ExtLoadLua(M.key,"BY3DPHBRightItemBase_sgxxlb")
GameButtonManager.ExtLoadLua(M.key,"BY3DPHBRightPanel_sgxxlb")--水果消消乐爬塔榜
local this
local lister

-- 是否有活动
function M.IsActive(parm)
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key
    if parm then
        -- body
        _permission_key=parm.condi_key
    end
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    else
        return true
    end
end
-- 创建入口按钮时调用
function M.CheckIsShow(parm, type)
    return M.IsActive(parm)
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    dump(parm,"<color=yellow>+++++++++++++phb+++++++++++</color>")
    if parm.goto_scene_parm == "panel" then
        if M.CheckIsShow(parm) then
            return BY3DPHBGamePanel.Create(parm.parent,parm.backcall)
        end 
    elseif parm.goto_scene_parm == "enter" then
        if M.CheckIsShow(parm) then
            return BY3DPHBEnterPrefab.Create(parm.parent, parm.cfg)
        end 
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
end


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
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg

    lister["query_rank_base_info_response"] = this.on_query_rank_base_info_response
    lister["query_rank_data_response"] = this.on_query_rank_data_response
    lister["query_bullet_rank_data_response"] = this.on_query_bullet_rank_data_response
    lister["fsqmg_match_rank_data_response"] = this.on_fsqmg_match_rank_data_response
    lister["fsmg_match_rank_data_response"] = this.on_fsmg_match_rank_data_response
    lister["EnterScene"] = this.OnEnterScene
end

function M.Init()
	M.Exit()

	this = BY3DPHBManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
    this.UIConfig.list = {}
    for i=1,#M.config.info do
        if M.config.info[i].is_on == 1 then--如果打开
            local pass = false
            if ((os.time() >= M.config.info[i].s_t) or (M.config.info[i].s_t == -1)) and ((os.time() <= M.config.info[i].e_t) or (M.config.info[i].e_t == -1)) then
                if M.config.info[i].condition then
                    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=M.config.info[i].condition, is_on_hint = true}, "CheckCondition")
                    if a and b then
                        pass = true
                    end
                else
                    pass = true
                end
            else
                pass = false
            end
            if pass then
                this.UIConfig.list[#this.UIConfig.list + 1] = M.config.info[i]
            end
        end
    end

    local function sort(v1,v2)
        if v1.order > v2.order then
            return true
        end
    end
    MathExtend.SortListCom(this.UIConfig.list, sort)
    this.UIConfig.left = this.UIConfig.list
    this.UIConfig.right = this.UIConfig.list

    this.UIConfig.rightPanelName = {}
    for i=1,#this.UIConfig.list do
        this.UIConfig.rightPanelName[#this.UIConfig.rightPanelName + 1] = this.UIConfig.list[i].panelName
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        for k,v in pairs(this.UIConfig.list) do
            if v.panelName == "BY3DPHBRightPanel_yjb" then
                M.QueryMyData_yjb()--运营要求:排行榜功能针对在榜的前30名玩家进入小游戏大厅或捕鱼大厅弹出排行榜
            elseif v.panelName == "BY3DPHBRightPanel_shtxb" then
                M.QueryMyData_shtxb()--运营要求:排行榜功能针对在榜的玩家进入小游戏大厅或捕鱼大厅弹出排行榜
            end
        end
    end
end
function M.OnReConnecteServerSucceed()
end

function M.GetLeftPagecfg()
    return this.UIConfig.left
end

function M.GetCurRightPanelName(index)
    return this.UIConfig.rightPanelName[index]
end

function M.GetCurRightConfig(index)
    return this.UIConfig.right[index]
end


function M.on_query_rank_base_info_response(_,data)
    dump(data,"<color=yellow>+++on_query_rank_base_info_response+++</color>")
    if data and data.result == 0 then
        if data.rank_type == "leijiyingjin_rank" then
            M.on_query_rank_base_info_response_yjb(data)
        elseif data.rank_type == "ground_1_boss_rank" or data.rank_type == "ground_2_boss_rank" or data.rank_type == "ground_3_boss_rank" or data.rank_type == "ground_4_boss_rank" then
            M.on_query_rank_base_info_response_hgb(data)
        elseif data.rank_type == "ocean_explore_week_rank" then
            M.on_query_rank_base_info_response_shtxb(data)
        elseif data.rank_type == "xiaoxiaole_tower_week_rank" then
            M.on_query_rank_base_info_response_sgxxlb(data)
        elseif data.rank_type == "leijixiaohao_rank" then
            M.on_query_rank_base_info_response_drb(data)
        end
    end
end

function M.on_query_rank_data_response(_,data)
    dump(data,"<color=yellow>+++on_query_rank_data_response+++</color>")
    if data and data.result == 0 then
        if data.rank_type == "leijiyingjin_rank" then
            M.on_query_rank_data_response_yjb(data)
        elseif data.rank_type == "ground_1_boss_rank" or data.rank_type == "ground_2_boss_rank" or data.rank_type == "ground_3_boss_rank" or data.rank_type == "ground_4_boss_rank" then
            M.on_query_rank_data_response_hgb(data)
        elseif data.rank_type == "ocean_explore_week_rank" then
            M.on_query_rank_data_response_shtxb(data)
        elseif data.rank_type == "xiaoxiaole_tower_week_rank" then
            M.on_query_rank_data_response_sgxxlb(data)
        elseif data.rank_type == "leijixiaohao_rank" then
            M.on_query_rank_data_response_drb(data)
        end
    end
end

----------------赢金榜---------------
function M.QueryMyData_yjb()
    if this.m_data.mydata and this.m_data.mydata["leijiyingjin_rank"] and (os.time() - this.m_data.mytime["leijiyingjin_rank"]) < 10  then 
        Event.Brocast("yjb_myrank_data_msg",this.m_data.mydata["leijiyingjin_rank"])
    else
        Network.SendRequest("query_rank_base_info",{rank_type = "leijiyingjin_rank"})
    end
end

function M.on_query_rank_base_info_response_yjb(data)
    dump(data,"<color=yellow>+++达人榜+++</color>")
    this.m_data.mydata = this.m_data.mydata or {}
    this.m_data.mydata[data.rank_type] = data
    dump(this.m_data.mydata[data.rank_type],"+++++")
    Event.Brocast("yjb_myrank_data_msg",this.m_data.mydata[data.rank_type])
    this.m_data.mytime = this.m_data.mytime or {}
    this.m_data.mytime[data.rank_type] = os.time()
end

function M.QueryData_yjb(page_index)
    if this.m_data.data and this.m_data.data["leijiyingjin_rank"] and this.m_data.data["leijiyingjin_rank"][page_index] and (os.time() - this.m_data.time["leijiyingjin_rank"][page_index]) < 10 then
        Event.Brocast("yjb_rank_data_msg",this.m_data.data["leijiyingjin_rank"][page_index])
    else
        Network.SendRequest("query_rank_data",{rank_type = "leijiyingjin_rank",page_index = page_index})
    end
end

function M.on_query_rank_data_response_yjb(data)
    dump(data,"<color=yellow>+++赢金榜+++</color>")
    if data and data.result == 0 then
        this.m_data.data = this.m_data.data or {}
        this.m_data.data[data.rank_type] = this.m_data.data[data.rank_type] or {}
        this.m_data.data[data.rank_type][data.page_index] = data
        Event.Brocast("yjb_rank_data_msg",this.m_data.data[data.rank_type][data.page_index])
        this.m_data.time = this.m_data.time or {}
        this.m_data.time[data.rank_type] = this.m_data.time[data.rank_type] or {}
        this.m_data.time[data.rank_type][data.page_index] = os.time()
    end
end
----------------赢金榜----------------


----------------达人榜---------------
function M.QueryMyData_drb()
    if this.m_data.mydata and this.m_data.mydata["leijixiaohao_rank"] and (os.time() - this.m_data.mytime["leijixiaohao_rank"]) < 10  then 
        Event.Brocast("drb_myrank_data_msg",this.m_data.mydata["leijixiaohao_rank"])
    else
        Network.SendRequest("query_rank_base_info",{rank_type = "leijixiaohao_rank"})
    end
end

function M.on_query_rank_base_info_response_drb(data)
    dump(data,"<color=yellow>+++达人榜+++</color>")
    this.m_data.mydata = this.m_data.mydata or {}
    this.m_data.mydata[data.rank_type] = data
    dump(this.m_data.mydata[data.rank_type],"+++++")
    Event.Brocast("drb_myrank_data_msg",this.m_data.mydata[data.rank_type])
    this.m_data.mytime = this.m_data.mytime or {}
    this.m_data.mytime[data.rank_type] = os.time()
end

function M.QueryData_drb(page_index)
    if this.m_data.data and this.m_data.data["leijixiaohao_rank"] and this.m_data.data["leijixiaohao_rank"][page_index] and (os.time() - this.m_data.time["leijixiaohao_rank"][page_index]) < 10 then
        Event.Brocast("drb_rank_data_msg",this.m_data.data["leijixiaohao_rank"][page_index])
    else
        Network.SendRequest("query_rank_data",{rank_type = "leijixiaohao_rank",page_index = page_index})
    end
end

function M.on_query_rank_data_response_drb(data)
    dump(data,"<color=yellow>+++达人榜+++</color>")
    if data and data.result == 0 then
        this.m_data.data = this.m_data.data or {}
        this.m_data.data[data.rank_type] = this.m_data.data[data.rank_type] or {}
        this.m_data.data[data.rank_type][data.page_index] = data
        Event.Brocast("drb_rank_data_msg",this.m_data.data[data.rank_type][data.page_index])
        this.m_data.time = this.m_data.time or {}
        this.m_data.time[data.rank_type] = this.m_data.time[data.rank_type] or {}
        this.m_data.time[data.rank_type][data.page_index] = os.time()
    end
end
----------------达人榜----------------

------------------海怪榜-------------------
function M.QueryMyData_hgb(game_id)
    local rank_type = "ground_"..game_id.."_boss_rank"
    if this.m_data.mydata and this.m_data.mydata[rank_type] and (os.time() - this.m_data.mytime[rank_type]) < 10  then 

        Event.Brocast("hgb_myrank_data_msg",this.m_data.mydata[rank_type])
    else
        Network.SendRequest("query_rank_base_info",{rank_type = rank_type})
    end
end

function M.on_query_rank_base_info_response_hgb(data)
    dump(data,"<color=yellow>+++海怪榜self+++</color>")
    this.m_data.mydata = this.m_data.mydata or {}
    this.m_data.mydata[data.rank_type] = data
    Event.Brocast("hgb_myrank_data_msg",this.m_data.mydata[data.rank_type])
    this.m_data.mytime = this.m_data.mytime or {}
    this.m_data.mytime[data.rank_type] = os.time()
end

function M.QueryData_hgb(game_id,page_index)
    local rank_type = "ground_"..game_id.."_boss_rank"
    if this.m_data.data and this.m_data.data[rank_type] and this.m_data.data[rank_type][page_index] and (os.time() - this.m_data.time[rank_type][page_index]) < 10 then
        Event.Brocast("hgb_rank_data_msg",this.m_data.data[rank_type][page_index])
    else
        Network.SendRequest("query_rank_data",{rank_type = rank_type,page_index = page_index})
    end
end

function M.on_query_rank_data_response_hgb(data)
    dump(data,"<color=yellow>+++海怪榜+++</color>")
    this.m_data.data = this.m_data.data or {}
    this.m_data.data[data.rank_type] = this.m_data.data[data.rank_type] or {}
    this.m_data.data[data.rank_type][data.page_index] = data
    Event.Brocast("hgb_rank_data_msg",this.m_data.data[data.rank_type][data.page_index])
    this.m_data.time = this.m_data.time or {}
    this.m_data.time[data.rank_type] = this.m_data.time[data.rank_type] or {}
    this.m_data.time[data.rank_type][data.page_index] = os.time()
end
------------------海怪榜-------------------

--------------------排名赛--------------------
function M.QueryData_pms(game_id, page_index)
    if this.m_data.pms_data and this.m_data.pms_data[game_id] and this.m_data.pms_data[game_id].tot_rank_data[page_index] and (os.time() - this.m_data.pms_data[game_id].time < 10) then
        Event.Brocast("pms_rank_data_msg", this.m_data.pms_data[game_id].tot_rank_data[page_index])
        Event.Brocast("pms_myrank_data_msg", this.m_data.pms_data[game_id].my_rank_data)
    else
        Network.SendRequest("query_bullet_rank_data",{id = game_id,page_index = page_index})
    end
end

function M.on_query_bullet_rank_data_response(_,data)
    dump(data,"<color=yellow>+++排名赛和排名赛self+++</color>")
    if data and  data.result == 0 then
        local id = data.id
        local page = data.page_index
        this.m_data.pms_data = this.m_data.pms_data or {}
        this.m_data.pms_data[id] = this.m_data.pms_data[id] or {}

        this.m_data.pms_data[id].time = os.time()
        this.m_data.pms_data[id].my_rank_data = data.my_rank_data
        this.m_data.pms_data[id].tot_rank_data = this.m_data.pms_data[id].tot_rank_data or {}
        if not data.tot_rank_data then
            this.m_data.pms_data[id].tot_rank_data[page] = data.tot_rank_data
        end
        Event.Brocast("pms_rank_data_msg", data.tot_rank_data)
        Event.Brocast("pms_myrank_data_msg", data.my_rank_data)
    end
end
--------------------排名赛--------------------
----------------千元赛---------------------
function M.QueryData_qys(game_id, page_index)
    if this.m_data.qys_data and this.m_data.qys_data[game_id] and this.m_data.qys_data[game_id][page_index] and os.time() - this.m_data.qys_data[game_id][page_index].time < 10 then
        Event.Brocast("qys_rank_data_msg", this.m_data.qys_data[game_id][page_index].rank_list)
        Event.Brocast("qys_myrank_data_msg", this.m_data.qys_data[game_id][page_index].rank_list.my_rank)
    else
        this.m_data.qys_data = this.m_data.qys_data or {}
        this.m_data.qys_data.last_game_id = game_id
        this.m_data.qys_data.last_page_index = page_index
        Network.SendRequest("fsqmg_match_rank_data",{id = game_id,index = page_index})
    end
end

function M.on_fsqmg_match_rank_data_response(_,data)
    dump(data,"<color=yellow>+++千元赛和千元赛self+++</color>")
    if data and data.result == 0 then
        this.m_data.qys_data = this.m_data.qys_data or {}
        this.m_data.qys_data[this.m_data.qys_data.last_game_id] = this.m_data.qys_data[this.m_data.qys_data.last_game_id] or {}
        this.m_data.qys_data[this.m_data.qys_data.last_game_id][this.m_data.qys_data.last_page_index] = this.m_data.qys_data[this.m_data.qys_data.last_game_id][this.m_data.qys_data.last_page_index] or {}
        this.m_data.qys_data[this.m_data.qys_data.last_game_id][this.m_data.qys_data.last_page_index] = data
        this.m_data.qys_data[this.m_data.qys_data.last_game_id][this.m_data.qys_data.last_page_index].time = os.time()
        Event.Brocast("qys_rank_data_msg", data.rank_list)
        Event.Brocast("qys_myrank_data_msg", data.my_rank)
    end
end
----------------千元赛---------------------

----------------大奖赛---------------------
function M.QueryData_djs(game_id, page_index)
    if this.m_data.djs_data and this.m_data.djs_data[game_id] and this.m_data.djs_data[game_id][page_index] and os.time() - this.m_data.djs_data[game_id][page_index].time < 10 then
        Event.Brocast("djs_rank_data_msg", this.m_data.djs_data[game_id][page_index].rank_list)
        Event.Brocast("djs_myrank_data_msg", this.m_data.djs_data[game_id][page_index].rank_list.my_rank)
    else
        this.m_data.djs_data = this.m_data.djs_data or {}
        this.m_data.djs_data.last_game_id = game_id
        this.m_data.djs_data.last_page_index = page_index
        Network.SendRequest("fsmg_match_rank_data",{id = game_id,index = page_index})
    end
end

function M.on_fsmg_match_rank_data_response(_,data)
    dump(data,"<color=yellow>+++大奖赛和大奖赛self+++</color>")
    if data and data.result == 0 then
        this.m_data.djs_data = this.m_data.djs_data or {}
        this.m_data.djs_data[this.m_data.djs_data.last_game_id] = this.m_data.djs_data[this.m_data.djs_data.last_game_id] or {}
        this.m_data.djs_data[this.m_data.djs_data.last_game_id][this.m_data.djs_data.last_page_index] = this.m_data.djs_data[this.m_data.djs_data.last_game_id][this.m_data.djs_data.last_page_index] or {}
        this.m_data.djs_data[this.m_data.djs_data.last_game_id][this.m_data.djs_data.last_page_index] = data
        this.m_data.djs_data[this.m_data.djs_data.last_game_id][this.m_data.djs_data.last_page_index].time = os.time()
        Event.Brocast("djs_rank_data_msg", data.rank_list)
        Event.Brocast("djs_myrank_data_msg", data.my_rank)
    end
end
----------------大奖赛---------------------

----------------深海探险榜---------------
function M.QueryMyData_shtxb()
    if this.m_data.mydata and this.m_data.mydata["ocean_explore_week_rank"] and (os.time() - this.m_data.mytime["ocean_explore_week_rank"]) < 10  then 
        Event.Brocast("shtxb_myrank_data_msg",this.m_data.mydata["ocean_explore_week_rank"])
    else
        Network.SendRequest("query_rank_base_info",{rank_type = "ocean_explore_week_rank"})
    end
end

function M.on_query_rank_base_info_response_shtxb(data)
    dump(data,"<color=yellow>+++深海探险榜self+++</color>")
    this.m_data.mydata = this.m_data.mydata or {}
    this.m_data.mydata[data.rank_type] = data
    dump(this.m_data.mydata[data.rank_type],"+++++")
    Event.Brocast("shtxb_myrank_data_msg",this.m_data.mydata[data.rank_type])
    this.m_data.mytime = this.m_data.mytime or {}
    this.m_data.mytime[data.rank_type] = os.time()
end

function M.QueryData_shtxb(page_index)
    if this.m_data.data and this.m_data.data["ocean_explore_week_rank"] and this.m_data.data["ocean_explore_week_rank"][page_index] and (os.time() - this.m_data.time["ocean_explore_week_rank"][page_index]) < 10 then
        Event.Brocast("shtxb_rank_data_msg",this.m_data.data["ocean_explore_week_rank"][page_index])
    else
        Network.SendRequest("query_rank_data",{rank_type = "ocean_explore_week_rank",page_index = page_index})
    end
end

function M.on_query_rank_data_response_shtxb(data)
    dump(data,"<color=yellow>+++深海探险榜+++</color>")
    if data and data.result == 0 then
        this.m_data.data = this.m_data.data or {}
        this.m_data.data[data.rank_type] = this.m_data.data[data.rank_type] or {}
        this.m_data.data[data.rank_type][data.page_index] = data
        Event.Brocast("shtxb_rank_data_msg",this.m_data.data[data.rank_type][data.page_index])
        this.m_data.time = this.m_data.time or {}
        this.m_data.time[data.rank_type] = this.m_data.time[data.rank_type] or {}
        this.m_data.time[data.rank_type][data.page_index] = os.time()
    end
end
----------------深海探险榜----------------

----------------水果消消乐爬塔榜---------------
function M.QueryMyData_sgxxlb()
    if this.m_data.mydata and this.m_data.mydata["xiaoxiaole_tower_week_rank"] and (os.time() - this.m_data.mytime["xiaoxiaole_tower_week_rank"]) < 10  then 
        Event.Brocast("sgxxlb_myrank_data_msg",this.m_data.mydata["xiaoxiaole_tower_week_rank"])
    else
        Network.SendRequest("query_rank_base_info",{rank_type = "xiaoxiaole_tower_week_rank"})
    end
end

function M.on_query_rank_base_info_response_sgxxlb(data)
    dump(data,"<color=yellow>+++水果消消乐爬塔榜self+++</color>")
    this.m_data.mydata = this.m_data.mydata or {}
    this.m_data.mydata[data.rank_type] = data
    dump(this.m_data.mydata[data.rank_type],"+++++")
    Event.Brocast("sgxxlb_myrank_data_msg",this.m_data.mydata[data.rank_type])
    this.m_data.mytime = this.m_data.mytime or {}
    this.m_data.mytime[data.rank_type] = os.time()
end

function M.QueryData_sgxxlb(page_index)
    if this.m_data.data and this.m_data.data["xiaoxiaole_tower_week_rank"] and this.m_data.data["xiaoxiaole_tower_week_rank"][page_index] and (os.time() - this.m_data.time["xiaoxiaole_tower_week_rank"][page_index]) < 10 then
        Event.Brocast("sgxxlb_rank_data_msg",this.m_data.data["xiaoxiaole_tower_week_rank"][page_index])
    else
        Network.SendRequest("query_rank_data",{rank_type = "xiaoxiaole_tower_week_rank",page_index = page_index})
    end
end

function M.on_query_rank_data_response_sgxxlb(data)
    dump(data,"<color=yellow>+++水果消消乐爬塔榜+++</color>")
    if data and data.result == 0 then
        this.m_data.data = this.m_data.data or {}
        this.m_data.data[data.rank_type] = this.m_data.data[data.rank_type] or {}
        this.m_data.data[data.rank_type][data.page_index] = data
        Event.Brocast("sgxxlb_rank_data_msg",this.m_data.data[data.rank_type][data.page_index])
        this.m_data.time = this.m_data.time or {}
        this.m_data.time[data.rank_type] = this.m_data.time[data.rank_type] or {}
        this.m_data.time[data.rank_type][data.page_index] = os.time()
    end
end
----------------水果消消乐爬塔榜---------------


function M.OnEnterScene()
    if MainModel.cur_myLocation == "game_MiniGame" or MainModel.cur_myLocation == "game_Fishing3DHall" then
        if this.m_data.mydata and this.m_data.mydata["leijiyingjin_rank"] and this.m_data.mydata["leijiyingjin_rank"].rank ~= -1 then
            local pre = BY3DPHBGamePanel.Create()
            local index = 1
            for i=1,#this.UIConfig.list do
                if this.UIConfig.list[i].panelName == "BY3DPHBRightPanel_yjb" then
                    index = i
                    break
                end
            end
            pre:Selet(index)
        elseif this.m_data.mydata and this.m_data.mydata["ocean_explore_week_rank"] and this.m_data.mydata["ocean_explore_week_rank"].rank ~= -1 then
            local pre = BY3DPHBGamePanel.Create()
            local index = 1
            for i=1,#this.UIConfig.list do
                if this.UIConfig.list[i].panelName == "BY3DPHBRightPanel_shtxb" then
                    index = i
                    break
                end
            end
            pre:Selet(index)
        end
    end
end
--@BY3DPHBManager.CheckShowExitAsk("探险榜")
function M.CheckShowExitAsk(type)
    local data1 = true
    local data2 = "海量福利券"
    local data3 = function () end
    if type == "达人榜" then
        data3 = function ()
            local pre = BY3DPHBGamePanel.Create()
            pre:Selet(1)
        end
    elseif type == "探险榜" then
        data3 = function ()
            local pre = BY3DPHBGamePanel.Create()
            pre:Selet(2)
        end
    end
    return data1,data2,data3
end