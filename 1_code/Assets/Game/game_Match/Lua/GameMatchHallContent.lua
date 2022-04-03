-- 创建时间:2018-12-04

local basefunc = require "Game.Common.basefunc"

GameMatchHallContent = basefunc.class()

local C = GameMatchHallContent
C.name = "GameMatchHallContent"
local dotweenlayer = "GameMatchHallContent_1"
local instance
function C.Create(parent, config)
    if instance then
        instance:Exit()
    end
    instance = C.New(parent, config)
	return instance
end

function C.Close()
    if instance then
        instance:Exit()
    end
end

function C.Refresh(game_tag)
    if instance then
        instance:Update(game_tag)
    end
end

function C.RefreshSwitch(game_type)
    if instance then
        instance:UpdateSwhich(game_type)
    end
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["finish_gift_shop_shopid_13"] = basefunc.handler(self, self.finish_gift_shop_shopid_13)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:ctor(parent, config)
    self.config = config
	local obj = newObject(C.name, parent)
    self.gameObject = obj
    self.transform = obj.transform
	self:MakeLister()
    self:AddMsgListener()
    LuaHelper.GeneratingVar(obj.transform, self)
    self:Init()
    self.update_timer = Timer.New(function()
            self:UpdateTimer()
        end,1,-1,false
    )
    self.update_timer:Start()
end

function C:Exit()
    self:RemoveListener()
    if self.update_timer then
        self.update_timer:Stop()
        self.update_timer = nil
    end
    self:ClearMatchList()
    GameObject.Destroy(self.gameObject)
end

function C:Init()
    EventTriggerListener.Get(self.begin_btn.gameObject).onClick = basefunc.handler(self, self.OnClickGotoMatch)
    self:Reset()
end

function C:Reset(cur_tge)
    GameMatchHallTgeMini.Close()
    if cur_tge then
        self.cur_tag = cur_tge
        self.cur_cfg = self.config[cur_tge]    
        self.cur_hall_cfg = GameMatchModel.GetHallMapConfigByGameTge(self.cur_tag)
    end
    self.begin_goto.gameObject:SetActive(false)
    self.begin_show.gameObject:SetActive(false)
    self.begin_show_switch.gameObject:SetActive(false)
    self.not_begin.gameObject:SetActive(false)
    self.begin_show_content.transform.localPosition = Vector3.New(0, 0, 0)
    self.begin_show_switch_content.transform.localPosition = Vector3.New(0, 0, 0)
end

function C:finish_gift_shop_shopid_13()
    --更新千元赛的游戏列表
    if self.cur_tag == GameMatchModel.MatchType.gms then
        self:Update(self.cur_tag)
    end
end

--刷新游戏列表
function C:ClearMatchList()
    if self.MatchList then
        for k,v in ipairs(self.MatchList) do
            v:OnDestroy()
        end
    end
    self.MatchList = {}
    self.MatchHash = {}
end

function C:AddMatchList(list)
    local parent_tf
    local content_type = self.cur_hall_cfg.content_type
    if content_type == 1 then
        parent_tf = self.begin_show_content.transform
    elseif content_type == 2 then
        parent_tf = self.begin_show_switch_content.transform
    end
    if self.cur_tag == GameMatchModel.MatchType.hbs then
        self.isGuide = GuideLogic.IsMatchNewButton()
        if self.isGuide then
            local item = GameMatchHallMatchItem.Create(parent_tf, config[1])
            item:SetObjName("MatchHallCell_888")
            table.insert( self.MatchList, item)
            self.MatchHash[1] = item
        end
        if list and next(list) then
            for k, v in ipairs(list) do
                if v.game_id ~= 1 then
                    local item = GameMatchHallMatchItem.Create(parent_tf, v)
                    item:SetObjName(v.game_id)
                    table.insert( self.MatchList, item)
                    self.MatchHash[v.game_id] = item
                end
            end
        end
    else
        if list and next(list) then
            for k, v in ipairs(list) do
                if v.game_id ~= 1 then
                    local item = GameMatchHallMatchItem.Create(parent_tf, v)
                    item:SetObjName(v.game_id)
                    table.insert( self.MatchList, item)
                    self.MatchHash[v.game_id] = item
                end
            end
        end
    end  
end

function C:SetContentTypeShow(force_is_on)
    local content_type = self.cur_hall_cfg.content_type
    local is_on = self.cur_hall_cfg.is_on and self.cur_hall_cfg.is_on == 1
    if force_is_on ~= nil then is_on = force_is_on end
    if content_type == 1 then
        self.begin_show.gameObject:SetActive(is_on)
    elseif content_type == 2 then
        self.begin_show_switch.gameObject:SetActive(is_on)
    elseif content_type == 3 then
        self.begin_goto.gameObject:SetActive(is_on)
    end
    self.not_begin.gameObject:SetActive(not is_on)
end

function C:SetMatchGoto()
    if not table_is_null(self.cur_hall_cfg.begin_goto_ui) then
        if not self.begin_goto_img then
            self.begin_goto_img = self.begin_btn.transform:GetComponent("Image")
        end
        self.begin_goto_img.sprite = GetTexture(self.cur_hall_cfg.begin_goto_ui[1])
    end
    local is_on = self.cur_hall_cfg.is_on and self.cur_hall_cfg.is_on == 1
    if is_on then
        self.begin_goto.gameObject:SetActive(true)
    end
end

function C:SetNotBegin()
    if not table_is_null(self.cur_hall_cfg.not_begin_ui) then
        self.not_begin_bg_img.sprite = GetTexture(self.cur_hall_cfg.not_begin_ui[1])
        self.not_begin_1_img.sprite = GetTexture(self.cur_hall_cfg.not_begin_ui[2])
        self.not_begin_2_img.sprite = GetTexture(self.cur_hall_cfg.not_begin_ui[3])
        self.not_begin_desc_txt.text = self.cur_hall_cfg.not_begin_ui[4]    
    end
    local is_on = self.cur_hall_cfg.is_on and self.cur_hall_cfg.is_on == 1
    if not is_on then
        self.not_begin.gameObject:SetActive(true)
    end
end

function C:Update(game_tag)
    self:Reset(game_tag)
    self:SetContentTypeShow()
    self:SetNotBegin()
    local content_type = self.cur_hall_cfg.content_type
    if content_type == 1 then
        self:ClearMatchList()
        local list = self:FilterMatchByType(self.cur_cfg)
        self:AddMatchList(list)
    elseif content_type == 2 then
        GameMatchHallTgeMini.Create(self.transform,self.cur_hall_cfg)
        if GameMatchModel.GetLastGameType() == "ddz" then
            self.game_type = "game_DdzMatch"
        elseif GameMatchModel.GetLastGameType() == "mj" then
            self.game_type = "game_MjXzMatch3D"
        elseif GameMatchModel.GetLastGameType() == "ddz_pdk_match" then
            self.game_type = "game_DdzPDKMatch"
        end
        GameMatchHallTgeMini.SetTgeIsOn(self.game_type)
    elseif content_type == 3 then
        self:SetMatchGoto()
    end
    self:OpenRightUIAnim()
end

function C:UpdateSwhich(game_type)
    self:ClearMatchList()
    local list = self:FilterMatchByType(self.cur_cfg,game_type)
    self:AddMatchList(list)
end

function C:OpenRightUIAnim()
    if self.isGuide then
        return
    end
    local isanim = false
    if not self.cur_tag or not self.cur_cfg then
        return
    end
    local is_on = self.cur_hall_cfg.is_on and self.cur_hall_cfg.is_on == 1
    local content_type = self.cur_hall_cfg.content_type

    local function move(node)
        local Ease = DG.Tweening.Ease.OutBack
        local tt2 = 0.3

        if self.rightSeq then
            self.rightSeq:Kill()
        end
        node.transform.localPosition = Vector3.New(1800, 0, 0)
        self.rightSeq = DoTweenSequence.Create()
        local tweenKey = DOTweenManager.AddTweenToLayer(self.rightSeq, dotweenlayer)
        self.rightSeq:Append(node.transform:DOLocalMoveX(0, tt2):SetEase(Ease))
        self.rightSeq:OnKill(
            function()
                DOTweenManager.RemoveLayerTween(tweenKey, dotweenlayer)
                node.transform.localPosition = Vector3.New(0, 0, 0)
            end
        )
    end

    if is_on then
        if content_type == 1 or content_type == 2 then
            if self.MatchList and next(self.MatchList) then
                local i = 0
                local tt = 0.1
                for k,v in ipairs(self.MatchList) do
                    v:PlayAnim(tt * i)
                    i = i + 1
                end
            end
        elseif content_type == 3 then
            move(self.begin_goto)
        end
    else
        move(self.not_begin)
    end
end

function C:FilterMatchByType(config,game_type)
    local list = {}
    local curT = os.time()
    if self.cur_tag == GameMatchModel.MatchType.hbs then
        if game_type then
            self.game_type = game_type
        else
            if GameMatchModel.GetLastGameType() == "ddz" then
                self.game_type = "game_DdzMatch"
            elseif GameMatchModel.GetLastGameType() == "mj" then
                self.game_type = "game_MjXzMatch3D"
            elseif GameMatchModel.GetLastGameType() == "ddz_pdk_match" then
                self.game_type = "game_DdzPDKMatch"
            end
        end
        for _, v in pairs(config) do
            if self.game_type == v.game_type then
                list[#list + 1] = v
            end
        end
        table.sort(list,function(a, b)
            return a.ui_order < b.ui_order
        end)
    elseif self.cur_tag == GameMatchModel.MatchType.gms then
        local latestOne = false
        for _, v in pairs(config) do
            if curT >= v.show_time and curT <= v.hide_time then
                list[#list + 1] = v
            end
        end
        table.sort(list, function(d1, d2)
            return d1.over_time < d2.over_time
        end)

        for i,v in ipairs(list) do
            if not latestOne and v.over_time > curT then
                latestOne = true
                v.latestOne = 1
            else
                v.latestOne = 0
            end 
        end
    else
        for _, v in pairs(config) do
            if curT >= v.show_time and curT <= v.hide_time then
                list[#list + 1] = v
            end
        end
        table.sort(list,function(a, b)
            return a.ui_order < b.ui_order
        end)
    end
    return list
end

function C:CheckMatchIsTime(game_tag)
    if self.cur_hall_cfg then
        if self.cur_hall_cfg.is_time and self.cur_hall_cfg.is_time == 1 then
            return true
        end
    end
end

function C:UpdateTimer()
    if not self:CheckMatchIsTime(self.cur_tag) then
        return
    end
    local cur_t = os.time()
    local content_type = self.cur_hall_cfg.content_type
    local is_on = self.cur_hall_cfg.is_on and self.cur_hall_cfg.is_on == 1
    if not is_on then
        self:SetContentTypeShow()
        return
    end

    if self.cur_tag == GameMatchModel.MatchType.jyb then
        --鲸鱼杯
        is_on = GameGlobalOnOff.CityActivity and 
        cur_t >= city_match_config.config_num.beginTime and
        cur_t <= city_match_config.config_num.endTime
    else
        local is_show_match
        local v_match = {}
        local match_list = {}
        for i,v_cfg in pairs(self.cur_cfg) do
            is_show_match = cur_t >= v_cfg.show_time and cur_t <= v_cfg.hide_time
            if not is_on then
                is_on = is_show_match
            end

            if is_show_match then
                if self.MatchHash and next(self.MatchHash) and self.MatchHash[v_cfg.game_id] then
                    --已添加
                else
                    --添加
                    table.insert( match_list,v_cfg)
                end
            else
                if self.MatchHash and next(self.MatchHash) and self.MatchHash[v_cfg.game_id] and self.MatchList and next(self.MatchList) then
                    if is_show_match then
                        --刷新
                    else
                        --移除
                        local match_item = self.MatchHash[v_cfg.game_id]
                        match_item:PlayAnimOut(0.2)
                        self.MatchHash[v_cfg.game_id] = nil
                        for j = #self.MatchList,1 do
                            if v_match.config.game_id == v_cfg.game_id then
                                table.remove( self.MatchList,j)                  
                            end
                        end
                    end                     
                else
                    --已移除
                end
            end
        end
        if match_list and next(match_list) then
            self:AddMatchList(match_list)
            local i = 0
            local tt = 0.1
            local match_item
            for k,v in ipairs(match_list) do
                match_item = self.MatchHash[v.game_id]
                if match_item then
                    match_item:PlayAnim(tt * i)
                    i = i + 1
                end
            end
        end
    end
    self:SetContentTypeShow(is_on)
end

function C:OnClickGotoMatch()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    GameMatchHallPanel.ShowMatch(self.cur_cfg)
end