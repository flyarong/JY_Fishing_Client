-- 创建时间:2018-11-06
local vip_cfg = {}
VIPManager = {}
local M = VIPManager
M.key = "vip"
local vip_showinfo_cfg = GameButtonManager.ExtLoadLua(M.key, "vip2_config")
GameButtonManager.ExtLoadLua(M.key, "VipShowTaskPanel")
GameButtonManager.ExtLoadLua(M.key, "VIPEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "VipShowInfoPanel")
GameButtonManager.ExtLoadLua(M.key, "VIPPayPrefab")
GameButtonManager.ExtLoadLua(M.key, "VIPShowWealPanel")
GameButtonManager.ExtLoadLua(M.key, "VIPHintPanel")
GameButtonManager.ExtLoadLua(M.key, "VIPUPPanel")

--测试 VipShowTaskPanel2
GameButtonManager.ExtLoadLua(M.key, "VipShowTaskPanel2")
GameButtonManager.ExtLoadLua(M.key, "VipShowYJTZPanel")
GameButtonManager.ExtLoadLua(M.key, "VipShowLBPanel")
GameButtonManager.ExtLoadLua(M.key, "VipShowTQPanel")
GameButtonManager.ExtLoadLua(M.key, "VipShowMZFLPanel")
GameButtonManager.ExtLoadLua(M.key, "VipShowMXBPanel")
GameButtonManager.ExtLoadLua(M.key, "VipShowQYSPanel")

VIPManager.is_on_off = true

local vip_up_cfg = GameButtonManager.ExtLoadLua(M.key, "vip_up_config")

local permission_hb_limit = GameButtonManager.ExtLoadLua(M.key, "permission_hb_limit")

--VIP任务类型
VIP_TASK_TYPE = {
    day = 1,
    level = 2,
    gold = 3,
    match = 4,
    week = 5,
}

VIP_CONFIG_TYPE = {
    dangci = "dangci",
    task = "task",
    level = "level",
}

M.CanGetStatus = {
    vip2 = false,
}

function M.CheckIsShow(parm, type)
    return true
end

function M.GotoUI(parm)
    if VIPManager.is_on_off then
        -- todo nmg:3D捕鱼屏蔽VIP入口
        if parm.goto_scene_parm == "hint" then
            return VIPHintPanel.Create(parm.data)
        else
            dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
        end
        return
    end

    if parm.goto_scene_parm == "vip_task" then
        return VipShowTaskPanel2.Create(nil,{gotoui = "viptq"})
    elseif parm.goto_scene_parm == "vip_task_match" then
        local is_have = GameMatchModel.IsTodayHaveMatchByType("mxb")
        local vip_level = VIPManager.get_vip_level()
        parm.goto_scene_parm1 = "mxb"
        if is_have and vip_level > 3 then
            return VipShowTaskPanel2.Create(nil,{gotoui = "vipmxb"})
        end
    elseif parm.goto_scene_parm == "info" then
        return VipShowInfoPanel.Create()
    elseif parm.goto_scene_parm == "VIP2" then
        local v = M.get_vip_level()
        if v > 0 then
            return VipShowInfoPanel.Create()
        else
            return VIPShowWealPanel.Create()
        end
    elseif parm.goto_scene_parm == "enter" then
        return VIPEnterPrefab.Create(parm.parent, parm.cfg)
    elseif parm.goto_scene_parm == "hint" then
        return VIPHintPanel.Create(parm.data)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

local this
local m_data
local lister
local function MakeLister()
    lister = {}
    lister["HallModelInitFinsh"] = this.HallModelInitFinsh
    lister["PayPanelCreate"] = this.PayPanelCreate
    lister["PayPanelClosed"] = this.PayPanelClosed

    lister["query_vip_base_info_response"] = this.query_vip_base_info_response
    lister["vip_upgrade_change_msg"] = this.on_vip_upgrade_change_msg

    lister["model_query_task_data_response"] = this.on_task_req_data_response
    lister["model_get_task_award_response"] = this.on_get_task_award_response
    lister["model_task_change_msg"] = this.on_task_change_msg
    lister["model_query_one_task_data_response"] = this.model_query_one_task_data_response

    lister["on_player_hb_limit_convert"] = this.on_player_hb_limit_convert
    
    --比赛场报名VIP限制
	lister["GameMatchHallMatchItemCreate"] = this.GameMatchHallMatchItemCreate
end

local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end
local function RemoveLister()
    if lister == nil then return end
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end
local function InitData()
	M.data={}
	m_data = M.data
end
function M.Init()
    M.Exit()
    print("<color=red>VIP初始化>>>>>>>>>>>>>>>>>>>>>>>>>>>></color>")
    this=M
    vip_cfg = this.InitCfg(vip_showinfo_cfg)
    this.Config = {}
    this.Config.hb_limit_map = permission_hb_limit.main
    for k,v in pairs(this.Config.hb_limit_map) do
        if not this.Config.min_hb_limit or this.Config.min_hb_limit > v.hb_limit then
            this.Config.min_hb_limit = v.hb_limit
        end
        if not this.Config.max_hb_limit or this.Config.max_hb_limit < v.hb_limit then
            this.Config.max_hb_limit = v.hb_limit
        end
    end
    InitData()
    MakeLister()
    AddLister()
    return this
end

function M.Exit()
    if this then
        RemoveLister()
        m_data=nil
        this=nil
    end
end

function M.InitCfg(cfg)
    local m_cfg = {}
    m_cfg.dangci = {}
    for i,v in ipairs(cfg.dangci) do
        if not m_cfg.dangci[v.vip] then
            m_cfg.dangci[v.vip] = {}
        end
        m_cfg.dangci[v.vip].xycj = v.xycj
        m_cfg.dangci[v.vip].total = v.total
        if not m_cfg.dangci[v.vip].info then
            m_cfg.dangci[v.vip].info = {}
        end
        m_cfg.dangci[v.vip].info[#m_cfg.dangci[v.vip].info + 1] = {desc = v.info, gotoUI = v.gotoUI}
    end
    m_cfg.task = {}
    for i,v in ipairs(cfg.task) do
        m_cfg.task[v.id] = v
    end
    m_cfg.level = {}
    for i,v in ipairs(cfg.level) do
        m_cfg.level[v.level] = v
    end
    m_cfg.lb = {}
    for i,v in ipairs(cfg.lb) do
        m_cfg.lb[v.index] = v
    end
    m_cfg.yjtz = {}
    for i,v in ipairs(cfg.yjtz) do
        m_cfg.yjtz[v.index] = v
    end
    m_cfg.qys = {}
    for i,v in ipairs(cfg.qys) do
        m_cfg.qys[v.index] = v
    end
    m_cfg.vipmzfl = {}
    for i,v in ipairs(cfg.vipmzfl) do
        m_cfg.vipmzfl[v.index] = v
    end
    return m_cfg
end

function M.GetVIPCfgByType(type)
    if type then
        return vip_cfg[type]
    end
    return vip_cfg
end

function M.GetVIPCfg()
    return vip_cfg
end

function M.HallModelInitFinsh()
    print("<color=yellow>请求VIP数据</color>")
    Network.SendRequest("query_vip_base_info", nil,"请求VIP数据")
    M.set_vip_task()
    M.ChangeTaskCanGetRedHint()
    dump(m_data.vip_task, "<color=yellow>VIP任务数据</color>")
end

function M.PayPanelCreate(tf)
    if not VIPManager.is_on_off then
        VIPPayPrefab.Create(tf)
    end
end

function M.PayPanelClosed(tf)
    if not VIPManager.is_on_off then
        VIPPayPrefab.Close()
    end
end

function M.query_vip_base_info_response(_,data)
    dump(data, "<color=white>query_vip_base_info_response</color>")
    if data.result == 0 then
        m_data.vip_data = data
        Event.Brocast("model_query_vip_base_info_response")
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function M.on_vip_upgrade_change_msg(_,data)
    dump(data, "<color=white>on_vip_upgrade_change_msg</color>")
    local up_data = {prev = MainModel.UserInfo.vip_level,cur = data.vip_level}
    if data.vip_level - MainModel.UserInfo.vip_level > 0 then
        VIPUPPanel.Create(up_data)
    end
    m_data.vip_data = data
    MainModel.UserInfo.vip_level = data.vip_level
    Event.Brocast("model_vip_upgrade_change_msg",m_data.vip_data)

    Event.Brocast("trace_honor_msg", {honor_id = 10001, vip_level = data.vip_level})

    if data.vip_level >= 1 then
        M.GameMatchHallMatchItemDestroy()
    end
end

--重新初始化VIP任务数据
function M.on_task_req_data_response()
    M.set_vip_task()
    M.ChangeTaskCanGetRedHint()
end

function M.on_get_task_award_response(data)
    if not M.check_is_vip_task(data.id) then return end
    --这里 GameTaskModel 会处理
end

function M.on_task_change_msg(data)
    if not M.check_is_vip_task(data.id) then return end
    m_data.vip_task = m_data.vip_task or {}
    m_data.vip_task[data.id] = data
    M.ChangeTaskCanGetRedHint()
    Event.Brocast("model_vip_task_change_msg",data)
end

function M.model_query_one_task_data_response(data)
    if not M.check_is_vip_task(data.id) then return end
    m_data.vip_task = m_data.vip_task or {}
    m_data.vip_task[data.id] = data
    M.ChangeTaskCanGetRedHint()
    Event.Brocast("model_vip_upgrade_change_msg",data)
end

function M.get_vip_level()
    local vl = MainModel.UserInfo.vip_level or 0
    return vl
end

function M.get_vip_data()
    return m_data.vip_data
end

function M.check_is_vip_task(task_id)
    if vip_cfg and vip_cfg.task then
        return vip_cfg.task[task_id]
    end
end

function M.set_vip_task()
    m_data.vip_task = {}
    local t = {}
    for k,v in pairs(vip_cfg.task) do
        t = GameTaskModel.GetTaskDataByID(k)
        m_data.vip_task[k] = t
    end
end

function M.get_vip_task(id)
    if table_is_null(m_data.vip_task) then
        M.set_vip_task()
    end
    if id then
        return m_data.vip_task[id]
    end
    return m_data.vip_task
end

function M.get_vip_task_by_type(type)
    if type then
        local t = {}
        for k,v in pairs(vip_cfg.task) do
            if v.type == type then
                table.insert(t, M.get_vip_task(k))
            end
        end
        return t
    end
    return m_data.vip_task
end
function M.get_change_viptxt(vip_level)
    local ascii = string.byte("A") - 1 + vip_level
    return string.char(ascii)
end
function M.set_vip_text(txt,vip_level)
    if not IsEquals(txt) then
        return
    end
    if not VIPManager.is_on_off then
        if txt.font.name == "vip_font_ty_hz" then
            if vip_level then
                txt.text = M.get_change_viptxt(vip_level)
            else
                txt.text = M.get_change_viptxt(M.get_vip_level())
            end
        else
            if vip_level then
                txt.text = "VIP" .. vip_level
            else
                txt.text = "VIP" .. M.get_vip_level()
            end
        end
	    txt.gameObject:SetActive(true)
    else
    	txt.gameObject:SetActive(false)
    end
end


function M.set_vip_text_new(txt,vip_level)
    if not IsEquals(txt) then
        return
    end
    if not VIPManager.is_on_off then
        local vl = 0
	    if vip_level then
		    vl = vip_level
	    else
		    vl = M.get_vip_level()
        end
        local ascii = string.byte("A") - 1 + vl
        txt.text = string.char(ascii)
	    txt.gameObject:SetActive(true)
    else
        txt.text = ""
    	txt.gameObject:SetActive(false)
    end
end

function M.set_vip_image(img)
    local cfg = M.GetVIPCfgByType(VIP_CONFIG_TYPE.level)[ M.get_vip_level()]
    img.sprite = GetTexture(cfg.head_img)
end

function M.ChangeTaskCanGetRedHint()
    if not VIPManager.is_on_off then
        M.CheckTaskCanGet()
        Event.Brocast("UpdateHallVIP2RedHint")
    end
end

--检测是否有可领取的任务
function M.CheckTaskCanGet()
    M.CanGetStatus.vip2 = false
    if false and m_data.vip_task then-- todo 临时屏蔽
        for k,v in pairs(m_data.vip_task) do
            if M.CanGetStatus.vip2 == false and v.id~=110  then
                if v.id == 21016 or v.id == 21017 then 
                    if os.date("%w", os.time()) == "0"  then
                        M.CanGetStatus.vip2 = v.award_status == 1
                    end  
                else    
                    M.CanGetStatus.vip2 = v.award_status == 1
                end 
            end
            if M.CanGetStatus.vip2 then
                return M.CanGetStatus.vip2
            end
        end
    end
    return M.CanGetStatus.vip2
end

function M.GameMatchHallMatchItemCreate(obj)
    M.match_item = M.match_item or {}
    local cfg = obj.config
    if cfg.game_type == GameMatchModel.GameType.game_DdzMatch or 
        cfg.game_type == GameMatchModel.GameType.game_MjXzMatch3D then
        --红包赛特殊设置
        if cfg.game_id == 4 or cfg.game_id == 7 or cfg.game_id == 11 or cfg.game_id == 12 then
            local config = GameMatchModel.GetGameIDToConfig(cfg.game_id)
            local itemkey, item_count = GameMatchModel.GetMatchCanUseTool(config.enter_condi_itemkey, config.enter_condi_item_count)
            --金币报名玩家
            if not itemkey or itemkey == "jing_bi" then
                local l = M.get_vip_level()
                if not l or l < 1 then
                    local item = newObject("VIPGameMatchHallMatchItem",obj.UINode.transform)
                    local tf = {}
                    LuaHelper.GeneratingVar(item.transform,tf)
                    tf.signup_btn.onClick:AddListener(function()
                        HintPanel.Create(1,"<color=#F47E14FF>vip1</color>及以上玩家可参赛，您的vip等级不足，请提高vip等级！",function(  )
                            PayPanel.Create(GOODS_TYPE.jing_bi)
                            DSM.PushAct({info = {vip = "vip_up"}})
                        end)
                    end)
                    tf.vip_txt.text = "1"
                    M.match_item[cfg.game_id]  = item
                end
            end
        end
    end
end

function M.GameMatchHallMatchItemDestroy()
    if not table_is_null(M.match_item) then
        for k,v in pairs(M.match_item) do
            if IsEquals(v) then
                destroy(v)
            end
            M.match_item[k] = nil
        end
    end
end

function M.GetHBLimit()
    local k = "player_vip_" .. M.get_vip_level()
    if this.Config.hb_limit_map[k] then
        return this.Config.hb_limit_map[k].hb_limit
    else
        print("<color=red>hb limit no find</color>")
        return this.Config.min_hb_limit or 0
    end
end

-- 检查红包是否超出上限，可能超出就给提示
function M.CheckHBLimit(parm)
    local hb = parm.hb or 0 -- 本次操作可能获得的红包数
    local call = parm.call
    local hb_limit = M.GetHBLimit()
    if (hb + MainModel.UserInfo.shop_gold_sum) > hb_limit then
        local desc = "您当前不可兑换，如兑换后那么福利券将超出上限！\n成为VIP后可增加携带福利券的上限！"
        VIPHintPanel.Create({desc=desc, type=2})
    else
        if call then
            call()
        end
    end
    return true
end

function M.on_player_hb_limit_convert(_, data)
    local hb_limit = M.GetHBLimit()
    local desc = string.format("您当前携带的福利券已达到上限:%s，超出的%s福利券将转换成%s金币！\n成为VIP后可增加福利券上限！",
                                StringHelper.ToRedNum(hb_limit), StringHelper.ToRedNum(data.shop_gold_change), StringHelper.ToCash(data.jing_bi_change))
    VIPHintPanel.Create({desc=desc, type=2, cw_cb = function (  )
        DSM.PushAct({info = {vip = "vip_up_hb_limit"}})
    end})
end

function M.get_vip_up_cfg(v_l)
    if v_l then
        return vip_up_cfg.vip_up[v_l]
    end
    return vip_up_cfg.vip_up
end


function M.CheakRed(button_gotoui)
    if button_gotoui == "viplb" then 
        return M.CheakRed_viplb()
    end
    if button_gotoui == "viptq" then 
        return M.CheakRed_viptq()
    end 
    if button_gotoui == "vipmzfl" then 
        return M.CheakRed_vipmzfl()
    end 
    if button_gotoui == "vipmxb" then 
        return  M.CheakRed_vipmxb()
    end 
    if button_gotoui == "vipyjtz" then 
        return  M.CheakRed_vipyjtz()
    end 
    if button_gotoui == "vipqys" then 
        return M.CheakRed_vipqys()
    end 
    return false
end


function M.CheakRed_viplb()
    if M.get_vip_task(111) and M.get_vip_task(111).award_status == 1 then 
        return true
    else
        return false
    end   
end

function M.CheakRed_viptq()
    return false
end

function M.CheakRed_vipmzfl()
    if M.get_vip_task(21016) then 
        if M.get_vip_task(21016).award_status == 1 then 
            return true
        end 
    end
    if M.get_vip_task(21017) then 
        if M.get_vip_task(21017).award_status == 1 then 
            return true
        end
    end
    return false 
end

function M.CheakRed_vipmxb()
    local is_have = GameMatchModel.IsTodayHaveMatchByType("mxb")
    if  is_have then 
        return true
    else
        return false
    end 
end

function M.CheakRed_vipyjtz()
    if M.get_vip_task(112) and M.get_vip_task(112).award_status == 1 then 
        return true
    else
        return false
    end 
end

function M.CheakRed_vipqys()
    local QYSdata = {}
    for i = 1, 8 do
        QYSdata[i] =  M.get_vip_task(112 + i)
    end
    for k, v in pairs(QYSdata) do 
        if v and v.award_status == 1 then
            return true
        end 
    end
    return false 
end