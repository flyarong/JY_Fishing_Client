-- 创建时间:2019-03-26
-- 玩家操作面板

local basefunc = require "Game.Common.basefunc"

FishingOperPrefab = basefunc.class()

local C = FishingOperPrefab

C.name = "FishingOperPrefab"

function C.Create(tran, panelSelf)
	return C.New(tran, panelSelf)
end
function C:FrameUpdate()
end
function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ui_laser_state_change"] = basefunc.handler(self, self.ui_laser_state_change)
    self.lister["SYSByPms_enter_scene"] = basefunc.handler(self,self.SYSByPms_enter_scene)
    self.lister["model_gun_info_change"] = basefunc.handler(self,self.on_model_gun_info_change)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:ctor(tran, panelSelf)
	self.panelSelf = panelSelf
	self.gameObject = tran.gameObject
	self.transform = tran

	self:MakeLister()
    self:AddMsgListener()
    LuaHelper.GeneratingVar(tran, self)

    self.back_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnBackClick()
    end)
    self.pms_exit_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        SYSByPmsGameExitPanel.Create()
    end)
    self.set_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        GameManager.GotoUI({gotoui = "sys_setting",goto_scene_parm = "panel"})
    end)
    self.open_oper_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnOpenOperClick()
    end)
    self.help_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnWikeClick()
    end)
    self.shop_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        PayPanel.Create(GOODS_TYPE.jing_bi)
    end)
    self.task_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        GameButtonManager.GotoUI({gotoui = "sys_active_daily_task", goto_scene_parm="panel"})
    end)
    self.bag_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        GameManager.GotoUI({gotoui = "sys_by_bag",goto_scene_parm = "panel", type="paotai"})
    end)
    self.jg_skill_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnJGClick()
    end)
    self.TopButtonImage = self.transform:Find("OperRight/@oper_rect/TopButtonImage"):GetComponent("MyButton")
    EventTriggerListener.Get(self.TopButtonImage.gameObject).onClick = basefunc.handler(self, self.SetHideMenu)
    self.back_img = self.back_btn.transform:GetComponent("Image")
    self.is_matching = false
    self:MyRefresh() 
end
function C:MyRefresh()
    self.task_btn.gameObject:SetActive(false)
    if GameGlobalOnOff.InternalTest then
        self.shop_btn.gameObject:SetActive(false)
    end
	self:SetOpenOper(false)
    self:RefreshJG()

    if FishingModel.game_id == 8 then
        self.jg_node.gameObject:SetActive(false)
    end
end

function C:MyExit()
	self:RemoveListener()
end
function C:SetHideMenu()
    self:SetOpenOper(false)
end
function C:SetOpenOper(b)
    self.oper_rect.gameObject:SetActive(b)
    self.open_oper_jt1.gameObject:SetActive(b)
    self.open_oper_jt2.gameObject:SetActive(not b)
end
function C:OnOpenOperClick()
    local b = not self.oper_rect.gameObject.activeSelf
    self:SetOpenOper(b)
end

function C:OnBackClick()
    local call = function ()
        if SYS_Exit_AskManager and SYS_Exit_AskManager.CheckIsShow() then
            Event.Brocast("sys_exit_ask_open_msg",function ()
                FishingLogic.quit_game()
            end)
            return
        end
        FishingLogic.quit_game()
    end
    local a,b = GameButtonManager.RunFun({gotoui="by3d_kpshb", call=call}, "QuiteCreate")
    if not a then
        call()
    end

   -- FishingLogic.quit_game()
end

function C:OnWikeClick()
    Fishing3DBKPanel.Create()
end

function C:GetSkillNode()
    if self.oper_rect.gameObject.activeSelf then
        return self.bag_btn.transform.position
    else
        return self.open_oper_btn.transform.position
    end
end

function C:close_jg_sound()
    if self.jg_xl_audio then
        soundMgr:CloseLoopSound(self.jg_xl_audio)
        self.jg_xl_audio = nil
    end
end
function C:SetLaserHide()
    self:close_jg_sound()
    self:CloseJGXL()
end
function C:CloseJGXL()
    self.jg_fx_yan.gameObject:SetActive(false)
    if IsEquals(self.jg_xl_fx) then
        CachePrefabManager.Back(self.jg_xl_fx)
    end
end

function C:CreateJGXL()
    local userdata = FishingModel.GetPlayerData()
    local uipos = FishingModel.GetSeatnoToPos(userdata.base.seat_num)
    local gunP = self.panelSelf.PlayerClass[uipos]:GetBulletPos()
    local pos = FishingModel.Get2DToUIPoint(gunP)

    self.jg_xl_fx = CachePrefabManager.Take("jiguang_attack_node_1")
    self.jg_xl_fx.prefab:SetParent(self.panelSelf.FXNode)
    local tran = self.jg_xl_fx.prefab.prefabObj.transform
    tran.position = pos
    tran.rotation = self.panelSelf.PlayerClass[uipos]:GetGunRotation()
end
function C:OnJGClick()
    local jgdata = self:GetJGData()
    if jgdata.num > 0 then
        if FishingModel.GetPlayerLaserState(FishingModel.GetPlayerSeat()) == "nor" then
            local gun_id = FishingModel.GetGunSkinID(FishingModel.GetPlayerSeat())
            local cfg = FishingModel.Config.gun_skill_map[gun_id]
            dump(cfg)
            if cfg.id ~= 1 and cfg.id ~= 4 then -- 除 激光 死灵之光  其他 直接使用
                local data = {}
                data.seat_num = FishingModel.GetPlayerSeat()
                data.msg_type = "gun_skill"
                data.vec = {x=1, y=1}
                Event.Brocast("model_use_skill_msg", data)
            else            
                FishingModel.SetPlayerLaserState(FishingModel.GetPlayerSeat(), "ready")
                self.jg_fx_yan.gameObject:SetActive(true)
                self:close_jg_sound()
                self.jg_xl_audio = ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_jiguang1.audio_name, -1)
                self:CloseJGXL()
                self:CreateJGXL()
            end
        elseif FishingModel.GetPlayerLaserState(FishingModel.GetPlayerSeat()) == "ready" then
            FishingModel.SetPlayerLaserState(FishingModel.GetPlayerSeat(), "nor")
            self.jg_fx_yan.gameObject:SetActive(false)
            self:close_jg_sound()
            self:CloseJGXL()
        end
    else
        LittleTips.Create("能量要蓄满才能使用哦！")
    end
end
function C:GetJGData()
    local userdata = FishingModel.GetPlayerData()
    if userdata and userdata.base then
        local cur = userdata.laser_rate or 0
        local max = FishingModel.GetGunSkinPower(userdata.base.seat_num, userdata.index)
        local val = cur / max
        local nn = math.floor(val)
        if val > 1 then
            val = 1
        end
        return {jd=val, num=nn}
    end
    return {jd=0, num=0}
end
function C:RefreshJG()
    local jgdata = self:GetJGData()
    self.jg_num_txt.text = jgdata.num
    self.jg_rate_img.fillAmount = jgdata.jd

    self.jg_fx_yan.gameObject:SetActive(false)

    if jgdata.num > 0 and FishingModel.GetPlayerLaserState(FishingModel.GetPlayerSeat()) == "ready" then
        self.jg_fx_yan.gameObject:SetActive(true)
    end
end
function C:ui_laser_state_change(seat_num)
    if seat_num == FishingModel.GetPlayerSeat() then
        if FishingModel.GetPlayerLaserState(seat_num) == "inuse" then
            return
        end
        self:CloseJGXL()
        self:RefreshJG()
    end
end


function C:SYSByPms_enter_scene(b)
    --self.open_oper_btn.gameObject:SetActive(b)
    -- 是否关闭跳转
    FishingModel.data.is_close_goto = not b

    self.pms_exit_btn.gameObject:SetActive(not b)
    self.back_btn.gameObject:SetActive(b)
end

function C:on_model_gun_info_change(seat_num)
    if seat_num == FishingModel.GetPlayerSeat() then
        local gun_id = FishingModel.GetGunSkinID(seat_num)
        dump(gun_id,"炮台id:  ")
        dump(FishingModel.Config.gun_skill_map,"gun_skill_map: ")
        local cfg = FishingModel.Config.gun_skill_map[gun_id]
        self.jg_skill_img.sprite = GetTexture(cfg.icon)
        self:RefreshJG()
    end
end