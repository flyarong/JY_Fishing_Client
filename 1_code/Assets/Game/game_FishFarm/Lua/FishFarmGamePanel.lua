-- 创建时间:2020-07-24
-- Panel:FishFarmGamePanel
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 --]]

local basefunc = require "Game/Common/basefunc"

FishFarmGamePanel = basefunc.class()
local C = FishFarmGamePanel
C.name = "FishFarmGamePanel"
local M = FishFarmManager
function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
	self.lister["model_fishbowl_info"] = basefunc.handler(self, self.MyRefresh)
	self.lister["model_fishbowl_backpack_change_msg"] = basefunc.handler(self, self.model_fishbowl_backpack_change_msg)
	self.lister["ui_fish_bowl_collect_msg"] = basefunc.handler(self, self.ui_fish_bowl_collect_msg)
	self.lister["model_fishbowl_collect_msg"] = basefunc.handler(self, self.fishbowl_collect)

	self.lister["ui_fish_bowl_stop_fishface_msg"] = basefunc.handler(self, self.ui_fish_bowl_stop_fishface_msg)

	-- 任务
	self.lister["sys_fishfarm_daytask_task_msg_change_msg"] = basefunc.handler(self, self.RefreshTask)
	self.lister["sys_fishfarm_daytask_task_msg_finish_msg"] = basefunc.handler(self, self.RefreshTask)
end
function C:RefreshTask()
	local a,b = GameButtonManager.RunFunExt("sys_fishfarm_daytask", "GetHintState", nil, {gotoui="sys_fishfarm_daytask"})
	if a and b == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
		self.task_get_tips.gameObject:SetActive(true)
	else
		self.task_get_tips.gameObject:SetActive(false)
	end
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.update_time then
		self.update_time:Stop()
		self.update_time = nil
	end
	for k,v in pairs(self.fish_map) do
		v.fish:MyExit()
	end
	SwimManager.Exit()
	self:RemoveListener()

	if MainModel.lastmyLocation
		and MainModel.lastmyLocation == "game_Fishing3DHall"
		and MainModel.lastmyLocation == "game_Fishing3D" then
		GameManager.GotoSceneName("game_Fishing3DHall")
	else
		GameManager.GotoSceneName("game_Hall")
	end
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.exp_rect = self.exp_img.transform:GetComponent("RectTransform")

	-- 创建2DUI
	local ui2d = newObject("FishFarmUI")
	self.Fishing2DUI_Obj = ui2d
	self.Fishing2DUI_Tran = ui2d.transform
	self.FishNodeTran = self.Fishing2DUI_Tran:Find("FishNodeTran").transform
	self.bg = self.Fishing2DUI_Tran:Find("bg_node/BG").transform
	self.camera2d = self.Fishing2DUI_Tran:Find("CatchFish2DCamera"):GetComponent("Camera")
	MainModel.SetGameBGScale(self.bg)

	local width = Screen.width
	local height = Screen.height
	if width / height < 1 then
		width,height = height,width
	end
	local matchWidthOrHeight = MainModel.GetScene_MatchWidthOrHeight(width, height)
	if matchWidthOrHeight == 1 then
		self.camera2d.orthographicSize = 5.4
	else
		self.camera2d.orthographicSize = 5.4 * self.bg.transform.localScale.x
	end
	self.camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")

	FishFarmModel.SetCamera(self.camera2d, self.camera)

	self.ui2d_map = {}
	LuaHelper.GeneratingVar(self.Fishing2DUI_Tran, self.ui2d_map)

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	math.randomseed(os.time())

	self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)

	self.jb_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
	end)
	self.xx_btn.onClick:AddListener(function ()
		-- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	end)
	self.sl_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		GameManager.GotoUI({gotoui = "sys_fishfarm_simplicity",goto_scene_parm = "panel_sl"})
	end)

	self.help_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnHelpClick()
	end)	
	self.share_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnShareClick()
	end)
	self.feed_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnFeedClick()
	end)
	self.getmoney_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnGetMoneyClick()
	end)
	self.sby_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnSBYClick()
	end)

	self.tank_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnTankClick()
	end)
	self.bag_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBagClick()
	end)
	self.task_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnTaskClick()
	end)
	self.book_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBookClick()
	end)
	self.spring_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnSpringClick()
	end)
	self.fish_bowl_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnFishBowlClick()
	end)

	self.is_jt_open = false
	self.fish_map = {}

	self.update_time = Timer.New(function (_, time_elapsed)
        self:FrameUpdate(time_elapsed)
    end, 0.033, -1, nil, true)
	self.update_time:Start()

	SwimManager.Init()

	FishFarmManager.QueryFishbowlInfo("")
end
function C:OnAssetChange(data)
	dump(data, "<color=red>OnAssetChange </color>")
	self:RefreshAsset()
end
function C:MyRefresh()
	self:RefreshFish()
	self:RefreshAsset()
	self:RefreshFishbowlLevel()
	self:RefreshTask()
end

function C:RefreshFishbowlLevel()
	local data = M.GetFishbowlInfo()
	self.level_txt.text = "Lv." .. data.level
	local cfg = M.GetFishbowlConfigByLevel(data.level)
	self.exp_txt.text = data.exp .. "/" .. cfg.exp
	local percent = data.exp / cfg.exp
	if percent > 1 then
		percent = 1
	end
	self.exp_rect.sizeDelta = Vector2.New(180*percent, 26)
end
function C:RefreshFish()
	local d = FishFarmManager.GetFishbowlOfFishList()
	for k,v in ipairs(d) do
		if self.fish_map[v.id] then
			self.fish_map[v.id].fish:MyRefresh()
		else
			self:AddFish(v)
		end
	end
end

function C:RefreshAsset()
	local xx = GameItemModel.GetItemCount("prop_fishbowl_stars")
	self.jb_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	self.xx_txt.text = StringHelper.ToCash(xx)
	self.fish_bowl_num_txt.text = M.GetCurFishbowlFishNum() .. "/" .. M.GetFishbowlMaxCount()
	self.sl_txt.text = StringHelper.ToCash(GameItemModel.GetItemCount("prop_fishbowl_feed"))
end

function C:model_fishbowl_backpack_change_msg(data)
	if data and data.obj_assets_list then
		for k,v in ipairs(data.obj_assets_list) do
			if v.type == "del" then
				self:DelFish(v.id, data.change_type)
			elseif v.type == "add" then
				self:AddFish(M.GetObjToolData(v.id), true)
			else
				self:ChgFish(v.id, data.change_type)
			end
		end
	end
end

function C:ChgFish(obj_id, change_type)
	if self.fish_map[obj_id] then
		self.fish_map[obj_id].fish:MyRefresh(change_type)
	else
		dump(obj_id, "<color=purple>|||||||||||obj_id </color>")
		dump(self.fish_map, "fish_map ")
	end
end
function C:DelFish(obj_id, change_type)
	SwimManager.DelSwim(obj_id)
	if self.fish_map[obj_id] then
		self.fish_map[obj_id].fish:MyExit(change_type)
		self.fish_map[obj_id] = nil
	else
		dump(obj_id, "<color=purple>|||||||||||obj_id </color>")
		dump(self.fish_map, "fish_map ")
	end
end
function C:AddFish(data, is_add)
	local fish
	local swim
	local cfg = M.GetFishConfig(data.fish_id)

	local pos = SwimManager.GetRandomPos()
	if cfg.move_id and M.GetMoveConfigByID(cfg.move_id) then
		local move_cfg = M.GetMoveConfigByID(cfg.move_id)
		local parm = SwimManager.GetSwimParm(move_cfg, cfg)
		pos = parm.pos or pos
		if move_cfg.style == "queue" then
			swim = SwimManager.CreateSwimVehicle({key=data.id, pos=pos, move_style="queue", queue_key=parm.key, mass=cfg.mass or 1})
			fish = FishFarm3DBase.Create( self.FishNodeTran, self.fishui_node, {obj_id=data.id, id=data.fish_id, is_add=is_add, pos=pos})
		else
			swim = SwimManager.CreateSwimVehicle({key=data.id, pos=pos, move_style="group", group_key=parm.key, mass=cfg.mass or 1})
			fish = FishFarm3DBase.Create( self.FishNodeTran, self.fishui_node, {obj_id=data.id, id=data.fish_id, is_add=is_add, pos=pos})
		end
	else
		swim = SwimManager.CreateSwimVehicle({key=data.id, pos=pos, mass=cfg.mass or 1})
		fish = FishFarm3DBase.Create( self.FishNodeTran, self.fishui_node, {obj_id=data.id, id=data.fish_id, is_add=is_add, pos=pos})
	end

	fish:SetVehicle(swim)
	self.fish_map[data.id] = {fish = fish}

	if is_add then
		LittleTips.Create("你已成功投放"..cfg.name)
	end
end

function C:FrameUpdate(time_elapsed)
	SwimManager.FrameUpdate(time_elapsed)

	for k,v in pairs(self.fish_map) do
		v.fish:FrameUpdate(time_elapsed)
	end

	self:PlayFaceAnim(time_elapsed)
end

function C:OnBackClick()
	self:MyExit()
end

-- 喂养
function C:OnFeedClick()
	print("OnFeedClick... ")
	local n = GameItemModel.GetItemCount("prop_fishbowl_feed")

	local is_have_sl = false
	local is_have_yu = false
	local cur_t = os.time()
	local d = M.GetFishbowlOfFishList()
	for k,v in ipairs(d) do
		local cfg = M.GetFishConfig(v.fish_id)

		if v.level < cfg.sum_stage and cur_t >= v.hungry then
			is_have_yu = true
			local state = M.GetFishByState(cfg, v.level)

			if n >= cfg.sum_stage_list[state].feed_consume then
				is_have_sl = true
			end
		end
	end

	if not is_have_yu then
		LittleTips.Create("没有待喂养的鱼儿")
	elseif not is_have_sl then
		LittleTips.Create("饲料不足")
	else
		Network.SendRequest("fishbowl_feed", nil, "", function(data)
			dump(data, "fishbowl_feed")
			if data.obj_ids and #data.obj_ids > 0 then

			else
				LittleTips.Create("没有待喂养的鱼儿")
			end
		end)
	end
end
-- 鱼缸升级
function C:OnTankClick()
	FishFarmUpLevelPanel.Create()
	print("OnTankClick... ")
end
-- 拍照
function C:OnShareClick()
	print("OnShareClick... ")

	self.ui_root.gameObject:SetActive(false)
	SYSFXManager.CreateShareImage(self.gameObject, self.fx_pos1.position, self.fx_pos2.position, function ()
		self.ui_root.gameObject:SetActive(true)
		print("OnShareClick Finish... ")
    end, nil, ShareLogic.GetImagePath())
end
-- 收宝
function C:OnGetMoneyClick()
	print("OnGetMoneyClick... ")
	local is_have_sb = false
	local cur_t = os.time()
	local d = M.GetFishbowlOfFishList()
	for k,v in ipairs(d) do
		local cfg = M.GetFishConfig(v.fish_id)

		if v.collect and v.collect > 0 and cur_t >= v.collect then
			is_have_sb = true
			break
		end
	end
	if is_have_sb then
		Network.SendRequest("fishbowl_collect",nil , "")
	else
		LittleTips.Create("没有待收宝的鱼儿")
	end
end
-- 背包
function C:OnBagClick()
	FishFarmBagPanel.Create()
	print("OnBagClick... ")
end
-- 帮助
function C:OnHelpClick()
	print("OnHelpClick... ")
	Network.SendRequest("fishbowl_hatch", {prop="prop_fishbowl_fry1"}, "", function(data)
		dump(data, "fishbowl_hatch")
	end)
end
-- 任务
function C:OnTaskClick()
	FishFarmDailyTaskPanel.Create()
	print("OnTaskClick... ")
end
-- 图鉴
function C:OnBookClick()
	print("OnBookClick... ")
	FishFarmBookPanel.Create()
end
-- 泉水
function C:OnSpringClick()
	JLSpringPanel.Create()
	print("OnSpringClick... ")
end
-- 养鱼
function C:OnFishBowlClick()
	SYSFishFarmSimplicityGamePanel.Create("fishfarming")
	--FishFarmFarmingPanel.Create()
end
function C:OnSBYClick()
	LittleTips.Create("暂未开放")
end

-- 
function C:ui_fish_bowl_collect_msg(data)
	if data.data.jinbi and data.data.jinbi > 0 then
		FishFarmCollect.Create(self.transform, {type="jinbi", value=data.data.jinbi, beginPos=data.pos, endPos=self.jb_icon.transform.position, endPos1=self.jb_icon.transform.position})
	end
	if data.data.exp and data.data.exp > 0 then
		FishFarmCollect.Create(self.transform, {type="exp", value=data.data.exp, beginPos=data.pos, endPos=self.tank_btn.transform.position, endPos1=self.exp_txt.transform.position})
	end
	if data.data.stars and data.data.stars > 0 then
		FishFarmCollect.Create(self.transform, {type="stars", value=data.data.stars, beginPos=data.pos, endPos=self.xx_icon.transform.position, endPos1=self.xx_icon.transform.position})
	end
end

function C:fishbowl_collect(data)
	if data.collect_info and #data.collect_info > 0 then
		for k,v in ipairs(data.collect_info) do
			if self.fish_map[v.id] then
				self.fish_map[v.id].fish:PlayCollect(v)
			else
				dump(v.id, "<color=purple>|||||||||||fishbowl_collect </color>")
				dump(self.fish_map, "fish_map ")
			end
		end
	else
		LittleTips.Create("没有待收宝的鱼儿")
	end
end

-- 表情
function C:PlayFaceAnim(time_elapsed)
	if self.is_fish_face_runing then
		self.face_time_runing = (self.face_time_runing or 0) + time_elapsed
		if self.face_time_runing > 60 then
			print("<color=red>||||| <><><><> -_- <><<><> |||||</color>")
			self:ui_fish_bowl_stop_fishface_msg()
		end
		return
	end
	self.face_time_elapsed = (self.face_time_elapsed or 0) + time_elapsed
	self.face_time_step = (self.face_time_step or 0) + time_elapsed

	if self.face_time_step > 1 then -- 检查频率 1次/秒
		self.face_time_step = 0
		if self.face_time_elapsed > 30 then
			local d = FishFarmManager.GetFishbowlOfFishList()
			if d and #d > 0 then
				local fd = d[math.random(1, #d)]
				local id = fd.id
				if self.fish_map[id] then
					local cfg = FishFarmManager.GetFishConfig(fd.fish_id)
					if cfg.face_ids and #cfg.face_ids > 0 then
						local face_id = cfg.face_ids[ math.random(1, #cfg.face_ids) ]
						local face_cfg = FishFarmManager.GetFaceConfigByID(face_id)
						if face_cfg then
							self.is_fish_face_runing = true
							self.face_time_runing = 0
							self.face_time_elapsed = 0

							self.fish_map[id].fish:PlayFaceAnim( face_cfg )
							print("<color=red>||||| <><><><> -_- <><<><> |||||</color>")
							dump(face_id)
						end
					else
						print("<color=red>||||| <><><><> -_- <><<><> |||||</color>")
						dump(cfg)
					end
				else
					print("<color=red>||||| <><><><> -_- <><<><> |||||</color>")
					dump(d)
					dump(id)
					for k,v in pairs(self.fish_map) do
						dump(v.fish)
					end
				end
			else
				print("<color=red>||||| <><><><> -_- <><<><> |||||</color>")
			end
		end
	end
end
function C:ui_fish_bowl_stop_fishface_msg(data)
	self.is_fish_face_runing = false
	self.face_time_runing = 0
	self.face_time_elapsed = 0
	self.face_time_step = 0
end