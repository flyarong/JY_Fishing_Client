-- 创建时间:2019-03-18
-- Panel:FishingHallGamePanel
local basefunc = require "Game/Common/basefunc"

FishingHallGamePanel = basefunc.class()
local C = FishingHallGamePanel
C.name = "FishingHallGamePanel"

local instance
function C.Create(parm)
	DSM.PushAct({panel = C.name})
	instance = C.New(parm)
	return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["AssetChange"] = basefunc.handler(self, self.UpdateAssetInfo)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	DSM.PopAct()
	if self.game_btn_pre then
		self.game_btn_pre:MyExit()
	end
	self:RemoveListener()
end

function C:ctor(parm)

	ExtPanel.ExtMsg(self)
	self.dot_del_obj = true


	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.config = FishingHallModel.GetHallCfg()
	self.parm = parm
	dump(self.config, "<color=yellow>配置</color>")
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	self:AddMsgListener()

	self.BackButton = tran:Find("TopRect/RectTop/BackButton"):GetComponent("Button")
	self.BackButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)
	self.SetButton = tran:Find("TopRect/RectTop/SetButton"):GetComponent("Button")
	self.SetButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		SettingPanel.Create()
	end)
	self.AddGold = tran:Find("TopRect/RectTop/JBBG"):GetComponent("Button")
	self.AddGold.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnAddGold()
	end)
	-- self.AddDiamond = tran:Find("TopRect/RectTop/ZSBG"):GetComponent("Button")
	-- self.AddDiamond.onClick:AddListener(function ()
	-- 	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	-- 	self:OnAddDiamond()
	-- end)
	self.GoldText = tran:Find("TopRect/RectTop/JBBG/GoldText"):GetComponent("Text")
	self.DiamondText = tran:Find("TopRect/RectTop/ZSBG/DiamondText"):GetComponent("Text")
	self.KSText = tran:Find("DLRect/KSButton/KSText"):GetComponent("Text")

	self.KSButton = tran:Find("DLRect/KSButton"):GetComponent("Button")
	self.KSButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnKSButton()
	end)

	self.TYText = tran:Find("DLRect/TYButton/TYText"):GetComponent("Text")
	self.TYParticle = tran:Find("DLRect/TYButton/Particle")
	self.TYButton = tran:Find("DLRect/TYButton"):GetComponent("Button")
	self.TYButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnTYButton()
	end)

	self.WikiButton = tran:Find("TopRect/RectTop/WikiButton"):GetComponent("Button")
	self.WikiButton.onClick:AddListener(function ()
		self:OnWikiClick()
	end)

	self.fishmatch_hint = tran:Find("DLRect/FishingMatchBtn/fishmatch_hint")
	self.fishmatch_hint.gameObject:SetActive(false)

	for k,v in pairs(self.config) do
		if not FishingHallModel.CehckIsTY(v.game_id) then
			local _id = v.game_id
			self["Item" .. _id] =  tran:Find("CenterRect/ItemBtn" .. _id)
			self["ItemBtn" .. _id] = tran:Find("CenterRect/ItemBtn" .. _id.. "/@bg_btn"):GetComponent("Button")
			self["ItemBtn" .. _id].onClick:AddListener(function ()
				local game_id = _id
				self:OnItemBtnClick(game_id)
			end)
			self["ItemTxt" .. _id] = tran:Find("CenterRect/ItemBtn" .. _id.. "/@gold_txt"):GetComponent("Text")
			self:SetEnterNum(self["ItemTxt" .. _id],v)
			self["Img_Item" .. _id] = self["Item" .. _id]:GetComponentsInChildren(typeof(UnityEngine.UI.Image), true)
			self["Txt_Item" .. _id] = self["Item" .. _id]:GetComponentsInChildren(typeof(UnityEngine.UI.Text), true)
			self["Ani".._id] = tran:Find("CenterRect/ItemBtn" .. _id):GetComponent("Animator")
			self["PS".._id] = tran:Find("CenterRect/ItemBtn" .. _id .. "/PS")
		end
	end
	self:InitUI()
	
	self.FishingDR = tran:Find("DLRect/FishingDRBtn"):GetComponent("Button")
	self.FishingDR.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnClickFishingDR()
	end)
	self.FishingDR.gameObject:SetActive(GameGlobalOnOff.FishingDR)

	self.FishingMatch = tran:Find("DLRect/FishingMatchBtn"):GetComponent("Button")
	self.FishingMatch.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnClickFishingMatch()
	end)
	self.FishingMatch.gameObject:SetActive(GameGlobalOnOff.FishingMatch)

	if MainModel.IsHWLowPlayer() then
		self.FishingDR.gameObject:SetActive(false)
	end

	-- 屏蔽
	self.FishingMatch.gameObject:SetActive(false)
	self.FishingDR.gameObject:SetActive(false)
	-- 屏蔽街机捕鱼-体验场
    self.TYButton.gameObject:SetActive(false)
end

function C:InitUI()
	-- self.KSText.text = self.rapid.name
	self.GoldText.text =  StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	self.DiamondText.text = StringHelper.ToCash(MainModel.UserInfo.fish_coin or 0)

	-- self:SetCurSwitch(self.rapid.game_id)
	self:SetCurSwitchByGold()
	local ty_cfg = FishingHallModel.CehckIsTYCfg()
	self:SetEnterNum(self.TYText,ty_cfg)
	self:RefreshFishingMatch()

	local btn_map = {}
	btn_map["right_top"] = {self.Node2}
	btn_map["top"] = {self.top_r_enter_node1}
	btn_map["top_c"] = {self.top_r_enter_node3}
	btn_map["down"] = {self.Node1}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "fishing_hall")
	self:MyRefresh()
end

function C:SetEnterNum(txt, v)
	if v.enter_min and v.enter_max then
		txt.text = string.format( "%s-%s金币入场",StringHelper.ToCash(v.enter_min),StringHelper.ToCash(v.enter_max))
	elseif v.enter_min and not v.enter_max then
		txt.text = string.format( "%s金币以上入场",StringHelper.ToCash(v.enter_min))
	elseif not v.enter_min and v.enter_max then
		txt.text = string.format( "%s金币以下入场",StringHelper.ToCash(v.enter_max))
	end
end

function C:MyRefresh()
end

function C:UpdateAssetInfo()
	if IsEquals(self.GoldText) and  IsEquals(self.DiamondText) then
		self.GoldText.text =  StringHelper.ToCash(MainModel.UserInfo.jing_bi)
		self.DiamondText.text = StringHelper.ToCash(MainModel.UserInfo.fish_coin)
	end
	self:SetCurSwitchByGold()
end

function C:OnKSButton()
	self:Sign(self.rapid.game_id)
end
-- 关闭
function C:OnBackClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	GameManager.GotoSceneName("game_Hall")
end

function C:OnAddGold()
	PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
end

function C:OnAddDiamond()
	PayPanel.Create(GOODS_TYPE.goods, "normal")
end

function C:OnDHClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    MainModel.OpenDH()
end

function C:OnWikiClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    FishingBKPanel.New()
end

function C:OnItemBtnClick(game_id)
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="fishing_"..game_id}, "CheckCondition")
    if a and not b then
    	return
    end
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	if self:CheckCurSwitch(game_id) then
		local cfg = FishingHallModel.GetGameIDToConfig(game_id)
		local gold =  FishingHallModel.GetFishCoinAndJingBi()
		self:CheckSign(cfg,gold,game_id,"你太富有了，请前往对应场")
	else
		self:SetCurSwitch(game_id)
	end
end

function C:CheckCurSwitch(game_id)
	if self.cur_switch then
		return self.cur_switch.game_id == game_id
	end
	return false
end

function C:SetCurSwitch(game_id)
	self.cur_switch = self.config[game_id]
	local function set_ui(_id,s,t,p,c,sp,b)
		self:ChangeScale(self["Item" .. _id].transform,s, t)
		self:ChangePos(self["Item" .. _id].transform,_id, t, p)
		self:ChangeUIArrColor(self["Img_Item" .. _id],c)
		self:ChangeUIArrColor(self["Txt_Item" .. _id],c)
		self["Ani".._id].speed = sp
		self["PS".._id].gameObject:SetActive(b)
	end
	if self.cur_switch then
		if IsEquals(self.TYParticle) then
			self.TYParticle.gameObject:SetActive(false)
		end
		for k,v in pairs(self.config) do
			if not FishingHallModel.CehckIsTY(v.game_id) then
				local _id = v.game_id
				if self.cur_switch and _id ~= self.cur_switch.game_id then
					set_ui(_id,0.8,0.4,652,0.7,0,false)
				else
					set_ui(_id,1,0.4,620,1,1,true)
				end
			end
		end
	else
		if IsEquals(self.TYParticle) then
			self.TYParticle.gameObject:SetActive(true)
		end
		for k,v in pairs(self.config) do
			if not FishingHallModel.CehckIsTY(v.game_id) then
				local _id = v.game_id
				set_ui(_id,0.8,0.4,652,0.7,0,false)
			end
		end
	end
	if self.cur_switch then
		Event.Brocast("ui_byhall_select_msg", self.cur_switch.index)
	else
		Event.Brocast("ui_byhall_select_msg", -1)
	end
end

function C:Sign(g_id)
	GameManager.CommonGotoScence({gotoui = "game_Fishing",p_requset = {id = g_id},goto_scene_parm={game_id = g_id}}, function ()
		PlayerPrefs.SetInt(FishingHallModel.FishRapidBeginKey, g_id)
	end)
end

function C:ChangeUIArrColor(ui_arr, num)
	for i = 0, ui_arr.Length - 1 do
		ui_arr[i].color = Color.New(num,num,num)
	end
end

function C:ChangeScale(tf, s, t)
	local ani_kill_callback = function ()
		if IsEquals(tf) then
			tf.localScale = Vector3.one * s
		end
	end
	local tween = tf:DOScale(Vector3.one * s,t)
	local seq = DoTweenSequence.Create()
	seq:Append(tween):OnForceKill(ani_kill_callback)
end

function C:ChangePos(tf, _id, t ,posx)
	if _id == 2 then return end
	local pos = tf.localPosition
	if _id == 1 then
		posx = -posx
	end
	local ani_kill_callback = function ()
		if IsEquals(tf) then
			tf.localPosition = Vector3.New(posx,pos.y,pos.z)
		end
	end
	local tween = tf:DOLocalMove(Vector3.New(posx,pos.y,pos.z),t)
	local seq = DoTweenSequence.Create()
	seq:Append(tween):OnForceKill(ani_kill_callback)
end

function C:OnTYButton()
	if MainModel.GetItemCount(GOODS_TYPE.jing_bi) < 10 and MainModel.GetItemCount("fish_coin") < 10 then
		GameButtonManager.RunFun({ gotoui="sys_jjj"}, "CheckAndRunJJJ", function ()
            Event.Brocast("show_gift_panel")
        end)
	else
		local cfg = FishingHallModel.GetGameIDToConfig(4)
		local gold =  FishingHallModel.GetFishCoinAndJingBi()
		self:CheckSign(cfg,gold,4,"你太富有了，请前往正式场")
	end
end

function C:SetCurSwitchByGold()
	local _cfg = FishingHallModel.CheckRecommendBeginGameIDByGold()
	if _cfg then
		self:SetCurSwitch(_cfg.game_id)
	else
		self:SetCurSwitch()
	end
	return _cfg
end

function C:CheckSign(cfg,gold,game_id,hint_desc)
	local can_sign, check_result = FishingHallModel.CheckCanBeginGameIDByGold(cfg, gold)
	if can_sign then
		--报名
		self:Sign(game_id)
	else
		if check_result == 1 then
			PayPanel.Create(GOODS_TYPE.jing_bi)
		elseif check_result == 2 then
			LittleTips.Create(hint_desc)
			self:SetCurSwitchByGold()
		end
	end
end

-- 刷新捕鱼比赛提示
function C:RefreshFishingMatch()
	local b = FishingManager.IsTodayHaveMatch()
	if b then
		self.fishmatch_hint.gameObject:SetActive(true)
	else
		self.fishmatch_hint.gameObject:SetActive(false)
	end
end

function C:OnClickFishingDR()
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="jing_yu_kuai_pao_game", is_on_hint = false}, "CheckCondition")
    if a and not b then
        return
    end
    GameManager.CommonGotoScence({gotoui="game_FishingDR"})
end
function C:OnClickFishingMatch()
	FishingMatchSignupPanel.Create()
end