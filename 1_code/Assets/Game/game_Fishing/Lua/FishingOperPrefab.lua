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
    self.lister["ui_auto_change"] = basefunc.handler(self, self.on_ui_auto_change)
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

    self.OperRect = tran:Find("OperRight/OperRect")
    self.OpenOperButton = tran:Find("OperRight/OpenOperButton"):GetComponent("Button")
    self.OpenOperJT1 = tran:Find("OperRight/OpenOperButton/Image1")
    self.OpenOperJT2 = tran:Find("OperRight/OpenOperButton/Image2")
    self.BackButton = tran:Find("OperRight/OperRect/BackButton"):GetComponent("Button")
    self.SetButton = tran:Find("OperRight/OperRect/SetButton"):GetComponent("Button")
    self.WikiButton = tran:Find("OperRight/OperRect/WikiButton"):GetComponent("Button")
    self.ShopButton = tran:Find("OperRight/OperRect/ShopButton"):GetComponent("Button")
    self.AutoBGImage = tran:Find("AutoRect/AutoBGImage")
    self.AutoYesButton = tran:Find("AutoRect/AutoYesButton"):GetComponent("Button")
    self.AutoNoButton = tran:Find("AutoRect/AutoNoButton"):GetComponent("Button")
    self.AutoScaleButton = tran:Find("AutoRect/AutoScaleButton"):GetComponent("Button")
    self.AutoScaleText = tran:Find("AutoRect/AutoScaleButton/AutoScaleText"):GetComponent("Text")
    self.BackButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnBackClick()
    end)
    self.SetButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        GameManager.GotoUI({gotoui = "sys_setting",goto_scene_parm = "panel"})
    end)
    self.OpenOperButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnOpenOperClick()
    end)
    self.WikiButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnWikeClick()
    end)
    self.ShopButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        PayPanel.Create(GOODS_TYPE.jing_bi)
    end)
    self.AutoNoButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnAutoClick(false)
    end)
    self.AutoYesButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnAutoClick(true)
    end)
    self.AutoScaleButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnAutoScaleClick()
    end)

    self:MyRefresh() 
end
function C:MyRefresh()
	self:SetOpenOper(false)
    self.AutoScaleButton.gameObject:SetActive(false)
    self.AutoYesButton.gameObject:SetActive(true)
    self.AutoNoButton.gameObject:SetActive(false)
    self.AutoBGImage.gameObject:SetActive(false)
end

function C:MyExit()
	self:RemoveListener()
end

function C:SetOpenOper(b)
    self.OperRect.gameObject:SetActive(b)
    self.OpenOperJT1.gameObject:SetActive(b)
    self.OpenOperJT2.gameObject:SetActive(not b)
end
function C:OnOpenOperClick()
    local b = not self.OperRect.gameObject.activeSelf
    self:SetOpenOper(b)
end

function C:OnBackClick()
    local call = function ()
        FishingLogic.quit_game()
    end

    local a,b = GameButtonManager.RunFun({gotoui="by3d_kpshb", call=call}, "QuiteCreate")
    if not a then
        if _G["FishingXRHBManager"] then
            local tash_data = FishingXRHBManager.GetTaskDataByGameID(FishingModel.data.game_id)
            local cfg = FishingXRHBManager.GetCfgByGameID(FishingModel.data.game_id)
            dump(tash_data, "<color=red>当前处于捕鱼新人红包中，完成即可领取红包</color>")
            if FishingXRHBManager.is_show(tash_data) then
                local desc = ""
                if tash_data.now_process >= tash_data.need_process then
                    desc = "当前处于捕鱼新人红包中，完成即可领取红包\n确定要退出吗？"
                else
                    local userdata = FishingModel.GetPlayerData()
                    local gun_config = FishingModel.GetGunCfg(userdata.index)
                    local g_num = math.ceil( (tash_data.need_process - tash_data.now_process) / gun_config.gun_rate )
                    desc = "当前炮倍再发射<color=#F18611FF>" .. StringHelper.ToCash(g_num) .. "发</color>即可领取\n<color=#F18611FF>" .. cfg.red_val .. "福利券</color>\n确定要退出吗？"
                end
                local pre = HintPanel.Create(5, desc, function ()
                    FishingLogic.quit_game()
                end)
                pre:SetButtonText("继续退出", "继续领红包")
                return
            end
        end
        FishingLogic.quit_game()
    end
end

function C:OnWikeClick()
    FishingBKPanel.New()
end

function C:OnAutoClick(is_auto)
    --潮流捕鱼中捕鱼的自动开炮功能增加vip1限制，vip1及以上开启自动开炮功能
    local cheak_func = function ()
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="clby_fish_auto",}, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    end
    if not cheak_func() then 
        return
    end 
    local userdata = FishingModel.GetPlayerData()
    local uipos = FishingModel.GetSeatnoToPos(userdata.base.seat_num)
    if is_auto then
        userdata.is_auto = true
        userdata.auto_index = 1
    else
        userdata.is_auto = false
        userdata.auto_index = 1
    end
    self:on_ui_auto_change()
end
function C:OnAutoScaleClick()
    local userdata = FishingModel.GetPlayerData()
    local uipos = FishingModel.GetSeatnoToPos(userdata.base.seat_num)
    userdata.auto_index = userdata.auto_index + 1
    if userdata.auto_index > #FishingModel.Defines.auto_bullet_speed then
        userdata.auto_index = 1
    end
    local v = FishingModel.Defines.auto_bullet_speed[userdata.auto_index]
    self.AutoScaleText.text = "x" .. v

    self:SetAutoCoefficient(v)
end

function C:SetAutoCoefficient(v)
    local userdata = FishingModel.GetPlayerData()
    local uipos = FishingModel.GetSeatnoToPos(userdata.base.seat_num)
    self.panelSelf.PlayerClass[uipos]:SetAutoCoefficient(v)
end

function C:on_ui_auto_change()
    local userdata = FishingModel.GetPlayerData()
    local uipos = FishingModel.GetSeatnoToPos(userdata.base.seat_num)
    if userdata.is_auto then
        local v = FishingModel.Defines.auto_bullet_speed[userdata.auto_index]
        self.AutoScaleText.text = "x" .. v
        self.AutoScaleButton.gameObject:SetActive(true)
        self.AutoYesButton.gameObject:SetActive(false)
        self.AutoNoButton.gameObject:SetActive(true)
        self.AutoBGImage.gameObject:SetActive(true)

        self.panelSelf.PlayerClass[uipos]:SetAuto(true)
    else
        self.AutoScaleButton.gameObject:SetActive(false)
        self.AutoYesButton.gameObject:SetActive(true)
        self.AutoNoButton.gameObject:SetActive(false)
        self.AutoBGImage.gameObject:SetActive(false)

        self.panelSelf.PlayerClass[uipos]:SetAuto(false)
    end
end