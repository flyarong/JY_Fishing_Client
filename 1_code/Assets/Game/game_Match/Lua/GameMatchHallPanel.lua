-- 创建时间:2018-10-15
local basefunc = require "Game.Common.basefunc"
GameMatchHallPanel = basefunc.class()
GameMatchHallPanel.name = "GameMatchHallPanel"
local dotweenlayer = "GameMatchHallPanel"
local instance
local lister
local listerRegisterName = "GameMatchHallListerRegister"
function GameMatchHallPanel.Create(parm)
    if not instance then
        DSM.PushAct({panel = GameMatchHallPanel.name})
        instance = GameMatchHallPanel.New(parm)
    else
        instance:MyRefresh(parm)
    end
    return instance
end

function GameMatchHallPanel:ctor(parm)

	ExtPanel.ExtMsg(self)
    self.dot_del_obj = true

    self.parm = parm
    local parent = GameObject.Find("Canvas/GUIRoot").transform
    local obj = newObject(GameMatchHallPanel.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    self.duihuanshangcheng_anniu = self.transform:Find("@hall_ui/duihuanshangcheng_anniu")
    local btn_map = {}
	btn_map["left_top"] = {self.btnNode}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "match_hall")
    self:MyInit()
    self:MyRefresh()
    Event.Brocast("JBS_Created")
end

function GameMatchHallPanel:MyInit()
    ExtendSoundManager.PlaySceneBGM(audio_config.game.bgm_bisai_bisaidengdai.audio_name)
    self:MakeLister()
    MatchLogic.setViewMsgRegister(lister, listerRegisterName)
    EventTriggerListener.Get(self.hall_back_btn.gameObject).onClick = basefunc.handler(self, self.OnClickBackMatch)
    EventTriggerListener.Get(self.shop_btn.gameObject).onClick = basefunc.handler(self, self.OnClickShoping)
    EventTriggerListener.Get(self.duihuan_btn.gameObject).onClick = basefunc.handler(self, self.OnClickStore)
    self:InitContent()
    self:InitTge()
    self:GameGlobalOnOff()
end

function GameMatchHallPanel:MyRefresh()
    self:UpdateAssetInfo()
    self:OpenUIAnim()
end

function GameMatchHallPanel:MyExit()
    if instance then
        DOTweenManager.KillAllLayerTween(dotweenlayer)
        MatchLogic.clearViewMsgRegister(listerRegisterName)
        GameMatchHallContent.Close()
        instance = nil
        GameMatchHallDetailPanel.Close()
        if self.game_btn_pre then
            self.game_btn_pre:MyExit()
        end
    end
end

function GameMatchHallPanel:MyClose()
    self:MyExit()
    DSM.PopAct()
    closePanel(GameMatchHallPanel.name)
end

function GameMatchHallPanel:MakeLister()
    lister = {}
    lister["AssetChange"] = basefunc.handler(self, self.UpdateAssetInfo)
end

--************方法
-- 界面打开的动画
function GameMatchHallPanel:OpenUIAnim()
    local Ease = DG.Tweening.Ease.InOutQuart
    local tt = 0.2
    local tt2 = 0.15
    local tt3 = 0.15

    self.RectTop.transform.localPosition = Vector3.New(0, 150, 0)
    self.LeftNode.transform.localPosition = Vector3.New(-1200, -67.5, 0)

    local seq = DoTweenSequence.Create()
    local tweenKey = DOTweenManager.AddTweenToLayer(seq, dotweenlayer)
    seq:Append(self.RectTop.transform:DOLocalMoveY(-86, tt):SetEase(Ease))
    seq:Append(self.LeftNode.transform:DOLocalMoveX(-763, tt3):SetEase(Ease))

    seq:OnComplete(
        function()
            self:OpenUIAnimFinish()
        end
    )
    seq:OnKill(
        function()
            DOTweenManager.RemoveLayerTween(tweenKey, dotweenlayer)            
        end
    )
end

function GameMatchHallPanel:OpenUIAnimFinish()
    self.RectTop.transform.localPosition = Vector3.New(0, -86, 0)
    self.LeftNode.transform.localPosition = Vector3.New(-763, -67.5, 0)
    GuideLogic.CheckRunGuide("match_hall")
end

function GameMatchHallPanel.SetTgeByID(tge_id)
    dump(instance, "<color=yellow>SetTgeByID</color>")
    if instance then
        GameMatchHallTge.SetTgeIsOn(tge_id)
    end
end

--func1 需要更新回调   func2正常状态回调
function GameMatchHallPanel.HandleEnterGameClick(game_type, func1, func2)
    local sceneConfig = GameConfigToSceneCfg[game_type]
    if not sceneConfig then
        print("<color=red> is nil</color>",game_type)
        return
    end

    local sceneName = sceneConfig.SceneName
    local state = gameMgr:CheckUpdate(sceneName)
    -- state = "Update"
    if state == "Install" or state == "Update" then
        if func1 then
            func1()
        end
    elseif state == "Normal" then
        if func2 then
            func2()
        end
    else
        local msg = MainLogic.FormatGameStateError(state)
        if msg ~= nil then
            HintPanel.ErrorMsg(msg)
        end
    end
end

function GameMatchHallPanel:GameGlobalOnOff()
    if GameGlobalOnOff.Exchange then
        self.duihuan_btn.gameObject:SetActive(true)
    else
        self.duihuan_btn.gameObject:SetActive(false)
    end

    if GameGlobalOnOff.MatchUrgencyClose then
        HintPanel.Create(1, "比赛正在升级，请耐心等待，升级完毕后会通过邮件告知，请注意查看邮件", function ()
            MainLogic.GotoScene("game_Hall")
        end)
    end
end

-- 刷新钱
function GameMatchHallPanel:UpdateAssetInfo()
    self.ticker_num_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
    self.red_packet_txt.text = StringHelper.ToRedNum(MainModel.GetHBValue())
end

function GameMatchHallPanel.SetContentByCfg(game_tag)
    GameMatchHallContent.Refresh(game_tag)
end

function GameMatchHallPanel.UpdateRightUI(cfg)
    GameMatchHallPanel.SetContentByCfg(cfg.game_tag)
end

--Tge
function GameMatchHallPanel:InitTge()
    local config = GameMatchModel.GetHall()
    GameMatchHallTge.Create(self.LeftNode,config)
    --默认开启红包赛
    local match_type_id = GameMatchModel.GetCurMatchType() or 1
    GameMatchHallTge.SetTgeIsOn(match_type_id)
    -- GameMatchHallPanel.SetTgeByID(match_type_id)
end

--Content
function GameMatchHallPanel:InitContent()
    local config = GameMatchModel.GetConfigByType()
    GameMatchHallContent.Create(self.RightNode,config)
end

--OnClick**********************************
function GameMatchHallPanel:OnClickBackMatch(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    -- GameMatchModel.SetCurMatchType()
    MainLogic.GotoScene("game_MiniGame")
end

function GameMatchHallPanel:OnClickShoping(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    DSM.PushAct({button = "pay_btn"})
    PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
end

function GameMatchHallPanel:OnClickStore(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    MainModel.OpenDH()
end

function GameMatchHallPanel.ShowMatch(cfg)
    if table_is_null(cfg) then return end
    if cfg.game_type == GameMatchModel.GameType.game_DdzMatch or cfg.game_type == GameMatchModel.GameType.game_DdzPDKMatch or cfg.game_type == GameMatchModel.GameType.game_MjXzMatch3D then
        --红包赛模式
        GameMatchHallPanel.ShowMatchHBS(cfg)
    elseif cfg.game_type == GameMatchModel.GameType.game_DdzMatchNaming or cfg.game_type == GameMatchModel.GameType.game_MjMatchNaming then
        --千元赛模式
        GameMatchHallPanel.ShowMatchQYS(cfg)
    elseif cfg.game_type == GameMatchModel.GameType.game_CityMatch then
        GameMatchHallPanel.ShowMatchJYB(cfg)
    elseif cfg.game_type == GameMatchModel.GameType.game_DdzMillion then
        GameMatchHallPanel.ShowMatchBWS(cfg)
    end
end

function GameMatchHallPanel.SignupMatch(cfg)
    if table_is_null(cfg) then return end
    if cfg.game_type == GameMatchModel.GameType.game_DdzMatch or cfg.game_type == GameMatchModel.GameType.game_DdzPDKMatch or cfg.game_type == GameMatchModel.GameType.game_MjXzMatch3D then
        --红包赛模式
        GameMatchHallPanel.SignupMatchHBS(cfg)
    elseif cfg.game_type == GameMatchModel.GameType.game_DdzMatchNaming or cfg.game_type == GameMatchModel.GameType.game_MjMatchNaming then
        --千元赛模式
        GameMatchHallPanel.SignupMatchQYS(cfg)
    elseif cfg.game_type == GameMatchModel.GameType.game_CityMatch then
    elseif cfg.game_type == GameMatchModel.GameType.game_DdzMillion then
    end
end

function GameMatchHallPanel.ShowMatchHBS(cfg)
    if tonumber(cfg.game_id) == 1 then
        --新手引导
        GameMatchHallPanel.SignupMatch(cfg)
        return
    end
    GameMatchHallDetailPanel.Create(cfg.game_id)
end

--红包赛模式报名
function GameMatchHallPanel.SignupMatchHBS(cfg)
    if tonumber(cfg.game_id) == 1 then
        --新手引导
        if instance then
            instance:MyExit()
        end
        GameManager.GotoSceneID(1,true,nil,function()
            if not Network.SendRequest("nor_mg_xsyd_signup", nil, "正在报名") then
                HintPanel.Create(1,"网络异常",function()
                    GameManager.GotoSceneName("game_Match")
                end)
            end
        end)
        return
    end

    if tonumber(cfg.game_id) == 10 then
        --一元赛
        GameMatchHallPanel.ShowMatch(cfg)
        return
    end

    if cfg.game_tag == GameMatchModel.MatchType.fps then
        LittleTips.Create("扶贫赛即将开始")
        return
    end

    local signup = function ()
        local request = {id = tonumber(cfg.game_id)}
        GameMatchModel.SetCurrGameID(cfg.game_id)
        local scene_id = GameMatchModel.GetGameIDToScene(cfg.game_id)
        GameManager.GotoSceneID(scene_id , true , nil , function() 
            if not Network.SendRequest("nor_mg_signup", request, "正在报名") then
                HintPanel.Create(1, "网络异常", function()
                    GameManager.GotoSceneName("game_Match")
                end)
            end
        end)
    end
    local config = GameMatchModel.GetGameIDToConfig(cfg.game_id)
    -- dump(config, "<color=white>比赛配置》》》》</color>")
    local itemkey, item_count = GameMatchModel.GetMatchCanUseTool(config.enter_condi_itemkey, config.enter_condi_item_count)
    if itemkey then
        signup()
    else
        if config.enter_condi_count <= MainModel.UserInfo.jing_bi then
            signup()
        else
            PayFastPanel.Create(config, signup)
        end 
    end
end

function GameMatchHallPanel.ShowMatchQYS(cfg)
    local game_over_countdown = tonumber(cfg.over_time) - os.time()
    local game_start_countdown = tonumber(cfg.start_time) - os.time()

    local qurey_rank = function()
        -- 排行榜分步请求
        local cur_index = 1
        local rank_list = {}
        local call
        call = function ()
            Network.SendRequest("nor_mg_query_all_rank",{id = cfg.game_id, index = cur_index},"正在请求排名",
                function(data)
                    cur_index = cur_index + 1
                    dump(data, "<color=yellow>nor_mg_query_all_rank_response</color>")
                    if data.result == 0 then
                        for k,v in ipairs(data.rank_list) do  
                            rank_list[#rank_list + 1] = v
                        end
                        if #data.rank_list < 100 then
                            -- 排行榜请求完成
                            GameMatchHallRankPanel.Create(cfg, rank_list)
                        else
                            call()
                        end
                    elseif data.result == 1004 then
                        GameMatchHallRankPanel.Create(cfg)
                    else
                        HintPanel.ErrorMsg(data.result)
                    end
            end)
        end
        call()
    end
    --比赛结束排行榜处理
    if game_over_countdown <= 0 then
        qurey_rank()
        return
    end

    GameMatchHallDetailPanel.Create(cfg.game_id)
end

--千元赛模式报名
function GameMatchHallPanel.SignupMatchQYS(cfg)
    dump(cfg, "<color=white>cfg????????千元赛模式报名</color>")
    local game_over_countdown = tonumber(cfg.over_time) - os.time()
    local game_start_countdown = tonumber(cfg.start_time) - os.time()
    --测试数据
    -- game_over_countdown = -1

    --各种情况不能报名
    if game_over_countdown <= 0 or 
        (cfg.iswy and cfg.iswy == 1) or
        game_start_countdown > 0 or
        not GameMatchModel.CheckIsCanSignup(cfg) then
            GameMatchHallPanel.ShowMatchQYS(cfg)
        return
    end

    if GameMatchModel.CheckIsCanSignup(cfg) and not GameMatchModel.CheckIsCanSignupByTicket(cfg) then
        --金币满足道具不满足，排除不能用金币报名的比赛
        if cfg.game_tag == GameMatchModel.MatchType.gms then
            if not cfg.iswy or cfg.iswy ~= 1 then
                GameMatchHallDetailPanel.Create(cfg.game_id)
                return
            end
        end
    end

    Network.SendRequest("nor_mg_signup", {id = cfg.game_id}, "正在报名",
        function(data)
            dump(data, "<color=yellow>千元赛模式报名结果</color>")
            if data.result == 0 then
                GameMatchModel.SetCurrGameID(cfg.game_id)
                local scene_id = GameMatchModel.GetGameIDToScene(cfg.game_id)
                GameManager.GotoSceneID(scene_id, false, nil)
                if instance then
                    instance:MyExit()
                end
            elseif data.result == 3601 then
                HintPanel.Create(2,"您已经参加过该比赛了，更多红包赛等你来，是否立刻前往红包赛？",function()
                    GameMatchHallDetailPanel.Close()
                    GameMatchHallPanel.SetTgeByID(1)
                end)
            else
                HintPanel.ErrorMsg(data.result)
            end
        end
    )
end

--百万大奖赛模式
function GameMatchHallPanel.ShowMatchBWS(cfg)
    local sceneName = GameConfigToSceneCfg["game_DdzMillion"].SceneName
    local function GoToMillion()
        Network.SendRequest("dbwg_req_game_list",nil,"正在请求数据",function(data)
            if data.result == 0 then
                MainLogic.GotoScene(sceneName)
            else
                HintPanel.Create(1, "今日没有比赛")
            end
        end)
    end

    GameMatchHallPanel.HandleEnterGameClick(
        sceneName,
        function()
            RoomCardDown.Create(
                sceneName,
                function()
                    GoToMillion()
                end
            )
        end,
        function()
            GoToMillion()
        end
    )
end

--鲸鱼杯模式
function GameMatchHallPanel.ShowMatchJYB(cfg)
    MainModel.RequestCityMatchStateData(
        function(data)
            local sceneName = GameConfigToSceneCfg["game_CityMatch"].SceneName
            GameMatchHallPanel.HandleEnterGameClick(
                sceneName,
                function()
                    package.loaded["Game.game_Hall.Lua.RoomCardDown"] = nil
                    require "Game.game_Hall.Lua.RoomCardDown"
                    RoomCardDown.Create(
                        sceneName,
                        function()
                            MainLogic.GotoScene(sceneName, data)
                        end
                    )
                end,
                function()
                    MainLogic.GotoScene(sceneName, data)
                end
            )
        end
    )
end