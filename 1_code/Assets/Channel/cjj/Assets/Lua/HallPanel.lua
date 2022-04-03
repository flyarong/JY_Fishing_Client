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

	lister["model_query_vip_base_info_response"] = basefunc.handler(self, self.set_vip_info)
	lister["model_vip_upgrade_change_msg"] = basefunc.handler(self, self.set_vip_info)

	lister["MainModelUpdateVerify"] = basefunc.handler(self, self.UpdateVerifide)
	lister["ReConnecteServerSucceed"] = basefunc.handler(self, self.ReConnecteServerSucceed)
	lister["client_system_variant_data_change_msg"] = basefunc.handler(self,self.on_model_vip_level_is_up_msg)

	lister["SYSChangeHeadAndNameManager_Change_Name_Success_msg"] = basefunc.handler(self,self.on_SYSChangeHeadAndNameManager_Change_Name_Success_msg)
	lister["SYSChangeHeadAndNameManager_Change_Head_Success_msg"] = basefunc.handler(self,self.on_SYSChangeHeadAndNameManager_Change_Head_Success_msg)

	lister["ByTouXiangKuangBagPanel_set_head_msg"] = basefunc.handler(self,self.on_ByTouXiangKuangBagPanel_set_head_msg)
	lister["model_vip_upgrade_change_msg"] = basefunc.handler(self,self.on_model_vip_upgrade_change_msg)

	lister["AssetGet"] = basefunc.handler(self,self.on_AssetGet)
------大厅显示财神大奖
	--lister["lwzb_query_qlcf_info_response"] = basefunc.handler(self,self.on_lwzb_query_qlcf_info_response)
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
	self.lwzb_box.PointerClick:AddListener(function (obj)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnLWZBClick(obj)
	end)
	self.cjj_box.PointerClick:AddListener(function (obj)
		self:OnCJJClick(obj)
	end)
	self.sgxxl_box.PointerClick:AddListener(function (obj)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnSGXXLClick(obj)
	end)
	self.zpg_box.PointerClick:AddListener(function (obj)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnZPGClick(obj)
	end)
	self.hbc_box.PointerClick:AddListener(function (obj)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnMiniGameClick(obj)
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
	EventTriggerListener.Get(self.duihuan_btn.gameObject).onClick = basefunc.handler(self, self.OnStoreClick)

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

	self.lwzb_box = self.lwzb_box:GetComponent("PolygonClick")
	self.cjj_box = self.cjj_box:GetComponent("PolygonClick")
	self.sgxxl_box = self.sgxxl_box:GetComponent("PolygonClick")
	self.zpg_box = self.zpg_box:GetComponent("PolygonClick")
	self.hbc_box = self.hbc_box:GetComponent("PolygonClick")

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

	self:MakeLister()
	self:AddLister()

	local deeplink = sdkMgr:GetDeeplink()
	if not deeplink or deeplink == "" then
		print("<color=red>deeplink is null</color>")
	else
		print("<color=red>deeplink = " .. deeplink .. "</color>")
		MainLogic.HandleOpenURL(deeplink)
	end

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
	btn_map["right_top"] = {self.hall_btn_share,self.hall_btn_4, self.hall_btn_3, self.hall_btn_2, self.hall_btn_1,self.hall_btn_31,self.hall_btn_32,self.hall_btn_33}
	btn_map["top"] = {self.hall_btn_top}
	btn_map["left_bottom"] = {self.hall_btn_tgzq}
	btn_map["right_bottom"] = {self.hall_btn_top}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "hall_config", self.transform)

	self:MyRefresh()
	--self:SGXXL_zhezhao()
	self:ZPG_zhezhao()
	--self:CCJ_zhezhao()
	--self:ShowCSDJUIInHallPanel()
	self:CreateHallFxPrefab()
	self.lwzb.transform:Find("dj_image_1").gameObject:SetActive(false)
	MainModel.SetGameBGScale(self.BGImg)
	self.head_pre = CommonHeadInstancePrafab.Create({type = 1,
									parent = self.player_head_img.transform,
									scale = 1.2, 
									})
	Event.Brocast("hallpanel_created",{panelSelf = self})
end

----------------------------------------大厅遮罩-----------------------------
-- function HallPanel:SGXXL_zhezhao()
-- 	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "sgxxl_level", is_on_hint = true}, "CheckCondition")
--     if a and b then
--         self.sgxxl.gameObject:GetComponent("Image").color = Color.New(1,1,1,1)
--         self.lock_lv_sg.gameObject:SetActive(false)
--         self.sgxxl_box.gameObject:SetActive(true)
--     else
--     	self.sgxxl.gameObject:GetComponent("Image").color = Color.New(0.5,0.5,0.5,1)
--     end
-- end

function HallPanel:ZPG_zhezhao()
	--[[local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "drt_guess_apple_play", is_on_hint = true}, "CheckCondition")
    if a and b then -- vip_curlevel >= 1
        self.zpg.gameObject:GetComponent("Image").color = Color.New(1,1,1,1)
        self.lock_lv_zpg.gameObject:SetActive(false)
    else
    	self.zpg.gameObject:GetComponent("Image").color = Color.New(0.5,0.5,0.5,1)
    end--]]
end

-- function HallPanel:CCJ_zhezhao()
-- 	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "zjd_level", is_on_hint = true}, "CheckCondition")
--     if a and b then
--         self.cjj.gameObject:GetComponent("Image").color = Color.New(1,1,1,1)
--         self.lock_lv_cjj.gameObject:SetActive(false) 
--         self.cjj_box.gameObject:SetActive(true)
--     else
--     	self.cjj.gameObject:GetComponent("Image").color = Color.New(0.5,0.5,0.5,1)
--     end
-- end

----------------------------------------------财神大奖------------------------------------------------------
-- function HallPanel:ShowCSDJUIInHallPanel()
-- 	self:StopSendTime()
-- 	--local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "zjd_level", is_on_hint = true}, "CheckCondition")
--     --if a and b then
--        self.csdj_node.gameObject:SetActive(true)
--        if MainModel.myLocation == "game_Hall"then
--        		self:SendCSDJData()
--         	send_time = Timer.New(function ()
-- 	            	self:SendCSDJData()
-- 	        	end, 10, -1, nil, true)
-- 	        	send_time:Start()
--        		--this.m_data.is_one = true
--    		end
--     --else
--     	--self.csdj_node.gameObject:SetActive(false)
--     --end

-- end

-- function HallPanel:StopSendTime()
--     if send_time then
--         send_time:Stop()
--         send_time = nil
--     end
-- end


-- function HallPanel:SendCSDJData()
-- 	Network.SendRequest("lwzb_query_qlcf_info",{game_id = 2})
-- end

-- --local award_pool = 0
-- function HallPanel:on_lwzb_query_qlcf_info_response(_,data)
-- 	dump(data,"<color=red>on_lwzb_query_qlcf_info_response</color>")
	
-- 	if data.result == 0 then
-- 		self.award_pool = data.value 
-- 		if not self.cur_num then
-- 			self.cur_num = math.floor(self.award_pool* 0.4)
-- 		end
-- 		self:RunChange()
-- 		-- award_pool = award_pool + 100000
-- 		-- self.award_pool = award_pool
-- 	end	
-- end

-- function HallPanel:RunChange()
-- 	if self.is_animing then
-- 		return
-- 	end
-- 	self.mb_num = self.award_pool
-- 	GameComAnimTool.stop_number_change_anim(self.anim_tab)
-- 	if not self.cur_num or not self.mb_num or self.cur_num == self.mb_num then
-- 		return
-- 	end
-- 	self.is_animing = true
-- 	self.anim_tab = GameComAnimTool.play_number_change_anim(self.award_txt, self.cur_num, self.mb_num, 40, function ()
-- 		self.cur_num = self.mb_num
-- 		self.is_animing = false
-- 		self:RunChange()
-- 	end)
-- end

--------------------------------------------------------------------------------------------------------
function HallPanel:MyRefresh()
	self:UpdateAssetInfo()

	self:UpdateVerifide()
	--感恩节宝箱，出现领福利提示
	self:RefreshBagGet()
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
			if IsEquals(self.duihuan_hint_txt) then
				self.duihuan_hint_txt.text = "您有" .. StringHelper.ToRedNum(MainModel.GetHBValue()/100) .. "元可兑换"
			end
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
		self.RectCenter.transform.localPosition = Vector3.New(1560, -50, 0)
		self.RectDownL.transform.localPosition = Vector3.New(0, -94, 0)
		--self.RectDownR.transform.localPosition = Vector3.New(435, 0, 0)
		self.log_img.transform.localScale = Vector3.New(0.1,0.1,0.1)
		--self.chongzhi.transform.localScale = Vector3.New(0.1,0.1,0.1)


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
		--seq:Join(self.RectDownR.transform:DOLocalMoveX(0, tt))
		seq:Join(self.log_img.transform:DOScale(Vector3.New(1,1,1), tt))
		-- seq:Append(self.RectDownR.transform:DOScale(Vector3.New(2,2,2), 0.1))
		-- seq:Append(self.RectDownR.transform:DOScale(Vector3.New(1,1,1), 0.1))
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
end

function HallPanel:OnAddGoldClick(go)
	PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
end

function HallPanel:OnAddDiamondClick(go)
	PayPanel.Create(GOODS_TYPE.goods, "normal")
end

--种苹果->西游消消乐
function HallPanel:OnZPGClick(go)
	-- GameManager.GotoUI({gotoui="game_EliminateXY", goto_scene_parm=true, enter_scene_call=function()
	-- 	--西游消消乐测试数据
	-- 	if EliminateXYLogic.is_test then
	-- 		local data = {
	-- 			result = 0
	-- 		}
 --        	Event.Brocast("xxl_xiyou_enter_game_response","xxl_xiyou_enter_game_response",data)
	-- 		return
	-- 	end
	-- 	if not Network.SendRequest("xxl_xiyou_enter_game", nil ,"正在进入") then
	-- 		HintPanel.Create(1, "网络异常", function()
	-- 			GameManager.GotoSceneName("game_MiniGame")
	-- 		end)
	-- 	end
	-- end})
	GameManager.CommonGotoScence({gotoui="game_EliminateXY"})
end

-- 小游戏
function HallPanel:OnMiniGameClick(go)
	GameManager.GotoSceneName("game_MiniGame", {down_style={panel=self.hbc.transform}})	
end

-- 龙王争霸
function HallPanel:OnLWZBClick()
	print("龙王争霸")
	GameManager.CommonGotoScence({gotoui="game_Eliminate"})
	-- GameManager.GotoUI({gotoui="game_Eliminate", goto_scene_parm=true, enter_scene_call=function()
	-- 	if not Network.SendRequest("xxl_enter_game", nil ,"正在进入") then
 --                HintPanel.Create(1, "网络异常", function()
 --                    GameManager.GotoSceneName("game_MiniGame")
 --                end)
	-- 		end
	-- 	end})

	--if LWZBManager.GetLwzbGuideOnOff() then
	-- 
	-- else
	-- 	GameManager.GotoSceneName("game_LWZBHall", {down_style={panel=self.lwzb.transform}})		
	-- end
end

function HallPanel:OnCJJClick()
	print("冲金鸡")
	if IsEquals(self.cjj) then
		GameManager.GotoSceneName("game_Zjd", {down_style={panel=self.cjj.transform}})	
	end
end

-- 消消乐入口
function HallPanel:OnSGXXLClick()
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="sgxxl_level", is_on_hint = false}, "CheckCondition")
    if a and not b then
        return
    end
	if GameGlobalOnOff.InternalTest then
		HintPanel.Create(1, "暂未开放，敬请期待")
		return
	end

	-- GameManager.GotoUI({gotoui="game_EliminateSH", goto_scene_parm=true, enter_scene_call=function()
	-- 	if not Network.SendRequest("xxl_shuihu_enter_game", nil ,"正在进入") then
	-- 		HintPanel.Create(1, "网络异常", function()
	-- 			GameManager.GotoSceneName("game_MiniGame")
	-- 		end)
	-- 	end
	-- end})
	GameManager.CommonGotoScence({gotoui="game_EliminateSH"})
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
function HallPanel:OnStoreClick(go)
	DSM.PushAct({button = "store_btn"})
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)

	MainModel.OpenDH()
	self:UpdateDHHint()
end

--打开充值
function HallPanel:OnPayClick(go)
	DSM.PushAct({button = "pay_btn"})
	Event.Brocast("bsds_send",{key = "pay_btn_enter"})
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


function HallPanel:OnKFFKClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	MainModel.OpenKFFK()
	self.ServiceNode.gameObject:SetActive(false)
end

-- 公众号
function HallPanel:OnGZHClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel"})	self.ServiceNode.gameObject:SetActive(false)
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
	self:UpdateDHHint()
	RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_XYCJ)

	RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Activity_Year)
	RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Activity_Year_Get)
	RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Daily_Task)

	self:RefreshBagGet()
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
	self.head_pre:MyExit()

	--self:StopSendTime()
end

function HallPanel:MyClose()
    self:MyExit()
    closePanel(HallPanel.name)
end

function HallPanel:InitAnim()
end
function HallPanel:EnterAnim()
end
function HallPanel:ExitAnim()
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
    	if IsEquals(self.authentication) then
	        self.authentication.gameObject:SetActive(false)
	    end
	    return
    end
	--print("HallPanel:UpdateVerifide: " .. MainModel.UserInfo.verifyData.status)
    if MainModel.UserInfo and MainModel.UserInfo.verifyData and MainModel.UserInfo.verifyData.status then
		local status = (MainModel.UserInfo.verifyData.status == 4 or MainModel.UserInfo.verifyData.status == 2)
        if IsEquals(self.authentication) then
        	self.authentication.gameObject:SetActive(not status)
        end
    else
    	if IsEquals(self.authentication) then
        	self.authentication.gameObject:SetActive(true)
        end
	end
end
function HallPanel:ReConnecteServerSucceed()
	MainModel.GetVerifyStatus(basefunc.handler(self, self.UpdateVerifide))
end

function HallPanel:OnFuliClick()
	GameButtonManager.GotoUI({gotoui = "jyfl",goto_scene_parm = "panel"})
end

function HallPanel:on_model_vip_level_is_up_msg()
	self:ZPG_zhezhao()
end

--修改昵称成功,刷新昵称显示
function HallPanel:on_SYSChangeHeadAndNameManager_Change_Name_Success_msg()
    self.player_name_txt.text = MainModel.UserInfo.name
end

--设置头像成功,刷新头像显示
function HallPanel:on_SYSChangeHeadAndNameManager_Change_Head_Success_msg()
    --URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.player_head_img)

    self.head_pre:MyRefresh()
end

--设置头像框成功,刷新
function HallPanel:on_ByTouXiangKuangBagPanel_set_head_msg()
	self.head_pre:MyRefresh()
end

--VIP等级提升,刷新vip显示
function HallPanel:on_model_vip_upgrade_change_msg()
	self.head_pre:MyRefresh()
end

function HallPanel:on_AssetGet(data)
	if data and data.data and data.data[1] and data.data[1].asset_type then
		if string.sub(data.data[1].asset_type,1,9) == "prop_gej_" then
			self:RefreshBagGet()
		end
	end
end
--感恩节宝箱，出现领福利提示
function HallPanel:RefreshBagGet()
	if not Act_Ty_LB1Manager or not Act_Ty_LB1Manager.CheckIsShow() then return end
    if Act_Ty_LB1Manager.IsHaveItemCount() then
        self.can_get.gameObject:SetActive(true)
	else
		self.can_get.gameObject:SetActive(false)
    end
end
---创建节日环境特效
function  HallPanel:CreateHallFxPrefab()
	-- local fx_prefab = newObject("hall_fx_hj_prefab", self.FXNode.transform)
end