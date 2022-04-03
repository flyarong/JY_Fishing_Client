-- 创建时间:2020-06-08

local basefunc = require "Game.Common.basefunc"
FishingActivityXY = basefunc.class()

local M = FishingActivityXY
M.name = "FishingActivityXY"
local Manager = FishingActivityManager

function M:ctor(data, config)
    if not data.msg_type or not data.seat_num then return end
    --检查配置，可能没有，根据具体活动决定
    if not config then
    	dump(data, "<color=red>EEE 检查配置</color>")
    	return
    end
    self.data = data
    self.config = config

    self.parent = GameObject.Find("Canvas/LayerLv2")
    self.gameObject = newObject(M.name, self.parent.transform)
    self.transform = self.gameObject.transform
    LuaHelper.GeneratingVar(self.transform, self)

    local status = M.CheckActivityStatus(self.data)
    if status == FISHING_ACTIVITY_STATUS_ENUM.begin then
        self:ActBegin()
    elseif status == FISHING_ACTIVITY_STATUS_ENUM.running then
        self:Refresh(data)
    end
end

function M:Exit(data)
    self.data = self.data or data
    dump(self.data, "<color=red>OOOOOOOOOOOO FishingActivityXY Exit</color>")
    dump(self.org_gun_cfg)
    self:RecoverGame()

    local pp = FishingLogic.GetPanel()
    local uipos = FishingModel.GetSeatnoToPos(self.data.seat_num)
    local playerPos = pp.PlayerClass[uipos]:GetPlayerFXPos()
    local cfg = FishingModel.Config.fish_map[31]
    local parm = {dead_guang = cfg.dead_guang, reward_image = cfg.reward_image, icon = cfg.icon}
    FishingAnimManager.PlayBY3D_HDY_FX(pp.LayerLv3, playerPos, playerPos, self.data.score, nil, self.data.seat_num, nil, parm)

    if IsEquals(self.act_obj) then
	    destroy(self.act_obj)
    end
    destroy(self.gameObject)
end

function M:ActBegin()
    local ani_kill_callback = function ()
        if not self.data then return end
        local sd = basefunc.deepcopy(self.data)
        sd.status = 1
        FishingModel.SendActivity(sd)

        self:ActIng() -- 可以不执行
    end

    if not self.data.speed then
        ani_kill_callback()
    else
        local beginPos
        local fish = FishManager.GetFishByID(self.data.speed)
        if fish then
            beginPos = FishingModel.Get2DToUIPoint(fish:GetPos())
        else
            beginPos = Vector3.zero
        end

        local pp = FishingLogic.GetPanel()
	    local gun_pos = pp.PlayerClass[self.data.seat_num]:GetLaserFXPos()
	    local pos = FishingModel.Get2DToUIPoint(gun_pos)
	    dump(pos, "<color=red>pos </color>")
        local endPos = pos

        local seq = DoTweenSequence.Create()
        seq:AppendInterval(1.5)
        seq:OnKill(function ()
            FishingAnimManager.PlayMoveAndHideFX(self.transform, "Fishing3D_qiangjixie", beginPos, endPos, 2, 1, function ()
                ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_zuantoudan1.audio_name)
    			Event.Brocast("ui_shake_screen_msg", 1, 0.3)
                FishingAnimManager.PlayBY3D_AZDCP(self.transform, endPos)
                ani_kill_callback()
            end, nil)
        end)
    end
end
function M:ActIng()
    if not IsEquals(self.act_obj) then
        self.act_obj = GameObject.Instantiate(GetPrefab("act_qjx_prefab"), self.root)
        LuaHelper.GeneratingVar(self.act_obj.transform, self)

        local pp = FishingLogic.GetPanel()
        local gun_pos = pp.PlayerClass[self.data.seat_num]:GetLaserFXPos()
        local pos = FishingModel.Get2DToUIPoint(gun_pos)
        self.act_obj.transform.position = pos
    end

	self:RefreshButtleTxt()
	self:RefreshMoneyTxt()
    self:ChangeGame()
end

function M:Refresh(data)
    self.data = data
    self:ActIng()
end

-- 刷新总钱数
function M:RefreshMoneyTxt()
	dump(self.data, "<color=red>RefreshMoneyTxt </color>")

    if IsEquals(self.all_gold_txt) then
		local mm = self.data.score or 0
        self.all_gold_txt.text = string.format( "%s", mm)
    else
    	self.all_gold_txt.text = "0"
    end
end
-- 刷新子弹剩余数
function M:RefreshButtleTxt()
    self.bullet_txt.text = string.format( "x%s", self.data.num)
    if self.data.num > 0 then
        self.act_obj.gameObject:SetActive(true)
    else
        self.act_obj.gameObject:SetActive(false)
        Event.Brocast("activity_over_msg", self.data)
    end
end
-- 改变游戏，退出的时候一定要恢复
function M:ChangeGame()
    if not self.data then return end
    if self.data.seat_num == FishingModel.GetPlayerSeat() then
        local pan = FishingLogic.GetPanel()
        local uipos = FishingModel.GetSeatnoToPos(FishingModel.GetPlayerSeat())
        local p_pre = pan.PlayerClass[uipos]
        if IsEquals(p_pre.AddButtonImage) then
            p_pre.AddButtonImage.gameObject:SetActive(false)
        end
        if IsEquals(p_pre.SubButtonImage) then
            p_pre.SubButtonImage.gameObject:SetActive(false)
        end
    end

    if self.data.num and self.data.num > 0 and self.data.status == 1 then
        -- 修改枪炮
        local userdata = FishingModel.GetSeatnoToUser(self.data.seat_num)
        local n_g = FishingModel.GetGunSkinCfg(self.data.seat_num, userdata.index)
        if n_g.gunprefab ~= "GunPrefab13" then
            self.org_gun_cfg = {}
            self.org_gun_cfg.gunprefab = n_g.gunprefab
            n_g.gunprefab = "GunPrefab13"

            Event.Brocast("model_gun_info_change", self.data.seat_num)
        end
    end
end

-- 还原游戏
function M:RecoverGame()
    -- 捕鱼比赛不显示加减按钮
    if MainModel.myLocation == "game_FishingMatch" then
        return
    end
    if self.data and self.data.seat_num == FishingModel.GetPlayerSeat() then
        local pan = FishingLogic.GetPanel()
        local uipos = FishingModel.GetSeatnoToPos(FishingModel.GetPlayerSeat())
        local p_pre = pan.PlayerClass[uipos]
        if IsEquals(p_pre.AddButtonImage) then
            p_pre.AddButtonImage.gameObject:SetActive(true)
    	end
        if IsEquals(p_pre.SubButtonImage) then
            p_pre.SubButtonImage.gameObject:SetActive(true)
        end
    end

    if self.org_gun_cfg then
        -- 还原枪炮
        local userdata = FishingModel.GetSeatnoToUser(self.data.seat_num)
        local n_g = FishingModel.GetGunSkinCfg(self.data.seat_num, userdata.index)
        n_g.gunprefab = self.org_gun_cfg.gunprefab
        Event.Brocast("model_gun_info_change", self.data.seat_num)
    end

end

------------------------------------------外部使用数据
function M:GetDropAwardRate()
    if not self.data then return nil end
    if not self:CheckIsRunning() then return nil end
    return self.data.rate    
end

function M:CheckIsGanChangeGun(  )
    if not self.config then return nil end
    if not self:CheckIsRunning() then return nil end
    return self.config.change_gun
end

function M:GetBulletType(  )
    if not self.config or not self.data then return nil end
    if not self:CheckIsRunning() then return nil end
    if self.data.num <= 0 then return nil end
    return self.config.bullet_type
end

function M:GetFishNetType(  )
    if not self.config or not self.data then return nil end
    if not self:CheckIsRunning() then return nil end
    if self.data.num <= 0 then return nil end
    return self.config.net_type
end

function M:activity_get_gold(data)
    if not self:CheckIsRunning() then return nil end
    if data and data.seat_num == self.data.seat_num and data.score then
        self.data.score = self.data.score or 0
        self.data.score = self.data.score + data.score
        self:RefreshMoneyTxt()
    end
end

function M:activity_kill_fish(data)
    if not self:CheckIsRunning() then return nil end
    -- dump(data, "<color=green>activity_kill_fish</color>")
end

function M:activity_shoot(data)
    if not self:CheckIsRunning() then return nil end
    -- dump(data, "<color=green>activity_shoot</color>")
    if self.data and self.data.num and self.data.num > 0 then
        self.data.num = self.data.num - 1
        self:RefreshButtleTxt()
    end
end

function M:activity_fish_gun_rotation(data)
    -- dump(data, "<color=green>activity_fish_gun_rotation</color>")
end

function M.CheckIsActivityTime(data)
    if not data then return false end
    if data and data.num then
        return data.num > 0
    end
    return false
end

function M.CheckActivityStatus(data)
    if not data then return false end
    local function check_time(_data)
        if _data.status == 0 then
            return FISHING_ACTIVITY_STATUS_ENUM.begin
        elseif _data.status == 1 then
            return FISHING_ACTIVITY_STATUS_ENUM.running
        end
        return FISHING_ACTIVITY_STATUS_ENUM.over
    end
    if data and data.status then
        return check_time(data)
    end
    return FISHING_ACTIVITY_STATUS_ENUM.over
end

function M:CheckHaveBullet()
    if self.data and self.data.msg_type == FISHING_ACTIVITY_ENUM.free_bullet then
        if self.data.status == 1 then
            if self.data.num then
        return self.data.num > 0
            end
        end
    end
    return false
end

function M:CheckIsRunning()
    if self.data and self.data.status and self.data.status == 1 then
        return true
    end
    return false
end
--　子弹的碰撞次数
function M:GetBulletCrash()
    if self.data and self.data.status and self.data.status == 1 then
        return self.data.speed
    end
end

