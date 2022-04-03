-- 创建时间:2019-03-18
-- Panel:Fishing3DHallGamePanel
local basefunc = require "Game/Common/basefunc"

Fishing3DHallGamePanel = basefunc.class()
local C = Fishing3DHallGamePanel
C.name = "Fishing3DHallGamePanel"

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
    self.lister["PayPanelClosed"]=basefunc.handler(self,self.OnClosePayPanel)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	DSM.PopAct()
	self:StopSignTimer()
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
	self.config = GameFishing3DManager.GetHallCfg()
	self.parm = parm
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	self:AddMsgListener()

	self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)
	self.set_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		SettingPanel.Create()
	end)
	self.add_jb_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnAddGold()
	end)
	self.wiki_btn.onClick:AddListener(function ()
		self:OnWikiClick()
	end)

	self:InitUI()
    GuideLogic.CheckRunGuide("by3d_hall")
end
function C:InitUI()
	self.jb_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	self.yb_txt.text = StringHelper.ToCash(MainModel.UserInfo.fish_coin or 0)
	local hall_cfg = GameFishing3DManager.GetHallCfg()
	local hall_map = {}
	for k,v in ipairs(hall_cfg) do
		hall_map[v.game_id] = v
	end
	
	local btn_map = {}
	btn_map["top"] = {self.top_enter_node1}
	btn_map["top_right"] = {self.top_r_enter_node1,self.top_r_enter_node2,self.top_r_enter_node3}

	self.map_db:GetComponent("RectTransform").sizeDelta = {x = Fishing3DHallModel.UIConfig.map.width, y = Fishing3DHallModel.UIConfig.map.height}
	self:CloseCell()
	self.hall_list = Fishing3DHallModel.GetHallList()
	for k,v in ipairs(self.hall_list) do
		local pre
		if v.game_id == 1 then
			pre = Fishing3DHallTYCEnterPrefab.Create(self.cell_node, v, self)
		else
			pre = Fishing3DHallEnterPrefab.Create(self.cell_node, v, self)
		end
		self.CellList[#self.CellList + 1] = pre
		btn_map["center"..v.game_id] = {pre.act_node1,pre.act_node2}
	end

	local zs = Fishing3DHallModel.GetHallZSList()
	for k,v in ipairs(zs) do
		local obj = GameObject.Instantiate(GetPrefab(v.prefab), self.cell_node)
		obj.transform.localPosition = v.pos
	end
	self.tyc_btn.gameObject:SetActive(false)
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "fishing3d_hall")

	self.tyc_btn.onClick:AddListener(function ()
		GameManager.GotoSceneName("game_FishingMatchHall")
	end)

	self.tyc_enter_txt.text = "万元奖金"
	self:MyRefresh()
	self:RefreshCondition()
	self.sign_time_config = SYSByPmsManager.GetSignTimeConfig()
	self:StartSignTimer(true)
end

function C:MyRefresh()
	self.cur_game_id = GameFishing3DManager.GetTJGameID()
	self:RefreshSelect()
	if self.cur_game_id == 1 then
		self.tyc_kuang_glow.gameObject:SetActive(true)
	else
		self.tyc_kuang_glow.gameObject:SetActive(false)
		local cfg = Fishing3DHallModel.GetConfigByGameID(self.cur_game_id)
		if cfg then
		    self.Content.transform.localPosition = Vector3.New(cfg.zs_pos_x, -154, 0)
		end
	end
end
function C:CloseCell()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:OnDestroy()
		end
	end
	self.CellList = {}
end
function C:OnGDClick(game_id)
	Fishing3DHallHelpPanel.Create(game_id)
end

function C:UpdateAssetInfo()
	if IsEquals(self.jb_txt) and  IsEquals(self.yb_txt) then
		self.jb_txt.text =  StringHelper.ToCash(MainModel.UserInfo.jing_bi)
		self.yb_txt.text = StringHelper.ToCash(MainModel.UserInfo.fish_coin)
	end
end

function C:RefreshSelect()
	for k,v in ipairs(self.CellList) do
		v:RefreshSelect(self.cur_game_id)
	end
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

function C:OnWikiClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    Fishing3DBKPanel.Create()
end

function C:OnItemBtnClick(index)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local game_id = self.config[index].game_id

	-- 对于上锁的场 还是要先判断钱
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="fishing3d_"..game_id, is_on_hint=true}, "CheckCondition")
	if a and not b then
		local can_sign = GameFishing3DManager.CheckCanBeginGameIDByGold(game_id)
		if can_sign == -1 then
			local cfg = GameFishing3DManager.GetGameIDToConfig(game_id)
			local pre = HintPanel.Create(2, "该场次需要携带" .. StringHelper.ToCash(cfg.enter_min) .. "以上金币才可进入，是否前往购买金币？", function ()
				PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
			end)
			pre:SetButtonText(nil, "充 值")
		else
			GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="fishing3d_"..game_id}, "CheckCondition")
		end
    	return
	end

    --[[if game_id == 1 then
		self:CheckSign(game_id, function ()
			self:SendSign(game_id)
		end)
    else--]]
	    if self.cur_game_id == game_id then
	    	self:CheckSign(game_id, function ()
	    		self:SendSign(game_id)
	    	end)
	    else
	    	self.cur_game_id = game_id
	    	self:RefreshSelect()
	    end
    --end
end

function C:SendSign(g_id)
	Network.SendRequest("fsg_3d_signup", {id = g_id}, "请求报名", function (data)
		if data.result == 0 then
			GameManager.GotoSceneName("game_Fishing3D", {game_id = g_id})
		else
			HintPanel.ErrorMsg(data.result)
		end
	end)
end

function C:CheckSign(game_id, call)
	local can_sign = GameFishing3DManager.CheckCanBeginGameIDByGold(game_id)
	if can_sign == 0 then
		if call then
			call()
		end
	elseif can_sign == -1 then
		local data = {}
		data.game_id = game_id
		GameButtonManager.RunFun({ gotoui="sys_jjj"}, "CheckAndRunJJJ", function ()
			PayPanel.Create(GOODS_TYPE.jing_bi)
		end)
	elseif can_sign == 1 then
		LittleTips.Create("你太富有了，请前往对应场")
	else
		local cfg = GameFishing3DManager.GetGameIDToConfig(game_id)
		LittleTips.Create(cfg.lvevl .. "等级开启,可以通过开炮提升等级!")
	end
end


function C:OnClosePayPanel()
	self:Refresh()
	self:RefreshSelect()
	self:RefreshCondition()
end

function C:Refresh()
	for k,v in ipairs(self.CellList) do
		v:MyRefresh(self.cur_game_id)
	end
end

function C:RefreshCondition()
	for k,v in pairs(self.CellList) do
		if not v:GetQX() then
			v:SetCondition()
			return
		end
	end
end

function C:StartSignTimer(b)
	self:StopSignTimer()
	if b then
		self:RefreshBtn()
		self.signTimer = Timer.New(function ()
			self:RefreshBtn()
		end,1,-1)
		self.signTimer:Start()
	end
end

function C:StopSignTimer()
	if self.signTimer then
		self.signTimer:Stop()
		self.signTimer = nil
	end
end

function C:RefreshBtn()
	local h = os.date("%H", os.time())
	local f = os.date("%M", os.time())
	local m = os.date("%S", os.time())
	local cur_all = h*3600 + f*60 + m
	if cur_all >= self.sign_time_config[#self.sign_time_config].timestamp_max and cur_all <= 86400 then--明日开赛
		self.tyc_kuang_glow.gameObject:SetActive(false)
		return
	end
	for i=1,#self.sign_time_config do
		if self.sign_time_config[i].timestamp_min >= cur_all then--倒计时
			self.tyc_kuang_glow.gameObject:SetActive(false)
			return
		elseif self.sign_time_config[i].timestamp_min < cur_all and self.sign_time_config[i].timestamp_max > cur_all then--立刻参赛
			self.tyc_kuang_glow.gameObject:SetActive(true)
			return
		end
	end
end