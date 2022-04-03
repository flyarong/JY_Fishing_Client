-- 创建时间:2019-03-19

FishingDRAnimManager = {}

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

function FishingDRAnimManager.PlayFishNet(parent, data)
	FishNetPrefab.Create(parent, data)
end

function FishingDRAnimManager.PlayShootFX(parent, data)
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

function FishingDRAnimManager.TweenDelay(period, update_callback, final_callback, force_callback)
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

function FishingDRAnimManager.PlayLinesFX(parent, data, speedTime, keepTime, lineName, pointName)
	local pointCount = #data
	if pointCount <= 0 then
		print(string.format("[ErrorFX]: PlayLinesFX(%s) failed pointCount is empty", lineName))
		return
	end

	ExtendSoundManager.PlaySound(audio_config.by.bgm_by_shandianyu.audio_name)

	speedTime = speedTime or 1
	keepTime = keepTime or 1
	lineName = lineName or "electricLine"
	pointName = pointName or "electricPoint"

	local lineTmpl = GetPrefab(lineName)
	if not lineTmpl then
		print(string.format("[ErrorFX]: PlayLinesFX(%s) failed lineTmpl is nil", lineName))
		return
	end
	local lineObject = GameObject.Instantiate(lineTmpl, parent)
	if not lineObject then
		print(string.format("[ErrorFX]: PlayLinesFX(%s) failed lineObject is nil", lineName))
		return
	end
	local lineRenderer = lineObject.transform:GetComponent("LineRenderer");
	if not lineRenderer then
		print(string.format("[ErrorFX]: PlayLinesFX(%s) failed lineRenderer is nil", lineName))
		return
	end

	local pointObjects = {}
	lineRenderer.positionCount = pointCount

	local function setLinePoint(index, position)
		if IsEquals(lineRenderer) then
			for idx = index, pointCount do
				lineRenderer:SetPosition(idx - 1, position)
			end
		end
	end

	local function clearAll()
		dump(pointObjects)
		for _, v in pairs(pointObjects) do
			CachePrefabManager.Back(v)
		end
		pointObjects = {}
		if IsEquals(lineObject) then
			GameObject.Destroy(lineObject.gameObject)
			lineObject = nil
		end
		lineTmpl = nil
	end

	local function getPos(idx)
		return data[idx]
	end

	local function reach(idx)
		local position = getPos(idx)
		local prefab = FishingDRAnimManager.PlayNormal(pointName, nil, 0, nil, parent)
		if prefab then
			prefab.prefab.prefabObj.transform.position = position
			pointObjects[#pointObjects + 1] = prefab
		end
		setLinePoint(idx, position)
	end

	local function playLine(begin_idx, end_idx, peroid, callback)
		local beginPoint = getPos(begin_idx)
		local endPoint = getPos(end_idx)
		local called = false

		setLinePoint(begin_idx, beginPoint)

		local vec3 = Vector3.New(endPoint.x - beginPoint.x, endPoint.y - beginPoint.y, endPoint.z - beginPoint.z)
		local dist = math.max(0.05, Vector3.Magnitude(vec3))
		local speed = dist / (peroid * 60)
		local total = 0
		FishingDRAnimManager.TweenDelay(peroid, function()
			if called then return end
			
			total = total + speed
			factor = Mathf.Clamp(total / dist, 0, 1)
			setLinePoint(end_idx, Vector3.Lerp(beginPoint, getPos(end_idx), factor))

			if factor >= 1 then
				called = true
				if callback then callback(begin_idx, end_idx) end
			end
		end, function()
			if called then return end

			setLinePoint(end_idx, getPos(end_idx))
			if callback then callback(begin_idx, end_idx) end
		end, function (force_kill)
			if force_kill then
				clearAll()
			end
		end)
	end

	local recursion
	recursion = function(idx)
		local next_idx = idx + 1
		if next_idx > pointCount then
			FishingDRAnimManager.TweenDelay(keepTime, nil, nil, function()
				clearAll()
			end)
		else
			playLine(idx, next_idx, speedTime, function(begin_idx, end_idx)
				reach(end_idx)
				recursion(end_idx)
			end)
		end
	end
	
	reach(1)
	recursion(1)
end

function FishingDRAnimManager.TestPlayLinesFX(parent)
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
				local offset = fish.transform.position - pos
				if Vector3.SqrMagnitude(offset) > 10 and math.random(0, 100) > 50 then
					fishTbl[idx + 1] = v.data.fish_id
				end
			else
				fishTbl[idx + 1] = v.data.fish_id
			end

			if #fishTbl >= 3 then break end
		end
	end

	FishingDRAnimManager.PlayLinesFX(parent, fishTbl, 0.1, 2)
end

-- 开始点 结束点
local function CreateGold(parent, beginPos, endPos, delay, call)
	local prefab = CachePrefabManager.Take("FishingFlyGlodPrefab")
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

-- 开始点 结束点
local function CreateNumGold(seat_num, parent, beginPos , endPos, score, a_rate, delay, call, rate, is_move)
	local prefab = CachePrefabManager.Take("NumGlodPrefab")
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = beginPos
	local gold_txt = tran:Find("gold_txt"):GetComponent("Text")
	gold_txt.font = FishingDRAnimManager.GetFontBySeatNum(seat_num)
	gold_txt.text = score
	if rate_on_off and a_rate then
		local rate_img = tran:Find("gold_txt/rate_img"):GetComponent("Image")
		rate_img.sprite = GetTexture("by_imgf_bj" .. (a_rate - 1))
		rate_img.gameObject:SetActive(true)
	end
	local scale = 1
	if rate < 30 then
		scale = 0.25
	elseif rate < 50 then
		scale = 0.35
	elseif rate < 100 then
		scale = 0.5
	else
		scale = 0.6
	end
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
function FishingDRAnimManager.PlayDeadFX(seat_num, score, parent, beginPos, endPos, playerPos, mbPos, rate, name_image, delta_t)
	rate = rate or 1
	local fx_cfg = FishingConfig.GetGoldFX(FishingModel.Config.fish_goldfx_list, rate)
	if not fx_cfg then
		dump(rate, "<color=red>该倍率没有对应表现</color>")
		Event.Brocast("ui_gold_fly_finish_msg", seat_num, score)
		return
	end
    if fx_cfg.level[1] == 1 then
        FishingDRAnimManager.PlayGold(seat_num, score, parent, beginPos, endPos, rate, fx_cfg, delta_t)
    elseif fx_cfg.level[1] == 2 then
    	ExtendSoundManager.PlaySound(audio_config.by.bgm_by_jiangli5.audio_name)
		FishingDRAnimManager.PlayMultiplyingPower100(parent, beginPos, playerPos, name_image, score, function ()
			Event.Brocast("ui_gold_fly_finish_msg", seat_num, score)
    		FishingDRAnimManager.PlayGoldBigFX(parent, mbPos)
		end, seat_num, delta_t)
    elseif fx_cfg.level[1] == 3 then
    	ExtendSoundManager.PlaySound(audio_config.by.bgm_by_jiangli6.audio_name)
    	FishingDRAnimManager.PlayMultiplyingPower200(parent, beginPos, playerPos, score, function ()
    		Event.Brocast("ui_gold_fly_finish_msg", seat_num, score)
    		FishingDRAnimManager.PlayGoldBigFX(parent, mbPos)
    	end, seat_num, delta_t)
    else
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(1)
		seq:OnKill(function ()
		    local my_seat_num = FishingModel.GetPlayerSeat()
		    if my_seat_num == seat_num then
				FishingDRAnimManager.PlayMultiplyingPower300(parent, beginPos, endPos, score, function ()
		    		FishingDRAnimManager.PlayGoldBigFX(parent, mbPos)
		    		Event.Brocast("ui_gold_fly_finish_msg", seat_num, score)
		    	end,seat_num)
		    else
				FishingDRAnimManager.PlayMultiplyingPower300_Other(parent, playerPos, endPos, score, function ()
		    		FishingDRAnimManager.PlayGoldBigFX(parent, mbPos)
		    		Event.Brocast("ui_gold_fly_finish_msg", seat_num, score)
		    	end,seat_num)
		    end
		end)
    end
end
function FishingDRAnimManager.PlayGoldBigFX(parent, pos)
	local prefab = CachePrefabManager.Take("biankuang_glow")
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
function FishingDRAnimManager.PlayGoldFX(parent, pos)
	local prefab = CachePrefabManager.Take("TYjinbi_glow")
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

function FishingDRAnimManager.PlayGold(seat_num, score, parent, beginPos, endPos, rate, fx_cfg, delta_t)
	local call = function ()
		local num = fx_cfg.level[2] or 1
		if num > 20 then
			num = 20
		end
		if fx_cfg.ID == 1 then
			ExtendSoundManager.PlaySound(audio_config.by.bgm_by_jiangli1.audio_name)
		elseif fx_cfg.ID == 2 then
			ExtendSoundManager.PlaySound(audio_config.by.bgm_by_jiangli2.audio_name)
		elseif fx_cfg.ID == 3 then
			ExtendSoundManager.PlaySound(audio_config.by.bgm_by_jiangli3.audio_name)
		else
			ExtendSoundManager.PlaySound(audio_config.by.bgm_by_jiangli4.audio_name)
		end
		local a_rate
		if FishingActivityManager.CheckIsActivityTime(seat_num) then
			a_rate = FishingActivityManager.GetDropAwardRate(seat_num)
		end
		local finish_num = 0
		local _call = function ()
			finish_num = finish_num + 1
			if finish_num == 1 then
				FishingDRAnimManager.PlayGoldFX(parent, endPos)
			end
			if finish_num == num then
				Event.Brocast("ui_gold_fly_finish_msg", seat_num, score)
			end
		end
		if num == 1 then
			CreateGold(parent, beginPos, endPos, nil, _call)
			CreateNumGold(seat_num, parent, beginPos, endPos, score, a_rate, nil, nil, rate)
		elseif num < 6 then
			local t = 0.08
			local detay = t * (num-1)
			for i = 1, num do
				local pos = Vector3.New(beginPos.x + 80 * (i-num/2), beginPos.y, beginPos.z)
				CreateGold(parent, pos, endPos, t * (i-1), _call)
			end
			CreateNumGold(seat_num, parent, beginPos, endPos, score, a_rate, nil, nil, rate)
		else
			local t = 0.08
			for i = 1, num do
				local x = beginPos.x + math.random(0, 200) - 100
				local y = beginPos.y + math.random(0, 200) - 100

				local pos = Vector3.New(x, y, beginPos.z)
				CreateGold(parent, pos, endPos, t * (i-1), _call)
			end
			CreateNumGold(seat_num, parent, beginPos, endPos, score, a_rate, nil, nil, rate)
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
function FishingDRAnimManager.PlayFrozen(parent)
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
function FishingDRAnimManager.PlayFishBoom(parent, pos)
	ExtendSoundManager.PlaySound(audio_config.by.bgm_by_zhadanyu.audio_name)

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

function FishingDRAnimManager.PlayWaveHint(parent, isLeft, img)
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
function FishingDRAnimManager.PlayWave(parent, isLeft)
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
function FishingDRAnimManager.PlaySwitchoverMap(parent, old_img, new_img, isLeft, call)
	local prefab = CachePrefabManager.Take("SwitchoverMap")
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	local yuchao = tran:Find("MoveNode/yuchao")
	local move_tran = tran:Find("MoveNode")
	local old_by_bg = tran:Find("old_by_bg"):GetComponent("SpriteRenderer")
	local new_by_bg = tran:Find("new_by_bg"):GetComponent("SpriteRenderer")
	
	local width = Screen.width
    local height = Screen.height
	
	local matchWidthOrHeight = MainModel.GetScene_MatchWidthOrHeight(width, height)
    if matchWidthOrHeight == 0 then
        old_by_bg.transform.localScale = Vector3.New(1, 1, 1)
        new_by_bg.transform.localScale = Vector3.New(1, 1, 1)
    else
        old_by_bg.transform.localScale = Vector3.New(1.25, 1.25, 1)
        new_by_bg.transform.localScale = Vector3.New(1.25, 1.25, 1)
    end

	local begin_pos
	local end_pos
	if isLeft then
		yuchao.rotation = Quaternion.Euler(0, 0, 0)
		begin_pos = Vector3.New(15, 0, 0)
		end_pos = Vector3.New(-15, 0, 0)
		old_by_bg.sprite = GetTexture(new_img)
		new_by_bg.sprite = GetTexture(old_img)
	else
		yuchao.rotation = Quaternion.Euler(0, 0, 180)
		begin_pos = Vector3.New(-15, 0, 0)
		end_pos = Vector3.New(15, 0, 0)
		old_by_bg.sprite = GetTexture(old_img)
		new_by_bg.sprite = GetTexture(new_img)
	end

	move_tran.transform.position = begin_pos

	local seq = DoTweenSequence.Create()
	seq:Append(move_tran:DOMove(end_pos, 3))
	seq:OnComplete(function ()
		if call then
			call()
		end
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
function FishingDRAnimManager.PlayMultiplyingPower100(parent, beginPos, endPos, name, money, callback, seat_num, delta_t)
	local call = function ()
		local effectName = "100bei_jingbi"
		local effectSnd = nil
		local effectTime = -1
		local burstTime = 1

		local gold_txt = nil
		local function set_money(value)
			if IsEquals(gold_txt) then
				gold_txt.font = FishingDRAnimManager.GetFontBySeatNum(seat_num)
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

		local prefab = FishingDRAnimManager.PlayNormal(effectName, effectSnd, effectTime, nil, parent)
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
function FishingDRAnimManager.PlayMultiplyingPower200(parent, beginPos, endPos, money, callback, seat_num, delta_t)
	local call = function ()
		local effectName = "200bei_jingbi"
		local effectSnd = nil
		local effectTime = -1
		local burstTime = 2

		local gold_txt = nil
		local function set_money(value)
			if IsEquals(gold_txt) then
				gold_txt.font = FishingDRAnimManager.GetFontBySeatNum(seat_num)
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

		local prefab = FishingDRAnimManager.PlayNormal(effectName, effectSnd, effectTime, nil, parent)
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

function FishingDRAnimManager.PlayNormal(particleName, soundName, interval, callback, parent, pos)
	if not parent then
		parent = GameObject.Find("Canvas/LayerLv2")
	end

	local prefab = CachePrefabManager.Take(particleName)
    prefab.prefab:SetParent(parent.transform)
	local tran = prefab.prefab.prefabObj.transform

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

function FishingDRAnimManager.PlayMultiplyingPower300(parent, beginPos, endPos, money, callback,seat_num)
	local function PlayMultipPower300()
		local effectName = "300bei_jingbi"
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

		local prefab = FishingDRAnimManager.PlayNormal(effectName, effectSnd, effectTime, nil, parent)
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
			image.font = FishingDRAnimManager.GetFontBySeatNum(seat_num)
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
			ExtendSoundManager.PlaySound(audio_config.by.bgm_by_jiangli7_1.audio_name)
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
				ExtendSoundManager.PlaySound(audio_config.by.bgm_by_jiangli7_2.audio_name)
				
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
	local _prefab = FishingDRAnimManager.PlayNormal(e_name, nil, 2.5, PlayMultipPower300, parent)
end
function FishingDRAnimManager.PlayMultiplyingPower300_Other(parent, beginPos, endPos, money, callback, seat_num)
	local function PlayMultipPower300()
		local effectName = "300bei_jingbi_other"
		if seat_num > 2 then
			effectName = effectName .. "_1"
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

		local prefab = FishingDRAnimManager.PlayNormal(effectName, effectSnd, effectTime, nil, parent, beginPos)
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
			image.font = FishingDRAnimManager.GetFontBySeatNum(seat_num)
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
			ExtendSoundManager.PlaySound(audio_config.by.bgm_by_jiangli7_1.audio_name)
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
				ExtendSoundManager.PlaySound(audio_config.by.bgm_by_jiangli7_2.audio_name)
				
				if not IsEquals(money_node) then
					if callback then callback() end
					return 
				end
				FlyingToTarget(money_node, endPos, 0.3, 0.5, function()
					if callback then callback() end
				end,function()
					if prefab then
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
	local _prefab = FishingDRAnimManager.PlayNormal(e_name, nil, 2.5, PlayMultipPower300, parent, beginPos)
end
-- 播放极光子弹
function FishingDRAnimManager.PlayLaser(parent, seat_num, beginPos, r)
	local prefab = CachePrefabManager.Take("jiguang_attack_node")
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	tran.rotation = Quaternion.Euler(0, 0, r)
	tran.position = beginPos

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(1)
	seq:OnKill(function ()
		Event.Brocast("ui_play_laser_finish_msg", seat_num)
	end)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)		
	end)
end

-- 播放核弹特效
function FishingDRAnimManager.PlayMissile(parent, seat_num, beginPos, endPos)
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
function FishingDRAnimManager.PlayMissileSP(parent, seat_num, beginPos, endPos, missile_index, putong_or_jinse, call)
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
function FishingDRAnimManager.PlayYWDJ(parent)
	local prefab = CachePrefabManager.Take("activity_ywdj")
	prefab.prefab:SetParent(parent)
	
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(2)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)		
	end)

end

-- 播放获得额外道具表现(锁定 冰冻)
function FishingDRAnimManager.PlayToolSP(parent, seat_num, beginPos, endPos, attr, num, call, img,t1, t2 )
	ExtendSoundManager.PlaySound(audio_config.by.bgm_by_huodejineng.audio_name)

	local prefab = CachePrefabManager.Take("FishingFlyToolPrefab")
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	local icon = tran:Find("Icon"):GetComponent("Image")
	tran.position = beginPos
	if img then
		icon.sprite = GetTexture(img)
	else
		if attr == FishingModel.FishDeadAppendType.LockCard then
			icon.sprite = GetTexture("3dby_btn_sd")
		elseif attr == FishingModel.FishDeadAppendType.IceCard then
			icon.sprite = GetTexture("3dby_btn_bd")
		end
	end
	t1 = t1 or 0.4
	t2 = t2 or 0.6
	FlyingToTarget(tran, endPos, 1, t1, function()
		if call then call(num) end
	end, function()
		CachePrefabManager.Back(prefab)
	end, t2)
end

function FishingDRAnimManager.GetFontBySeatNum(seat_num)
	local font
	if seat_num == FishingModel.GetPlayerSeat() then
		font = GetFont("by_tx1")
	else
		font = GetFont("by_tx2")
	end
	return font
end

-- 播放鱼死亡冒泡特效
function FishingDRAnimManager.PlayFishHitTS(parent, pos)
	-- ExtendSoundManager.PlaySound(audio_config.by.bgm_by_zhadanyu.audio_name)

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
function FishingDRAnimManager.PlayTSFishDeadHint(parent, pos, fish_obj, call)
	local prefab = CachePrefabManager.Take("activity_Hit_TS")
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	tran.position = pos

	local seq = DoTweenSequence.Create()
	for i = 1, 10 do
		seq:Append(fish_obj.transform:DOScale(Vector3.New(1.5, 1.5, 1.5), 0.075))
		seq:Append(fish_obj.transform:DOScale(Vector3.New(1, 1, 1), 0.075))
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
local function CreateZongzi(parent, beginPos, endPos, delay, call)
	local prefab = CachePrefabManager.Take("FishingFlyZongziPrefab")
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
-- 播放西瓜
function FishingDRAnimManager.PlayZongzi(seat_num, score, parent, beginPos, endPos, delta_t, index)
	local call = function ()
		local num = FishingConfig.GetZZFX(FishingModel.Config.fish_zzfx_list, index)
		local finish_num = 0
		local _call = function ()
			finish_num = finish_num + 1
			if finish_num == 1 then
				FishingDRAnimManager.PlayGoldFX(parent, endPos)
			end
			if finish_num == num then
				Event.Brocast("ui_zongzi_fly_finish_msg", seat_num, score)
			end
		end
		if num == 1 then
			CreateZongzi(parent, beginPos, endPos, nil, _call)
		elseif num < 6 then
			local t = 0.08
			local detay = t * (num-1)
			for i = 1, num do
				local pos = Vector3.New(beginPos.x + 80 * (i-num/2), beginPos.y, beginPos.z)
				CreateZongzi(parent, pos, endPos, t * (i-1), _call)
			end
		else
			local t = 0.08
			for i = 1, num do
				local x = beginPos.x + math.random(0, 200) - 100
				local y = beginPos.y + math.random(0, 200) - 100

				local pos = Vector3.New(x, y, beginPos.z)
				CreateZongzi(parent, pos, endPos, t * (i-1), _call)
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
function FishingDRAnimManager.PlayAddZongzi(seat_num, score, parent, beginPos)
		local prefab = CachePrefabManager.Take("AddZongzi")
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.localPosition = beginPos

	local canvas_group = tran:GetComponent("CanvasGroup")
	local text = tran:Find("Text"):GetComponent("Text")
	text.text = "+" .. score
	local seq = DoTweenSequence.Create()
	seq:Append(tran:DOLocalMoveY(100, 0.5))
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
-- 贝壳死亡动画
-- 座位号 钱 特效节点 开始点 结束点 延迟
function FishingDRAnimManager.PlayBKDeadFX(seat_num, score, parent, beginPos, endPos, delta_t)
	local call = function ()
		local prefab = CachePrefabManager.Take("bk_jingbi")
		prefab.prefab:SetParent(parent)
		local tran = prefab.prefab.prefabObj.transform
		tran.position = beginPos
		
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(0.5)
		seq:AppendCallback(function ()
			local fx_cfg = FishingModel.Config.fish_goldfx_list[4]
        	FishingDRAnimManager.PlayGold(seat_num, score, parent, beginPos, endPos, 10, fx_cfg)
		end)
		seq:AppendInterval(1.5)
		seq:OnForceKill(function ()
			if prefab then
				CachePrefabManager.Back(prefab)
			end
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
-- 贝壳渐隐消失时的特效
function FishingDRAnimManager.PlayBKFleeFX(parent, beginPos)
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
function FishingDRAnimManager.PlayBoxFishZJHint(parent, beginPos, img, delta_t)
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
function FishingDRAnimManager.PlayBoxFishZJLvl(parent, beginPos, lvl, delta_t)
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
function FishingDRAnimManager.PlayTZTaskAppear(parent, beginPos, endPos, call)
	local prefab = CachePrefabManager.Take("by_tiaozhanrenwu_cx")
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

function FishingDRAnimManager.PlayLinesFX_FS(parent, fs_pos, data, speedTime, keepTime, lineName, pointName)
	FishingDRAnimManager.PlayShowAndHideFX(parent, "by_qpsd", fs_pos, 2)
	
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
			FishingDRAnimManager.PlayLinesFX(parent, v, speedTime, keepTime, lineName, pointName, true)
		end
	end
end

-- 捕鱼赛跑激光
function FishingDRAnimManager.PlayDRLaser(parent,seat_num,beginPos)
	local prefab = CachePrefabManager.Take("by_jiguang")
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	tran.rotation = Quaternion.Euler(0, 0, 0)
	tran.position = beginPos
	dump(beginPos,"---------------")
	tran.localScale=Vector3.New(1,1,1)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(2.5)
	seq:OnKill(function ()
		Event.Brocast("ui_play_DRlaser_finish_msg", seat_num)
	end)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)		
	end)
end

-- 一个固定位置的特效 显示一段时间消失
function FishingDRAnimManager.PlayShowAndHideFX(parent, fx_name, beginPos, keepTime)
	local prefab
	prefab = CachePrefabManager.Take(fx_name)
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = beginPos
	tran.localScale = Vector3.one
  
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(keepTime)
	seq:OnForceKill(function ()
	  if no_take then
		destroy(prefab)
	  else
		CachePrefabManager.Back(prefab)
	  end
	end)    
  end
  
  -- 前奏表现 放大缩小
  function FishingDRAnimManager.PlayDRFishDeadFX(parent, pos, fish_obj, call)
	local name = tonumber(fish_obj.gameObject.name)
	local seq = DoTweenSequence.Create()
	for i = 1, 6 do
	  seq:Append(fish_obj.transform:DOScale(Vector3.New(1.5, 1.5, 1.5), 0.05))
	  seq:Append(fish_obj.transform:DOScale(Vector3.New(1, 1, 1), 0.05))
	end
	seq:OnKill(function ()
	  if IsEquals(fish_obj) then
		if call then
			call()
			local prefab
		  	local seq1 = DoTweenSequence.Create()
			seq1:AppendInterval(0.5)
			seq1:AppendCallback(function(  )
				local offset ={
					-0.54,-0.6,-0.9,-0.6,-0.7,-1.74,-3.6
				}
				prefab = CachePrefabManager.Take("fishing_dr_dead")
				prefab.prefab:SetParent(parent)
				local obj = prefab.prefab.prefabObj
				local tran = obj.transform
				tran.position = Vector3.New(pos.x + offset[name],pos.y,pos.z)
			end)
			seq1:AppendInterval(0.5)
			seq1:OnForceKill(function ()
				CachePrefabManager.Back(prefab)
			  end)
		end
	  end
	end)
  end

  function FishingDRAnimManager.PlayComMove(target_tran, beginPos, endPos, moveTime, call)
	local tran = target_tran
	tran.position = beginPos
	moveTime = moveTime or 0.2
  
	local seq = DoTweenSequence.Create()
	seq:Append(tran:DOMove(endPos, moveTime):SetEase(DG.Tweening.Ease.InQuint))
	seq:OnKill(function ()
	  if call then
		call()
	  end
	end)
  end

  function FishingDRAnimManager.PlayGunShootFX(parent,data)
	local prefab = CachePrefabManager.Take("paokou")
	prefab.prefab:SetParent(parent)
    prefab.prefab.prefabObj.transform.localPosition = data.pos_ui
    prefab.prefab.prefabObj.transform.localRotation = Quaternion.Euler(0, 0, data.angle)

    local seq = DoTweenSequence.Create()
    seq:AppendInterval(0.2)
    seq:OnForceKill(
        function()
            CachePrefabManager.Back(prefab)
        end)
end

function FishingDRAnimManager.FlyItem(item, point, period, callback, delay, inverse)
	if not IsEquals(item) then return end

	local seq = DoTweenSequence.Create()
	seq:OnKill(function ()
		if IsEquals(item) then
			item.transform.localPosition = Vector3.zero
		end

		if callback then callback() end
	end)

	local h = math.random(100, 260)
	if inverse then
		seq:Append(item.transform:DOLocalMove(point, period):From())
	else
		seq:Append(item.transform:DOLocalMove(point, period))
	end

	delay = delay or 0
	if delay > 0 then
		seq:AppendInterval(delay):AppendCallback(function()
			--delay
		end)
	end
end
