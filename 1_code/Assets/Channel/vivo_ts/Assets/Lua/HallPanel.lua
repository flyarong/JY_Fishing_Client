local basefunc = require "Game.Common.basefunc"
HallPanel = basefunc.class()

HallPanel.name = "HallPanel"

-- by lyx 商城的 url
local shop_url
local instance

--自己关心的事件
local lister
function HallPanel:MakeLister()
	lister={}
    lister["AssetChange"] = self.updateAssetInfoHandler
	lister["update_dressed_head_frame"] = basefunc.handler(self, self.update_dressed_head_frame)
	lister["model_update_init_rapid_id"] = basefunc.handler(self, self.model_update_init_rapid_id)

	lister["model_query_vip_base_info_response"] = basefunc.handler(self, self.set_vip_info)
	lister["model_vip_upgrade_change_msg"] = basefunc.handler(self, self.set_vip_info)

	lister["MainModelUpdateVerify"] = basefunc.handler(self, self.UpdateVerifide)
	lister["ReConnecteServerSucceed"] = basefunc.handler(self, self.ReConnecteServerSucceed)
	lister["client_system_variant_data_change_msg"] = basefunc.handler(self,self.on_model_vip_level_is_up_msg)
end



function HallPanel:AddLister()
    for proto_name,func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end

function HallPanel:RemoveLister()
    if lister and next(lister) then
		for msg,cbk in pairs(lister) do
			Event.RemoveListener(msg, cbk)
		end	
	end
    lister=nil
end

function HallPanel.Create(call)
	DSM.PushAct({panel = "HallPanel"})
	instance=HallPanel.New(call)
	return instance
end

function HallPanel:SetupBtns()
	self.JBSBox.PointerClick:AddListener(function (obj)
		self:OnMatchClick(obj)
	end)
	self.JBSTSBox.PointerClick:AddListener(function (obj)
		self:OnMatchClick(obj)
	end)
	self.QPBox.PointerClick:AddListener(function (obj)
		local _,ksdata = GameFreeModel.CheckRapidBeginGameID ()
		dump(ksdata, "----------------- rapid begin game ----------------------")
		if ksdata and ksdata.order == 1 and GameGlobalOnOff.Shop_10_gift_bag and GameFreeModel.IsRoomEnter(ksdata.game_id) == 1 then
			OneYuanGift.Create(nil, function ()
				GameFreeModel.RapidBeginGame()			
			end)
		else
			GameFreeModel.RapidBeginGame()
		end
	end)
	self.PEBox.PointerClick:AddListener(function (obj)
		-- GameManager.GotoSceneID(19)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		GameFreeModel.RapidBeginGameLevel(1)
	end)
	self.MINIGAMEBox.PointerClick:AddListener(function (obj)
		self:OnMiniGameClick(obj)
	end)

	self.QYBox.PointerClick:AddListener(function (obj)
		self:OnMatchQYSClick(obj)
	end)

	self.Fishing3DBox.PointerClick:AddListener(function (obj)
		self:OnFishing3DClick(obj)
	end)
	
	self.JJBYBox.PointerClick:AddListener(function (obj)
		self:OnJJBYClick(obj)
	end)

	self.TTLBox.PointerClick:AddListener(function (obj)
		self:OnTTLClick(obj)
	end)
	
	self.FishingMatchBox.PointerClick:AddListener(function (obj)
		self:OnFishingMatchClick(obj)
		--LittleTips.Create("敬请期待")
	end)

	self.FKBYBox.PointerClick:AddListener(function (obj)
		self:OnFishingDRClick(obj)
	end)

end



function HallPanel:ctor(call)

	ExtPanel.ExtMsg(self)
	self.dot_del_obj = true

    Event.Brocast("Now_In_Game_Hall")

	local parent = GameObject.Find("Canvas/LayerLv1").transform
	local obj = newObject(HallPanel.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self.openCall = call
	LuaHelper.GeneratingVar(self.transform, self)

	EventTriggerListener.Get(self.player_center_btn.gameObject).onClick = basefunc.handler(self, self.OnPlayerCenterClick)
	--EventTriggerListener.Get(self.duihuan_btn.gameObject).onClick = basefunc.handler(self, self.OnStoreClick)

	EventTriggerListener.Get(self.pay_btn.gameObject).onClick = basefunc.handler(self, self.OnPayClick)
	EventTriggerListener.Get(self.set_btn.gameObject).onClick = basefunc.handler(self, self.OnSetClick)
	EventTriggerListener.Get(self.service_btn.gameObject).onClick = basefunc.handler(self, self.OnServiceClick)
	EventTriggerListener.Get(self.LBDH_btn.gameObject).onClick = basefunc.handler(self, self.OnLBDHClick)

	EventTriggerListener.Get(self.AddGold_btn.gameObject).onClick = basefunc.handler(self, self.OnAddGoldClick)
	EventTriggerListener.Get(self.AddDiamond_btn.gameObject).onClick = basefunc.handler(self, self.OnAddDiamondClick)
	EventTriggerListener.Get(self.activity_btn.gameObject).onClick = basefunc.handler(self, self.OnActivityClick)
	EventTriggerListener.Get(self.rw_btn.gameObject).onClick = basefunc.handler(self, self.OnDailyTaskClick)
	EventTriggerListener.Get(self.money_center_btn.gameObject).onClick = basefunc.handler(self, self.OnMoneyConterClick)
	EventTriggerListener.Get(self.bag_btn.gameObject).onClick = basefunc.handler(self, self.OnBagClick)
	EventTriggerListener.Get(self.email_btn.gameObject).onClick = basefunc.handler(self, self.OnEmailClick)
	EventTriggerListener.Get(self.scanner_btn.gameObject).onClick = basefunc.handler(self, self.OnScannerClick)

	EventTriggerListener.Get(self.change_city_btn.gameObject).onClick = basefunc.handler(self, self.OnChangeCityClick)

	EventTriggerListener.Get(self.PhoneButton_btn.gameObject).onClick = basefunc.handler(self, self.OnPhoneClick)
	EventTriggerListener.Get(self.GZHButton_btn.gameObject).onClick = basefunc.handler(self, self.OnGZHClick)
	EventTriggerListener.Get(self.kffk_btn.gameObject).onClick = basefunc.handler(self, self.OnKFFKClick)

	EventTriggerListener.Get(self.Area_btn.gameObject).onClick = basefunc.handler(self, self.OnAreaClick)
	EventTriggerListener.Get(self.VIP_btn.gameObject).onClick = basefunc.handler(self, self.OnVIPClick)
	EventTriggerListener.Get(self.fuli_btn.gameObject).onClick = basefunc.handler(self, self.OnFuliClick)
	GameManager.GotoUI({gotoui = "sys_banner_hall",goto_scene_parm = "panel",BannerNode = self.BannerNode})
	self.updateAssetInfoHandler = function ()
		self:UpdateAssetInfo()
	end

	--for dynamic replace image
	-- local PETitle = self.RectCenter.transform:Find("@PE/Image"):GetComponent("Image")
	if IsEquals(PETitle) then
		PETitle:SetNativeSize()
	end

	self.JBSBox = self.JBSBox:GetComponent("PolygonClick")
	self.JBSTSBox = self.JBSTSBox:GetComponent("PolygonClick")
	self.FKBox = self.FKBox:GetComponent("PolygonClick")
	self.QPBox = self.QPBox:GetComponent("PolygonClick")
	self.PEBox = self.PEBox:GetComponent("PolygonClick")
	self.MINIGAMEBox = self.MINIGAMEBox:GetComponent("PolygonClick")
	self.QYBox = self.QYBox:GetComponent("PolygonClick")
	self.Fishing3DBox = self.Fishing3DBox:GetComponent("PolygonClick")
	self.JJBYBox = self.JJBYBox:GetComponent("PolygonClick")
	self.TTLBox = self.TTLBox:GetComponent("PolygonClick")
	self.FishingMatchBox = self.FishingMatchBox:GetComponent("PolygonClick")
	self.FKBYBox = self.FKBYBox:GetComponent("PolygonClick")
    EventTriggerListener.Get(self.ServiceTop.gameObject).onClick = basefunc.handler(self, self.SetServiceTopClick)

	self.headimage = self.player_center_btn.gameObject:GetComponent("Image")
	self:update_dressed_head_frame()
	self:set_vip_info()
	
	--刷新头像
	URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.player_head_img)
	
	self.player_name_txt.text = MainModel.UserInfo.name
	self.shop_gold_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	self.duihuan_num_txt.text = StringHelper.ToRedNum(MainModel.GetHBValue())
	self.shop_diamond_txt.text = StringHelper.ToCash(MainModel.UserInfo.diamond)

	self.QPJJHintKey = "QPJJHintKey" .. MainModel.UserInfo.user_id
	self:UpdateDHHint()

	self.ServiceNode.gameObject:SetActive(false)
	self:InitAnim()
	self:EnterAnim()

	--更新部分
	self.updateHintTmpl = self.transform:Find("UpdateHintTmpl")
	self.updateUI = {}
	self:UpdateUpdateHint()

	self.ksSpine = self.dt_dizhu:GetComponent("SkeletonAnimation")

	self:MakeLister()
	self:AddLister()

	local deeplink = sdkMgr:GetDeeplink()
	if not deeplink or deeplink == "" then
		print("<color=red>deeplink is null</color>")
	else
		print("<color=red>deeplink = " .. deeplink .. "</color>")
		MainLogic.HandleOpenURL(deeplink)
	end
	self:model_update_init_rapid_id()

	MainModel.GetVerifyStatus()
	MainModel.GetBindPhone()
	-- GameTaskModel.InitTaskRedHint()
	GameTaskModel.ChangeTaskCanGetRedHint()

	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_Email, self.email_red.gameObject)
	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_EmailHint, self.email_hint.gameObject)
	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_Head, self.head_red.gameObject)
	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_Bag, self.bag_red.gameObject)

	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="drt_block_binding_phone_num", is_on_hint = true}, "CheckCondition")
	local bindphone = (not a or (a and not b)) and GameGlobalOnOff.BindingPhone
	if bindphone then
		RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_PhoneAward, self.phone_award_red.gameObject)
	else
		self.phone_award_red.gameObject:SetActive(false)
	end

	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_Activity, self.activity_red.gameObject)
	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_Activity_GET, self.activity_get.gameObject)
	-- RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_GD, self.service_red.gameObject)
	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_Money_Center, self.money_center_red.gameObject)
	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_Fuli, self.fuli_red.gameObject)
	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_Fuli_GET, self.fuli_get.gameObject)
	
	RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Daily_Task)
	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_Daily_Task,self.rw_get.gameObject)

	RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_XYCJ)
	 --年末回馈修改UI
	Event.Brocast("act_match_order_msg_change",{ButtonGet_Game = self.activity_lmp:GetComponent("Image")})
	self:OnOff()
	--大厅活动图标更新
	self:RefreshActivityUI()
	self:OpenUIAnim()

	HandleLoadChannelLua("HallPanel", self)

	GameButtonManager.RunFun({gotoui = "sys_cfzx"}, "GetSCZDBaseInfo")

	local btn_map = {}
	btn_map["left"] = {self.hall_btn_5, self.hall_btn_6, self.hall_btn_7, self.hall_btn_8}
	btn_map["right"] = {self.hall_btn_22, self.hall_btn_23, self.hall_btn_24, self.hall_btn_25}
	btn_map["right_top"] = {self.hall_btn_4, self.hall_btn_3, self.hall_btn_2, self.hall_btn_1}
	btn_map["top"] = {self.hall_btn_top}
	btn_map["fish3d_node"] = {self.Fishing3DNode}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "hall_config", self.transform)
	self:MyRefresh()

	self:TTL_zhezhao()
	self:FKBY_zhezhao()

	MainModel.SetGameBGScale(self.BGImg)
	--年末回馈修改UI
	Event.Brocast("act_match_order_msg_change",{hall_img = self.QY.gameObject.transform:Find("Image"):GetComponent("Image")})
end

function HallPanel:TTL_zhezhao()
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "sgxxl_level", is_on_hint = true}, "CheckCondition")
    if a and b then
        self.lock_TTL.gameObject:SetActive(false)
    else
    	self.lock_TTL.gameObject:SetActive(true)
    end
end

function HallPanel:FKBY_zhezhao()
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "jing_yu_kuai_pao_game", is_on_hint = true}, "CheckCondition")
    if a and b then
        self.lock_FKBY.gameObject:SetActive(false)
    else
    	self.lock_FKBY.gameObject:SetActive(true)
    end
end

function HallPanel:MyRefresh()
	-- 捕鱼
	-- self.transform:Find("Top/@RectTop/TitleImage/caiqi").gameObject:SetActive(false)
	-- self.transform:Find("Top/@RectTop/TitleImage/fj").gameObject:SetActive(false)
	-- self.transform:Find("Top/@RectTop/TitleImage/qiqiu").gameObject:SetActive(false)
	-- if os.time() >= 1579881600 then
	-- 	self.transform:Find("Top/@RectTop/TitleImage/fu").gameObject:SetActive(true)
	-- 	self.transform:Find("Top/@RectTop/TitleImage/shizi").gameObject:SetActive(false)
	-- else
	-- 	self.transform:Find("Top/@RectTop/TitleImage/fu").gameObject:SetActive(false)
	-- 	self.transform:Find("Top/@RectTop/TitleImage/shizi").gameObject:SetActive(true)
	-- end

	self:UpdateAssetInfo()
	self:RefreshQYSMatch()

	self:UpdateVerifide()

	self:RefreshTJGame()
end
-- 刷新推荐游戏
function HallPanel:RefreshTJGame()
	if self.tj_game_pre then
		self.tj_game_pre:MyExit()
		self.tj_game_pre = nil
	end
	self.tj_game_pre = GameManager.GotoUI({gotoui="sys_dttjyxw", goto_scene_parm="prefab", parent=self.TJGameNode})
end
-- 刷新千元赛比赛提示
function HallPanel:RefreshQYSMatch()
	local b = GameMatchModel.IsTodayHaveMatch()
	if b then
		self.qys_jb_img.gameObject:SetActive(true)
		self.qys_jb_not_img.gameObject:SetActive(false)
	else
		self.qys_jb_img.gameObject:SetActive(false)
		self.qys_jb_not_img.gameObject:SetActive(true)
	end
end

function HallPanel:model_update_init_rapid_id()
	local _,ksdata = GameFreeModel.CheckRapidBeginGameID ()
	if not IsEquals(self.KS_img) then
		return
	end
	if ksdata then
		self.KS_img.gameObject:SetActive(true)
		self.KS_img.sprite = GetTexture(ksdata.image)
		self.KS_img:SetNativeSize()
		self.KS_txt.text = "底分 " .. ksdata.base

		if self.QP.gameObject.activeSelf and self.ksSpine and IsEquals(self.ksSpine) then
			if string.sub(ksdata.game_type, 1, 7) == "game_Mj" then
				self.ksSpine.AnimationName = "majiang"
			else
				self.ksSpine.AnimationName = "doudizhu"
			end
		end
	else
		self.KS_img.gameObject:SetActive(false)
		self.KS_txt.text = ""
	end
end

function HallPanel:update_dressed_head_frame()
	if true then return end
	PersonalInfoManager.SetHeadFarme(self.headimage)
end
function HallPanel:UpdateDHHint()
	if MainModel.GetHBValue() >= 10 then
		local newtime = tonumber(os.date("%Y%m%d", os.time()))
        local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString("HallDHHintTime" .. MainModel.UserInfo.user_id, 0))))
		if oldtime ~= newtime then
			self.duihuan_hint_txt.text = "您有" .. StringHelper.ToRedNum(MainModel.GetHBValue()/100) .. "元可兑换"
			if IsEquals(self.duihuan_hint) then
				self.duihuan_hint.gameObject:SetActive(true)
			end
		else
			if IsEquals(self.duihuan_hint) then
				self.duihuan_hint.gameObject:SetActive(false)
			end
		end
	else
		if IsEquals(self.duihuan_hint) then
			self.duihuan_hint.gameObject:SetActive(false)
		end
	end

	if GameGlobalOnOff.InternalTest then
		self.duihuan_hint.gameObject:SetActive(false)
	end
end
-- 界面打开的动画
function HallPanel:OpenUIAnim()
	if true then
		local tt = 0.25

		local RectLeft_x = self.RectLeft.transform.localPosition.x

		self.RectTop.transform.localPosition = Vector3.New(0, 118, 0)
		self.RectLeft.transform.localPosition = Vector3.New(-500 + RectLeft_x, self.RectLeft.transform.localPosition.y, 0)
		self.RectCenter.transform.localPosition = Vector3.New(1560, 0, 0)
		self.RectDownL.transform.localPosition = Vector3.New(0, -94, 0)
		self.RectDownR.transform.localPosition = Vector3.New(435, 0, 0)
		self.log_img.transform.localScale = Vector3.New(0.1,0.1,0.1)

		local seq = DoTweenSequence.Create()
		seq:Join(self.RectTop.transform:DOLocalMoveY(-92, tt))
		-- seq:AppendInterval(-1 * tt)
		-- seq:Join(self.RectLeft.transform:DOLocalMoveX(-540, tt))
		seq:Join(self.RectLeft.transform:DOLocalMoveX(RectLeft_x, tt))
		-- seq:AppendInterval(-1 * tt)
		-- seq:Join(self.RectCenter.transform:DOLocalMoveX(360, tt))
		seq:Join(self.RectCenter.transform:DOLocalMoveX(0, tt))
		-- seq:AppendInterval(-1 * tt)
		seq:Join(self.RectDownL.transform:DOLocalMoveY(42, tt))
		-- seq:AppendInterval(-1 * tt)
		seq:Join(self.RectDownR.transform:DOLocalMoveX(0, tt))
		seq:Join(self.log_img.transform:DOScale(Vector3.New(1,1,1), tt))
		seq:Append(self.RectDownR.transform:DOScale(Vector3.New(2,2,2), 0.1))
		seq:Append(self.RectDownR.transform:DOScale(Vector3.New(1,1,1), 0.1))
		seq:OnComplete(function ()
		end)
		seq:OnForceKill(function ()
			self:OpenUIAnimFinish()
		end)
	else
		self:OpenUIAnimFinish()
	end
end
function HallPanel:OpenUIAnimFinish()
	if not IsEquals(self.RectTop) then
		return
	end
	self:SetupBtns()
	
	--同步一下任务数据
	local SYNC_TASK_TBL = { 53, 54 }
	for _, v in pairs(SYNC_TASK_TBL) do
		Network.SendRequest("query_one_task_data", {task_id = v})
	end
	
	local call = function ()
		if self.openCall then
			self.openCall()
		end
	end

	call()
end
-- 客服全局点击控制
function HallPanel:SetServiceTopClick()
	if IsEquals(self.ServiceNode) then
		self.ServiceNode.gameObject:SetActive(false)
	end
end

function HallPanel:OnOff()
	self.JBSTS.gameObject:SetActive(false)

	if GameGlobalOnOff.PlayerInfo then
		self.player_center_btn:GetComponent("Image").raycastTarget = true
	else
		self.player_center_btn:GetComponent("Image").raycastTarget = false
	end

	-- if GameGlobalOnOff.Exchange then
	-- 	self.duihuan_btn.gameObject:SetActive(true)
	-- else
	-- 	self.duihuan_btn.gameObject:SetActive(false)
	-- end

	if GameGlobalOnOff.Shop then
		self.pay_btn.gameObject:SetActive(true)
	else
		self.pay_btn.gameObject:SetActive(false)
	end

	if GameGlobalOnOff.Money_Center then
		self.money_center_btn.transform.parent.gameObject:SetActive(true)
	else
		self.money_center_btn.transform.parent.gameObject:SetActive(false)
	end
end

function HallPanel:OnAddGoldClick(go)
	PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
end

function HallPanel:OnAddDiamondClick(go)
	PayPanel.Create(GOODS_TYPE.goods, "normal")
end

--比赛场
function HallPanel:OnMatchClick(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	-- local parm = {match_type_id = 1}
	GameManager.GotoSceneID(GameConfigToSceneCfg.game_Match.ID)
end

-- 小游戏
function HallPanel:OnMiniGameClick(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	GameManager.GotoSceneName("game_MiniGame", {down_style={panel=self.MINIGAME.transform}})	
end

-- 千元赛
function HallPanel:OnMatchQYSClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local parm = {match_type_id = 5}
	--年末回馈修改UI
	Event.Brocast("act_match_order_msg_change",{goto_parm = parm})
	GameManager.GotoSceneID(GameConfigToSceneCfg.game_Match.ID,parm)
end

function HallPanel:OnFishing3DClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	GameManager.GotoSceneName("game_Fishing3DHall")
end

function HallPanel:OnJJBYClick()
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="fishing_1", is_on_hint = false}, "CheckCondition")
    if a and not b then
        return
    end
	if GameGlobalOnOff.InternalTest then
		HintPanel.Create(1, "暂未开放，敬请期待")
		return
	end
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	GameManager.GotoSceneName("game_FishingHall")
end

-- 弹弹乐入口换成了消消乐入口
function HallPanel:OnTTLClick()
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="sgxxl_level", is_on_hint = false}, "CheckCondition")
    if a and not b then
        return
    end
	if GameGlobalOnOff.InternalTest then
		HintPanel.Create(1, "暂未开放，敬请期待")
		return
	end
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)

	GameManager.GotoUI({gotoui="game_Eliminate", goto_scene_parm={down_style={panel=self.TTL.transform}}, enter_scene_call=function()
		if not Network.SendRequest("xxl_enter_game", nil ,"正在进入") then
            HintPanel.Create(1, "网络异常", function()
                GameManager.GotoSceneName("game_Hall")
            end)
		end
	end})
end

function HallPanel:OnFishingMatchClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	GameManager.GotoSceneName("game_FishingMatchHall")	
end

function HallPanel:OnFishingDRClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="jing_yu_kuai_pao_game", is_on_hint = false}, "CheckCondition")
    if a and not b then
        return
    end
    
	GameManager.GotoUI({gotoui="game_FishingDR", goto_scene_parm=true, enter_scene_call=function()
		--测试数据
		--[[
			local data = {
			result = 0
		}
		Event.Brocast("fishing_dr_enter_game_response","fishing_dr_enter_game_response", data)
		--]]

		 if not Network.SendRequest("fishing_dr_enter_room", nil ,"正在进入") then
		 	HintPanel.Create(1, "网络异常", function()
		  		GameManager.GotoSceneName("game_FishingHall")
		  	end)
		end
	end})
end

function HallPanel:OnAreaClick()
	HintPanel.Create(1, "敬请期待")
end

function HallPanel:OnVIPClick()
	local vip_l = VIPManager.get_vip_level()
	if vip_l > 0 then
		GameManager.GotoUI({gotoui="vip", goto_scene_parm="vip_task", goto_scene_parm1 = "vip_tq"})
	else
		GameManager.GotoUI({gotoui="vip", goto_scene_parm="VIP2"})
	end
end

--打开邮件
function HallPanel:OnEmailClick(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	EmailLogic.GotoUI({gotoui="sys_email", goto_scene_parm="panel"})
	self.ServiceNode.gameObject:SetActive(false)
end

--打开兑换
-- function HallPanel:OnStoreClick(go)
-- 	DSM.PushAct({button = "store_btn"})
-- 	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)

-- 	MainModel.OpenDH()
-- 	self:UpdateDHHint()
-- end

--打开充值
function HallPanel:OnPayClick(go)
	DSM.PushAct({button = "pay_btn"})
	Event.Brocast("bsds_add",{key = "pay_btn_enter"})
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	HallLogic.gotoPay()
end

--打开设置
function HallPanel:OnSetClick(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	GameManager.GotoUI({gotoui = "sys_setting",goto_scene_parm = "panel"})
	self.ServiceNode.gameObject:SetActive(false)
end

--打开礼包兑换
function HallPanel:OnLBDHClick(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self.ServiceNode.gameObject:SetActive(false)
	GameManager.GotoUI({gotoui = "sys_gift_exchange",goto_scene_parm = "panel"})
end

-- 打开活动
function HallPanel:OnActivityClick(go)
	DSM.PushAct({button = "activity_btn"})
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	GameManager.GotoUI({gotoui="hall_activity", goto_scene_parm="panel"})
end

--打开每日活跃任务
function HallPanel:OnDailyTaskClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	if ActiveDailyTaskManager then
		ActiveDailyTaskManager.GotoUI({goto_scene_parm = "panel"})
	end
end

--财富中心
function HallPanel:OnMoneyConterClick(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	Event.Brocast("open_game_money_center")
end

--打开背包
function HallPanel:OnBagClick(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	-- GameManager.GotoUI({gotoui = "sys_bag",goto_scene_parm = "panel"})
	GameManager.GotoUI({gotoui = "sys_by_bag",goto_scene_parm = "panel"})
	self.ServiceNode.gameObject:SetActive(false)
end

--扫码
function HallPanel:OnScannerClick(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	MainLogic.TryStartScan(function(k, v)
	end)
end

-- 打电话
function HallPanel:OnPhoneClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	sdkMgr:CallUp("028-63208358")
	self.ServiceNode.gameObject:SetActive(false)
end

-- 公众号
function HallPanel:OnGZHClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel"})	self.ServiceNode.gameObject:SetActive(false)
	self.ServiceNode.gameObject:SetActive(false)
end
function HallPanel:OnKFFKClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	MainModel.OpenKFFK()
	self.ServiceNode.gameObject:SetActive(false)
end

-- 客服中心
function HallPanel:OnServiceClick(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local b = self.ServiceNode.gameObject.activeInHierarchy
	self.ServiceNode.gameObject:SetActive(not b)
end

--打开玩家中心
function HallPanel:OnPlayerCenterClick(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local parm
	if not MainModel.UserInfo.phoneData or not MainModel.UserInfo.phoneData.phone_no then
		parm = {}
		parm.open_award = 1
	end
	GameManager.GotoUI({gotoui = "sys_personal_info",goto_scene_parm = "panel",parm = parm})
end

-- 切换地区
function HallPanel:OnChangeCityClick(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	if GameGlobalOnOff.ChangeCity then
		HintPanel.Create(1,"敬请期待")
	else
		HintPanel.Create(1,"目前只支持成都地区")
	end
end

function HallPanel:UpdateAssetInfo()
	if IsEquals(self.player_name_txt) then
		self.player_name_txt.text = MainModel.UserInfo.name
	end
	if IsEquals(self.shop_gold_txt) then
		self.shop_gold_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	end
	if IsEquals(self.duihuan_num_txt) then
		self.duihuan_num_txt.text = StringHelper.ToRedNum(MainModel.GetHBValue())
	end
	if IsEquals(self.shop_diamond_txt) then
		self.shop_diamond_txt.text = StringHelper.ToCash(MainModel.UserInfo.diamond)
	end
	self:model_update_init_rapid_id()
	self:UpdateDHHint()
	RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_XYCJ)

	RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Activity_Year)
	RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Activity_Year_Get)
	RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Daily_Task)
end

function HallPanel.HandleDownloadNetworkError()
	HintPanel.ErrorMsg(3001)
end

function HallPanel:SetBtnFade(nodeType, node, value)
	if nodeType == "spine" then
		local render = node.gameObject:GetComponent("Renderer")
		if render then
			render.sharedMaterial:SetFloat("_FillPhase", 1 - value)
		end
	else
		local images = node.gameObject:GetComponentsInChildren(typeof(UnityEngine.UI.Image))
		for i = 0, images.Length - 1 do
			images[i].color = Color.New(value, value, value, 1)
		end
	end
end
function HallPanel:SetBtnNotice(nodeType, node, value)
	local updateUI = self.updateUI
	local spineTbl = updateUI["spineTbl"] or {}

	local nodeName = node.name
	local go = spineTbl[nodeName]
	
	if value then
		local tmpl = self.updateHintTmpl
		if not go then
			local parent = GameObject.Find("Canvas/LayerLv1").transform
			go = GameObject.Instantiate(tmpl, parent)
			go.transform.localPosition = Vector3.zero
			go.transform.position = node.transform:Find("UpdateHintNode").position
			go.gameObject:SetActive(true)
			spineTbl[nodeName] = go
		end
	else
		if go then
			go.transform:SetParent(nil)
			destroy(go.gameObject)
			spineTbl[nodeName] = nil
		end

	end

	self.updateUI["spineTbl"] = spineTbl
end

function HallPanel:UpdateSceneState(sceneCfg)
	local sceneName = sceneCfg.SceneName
	if sceneName == "" then return end
	if sceneCfg.BtnName == nil or sceneCfg.BtnName == "" then return end

	local transform = self.transform
	local node = transform:Find(sceneCfg.BtnName)
	if not node then
		print(string.format("<color=red>[Update] UpdateSceneState(%d) error: btnNode(%s) not find</color>", sceneCfg.ID, sceneCfg.BtnName))
		return
	end

	if not node.gameObject.activeSelf then return end

	local state = gameMgr:CheckUpdate(sceneName)
	-- state = "Install"
	if state == "Install" or state == "Update" then
		self:SetBtnFade(sceneCfg.BtnType, node, 0.6)
		self:SetBtnNotice(sceneCfg.BtnType, node, true)
	else
		self:SetBtnFade(sceneCfg.BtnType, node, 1.0)
		self:SetBtnNotice(sceneCfg.BtnType, node, false)
	end
end

function HallPanel:UpdateUpdateHint()
	local sceneTbl = HallModel.GetGameSceneCfgByPanel(HallPanel.name)
	if sceneTbl == nil or #sceneTbl <= 0 then return end

	for _, v in pairs(sceneTbl) do
		self:UpdateSceneState(v)
	end
end

function HallPanel:ClearUpdateUI()
	local updateUI = self.updateUI

	local spineTbl = updateUI["spineTbl"] or {}
	for _, v in pairs(spineTbl) do
		dsestroy(v.gameObject)
	end

	self.updateUI = {}
end

function HallPanel:MyExit()
	DSM.PopAct()
	EmailLogic.ClosePanel()
	self:RemoveLister()
	GameManager.GotoUI({gotoui = "sys_banner_hall",goto_scene_parm = "panel_close"})
	if RoomCardHallPopPrefab then
		RoomCardHallPopPrefab.Close()
	end
	GameManager.GotoUI({gotoui = "sys_personal_info",goto_scene_parm = "panel_close"})
	self:ExitAnim()
	if self.game_btn_pre then
		self.game_btn_pre:MyExit()
	end
	if self.tj_game_pre then
		self.tj_game_pre:MyExit()
	end
end

function HallPanel:MyClose()
    self:MyExit()
    closePanel(HallPanel.name)
end

function HallPanel:InitAnim()
	self.anim_jbs = self.JBS:GetComponent("Animator")
	self.fx_pay = self.chongzhi.gameObject

end
function HallPanel:EnterAnim()
	self:PlayPayFX()
	self:PlayJBSFX()
end
function HallPanel:ExitAnim()
	if self.time_pay_anim then
		self.time_pay_anim:Stop()
	end
	if self.time_pay_fx then
		self.time_pay_fx:Stop()
	end
	if self.time_jbs_fx then
		self.time_jbs_fx:Stop()
	end
end

-- 充值特效
function HallPanel:PlayPayFX()
	local t = math.random(5, 10)
	self.time_pay_fx = Timer.New(function ()
		self.fx_pay:SetActive(false)
		self.fx_pay:SetActive(true)
		self.time_pay_fx:Stop()
		self:PlayPayFX()
	end, t)
	self.time_pay_fx:Start()
end
-- 充值特效
function HallPanel:PlayJBSFX()
	local t = math.random(5, 10)
	self.time_jbs_fx = Timer.New(function ()
		self.time_jbs_fx:Stop()
		if IsEquals(self.anim_jbs_jbs) then
			self.anim_jbs:Play("@JBS_liuguang", -1, 0)
		end
		self:PlayJBSFX()
	end, t)
	self.time_jbs_fx:Start()
end

function HallPanel.GetQYSZhouKaRemain()
	return HallPanel.qys_zhouka_remain or -1
end

function HallPanel:RefreshActivityUI()
	local transform = self.transform
	if not IsEquals(transform) then return end

	local function check_activity_time(time_table, current_time)
		for k, v in pairs(time_table) do
			if v[1] <= current_time and v[2] > current_time then
				return true
			end
		end
		return false
	end

	local function find_node(trans, node_name)
		local result = trans:Find(node_name)
		
		if not result then
			for idx = 0, trans.childCount - 1 do
				local child = trans:GetChild(idx)
				result = find_node(child, node_name)
				if result then return result end
			end
		end

		return result
	end

	local current_time = os.time()
	local timeTable = HallLogic.GetActivityTimeTable() or {}
	for k, v in pairs(timeTable) do
		if v.activity_node and v.activity_node ~= "" then
			local node = find_node(transform, v.activity_node)	--transform:Find(v.activity_node)
			if node then
				if check_activity_time(v.activity_time, current_time) then
					node.gameObject:SetActive(true)
				else
					node.gameObject:SetActive(false)
				end
			end
		end
	end	  
end

function HallPanel:set_vip_info()
	print("++++++++++++++++++++++set_vip_info")
	VIPManager.set_vip_text(self.head_vip_txt)
end

function HallPanel:UpdateVerifide()
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="drt_block_real_name_verify", is_on_hint = true}, "CheckCondition")
    if (a and b) or not GameGlobalOnOff.Certification then
        self.authentication.gameObject:SetActive(false)
        return
    end
	--print("HallPanel:UpdateVerifide: " .. MainModel.UserInfo.verifyData.status)
    if MainModel.UserInfo and MainModel.UserInfo.verifyData and MainModel.UserInfo.verifyData.status then
        local status = (MainModel.UserInfo.verifyData.status == 4 or MainModel.UserInfo.verifyData.status == 2)
        self.authentication.gameObject:SetActive(not status)
    else
        self.authentication.gameObject:SetActive(true)
	end
end
function HallPanel:ReConnecteServerSucceed()
	MainModel.GetVerifyStatus(basefunc.handler(self, self.UpdateVerifide))
end

function HallPanel:OnFuliClick()
	GameButtonManager.GotoUI({gotoui = "jyfl",goto_scene_parm = "panel"})
end

function HallPanel:on_model_vip_level_is_up_msg()
	self:TTL_zhezhao()
	self:FKBY_zhezhao()
end