local basefunc = require "Game/Common/basefunc"

Act_030_GQFDPanel = basefunc.class()
local M = Act_030_GQFDPanel
M.name = "Act_030_GQFDPanel"
local Mgr = Act_030_GQFDManager
local instance

local pay_fd = {
	[1] = 3,
	[2] = 5,
	[3] = 7,
}   
  
 
local gift_posX = {
[10317] = 148,
[10318] = 365,
[10319] = 582,
[10320] = 799,
[10321] = 1016,
[10322] = 1233,
[10323] = 1450,
}

function M.Create(parent)
    if instance then
        instance:MyExit()
    end
    instance = M.New(parent)
	return instance
end

function M.Close()
    if instance then
        instance:MyExit()
    end
    instance = nil
end

function M:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function M:MakeLister()
	self.lister = {}
	self.lister["act_030_gqfd_refresh"] = basefunc.handler(self,self.MyRefresh)
	self.lister["AssetChange"] = basefunc.handler(self, self.MyRefresh)
end

function M:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function M:MyExit()
	self:StopTimer()
	self:KillTween()
	self:RemoveListener()
    destroy(self.gameObject)
    instance = nil
end

function M:ctor(parent)
    ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.btn_pos = {}
	self.gift_position= {}
	for i=1 ,3 do
		self.btn_pos[i] = self[i.."_tge"].transform.localPosition
		self[i.."_Label"].gameObject:SetActive(false)
	end
	--self.sv = self.ScrollView.gameOebjct:GetComponent("ScrollRect")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

end

function M:InitUI()
	self:RefreshData()
	self.fd_objs = {}
	local ui_table = {}
	for i,v in ipairs(Mgr.gift_ids) do
		self.fd_objs[v] = newObject("Act_030_gqfd_fd",self.fd_content)
		ui_table = {}
		LuaHelper.GeneratingVar(self.fd_objs[v].transform, ui_table)
		ui_table.fd_img.sprite = GetTexture("gqfd_icon_" .. i)
		if self.gift_data[v].status == 0 then
			--礼包已购买
			ui_table.name_img.sprite = GetTexture("gqfd_btn_ylq")
		else
			ui_table.name_img.sprite = GetTexture("gqfd_btn_" .. i)
		end
		ui_table.name_btn = ui_table.name_img.transform:GetComponent("Button")
		local gift_id = v
		ui_table.name_btn.onClick:AddListener(function()
			self.selected_gift = gift_id
			self:RefreshGift()
		end)
	end
	ui_table = nil
	self.selected_gift = Mgr.gift_ids[1] --选中礼包id
	for i,v in ipairs(Mgr.gift_ids or {}) do
		if self.gift_data[v] and self.gift_data[v].status == 1 then
			self.selected_gift = v
			--可以购买
			break
		end
	end
	self.selected_task = 1
	for i,v in ipairs(self.task_atas or {}) do
		if v == 1 then
			self.selected_task = i
			break
		end
	end

	for i=1,3 do
		self[i .. "_tge"].onValueChanged:AddListener(
			function(val)
				self[i .. "_Label"].gameObject:SetActive(val)
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				if val then
					self.selected_task = i
					self:RefreshTask()
				end
			end
		)
	end
	-- self.get_btn.onClick:AddListener(function(  )
	-- 	if not self.selected_task or not Mgr.task_id then return end
	-- 	Network.SendRequest("get_task_award_new", { id = Mgr.task_id, award_progress_lv = tonumber(self.selected_task) })
	-- end)

	self.pay_btn.onClick:AddListener(function(  )
		if not self.selected_gift then return end
		self:BuyShop(self.selected_gift)
	end)
	self.not_pay_btn.onClick:AddListener(function(  )
		LittleTips.Create("您今日已购买过该礼包，请于明日购买")
	end)

    self:MyRefresh()
end

function M:MyRefresh()	
	self:RefreshData()
	self:RefreshGift()
	self:RefreshTask()
	self:SortJLBox()
	self:ChoosePosUIBtn()
	self:StartTimer()
	self:RefreshImage()
	self:RefreshGiftPos()

end

function M:OnDestroy()
	self:MyExit()
end


function M:RefreshImage()
	for i,v in ipairs(Mgr.gift_ids) do
		self.ui_table = {}
		LuaHelper.GeneratingVar(self.fd_objs[v].transform, self.ui_table)
		if self.gift_data[v].status == 0 then
			--礼包已购买
			self.ui_table.name_img.sprite = GetTexture("gqfd_btn_ylq")
		else
			self.ui_table.name_img.sprite = GetTexture("gqfd_btn_" .. i)
		end
	end
end


function M:RefreshGift()
	if not self.selected_gift then return end
	local gift_cfg = self.gift_cfg[self.selected_gift]
	local gift_data = self.gift_data[self.selected_gift]
	local fd_obj = self.fd_objs[self.selected_gift]
	if not gift_cfg or not gift_data or not IsEquals(fd_obj) then
		gift_cfg = nil
		gift_data = nil
		fd_obj = nil
		return
	end

	local ui_table = {}
	for k,v in pairs(self.fd_objs or {}) do
		ui_table = {}
		LuaHelper.GeneratingVar(v.transform, ui_table)
		if k == self.selected_gift then
			--选中
			ui_table.tx_node.gameObject:SetActive(true)
			self:CurPanelShake(ui_table.fd_img.gameObject, 0.3)
			--self.fd_objs[k].gameObject.transform.localPosition = Vector3.New(gift_posX[k],-192.6,0) 
		else
			ui_table.tx_node.gameObject:SetActive(false)
		end
	end

	self.price_txt.text = gift_cfg.price / 100 .. "元购买"
	self.not_pay_btn.gameObject:SetActive(gift_data.status ~= 1)

	if self.cur_selected_gift and self.cur_selected_gift == self.selected_gift then return end
	self.cur_selected_gift = self.selected_gift
	--奖励刷新
	destroyChildren(self.jl_content)
	local item
	local img
	local obj
	local count
	for i,v in ipairs(gift_cfg.buy_asset_type) do
		ui_table = {}
		obj = newObject("Act_030_gqfd_jl",self.jl_content)
		LuaHelper.GeneratingVar(obj.transform, ui_table)
		count = gift_cfg.buy_asset_count[i]
		if v == "jing_bi" then
			if count < 180000 then
				img = "pay_icon_gold3"
			else
				img = "pay_icon_gold4"
			end
			ui_table.icon_img.sprite = GetTexture(img)
			ui_table.num_txt.text = StringHelper.ToCash(count)
		else
			item = GameItemModel.GetItemToKey(v)
			if not table_is_null(item) then
				ui_table.icon_img.sprite = GetTexture(item.image)
			end
			ui_table.num_txt.text = StringHelper.ToCash(count)
		end
	end
	for i,v in ipairs(gift_cfg.content) do
		if i == #gift_cfg.content then
			ui_table.bg_btn.onClick:AddListener(function()
				LittleTips.Create("请在苹果大战中使用")
				end
			)
		end
	end
	item = nil
	img = nil
	obj = nil
	ui_table = nil
end

function M:RefreshTask()
	if not self.selected_task then return end
	if not self.task_data then 
		self.task_data = Mgr.GetTaskData()
	end
	if not self.task_data then return end
	for i=1,3 do
		self[i .. "_tge"].isOn = i == self.selected_task
	end
	self.task_atas = Mgr.GetAllTaskAwardStatus()

	local i = self.selected_task + 7
	self.box_img.sprite = GetTexture("gqfd_icon_" .. i)
	if self.selected_task == 1 then
		self.box_txt.text = "最高200万鲸币"
		self.have_txt.text = "(<color=#fffd45>"..self.task_data.now_total_process.. "</color>/"..pay_fd[self.selected_task]..")"
	elseif self.selected_task == 2 then
		self.box_txt.text = "最高500万鲸币"
		self.have_txt.text = "(<color=#fffd45>"..self.task_data.now_total_process.. "</color>/"..pay_fd[self.selected_task]..")"
	elseif self.selected_task == 3 then
		self.box_txt.text = "最高1000万鲸币"
		self.have_txt.text = "(<color=#fffd45>"..self.task_data.now_total_process.. "</color>/"..pay_fd[self.selected_task]..")"
	end



	if not table_is_null(self.task_atas) then
		if self.task_atas[self.selected_task] == 0 then
			self.get_txt.text = "任购<color=#fffd45>" .. pay_fd[self.selected_task] .. "</color>个福袋\n获得额外奖励"
			self.get_btn.gameObject:SetActive(false)
		elseif self.task_atas[self.selected_task] == 1 then
			self.get_txt.text = ""
			self.have_txt.text = ""
			self.get_btn.gameObject:SetActive(true)
		elseif self.task_atas[self.selected_task] == 2 then
			self.get_txt.text = "明日再来"
			self.have_txt.text = ""
			self.get_btn.gameObject:SetActive(false)
		end

	end

end

function M:BuyShop(shopid)
    local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
    if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
        ServiceGzhPrefab.Create({desc="请前往公众号获取"})
    else
        PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
    end
end

function M:RefreshData()
	self.gift_data = {}
	self.gift_cfg = {}
	for i,v in ipairs(Mgr.gift_ids) do
		self.gift_cfg[v] = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag,v)
		self.gift_data[v] = MainModel.GetGiftDataByID(v)
		if not self.gift_data[v] then
			self.gift_data[v] = {
				status = 0
			}
		end
	end
	self.task_data = Mgr.GetTaskData()
	self.task_atas = Mgr.GetAllTaskAwardStatus()
end

function M:ChoosePosUIBtn()
	self.left_btn.onClick:AddListener(function ()
		self.right_btn.gameObject:SetActive(true)
		self.left_btn.gameObject:SetActive(false)
		self.fd_content.transform.position = Vector3.New(-287, 245, 0) 
	end)

	self.right_btn.onClick:AddListener(function ()
		self.left_btn.gameObject:SetActive(true)
		self.right_btn.gameObject:SetActive(false)
		self.fd_content.transform.position = Vector3.New(-773, 245, 0) 
	end)

end

function M:CurPanelShake(obj, t ,k)
	self:KillTween()
  	t = t or 1
    self.seq = DoTweenSequence.Create()
    self.seq:Append(obj.transform:DOShakePosition(t, Vector3.New(5, 5, 0), 20))
    self.seq:OnKill(function()
		   --obj.transform.localPosition = self.fd_objs[k].gameObject.transform.localPosition 
    	end)
  	self.seq:OnForceKill(function ()
		return
	end)
end

function M:KillTween()
	if self.seq then
		self.seq:Kill()
	end
	self.seq = nil
end

function M:StartTimer()
	self:StopTimer()
	self.main_time = Timer.New(function ()
		local pos = self.fd_content.transform.localPosition.x 
		if pos >= 0 then
			self.left_btn.gameObject:SetActive(false)
			self.right_btn.gameObject:SetActive(true)
		else
			self.right_btn.gameObject:SetActive(false)
			self.left_btn.gameObject:SetActive(true)
		end
	end,0.02,-1) 
	self.main_time:Start()
end

function M:StopTimer()
	if self.main_time then
		self.main_time:Stop()
		self.main_time = nil
	end
end

function M:SortJLBox()
	self.box_map = {}
	self.task_atas = Mgr.GetAllTaskAwardStatus()
	if not table_is_null(self.task_atas) then
		for i=1,3 do
			self.box_map[i] = self.task_atas[i]
		end
	end
	self.had_getmap = {}
	self.not_getmap = {}
	if not table_is_null(self.box_map) then
		for i=1,#self.box_map do
			if self.box_map[i] == 2 then
				self.had_getmap[#self.had_getmap + 1] = i
			else
				self.not_getmap[#self.not_getmap + 1] = i
			end
		end
		-- if not table_is_null(self.not_getmap)then 
		-- 	for i=1,#self.not_getmap do
		-- 		self[self.not_getmap[i].."_tge"].transform.localPosition = self.btn_pos[i]
		-- 	end
		-- end
		-- if not table_is_null(self.had_getmap)then
		-- 	for i=1,#self.had_getmap do
		-- 		if #self.not_getmap <3 then
		-- 			self[self.had_getmap[i].. "_tge"].transform.localPosition = self.btn_pos[#self.not_getmap + i]
		-- 		end
		-- 	end
		-- end
	end
	for i=1,3 do
		self[i.."_Label"].gameObject:SetActive(false)
	end
	if not table_is_null(self.not_getmap) then
		self.box_img.sprite = GetTexture("gqfd_icon_" .. self.not_getmap[1]+7)
	else
		self.box_img.sprite = GetTexture("gqfd_icon_" .. 8)
	end
	if not table_is_null(self.not_getmap) then
		if self.not_getmap[1] == 1 then
			self.box_txt.text = "最高200万鲸币"
			self.have_txt.text = "(<color=#fffd45>"..self.task_data.now_total_process.. "</color>/"..pay_fd[self.not_getmap[1]]..")"
		elseif self.not_getmap[1] == 2 then
			self.box_txt.text = "最高500万鲸币"
			self.have_txt.text = "(<color=#fffd45>"..self.task_data.now_total_process.. "</color>/"..pay_fd[self.not_getmap[1]]..")"
		elseif self.not_getmap[1] == 3 then
			self.box_txt.text = "最高1000万鲸币"
			self.have_txt.text = "(<color=#fffd45>"..self.task_data.now_total_process.. "</color>/"..pay_fd[self.not_getmap[1]]..")"
		end
	end

	if not table_is_null(self.not_getmap) then
		self.get_txt.text = "任购<color=#fffd45>" .. pay_fd[self.not_getmap[1]] .. "</color>个福袋\n获得额外奖励"
	end
	if not table_is_null(self.task_atas) then
		if self.task_atas[self.not_getmap[1]] == 0 then
			self.get_txt.text = "任购<color=#fffd45>" .. pay_fd[self.not_getmap[1]] .. "</color>个福袋\n获得额外奖励"
			self.get_btn.gameObject:SetActive(false)
		elseif self.task_atas[self.not_getmap[1]] == 1 then
			self.get_txt.text = ""
			self.have_txt.text = ""
			self.get_btn.gameObject:SetActive(true)
		elseif self.task_atas[self.not_getmap[1]] == 2 then
			self.get_txt.text = "明日再来"
			self.have_txt.text = ""
			self.get_btn.gameObject:SetActive(false)
		end
	end
	self.get_btn.onClick:AddListener(function(  )
		if not self.selected_task or not Mgr.task_id then return end
	
		if self.box_txt.text == "最高200万鲸币" then
			Network.SendRequest("get_task_award_new", { id = Mgr.task_id, award_progress_lv = 1 })
		elseif self.box_txt.text == "最高500万鲸币" then
			Network.SendRequest("get_task_award_new", { id = Mgr.task_id, award_progress_lv = 2 })
		else
			Network.SendRequest("get_task_award_new", { id = Mgr.task_id, award_progress_lv = 3 })
		end
	end)
end


function M:RefreshGiftPos()
	
	self.hadbuy_pos = {}
	self.canbuy_pos = {}
	for i,v in ipairs(Mgr.gift_ids) do
		if self.gift_data[v].status == 0 then
			--礼包已购买
			self.hadbuy_pos[#self.hadbuy_pos + 1] = v
		else
			self.canbuy_pos[#self.canbuy_pos +1 ] = v
		end
	end
	if not table_is_null(self.canbuy_pos)then 
		for i=1,#self.canbuy_pos do
			self.fd_objs[self.canbuy_pos[i]].transform:SetSiblingIndex(i-1)
		end
	end
	--self.sv:Rebuild(UnityEngine.UI.CanvasUpdate.Layout)
	UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.fd_content.transform:GetComponent("RectTransform"))
	-- if not table_is_null(self.hadbuy_pos)then
	-- 	for i=1,#self.hadbuy_pos do
	-- 		self.fd_objs[self.hadbuy_pos[i]].transform.localPosition = Vector3.New(gift_posX[#self.canbuy_pos+i],-192.6,0)   
	-- 	end
	-- end
end