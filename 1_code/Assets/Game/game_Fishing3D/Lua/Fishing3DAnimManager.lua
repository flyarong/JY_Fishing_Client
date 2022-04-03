-- 创建时间:2019-03-19
-- 复制了一份3D捕鱼动画

FishingAnimManager = {}

local function anim_close_ui_tab(ui)
	if not table_is_null(ui) then
		for k,v in pairs(ui) do
			ui[k] = nil
		end
	end
end

local rate_on_off = false --倍率开关
local function GetColorByRate(rate)
	if rate == 1 then
		return Color.cyan
	elseif rate == 2 then
		return Color.green
	elseif rate == 3 then
		return Color.yellow
	elseif rate == 4 then
		return Color.red
	end
	return Color.red
end

function FishingAnimManager.PlayFishNet(parent, data)
	FishNetPrefab.Create(parent, data)
end

function FishingAnimManager.PlayShootFX(parent, data)
	local prefab = CachePrefabManager.Take("paokou")
	prefab.prefab:SetParent(parent)
    prefab.prefab.prefabObj.transform.localPosition = Vector3.zero
    prefab.prefab.prefabObj.transform.localRotation = Quaternion.Euler(0, 0, 0)

    local seq = DoTweenSequence.Create()
    seq:AppendInterval(0.2)
    seq:OnForceKill(
        function()
            CachePrefabManager.Back(prefab)
        end)
end

function FishingAnimManager.TweenDelay(period, update_callback, final_callback, force_callback)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(period):OnUpdate(function()
		if update_callback then update_callback() end
	end)
	seq:OnKill(function()
		if final_callback then final_callback() end
	end)
	seq:OnForceKill(function (force_kill)
		if force_callback then
			force_callback(force_kill)
		end
	end)
end

function FishingAnimManager.PlayLinesFX(parent, data, speedTime, keepTime, lineName, pointName, is_hide_one)
	local pointCount = #data
	if pointCount <= 0 then
		return
	end
	ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_shandianyu.audio_name)

	speedTime = speedTime or 1
	keepTime = keepTime or 1
	local lineName_list = {"Fishing3D_sd_Line_01", "Fishing3D_sd_Line_02", "Fishing3D_sd_Line_03"}
	pointName = pointName or "Fishing3D_sd_sj_01"
	sj_pointName = sj_pointName or "Fishing3D_sd_sj_02"

	FishingAnimManager.PlayShowAndHideFX(parent, "Fishing3D_sd_fashe", data[1], 2.3)

	local function play_line(pos1, pos2)
		local lineName = lineName_list[math.random(1, 3)]
		local line = CachePrefabManager.Take(lineName)
		line.prefab:SetParent(parent)
		local tran = line.prefab.prefabObj.transform
		local line_read = tran:GetComponent("LineRenderer")
		line_read.positionCount = 2
		line_read:SetPosition(0, pos1)
		line_read:SetPosition(1, pos2)
		-- line_read.startWidth = 60
		-- line_read.endWidth = 20

		local seq = DoTweenSequence.Create()
		seq:AppendInterval(2)
		seq:OnKill(function ()
		end)
		seq:OnForceKill(function ()
			CachePrefabManager.Back(line)
		end)

		FishingAnimManager.PlayShowAndHideFX_CallTime(parent, sj_pointName, pos2, 0.3, nil, function ()
			FishingAnimManager.PlayShowAndHideFX(parent, pointName, pos2, 2, nil)
		end, 0.1)
	end


	local beginPos = data[1]
	for i = 2, #data do
		play_line(beginPos, data[i])
	end
end

function FishingAnimManager.TestPlayLinesFX(parent)
	local fishTbl = {}

	local allFish = FishManager.GetAllFish()

	local WorldDimensionUnit = FishingModel.Defines.WorldDimensionUnit
	local pos = nil
	for k, v in pairs(allFish) do
		pos = v.transform.position
		if pos.x < WorldDimensionUnit.xMax and pos.x > WorldDimensionUnit.xMin and pos.y < WorldDimensionUnit.yMax and pos.y > WorldDimensionUnit.yMin then
			local idx = #fishTbl
			if idx > 0 then
				local fish = FishManager.GetFishByID(fishTbl[idx])
				local offset = fish:GetPos() - pos
				if Vector3.SqrMagnitude(offset) > 10 and math.random(0, 100) > 50 then
					fishTbl[idx + 1] = v.data.fish_id
				end
			else
				fishTbl[idx + 1] = v.data.fish_id
			end

			if #fishTbl >= 3 then break end
		end
	end

	FishingAnimManager.PlayLinesFX(parent, fishTbl, 0.1, 2)
end

-- 开始点 结束点
local function CreateGold(parent, beginPos, endPos, delay, call, prefab_name)
	local zz = 100
	local _beginPos = Vector3.New(beginPos.x, beginPos.y, zz)
	local _endPos = Vector3.New(endPos.x, endPos.y, zz)
	prefab_name = prefab_name
	local prefab = CachePrefabManager.Take(prefab_name)
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = _beginPos
	tran.localScale = Vector3.New(1, 1, 1)

	local seq = DoTweenSequence.Create()
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
		if prefab then
			CachePrefabManager.Back(prefab)
		end
	end)
end
local function CreateNumGold_New(seat_num, parent, beginPos , endPos, score, delay, call, style)
	local prefab = CachePrefabManager.Take("NumGlod3DPrefab")
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = beginPos
	tran.localScale = Vector3.one
	local gold_txt = tran:Find("gold_txt"):GetComponent("Text")
	gold_txt.font = FishingAnimManager.GetFontBySeatNum(seat_num)
	gold_txt.text = score

	style = 3 -- 改为同一表现
	local seq = DoTweenSequence.Create()
	if style == 1 then
		seq:AppendInterval(1.2)
	elseif style == 2 then
		seq:Append(tran:DOScale(3, 0.2))
		seq:Append(tran:DOScale(1.5, 0.2))
		seq:AppendInterval(0.8)
	else
		seq:Append(tran:DOScale(2.5, 0.2))
		seq:Append(tran:DOScale(1, 0.15))
		seq:Append(tran:DOScale(2, 0.1))
		seq:Append(tran:DOScale(1.2, 0.1))
		seq:AppendInterval(0.65)
	end
	seq:AppendCallback(function ()
		CachePrefabManager.Back(prefab)
		prefab = nil
	end)
	if delay and delay > 0.00001 then		
		seq:AppendInterval(delay)
	end
	seq:OnKill(function ()
		if call then
			call()
		end
	end)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)
		prefab = nil
	end)
end
-- 开始点 结束点
local function CreateNumGold(seat_num, parent, beginPos , endPos, score, a_rate, delay, call, rate, is_move, style)
	local prefab = CachePrefabManager.Take("NumGlod3DPrefab")
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = beginPos
	local gold_txt = tran:Find("gold_txt"):GetComponent("Text")
	if style and style == "match"  then
		gold_txt.font = GetFont("by_tx6")
	else
		gold_txt.font = FishingAnimManager.GetFontBySeatNum(seat_num)
	end
	gold_txt.text = score
	if rate_on_off and a_rate then
		local rate_img = tran:Find("gold_txt/rate_img"):GetComponent("Image")
		rate_img.sprite = GetTexture("by_imgf_bj" .. (a_rate - 1))
		rate_img.gameObject:SetActive(true)
	end
	local scale = 1
	tran.localScale = Vector3.New(scale, scale, 1)

	local HH = 35
	local seq = DoTweenSequence.Create()
	if not delay then delay = 0 end
	delay = delay + 0.15
	if delay > 0.00001 then		
		seq:AppendInterval(delay)
	end
	seq:Append(tran:DOMove(Vector3.New(beginPos.x, beginPos.y + HH, 0), 0.8))
	if is_move then
		local len = math.sqrt( (beginPos.x - endPos.x) * (beginPos.x - endPos.x) + (beginPos.y - endPos.y) * (beginPos.y - endPos.y) )
		local t = len / 1200
		local h = math.random(100, 200)
		seq:Append(tran:DOMoveBezier(endPos, h, t))
	end
	seq:OnKill(function ()
		if call then
			call()
		end
	end)
	seq:OnForceKill(function ()
		if prefab then
			local rate_img = tran:Find("gold_txt/rate_img"):GetComponent("Image")
			rate_img.gameObject:SetActive(false)
			CachePrefabManager.Back(prefab)
		end		
	end)
	return prefab
end

-- 座位号 钱 特效节点 开始点 结束点 倍率 鱼配置
function FishingAnimManager.PlayDeadFX(data, parent, beginPos, endPos, playerPos, mbPos, gunPos, name_image, delta_t)
	if data.score and data.score <= 0 then
		-- 分数为0不播结算
		dump(data, "<color=red><size=20>EEE 分数为0不播结算</size></color>")
		return
	end
	if data.cfg_fish_id and data.cfg_fish_id == 37 then -- 财神鱼死亡效果
		FishingAnimManager.PlayCSFishDead(data, parent, beginPos, endPos, playerPos, mbPos, name_image, 1)
		return
	end
	if data.cfg_fish_id and data.cfg_fish_id == 24 and (not data.fish or not data.fish.data or data.fish.data.status > 0) then -- 黄金河豚鱼死亡效果
		FishingAnimManager.PlayJCFishDead(data, parent, beginPos, endPos, playerPos, mbPos, name_image, 1)
		return
	end
	-- 鳄鱼死亡 爆宝箱鱼的出现效果
    if data.cfg_fish_id and data.cfg_fish_id == 48 then
        FishingAnimManager.PlayEYBox(beginPos, data.seat_num)
    end
    if data.cfg_fish_id and data.cfg_fish_id == 50 then
    	FishingAnimManager.PlayEYBoxDead(beginPos)
    end

	-- 特殊处理 奖励游戏
	if data.seat_num ~= FishingModel.GetPlayerSeat() then
		if data.cfg_fish_id == 32 then
			FishingAnimManager.PlayOthJLYX(parent, playerPos, math.random(4, 7))
		end
		if data.cfg_fish_id == 33 then
			FishingAnimManager.PlayOthJLYX(parent, playerPos, math.random(25, 40))
		end
	end

	local fish_cfg = FishingModel.Config.fish_map[data.cfg_fish_id]
	-- if not fish_cfg then
	-- 	if AppDefine.IsEDITOR() then
	-- 		HintPanel.Create(1, "问题：鱼不存在")
	-- 	end
	-- 	dump(data, "<color=red>EEE 鱼不存在</color>")
	-- 	Event.Brocast("ui_gold_fly_finish_msg", data)
	-- 	return
	-- end
	if not fish_cfg then
        FishingAnimManager.PlayGold(data, parent, beginPos, endPos, {1,2}, delta_t)		
		return
	end
    if fish_cfg.reward_level[1] == 1 then
        FishingAnimManager.PlayGold(data, parent, beginPos, endPos, fish_cfg.reward_level, delta_t)
    elseif fish_cfg.reward_level[1] == 2 then
    	ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_jiangli2.audio_name)
        FishingAnimManager.PlayGold(data, parent, beginPos, endPos, fish_cfg.reward_level, delta_t)

		FishingAnimManager.PlayBY3D_ZPY(parent, beginPos, playerPos, name_image, data.score, function ()
			-- Event.Brocast("ui_gold_fly_finish_msg", data)
   --  		FishingAnimManager.PlayGoldBigFX(parent, mbPos)
		end, data.seat_num, delta_t, data.cfg_fish_id)
    else
        FishingAnimManager.PlayGold(data, parent, beginPos, endPos, fish_cfg.reward_level, delta_t)

    	FishingAnimManager.PlayBY3D_HDY(parent, beginPos, playerPos, data.score, function ()
    		-- Event.Brocast("ui_gold_fly_finish_msg", data)
    		-- FishingAnimManager.PlayGoldBigFX(parent, mbPos)
    	end, data.seat_num, fish_cfg.reward_level[1], data.cfg_fish_id, data.dead_rate,data.active_rate)
    end
end
function FishingAnimManager.PlayGoldBigFX(parent, pos)
	local prefab = CachePrefabManager.NoForceTake("biankuang_glow")
	if prefab then
		prefab.prefab:SetParent(parent)
		local obj = prefab.prefab.prefabObj
		local tran = obj.transform
		tran.position = pos

		local seq = DoTweenSequence.Create()
		seq:AppendInterval(1)
		seq:OnForceKill(function ()
			CachePrefabManager.Back(prefab)
		end)
	end
end
function FishingAnimManager.PlayGoldFX(parent, pos)
	local prefab = CachePrefabManager.NoForceTake("TYjinbi_glow")
	if prefab then
		prefab.prefab:SetParent(parent)
		local obj = prefab.prefab.prefabObj
		local tran = obj.transform
		tran.position = pos

		local seq = DoTweenSequence.Create()
		seq:AppendInterval(1)
		seq:OnForceKill(function ()
			CachePrefabManager.Back(prefab)
		end)
	end
end

function FishingAnimManager.PlayGold(data, parent, beginPos, endPos, fx_cfg, delta_t)
	local seat_num, score = data.seat_num, data.score
	local gold_pre
	local style
	--if seat_num == FishingModel.GetPlayerSeat() then
	--	gold_pre = "by3d_js_prefab"
	--else
	--	gold_pre = "by3d_ys_prefab"
	--end
	gold_pre = "by3d_js_prefab"
	
	local play_jb_au = function(num)
		if num >= 20 then
			ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_jinbi3.audio_name)
		elseif num >= 10 then
			ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_jinbi2.audio_name)
		else
			ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_jinbi1.audio_name)
		end
	end

	local call = function ()
		local jb_lvl = fx_cfg[1] or 1
		local num = fx_cfg[2] or 1
		if fx_cfg[1] == 1 then
			jb_lvl = 1
		elseif fx_cfg[1] == 2 then
			jb_lvl = 2
		elseif fx_cfg[1] == 3 then
			jb_lvl = 3
		else
			jb_lvl = 3
		end
		if num > 20 then
			num = 20
		end
		local a_rate
		if FishingActivityManager.CheckIsActivityTime(seat_num) then
			a_rate = FishingActivityManager.GetDropAwardRate(seat_num)
		end
		local finish_num = 0
		local _call = function ()
			finish_num = finish_num + 1
			if finish_num == 1 and (not data.style or seat_num == 1) then
				FishingAnimManager.PlayGoldFX(parent, endPos)
			end
			if finish_num == num then
				if data.score <= 0 and data.grades and data.grades > 0 then
					Event.Brocast("ui_grades_fly_finish_msg", data)
				else
					Event.Brocast("ui_gold_fly_finish_msg", data)
				end
			end
		end
		if num == 1 then
			CreateNumGold_New(seat_num, parent, beginPos , endPos, score, delay, function ()
				play_jb_au(num)
				CreateGold(parent, beginPos, endPos, nil, _call, gold_pre)			
			end, jb_lvl)		
		else
			CreateNumGold_New(seat_num, parent, beginPos , endPos, score, delay, function ()
				play_jb_au(num)
				local t = 0.08
				local prefab_name = gold_pre
				if CachePrefabManager.IsBeCache(prefab_name, num) then
					for i = 1, num do
						local x = beginPos.x + math.random(0, 200) - 50
						local y = beginPos.y + math.random(0, 200) - 50
						local pos = Vector3.New(x, y, beginPos.z)
						CreateGold(parent, pos, endPos, t * (i-1), _call, gold_pre)
					end
				else
					num = 1
					CreateGold(parent, beginPos, endPos, nil, _call, gold_pre)
				end
			end, jb_lvl)
		end
	end
	if delta_t and delta_t > 0 then
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(delta_t)
		seq:OnKill(function ()
			call()
		end)
	else
		call()
	end
	
end
-- 播放冰冻特效
function FishingAnimManager.PlayFrozen(parent)
	local prefab = CachePrefabManager.Take("bing_yan")
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(3)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)
	end)
end
-- 播放鱼的爆炸特效
function FishingAnimManager.PlayFishBoom(parent, pos)
	ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_zhadanyu.audio_name)

	local prefab = CachePrefabManager.Take("baozha")
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	tran.position = pos

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(4)
	seq:OnForceKill(function ()
		if prefab then
			CachePrefabManager.Back(prefab)
		end
	end)
end
-- 播放鱼潮字幕

function FishingAnimManager.PlayWaveHint(parent, isLeft, img)
	local prefab = CachePrefabManager.Take("FishBoomPrefab")
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform

	if img then
		local image = tran:Find("Image"):GetComponent("Image")
		image.sprite = GetTexture(img)
	end
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(3)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)
	end)	
end
-- 播放鱼潮
function FishingAnimManager.PlayWave(parent, isLeft)
	local prefab = CachePrefabManager.Take("yuchao")
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	local end_pos
	if isLeft then
		tran.rotation = Quaternion.Euler(0, 0, 0)
		tran.position = Vector3.New(1500, 0, 0)
		end_pos = Vector3.New(-1500, 0, 0)
	else
		tran.rotation = Quaternion.Euler(0, 0, 180)
		tran.position = Vector3.New(-1500, 0, 0)
		end_pos = Vector3.New(1500, 0, 0)
	end

	local seq = DoTweenSequence.Create()
	seq:Append(tran:DOMove(end_pos, 3))
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)
	end)	
end
-- 鱼潮加场景图切换
function FishingAnimManager.PlaySwitchoverMap(parent, call)
	local prefab = CachePrefabManager.Take("Fishing3D_qiepin")
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = Vector3.zero
	tran.localScale = Vector3.one

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(1.5)
	seq:AppendCallback(function ()
		if call then
			call()
		end
		call = nil
	end)
	seq:AppendInterval(1.5)
	seq:OnKill(function ()
		if call then
			call()
		end
		call = nil
	end)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)
	end)
end

--
local function FlyingToTarget(node, targetPoint, targetScale, interval, callback, forcecallback, delay)
	if not IsEquals(node) then
		if callback then callback() end
		return
	end

	local seq = DoTweenSequence.Create()
	delay = delay or 0
	if delay > 0 then		
		seq:AppendInterval(delay)
	end

	seq:Append(node.transform:DOMoveBezier(targetPoint, 300, interval))

	targetScale = targetScale or 1
	if targetScale ~= 1 then
		seq:Join(node.transform:DOScale(targetScale, interval))
	end

	seq:OnKill(function ()
		if callback then callback() end
	end)
	seq:OnForceKill(function ()
		if forcecallback then
			forcecallback()
		end
	end)
end

--播放100倍金币效果
function FishingAnimManager.PlayMultiplyingPower100(parent, beginPos, endPos, name, money, callback, seat_num, delta_t, style)
	local call = function ()
		local effectName = "100bei_jingbi"
		local effectSnd = nil
		local effectTime = -1
		local burstTime = 1

		local gold_txt = nil
		local function set_money(value)
			if IsEquals(gold_txt) then
				if style and style == "match" then
					gold_txt.font = GetFont("by_tx6")
				else
					gold_txt.font = FishingAnimManager.GetFontBySeatNum(seat_num)
				end
				gold_txt.text = value
			end
		end
		local rate_img = nil
		local function set_rate()
			if rate_on_off and IsEquals(rate_img) then
				if FishingActivityManager.CheckIsActivityTime(seat_num) then
					local v = FishingActivityManager.GetDropAwardRate(seat_num)
					if v and tonumber(v) then
						rate_img.sprite = GetTexture("by_imgf_bj" .. (v - 1))
						rate_img.gameObject:SetActive(true)
					end
				end
			end
		end

		local timer = nil
		local function close_timer()
			if timer then
				timer:Stop()
				timer = nil
			end
		end

		local prefab = FishingAnimManager.PlayNormal(effectName, effectSnd, effectTime, nil, parent)
		local fx = prefab.prefab.prefabObj
		if not fx then
			print("[FX] PlayMultiplyingPower100 create fx failed")
			if callback then
				callback()
			end
			return
		end

		local name_img = fx.transform:Find("bytx_zp6/name_img"):GetComponent("Image")
		name_img.sprite = GetTexture(name)
		name_img:SetNativeSize()

		fx.transform.position = beginPos
		gold_txt = fx.transform:Find("bytx_zp3/gold_txt"):GetComponent("Text")
		rate_img = fx.transform:Find("bytx_zp3/gold_txt/rate_img"):GetComponent("Image")
		set_rate()
		local interval = 0.05
		local split = burstTime / interval
		local step = math.max(1, math.floor(money / split))
		local count = 0
		timer = Timer.New(function()
			if not timer then
				if callback then
					callback()
				end
				return
			end

			count = count + step
			if count > money then
				count = money
				close_timer()
			end
			set_money(count)
		end, interval, -1, false, false)
		timer:Start()

		local seq = DoTweenSequence.Create()
		seq:Append(fx.transform:DOMove(Vector3.New(beginPos.x, beginPos.y + 30, 0), 0.8))
		seq:AppendInterval(0.6)
		seq:Append(fx.transform:DOMove(endPos, 0.5))
		-- seq:AppendInterval(0.6)
		seq:OnKill(function ()
			if callback then
				callback()
			end
		end)
		seq:OnForceKill(function ()
			CachePrefabManager.Back(prefab)			
		end)

	end
	if delta_t and delta_t > 0 then
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(delta_t)
		seq:OnKill(function ()
			call()
		end)
	else
		call()
	end
end

--播放滚动钱币ui
function FishingAnimManager.PlayMultiplyingPower200(parent, beginPos, endPos, money, callback, seat_num, delta_t, style)
	local call = function ()
		local effectName = "200bei_jingbi"
		local effectSnd = nil
		local effectTime = -1
		local burstTime = 2

		local gold_txt = nil
		local function set_money(value)
			if IsEquals(gold_txt) then
				if style and style == "match" then
					gold_txt.font = GetFont("by_tx6")
				else
					gold_txt.font = FishingAnimManager.GetFontBySeatNum(seat_num)
				end
				gold_txt.text = value
			end
		end
		local rate_img = nil
		local function set_rate()
			if rate_on_off and IsEquals(rate_img) then
				if FishingActivityManager.CheckIsActivityTime(seat_num) then
					local v = FishingActivityManager.GetDropAwardRate(seat_num)
					if v and tonumber(v) then
						rate_img.sprite = GetTexture("by_imgf_bj" .. (v - 1))
						rate_img.gameObject:SetActive(true)
					end
				end
			end
		end

		local timer = nil
		local function close_timer()
			if timer then
				timer:Stop()
				timer = nil
			end
		end

		local prefab = FishingAnimManager.PlayNormal(effectName, effectSnd, effectTime, nil, parent)
		local fx = prefab.prefab.prefabObj
		if not fx then
			print("[FX] PlayMultiplyingPower200 create fx failed")
			if callback then callback() end
			return
		end

		fx.transform.position = beginPos
		gold_txt = fx.transform:Find("Center/@gold_txt"):GetComponent("Text")
		rate_img = fx.transform:Find("Center/@gold_txt/rate_img"):GetComponent("Image")
		-- set_rate()
		local interval = 0.05
		local split = burstTime / interval
		local step = math.max(1, math.floor(money / split))
		local count = 0
		timer = Timer.New(function()
			if not timer then
			 	if callback then callback() end
				return 
			end

			count = count + step
			if count > money then
				count = money
				close_timer()
			end
			set_money(count)
		end, interval, -1, false, false)
		timer:Start()

		local seq = DoTweenSequence.Create()
		seq:Append(fx.transform:DOMove(Vector3.New(beginPos.x, beginPos.y + 50, 0), 0.8))
		seq:AppendInterval(1.6)
		seq:Append(fx.transform:DOMove(endPos, 0.5))
		-- seq:AppendInterval(1.2)
		seq:OnKill(function ()
			if callback then callback() end
		end)
		seq:OnForceKill(function ()
			CachePrefabManager.Back(prefab)			
		end)
	end
	if delta_t and delta_t > 0 then
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(delta_t)
		seq:OnKill(function ()
			call()
		end)
	else
		call()
	end
end

function FishingAnimManager.PlayNormal(particleName, soundName, interval, callback, parent, pos)
	if not parent then
		parent = GameObject.Find("Canvas/LayerLv2")
	end

	local prefab = CachePrefabManager.Take(particleName)
    prefab.prefab:SetParent(parent.transform)
	local tran = prefab.prefab.prefabObj.transform
	tran.localScale = Vector3.one

	if not prefab then
		print("[PARTICLE] PlayNormal failed. particle is nil:" .. particleName)
		return
	end

	if pos then
		tran.position = pos
	else
		tran.position = Vector3.zero
	end

	if interval > 0 then
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(interval)
		seq:OnKill(function ()
			if callback then
				callback()
			end
		end)
		seq:OnForceKill(function ()
			CachePrefabManager.Back(prefab)			
		end)
	end

	if soundName then
		ExtendSoundManager.PlaySound(soundName)
	end

	return prefab
end

function FishingAnimManager.PlayMultiplyingPower300(parent, beginPos, endPos, money, callback,seat_num, style)
	local function PlayMultipPower300()
		local effectName = "300bei_jingbi"
		if style and style == "match" then
			effectName = "300bei_jingbi_lan"
		end
		local effectSnd = nil
		local effectTime = -1
		local interval = 0.2

		local objects = {}
		local function destroy_objects()
			for _, v in pairs(objects) do
				GameObject.Destroy(v.gameObject)
			end
			objects = {}
		end

		local prefab = FishingAnimManager.PlayNormal(effectName, effectSnd, effectTime, nil, parent)
		local fx = prefab.prefab.prefabObj
		if not fx then
			print("[FX] PlayMultiplyingPower300 create fx failed")
			if callback then callback() end
			return
		end

		local number_to_array = function(number)
			local tbl = {}
			while number > 0 do
				tbl[#tbl + 1] = number % 10
				number = math.floor(number / 10)
			end

			local array = {}
			for idx = #tbl, 1, -1 do
				array[#array + 1] = tbl[idx]
			end

			return array
		end

		local money_array = number_to_array(money)
		local split = #money_array

		local money_tmpl = fx.transform:Find("money_tmpl")
		local money_node = fx.transform:Find("money_node")

		for idx = 1, split do
			local object = GameObject.Instantiate(money_tmpl, money_node)
			object.transform.localPosition = Vector3.zero
			local image = object.transform:Find("300bei_shuzi/Image"):GetComponent("Text")
			if style and style == "match" then
				image.font = GetFont("by_tx6")
			else
				image.font = FishingAnimManager.GetFontBySeatNum(seat_num)
			end
			image.text = money_array[idx]
			image.gameObject:SetActive(false)
			objects[#objects + 1] = object
			object.gameObject:SetActive(false)
		end

		local show_number = function (idx, number)
			local object = objects[idx]
			if not IsEquals(object) then return end

			local shuzi = object.transform:Find("300bei_shuzi")
			local image = object.transform:Find("300bei_shuzi/Image"):GetComponent("Text")
			local animator = shuzi:GetComponentInChildren(typeof(UnityEngine.Animator))
			shuzi.gameObject:SetActive(true)
			if animator then
				image.gameObject:SetActive(true)
				object.gameObject:SetActive(true)
				animator:Play("300bei_shuzi", 0, 0)
			end
			ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_jiangli7_1.audio_name)
		end

		local timer = nil
		local function close_timer()
			if timer then
				timer:Stop()
				timer = nil
			end
		end

		local count = 0
		timer = Timer.New(function()
			if not timer then
				if callback then callback() end
				return
			end

			count = count + 1
			show_number(count, count)

			if count >= split then
				close_timer()
				ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_jiangli7_2.audio_name)
				
				if not IsEquals(money_node) then
					if callback then callback() end
					return 
				end
				FlyingToTarget(money_node, endPos, 0.3, 0.5, function()
					if callback then callback() end
						if IsEquals(money_node) then
							money_node.localPosition = Vector3.zero
							money_node.localScale = Vector3.one
						end
						destroy_objects()
				end,function()
					if prefab then
						CachePrefabManager.Back(prefab)
					end
				end, 2)
			end
		end, interval, -1, false, false)
		timer:Start()
	end

	local e_name = "300bei_shuzi_Bj"
	local _prefab = FishingAnimManager.PlayNormal(e_name, nil, 2.5, PlayMultipPower300, parent)
end
function FishingAnimManager.PlayMultiplyingPower300_Other(parent, beginPos, endPos, money, callback, seat_num, style)
	local function PlayMultipPower300()
		local effectName = "300bei_jingbi_other"
		if seat_num > 2 then
			effectName = effectName .. "_1"
		end
		if style and style == "match" then
			effectName = effectName .. "_lan"
		end
		local effectSnd = nil
		local effectTime = -1
		local interval = 0.2

		local objects = {}
		local function destroy_objects()
			for _, v in pairs(objects) do
				GameObject.Destroy(v.gameObject)
			end
			objects = {}
		end

		local prefab = FishingAnimManager.PlayNormal(effectName, effectSnd, effectTime, nil, parent, beginPos)
		local fx = prefab.prefab.prefabObj
		if not fx then
			print("[FX] PlayMultiplyingPower300 create fx failed")
			if callback then callback() end
			return
		end

		local number_to_array = function(number)
			local tbl = {}
			while number > 0 do
				tbl[#tbl + 1] = number % 10
				number = math.floor(number / 10)
			end

			local array = {}
			for idx = #tbl, 1, -1 do
				array[#array + 1] = tbl[idx]
			end

			return array
		end

		local money_array = number_to_array(money)
		local split = #money_array

		local money_tmpl = fx.transform:Find("money_tmpl")
		local money_node = fx.transform:Find("money_node")

		for idx = 1, split do
			local object = GameObject.Instantiate(money_tmpl, money_node)
			object.transform.localPosition = Vector3.zero
			local image = object.transform:Find("300bei_shuzi/Image"):GetComponent("Text")
			image.font = FishingAnimManager.GetFontBySeatNum(seat_num)
			image.text = money_array[idx]
			image.gameObject:SetActive(false)
			objects[#objects + 1] = object
			object.gameObject:SetActive(false)
		end

		local show_number = function (idx, number)
			local object = objects[idx]
			if not IsEquals(object) then return end

			local shuzi = object.transform:Find("300bei_shuzi")
			local image = object.transform:Find("300bei_shuzi/Image"):GetComponent("Text")
			local animator = shuzi:GetComponentInChildren(typeof(UnityEngine.Animator))
			shuzi.gameObject:SetActive(true)
			if animator then
				image.gameObject:SetActive(true)
				object.gameObject:SetActive(true)
				animator:Play("300bei_shuzi", 0, 0)
			end
			ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_jiangli7_1.audio_name)
		end

		local timer = nil
		local function close_timer()
			if timer then
				timer:Stop()
				timer = nil
			end
		end

		local count = 0
		timer = Timer.New(function()
			if not timer then
				if callback then callback() end
				return
			end

			count = count + 1
			show_number(count, count)

			if count >= split then
				close_timer()
				ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_jiangli7_2.audio_name)
				
				if not IsEquals(money_node) then
					if callback then callback() end
					return 
				end
				FlyingToTarget(money_node, endPos, 0.3, 0.5, function()
					if callback then callback() end
				end,function()
					if prefab and IsEquals(money_node) then
						money_node.localPosition = Vector3.zero
						money_node.localScale = Vector3.one
						destroy_objects()
						CachePrefabManager.Back(prefab)
					end
				end, 2)
			end
		end, interval, -1, false, false)
		timer:Start()
	end

	local e_name = "300bei_shuzi_Bj_other"
	local _prefab = FishingAnimManager.PlayNormal(e_name, nil, 2.5, PlayMultipPower300, parent, beginPos)
end

function FishingAnimManager.PlayJBLaser(parent, seat_num, beginPos, r, call)
	local prefab = CachePrefabManager.Take("jiguang_attack_node")
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	tran.rotation = Quaternion.Euler(0, 0, r)
	tran.position = beginPos

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(1.5)
	seq:AppendCallback(function ()
		if call then
			call()
		end
	end)
	seq:AppendInterval(1)
	seq:OnKill(function ()
		Event.Brocast("ui_play_laser_finish_msg", seat_num)
	end)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)		
	end)	
end

-- 播放极光子弹
function FishingAnimManager.PlayLaser(parent, seat_num, beginPos, r)
	local prefab = CachePrefabManager.Take("fishing3D_diancipao")
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	tran.rotation = Quaternion.Euler(0, 0, r)
	tran.position = beginPos

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(3)
	seq:OnKill(function ()
		Event.Brocast("ui_play_laser_finish_msg", seat_num)
	end)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)		
	end)
end

-- 播放核弹特效
function FishingAnimManager.PlayMissile(parent, seat_num, beginPos, endPos)
	-- nmg todo 效果没加
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(2)
	seq:OnKill(function ()
		Event.Brocast("ui_play_missile_finish_msg", seat_num)
		if IsEquals(obj) then
			destroy(obj)
		end
	end)	
end

-- 播放获得额外道具表现(核弹碎片)
function FishingAnimManager.PlayMissileSP(parent, seat_num, beginPos, endPos, missile_index, putong_or_jinse, call)
	local prefab = CachePrefabManager.Take("FishingFlyToolPrefab")
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	local icon = tran:Find("Icon"):GetComponent("Image")
	tran.position = beginPos
	if putong_or_jinse == 1 then
		icon.sprite = GetTexture("by_btn_hd" .. (missile_index + 1))
	else
		icon.sprite = GetTexture("by_btn_hdj" .. (missile_index + 1))
	end

	FlyingToTarget(tran, endPos, 0.3, 0.5, function()
		if call then call(putong_or_jinse) end
	end, function()
		CachePrefabManager.Back(prefab)
	end, 2)
end

-- 播放一网打尽
function FishingAnimManager.PlayYWDJ(parent)
	local prefab = CachePrefabManager.Take("activity_ywdj")
	prefab.prefab:SetParent(parent)
	
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(2)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)		
	end)

end

-- 播放获得额外道具表现(锁定 冰冻)
function FishingAnimManager.PlayToolSP(parent, seat_num, beginPos, endPos, attr, num, call)
	ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_huodejineng.audio_name)

	local prefab = CachePrefabManager.Take("FishingFlyToolPrefab")
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	local icon = tran:Find("Icon"):GetComponent("Image")
	tran.position = beginPos
	local cc = FishingSkillManager.FishDeadAppendMap[attr]
	if cc then
		icon.sprite = GetTexture(cc.icon)
	else
		dump(attr, "<color=red>EEE 播放获得额外道具表现</color>")
		icon.sprite = GetTexture("pond_btn_close")
	end

	FlyingToTarget(tran, endPos, 1, 0.5, function()
		if call then call(num) end
	end, function()
		CachePrefabManager.Back(prefab)
	end, 2)
end

function FishingAnimManager.GetFontBySeatNum(seat_num)
	local font
	if seat_num == FishingModel.GetPlayerSeat() then
		font = GetFont("3dby_font_hjz")
	else
		font = GetFont("3dby_font_hjzy")
	end
	return font
end
function FishingAnimManager.GetFontBySeatNum2(seat_num)
	local font = GetFont("3dby_font_hjz")
	return font
end

-- 播放鱼死亡冒泡特效
function FishingAnimManager.PlayFishHitTS(parent, pos)
	-- ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_zhadanyu.audio_name)

	local prefab = CachePrefabManager.Take("activity_Hit_TS")
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	tran.position = pos

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(4)
	seq:OnForceKill(function ()
		if prefab then
			CachePrefabManager.Back(prefab)
		end
	end)
end

-- 播放特殊鱼死亡前奏表现
-- 放大缩小 并带有泡泡特效
function FishingAnimManager.PlayTSFishDeadHint(parent, pos, fish_obj, call)
	local prefab = CachePrefabManager.Take("activity_Hit_TS")
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	tran.position = pos

	local seq = DoTweenSequence.Create()
	if IsEquals(fish_obj) then
		for i = 1, 10 do
			seq:Append(fish_obj.transform:DOScale(Vector3.New(1.5, 1.5, 1.5), 0.075))
			seq:Append(fish_obj.transform:DOScale(Vector3.New(1, 1, 1), 0.075))
		end
	end
	seq:OnKill(function ()
		if IsEquals(fish_obj) then
			if call then
				call()
			end
		end
	end)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)
	end)
end

-- 开始点 结束点
local function CreateZongzi(parent, beginPos, endPos, delay, call, ext_prefab)
	local prefab
	if not ext_prefab or type(ext_prefab) == "string" then
		prefab = CachePrefabManager.Take(ext_prefab or "FishingFlyZongziPrefab")
	else
		prefab = ext_prefab
	end
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = beginPos

	local seq = DoTweenSequence.Create()
	if delay and delay > 0.00001 then		
		seq:AppendInterval(delay)
	end
	local len = math.sqrt( (beginPos.x - endPos.x) * (beginPos.x - endPos.x) + (beginPos.y - endPos.y) * (beginPos.y - endPos.y) )
	local HH = 35
	local t = len / 1200
	local h = math.random(100, 200)
	seq:Append(tran:DOMove(Vector3.New(beginPos.x, beginPos.y + HH, 0), 0.25))
	seq:Append(tran:DOMove(Vector3.New(beginPos.x, beginPos.y, 0), 0.2))
	seq:Append(tran:DOMove(Vector3.New(beginPos.x, beginPos.y + HH*0.7, 0), 0.2))
	seq:Append(tran:DOMove(Vector3.New(beginPos.x, beginPos.y, 0), 0.2))
	seq:AppendInterval(0.2)
	seq:Append(tran:DOMoveBezier(endPos, h, t))
	seq:OnKill(function ()
		if call then
			call()
		end
	end)
	seq:OnForceKill(function ()
		if prefab then
			CachePrefabManager.Back(prefab)
		end
	end)
end
-- 播放粽子
function FishingAnimManager.PlayZongzi(seat_num, score, parent, beginPos, endPos, delta_t, ext_data)
	local call = function ()
		local num = 1
		local finish_num = 0

		local _call = function ()
			finish_num = finish_num + 1
			if finish_num == 1 then
				FishingAnimManager.PlayGoldFX(parent, endPos)
			end
			if finish_num == num then
				Event.Brocast("ui_zongzi_fly_finish_msg", seat_num, score)
			end
		end

		local ext_prefab
		local ex_id = ext_data.act_type
		--默认类型的act_type = 0
		if ex_id then
			if ex_id == 10 then
				ext_prefab = "FishingFlyZongziPrefab"
			elseif ex_id == 8 then
				ext_prefab = "FishingFlyHBPrefab"
			elseif ex_id == 9 then
				ext_prefab = "FishingFlyHBPrefab_lwgp"
			else
				local a, _pre = GameButtonManager.RunFunExt("act_ty_by_drop", "GetDLFlyPrefab", nil, ex_id)
				if a and _pre then
					ext_prefab = _pre
				else
					ext_prefab = "FishingFlyZongziPrefab"
				end
			end
		end

		if num == 1 then
			CreateZongzi(parent, beginPos, endPos, nil, _call, ext_prefab)
		elseif num < 6 then
			local t = 0.08
			local detay = t * (num-1)
			for i = 1, num do
				local pos = Vector3.New(beginPos.x + 80 * (i-num/2), beginPos.y, beginPos.z)
				CreateZongzi(parent, pos, endPos, t * (i-1), _call, ext_prefab)
			end
		else
			local t = 0.08
			for i = 1, num do
				local x = beginPos.x + math.random(0, 200) - 100
				local y = beginPos.y + math.random(0, 200) - 100

				local pos = Vector3.New(x, y, beginPos.z)
				CreateZongzi(parent, pos, endPos, t * (i-1), _call, ext_prefab)
			end
		end
	end
	if delta_t and delta_t > 0 then
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(delta_t)
		seq:OnKill(function ()
			call()
		end)
	else
		call()
	end
end
function FishingAnimManager.PlayAddZongzi(seat_num, score, parent, beginPos)
		local prefab = CachePrefabManager.Take("AddZongzi3D")
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = beginPos

	local canvas_group = tran:GetComponent("CanvasGroup")
	local text = tran:Find("Text"):GetComponent("Text")
	text.text = "+" .. score
	local seq = DoTweenSequence.Create()
	seq:Append(tran:DOMoveY(beginPos.y + 100, 0.5))
	seq:AppendInterval(1)
	seq:Append(canvas_group:DOFade(0.5, 0))
	seq:OnKill(function ()
	end)
	seq:OnForceKill(function ()
		if prefab then
			CachePrefabManager.Back(prefab)
		end
	end)
end

-- 贝壳渐隐消失时的特效
function FishingAnimManager.PlayBKFleeFX(parent, beginPos)
	local prefab = CachePrefabManager.Take("bk_siwang")
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = beginPos

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(2)
	seq:OnForceKill(function ()
		if prefab then
			CachePrefabManager.Back(prefab)
		end
	end)
end
-- 宝箱鱼中奖提示
function FishingAnimManager.PlayBoxFishZJHint(parent, beginPos, img, delta_t)
	local prefab = CachePrefabManager.Take("FXBoxFishPrefab")
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = beginPos
	local image = tran:Find("HintImage"):GetComponent("Image")
	image.sprite = GetTexture(img)
	image:SetNativeSize()
	prefab.prefab.prefabObj:SetActive(false)

	local seq = DoTweenSequence.Create()
	if delta_t and delta_t > 0 then
		seq:AppendInterval(delta_t)
	end
	seq:AppendCallback(function ()
		prefab.prefab.prefabObj:SetActive(true)
	end)
	seq:AppendInterval(2)
	seq:OnForceKill(function ()
		if prefab then
			CachePrefabManager.Back(prefab)
		end
	end)
end

local box_award_lvl_list = {"by_bx_pingguo", "by_bx_ling", "by_bx_qi", "by_bx_bar"}
local box_award_lvl_time = {1.93, 2.66, 2.83, 3.25}
-- 宝箱鱼中奖提示
function FishingAnimManager.PlayBoxFishZJLvl(parent, beginPos, lvl, delta_t)
	if not lvl or lvl < 1 or lvl > 4 then
		lvl = 1
	end
	local prefab = CachePrefabManager.Take(box_award_lvl_list[lvl])
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = beginPos

	local seq = DoTweenSequence.Create()
	if delta_t and delta_t > 0 then
		seq:AppendInterval(delta_t)
	end
	seq:AppendInterval(box_award_lvl_time[lvl])
	seq:OnForceKill(function ()
		if prefab then
			CachePrefabManager.Back(prefab)
		end
	end)
end

-- 挑战任务出现
function FishingAnimManager.PlayTZTaskAppear(parent, beginPos, endPos, call)
	local prefab = CachePrefabManager.Take("by_tiaozhanrenwu_cx_3D")
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = beginPos

    local seq = DoTweenSequence.Create()
    seq:AppendInterval(1.8)
    seq:Append(tran:DOMove(endPos, 0.3):SetEase(DG.Tweening.Ease.InQuint))
    seq:OnKill(function ()
	    Event.Brocast("ui_shake_screen_msg",1.5,0.5)
	    if call then
	    	call()
	    end
	    call = nil
    end)
    seq:OnForceKill(function ()
		if prefab then
			CachePrefabManager.Back(prefab)
		end
	end)
end


local function CreateNumGrades(seat_num, parent, beginPos, endPos, score, rate)
	local prefab = CachePrefabManager.Take("NumGradesPrefab")
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = beginPos
	local gold_txt = tran:Find("gold_txt"):GetComponent("Text")
	gold_txt.text = score
	local rate_txt = tran:Find("gold_txt/rate_img"):GetComponent("Text")
	if rate and rate > 1 then
		rate_txt.text = "(" .. rate .. "倍)"
	else
		rate_txt.text = ""
	end

	local HH = 50
	local seq = DoTweenSequence.Create()
	seq:Append(tran:DOMove(Vector3.New(beginPos.x, beginPos.y + HH, 0), 0.8))
	seq:OnForceKill(function ()
		if prefab then
			CachePrefabManager.Back(prefab)
		end		
	end)
end

-- 飞行累计赢金
function FishingAnimManager.PlayFlyGrades(data, parent, beginPos, endPos, playerPos, mbPos, name_image, delta_t)
	ExtendSoundManager.PlaySound(audio_config.by3d.bgm_bymatch_yingfenjiangli.audio_name)
	local keepTime = 1
	local moveTime = 0.3
	local endTime = 0.3
	local fx_name = "grades_prefab"
	local prefab = CachePrefabManager.Take(fx_name)
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = beginPos
	local sc_text = tran:Find("MoneyText"):GetComponent("Text")
	local re_text = tran:Find("ReatText"):GetComponent("Text")
	sc_text.text = data.grades
	re_text.text = data.rate * (data.grades_rate or 1) .. "倍赢分"

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(keepTime)
	seq:Append(tran:DOMove(endPos, moveTime):SetEase(DG.Tweening.Ease.InQuint))
	if endTime then
		seq:AppendInterval(endTime)
	end
	seq:OnKill(function ()
		Event.Brocast("ui_grades_fly_finish_msg", data)
	end)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)
	end)
end

-- 累计赢金往上飘
function FishingAnimManager.PlayGradesUpMove(parent, beginPos, score)
	local prefab = CachePrefabManager.Take("FishingMoneyGrades")
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = beginPos
	local gold_txt = tran:GetComponent("Text")
	gold_txt.text = "+" .. score

	local HH = 50
	local seq = DoTweenSequence.Create()
	seq:Append(tran:DOMove(Vector3.New(beginPos.x, beginPos.y + HH, 0), 0.8))
	seq:OnForceKill(function ()
		if prefab then
			CachePrefabManager.Back(prefab)
		end		
	end)
end
-- 累计金币往上飘
function FishingAnimManager.PlayGoldUpMove(parent, beginPos, score, seat_num)
	local prefab = CachePrefabManager.Take("Fishing3DMoneyNumber")
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = beginPos
	local gold_txt = tran:GetComponent("Text")
	gold_txt.font = FishingAnimManager.GetFontBySeatNum(seat_num)
	gold_txt.text = "+" .. score

	local HH = 50
	local seq = DoTweenSequence.Create()
	seq:Append(tran:DOMove(Vector3.New(beginPos.x, beginPos.y + HH, 0), 0.8))
	seq:OnForceKill(function ()
		if prefab then
			CachePrefabManager.Back(prefab)
		end		
	end)
end

-- 游戏开始
function FishingAnimManager.PlayMatchBeginGame(parent)
	local prefab = CachePrefabManager.Take("bymatch_begin")
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = Vector3.zero

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(2)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)
	end)		
end
-- 主炮升级
function FishingAnimManager.PlayGunUpFX1(parent, beginPos, endPos, data, main_index)
    ExtendSoundManager.PlaySound(audio_config.by3d.bgm_bymatch_zhupaoshengji.audio_name)
	local prefab = CachePrefabManager.Take("by_sj_tw")
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = beginPos
	local seq = DoTweenSequence.Create()
	seq:Append(tran:DOMove(Vector3.zero, 0.5))
	seq:OnKill(function ()
		FishingAnimManager.PlayGunUpFX2(parent, Vector3.zero, endPos, data, main_index)
	end)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)
	end)
end
function FishingAnimManager.PlayGunUpFX2(parent, beginPos, endPos, data, main_index)
	local prefab = CachePrefabManager.Take("gunup_prefab")
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = beginPos
	local node = tran:Find("Node")
	node.gameObject:SetActive(true)
	local anim = tran:GetComponent("Animator")
	anim:Play("by_gunup", -1, 0)
	local GunImage = tran:Find("GunImage"):GetComponent("Image")
	local cfg = FishingModel.GetGunCfg(main_index)
	GunImage.sprite = GetTexture(cfg.gun_icon)

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(2)
	seq:AppendCallback(function ()
		node.gameObject:SetActive(false)
	end)
	seq:Append(tran:DOMove(endPos, 0.3):SetEase(DG.Tweening.Ease.InQuint))
	seq:AppendCallback(function ()
	    ExtendSoundManager.PlaySound(audio_config.by3d.bgm_bymatch_zhupaozhuangji.audio_name)
		Event.Brocast("ui_gunup_fx_finish", data)
	end)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)
	end)	
end
-- 炮台改变 闪光特效
function FishingAnimManager.PlayGunChangeFX(parent, beginPos)
	local prefab = CachePrefabManager.Take("by_gun_ks")
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = beginPos

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(2)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)
	end)		
end
-- 升级(或其他)补偿动画
function FishingAnimManager.PlayGiveMoney(parent, beginPos, endPos, money)
	local data = {}
	data.seat_num = 1
	data.score = money
	data.grades = 0
	data.rate = 40
	data.style = "match"
	local fx_cfg = FishingConfig.GetGoldFX(FishingModel.Config.fish_goldfx_list, data.rate)
	FishingAnimManager.PlayGold(data, parent, beginPos, endPos, fx_cfg, delta_t)
end
-- 一个固定位置的特效 显示一段时间消失
function FishingAnimManager.PlayShowAndHideFX(parent, fx_name, beginPos, keepTime, no_take, call)
	local prefab
	if no_take then
		prefab = GameObject.Instantiate(GetPrefab(fx_name), parent).gameObject
		prefab.transform.position = beginPos
		prefab.transform.localScale = Vector3.one
	else
		prefab = CachePrefabManager.Take(fx_name)
		prefab.prefab:SetParent(parent)
		local tran = prefab.prefab.prefabObj.transform
		tran.position = beginPos
		tran.localScale = Vector3.one
	end

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(keepTime)
	seq:OnKill(function ()
		if call then
			call()
		end
	end)
	seq:OnForceKill(function ()
		if no_take then
			destroy(prefab)
		else
			CachePrefabManager.Back(prefab)
		end
	end)		
end
-- 通用飞行特效 
function FishingAnimManager.PlayMoveAndHideFX(parent, fx_name, beginPos, endPos, keepTime, moveTime, call, endTime)
	local prefab = CachePrefabManager.Take(fx_name)
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = beginPos

	local seq = DoTweenSequence.Create()
	if keepTime and keepTime > 0 then
		seq:AppendInterval(keepTime)
	end
	seq:Append(tran:DOMove(endPos, moveTime):SetEase(DG.Tweening.Ease.InQuint))
	if endTime and endTime > 0 then
		seq:AppendInterval(endTime)
	end
	seq:OnKill(function ()
		if call then
			call()
		end
	end)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)
	end)		
end

-- 全屏闪电 传动效果
function FishingAnimManager.PlayMaxLinesFX_FS(parent, fs_pos, data, speedTime, keepTime, lineName, pointName)
    ExtendSoundManager.PlaySound(audio_config.by3d.bgm_bymatch_shandian1.audio_name)
    FishingAnimManager.PlayLinesFX_FS(parent, fs_pos, data, speedTime, keepTime, lineName, pointName)
end
function FishingAnimManager.PlayMinLinesFX_FS(parent, fs_pos, data, speedTime, keepTime, lineName, pointName)
    ExtendSoundManager.PlaySound(audio_config.by3d.bgm_bymatch_shandian2.audio_name)
    FishingAnimManager.PlayLinesFX_FS(parent, fs_pos, data, speedTime, keepTime, lineName, pointName)
end
function FishingAnimManager.PlayLinesFX_FS(parent, fs_pos, data, speedTime, keepTime, lineName, pointName)
	FishingAnimManager.PlayShowAndHideFX(parent, "by_qpsd", fs_pos, 2)
	
	local pos_list = {}
	for k,v in ipairs(data) do
		local pp = v - fs_pos
		local r = Vec2DAngle(Vec2DNormalize({x = pp.x, y = pp.y}))
		local j = math.floor(r / 30)
		if not pos_list[j+1] then
			pos_list[j+1] = {fs_pos}
		end
		pos_list[j+1][#pos_list[j+1] + 1] = v
	end
	local len_list = {}
	for k,v in pairs(pos_list) do
		len_list[k] = {}
		for k1,v1 in ipairs(v) do
			local cha = fs_pos - v1
			local len = Vec2DLength({x=cha.x, y=cha.y})
			local dd = {}
			dd.len = len
			dd.pos = v1
			len_list[k][#len_list[k] + 1] = dd
		end
	end
	
	--  排序
	for k,v in pairs(len_list) do
		MathExtend.SortList(v, "len", true)
	end
	pos_list = {}
	for k,v in pairs(len_list) do
		pos_list[k] = {}
		for k1, v1 in ipairs(v) do
			pos_list[k][#pos_list[k] + 1] = v1.pos
		end
	end

	for k,v in pairs(pos_list) do
		if #v > 0 then
			FishingAnimManager.PlayLinesFX(parent, v, speedTime, keepTime, lineName, pointName, true)
		end
	end
end

-- 播放全屏小爆炸特效
function FishingAnimManager.PlayQPMinBoom(parent,callback,forcecallback)
	ExtendSoundManager.PlaySound(audio_config.by3d.bgm_bymatch_zhadan2.audio_name)
	FishingAnimManager.PlayQPBoom(parent,1,callback,forcecallback)
end
-- 播放全屏大爆炸特效
function FishingAnimManager.PlayQPMaxBoom(parent,callback,forcecallback)
	ExtendSoundManager.PlaySound(audio_config.by3d.bgm_bymatch_zhadan1.audio_name)
	FishingAnimManager.PlayQPBoom(parent,3,callback,forcecallback)
end
-- 播放全屏爆炸特效
function FishingAnimManager.PlayQPBoom(parent,level,callback,forcecallback)
	parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local level_pos = {
		[1] = {
			[1] = {x = 0,y = 0}
		},
		[2] = {
			[4] = {x = 400,y = 200},
			[1] = {x = -400,y = 200},
			[3] = {x = 400,y = -200},
			[2] = {x = -400,y = -200},
		},
		[3] = {
			[4] = {x = 400,y = 200},
			[1] = {x = -400,y = 200},
			[3] = {x = 400,y = -200},
			[2] = {x = -400,y = -200},
			[5] = {x = 0,y = 0,scale = Vector3.one * 2},
		},
	}
	level = level or 3
	local cur_pos = level_pos[level]
	local t_d = {}
	for i=1,#cur_pos do
		t_d[i] = {}
		t_d[i].x = cur_pos[i].x
		t_d[i].y = cur_pos[i].y
		t_d[i].d_time = 0.2 * i
		if level == 3 and i == #cur_pos then 
			t_d[i].d_time = t_d[i].d_time + 0.3
		end
		t_d[i].o_x = t_d[i].x + 960
		t_d[i].o_y = t_d[i].y + 960
		t_d[i].scale = cur_pos[i].scale
	end

	local run_tt = 0
	if level == 1 then
		run_tt = 1.6
	elseif level == 2 then
		run_tt = 2.2
	else
		run_tt = 2.7
	end

	local pp = FishingLogic.GetPanel()
	local by_bg = pp.by_bg
	local bg = newObject("by_qpb_bgkuang",parent.transform)
	local max_num = #t_d
	local cur_num = 0
	for i,v in ipairs(t_d) do
		local prefab = CachePrefabManager.Take("by_qpb")
		prefab.prefab:SetParent(parent)
		local obj = prefab.prefab.prefabObj
		local tran = obj.transform
		tran.localPosition = {x = v.o_x,y = v.o_y}
		tran.localScale = v.scale or Vector3.one
		
		local mz_pre = CachePrefabManager.Take("buyu_miaozhunqi")
		mz_pre.prefab:SetParent(parent)
		local mz_tran = mz_pre.prefab.prefabObj.transform
		mz_tran.localPosition = {x = v.x,y = v.y}

		local seq = DoTweenSequence.Create()
		seq:AppendInterval(v.d_time)
		seq:AppendCallback(function ()
			if prefab then
				local ani = tran:GetChild(0):GetComponent("Animator")
				if ani then
					ani.enabled = true
				end
			end
		end)
		seq:Append(tran:DOLocalMove(Vector3.New(v.x, v.y, 0), 0.4))
		seq:SetEase(DG.Tweening.Ease.InSine)
		seq:AppendCallback(function ()
			if callback then callback() end
			if mz_pre then
				CachePrefabManager.Back(mz_pre)
			end
			if prefab then
				ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_zhadanyu.audio_name)
				local t = 1
				local shake = Vector3.New(40,40,0)
				local shake2d = Vector3.New(0.4,0.4,0)
				if level == 3 and i == #t_d then
					t = 2
					shake = Vector3.New(60,60,0)
					shake2d = Vector3.New(0.6,0.6,0)
				end
				seq:Append(by_bg.transform:DOShakePosition(t, shake2d,40))
			end
		end)
		seq:AppendInterval(3)
		seq:OnForceKill(function ()
			by_bg.transform.localPosition = Vector3.zero
			destroy(bg)
			if mz_pre then
				CachePrefabManager.Back(mz_pre)
			end
			if prefab then
				CachePrefabManager.Back(prefab)
			end
		end)
	end

	local run_seq = DoTweenSequence.Create()
	run_seq:AppendInterval(run_tt)
	run_seq:OnKill(function ()
		if forcecallback then forcecallback() end	
	end)
end

-- 事件来临预热 @data: type,player,time
function FishingAnimManager.ShowEventWarmUp(parent,data)
	if not data or not data.type or not data.time then return end
	parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local content = {
		[1] = string.format( "好运宝箱即将出现"),
		[2] = string.format( "玩家%s触发的奖励时刻即将出现",data.player),
		[3] = string.format( "高倍赢金鱼即将出现"),
		[4] = string.format( "小章鱼即将出现"),
		[5] = string.format( "玩家%s将禁止你的负炮捕鱼",data.player),
	}
	local prefab = CachePrefabManager.Take("event_warm_up")
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	tran.localPosition = Vector3.zero
	DOTweenManager.OpenPopupUIAnim(tran)
	local ui_t = {}
	LuaHelper.GeneratingVar(tran,ui_t)
	ui_t.hint_txt.text = content[data.type]
	local timer = nil
	local function close_timer()
		if timer then
			timer:Stop()
			timer = nil
		end
	end
	ui_t.ok_btn.onClick:AddListener(function (  )
		close_timer()
		if prefab then
			anim_close_ui_tab(ui_t)
			CachePrefabManager.Back(prefab)
		end
	end)
	local cd = data.time
	ui_t.hint_time_txt.text = cd
	timer = Timer.New(function()
		cd = cd -1
		ui_t.hint_time_txt.text = cd
	end, 1, cd, false, false)
	timer:Start()
	timer:SetStopCallBack(function()
		if prefab then
			anim_close_ui_tab(ui_t)
			CachePrefabManager.Back(prefab)
		end
	end)
end

--禁止开炮
function FishingAnimManager.ProhibitShoot(parent)
	FishingAnimManager.PlayShowAndHideFX(parent, "by_fengsuo_zi", Vector3.zero, 1.2, true)
end

-- 创鱼特效
function FishingAnimManager.PlayCreateFishFX(fish_tran)
	ExtendSoundManager.PlaySound(audio_config.by3d.bgm_bymatch_eyunxuanwo.audio_name)
	FishingAnimManager.PlayShowAndHideFX(fish_tran.parent, "by_zhaohuan", fish_tran.position, 3)

	fish_tran.localScale = Vector3.New(0.1, 0.1, 0.1)
	local targetScale = 1
	local seq = DoTweenSequence.Create()
	seq:Append(fish_tran:DOScale(targetScale, 1))
end

-- 快速射击
function FishingAnimManager.PlayKSSJFX(parent, beginPos, endPos, call)
	FishingAnimManager.PlayMoveAndHideFX(parent, "Superbullet_mfsk", beginPos, endPos, 2, 0.3, call)
end

-- 好运特效
function FishingAnimManager.PlayLuckFX(parent, data, beginPos, endPos)
    ExtendSoundManager.PlaySound(audio_config.by3d.bgm_bymatch_zhupaoshengji.audio_name)
	local prefab = CachePrefabManager.Take("by_sj_tw")
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = beginPos
	local seq = DoTweenSequence.Create()
	seq:Append(tran:DOMove(endPos, 0.5))
	seq:OnKill(function ()
		FishingAnimManager.PlayLuckFX1(parent, data)
	end)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)
	end)
end
function FishingAnimManager.PlayLuckFX1(parent, data)
	local fx_name = "luck_prefab"
	local keepTime = 3
	local prefab = GameObject.Instantiate(GetPrefab(fx_name), parent).gameObject
	prefab.transform.position = Vector3.zero
	prefab.transform.localScale = Vector3.one

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(keepTime)
	seq:OnForceKill(function ()
		destroy(prefab)
	end)
end
-- 超级好运特效
function FishingAnimManager.PlaySuperLuckFX()
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	FishingAnimManager.PlayShowAndHideFX(parent, "superluck_prefab", Vector3.zero, 3, true)
end

-- 贝壳出现特效
function FishingAnimManager.PlayBKCXFX(parent, beginPos)
	local prefab = CachePrefabManager.Take("bk_siwang")
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = beginPos

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(2)
	seq:OnForceKill(function ()
		if prefab then
			CachePrefabManager.Back(prefab)
		end
	end)
end

-- 技能金币汇总
function FishingAnimManager.PlaySkillAllGold(data, parent, endPos, delta_t)
	local add_score = function ()
		Event.Brocast("ui_gold_fly_finish_msg", data)
	end
	local call = function ()
		local fish_cfg
		if data.fish_cfg_id then
			fish_cfg = FishingModel.Config.fish_map[data.fish_cfg_id]
		else
			if data.type == FishingSkillManager.FishDeadAppendType.Boom then
				if data.parm and data.parm == "zt" then
					fish_cfg = FishingModel.Config.fish_map[29]
				elseif data.parm and data.parm == "zypd" then
					fish_cfg = FishingModel.Config.fish_map[49]
				elseif data.parm and data.parm == "zt1" then
					fish_cfg = FishingModel.Config.fish_map[29]
				else
					fish_cfg = FishingModel.Config.fish_map[19]
				end
			else
				fish_cfg = FishingModel.Config.fish_map[19]
			end
		end
		local parm = {dead_guang = fish_cfg.dead_guang, reward_image = fish_cfg.reward_image, icon = fish_cfg.icon, js3_td=fish_cfg.js3_td}
		FishingAnimManager.PlayBY3D_HDY_FX_1(parent, endPos, data.score, add_score, data.seat_num, 3, parm)
	end

	if delta_t then
		local seq1 = DoTweenSequence.Create()
		seq1:AppendInterval(delta_t)
		seq1:OnKill(function ()
			call()
		end)
	else
		call()
	end
end
-- 播放获得 Luck获得的道具
function FishingAnimManager.PlayLuckToolFX(parent, seat_num, beginPos, endPos, attr, num, call)
	ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_huodejineng.audio_name)

	local prefab = CachePrefabManager.Take("FishingFlyToolPrefab")
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	local icon = tran:Find("Icon"):GetComponent("Image")
	local anim = tran:GetComponent("Animator")
	anim.speed = 0
	tran.position = beginPos
	local cc = FishingSkillManager.FishDeadAppendMap[attr]
	if cc then
		icon.sprite = GetTexture(cc.icon)
	else
		dump(attr, "<color=red>EEE 播放获得额外道具表现</color>")
		icon.sprite = GetTexture("pond_btn_close")
	end
	tran.localScale = Vector3.New(3, 3, 3)

	local seq = DoTweenSequence.Create()
	seq:Append(tran:DOScale(0.8, 0.3):SetEase(DG.Tweening.Ease.InQuint))--OutElastic
	seq:AppendCallback(function ()
		FishingAnimManager.PlayShowAndHideFX(parent, "by_luck_reward", beginPos, 0.5)
	end)
	seq:Append(tran:DOScale(1, 0.1):SetEase(DG.Tweening.Ease.InQuint))
	seq:AppendInterval(1.6)
	seq:Append(tran:DOMoveBezier(endPos, 300, 0.5))
	seq:OnKill(function ()
		if call then call(num) end
	end)
	seq:OnForceKill(function ()
		if prefab then
			CachePrefabManager.Back(prefab)
		end
	end)
end

-- 一个固定位置的特效 显示一段时间消失
function FishingAnimManager.PlayShowAndHideFXAndCall(parent, fx_name, beginPos, keepTime, no_take, call, calltime)
	local prefab
	if no_take then
		prefab = GameObject.Instantiate(GetPrefab(fx_name), parent).gameObject
		prefab.transform.position = beginPos
		prefab.transform.localScale = Vector3.one
	else
		prefab = CachePrefabManager.Take(fx_name)
		prefab.prefab:SetParent(parent)
		local tran = prefab.prefab.prefabObj.transform
		tran.position = beginPos
		tran.localScale = Vector3.one
	end

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(calltime)
	seq:AppendCallback(function ()
		if call then
			call()
		end
	end)
	seq:AppendInterval(keepTime-calltime)
	seq:OnForceKill(function ()
		if no_take then
			destroy(prefab)
		else
			CachePrefabManager.Back(prefab)
		end
	end)		
end

-- 排名提升
function FishingAnimManager.PlayRankUp(parent, beginPos, endPos)
	local prefab = CachePrefabManager.Take("rank_up")
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	tran.localScale = Vector3.New(3, 3, 3)
	tran.position = beginPos

	local seq = DoTweenSequence.Create()
	seq:Append(tran:DOScale(1, 0.2):SetEase(DG.Tweening.Ease.InQuint))
	seq:AppendInterval(1)
	seq:Append(tran:DOMove(endPos, 0.3):SetEase(DG.Tweening.Ease.InQuint))
	seq:OnKill(function ()
	    ExtendSoundManager.PlaySound(audio_config.by3d.bgm_bymatch_zhupaozhuangji.audio_name)
	    Event.Brocast("ui_fish_match_rank_up_msg")
	end)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)
	end)	

end

-- 召唤鱼的特效
function FishingAnimManager.PlaySummonFishFX(parent, beginPos)
	ExtendSoundManager.PlaySound(audio_config.by.bgm_bymatch_eyunxuanwo.audio_name)
	FishingAnimManager.PlayShowAndHideFX(parent, "by_zhaohuan_jing", beginPos, 3)
end

-- 特殊鱼
function FishingAnimManager.PlaySpecialFishFX(parent, data)
	local use_fish_cfg = FishingModel.Config.use_fish_map[data.use_fish]
	if not use_fish_cfg then
		return
	end
	local fish_cfg = FishingModel.Config.fish_map[use_fish_cfg.fish_id]
	if not fish_cfg then
		return
	end

	local icon = fish_cfg.icon
	local name_image = fish_cfg.name_image
	if fish_cfg.prefab == "Fish_Act" then
		local a, _cfg = GameButtonManager.RunFunExt("act_ty_by_drop", "GetFishConfig")
		if a and _cfg then
			icon = _cfg.icon
			name_image = _cfg.name_image
		end
	end
	
	ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_hdylaixi.audio_name)

	local prefab = CachePrefabManager.Take("tsy_fish3d")
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	tran.localPosition = Vector3.New(0, 200, 0)
	local ui = {}
	LuaHelper.GeneratingVar(tran, ui)
	ui.icon_img.sprite = GetTexture(icon)
	ui.icon_img:SetNativeSize()
	ui.name_img.sprite = GetTexture(name_image)
	ui.name_img:SetNativeSize()

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(1.5)
	seq:OnForceKill(function ()
		anim_close_ui_tab(ui)
		CachePrefabManager.Back(prefab)
	end)
end

local special_fish3d_cfg_map = {}
special_fish3d_cfg_map[39] = {icon="yle_icon_bwx", type="yle_imgf_bwx"}
special_fish3d_cfg_map[40] = {icon="yle_icon_shj", type="yle_imgf_shjj"}
special_fish3d_cfg_map[41] = {icon="yle_icon_syjj", type="yle_imgf_syjj"}
special_fish3d_cfg_map[43] = {icon="yle_icon_yglg", type="yle_imgf_yglg"}
special_fish3d_cfg_map[38] = {icon="yle_icon_hjjl", type="yle_imgf_hjjl"}

-- 小boss来临
function FishingAnimManager.PlaySmallBossFX(parent, data)
	ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_hdylaixi.audio_name)

	local prefab = CachePrefabManager.Take("special_fish3d1")
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	tran.localPosition = Vector3.New(0, 0, 0)
	local ui = {}
	LuaHelper.GeneratingVar(tran, ui)
	ui.icon_glow_img = ui.icon_glow:GetComponent("Image")
	local use_fish_cfg = FishingModel.Config.use_fish_map[data.use_fish]
	local fish_cfg = FishingModel.Config.fish_map[use_fish_cfg.fish_id]

	local cfg = special_fish3d_cfg_map[fish_cfg.id]
	if cfg then
		ui.icon_img.sprite = GetTexture(cfg.icon)
		if cfg.type then
			ui.type_img.gameObject:SetActive(true)
			ui.type_img.sprite = GetTexture(cfg.type)
		else
			ui.type_img.gameObject:SetActive(false)
		end
		ui.reat_txt.text = fish_cfg.rate
	else
		dump(fish_cfg, "<color=red>EEE 小boss的表现没有对应配置</color>")
	end

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(1.5)
	seq:OnForceKill(function ()
		anim_close_ui_tab(ui)
		CachePrefabManager.Back(prefab)
	end)
end

-- 大boss来临
function FishingAnimManager.PlayBigBossFX(parent)
	FishingAnimManager.PlayShowAndHideFX(parent, "by_boss", Vector3.zero, 2.5)
end

-- 新人红包任务出现
function FishingAnimManager.PlayNewPlayerRedTaskAppear(parent, beginPos, endPos, call)
	local prefab = CachePrefabManager.Take("by_hongbaorenwu_cx")
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = beginPos

    local seq = DoTweenSequence.Create()
    seq:AppendInterval(2)
    seq:Append(tran:DOMove(endPos, 0.3):SetEase(DG.Tweening.Ease.InQuint))
    seq:AppendCallback(function ()
	    Event.Brocast("ui_shake_screen_msg")
    end)
    seq:AppendInterval(0.5)
    seq:AppendCallback(function ()
	    if call then
	    	call()
	    end
	    call = nil
    end)
    seq:AppendInterval(1)
    seq:OnKill(function ()
	    if call then
	    	call()
	    end
	    call = nil
    end)
    seq:OnForceKill(function ()
		if prefab then
			CachePrefabManager.Back(prefab)
		end
	end)
end

-- 幸运宝箱 死亡前优化
function FishingAnimManager.PlayXYBXDeadQZ(parent, beginPos, data)
	if true then -- 屏蔽
		return
	end
	local prefab_name = ""
	if data.type == FishingSkillManager.FishDeadAppendType.summon_fish then

	elseif data.type == FishingSkillManager.FishDeadAppendType.FreeBullet
		or data.type == FishingSkillManager.FishDeadAppendType.AddForce
		or data.type == FishingSkillManager.FishDeadAppendType.DoubleTime then
	end

	local prefab = CachePrefabManager.Take(prefab_name)
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = beginPos

    local seq = DoTweenSequence.Create()
    seq:AppendInterval(2)
    seq:OnForceKill(function ()
		if prefab then
			CachePrefabManager.Back(prefab)
		end
	end)
end

-- 财神鱼死亡效果
function FishingAnimManager.PlayCSFishDead(data, parent, beginPos, endPos, playerPos, mbPos, name_image, delta_t)
	ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_jiangli5.audio_name)
	local prefab = CachePrefabManager.Take("cs_anim_prefab")
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	tran.localScale = Vector3.one
	tran.position = beginPos
	local ui = {}
	LuaHelper.GeneratingVar(tran, ui)
	obj:SetActive(false)
	
	local number_to_array = function(number, len)
		local tbl = {}
		local nn = number
		while nn > 0 do
			tbl[#tbl + 1] = nn % 10
			nn = math.floor(nn / 10)
		end

		local array = {}
		if len then
			if len > #tbl then
				for idx = len, 1, -1 do
					if idx > #tbl then
						array[#array + 1] = 0
					else
						array[#array + 1] = ""..tbl[idx]
					end
				end
			else
				for idx = #tbl, 1, -1 do
					array[#array + 1] = ""..tbl[idx]
				end
				print("<color=red>EEE 长度定义不合理 number = " .. number .. "  len = " .. len .. "</color>")
			end
		else
			for idx = #tbl, 1, -1 do
				array[#array + 1] = ""..tbl[idx]
			end
		end
		return array
	end

	local arr = number_to_array(data.score, 8)

	-- 滚动数据
	local item_list = {}
	for i = 1, 8 do
		item_list[#item_list + 1] = ui["Mask"..i].gameObject
	end

	local seq = DoTweenSequence.Create()
	if delta_t and delta_t > 0 then
		seq:AppendInterval(delta_t)
		seq:AppendCallback(function ()
			obj:SetActive(true)
			FishingAnimManager.ScrollLuckyChangeToFiurt(item_list,arr,function ()
				print("<color=red>滚动完成XXXXXXXXXXXXX</color>")
			end)
		end)
	else
		obj:SetActive(true)
		FishingAnimManager.ScrollLuckyChangeToFiurt(item_list,arr,function ()
			print("<color=red>滚动完成XXXXXXXXXXXXX</color>")
		end)
	end
	seq:AppendInterval(3)
	seq:Append(tran:DOMove(endPos, 0.3):SetEase(DG.Tweening.Ease.InQuint))
	seq:OnKill(function ()
		Event.Brocast("ui_gold_fly_finish_msg", data)
		FishingAnimManager.PlayGoldBigFX(parent, mbPos)
	end)
	seq:OnForceKill(function ()
		anim_close_ui_tab(ui)
		CachePrefabManager.Back(prefab)
	end)
end

--财神鱼数字滚动
function FishingAnimManager.ScrollLuckyChangeToFiurt(item_list,data_list,callback)
	local item_map = {}--数据转换
	for x=1,#item_list do
		item_map[x] = item_map[x] or {}
		item_map[x][1] = {}
		item_map[x][1].data = {id=data_list[x], x=x, y=1}
		item_map[x][1].ui = {}
		item_map[x][1].ui.gameObject = item_list[x]
		item_map[x][1].ui.transform = item_map[x][1].ui.gameObject.transform
		LuaHelper.GeneratingVar(item_map[x][1].ui.transform, item_map[x][1].ui)
		item_map[x][1].ui.num_txt.text = item_map[x][1].data.id
	end

	local change_up_t = 0.2 --加速时间
	local change_uni_t = 0.02 --每一次滚动时间
	local change_down_t = 0.2 --减速时间
	local change_uni_d = 2 --匀速滚动时长
	local change_up_d = 0.04 --滚动加速间隔

	local speed_status = {
		speed_up = "speed_up",
		speed_uniform = "speed_uniform",
		speed_down = "speed_down",
		speed_end = "speed_end",
	}
	local material_FrontBlur = GetMaterial("FrontBlur")
	local spacing = 65 + 0
	local add_y_count = 3
	local down_count = 0
	local all_count = 0
	local all_fruit_map = {}
	for x,_v in pairs(item_map) do
		for y,v in pairs(_v) do
			all_count = all_count + 1
		end
	end
	all_count = all_count * add_y_count

	local speed_uniform
	local speed_up
	local speed_down

	local function get_pos_by_index(x,y,size_x,size_y,spac_x,spac_y)
		size_x = size_x or 46
		size_y = size_y or 65
		spac_x = spac_x or 0
		spac_y = spac_y or 0
		local pos = {x = 0,y = 0}
		pos.x = (x - 1) * (size_x + spac_x)
		pos.y = (y - 1) * (size_y + spac_y)
		return pos
	end

	local function get_index_by_pos(x,y,size_x,size_y,spac_x,spac_y)
		size_x = size_x or 46
		size_y = size_y or 65
		spac_x = spac_x or 0
		spac_y = spac_y or 0
		local index = {x = 1,y = 1}
		index.x = math.floor(x / (size_x + spac_x)) + 1
		index.y = math.floor(y / (size_y + spac_y)) + 1
		return index
	end

	local function create_obj(data)
		local _obj = {}
		_obj.ui = {}
		_obj.data = data
		local parent = _obj.data.parent
		if not parent then return end
		_obj.ui.gameObject = GameObject.Instantiate(data.obj, parent)
		_obj.ui.transform = _obj.ui.gameObject.transform
		_obj.ui.transform.localPosition = get_pos_by_index(_obj.data.x,_obj.data.y)
		_obj.ui.gameObject.name = _obj.data.x .. "_" .. _obj.data.y
		LuaHelper.GeneratingVar(_obj.ui.transform, _obj.ui)
		_obj.ui.num_txt.text = data.id
		--_obj.ui.num_txt = nil
		return _obj
	end

	local function call(v)
		if not v.obj.ui or not v.obj.ui.transform or not IsEquals(v.obj.ui.transform) then return end
		if v.status == speed_status.speed_up or v.status == speed_status.speed_uniform or v.status == speed_status.speed_down then
			if v.status == speed_status.speed_up then
				--v.obj.ui.num_txt.material = material_FrontBlur
			elseif v.status == speed_status.speed_down then
				v.obj.ui.num_txt.material = nil
			end
			if v.obj.ui.transform.localPosition.y < -spacing then
				v.obj.ui.transform.localPosition = get_pos_by_index(1,2)
				v.obj.ui.num_txt.text = math.random( 0,9)
			end
		elseif v.status == speed_status.speed_end then
			down_count = down_count + 1
			if down_count == all_count then
				for x,_v in pairs(item_map) do
					for y,v in pairs(_v) do
						v.ui.num_txt.gameObject:SetActive(true)
					end
				end
				for x1,_v1 in pairs(all_fruit_map) do
					for y1,v1 in pairs(_v1) do
						for x2,_v2 in pairs(v1) do
							for y2,v2 in pairs(_v2) do
								Destroy(v2.obj.ui.gameObject)
							end
						end
					end
				end
				all_fruit_map = {}
				if callback and type(callback) == "function" then
					callback()
				end
			end
		end
		if v.status == speed_status.speed_up then
			v.status = speed_status.speed_uniform --加速完成进入匀速状态
		end
		if v.status == speed_status.speed_uniform then
			speed_uniform(v)
		elseif v.status == speed_status.speed_up then
			speed_up(v)
		elseif v.status == speed_status.speed_down then
			speed_down(v)
		end
	end

	speed_up = function  (v)
		v.status = speed_status.speed_up
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, change_up_t))
		seq:SetEase(DG.Tweening.Ease.InCirc)
		seq:OnForceKill(function ()
			call(v)
		end)
	end

	speed_uniform = function (v)
		v.status = speed_status.speed_uniform
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, change_uni_t))
		seq:SetEase(DG.Tweening.Ease.Linear)
		seq:OnForceKill(function ()
			call(v)
		end)
	end

	speed_down = function (v)
		v.status = speed_status.speed_down
		local index = get_index_by_pos(v.obj.ui.transform.localPosition.x,v.obj.ui.transform.localPosition.y)
		if index.y == 2 then
			local id = item_map[v.real_x][v.real_y].data.id
			v.obj.ui.num_txt.text = id
		end
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, change_down_t))
		seq:SetEase(DG.Tweening.Ease.OutCirc)
		seq:OnForceKill(function ()
			v.status = speed_status.speed_end
			call(v)
		end)
	end

	local function lucky_chang_to_fruit(v_obj,index_x)
		if not IsEquals(item_map[index_x][1].ui.gameObject) then
			return
		end
		local fruit_map = {}
		local id
		local ins_obj = GameObject.Instantiate(item_map[index_x][1].ui.gameObject)
		for y=1,add_y_count do
			if y == 1 then
				id = v_obj.data.id
			else
				id = math.random(0,9)
			end
			fruit_map[1] = fruit_map[1] or {}
			fruit_map[1][y] ={obj = create_obj({obj = ins_obj,x = 1,y = y,id = id ,parent = v_obj.ui.transform}),status = speed_status.speed_up,real_x = v_obj.data.x,real_y = v_obj.data.y}
			local v = fruit_map[1][y]
			if v.obj.ui.transform.localPosition.y < -spacing then
				v.obj.ui.transform.localPosition = get_pos_by_index(1,2)
				v.obj.ui.num_txt.text = math.random(0,9)
			end
			speed_up(fruit_map[1][y])
		end
		--隐藏自己
		v_obj.ui.num_txt.gameObject:SetActive(false)
		Destroy(ins_obj)
		return fruit_map
	end

	--一列一列加速改变
	local x = 1
	local change_up_timer
	if change_up_timer then change_up_timer:Stop() end
	change_up_timer = Timer.New(function()
		if item_map[x] then
			for y=1,8 do
				local v = item_map[x][y]
				if v then
					all_fruit_map[x] = all_fruit_map[x] or {}
					all_fruit_map[x][y] = lucky_chang_to_fruit(v,x)
				end
			end
		end
		x = x + 1
		if x == 8 then
			local m_callback = function(  )
				for x,_v in pairs(all_fruit_map) do
					for y,v in pairs(_v) do
						for x1,v1 in pairs(v) do
							for y1,v2 in pairs(v1) do
								v2.status = speed_status.speed_down
							end
						end
					end
				end
			end
			local change_uni_timer = Timer.New(function ()
				m_callback()
			end,change_uni_d,1)
			change_uni_timer:Start()
		end
	end,change_up_d,8)
	change_up_timer:Start()
end
-- 原子弹炸空效果
function FishingAnimManager.PlayYZD_Null(data, parent)
	FishingAnimManager.PlayShowAndHideFX(parent, "hyh_prefab", Vector3.zero, 1)
end

------------------------
--- 3D表现
------------------------
-- 一个固定位置的特效 显示一段时间消失
-- 支持回调方法在中间位置出现
function FishingAnimManager.PlayShowAndHideFX_CallTime(parent, fx_name, beginPos, keepTime, no_take, call, call_time)
	local prefab
	if no_take then
		prefab = GameObject.Instantiate(GetPrefab(fx_name), parent).gameObject
		prefab.transform.position = beginPos
		prefab.transform.localScale = Vector3.one
	else
		prefab = CachePrefabManager.Take(fx_name)
		prefab.prefab:SetParent(parent)
		local tran = prefab.prefab.prefabObj.transform
		tran.position = beginPos
		tran.localScale = Vector3.one
	end

	local seq = DoTweenSequence.Create()
	if call_time then
		seq:AppendInterval(call_time)
		seq:AppendCallback(function ()
			if call then
				call()
			end
			call = nil
		end)
		keepTime = keepTime - call_time
		if keepTime < 0 then
			keepTime = nil
		end
	end
	if keepTime then
		seq:AppendInterval(keepTime)
	end
	seq:OnKill(function ()
		if call then
			call()
		end
		call = nil
	end)
	seq:OnForceKill(function ()
		if no_take then
			destroy(prefab)
		else
			CachePrefabManager.Back(prefab)
		end
	end)		
end


-- 转盘抽奖
function FishingAnimManager.PlayBY3D_ZPCJAnim(data, parent)
	
	Event.Brocast("ui_gold_fly_finish_msg", {seat_num = data.jn_data.seat_num, score = data.jn_data.add_score})
end
-- 电磁炮安装特效
function FishingAnimManager.PlayBY3D_AZDCP(parent, beginPos)
	FishingAnimManager.PlayShowAndHideFX(parent, "fishing3D_diancipao_luoxia", beginPos, 1)
end
-- 电磁炮发射特效
function FishingAnimManager.PlayBY3D_FSDCP(parent, seat_num, beginPos, r)
	Event.Brocast("ui_shake_screen_msg", 3.5, 0.3)

	local prefab = CachePrefabManager.Take("fishing3D_diancipao2")
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	tran.rotation = Quaternion.Euler(0, 0, r)
	tran.position = beginPos

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(3.5)
	seq:OnKill(function ()
	end)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)		
	end)
end
-- boss鱼潮
function FishingAnimManager.PlayBY3D_BSYC(parent, call)
	local boss_id = FishingModel.GetBossType()
    if boss_id == 0 then

    elseif boss_id == 1 then
    	FishingAnimManager.PlayShowAndHideFX(parent, "fishing3D_hwlx_jc", Vector3.zero, 3.2, nil, function ()
    		ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_bossAchuchang.audio_name)
	        Event.Brocast("ui_shake_screen_msg", 1, 0.3)
	        local seq = DoTweenSequence.Create()
	        seq:AppendInterval(3)
	        seq:OnKill(function ()
	    		ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_bossAchuchang.audio_name)
	        	Event.Brocast("ui_shake_screen_msg", 1, 0.3)
	        	if call then
	        		call()
	        	end
			end)
	    end)
    elseif boss_id == 2 then
    	FishingAnimManager.PlayShowAndHideFX(parent, "fishing3D_hwlx_sy", Vector3.zero, 3.3, nil, call)
    elseif boss_id == 3 then
    	FishingAnimManager.PlayShowAndHideFX(parent, "fishing3D_hwlx_ey", Vector3.zero, 3.2, nil, function ()
	    	FishingAnimManager.PlayShowAndHideFX_CallTime(parent, "fishing3D_hwlx_ey_glow", Vector3.zero, 4.5, nil, call, 2.2)
	
	    	ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_bossCchuchang.audio_name)
	    	local seq = DoTweenSequence.Create()
			seq:AppendInterval(1.1)
			seq:AppendCallback(function ()
		    	ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_bossCchuchang.audio_name)
			end)
			seq:AppendInterval(1.1)
			seq:OnKill(function ()
				ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_bossCchuchang1.audio_name)
			end)
    	end)
    elseif boss_id == 4 then
    	FishingAnimManager.PlayShowAndHideFX(parent, "fishing3D_hwlx_zy", Vector3.zero, 3.2, nil, function ()
    		local seq = DoTweenSequence.Create()
			seq:AppendCallback(function ()
				ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_bossDchuchang.audio_name)
				Event.Brocast("ui_shake_screen_msg", 1, 0.6)
			end)
			seq:AppendInterval(1.5)
			seq:AppendCallback(function ()
				ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_bossDchuchang.audio_name)
				Event.Brocast("ui_shake_screen_msg", 1, 0.6)
			end)
			seq:AppendInterval(1.5)
			seq:OnKill(function ()
				ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_bossDchuchang1.audio_name)
				Event.Brocast("ui_shake_screen_msg", 1, 0.6)
				FishingAnimManager.PlayShowAndHideFX(parent, "hwlx_zy_mozhi", Vector3.zero, 2, nil, call)
			end)
    		
    	end)
    else

	end
end
-- 打赢家 高级表现
function FishingAnimManager.PlayBY3D_DYJ(parent, beginPos, endPos, money, callback, seat_num, style)
	local LayerLv2 = FishingLogic.GetPanel().LayerLv2

	local prefab = CachePrefabManager.Take("Fishing3D_dyj")
	prefab.prefab:SetParent(LayerLv2)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	tran.localPosition = Vector3.New(0, 80, -200)
	tran.localScale = Vector3.one

	local gold_txt = tran:Find("ban/Text"):GetComponent("Text")
	gold_txt.font = FishingAnimManager.GetFontBySeatNum2(seat_num)
	local update_time
	local cur_m = 0
	local spt = 0.04
	local spm = math.max(1, math.ceil(money / (2.2 * 1 / spt)))

	local function close_timer()
		if update_time then
			update_time:Stop()
			update_time = nil
		end
	end
	local function set_money(value)
		if IsEquals(gold_txt) then
			gold_txt.text = value
		end
	end
	update_time = Timer.New(function ()
		cur_m = cur_m + spm
		if cur_m > money then
			cur_m = money
			close_timer()
		end
		set_money(cur_m)
	end, spt, -1)
	update_time:Start()
	set_money(cur_m)

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(3)
	seq:OnKill(function ()
		if callback then
			callback()
		end
	end)
	seq:OnForceKill(function ()
		close_timer()
		CachePrefabManager.Back(prefab)		
	end)
end
function FishingAnimManager.PlayBY3D_DYJ_Oth(parent, beginPos, endPos, money, callback, seat_num, style)
	beginPos.z = -200
	local LayerLv2 = FishingLogic.GetPanel().LayerLv2

	local prefab = CachePrefabManager.Take("Fishing3D_dyj_xiao")
	prefab.prefab:SetParent(LayerLv2)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	tran.position = beginPos
	tran.localScale = Vector3.one

	local gold_txt = tran:Find("Fishing3D_dyj/ban/Text"):GetComponent("Text")
	gold_txt.font = FishingAnimManager.GetFontBySeatNum2(seat_num)
	local update_time
	local cur_m = 0
	local spt = 0.04
	local spm = math.max(1, math.ceil(money / (2.2 * 1 / spt)))

	local function close_timer()
		if update_time then
			update_time:Stop()
			update_time = nil
		end
	end
	local function set_money(value)
		if IsEquals(gold_txt) then
			gold_txt.text = value
		end
	end
	update_time = Timer.New(function ()
		cur_m = cur_m + spm
		if cur_m > money then
			cur_m = money
			close_timer()
		end
		set_money(cur_m)
	end, spt, -1)
	update_time:Start()
	set_money(cur_m)

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(3)
	seq:OnKill(function ()
		if callback then
			callback()
		end
	end)
	seq:OnForceKill(function ()
		close_timer()
		CachePrefabManager.Back(prefab)		
	end)
end
-- 活动鱼 中级表现
function FishingAnimManager.PlayBY3D_HDY(parent, beginPos, endPos, money, callback, seat_num, style, cfg_fish_id, dead_rate,active_rate)
	local cfg = FishingModel.Config.fish_map[cfg_fish_id]
	if not cfg then
		dump(cfg_fish_id, "<color=red></color>")
		if callback then
			callback()
		end
		return
	end
	local parm = {dead_guang = cfg.dead_guang, reward_image = cfg.reward_image, icon = cfg.icon, js3_td=cfg.js3_td,rate = cfg.rate}
	FishingAnimManager.PlayBY3D_HDY_FX(parent, beginPos, endPos, money, callback, seat_num, style, parm, dead_rate,active_rate)
end
-- 活动鱼 中级表现
function FishingAnimManager.PlayBY3D_HDY_FX(parent, beginPos, endPos, money, callback, seat_num, style, parm, dead_rate, active_rate)
	endPos.z = -200
	local LayerLv2 = FishingLogic.GetPanel().LayerLv2

	FishingAnimManager.PlayShowAndHideFX(LayerLv2, "Fishing3D_js_jingbi", endPos, 1, nil)

	FishingAnimManager.PlayBY3D_Guang(parent, parm.dead_guang, beginPos)	

	FishingAnimManager.PlayBY3D_HDY_FX_1(parent, endPos, money, callback, seat_num, style, parm, dead_rate, active_rate)
end
-- 中级表现
function FishingAnimManager.PlayBY3D_HDY_FX_1(parent, endPos, money, callback, seat_num, style, parm, dead_rate, active_rate)
	endPos.z = -200
	local LayerLv2 = FishingLogic.GetPanel().LayerLv2

	local prefab = CachePrefabManager.Take("Fishing3D_UI_zdy")
	prefab.prefab:SetParent(LayerLv2)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	tran.position = endPos
	tran.localScale = Vector3.one

	local anim = tran:GetComponent("Animator")
	anim:Play("run")
	if style == 3 then
    	ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_jiangli3.audio_name)
	else
    	ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_jiangli4.audio_name)
	end
	local gold_txt = tran:Find("wz_zx/Text"):GetComponent("Text")
	local yu_img = tran:Find("yu/tu"):GetComponent("Image")
	local yu_name_img = tran:Find("wenzi/Image"):GetComponent("Image")
	yu_name_img.sprite = GetTexture(parm.reward_image)
	yu_name_img:SetNativeSize()
	gold_txt.font = FishingAnimManager.GetFontBySeatNum2(seat_num)
	yu_img.sprite = GetTexture(parm.icon)
	yu_img:SetNativeSize()
	if style == 3 then
		--双倍黄金鱼
		--[[dump(parm,"<color=yellow><size=15>++++++++++parm++++++++++</size></color>")
		dump(dead_rate,"<color=yellow><size=15>++++++++++dead_rate++++++++++</size></color>")
		dump(active_rate,"<color=yellow><size=15>++++++++++active_rate++++++++++</size></color>")--]]
		if parm.rate and ((dead_rate / (active_rate or 1)) > parm.rate) then
			gold_txt.text = StringHelper.ToAddDH(money/2)
			local seq = DoTweenSequence.Create()
			seq:AppendInterval(2)
			seq:AppendCallback(function ()
				GameComAnimTool.PlayShowAndHideAndCall(tran,"3dby_baoji_fx",tran.position,2,0.6,function ()
					--gold_txt.transform.localScale = Vector3.New(3,3,3)
					local seq = DoTweenSequence.Create()
					seq:AppendCallback(function ()
						gold_txt.text = StringHelper.ToAddDH(money)
					end)
					seq:AppendInterval(1.4)
					--seq:Append(gold_txt.transform:DOScale(1.8, 0.5))
					seq:OnKill(function ()
						if callback then
							callback()
						end
					end)
					seq:OnForceKill(function ()
						CachePrefabManager.Back(prefab)
						prefab = nil
					end)
				end)
			end)
		else
			gold_txt.text = StringHelper.ToAddDH(money)
			local seq = DoTweenSequence.Create()
			seq:AppendInterval(2)
			seq:AppendCallback(function ()
				anim:Play("end")
			end)
			seq:AppendInterval(0.7)
			seq:OnKill(function ()
				if callback then
					callback()
				end
			end)
			seq:OnForceKill(function ()
				CachePrefabManager.Back(prefab)
			end)
		end
	else
		if not parm.js3_td then
			local update_time
			local cur_m = 0
			local spt = 0.04
			local spm = math.max(1, math.ceil(money / (1.5 * 1 / spt)))

			local function close_timer()
				if update_time then
					update_time:Stop()
					update_time = nil
				end
			end
			local function set_money(value)
				if IsEquals(gold_txt) then
					gold_txt.text = StringHelper.ToAddDH(value)
				end
			end
			update_time = Timer.New(function ()
				cur_m = cur_m + spm
				if cur_m > money then
					cur_m = money
					close_timer()
				end
				set_money(cur_m)
			end, spt, -1)
			update_time:Start()
			set_money(cur_m)

			local seq = DoTweenSequence.Create()
			seq:AppendInterval(2.7)
			seq:OnKill(function ()
				if callback then
					callback()
				end
			end)
			seq:OnForceKill(function ()
				close_timer()
				CachePrefabManager.Back(prefab)
			end)
		else
			local td = parm.js3_td
			local nn = math.floor(money / dead_rate)
			local run1
			local add_audio_name = "bgm_by_count_"
			local dd_audio_name = "bgm_by_countEnd_"
			local audio_key
			run1 = function (i)
			local a_i = i
			if a_i > 6 then
				a_i = 6
			end
				audio_key = ExtendSoundManager.PlaySound(audio_config.by3d[add_audio_name..a_i].audio_name, -1)
				local begin_num = 0
				local end_num = money
				if td[i-1] then
					begin_num = td[i-1] * nn
				end
				if td[i] and dead_rate > td[i] then
					end_num = td[i] * nn
				end
				FishingAnimManager.PlayMoneyChangeAnim(gold_txt, begin_num, end_num, 2, function ()
					soundMgr:CloseLoopSound(audio_key)
					audio_key = nil
					ExtendSoundManager.PlaySound(audio_config.by3d[dd_audio_name..a_i].audio_name, 1)
					if not IsEquals(gold_txt) then
						return
					end
					if end_num == money then
						-- 等一秒消失
						gold_txt.transform.localScale = Vector3.New(3,3,3)
						local seq = DoTweenSequence.Create()
						seq:Append(gold_txt.transform:DOScale(1.8, 0.5))
						seq:AppendInterval(1)
						seq:AppendCallback(function ()
							anim:Play("end")
						end)
						seq:AppendInterval(0.7)
						seq:OnKill(function ()
							if audio_key then
								soundMgr:CloseLoopSound(audio_key)
								audio_key = nil
							end
							if callback then
								callback()
							end
						end)
						seq:OnForceKill(function ()
							CachePrefabManager.Back(prefab)
							prefab = nil
						end)
					else
						gold_txt.transform.localScale = Vector3.New(3,3,3)
						local seq = DoTweenSequence.Create()
						seq:Append(gold_txt.transform:DOScale(1.8, 0.5))
						seq:OnKill(function ()
							run1(i+1)
						end)
						seq:OnForceKill(function (force_kill)
							if force_kill then
								CachePrefabManager.Back(prefab)
								prefab = nil
							end
						end)
					end
				end, function ()
					if audio_key then
						soundMgr:CloseLoopSound(audio_key)
						audio_key = nil
					end
					CachePrefabManager.Back(prefab)
					prefab = nil
				end)				
			end
			run1(1)
		end
	end
end
-- 自己的活动 通用结算
function FishingAnimManager.PlayBY3D_HDY_FX_MY(money, fish_id)
	local panel = FishingLogic.GetPanel()
	local seat_num = FishingModel.GetPlayerSeat()
	local data = {seat_num=seat_num, score=money}
	local endPos = panel.PlayerClass[seat_num]:GetPlayerFXPos()
	local fish_cfg = FishingModel.Config.fish_map[fish_id]
	local parm = {dead_guang = fish_cfg.dead_guang, reward_image = fish_cfg.reward_image, icon = fish_cfg.icon}
	FishingAnimManager.PlayBY3D_HDY_FX_1(panel.FXNode, endPos, money, function ()
		Event.Brocast("ui_gold_fly_finish_msg", data)
	end, seat_num, 3, parm)
end

function FishingAnimManager.PlayMoneyChangeAnim(gold_txt, begin_num, end_num, t, finish_call, forcekill_call)
	local update_time
	local cur_m = begin_num
	local spt = 0.04
	local money = end_num - begin_num
	local spm = math.max(1, math.ceil(money / (t * 1 / spt)))

	local function close_timer()
		if update_time then
			update_time:Stop()
			update_time = nil
		end
	end
	local function set_money(value)
		if IsEquals(gold_txt) then
			gold_txt.text = StringHelper.ToAddDH(value)
		else
			close_timer()
		end
	end
	update_time = Timer.New(function ()
		cur_m = cur_m + spm
		if cur_m > end_num then
			cur_m = end_num
			close_timer()
		end
		set_money(cur_m)
	end, spt, -1)
	update_time:Start()
	set_money(cur_m)

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(t)
	seq:OnKill(function ()
		if finish_call then
			finish_call()
		end
	end)
	seq:OnForceKill(function (force_kill)
		close_timer()
		if force_kill and forcekill_call then
			forcekill_call()
		end
	end)
	
end

local zpy_name_list = {"3dby_imgf_bdqf","3dby_imgf_lgw","3dby_imgf_lhlwdg","3dby_imgf_lt6","3dby_imgf_cyll","3dby_imgf_zfl"}
-- 转盘鱼 低级表现
function FishingAnimManager.PlayBY3D_ZPY(parent, beginPos, endPos, name_image, money, callback, seat_num, style, cfg_fish_id)
	local cfg = FishingModel.Config.fish_map[cfg_fish_id]
	if not cfg then
		dump(cfg_fish_id, "<color=red></color>")
		if callback then
			callback()
		end
		return
	end
	endPos.z = -200
	local LayerLv2 = FishingLogic.GetPanel().LayerLv2

	FishingAnimManager.PlayShowAndHideFX(LayerLv2, "Fishing3D_js_jingbi", endPos, 1, nil)
	
	FishingAnimManager.PlayBY3D_Guang(parent, cfg.dead_guang, beginPos)	

	local prefab = CachePrefabManager.Take("Fishing3D_djxg")
	prefab.prefab:SetParent(LayerLv2)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	tran.position = endPos
	tran.localScale = Vector3.one
	local ui_t = {}
	LuaHelper.GeneratingVar(tran, ui_t)

	ui_t.gold_txt.font = FishingAnimManager.GetFontBySeatNum2(seat_num)
	ui_t.gold_txt.text = StringHelper.ToAddDH(money)

	local nm = zpy_name_list[math.random(1,#zpy_name_list)]
	ui_t.name_img.sprite = GetTexture(nm)
	ui_t.name_img:SetNativeSize()

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(2.3)
	seq:OnKill(function ()
		if callback then
			callback()
		end
	end)
	seq:OnForceKill(function ()
		anim_close_ui_tab(ui_t)
		CachePrefabManager.Back(prefab)		
	end)
end
-- 金蟾鱼死亡效果
function FishingAnimManager.PlayJCFishDead(data, parent, beginPos, endPos, playerPos, mbPos, name_image, delta_t)
	local LayerLv2 = FishingLogic.GetPanel().LayerLv2
	FishingAnimManager.PlayTSFishDeadHint(parent, beginPos, data.fish_cls.gameObject, function ()
		
		FishingAnimManager.PlayBY3D_Guang(parent, 1, beginPos)
		FishingAnimManager.PlayGold(data, parent, beginPos, endPos, {3,6}, nil)
		FishingAnimManager.PlayShowAndHideFX(LayerLv2, "Fishing3D_jingbi", beginPos, 2, nil)
    end)
end

function FishingAnimManager.PlayBY3D_Guang(parent, dead_guang, beginPos)
	if dead_guang then
		if dead_guang == 1 then
			Event.Brocast("ui_shake_screen_msg", 1, 0.6)
			FishingAnimManager.PlayShowAndHideFX(parent, "Fishing3D_siwang_jin", beginPos, 1, nil)
		else
			Event.Brocast("ui_shake_screen_msg", 1, 0.3)
			FishingAnimManager.PlayShowAndHideFX(parent, "Fishing3D_siwang_lan", beginPos, 1, nil)
		end
	end

end

-- 炸弹鱼死亡前奏效果 红光
function FishingAnimManager.PlayBY3D_ZDFishDead_QZ_HG(parent, ss, beginPos)
	local prefab = CachePrefabManager.Take("by3d_bomb_fwq")
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	tran.position = beginPos
	tran.localScale = Vector3.New(ss, ss, ss)

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(1.5)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)		
	end)
end

-- 炸弹鱼死亡前奏效果
function FishingAnimManager.PlayBY3D_ZDFishDead_QZ(parent, fish, callback)
	if fish and IsEquals(fish.fish_base.fish_mesh) then
		local fish_mesh = fish.fish_base.fish_mesh
		fish_mesh.material:SetColor("_Color", Color.New(1,0,0,1))
		local seq = DoTweenSequence.Create()
		if fish.fish_cfg.id == 21 then
			FishingAnimManager.PlayBY3D_ZDFishDead_QZ_HG(parent, 6, fish.transform.position)
			seq:Append(fish.transform:DOScale(Vector3.one * 3, 0.1):SetLoops(15, DG.Tweening.LoopType.Yoyo))
		else
			FishingAnimManager.PlayBY3D_ZDFishDead_QZ_HG(parent, 4, fish.transform.position)			
			seq:Append(fish.transform:DOScale(Vector3.one * 2, 0.1):SetLoops(15, DG.Tweening.LoopType.Yoyo))
		end
        seq:Join(fish_mesh.material:DOColor(Color.New(0.5,0,0,1), 0.1):SetLoops(15, DG.Tweening.LoopType.Yoyo))

		seq:OnKill(function ()
			if callback then
				callback()
			end
		end)
	else
		if callback then
			callback()
		end
	end
end
function FishingAnimManager.PlayBY3D_ZDFishDead(parent, beginPos, cfg_fish_id)
	local pre_name = "Fishing3D_zdy_baozha_xiao"
	if cfg_fish_id == 21 then
		pre_name = "Fishing3D_zdy_baozha_da"
		ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_zhadanyu1.audio_name)
	else
		ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_zhadanyu.audio_name)
	end
	FishingAnimManager.PlayShowAndHideFX(parent, pre_name, beginPos, 2, nil)
end

function FishingAnimManager.PlayBY3D_ZTBomb(parent, beginPos)
	local pre_name = "Fishing3D_zty_baozha"
	FishingAnimManager.PlayShowAndHideFX(parent, pre_name, beginPos, 2, nil)
end
function FishingAnimManager.PlayBY3D_ZT1Bomb(parent, beginPos)
	local pre_name = "Fishing3D_jbsz_baozha"
	FishingAnimManager.PlayShowAndHideFX(parent, pre_name, beginPos, 2, nil)
end

function FishingAnimManager.PlayFishNet_ZT(parent, data, ZZ, beginPos, status)
	
	local prefab
	if status == 17 then
		prefab = CachePrefabManager.Take("FishNetPrefab_3d_zt")
	else
		prefab = CachePrefabManager.Take("FishNetPrefab_jbsz_zt")
	end
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	tran.position = beginPos
	tran.localScale = Vector3.New(0.2, 0.2, 0.2)
	tran.localEulerAngles = Vector3.New(0, 0, ZZ)

	local seq = DoTweenSequence.Create()
	seq:Append(tran:DOScale(1, 0.2))
	seq:Append(tran:DOScale(0.2, 0.2))
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)		
	end)
end

function FishingAnimManager.PlayOthJLYX(parent, beginPos, keepTime)
	local pre_name = "by3d_jlyx_prefab"
	FishingAnimManager.PlayShowAndHideFX(parent, pre_name, beginPos, keepTime, nil)
end

-- 宝蟾烟尘
function FishingAnimManager.PlayBCYan(parent, beginPos, keepTime)
	local pre_name = "Fish3D058_yan"
	FishingAnimManager.PlayShowAndHideFX(parent, pre_name, beginPos, keepTime, nil)
end

-- 一个固定位置的特效 显示一段时间消失
function FishingAnimManager.PlayShowAndHideFXAndCall_A(parent, fx_name, beginPos, keepTime, no_take, call, calltime, q_time)
	if q_time then
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(q_time)
		seq:OnKill(function ()
			FishingAnimManager.PlayShowAndHideFXAndCall(parent, fx_name, beginPos, keepTime, no_take, call, calltime)		
		end)
	else
		FishingAnimManager.PlayShowAndHideFXAndCall(parent, fx_name, beginPos, keepTime, no_take, call, calltime)	
	end
end

-- 鲨鱼死亡表现
function FishingAnimManager.PlaySYFishDead(moneys, all_fish_list, seat_num)
	local panel = FishingLogic.GetPanel()
	ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_bossBchiyu.audio_name)

	FishingAnimManager.PlayShowAndHideFX(panel.FlyGoldNode.transform, "Fish3D077_xi", Vector3.zero, 4, nil)

	local prefab = CachePrefabManager.Take("Fish3D077")
	prefab.prefab:SetParent(panel.fish_group_node_tran)
	local tran = prefab.prefab.prefabObj.transform
	tran.localPosition = Vector3.New(0, 2, 9000)
	tran.localScale = Vector3.New(1.8, 1.8, 1.8)
	tran.localRotation = Quaternion.Euler(0, 0, -90)
	local box2d = tran:GetComponent("BoxCollider2D")
	box2d.enabled = false
	local anim_pay = tran:Find("fish3d"):GetComponent("Animator")
	anim_pay:Play("skill")

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(3.5)
	seq:Append(tran:DOScale(0.5, 0.8):SetEase(DG.Tweening.Ease.InQuint))
	seq:AppendInterval(-0.2)
	seq:AppendCallback(function ()
		FishingAnimManager.PlayShowAndHideFX(panel.fish_group_node_tran, "Fish3D077_shuihua", Vector3.New(0,2,9000), 1, nil)
		FishingAnimManager.PlayShowAndHideFX(panel.fish_group_node_tran, "Fish3D077_bowen", Vector3.New(0,0,9000), 2, nil)
	end)
	seq:AppendInterval(0.2)
	seq:OnKill(function ()
		tran.localScale = Vector3.zero
	end)
	seq:OnForceKill(function ()
		if IsEquals(tran) then
			tran.localScale = Vector3.one
		end
		CachePrefabManager.Back(prefab)
	end)

    dump(all_fish_list)
    for k,v in ipairs(all_fish_list) do
        local fish = FishManager.GetFishByID(v)
        if fish then
        	fish.transform:SetParent(panel.FishXZAnimTran)
            fish:AttractHit(Vector3.zero, 3.5)
        end
    end

    FishingAnimManager.PlaySYFishDead_JS(panel.FlyGoldNode.transform, moneys, seat_num, cfg_fish_id)
end
-- 结算动画
function FishingAnimManager.PlaySYFishDead_JS(parent, moneys, seat_num, cfg_fish_id, name)
	local panel = FishingLogic.GetPanel()
    local endPos = panel.PlayerClass[seat_num]:GetPlayerFXPos()

    local curSoundKey

    local prefab_name = name or "fishing3D_shayu_jiesuan"
	local prefab = CachePrefabManager.Take(prefab_name)

	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	tran.position = Vector3.New(0,-100,0)
	tran.localScale = Vector3.New(1, 1, 1)

	local Text_01 = tran:Find("Text_01"):GetComponent("Text")
	Text_01.text = "0"
	local all_money = 0
	local all_money_tt = #moneys*0.1 + 1
	for k,v in ipairs(moneys) do
		all_money = all_money + v
	end

	local yc_exit = function ()
		if curSoundKey then
			soundMgr:CloseLoopSound(curSoundKey)
			curSoundKey = nil
		end
	end
	
	local update_time
	local add_score = function ()
		
		local cur_m = 0
		local spt = 0.04
		local spm = math.max(1, math.ceil(all_money / (all_money_tt * 1 / spt)))

		local function close_timer()
			if update_time then
				update_time:Stop()
				update_time = nil
			end
		end
		local function set_money(value)
			if IsEquals(Text_01) then
				Text_01.text = "+" .. value
			end
		end
		update_time = Timer.New(function ()
			cur_m = cur_m + spm
			if cur_m > all_money then
				cur_m = all_money
				close_timer()
			end
			set_money(cur_m)
		end, spt, -1)
		update_time:Start()
		set_money(cur_m)

		local seq = DoTweenSequence.Create()
		seq:AppendInterval(all_money_tt)
		seq:OnForceKill(function (force_kill)
			if force_kill then
				yc_exit()
			end
			close_timer()
		end)
	end

	local tran_ani = tran:GetComponent("Animator")
	local nn = 0
	local movefinish = function ()
		nn = nn + 1
		if nn >= #moneys then
			yc_exit()
			-- 移动到 endPos
			local playAni3 = function ()
				tran_ani:Play("fishing3D_shayu_jiesuan3",-1,0)
			end
			playAni3()
			local seq = DoTweenSequence.Create()
			seq:Append(tran:DOMove(endPos,1))
			seq:AppendCallback(function ()
				if update_time then
					update_time:Stop()
					update_time = nil
				end
				Text_01.text = "+" .. all_money
			end)
			seq:AppendInterval(0.5)
			tran_ani.enabled = false
			seq:Append(tran:DOScale(Vector3.New(2,2,1), 0.2))
			seq:Append(tran:DOScale(Vector3.zero, 0.2))
			seq:OnKill(function ()
				--
				Event.Brocast("ui_gold_fly_finish_msg", {seat_num=seat_num, score=all_money})

				cfg_fish_id = cfg_fish_id or 47
				local fish_cfg = FishingModel.Config.fish_map[cfg_fish_id]

				local parm = {dead_guang = fish_cfg.dead_guang, reward_image = fish_cfg.reward_image, icon = fish_cfg.icon, js3_td=fish_cfg.js3_td}
				FishingAnimManager.PlayBY3D_HDY_FX_1(parent, endPos, all_money, nil, seat_num, 3, parm)
			end)
			seq:OnForceKill(function ()
				CachePrefabManager.Back(prefab)
			end)
		end
	end
	local movecall = function (money, delta_t, di)
		local prefab = CachePrefabManager.Take("fishing3D_shayu_jiesuan_wz1")
		prefab.prefab:SetParent(parent)
		local obj1 = prefab.prefab.prefabObj
		local tran1 = obj1.transform
		local yy = 0
		if di < 6 then
			yy = 30 * (6-di)
		end
		tran1.localPosition = Vector3.New(0,0,0)
		tran1.localScale = Vector3.one
		local tt = tran1:GetComponent("Text")
		tt.text = "+" .. money
		local _endPos = Vector3.New(0, 320-yy, 0)

		local textCanvasGroup = tran1:GetComponent("CanvasGroup")
		local seq = DoTweenSequence.Create()
		if delta_t then
			obj1:SetActive(false)
			seq:AppendInterval(delta_t)
			seq:AppendCallback(function ()
				obj1:SetActive(true)
			end)
		end
		seq:Append(tran1:DOScale(Vector3.New(2,2,2), 0.1))
		seq:Append(tran1:DOScale(Vector3.New(1,1,1), 0.1))
		seq:Append(tran1:DOLocalMove(_endPos, 0.3))

		seq:Join(textCanvasGroup:DOFade(0, 0.8):SetEase(DG.Tweening.Ease.InQuint))
		seq:OnKill(function ()
			movefinish()
		end)
		seq:OnForceKill(function (force_kill)
			if force_kill then
				yc_exit()
			end
			CachePrefabManager.Back(prefab)
		end)
	end
	local playAni2 = function ()
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(3.7)
		seq:AppendCallback(function ()
			curSoundKey = ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_bossBdefen.audio_name, -1)
			add_score()
			tran_ani:Play("fishing3D_shayu_jiesuan2",-1,0)
			for k,v in ipairs(moneys) do
				movecall(v, 0.1*k, #moneys-k+1)
			end
		end)
	end
	
	playAni2()
end

local big_boss_fenwei
local small_boss_fenwei
function FishingAnimManager.PlayBossFenwei(type, parent, keepTime, is_exit)
	if type == "big" then
		if is_exit then
			if IsEquals(big_boss_fenwei) then
				destroy(big_boss_fenwei)
				big_boss_fenwei = nil
			end
			return
		end
		if not IsEquals(big_boss_fenwei) then
			big_boss_fenwei = GameObject.Instantiate(GetPrefab("fish3d_boss_bg_js"), parent).gameObject
			local img = big_boss_fenwei.transform:GetComponent("Image")
			local boss_id = FishingModel.GetBossType()
			if boss_id == 1 then
				img.color = Color.New(0, 1, 92/255, 207/255)
			elseif boss_id == 2 then
				img.color = Color.New(0, 118/255, 1, 207/255)
			elseif boss_id == 3 then
				img.color = Color.New(0, 120/255, 1, 207/255)
			elseif boss_id == 4 then
				img.color = Color.New(1, 81/255, 0, 207/255)
			end
			
		    big_boss_fenwei.transform.localScale = Vector3.one
		end
	else
		if is_exit then
			if IsEquals(small_boss_fenwei) then
				destroy(small_boss_fenwei)
				small_boss_fenwei = nil
				FishingModel.PlaySceneBGM()
			end
			return
		end
		if not IsEquals(small_boss_fenwei) then
		    small_boss_fenwei = GameObject.Instantiate(GetPrefab("fish3d_boss_bg_ls"), parent).gameObject
		    small_boss_fenwei.transform.localScale = Vector3.one
		end
	end
end

-- 章鱼触角拍打的烟尘
function FishingAnimManager.PlayZYCJPDYan()
	local panel = FishingLogic.GetPanel()
	local pre_name = "Fishing3D_Fish3D084_bowen"
	FishingAnimManager.PlayShowAndHideFX(panel.transform, pre_name, Vector3.New(0,-200, 0), 1, nil)
end

-- 鳄鱼宝箱出现
function FishingAnimManager.PlayEYBox(beginPos, seat_num)
	local panel = FishingLogic.GetPanel()
	local uipos = FishingModel.GetSeatnoToPos(seat_num)
	local path = panel:GetTSPath(uipos)
    local endPos = panel.PlayerClass[seat_num]:GetPlayerFXPos()

	local prefab = CachePrefabManager.Take("Fish3DBOX_chuxian")
	prefab.prefab:SetParent(panel.FlyGoldNode.transform)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	tran.position = beginPos

	local box_node = {}
	box_node[#box_node + 1] = tran:Find("box_01/box_01node")
	box_node[#box_node + 1] = tran:Find("box_02/box_02node")
	box_node[#box_node + 1] = tran:Find("box_03/box_03node")

	local move = function (i, t)
		local move_seq = DoTweenSequence.Create()
		if t and t > 0.001 then
			move_seq:AppendInterval(t)
		end
		move_seq:Append(box_node[i]:DOMove(path[i], 0.5))
		move_seq:AppendCallback(function ()
			Event.Brocast("uifx_move_finish_show_fish_by_id", seat_num, i)
		end)
		move_seq:OnKill(function ()
			FishingAnimManager.PlayShowAndHideFX(panel.FlyGoldNode.transform, "Fish3DBOX_cc_sw_glow", path[i], 1, nil)
			if IsEquals(box_node[i]) then
				box_node[i].gameObject:SetActive(false)
			end
		end)
	end

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(1)
	seq:AppendCallback(function ()
		for i = 1, #box_node do
			move(i, 0.2*(i-1))
		end
	end)
	seq:AppendInterval(2)
	seq:OnKill(function ()
		Event.Brocast("uifx_all_move_finish", seat_num)
	end)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)
	end)
end
-- 鳄鱼宝箱爆金币效果
function FishingAnimManager.PlayEYBoxDead(beginPos)
	local panel = FishingLogic.GetPanel()
	FishingAnimManager.PlayShowAndHideFX(panel.FlyGoldNode.transform, "by3d_box_sw_jingbi", beginPos, 2, nil)
end

-- 金龙爆炸效果
function FishingAnimManager.PlayJLongBZ(beginPos, delta_t)
	local call = function ()		
		local panel = FishingLogic.GetPanel()
		Event.Brocast("ui_shake_screen_msg")
		FishingAnimManager.PlayShowAndHideFX(panel.FlyGoldNode.transform, "Fish3D036_jl_bao", beginPos, 1, nil)
	end

	if delta_t and delta_t > 0.0001 then
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(delta_t)
		seq:OnKill(function ()
			call()
		end)
	else
		call()
	end
end

-- 核能风暴
function FishingAnimManager.PlayHNFB(parent, callback)
    FishingAnimManager.PlayShowAndHideFX(parent, "Fishing3D_hnfb_ui", Vector3.zero, 1.74)

	local call = function ()
		FishingAnimManager.PlayShowAndHideFX_CallTime(parent, "Fishing3D_hnfb", Vector3.zero, 4, nil, function ()
			Event.Brocast("ui_shake_screen_msg")
			if callback then
				callback()
			end
		end, 0.6)
	end

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(1)
	seq:OnKill(function ()
		call()			
	end)
end

-- 死亡之灵
function FishingAnimManager.PlaySWZL(parent, beginPos, endPos, callback)
	FishingAnimManager.PlayMoveAndHideFX(parent, "Fishing3D_slzg_shandian_01", beginPos, endPos, 0, 1, function ()
	    FishingAnimManager.PlayShowAndHideFX(parent, "Fishing3D_slzg_shandian_02", endPos, 3, nil, function ()
	    	if callback then
	    		callback()
	    	end
	    end)
	end, 0)
end

-- 金币使者
function FishingAnimManager.PlayJBSZ()
    FishingAnimManager.PlayShowAndHideFX(parent, "Fishing3D_jqsz_ui", Vector3.zero, 1.74)
	
end


-- 公用分段加金币
function FishingAnimManager.ComFDJQ(gold_txt, moneys, t1, t2, call, csjb, forcekill_call)
	local init_money = csjb or 0
	local all_money = 0
	for k,v in ipairs(moneys) do
		all_money = all_money + v
	end
	local init_scale = Vector3.New(gold_txt.transform.localScale.x, gold_txt.transform.localScale.y, gold_txt.transform.localScale.z)
	local begin_num = init_money
	local end_num = init_money

	gold_txt.text = StringHelper.ToAddDH(init_money)

	local run1
	run1 = function (i)
		local a_i = i
		end_num = end_num + moneys[a_i]
		if call then
			call(a_i, "ks")
		end

		FishingAnimManager.PlayMoneyChangeAnim(gold_txt, begin_num, end_num, t1, function ()
			begin_num = end_num
			if call then
				call(a_i, "js")
			end
			if IsEquals(gold_txt) then
				gold_txt.text = StringHelper.ToAddDH(end_num)
			end
			gold_txt.transform.localScale = init_scale*1.5
			local seq = DoTweenSequence.Create()
			seq:Append(gold_txt.transform:DOScale(init_scale.x, 0.5))
			if t2 and t2 > 0 and end_num < all_money then
				seq:AppendInterval(t2)
			end
			seq:OnKill(function ()
				if end_num == all_money then
					print("<color=red>end_num = " .. end_num .. "</color>")
				else
					run1(a_i+1)
				end
			end)
			seq:OnForceKill(function (force_kill)
				if force_kill and forcekill_call then
					forcekill_call()
				end
			end)
		end, function ()
			if forcekill_call then
				forcekill_call()
			end
		end)				
	end

	run1(1)
end

function FishingAnimManager.PlayHLJS(parent, moneys, seat_num, cfg_fish_id, name)
	local all_money = 0
	for k,v in ipairs(moneys) do
		all_money = all_money + v
	end
	moneys = MathExtend.SplitNumber(all_money, 3)

	local panel = FishingLogic.GetPanel()
    local endPos = panel.PlayerClass[seat_num]:GetPlayerFXPos()
    
    local prefab_name = name or "fishing3D_shayu_jiesuan"
	local prefab = CachePrefabManager.Take(prefab_name)

	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	tran.position = Vector3.New(0,-100,0)
	tran.localScale = Vector3.New(1, 1, 1)
	local Text_01 = tran:Find("Text_01"):GetComponent("Text")
	Text_01.text = "0"
	local tran_ani = tran:GetComponent("Animator")

	local len = #moneys
	FishingAnimManager.ComFDJQ(Text_01, moneys, 2.3, 1, function (i, s)
		if s == "ks" then
			tran_ani:Play("dd", 0, 0)
		else
			tran_ani:Play("dj", 0, 0)
		end
		if i == len and s == "js" then

			local seq = DoTweenSequence.Create()
			seq:AppendInterval(2)
			seq:Append(tran:DOMove(endPos, 1))
			seq:AppendInterval(0.5)
			seq:Append(tran:DOScale(Vector3.New(2,2,1), 0.2))
			seq:Append(tran:DOScale(Vector3.zero, 0.2))
			seq:OnKill(function ()
				-- 结算面板
				Event.Brocast("ui_gold_fly_finish_msg", {seat_num=seat_num, score=all_money})
				local id = cfg_fish_id or 47
				local fish_cfg = FishingModel.Config.fish_map[id]
				local parm = {dead_guang = fish_cfg.dead_guang, reward_image = fish_cfg.reward_image, icon = fish_cfg.icon, js3_td=fish_cfg.js3_td}
				FishingAnimManager.PlayBY3D_HDY_FX_1(parent, endPos, all_money, nil, seat_num, 3, parm)				
			end)
			seq:OnForceKill(function ()
				CachePrefabManager.Back(prefab)
				prefab = nil
			end)
		end
	end, 0, function ()
		CachePrefabManager.Back(prefab)
		prefab = nil
	end)
end

-- 炮台升级的飞金币
function FishingAnimManager.PlayPTSJ_JB(parent, beginPos, endPos, data)
	local num = 10
	local t = 0.08
	local finish_num = 0
	local _call = function ()
		finish_num = finish_num + 1
		if finish_num == 1 then
			FishingAnimManager.PlayGoldFX(parent, endPos)
		end
		if finish_num == num then
			
		end
	end

	for i = 1, num do
		local x = beginPos.x + math.random(0, 200) - 50
		local y = beginPos.y + math.random(0, 200) - 50
		local pos = Vector3.New(x, y, beginPos.z)
		CreateGold(parent, pos, endPos, t * (i-1), _call, "by3d_js_prefab")
	end
end

--西瓜鱼死亡
function FishingAnimManager.PlayXGYFishDead(data, parent,backcall,endPos)
	ExtendSoundManager.PlaySound(audio_config.by.bgm_by_jiangli5.audio_name)
	local prefab_name
	local prefab
	if data.act_type == 10 then
		prefab_name = "hf_dl_anim_prefab"
	elseif data.act_type == 8 then
		prefab_name = "hb_dl_anim_prefab"
	else
		local a, _pre = GameButtonManager.RunFunExt("act_ty_by_drop", "GetDLPrefab",nil,data.act_type)
		if a and _pre then
			prefab = _pre
		else
			prefab_name = "hf_dl_anim_prefab"
		end
	end
	if not prefab then
		prefab = CachePrefabManager.Take(prefab_name)
	end
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	tran.localScale = Vector3.one
	tran.position = Vector3.zero
	local ui = {}
	LuaHelper.GeneratingVar(tran, ui)
	obj:SetActive(false)
	
	local number_to_array = function(number, len)
		local tbl = {}
		local nn = number
		while nn > 0 do
			tbl[#tbl + 1] = nn % 10
			nn = math.floor(nn / 10)
		end

		local array = {}
		if len then
			if len > #tbl then
				for idx = len, 1, -1 do
					if idx > #tbl then
						array[#array + 1] = 0
					else
						array[#array + 1] = ""..tbl[idx]
					end
				end
			else
				for idx = #tbl, 1, -1 do
					array[#array + 1] = ""..tbl[idx]
				end
				print("<color=red>EEE 长度定义不合理 number = " .. number .. "  len = " .. len .. "</color>")
			end
		else
			for idx = #tbl, 1, -1 do
				array[#array + 1] = ""..tbl[idx]
			end
		end
		return array
	end

	local arr = number_to_array(data.score, 8)

	-- 滚动数据
	local item_list = {}
	for i = 1, 8 do
		item_list[#item_list + 1] = ui["Mask"..i].gameObject
	end

	local seq = DoTweenSequence.Create()
	local delta_t = 2
	if delta_t and delta_t > 0 then
		seq:AppendInterval(delta_t)
		seq:AppendCallback(function ()
			obj:SetActive(true)
			FishingAnimManager.ScrollLuckyChangeToFiurt(item_list,arr,function ()
				print("<color=red>滚动完成XXXXXXXXXXXXX</color>")
			end)
		end)
	else
		obj:SetActive(true)
		FishingAnimManager.ScrollLuckyChangeToFiurt(item_list,arr,function ()
			print("<color=red>滚动完成XXXXXXXXXXXXX</color>")
		end)
	end
	seq:AppendInterval(5)
	--seq:Append(tran:DOMove(endPos, 0.6):SetEase(DG.Tweening.Ease.InQuint))
	seq:AppendCallback(
		function()
			if backcall then
				backcall()
			end
		end
	)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)
	end)
	
end

function FishingAnimManager.PlayTYJBFly(parent, beginPos, endPos, data, call)
	local delta_t
	local num = 10
	if data and data.delta then
		delta_t = data.delta
	end
	if data and data.num then
		num = data.num
	end
	local prefab = "by3d_js_prefab"
	if data and data.prefab then
		prefab = data.prefab
	end

	local call = function ()
		local t = 0.08
		local finish_num = 0
		local _call = function ()
			finish_num = finish_num + 1
			if finish_num == 1 then
				FishingAnimManager.PlayGoldFX(parent, endPos)
			end
			if finish_num == num then
				if call then
					call()
				end
			end
		end

		for i = 1, num do
			local x = beginPos.x + math.random(0, 200) - 50
			local y = beginPos.y + math.random(0, 200) - 50
			local pos = Vector3.New(x, y, beginPos.z)
			CreateGold(parent, pos, endPos, t * (i-1), _call, prefab)
		end
	end

	if delta_t and delta_t > 0 then
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(delta_t)
		seq:OnKill(function ()
			call()
		end)
	else
		call()
	end
end