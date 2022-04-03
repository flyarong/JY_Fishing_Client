-- 创建时间:2018-11-06
local basefunc = require "Game/Common/basefunc"

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
GameButtonManager.ExtLoadLua(M.key, "VIPUPPanel_New")
GameButtonManager.ExtLoadLua(M.key, "VIPUPItemBase")

--测试 VipShowTaskPanel2
GameButtonManager.ExtLoadLua(M.key, "VipShowTaskPanel2")
GameButtonManager.ExtLoadLua(M.key, "VipShowYJTZPanel")
GameButtonManager.ExtLoadLua(M.key, "VipShowLBPanel")
GameButtonManager.ExtLoadLua(M.key, "VipShowTQPanel")
GameButtonManager.ExtLoadLua(M.key, "VipShowMZFLPanel")
GameButtonManager.ExtLoadLua(M.key, "VipShowMXBPanel")
GameButtonManager.ExtLoadLua(M.key, "VipShowQYSPanel")
GameButtonManager.ExtLoadLua(M.key, "VipShowJHLBPanel")
GameButtonManager.ExtLoadLua(M.key, "VipShowJHLBItemBase")
GameButtonManager.ExtLoadLua(M.key, "VipShowFHFLPanel")
GameButtonManager.ExtLoadLua(M.key, "VipShowFHFLItemBase")
GameButtonManager.ExtLoadLua(M.key, "VipShowVIP4HKSPanel")
GameButtonManager.ExtLoadLua(M.key, "VIPMZFLChildPrefab")
GameButtonManager.ExtLoadLua(M.key, "VIPMZFLHelpPanel")
GameButtonManager.ExtLoadLua(M.key, "VipShowZZLBPanel")
GameButtonManager.ExtLoadLua(M.key, "VIPYJTZChildPrefab")
GameButtonManager.ExtLoadLua(M.key, "VIPYJTZHelpPanel")
GameButtonManager.ExtLoadLua(M.key, "VIPNoticetPanel")


VIPManager.is_on_off = false

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

function M.CheckIsShow()
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
    elseif parm.goto_scene_parm == "info" or parm.goto_scene_parm == "VIP2" then
        return VipShowTaskPanel2.Create()
    -- elseif parm.goto_scene_parm == "VIP2" then
    --     local v = M.get_vip_level()
    --     if v > 0 then
    --         return VipShowInfoPanel.Create()
    --     else
    --         return VIPShowWealPanel.Create()
    --     end
    elseif parm.goto_scene_parm == "enter" then
        return VIPEnterPrefab.Create(parm.parent, parm.cfg)
    elseif parm.goto_scene_parm == "hint" then
        return VIPHintPanel.Create(parm.data)
    elseif parm.goto_scene_parm == "notice" then
        --冲金鸡没有vip11和vip12
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="cpl_notcjj", is_on_hint = true}, "CheckCondition")
        if a and b then
            if PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."vip10",0) == 0 and VIPManager.get_vip_level() == 10  then
                PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."vip10",1)
                return VIPNoticetPanel.Create()
            end
        end
    elseif parm.goto_scene_parm == "vip4hks" then
        local tab = os.date("*t")
        local target_month
        local target_year
        if tab.month + 1 <= 12 then
            target_month = tab.month + 1
            target_year = tab.year
        else
            target_month = 1
            target_year = tab.year + 1
        end
        local temp = {year = target_year,month = target_month,day = 1,hour = 0,min = 0,sec = 0,isdst = false}
        local begin_time = os.time(temp) - 86400
        local end_time = os.time(temp)
        if (os.time() >= begin_time) and (os.time() <= end_time) then
            if MainModel.UserInfo.vip_level >= 4 then
                local newtime = tonumber(os.date("%Y%m%d", os.time()))
                local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetInt(M.key .. MainModel.UserInfo.user_id .. "vip4hks_popup", 0))))
                if newtime ~= oldtime then
                    PlayerPrefs.SetInt(VIPManager.key .. MainModel.UserInfo.user_id .. "vip4hks_popup", os.time())
                    return VipShowTaskPanel2.Create(nil,{gotoui = "vip4hks"})
                end
            end
        end
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
    m_cfg.cfg_max_vip_level = 1
    for i,v in ipairs(cfg.dangci) do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key= v.key, is_on_hint = true}, "CheckCondition")
        if a and b then

            if not m_cfg.dangci[v.vip] then
                m_cfg.dangci[v.vip] = {}
            end
            m_cfg.dangci[v.vip].xycj = v.xycj
            m_cfg.dangci[v.vip].total = v.total
            m_cfg.dangci[v.vip].cfz = v.cfz
            if not m_cfg.dangci[v.vip].info then
                m_cfg.dangci[v.vip].info = {}
            end
            m_cfg.dangci[v.vip].info[#m_cfg.dangci[v.vip].info + 1] = {desc = v.info, gotoUI = v.gotoUI , gotoShop = v.gotoShop}

            if v.vip > m_cfg.cfg_max_vip_level then
                m_cfg.cfg_max_vip_level = v.vip
            end
        end
    end

    m_cfg.gift = {}
    for i,v in ipairs(cfg.gift) do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key= v.condi_key, is_on_hint = true}, "CheckCondition")
        if a and b then
            m_cfg.gift[#m_cfg.gift + 1] = v
        end
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
    m_cfg.vip_up = cfg.vip_up
    m_cfg.vipmzfl = {}
    for i,v in ipairs(cfg.vipmzfl) do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key= v.condi_key, is_on_hint = true}, "CheckCondition")
        if a and b then
            m_cfg.vipmzfl[#m_cfg.vipmzfl + 1] = v
            m_cfg.task[v.task_id] = 1
        end
    end
    m_cfg.fhfl = {}
    for i,v in ipairs(cfg.fhfl) do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key= v.condi_key, is_on_hint = true}, "CheckCondition")
        if a and b then
            m_cfg.fhfl[#m_cfg.fhfl + 1] = v
            m_cfg.task[v.task_id] = 1
        end
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

-- 每周福利
function M.GetVIPMzflConfig()
    return vip_cfg.vipmzfl
end
function M.GetVIPMzflCfgByIndex(index)
    return vip_cfg.vipmzfl[index]
end
function M.GetMZFLTaskDataAndSort()
    local task_list = {}
    for k,v in ipairs(vip_cfg.vipmzfl) do
        local task = GameTaskModel.GetTaskDataByID(v.task_id)
        if task then
            task_list[#task_list + 1] = {award_status = task.award_status}
        else
            task_list[#task_list + 1] = {award_status = 0}
        end
        task_list[#task_list].id = v.task_id
        task_list[#task_list].order = v.index
    end
    local callSortGun = function(v1,v2)
        if v1.award_status == 1 and v2.award_status ~= 1 then
            return false
        elseif v1.award_status ~= 1 and v2.award_status == 1 then
            return true
        else
            if v1.award_status ~= 2 and v2.award_status == 2 then
                return false
            elseif v1.award_status == 2 and v2.award_status ~= 2 then
                return true
            else
                if v1.order > v2.order then
                    return true
                else
                    return false
                end
            end
        end
    end
    MathExtend.SortListCom(task_list, callSortGun)
    local ll = {}
    for k,v in ipairs(task_list) do
        ll[k] = v.id
    end
    return ll
end


-- 赢金挑战
function M.GetVIPYjtzTaskID()
    return 112
end
function M.GetVIPYjtzConfig()
    return vip_cfg.yjtz
end
function M.GetVIPYjtzCfgByIndex(index)
    return vip_cfg.yjtz[index]
end
function M.GetYjtzTaskDataAndSort()
    local task_data = GameTaskModel.GetTaskDataByID( M.GetVIPYjtzTaskID() )
    local award_status = {}
    if task_data then
        award_status = basefunc.decode_task_award_status(task_data.award_get_status)
        award_status = basefunc.decode_all_task_award_status2(award_status, task_data, #vip_cfg.yjtz)
    else
        for i=1, #vip_cfg.yjtz do
            award_status[#award_status + 1] = 0
        end
    end

    local task_list = {}
    for k,v in ipairs(vip_cfg.yjtz) do
        task_list[#task_list + 1] = {award_status = award_status[k]}
        task_list[#task_list].order = v.index
        task_list[#task_list].id = v.index
    end
    local callSortGun = function(v1,v2)
        if v1.award_status == 1 and v2.award_status ~= 1 then
            return false
        elseif v1.award_status ~= 1 and v2.award_status == 1 then
            return true
        else
            if v1.award_status ~= 2 and v2.award_status == 2 then
                return false
            elseif v1.award_status == 2 and v2.award_status ~= 2 then
                return true
            else
                if v1.order > v2.order then
                    return true
                else
                    return false
                end
            end
        end
    end
    MathExtend.SortListCom(task_list, callSortGun)
    local ll = {}
    for k,v in ipairs(task_list) do
        ll[k] = v.id
    end
    return ll
end
function M.QueryYjtzTask(jh)
    local task_data = GameTaskModel.GetTaskDataByID( M.GetVIPYjtzTaskID() )

    if not task_data then
        Network.SendRequest("query_one_task_data", {task_id = M.GetVIPYjtzTaskID()}, jh)
    else
        Event.Brocast("model_vip_upgrade_change_msg", task_data)
    end
end

function M.HallModelInitFinsh()
    print("<color=yellow>请求VIP数据</color>")
    Network.SendRequest("query_vip_base_info", nil,"请求VIP数据")
    M.set_vip_task()
    M.ChangeTaskCanGetRedHint()
    dump(m_data.vip_task, "<color=yellow>VIP任务数据</color>")
end

function M.PayPanelCreate(tf)
    if GameGlobalOnOff.VIPGift then
        VIPPayPrefab.Create(tf)
    end
end

function M.PayPanelClosed(tf)
    if GameGlobalOnOff.VIPGift then
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
        if M.CheckIsCJJ() then
            VIPUPPanel.Create(up_data)
        else
            VIPUPPanel_New.Create(up_data)
        end
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
    if GameGlobalOnOff.Vip then
        if txt.font.name == "vip_font_ty_hz" or txt.font.name == "vip_font_ty_hz_1" then
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
    if GameGlobalOnOff.Vip then
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
    if GameGlobalOnOff.VIPGift == true then
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

function M.is_waite(wait)
    M.waite=wait
end
function M.save_data(_, data)
    M.waite_data={}
    M.waite_data.other=_
    M.waite_data.data=data
end
function M.get_data()
    return M.waite_data
end

function M.on_player_hb_limit_convert(_, data)
    if  M.waite then
        M.save_data(_, data)
        return
    end
    local hb_limit = M.GetHBLimit()
    local desc = string.format("您当前携带的福利券已达到上限:%s，超出的%s福利券将转换成%s金币！\n成为VIP后可增加福利券上限！",
                                StringHelper.ToRedNum(hb_limit), StringHelper.ToRedNum(data.shop_gold_change), StringHelper.ToCash(data.jing_bi_change))
    VIPHintPanel.Create({desc=desc, type=2, cw_cb = function (  )
        Event.Brocast("player_hb_limit_over_msg")
        DSM.PushAct({info = {vip = "vip_up_hb_limit"}})
    end})
end

function M.get_vip_up_cfg(v_l)
    if v_l then
        local cfg = {}
        cfg.icon = "vip_tq_icon_hz" .. v_l
        cfg.qx = ""
        if vip_cfg.dangci[v_l] then
            for k,v in ipairs(vip_cfg.dangci[v_l].info) do
                if k == 1 then
                    cfg.qx = cfg.qx .. k .. "、" .. v.desc
                else
                    cfg.qx = cfg.qx .. "\n" .. k .. "、" .. v.desc
                end
            end
        end
        return cfg
    end
    return vip_cfg.dangci
end


function M.CheakRed(button_gotoui)
    --dump(button_gotoui,"<color=yellow>+++++++++++++++//////-----------</color>")
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
    if button_gotoui == "vipfhfl" then
        return M.CheakRed_vipfhfl()
    end
    if button_gotoui == "vipzzlb" then
        return M.CheakRed_vipzzlb()
    end
    if button_gotoui == "vip4hks" then
        return M.CheakRed_vip4hks()
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
    local cfg = M.GetVIPMzflConfig()
    local vip_level = M.get_vip_level()
    for k,v in ipairs(cfg) do
        local task_data = GameTaskModel.GetTaskDataByID(v.task_id)
        if task_data and task_data.award_status == 1 and vip_level <= v.vip then
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

function M.CheakRed_vipfhfl()
    local basefunc = require "Game/Common/basefunc"
    local data = GameTaskModel.GetTaskDataByID(M.GetFHFLTaskID())
    local b = basefunc.decode_task_award_status(data.award_get_status)
    b = basefunc.decode_all_task_award_status(b, data, #VIPManager.GetFHFLData())
    for i=1,#b do
        if b[i] and b[i] == 1 then
            return true
        end
    end
    return false
end

function M.CheakRed_vipzzlb()
    local tasks = {21248,21249,21250,21551}
    local func = function (task_id)
        local data = GameTaskModel.GetTaskDataByID(task_id)
        if data and data.award_status == 1 then
            return true
        end
    end
    for i = 1,#tasks do
        if func(tasks[i]) then
            return true
        end
    end
    return false
end

function M.CheakRed_vip4hks()
    local newtime = tonumber(os.date("%Y%m%d", os.time()))
    local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetInt(M.key .. MainModel.UserInfo.user_id .. "vip4hks", 0))))
    if newtime ~= oldtime then
        return true
    end
    return false
end

function M.GetJHLBData()
    return vip_cfg.gift
end

function M.GetFHFLTaskID()
    if vip_cfg and vip_cfg.fhfl and vip_cfg.fhfl[i] and vip_cfg.fhfl[1].task_id then
        return vip_cfg.fhfl[1].task_id
    else
        return 21341
    end
end
function M.GetFHFLData()
    return vip_cfg.fhfl
end

function M.GetUserMaxVipLevel()
    return vip_cfg.cfg_max_vip_level
end

function M.IsQuDaoChannel()
    local cheakfunc = function (_permission_key)
        if _permission_key then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
            if a and not b then
                return false
            end
            return true
        else
            return false
        end
    end
    if cheakfunc("vip11_treasure_to_gift_remain_hard") then
        return true
    else
        return false
    end
end

function M.CheckIsCJJ()
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "cpl_cjj", is_on_hint = true}, "CheckCondition")
    if a and b then
        return true
    else
        return false
    end
end