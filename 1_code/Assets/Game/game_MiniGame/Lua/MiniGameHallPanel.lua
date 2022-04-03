-- 创建时间:2019-05-30
-- Panel:MiniGameHallPanel
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

MiniGameHallPanel = basefunc.class()
local C = MiniGameHallPanel
C.name = "MiniGameHallPanel"

local instance
function C.Create()
	if not instance then
		instance = C.New()
	else
		instance:MyRefresh()
	end
	return instance
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
	self.lister["AssetChange"] = basefunc.handler(self, self.UpdateAssetInfo)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:ClearCellList()
	self:RemoveListener()
	if self.game_btn_pre then
		self.game_btn_pre:MyExit()
	end
end

function C:ctor()
	ExtPanel.ExtMsg(self)
	self.dot_del_obj = true
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()
    LuaHelper.GeneratingVar(obj.transform, self)

	self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)

	self.pay_gold_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
	end)

	----优量汇插屏广告
	if SYSQXManager.IsNeedWatchAD() then
		Event.Brocast("ylh_ad_create_msg",{_type = "chaping",})
	end
	
	self.pre_config = MiniGameModel.GetUIConfig()
	dump(self.pre_config,"<color=yellow>++++++++++MiniGame++++++++</color>")
	self.pre_list = {}
	for k,v in pairs(self.pre_config) do
		if v.is_onoff == 1 then
			if v.permission then
				local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = v.permission, is_on_hint = true}, "CheckCondition")
				if a and b then
					self.pre_list[#self.pre_list + 1] = v
				end
			else
				self.pre_list[#self.pre_list + 1] = v
			end
		end
	end
    if #self.pre_list < 5 then
        for i = 1, (5 - #self.pre_list) do
            self.pre_list[#self.pre_list + 1] = self.pre_config["MiniGameWaitPrefab"]
        end
    end

	self.pre_list = MathExtend.SortList(self.pre_list, "sort", true)
	
	self:InitUI()
	dump(MainModel.lastmyLocation,"<color=yellow>上一次的场景</color>")
	if MainModel.lastmyLocation ~= "game_Hall" then 
		Event.Brocast("show_gift_panel_once_in1day")		
	end
	Event.Brocast("qflb_back_to_minihall")
end

function C:InitUI()
	-- self.pos_list = {}
	-- for i = 1, 2 do
	-- 	for j = 1, 2 do
	-- 		self.pos_list[#self.pos_list + 1] = Vector3.New(-296 + (j-1)*510, 210 - (i-1)*500, 0)
	-- 	end
	-- end
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key= "cpl_cjj", is_on_hint = true}, "CheckCondition")
  	if a and b then
  		self.TitleImage1.gameObject:SetActive(false)
  		self.TitleImage2.gameObject:SetActive(false)
  		self.TitleImage3.gameObject:SetActive(true)
	else
		self.TitleImage1.gameObject:SetActive(true)
  		self.TitleImage2.gameObject:SetActive(true)
  		self.TitleImage3.gameObject:SetActive(false)
	end
	
	self:ClearCellList()
	local index = 1
	for k,v in ipairs(self.pre_list) do
		local pre
		if v.bigpre_name then 
			pre = MiniGameHallPrefab.Create(self.CenterRectBig, v, nil, self)
		else
			pre = MiniGameHallPrefab.Create(self.Content, v, nil, self, index)
			-- pre:SetPosition(self.pos_list[index])
			index = index + 1
		end
		self.CellList[#self.CellList + 1] = pre

		-- -- 最多创建4个
		-- if index > 4 then
		-- 	break
		-- end
	end
	self:MyRefresh()
	local bt1 = GameObject.Find("MiniGameSHXXLPrefab")
	if IsEquals(bt1) then
		bt1 = bt1.transform:Find("@tag_mr")
	end
	local bt2 = GameObject.Find("MiniGameSGXXLPrefab")
	if IsEquals(bt2) then
		bt2 = bt2.transform:Find("@tag_mr")
	end
	local btn_map = {}
	if IsEquals(bt1) then
		btn_map["center"] = {bt1}
	end
	if IsEquals(bt2) then
		btn_map["center1"] = {bt2}
	end
	btn_map["top_left"] = {self.top_l_enter_node1,self.top_l_enter_node2}

	btn_map["center_top"] = {self.center_top_node_1,self.center_top_node_2}
	btn_map["top_right"] = {self.top_r_enter_node1,self.top_r_enter_node2}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "mini_game_hall")
end
function C:ClearCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:OnDestroy()
		end
	end
	self.CellList = {}
end

function C:MyRefresh()
	self:UpdateAssetInfo()
end

function C:UpdateAssetInfo()
	if IsEquals(self.gold_txt) then
		self.gold_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	end
end

--从GameFreeHallPanel:CallEnter抄过来的
local function EnterSignGame(game_id)
	local function BuyCoin(game_id, check)
		local dd = GameFreeModel.GetGameIDToConfig(game_id)
		if dd.order == 1 then
			OneYuanGift.Create(nil, function ()
			PayFastFreePanel.Create(dd, check)
			end)
		else
			PayFastFreePanel.Create(dd, check)
		end
	end

	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="freestyle_game_"..game_id}, "CheckCondition")
	if a and not b then
		return
	end
	local xsyd_signup = function ()
        	print("<color=red>匹配场新手引导 报名 》》》》》 </color>")
		GameManager.GotoSceneID( GameFreeModel.data.sceneID , true , nil , function()
		Network.SendRequest("fg_signup", {id = game_id, xsyd = 1}, "正在报名")
		end)
	end
	local signup = function()
		GameManager.GotoSceneID( game_id , true , nil , function() 
		print("<color=yellow>-------------------  CallEnter call back ---------------- </color>",game_id)
		GameFreeModel.SetCurrGameID(game_id)
		Network.SendRequest("fg_signup", {id = game_id}, "正在报名")
		end)	    
	end
	local check
	check = function ()
		local ss = GameFreeModel.IsRoomEnter(game_id)
		if ss == 1 then
			if GameGlobalOnOff.Shop_10_gift_bag ~= nil and GameGlobalOnOff.Shop_10_gift_bag == false then
				local dd = GameFreeModel.GetGameIDToConfig(game_id)
				PayFastFreePanel.Create(dd, check)
			else
				BuyCoin(game_id, check)
			end
			return
		end
		if ss == 2 then
			local pre = HintPanel.Create(2, "您太富有了，更高级的场次才适合您！", function ()
				self:UpdateKS()
				self:OnKSClick()
			end)
			pre:SetButtonText(nil, "前 往")
			return
		end
		if GuideLogic.IsFreeBattle() then
			xsyd_signup()
		else
			signup()
		end
	end
	check()
end

function C:OnBackClick()
	MainLogic.GotoScene("game_Hall")
end