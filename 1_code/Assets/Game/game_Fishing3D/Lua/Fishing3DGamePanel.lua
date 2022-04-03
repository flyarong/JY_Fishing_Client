-- 创建时间:2019-03-06
-- Panel:FishingGamePanel
local basefunc = require "Game/Common/basefunc"

FishingGamePanel = basefunc.class()
Fishing3DGamePanel = FishingGamePanel
local C = FishingGamePanel
C.name = "Fishing3DGamePanel"

-- 系统时间用于帧刷新的开关
local is_use_sys_clock = false

local is_run_game_panel = false
local instance
local m_pram
local isDebug = false
function C.Create(pram)
    m_pram = pram
    if not instance then
        DSM.PushAct({panel = C.name})
		instance = C.New(pram)
		instance = createPanel(instance, C.name)
	else
		instance:MyRefresh()
	end
	return instance
end
function C.Bind()
    local _in = instance
    instance = nil
    return _in
end

function C.Close()
	if instance then
		instance:MyExit()
	end
	instance = nil
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_shoot"] = basefunc.handler(self, self.Shoot)
    self.lister["model_player_PC"] = basefunc.handler(self, self.on_model_player_PC)
    self.lister["model_bullet_boom"] = basefunc.handler(self, self.on_model_bullet_boom)

    self.lister["model_fsg_join_msg"] = basefunc.handler(self, self.on_fsg_join_msg)
    self.lister["model_fsg_leave_msg"] = basefunc.handler(self, self.on_fsg_leave_msg)
    self.lister["model_player_money_msg"] = basefunc.handler(self, self.on_model_player_money_msg)

    self.lister["model_ready_finish_msg"] = basefunc.handler(self, self.ReadyFinish)
    self.lister["model_fish_wave"] = basefunc.handler(self, self.FishWaveEvent)
    self.lister["model_box_fish"] = basefunc.handler(self, self.onBoxFishEvent)

    self.lister["model_ice_skill_deblocking_msg"] = basefunc.handler(self, self.on_model_ice_skill_deblocking_msg)

    self.lister["model_time_skill_change_msg"] = basefunc.handler(self, self.on_model_time_skill_change_msg)

    self.lister["model_fish_dead"] = basefunc.handler(self, self.on_model_fish_dead)
    self.lister["model_fish_dead_laser"] = basefunc.handler(self, self.on_model_fish_dead_laser)
    self.lister["model_fish_dead_missile"] = basefunc.handler(self, self.on_model_fish_dead_missile)

    self.lister["AssetChange"] = basefunc.handler(self, self.onAssetChange)

    self.lister["model_fish_laser_rate_change"] = basefunc.handler(self, self.on_model_fish_laser_rate_change)
    self.lister["model_fish_missile_rate_change"] = basefunc.handler(self, self.on_model_fish_missile_rate_change)

    self.lister["ai_fsg_join_msg"] = basefunc.handler(self, self.on_fsg_join_msg)
    self.lister["ai_manual_shoot"] = basefunc.handler(self, self.ManualShoot)
    self.lister["ai_freed_skill"] = basefunc.handler(self, self.FreeSkill)
    self.lister["ai_change_gun_level"] = basefunc.handler(self, self.ChangeGunLevel)
    self.lister["ai_set_gun_level"] = basefunc.handler(self, self.SetGunLevel)

    self.lister["activity_set_gun_level"] = basefunc.handler(self, self.SetGunLevel)

    self.lister["ui_gold_fly_finish_msg"] = basefunc.handler(self, self.on_ui_gold_fly_finish_msg)
    self.lister["ui_play_laser_finish_msg"] = basefunc.handler(self, self.on_ui_play_laser_finish_msg)
    self.lister["ui_play_missile_finish_msg"] = basefunc.handler(self, self.on_ui_play_missile_finish_msg)
    self.lister["ui_missile_fly_finish_msg"] = basefunc.handler(self, self.on_ui_missile_fly_finish_msg)
    self.lister["ui_timeskill_fly_finish_msg"] = basefunc.handler(self, self.on_ui_timeskill_fly_finish_msg)

    self.lister["ui_zongzi_fly_finish_msg"] = basefunc.handler(self, self.on_ui_zongzi_fly_finish_msg)
    self.lister["ui_zh_fly_finish_msg"] = basefunc.handler(self, self.on_ui_zh_fly_finish_msg)

    self.lister["ui_shake_screen_msg"] = basefunc.handler(self, self.on_ui_shake_screen_msg)

    self.lister["UpdateFishingBagRedHint"] = basefunc.handler(self, self.UpdateFishingBagRedHint)
    self.lister["model_refresh_money"] = basefunc.handler(self, self.model_refresh_money)

    self.lister["model_refresh_player"] = basefunc.handler(self, self.RefreshPlayer)

    self.lister["ui_oper_manual_shoot_msg"] = basefunc.handler(self, self.on_ui_oper_manual_shoot)

    self.lister["model_event_summon_fish"] = basefunc.handler(self, self.on_event_summon_fish)
    self.lister["model_event_special_fish"] = basefunc.handler(self, self.on_event_special_fish)
    self.lister["model_event_small_boss"] = basefunc.handler(self, self.on_event_small_boss)
    self.lister["model_event_big_boss"] = basefunc.handler(self, self.on_event_big_boss)

    self.lister["ui_refresh_player_money"] = basefunc.handler(self, self.on_ui_refresh_player_money)
    self.lister["ui_bullet_scale_s2c"] = basefunc.handler(self, self.on_bullet_scale_s2c)

    self.lister["model_by_bag_gun_info_change"] = basefunc.handler(self, self.on_model_by_bag_gun_info_change)
    self.lister["model_gun_info_change"] = basefunc.handler(self, self.on_model_gun_info_change)

    self.lister["ui_play_scene_anim_msg"] = basefunc.handler(self, self.play_scene_anim)

    self.lister["sys_by_level_get_award_msg"] = basefunc.handler(self, self.sys_by_level_get_award_msg)
    self.lister["model_by3d_level_up_fx"] = basefunc.handler(self, self.model_by3d_level_up_fx) 

    self.lister["model_event_change_map"] = basefunc.handler(self, self.model_event_change_map) 

    self.lister["fishing_com_fly_jb_msg"] = basefunc.handler(self, self.fishing_com_fly_jb_msg)

    self.lister["close_finshing_guide_panel"] = basefunc.handler(self, self.on_close_finshing_guide_panel)

    self.lister["level_info_got"] = basefunc.handler(self,self.on_level_info_got)
end

function C:on_level_info_got()
    if _G["SYSBYLevelManager"] and FishingModel.game_id == 1 and SYSBYLevelManager.GetLevel() >= 5 and not self.is_top_xscyd then
        local userdata = FishingModel.GetPlayerData()
        userdata.is_auto = false
        userdata.auto_index = 1
        Event.Brocast("set_gun_auto_state", { seat_num=FishingModel.GetPlayerSeat() })

        self.is_top_xscyd = true
        HintPanel.Create(1, "恭喜您可去更高场次了！", function ()
            self.is_top_xscyd = false
            FishingLogic.quit_game()
        end)
    end
end
function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    if is_run_game_panel then
        DSM.PopAct()
        FishDeadManager.MyExit()
        FishingModel.StopUpdateFrame()
        is_run_game_panel = false
        self.update_time_log = "退出 开启"
        if self.game_btn_pre then
            self.game_btn_pre:MyExit()
            self.game_btn_pre = nil
        end
        if self.update_time then
            self.update_time:Stop()
        end
        for i=1, FishingModel.maxPlayerNumber do
            self.PlayerClass[i]:MyExit()
        end
        self:KillTween()
        self.Fishing3DFZ_HF:MyExit()
        
        self.update_time = nil
        FishManager.Exit()
        FishExtManager.Exit()
        VehicleManager.Exit()
        BulletManager.Exit()
        Fishing3DSceneAnim.Exit()
        self.nor_skill_prefab:MyExit()
        self.oper_prefab:MyExit()
        self:RemoveListener()
        CachePrefabManager.Back(self.by3d_cj)

        Event.Brocast("fishing_gameui_exit")
    end
end

local isPointDownOnUI = false
local isSkillReady = false
function C:Update()
    if is_run_game_panel and not FishingModel.IsRecoverRet then
    	-- 检测是否放在UI上
        local worldpos_up
        local seatno = FishingModel.GetPlayerSeat()
        if FishingModel.IsEDITOR then
            if UnityEngine.Input.GetMouseButtonDown(0) then
                if FishingModel.GetPlayerLaserState(seatno) == "ready" or
                FishingModel.GetPlayerMissileState(seatno) == "ready" then
                    isSkillReady = true
                else
                    isSkillReady = false
                end
            end
            if EventSystem.current:IsPointerOverGameObject() and UnityEngine.Input.GetMouseButtonDown(0) then
                isPointDownOnUI = true
                return
            end
            if UnityEngine.Input.GetMouseButtonUp(0) then
                worldpos_up = UnityEngine.Input.mousePosition
                if isPointDownOnUI then
                    isSkillReady = false
                end
            end

            if isPointDownOnUI and UnityEngine.Input.GetMouseButtonUp(0) then
                isPointDownOnUI = false
            end
        else
            if UnityEngine.Input.touchCount > 0 and UnityEngine.Input.GetTouch(0).phase == UnityEngine.TouchPhase.Began then
                if FishingModel.GetPlayerLaserState(seatno) == "ready" or
                FishingModel.GetPlayerMissileState(seatno) == "ready" then
                    isSkillReady = true
                else
                    isSkillReady = false
                end
            end
            if UnityEngine.Input.touchCount > 0 and EventSystem.current:IsPointerOverGameObject(UnityEngine.Input.GetTouch(0).fingerId) and UnityEngine.Input.GetTouch(0).phase == UnityEngine.TouchPhase.Began then
                isPointDownOnUI = true
                return
            end

            if UnityEngine.Input.touchCount > 0 and UnityEngine.Input.GetTouch(0).phase == UnityEngine.TouchPhase.Ended then
                worldpos_up = Vector3.New(UnityEngine.Input.GetTouch(0).position.x, UnityEngine.Input.GetTouch(0).position.y, 0)
                if isPointDownOnUI then
                    isSkillReady = false
                end
            end
            if isPointDownOnUI and UnityEngine.Input.touchCount > 0 and UnityEngine.Input.GetTouch(0).phase == UnityEngine.TouchPhase.Ended then
                isPointDownOnUI = false
            end
        end

        if isPointDownOnUI then
            return
        end

        local worldpos
        if UnityEngine.Input.GetMouseButton(0) then
            worldpos = UnityEngine.Input.mousePosition
        end

        if UnityEngine.Input.touchCount > 0 and UnityEngine.Input.GetTouch(0).phase == UnityEngine.TouchPhase.Moved then
            worldpos = Vector3.New(UnityEngine.Input.GetTouch(0).position.x, UnityEngine.Input.GetTouch(0).position.y, 0)
        end

        if isSkillReady and FishingModel.GetPlayerLaserState(seatno) == "ready" and worldpos_up then
            isSkillReady = false
            worldpos_up = self.camera2d:ScreenToWorldPoint(worldpos_up)
            self:GunSkillShoot({vec=worldpos_up, seat_num=seatno})
        elseif isSkillReady and FishingModel.GetPlayerMissileState(seatno) == "ready" and worldpos_up then
            isSkillReady = false
            worldpos_up = self.camera2d:ScreenToWorldPoint(worldpos_up)
            self:MissileShoot({vec=worldpos_up, seat_num=seatno})
        else
            if worldpos then
                worldpos = self.camera2d:ScreenToWorldPoint(worldpos)

                local user = FishingModel.GetPlayerData()
                if user and user.base and user.lock_state == "inuse" and not user.is_lock_gun then

                    -- 射线检测鱼
                    local hit = UnityEngine.Physics2D.Raycast(Vector2(worldpos.x, worldpos.y), Vector2.zero, 1000)

                    if hit.collider ~= nil then
                        local fish = FishManager.GetFishByID(tonumber(hit.collider.gameObject.name))
                        if fish then
                            if not fish.data.seat_num or fish.data.seat_num == FishingModel.data.seat_num then
                                FishingModel.SetLockFishID(FishingModel.data.seat_num, fish.data.fish_id)
                            else
                                LittleTips.Create("这条鱼不属于你@_@")
                            end
                        end
                    end
                else
                    self:ManualShoot({vec=worldpos, seatno=seatno})
                end
            end        
        end
    end
end
function C:on_ui_shake_screen_msg(t, fd)
    t = t or 1
    fd = fd or 0.3
    local bg_tran = self.by3d_cj.prefab.prefabObj.transform
    local seq = DoTweenSequence.Create()
    seq:Append(bg_tran:DOShakePosition(t, Vector3.New(fd, fd, 0), 20))
    seq:OnForceKill(function ()
        if IsEquals(bg_tran) then
            bg_tran.localPosition = Vector3.zero
        end
    end)
end

function C:UpdateFishingBagRedHint()
    local tt1 = PlayerPrefs.GetString(MainModel.RecentlyOpenBagTimeFishing, "0")
    local tt2 = PlayerPrefs.GetString(MainModel.RecentlyGetNewItemTimeFishing, "0")
    if tonumber(tt1) < tonumber(tt2) then
        --有新东西
        print("<color=green>捕鱼背包有新物品</color>")
    else
        print("<color=green>捕鱼背包没有新物品</color>")
    end
end

function C:model_refresh_money()
    local uipos = FishingModel.GetPlayerUIPos()
    self.PlayerClass[uipos]:RefreshMoney("fishing_model_msg")
end
function C:Awake()
	local tran = self.transform
	self.gameObject = self.transform.gameObject
    self.gameObject.name = "FishingGamePanel"
    ExtPanel.ExtMsg(self)
	self:MakeLister()
	self:AddMsgListener()
    LuaHelper.GeneratingVar(self.transform, self)

	-- 创建2DUI
	local ui2d = newObject("Fishing3DUI")
	self.Fishing2DUI_Obj = ui2d
	self.Fishing2DUI_Tran = ui2d.transform
	local tran_2D = ui2d.transform
    tran_2D.gameObject.name = "Fishing2DUI"
	self.fish_node_tran = self.Fishing2DUI_Tran:Find("FishNodeTran").transform
    self.fish_group_node_tran = self.Fishing2DUI_Tran:Find("FishGroupNodeTran").transform
    self.FishXZAnimTran = self.Fishing2DUI_Tran:Find("FishXZAnimTran").transform
    self.bullet_node_tran = self.Fishing2DUI_Tran:Find("BulletNodeTran").transform
	self.bullet_node_list = {}
    for i = 1, 4 do
        self.bullet_node_list[#self.bullet_node_list + 1] = self.Fishing2DUI_Tran:Find("BulletNodeTran/Node" .. i).transform
    end

	FishManager.Init(self.fish_node_tran, self.fish_group_node_tran)
    Fishing3DSceneAnim.Init(self.fish_node_tran, self.fish_group_node_tran)
    FishExtManager.Init()
	BulletManager.Init(self.bullet_node_list)
	self.camera2d = self.Fishing2DUI_Tran:Find("CatchFish2DCamera"):GetComponent("Camera")

	self.camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")
    FishingModel.SetCamera(self.camera2d, self.camera)

    self.LayerLv2 = tran:Find("FXNodeLayerLv2")
    self.LayerLv3 = GameObject.Find("Canvas/LayerLv3").transform

	self.isDown = false
    self.update_time_log = ""

    self.cj_node = self.Fishing2DUI_Tran:Find("cj_node")
    self.Bingdong = self.Fishing2DUI_Tran:Find("Bingdong"):GetComponent("SpriteRenderer")
    self.PlayerUI = {}
    self.PlayerUI2D = {}
    self.PlayerClass = {}
    for i=1, FishingModel.maxPlayerNumber do
    	self.PlayerUI[i] = tran:Find("UINode/Player"..i)
    	self.PlayerUI2D[i] = tran_2D:Find("Player"..i)
    end
    for i=1, FishingModel.maxPlayerNumber do
    	if FishingModel.IsRotationPlayer() then
	    	local i2d = FishingModel.maxPlayerNumber - i + 1
    		self.PlayerClass[i] = FishingPlayer.Create(self, i, self.PlayerUI[i], self.PlayerUI2D[i2d])
    	else
	    	self.PlayerClass[i] = FishingPlayer.Create(self, i, self.PlayerUI[i], self.PlayerUI2D[i])
    	end
	end

    self.DebugText = tran:Find("UINode/DebugText"):GetComponent("Text")
    self.DebugText.transform.localPosition = Vector3.zero
    self.DebugText.gameObject:SetActive(isDebug)
    
    self.FXNode = tran:Find("FXNode")
    self.FishNetNode = tran:Find("UINode/FishNetNode")
    self.SkillNode = tran:Find("UINode/SkillNode")
    self.FlyGoldNode = tran:Find("UINode/FlyGoldNode")
    self.OperNode = tran:Find("UINode/OperNode")
    self.ActFXNode = tran:Find("UINode/ActFXNode")
    

    self.LockHintImage = tran:Find("FXNode/LockHintImage")
    self.DotLine = tran:Find("FXNode/LockHintImage/DotLine")
    self.DotLineLayout = tran:Find("FXNode/LockHintImage/DotLine/DotLine"):GetComponent("HorizontalLayoutGroup")
    self.LockHintAnim = tran:Find("FXNode/LockHintImage/suoding"):GetComponent("Animator")

    self.update_time = Timer.New(function (_, time_elapsed)
        self:FrameUpdate(time_elapsed)
    end, FishingModel.Defines.FrameTime, -1, nil, true)

    FishDeadManager.Init(self)
    FishingSkillManager.SetPanelSelf(self)
    self.nor_skill_prefab = FishingNorSKillPrefab.Create(self.SkillNode, self)
    self.oper_prefab = FishingOperPrefab.Create(self.OperNode, self)
    FishingLoadingPanel.Create(function(  )
        Event.Brocast("fishing_guide_step")
        Event.Brocast("fishing_activity_begin")
    end, "by3d"..FishingModel.game_id)
    self:InitUI()
    is_run_game_panel = true

    if FishingModel.Config.fish_debug_map and
        FishingModel.Config.fish_debug_map.is_bullet_node_onoff and
        FishingModel.Config.fish_debug_map.is_bullet_node_onoff == 1 then
        self.bullet_node_tran.gameObject:SetActive(false)
    end
    if FishingModel.Config.fish_debug_map and
        FishingModel.Config.fish_debug_map.is_fish_node_onoff and
        FishingModel.Config.fish_debug_map.is_fish_node_onoff == 1 then
        self.fish_node_tran.gameObject:SetActive(false)
    end
    self.isHintYB = true

    if GetPrefab("Crit_time_fire") then
        self.wild_obj = newObject("Crit_time_fire", self.transform)
        self.wild_obj.gameObject:SetActive(false)
    end
    if GetPrefab("activity_bjsk_jinbi") then
        self.doubled_obj = newObject("activity_bjsk_jinbi", self.transform)
        self.doubled_obj.gameObject:SetActive(false)
    end
    local btn_map = {}
    btn_map["down"] = {self.ACTNode1, self.ACTNode2,self.ACTNode3,self.ACTNode4,self.ACTNode5}
    btn_map["down2"] = {self.ACTNode11, self.ACTNode12,self.ACTNode13,self.ACTNode14,self.ACTNode15}
    btn_map["top"] = {self.ACTTopNode}
    btn_map["top2"] = {self.ACTCenterNode}
    btn_map["Right_top"] = {self.JsEnterNode2,self.JsEnterNode1}
    btn_map["Right_down"] = {self.rd_node2,self.rd_node1}
    btn_map["Right_down2"] = {self.rd_node4,self.rd_node3}
    btn_map["Right_shtx"] = {self.rm_node1}--深海探险专用节点
    btn_map["Right_hd"] = {self.rm_node2,self.rm_node2_1}--核弹,龙王争霸专用节点
    btn_map["Right_boss"] = {self.rt_node1}--boss来了专用节点
    self.game_btn_pre = GameButtonPanel.Create(btn_map, "fishing3d_game")
-----------------左侧收纳按钮相关----------------------
    self:CheckLeftRed()
    self.left_node_is_on = true
    self.on_img.gameObject:SetActive(self.left_node_is_on)
    self.off_img.gameObject:SetActive(not self.left_node_is_on)
    self.left_node_btn.onClick:AddListener(function()
        PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."fishing3dgamepanel_left_node",1)
        self:CheckLeftRed()
        if self.left_node_is_on then
            self.left_node_is_on = false
            self:Left_off_tween()
            Event.Brocast("fishing3dgamepanel_left_ndoe_btn_off_msg")
        else
            self.left_node_is_on = true
            self:Left_on_tween()
        end
        self.on_img.gameObject:SetActive(self.left_node_is_on)
        self.off_img.gameObject:SetActive(not self.left_node_is_on)
    end)
----------------左侧收纳按钮相关----------------------------
    self.Fishing3DFZ_HF = Fishing3DFZ_HF.Create()

    self:RefreshCJ()
    self:UpdateFishingBagRedHint()
end
function C:Start()
end
function C:InitUI()
    self:TestAddJoinAI(  )
end

function C:GetTSPath(uipos)
    local pos = {}
    for i = 1, 3 do
        local path = 20000 + (uipos-1) * 3 + i
        local cfg = FishingModel.ts_steer_map[path]
        pos[#pos + 1] = FishingModel.Get2DToUIPoint(Vector3.New(cfg.posX, cfg.posY, 0))
    end
    return pos
end
function C:GetTSPathNode(path_id, fish_id)
    if fish_id == 36 then
        return self.ts_fish_path_node[1]
    else
        return self.fish_group_node_tran
    end
end
function C:InitTSPath()
    -- 初始化一些特殊路径
    -- 贝壳路径
    print("<color=red>初始化一些特殊路径</color>")
    self.ts_fish_path_node = {}
    self.ts_fish_path_node[#self.ts_fish_path_node + 1] = self.Fishing2DUI_Tran:Find("FishGroupNodeTran/ts_fish_path_node1").transform

    self.pathnode_list = {}
    local path_pos = {{x=-2,y=1.2}, {x=0,y=2.2}, {x=2,y=1.2}}
    for i = 1, FishingModel.maxPlayerNumber do
        local pathnode = self.PlayerClass[i].transform_2D:Find("TSPath/TSPath")
        self.pathnode_list[#self.pathnode_list + 1] = pathnode
    end

    path_pos = {{x=-2,y=1.2}, {x=-0.8,y=2.2}, {x=0.8,y=1.2}, {x=2,y=1.2}}
    FishingModel.ts_steer_map = {}
    local path_id = 10001
    for i = 1, FishingModel.maxPlayerNumber do
        for j = 1, 4 do
            local steer = {}
            self.pathnode_list[i].localPosition = Vector3.New(path_pos[j].x, path_pos[j].y, 0)
            steer.posX = self.pathnode_list[i].position.x
            steer.posY = self.pathnode_list[i].position.y
            steer.headX = 0
            steer.headY = 1
            steer.id = path_id
            steer.steer = {}
            local stelist = {}
            steer.steer[#steer.steer + 1] = stelist
            stelist[1] = {}
            stelist[1].id = 3
            stelist[1].line = 3
            stelist[1].type = 3
            stelist[1].waitTime = 600

            -- 增加路径一条
            FishingModel.ts_steer_map[path_id] = steer
            path_id = path_id + 1
        end
    end

    -- 11001 11002 11003 11004
    if self.cur_scene_id == 5 then
        path_id = 11001
        for j = 1, 4 do
            local steer = {}
            local pathnode = self.by3d_cj_tran:Find("path" .. j)
            steer.posX = pathnode.position.x
            steer.posY = pathnode.position.y
            steer.headX = 0
            steer.headY = 1
            steer.id = path_id
            steer.steer = {}
            local stelist = {}
            steer.steer[#steer.steer + 1] = stelist
            stelist[1] = {}
            stelist[1].id = 3
            stelist[1].line = 3
            stelist[1].type = 3
            stelist[1].waitTime = 15

            -- 增加路径一条
            FishingModel.ts_steer_map[path_id] = steer
            path_id = path_id + 1
        end
    end

    local path_pos = {{x=-2,y=1.2}, {x=0,y=2.2}, {x=2,y=1.2}}
    path_id = 20001
    for i = 1, FishingModel.maxPlayerNumber do
        for j = 1, 3 do
            local steer = {}
            self.pathnode_list[i].localPosition = Vector3.New(path_pos[j].x, path_pos[j].y, 0)
            steer.posX = self.pathnode_list[i].position.x
            steer.posY = self.pathnode_list[i].position.y
            steer.headX = 0
            steer.headY = 1
            steer.id = path_id
            steer.steer = {}
            local stelist = {}
            steer.steer[#steer.steer + 1] = stelist
            stelist[1] = {}
            stelist[1].id = 3
            stelist[1].line = 3
            stelist[1].type = 3
            stelist[1].waitTime = 600

            -- 增加路径一条
            FishingModel.ts_steer_map[path_id] = steer
            path_id = path_id + 1
        end
    end

    dump(FishingModel.ts_steer_map)
end

-- 重置
function C:ResetUI()
    if self.update_time then
        self.update_time:Stop()
    end
    if self.flee_time then
        self.flee_time:Stop()
    end
end
function C:MyRefresh()
    self:RefreshIce()
    self:RefreshPlayer()
    self.nor_skill_prefab:MyRefresh()
    self.oper_prefab:MyRefresh()
end
function C:RefreshCJ()
    if not FishingModel.GetSceneID() or (self.cur_scene_id and self.cur_scene_id == FishingModel.GetSceneID()) then
        dump(self.cur_scene_id, "<color=red>EEEE self.cur_scene_id</color>")
        return
    end

    local width = Screen.width
    local height = Screen.height
    if width / height < 1 then
        width,height = height,width
    end

    CachePrefabManager.Back(self.by3d_cj)
    self.cur_scene_id = FishingModel.GetSceneID()
    -- 场景
    if self.cur_scene_id == 1 then
        self.by3d_cj = CachePrefabManager.Take("fish3d_cj1")
    elseif self.cur_scene_id == 2 then
        self.by3d_cj = CachePrefabManager.Take("fish3d_cj2")
    elseif self.cur_scene_id == 3 then
        self.by3d_cj = CachePrefabManager.Take("fish3d_cj3")
    elseif self.cur_scene_id == 4 then
        self.by3d_cj = CachePrefabManager.Take("fish3d_cj4")
    else
        self.by3d_cj = CachePrefabManager.Take("fish3d_cj5")
        self.by3d_cj_anim = self.by3d_cj.prefab.prefabObj.transform:GetComponent("Animator")
    end
    self.by3d_cj.prefab:SetParent(self.cj_node)
    
    local bg_tran = self.by3d_cj.prefab.prefabObj.transform
    self.by3d_cj_tran = self.by3d_cj.prefab.prefabObj.transform
    self.boss_fx_node = bg_tran:Find("boss_fx_node")
    self.not_boss_fx_node = bg_tran:Find("not_boss_fx_node")
    bg_tran.localScale = Vector3.New(1.25, 1.25, 1)

    dump(self.cur_scene_id, "<color=red>EEEE self.cur_scene_id</color>")
    
    if self.cur_scene_id == 5 then
        self.ts_fish_root = {}
        path_id = 11001
        for j = 1, 4 do
            local pathnode = self.by3d_cj_tran:Find("path" .. j)
            self.ts_fish_root[path_id] = pathnode.transform
            path_id = path_id + 1
        end
        dump(self.ts_fish_root, "<color=red>EEEE self.ts_fish_root</color>")
    end
end
function C:PrintDebug()
end

function C:play_scene_anim(anim)
    if IsEquals(self.by3d_cj_anim) then
        if anim == "anim3" then
            self.by3d_cj_anim:Play(anim, -1, 0)
        else
            if FishingModel.data.image_type_index == 3 then
                if IsEquals(self.by3d_cj_anim) then
                    self.by3d_cj_anim:Play("anim2", -1, 0)
                end
            else
                if IsEquals(self.by3d_cj_anim) then
                    self.by3d_cj_anim:Play("anim1", -1, 0)
                end
            end
        end
    end
end

-- 断线重连完成
function C:ReadyFinish()
    self:MyRefresh()

    self:RefreshTimeSkill()

    self.last_update_time_clock = nil
    self.update_time_log = "断线重连完成 开启"
    self.update_time:Start()
    self:RefreshCJ()
    if FishingModel.data.image_type_index == 3 then
        ExtendSoundManager.PlaySceneBGM(audio_config.by3d.bgm_by_bossgame.audio_name)
    else
        FishingModel.PlaySceneBGM()
    end

    local userdata = FishingModel.GetPlayerData()
    if self.isHintYB then
        if userdata and userdata.base and userdata.base.fish_coin > 0 then
            -- HintYBPrefab.Create(self)
            self.isHintYB = false
        end
    end

    if IsEquals(self.Fishing3D_hwlx_bg) then
        destroy(self.Fishing3D_hwlx_bg)
        self.Fishing3D_hwlx_bg = nil
    end
    if FishingModel.data.image_type_index == 3 then
        if IsEquals(self.boss_fx_node) then
            self.boss_fx_node.gameObject:SetActive(true)
        end
        if IsEquals(self.not_boss_fx_node) then
            self.not_boss_fx_node.gameObject:SetActive(false)
        end
        if IsEquals(self.by3d_cj_anim) then
            self.by3d_cj_anim:Play("anim2", -1, 0)
        end
        FishingAnimManager.PlayBossFenwei("big", self.transform, nil, false)
    else
        if IsEquals(self.boss_fx_node) then
            self.boss_fx_node.gameObject:SetActive(false)
        end
        if IsEquals(self.not_boss_fx_node) then
            self.not_boss_fx_node.gameObject:SetActive(true)
        end
        if IsEquals(self.by3d_cj_anim) then
            self.by3d_cj_anim:Play("anim1", -1, 0)
        end
        FishingAnimManager.PlayBossFenwei("big", self.transform, nil, true)
    end
    
    Event.Brocast("fishing_activity_begin")
    Event.Brocast("fishing_ready_finish")
    if not self.is_one_guide then
        self.is_one_guide = true
        GuideLogic.CheckRunGuide("by3d")
    end
    if MainModel.UserInfo.xsyd_status ~= -1 and FishingModel and FishingModel.game_id == 1 then
    else
        --Event.Brocast("open_sys_act_base")
    end
end
function C:on_background_msg()
    if self.update_time then
        self.update_time:Stop()
        -- self.update_time = nil
        self.update_time_log = "切入后台 关闭"
        -- self.back_time = os.time()
    end
end
function C:on_backgroundReturn_msg()
    -- local ct = os.time() - self.back_time
    -- while (true) do
    --     if ct >= FishingModel.Defines.FrameTime then
    --         self:FrameUpdate(FishingModel.Defines.FrameTime)
    --         ct = ct - FishingModel.Defines.FrameTime
    --     else
    --         self:FrameUpdate(ct)
    --         break
    --     end
    -- end
    self.update_time_log = "进入前台 开启"
    -- self.update_time = Timer.New(function ()
    --     self:FrameUpdate(FishingModel.Defines.FrameTime)
    -- end, FishingModel.Defines.FrameTime, -1,false,true)
    -- self.update_time:Start()
end
-- 刷新玩家
function C:RefreshPlayer()
    for i=1, FishingModel.maxPlayerNumber do
        self.PlayerClass[i]:MyRefresh()
    end
    self:RefreshCJ()
end
-- 刷新冰冻
function C:RefreshIce()
    local ice_state = FishingModel.GetSceneIceState()
    if ice_state == "inuse" then
        FishManager.SetIceState(true)
        self.Bingdong.gameObject:SetActive(true)
    else
        FishManager.SetIceState(false)
        self.Bingdong.gameObject:SetActive(false)
    end
end

function C:RefreshTimeSkill(skill_type)
    local userdata = FishingModel.GetPlayerData()
    if not userdata or not userdata.base then
        return
    end

    if skill_type then
        if skill_type == "accelerate" then
            local uipos = FishingModel.GetSeatnoToPos(userdata.base.seat_num)
            if userdata.accelerate_state == "inuse" then
                self.PlayerClass[uipos]:SetAutoCoefficient(1.5)
            else
                self.PlayerClass[uipos]:SetAutoCoefficient(1)
            end
        end
        if (skill_type == "wild" or skill_type == "doubled") and IsEquals(self[skill_type .. "_obj"]) then
            if userdata[skill_type .. "_state"] == "inuse" then
                self[skill_type .. "_obj"].gameObject:SetActive(true)
            else
                self[skill_type .. "_obj"].gameObject:SetActive(false)
            end
        end
    else
        local ll = {"accelerate", "wild", "doubled"}
        for k,v in ipairs(ll) do
            self:RefreshTimeSkill(v)
        end
    end
end

function C:FrameUpdate(time_elapsed)
    if is_use_sys_clock then
        if self.last_update_time_clock then
            time_elapsed = os.clock() - self.last_update_time_clock
            self.last_update_time_clock = os.clock()
        end
    end
    if isDebug then
        local nn = FishManager.GetFishNum()
        self.all_fish_num = self.all_fish_num or 0
        self.all_fish_tt = self.all_fish_tt or 0
        self.all_fish_tt = self.all_fish_tt + time_elapsed
        self.all_fish_tt_oo = self.all_fish_tt_oo or 1
        if self.all_fish_tt > self.all_fish_tt_oo then
            self.all_fish_num = self.all_fish_num + nn
            self.pj_fish_num = self.all_fish_num / self.all_fish_tt
            self.all_fish_tt_oo = self.all_fish_tt_oo + 1
        end
        self.pj_fish_num = self.pj_fish_num or nn
        self.DebugText.text = nn .. "\n" .. self.pj_fish_num

    end
    -- 防止除0
    if time_elapsed < 0.000001 then
        time_elapsed = 0.000001
    end
    FishingModel.UpdateSkillCD(time_elapsed)

    local ice_state = FishingModel.GetSceneIceState()
    if ice_state == "inuse" then
        local a,b = FishingModel.GetSceneIceTime()
        if a and b then
            self.Bingdong.color = Color.New(1, 1, 1, a/b * 0.7 + 0.3)
        end
    else
        VehicleManager.FrameUpdate(time_elapsed)
    end

    FishManager.FrameUpdate(time_elapsed)
    BulletManager.FrameUpdate(time_elapsed)

    for i=1, FishingModel.maxPlayerNumber do
        self.PlayerClass[i]:FrameUpdate(time_elapsed)
    end
    self.nor_skill_prefab:FrameUpdate(time_elapsed)
    self.oper_prefab:FrameUpdate(time_elapsed)
end

function C:onBoxFishEvent()
    -- FishingAnimManager.PlayWaveHint(self.FXNode, false, "by_imgf_bxycll")
end

-- 鱼儿逃离 2秒逃离完成
function C:FishWaveEvent()
    if IsEquals(self.boss_fx_node) then
        self.boss_fx_node.gameObject:SetActive(false)
    end
    if IsEquals(self.not_boss_fx_node) then
        self.not_boss_fx_node.gameObject:SetActive(true)
    end
    if IsEquals(self.by3d_cj_anim) then
        self.by3d_cj_anim:Play("anim1", -1, 0)
    end
    FishingAnimManager.PlayBossFenwei("big", self.transform, nil, true)

    if FishingModel.data.game_id >= 1 and FishingModel.data.game_id <= 5 then
        self:RunFishWave()
    else
    end

    VehicleManager.PlayFlee(FishingModel.data.clear_level)
    FishManager.PlayFlee(FishingModel.data.clear_level)
end

function C:RunFishWave()
    if FishingModel.IsRecoverRet then
        return
    end
    
    local boss_type = FishingModel.GetBossType()
    if boss_type ~= 0 then
        ExtendSoundManager.PauseSceneBGM()
        FishingAnimManager.PlayBY3D_BSYC(self.LayerLv2, function ()
            if boss_type == 3 then
                local seq = DoTweenSequence.Create()
                seq:AppendInterval(3)
                seq:OnKill(function ()
                    ExtendSoundManager.PlaySceneBGM(audio_config.by3d.bgm_by_bossgame.audio_name)                
                end)
            else
                ExtendSoundManager.PlaySceneBGM(audio_config.by3d.bgm_by_bossgame.audio_name)
            end

            if IsEquals(self.boss_fx_node) then
                self.boss_fx_node.gameObject:SetActive(true)
            end
            if IsEquals(self.not_boss_fx_node) then
                self.not_boss_fx_node.gameObject:SetActive(false)
            end
            if IsEquals(self.by3d_cj_anim) then
                self.by3d_cj_anim:Play("anim2", -1, 0)
            end

            FishingAnimManager.PlayBossFenwei("big", self.transform, nil, false)
            Event.Brocast("ui_boss_wave_msg")
        end)

        FishingAnimManager.PlaySwitchoverMap(self.FlyGoldNode)
        ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_yuchao.audio_name)
    else
        if FishingModel.data.fish_map_id % 2 == 0 then
            -- FishingAnimManager.PlayWaveHint(self.LayerLv2, false, "by_imgf_ycll")
            FishingAnimManager.PlaySwitchoverMap(self.FlyGoldNode, function ()
                FishingModel.PlaySceneBGM()
            end)
        else
            -- FishingAnimManager.PlayWaveHint(self.LayerLv2, false, "by_imgf_ycjs")
            FishingAnimManager.PlaySwitchoverMap(self.FlyGoldNode, function ()
                FishingModel.PlaySceneBGM()
            end)
        end
        ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_yuchao.audio_name)
    end
end

-- 发射子弹
function C:ManualShoot(data)
    -- 激光场
    if FishingModel.game_id == 8 then
        self.jb_laser_cd = self.jb_laser_cd or {}
        if self.jb_laser_cd[data.seatno] and self.jb_laser_cd[data.seatno] > os.time() then
            return
        end
        if data.seatno == FishingModel.GetPlayerSeat() then
            local uipos = FishingModel.GetSeatnoToPos(data.seatno)
            if not self.PlayerClass[uipos].not_one_open_gun then
                -- 首次开抢后移除提示效果
                if IsEquals(self.PlayerClass[uipos].HintGuide) then
                    self.PlayerClass[uipos].HintGuide.gameObject:SetActive(false)
                end
                self.PlayerClass[uipos].not_one_open_gun = true
            end
        end

        self.jb_laser_cd[data.seatno] = os.time() + 2.6
        Event.Brocast("model_use_skill_msg", {msg_type="jb_laser", seat_num=data.seatno, vec=data.vec})
    else
        local uipos = FishingModel.GetSeatnoToPos(data.seatno)
        self.PlayerClass[uipos]:ManualShoot(data.vec)
    end
end

function C:on_ui_oper_manual_shoot(pram)
    local uipos = FishingModel.GetSeatnoToPos(pram.seat_num)
    self.PlayerClass[uipos]:ForceShoot(pram)
    if uipos == 1 then
        self.PlayerClass[uipos].FSZT_btn.gameObject:SetActive(false)
        -- self.PlayerClass[uipos].ZT.gameObject:SetActive(false)
        Event.Brocast("ui_player_change_zt", {seat_num = pram.seat_num, is_cj_or_sc = false})
        self.LockHintImage.gameObject:SetActive(false)
    end
end

-- 事件
-- 召唤
function C:on_event_summon_fish(data)
    local cfg = FishingModel.Config.steer_map[data.path]
    local pos = {x=cfg.posX, y=cfg.posY, z=0}
    FishingAnimManager.PlaySummonFishFX(self.fish_node_tran, pos)
end
-- 特殊鱼
function C:on_event_special_fish(data)
    FishingAnimManager.PlaySpecialFishFX(self.FlyGoldNode, data)
end
-- 小boss鱼
function C:on_event_small_boss(data)
    dump(data, "<color=red>小boss鱼</color>")
    ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_xiaobosschuchang.audio_name)
    ExtendSoundManager.PlaySceneBGM(audio_config.by3d.bgm_by_xiaobossgame.audio_name)
    FishingAnimManager.PlayBossFenwei("small", self.transform, nil, false)
    FishingAnimManager.PlaySmallBossFX(self.FlyGoldNode, data)
end
-- 大boss鱼
function C:on_event_big_boss(data)
    dump(data, "<color=red>大boss鱼</color>")
    ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_bosschuchang.audio_name)
    FishingAnimManager.PlayBigBossFX(self.FlyGoldNode)
end

-- 使用炮台(枪)技能
function C:GunSkillShoot(data)
    dump(data, "<color=red><size=20>EEEE  使用炮台(枪)技能 </size></color>")
    data.msg_type = "gun_skill"
    Event.Brocast("model_use_skill_msg", data)
end

-- 使用激光技能
function C:LaserShoot(data)
    data.msg_type = "laser"
    Event.Brocast("model_use_skill_msg", data)
end
-- 使用核弹技能
function C:MissileShoot(data)
    data.msg_type = "missile"
    Event.Brocast("model_use_skill_msg", data)
end

function C:FreeSkill(data)
    if data.msg_type == "gun_skill" then
        self:GunSkillShoot(data)
        return
    end

    if data.msg_type == "drill" or data.msg_type == "dcp" then
        Event.Brocast("ui_oper_fashe_msg", data)
        return
    end
	FishingModel.SendSkill(data)
end

function C:ChangeGunLevel(data)
    if data then
        if data.is_up then
            self.PlayerClass[data.seat_num]:OnUpGunLevel()
        else
            self.PlayerClass[data.seat_num]:OnDownGunLevel()
        end
    end
end

function C:on_model_by_bag_gun_info_change(gun_id, bed_id)
    local seat_num = FishingModel.GetPlayerSeat()

    FishingModel.SetGunSkinID(seat_num, gun_id)
    FishingModel.SetBedSkinID(seat_num, bed_id)

    self.oper_prefab:SetLaserHide()
    FishingModel.SetPlayerLaserState(seat_num, "nor")
end

function C:on_model_gun_info_change(seat_num)
    local uipos = FishingModel.GetSeatnoToPos(seat_num)
    self.PlayerClass[uipos]:RefreshGun()
end

function C:SetGunLevel(data)
    dump(data, "<color=yellow>活动的数据。>>>>>></color>")
    if data and data.seat_num and data.bullet_index and self.PlayerClass[data.seat_num] then
        self.PlayerClass[data.seat_num]:SetGunLevel(data.bullet_index)
    end
end
function C:on_ui_refresh_player_money(seat_num)
    seat_num = seat_num or 1
    self.PlayerClass[seat_num]:RefreshMoney()
end
function C:on_bullet_scale_s2c(seat_num, cha)
    local user = FishingModel.GetSeatnoToUser(seat_num)
    if user and user.base then
        user.base.score = user.base.score + cha
        self:on_ui_refresh_player_money(seat_num)
    end
end
function C:Shoot(data)
    local uipos = FishingModel.GetSeatnoToPos(data.seat_num)

    local pos = self.PlayerClass[uipos]:GetBulletPos()
    local dirVec = {x = data.x, y = data.y}
    local r = Vec2DAngle(dirVec)
    local rr = r - 90
    data.angle = rr
    data.pos = pos

    local userdata = FishingModel.GetSeatnoToUser(data.seat_num)
    local gun_config = FishingModel.GetGunCfg(userdata.index)
    if not FishingActivityManager.CheckHaveBullet(data.seat_num) then

        local gun_rate = gun_config.gun_rate
        local bullet_rate_coefficient = 1 -- 倍率系数
        if data.type == FishingModel.BulletType.skill_power_bullet
            or data.type == FishingModel.BulletType.skill_crit_bullet then
                bullet_rate_coefficient = 2
        end
        gun_rate = gun_rate * bullet_rate_coefficient

        FishingModel.AddMoneyLog(data.seat_num, "开抢=(" .. gun_rate .. ")")
        if userdata.base.fish_coin >= gun_rate then
            userdata.base.fish_coin = userdata.base.fish_coin - gun_rate
        else
            userdata.base.score = userdata.base.score - gun_rate + userdata.base.fish_coin
            userdata.wait_dec_score = userdata.wait_dec_score + gun_rate - userdata.base.fish_coin
            userdata.base.fish_coin = 0
        end
    end
    self.PlayerClass[uipos]:RunShoot(data)
    self.PlayerClass[uipos]:RefreshMoney()
end

function C:GetTimeSkillPos(skill_type)
    return self.nor_skill_prefab[skill_type .. "_btn"].transform.position
end

function C:GetLockPos()
    return self.nor_skill_prefab.lock_btn.transform.position
end
function C:GetIcePos()
    return self.nor_skill_prefab.ice_btn.transform.position
end
function C:GetZHPos()
    return self.nor_skill_prefab.zh_btn.transform.position
end

function C:GetPlayerPos(seat_num)
    local uipos = FishingModel.GetSeatnoToPos(seat_num)
    local pos = self.PlayerClass[uipos]:GetPlayerFXPos()
    return pos
end

-- *******************************
-- model的广播消息
-- *******************************
-- 冰冻解封
function C:on_model_ice_skill_deblocking_msg()
    FishManager.SetIceDeblocking()
end

function C:on_model_time_skill_change_msg(seat_num, skill_type, is_lose)
    local userdata = FishingModel.GetSeatnoToUser(seat_num)
    local uipos = FishingModel.GetSeatnoToPos(seat_num)
    local my_seat_num = FishingModel.GetPlayerSeat()
    
    if not is_lose then
        if skill_type == "lock" then
            self.PlayerClass[uipos]:RefreshLock()
            if userdata.lock_state ~= "inuse" then
                FishingModel.RemoveLockFishID(seat_num)
            end
        end
        if skill_type == "frozen" then
            if FishingModel.data.scene_frozen_state == "inuse" then
                ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_bingfeng.audio_name)
                FishManager.SetIceState(true)
                self.Bingdong.gameObject:SetActive(true)
                FishingAnimManager.PlayFrozen(self.FXNode)
                self.PlayerClass[uipos]:SetIce(true)
            else
                FishManager.SetIceState(false)
                self.Bingdong.gameObject:SetActive(false)
                self.PlayerClass[uipos]:SetIce(false)
            end
        end
        if skill_type == "accelerate" then
            if userdata[skill_type .. "_state"] == "inuse" then
                GameComAnimTool.PlayShowAndHideAndCall(self.transform, "activity_zdjs", Vector3.zero, 2.16)
            end
            self.PlayerClass[uipos]:RefreshTimeSkill(skill_type)
            self:RefreshTimeSkill(skill_type)
        end
        if skill_type == "wild" and seat_num == my_seat_num then
            if userdata[skill_type .. "_state"] == "inuse" then
                GameComAnimTool.PlayShowAndHideAndCall(self.transform, "activity_wlsk", Vector3.zero, 1.8)
            end
            self:RefreshTimeSkill(skill_type)
        end
        if skill_type == "doubled" and seat_num == my_seat_num then
            if userdata[skill_type .. "_state"] == "inuse" then
                GameComAnimTool.PlayShowAndHideAndCall(self.transform, "activity_bjsk", Vector3.zero, 1.8)
            end
            self:RefreshTimeSkill(skill_type)
        end
    end
end

function C:on_model_player_PC(seat_num)
    local uipos = FishingModel.GetSeatnoToPos(seat_num)
    self.PlayerClass[uipos]:SetPC()
end

-- 子弹碰撞
function C:on_model_bullet_boom(data)
    local bullet =  BulletManager.GetIDToBullet(data.id)
    if bullet then
        if bullet.bulletSpr.type == 5 then
            local pos = FishingModel.Get2DToUIPoint(bullet.bulletSpr.transform.position)
            FishingAnimManager.PlayFishNet_ZT(self.FishNetNode.transform, data, bullet.bulletSpr.transform.localEulerAngles.z, pos, data.status)
        else
            FishingAnimManager.PlayFishNet(self.FishNetNode.transform, data)
        end
        -- 只有自己的子弹碰到鱼才播受击
        if bullet.seat_num == FishingModel.data.seat_num then
            FishManager.PlayFishSuffer(data.fish_list)
        end
    end
end
-- 玩家加入
function C:on_fsg_join_msg(seatno)
    local uipos = FishingModel.GetSeatnoToPos(seatno)
    self.PlayerClass[uipos]:SetPlayerEnter()
    if not FishingModel.isChangeAI then
        FishingPlayerAIManager.AddPlayer(seatno,self.PlayerClass[uipos])
    end
end
-- 玩家离开
function C:on_fsg_leave_msg(seatno)
    local uipos = FishingModel.GetSeatnoToPos(seatno)
    self.PlayerClass[uipos]:SetPlayerExit()
    if not FishingModel.isChangeAI then
        FishingPlayerAIManager.RemovePlayer(seatno)
    end
end
function C:on_model_player_money_msg(data)
    local uipos = FishingModel.GetSeatnoToPos(data.seat_num)
    if uipos then
    	self.PlayerClass[uipos]:RefreshMoney(data.change_type)
    	self.nor_skill_prefab:RefreshAssets()
    end
end
-- 金币飞行完成
function C:on_ui_gold_fly_finish_msg(data)
    local uipos = FishingModel.GetSeatnoToPos(data.seat_num)
    self.PlayerClass[uipos]:AddMoneyNumber(data.score, data.fish_id, data.fish_ids)
end
-- 粽子飞行完成
function C:on_ui_zongzi_fly_finish_msg(seat_num, score)
    local my_seat_num = FishingModel.GetPlayerSeat()
    if my_seat_num == seat_num then
        local uipos = FishingModel.GetSeatnoToPos(seat_num)
        FishingAnimManager.PlayAddZongzi(seat_num, score, self.FlyGoldNode, self.PlayerClass[uipos]:GetPlayerFXPos())
    end
end

-- 激光播放完成
function C:on_ui_play_laser_finish_msg(seat_num)
    FishingModel.SetPlayerLaserState(seat_num, "nor")
    Event.Brocast("ui_laser_state_change", seat_num)
end
-- 核弹播放完成
function C:on_ui_play_missile_finish_msg(seat_num)
    FishingModel.SetPlayerMissileState(seat_num, "nor")
end
-- 核弹碎片飞行完成
function C:on_ui_missile_fly_finish_msg(seat_num, v)
    local my_seat_num = FishingModel.GetPlayerSeat()
    local userdata = FishingModel.GetSeatnoToUser(seat_num)
    if userdata and userdata.base then
        userdata.missile_index = userdata.missile_index + 1
        userdata.missile_list[userdata.missile_index] = v
    end
    if my_seat_num == seat_num then
        self.nor_skill_prefab:UpdateMissileState()
    end
end

-- 时间道具飞行完成
function C:on_ui_timeskill_fly_finish_msg(seat_num, v, skill_type)
    local my_seat_num = FishingModel.GetPlayerSeat()
    local userdata = FishingModel.GetSeatnoToUser(seat_num)
    if userdata and userdata.base then
        userdata["prop_fish_" .. skill_type] = userdata["prop_fish_" .. skill_type] + v
    end
    if my_seat_num == seat_num then
        self.nor_skill_prefab:RefreshTimeSkill(skill_type)
    end
end

-- 召唤道具飞行完成
function C:on_ui_zh_fly_finish_msg(seat_num, v)
    local my_seat_num = FishingModel.GetPlayerSeat()
    if my_seat_num == seat_num then
        self.nor_skill_prefab:RefreshMF()
    end
end

-- 子弹弄死的鱼
function C:on_model_fish_dead(data)
    FishDeadManager.on_model_fish_dead(data, self.FXNode)
end
-- 激光弄死的鱼
function C:on_model_fish_dead_laser(data)
    FishDeadManager.on_model_fish_dead_laser(data, self.FXNode)
end
-- 核弹弄死的鱼
function C:on_model_fish_dead_missile(data)
    FishDeadManager.on_model_fish_dead_missile(data, self.FXNode)
end
-- 激光进度改变
function C:on_model_fish_laser_rate_change(seat_num)
    local uipos = FishingModel.GetSeatnoToPos(seat_num)
    self.PlayerClass[uipos]:RefreshJG(true)
end

-- 核弹进度改变
function C:on_model_fish_missile_rate_change(seat_num)
    local my_seat_num = FishingModel.GetPlayerSeat()
    if my_seat_num == seat_num then
        self.nor_skill_prefab:UpdateMissileState()
    end
end

--加入机器人
local add_ai_num = 1
function C:TestAddJoinAI(  )
    self.add_ai_btn = self.transform:Find("UINode/@add_ai_btn"):GetComponent("Button")
    self.add_ai_btn.gameObject:SetActive(false)
    self.add_ai_btn.onClick:AddListener(function ()
        -- local v = {}
        -- v.type = 10
        -- v.types = {10,2,2,2,2}
        -- v.time = FishingModel.data.system_time - FishingModel.data.begin_time
        -- v.path = 7
        -- v.rate = 100
        -- v.fish_id = 8883
        -- FishManager.AddFishTeam(v)

        local v = {}
        v.types = {1,1,1,1,1}
        v.ids = {8883,8884,8885,8886,8887}
        v.time = FishingModel.data.system_time - FishingModel.data.begin_time
        v.time = v.time * 10
        v.path = 6
        v.rate = 100
        v.group_id = 1000
        FishManager.AddFishGroup(v)
    end)
end

function C:onAssetChange(data)
    for k,v in ipairs(data.data) do
        if v.asset_type =="jing_bi" or v.asset_type=="fish_coin" then
            self:CheckIsShowGuidFuc()
            return
        end
    end
end
local isOpenGuidPanel=false
function C:on_close_finshing_guide_panel()
    isOpenGuidPanel=false
end
function C:CheckIsShowGuidFuc()
    if isOpenGuidPanel then
        return
    end
    if SYSByPmsManager and SYSByPmsManager.IsMatching() then
        return
    end
    local game_id= FishingModel.game_id
    if game_id>1 then
		local maxCanGoGameID=game_id
        maxCanGoGameID=GameFishing3DManager.GetTJGameIDbyJB()
		if maxCanGoGameID>game_id then
			local lastCloseTime=	PlayerPrefs.GetString("hall_guide"..MainModel.UserInfo.user_id,"0")
			if (os.time()-1200)>tonumber(lastCloseTime) then
				local bossFishIDMap={47,48,49}
				local bossFishId=bossFishIDMap[maxCanGoGameID-2]
				local bossInfo=GameFishing3DManager.GetFishInfoByID(bossFishId)
				-- dump(bossInfo,"boss鱼数据：  ")
                isOpenGuidPanel=true
				Fishing3DHallGuideSessionPanel.Create(bossFishId,bossInfo,maxCanGoGameID)
				return
			end
		end
	end
end
function C.GetPlayerInstance(seatno)
    if instance then
        if not seatno then
            seatno = FishingModel.GetPlayerSeat()
        end
        local uipos = FishingModel.GetSeatnoToPos(seatno)
        return instance.PlayerClass[uipos]
    end
end

function C:GetSkillNode()
    return self.oper_prefab:GetSkillNode()
end

function C:sys_by_level_get_award_msg(data)
    local uipos = FishingModel.GetPlayerUIPos()
    local endPos = self.PlayerClass[uipos]:GetFlyGoldPos()
    FishingAnimManager.PlayPTSJ_JB(self.LayerLv2, data.pos, endPos, data)
end

-- score pos
function C:fishing_com_fly_jb_msg(data)
    local uipos = FishingModel.GetPlayerUIPos()
    local seat_num = FishingModel.GetPlayerSeat()
    local player_cls = self.PlayerClass[uipos]
    local endPos = player_cls:GetFlyGoldPos()
    FishingAnimManager.PlayTYJBFly(self.LayerLv2, data.pos, endPos, data, function ()
        local beginPos = player_cls.AddMoneyRect.transform.position
        FishingAnimManager.PlayGoldUpMove(player_cls.AddMoneyRect.transform, beginPos, data.score, seat_num)
    end)
end

function C:model_by3d_level_up_fx()
    local uipos = FishingModel.GetPlayerUIPos()
    local beginPos = self.PlayerClass[uipos]:GetPlayerFXPos()
    GameComAnimTool.PlayShowAndHideAndCall(self.LayerLv2, "Fishing3D_gun_shengji", beginPos+Vector3.New(0, -70, 0), 1)
end

function C:model_event_change_map()
    self:RunFishWave()
    self:RefreshCJ()
    self:InitTSPath()
end
function C:Left_off_tween()
    self:KillTween()
    self.left_seq = DoTweenSequence.Create()
    self.left_seq:Append(self.celan.transform:DOLocalMoveX(-900,0.25))
end

function C:Left_on_tween()
    self:KillTween()
    self.left_seq = DoTweenSequence.Create()
    self.left_seq:Append(self.celan.transform:DOLocalMoveX(0,0.25))
end

function C:KillTween()
    if self.left_seq then
        self.left_seq:Kill()
        self.left_seq = nil
    end
end

--初次左边的收纳按钮需要加一个红点提示
function C:CheckLeftRed()
    if PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."fishing3dgamepanel_left_node",0) == 0 then
        self.red.gameObject:SetActive(true)
    else
        self.red.gameObject:SetActive(false)
    end
end
