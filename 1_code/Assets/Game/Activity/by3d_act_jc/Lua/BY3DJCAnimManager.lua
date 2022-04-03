-- 创建时间:2020-06-18

BY3DJCAnimManager = {}
local M = BY3DJCAnimManager

function M.PlayAward(data)

    local LayerLv3 = GameObject.Find("Canvas/LayerLv3").transform
    GameComAnimTool.PlayShowAndHideAndCall(LayerLv3, "HFJJPrefab", Vector3.zero, 2.2, 2, function ()
        M.AnimCallBack(data)     
    end)
end
function M.AnimCallBack(data)
    local LayerLv3 = GameObject.Find("Canvas/LayerLv3").transform
    local object = GameObject.Instantiate(GetPrefab("JS" .. data.award_type .."Prefab"), LayerLv3)
    object.transform.localPosition = Vector3.zero
    local ui = {}
    LuaHelper.GeneratingVar(object.transform, ui)
    ui.score_txt.text = "0"
    local anim_tab = GameComAnimTool.play_number_change_anim(ui.score_txt, 0, data.money, 2, function ()
    end)
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(3)



    seq:OnKill(function () 
        GameComAnimTool.stop_number_change_anim(anim_tab)
        if call then 
        end
        Event.Brocast("change_game_show_font_color_msg")
        Event.Brocast("fishing_com_fly_jb_msg", {pos=Vector3.zero, score=data.money})
    end)
    seq:OnForceKill(function ()
        destroy(object)

    end)
end


local function CreateGold(parent, beginPos, endPos, delay, call, prefab_name, seq_parm)
    local zz = 100
    local _beginPos = Vector3.New(beginPos.x, beginPos.y, zz)
    local _endPos = Vector3.New(endPos.x, endPos.y, zz)
    local obj = GameObject.Instantiate(GetPrefab(prefab_name), parent).gameObject
    local tran = obj.transform
    tran.position = _beginPos
    tran.localScale = Vector3.New(1, 1, 1)

    local seq = DoTweenSequence.Create(seq_parm)
    local len = math.sqrt( (beginPos.x - endPos.x) * (beginPos.x - endPos.x) + (beginPos.y - endPos.y) * (beginPos.y - endPos.y) )
    local t = len / 1800
    if delay and delay > 0.00001 then       
        tran.gameObject:SetActive(false)
        seq:AppendInterval(delay)
        seq:AppendCallback(function ()
            if IsEquals(tran) then
                tran.gameObject:SetActive(true)
            end
        end)
    end
    seq:AppendInterval(1)
    seq:Append(tran:DOMove(_endPos, t))
    seq:OnKill(function ()
        if call then
            call()
        end
    end)
    seq:OnForceKill(function ()
        destroy(obj)
    end)
end 

--通用游戏局外产生金币飞行
function M.PlayTYJBFly(parent, beginPos, endPos, data, delta_t, call, seq_parm)
    local delta_t
    local num = 8
    if data and data.delta then
        delta_t = data.delta
    end
    if data and data.num then
        num = data.num
    end
    local prefab = "BY3DJCGold"
    if data and data.prefab then
        prefab = data.prefab
    end

    local call = function ()
        local t = 0.08
        local finish_num = 0
        local _call = function ()
            finish_num = finish_num + 1
            if finish_num == 1 then
                --GameComAnimTool.PlayMoveAndHideFX(parent, prefab, beginPos, endPos, nil, 1, nil, nil, seq_parm)
            end
            if finish_num == num then
                if call then
                    call()
                end
            end
        end


        for i = 1, num do
            local x = beginPos.x --+ math.random(0, 200) - 50  添加则会随机位置,当前为全部在同一位置
            local y = beginPos.y --+ math.random(0, 200) - 50
            local pos = Vector3.New(x, y, beginPos.z)
            CreateGold(parent, pos, endPos, t * (i-1), _call, prefab, seq_parm)
        end
    end

    if delta_t and delta_t > 0 then
        local seq = DoTweenSequence.Create(seq_parm)
        seq:AppendInterval(delta_t)
        seq:OnKill(function ()
            call()
        end)
    else
        call()
    end

end

--由小变大
function M.play_number_change_anim(gold_txt, begin_num, end_num, t, finish_call, force_kill_call)
    local tab = {}
    tab.gold_txt = gold_txt
    tab.begin_num = begin_num
    tab.end_num = end_num
    tab.t = t
    tab.finish_call = finish_call

    local cur_m = begin_num
    local spt = 0.04
    local money = math.abs(end_num - begin_num)
    local spm = math.max(1, math.ceil(money / (t * 1 / spt)))

    local function close_timer()
        if tab.update_time then
            tab.update_time:Stop()
            tab.update_time = nil
        end
        if IsEquals(tab.gold_txt) and tab.end_num then
            tab.gold_txt.text = tab.end_num
        end
        tab.gold_txt = nil
    end
    local function set_money(value)
        if IsEquals(gold_txt) then
            gold_txt.text = value
        else
            close_timer()
        end
    end
    tab.update_time = Timer.New(function ()
        cur_m = cur_m - spm
        if cur_m > end_num then
            set_money(cur_m)
        else
            cur_m = end_num
            close_timer()
        end
    end, spt, -1, nil, true)
    tab.update_time:Start()
    set_money(cur_m)

    tab.seq = DoTweenSequence.Create()
    tab.seq:AppendInterval(t)
    tab.seq:OnKill(function ()
        if finish_call then
            finish_call()
        end
    end)
    tab.seq:OnForceKill(function (force_kill)
        tab.seq = nil
        close_timer()
        if force_kill and force_kill_call then
            force_kill_call()
        end
    end)

    return tab
end

--小->大
function M.play_number_change_anim_samlltobig(gold_txt, begin_num, end_num, t, finish_call, force_kill_call)
    local tab = {}
    tab.gold_txt = gold_txt
    tab.begin_num = begin_num
    tab.end_num = end_num
    tab.t = t
    tab.finish_call = finish_call
    local  p_number = {10,100,1000,10000}
 
    local cur_m = begin_num
    local spt = 0.04
    local money = end_num - begin_num
    local spm = math.max(1, math.ceil(money / (t * 1 / spt)))

    local function close_timer()
        if tab.update_time then
            tab.update_time:Stop()
            tab.update_time = nil
        end
        if IsEquals(tab.gold_txt) and tab.end_num then
            tab.gold_txt.text = tab.end_num
        end
        tab.gold_txt = nil
    end
    local function set_money(value)
        local random_x = math.random(1,4) 
        if IsEquals(gold_txt) then
            gold_txt.text = value *p_number[random_x]
        else
            close_timer()
        end
    end
    tab.update_time = Timer.New(function ()
        cur_m = cur_m + spm 
        if cur_m > end_num then
            cur_m = end_num
            close_timer()
        end
        set_money(cur_m)
    end, spt, -1, nil, true)
    tab.update_time:Start()
    set_money(cur_m)

    tab.seq = DoTweenSequence.Create()
    tab.seq:AppendInterval(t)
    tab.seq:OnKill(function ()
        if finish_call then
            finish_call()
        end
    end)
    tab.seq:OnForceKill(function (force_kill)
        tab.seq = nil
        close_timer()
        if force_kill and force_kill_call then
            force_kill_call()
        end
    end)

    return tab
end

