local basefunc = require "Game/Common/basefunc"

Act_ty_LDFDPanel = basefunc.class()
local M = Act_ty_LDFDPanel
M.name = "Act_ty_LDFDPanel"
local Mgr = Act_ty_LDFDManager
local instance

local pay_fd = {
	[1] = 2,
	[2] = 3,
	[3] = 5,
}
local offsetPosTable={
	[1]=12,
	[2]=-35,
	[3]=15,
	[4]=-35,
	[5]=40,
	[6]=-30,
	[7]=40,

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
	self.lister["act_ty_ldfd_refresh"] = basefunc.handler(self,self.on_act_ty_ldfd_refresh)
	self.lister["act_ty_ldfd_refresh_gift"] = basefunc.handler(self,self.on_finish_gift_shop)
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
	if not Mgr.gift_ids  then
		return
	end
	self.left_btn.onClick:AddListener(function ()
		self.right_btn.gameObject:SetActive(true)
		self.left_btn.gameObject:SetActive(false)
		self.fd_content.transform.localPosition = Vector3.New(0, 0, 0) 
	end)
	self.right_btn.onClick:AddListener(function ()
		self.left_btn.gameObject:SetActive(true)
		self.right_btn.gameObject:SetActive(false)
		self.fd_content.transform.localPosition = Vector3.New(-485, 0, 0) 
	end)
	self.get_btn.onClick:AddListener(function(  )
		if not self.selected_task or not Mgr.task_id then return end
		Network.SendRequest("get_task_award_new", { id = Mgr.task_id, award_progress_lv = tonumber(self.selected_task) })
	end)
	
	self.pay_btn.onClick:AddListener(function(  )
		if not self.selected_gift then return end
		self:BuyShop(self.selected_gift)
	end)
	self.not_pay_btn.onClick:AddListener(function(  )
		LittleTips.Create("您今日已购买过该礼包，请于明日购买")
	end)
    self.sv = self.ScrollView.transform:GetComponent("ScrollRect")

	self:StartTimer()
	local cur_conf=Mgr.GetCurTime()
	CommonTimeManager.GetCutDownTimer(cur_conf.etime,self.time_txt)
	-- local sta_t = string.sub(os.date("%m月%d日%H:%M",cur_conf.stime),1,1) ~= "0" and os.date("%m月%d日%H:%M",cur_conf.stime) or string.sub(os.date("%m月%d日%H:%M",cur_conf.stime),2)
	-- local end_t = string.sub(os.date("%m月%d日%H:%M:%S",cur_conf.etime),1,1) ~= "0" and os.date("%m月%d日%H:%M:%S",cur_conf.etime) or string.sub(os.date("%m月%d日%H:%M:%S",cur_conf.etime),2)
   	-- self.time_txt.text = "活动时间：".. sta_t .."-".. end_t

	self.gift_data = {}
	self.gift_cfg = {}
	for i,v in ipairs(Mgr.gift_ids) do
		self.gift_cfg[v] = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag,v)
		self.gift_data[v] = MainModel.GetGiftDataByID(v)
		--  dump(self.gift_data[v],"每个福袋数据：  "..v)
		if not self.gift_data[v] then
			self.gift_data[v] = {
				status = 0
			}
		end
	end
	self:RefreshSelectGiftID()

	self.fd_objs = {}
	local ui_table = {}
	for i,v in ipairs(Mgr.gift_ids) do
		-- dump(i,"福袋数据初始化： ")
		self.fd_objs[v] = Act_ty_LDFDFDItem.Create(self.fd_content,offsetPosTable[i])
		ui_table = {}
		LuaHelper.GeneratingVar(self.fd_objs[v].transform, ui_table)
		ui_table.fd_img.sprite = GetTexture("gqfd_icon_" .. (#Mgr.gift_ids - i + 1))
		ui_table.name_btn = ui_table.name_img.transform:GetComponent("Button")
		local gift_id = v
		ui_table.name_btn.onClick:AddListener(function()
			self.selected_gift = gift_id
			self:RefreshGift()
		end)
	end
	ui_table = nil

	self:RefreshShowSort()
	self.selected_task = self.show_sort_list[1].index

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
    self:MyRefresh()
end

function M:MyRefresh()
	self:RefreshGift()
	self:RefreshTask()
end
function M:on_finish_gift_shop(id)
	self.gift_data[id].status = 0
	self:RefreshSelectGiftID()
    self.fd_content.transform.localPosition = Vector3.New(0, 0, 0)
	self:RefreshGift()
end
function M:on_act_ty_ldfd_refresh(data)
	if data then
		self:RefreshShowSort()
		self.selected_task = self.show_sort_list[1].index
		self:RefreshTask()
	else
		self:RefreshTask()
	end
end

function M:RefreshSelectGiftID()
	self.selected_gift = Mgr.gift_ids[1] --选中礼包id
	for i,v in ipairs(Mgr.gift_ids or {}) do
		if self.gift_data[v] and self.gift_data[v].status == 1 then
			self.selected_gift = v
			--可以购买
			break
		end
	end
end
-- 任务显示顺序
function M:RefreshShowSort()
	self.task_atas = Mgr.GetAllTaskAwardStatus()
	if self.task_atas then
		self.show_sort_list = {}
		for i=1,3 do
			self.show_sort_list[#self.show_sort_list + 1] = {index = i, s = self.task_atas[i]}
		end
		MathExtend.SortListCom(self.show_sort_list, function (v1, v2)
			if v1.s == v2.s then
				return false
			else
				if v1.s == 1 and v2.s ~= 1 then
					return false
				elseif v1.s ~= 1 and v2.s == 1 then
					return true
				else
					if v1.s == 0 and v2.s ~= 0 then
						return false
					else
						return true
					end
				end
			end
		end)
	end
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
			self.ui_table.name_img.sprite = GetTexture("gqfd_btn_" .. (#Mgr.gift_ids - i + 1))
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
	self:RefreshImage()
	self:RefreshGiftPos()


	local ui_table = {}
	for k,v in pairs(self.fd_objs or {}) do
		ui_table = {}
		LuaHelper.GeneratingVar(v.transform, ui_table)
		if k == self.selected_gift then
			--选中
			ui_table.tx_node.gameObject:SetActive(true)
			self:CurPanelShake(ui_table.fd_img.gameObject, 0.3)
		else
			ui_table.tx_node.gameObject:SetActive(false)
		end

		if self.gift_data[k].status == 0 then
			--礼包已购买
			dump(self.gift_data, "<color=yellow>asssssssssssssssssssssssssssssssssssssssss</color>")
			ui_table.name_img.sprite = GetTexture("gqfd_btn_ylq")
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
		obj = newObject("act_ty_ldfd_jl",self.jl_content)
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
				--ui_table.icon_btn = ui_table.icon_img.transform:GetComponent("Button")
				-- local desc = item.desc
				-- ui_table.icon_btn.onClick:AddListener(function(  )
				-- 	LittleTips.Create(desc)
				-- end)
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

	self.task_data = Mgr.GetTaskData()
	self.task_atas = Mgr.GetAllTaskAwardStatus()

	self:SortJLBox()

	self[self.selected_task .. "_tge"].isOn = true
	self.task_atas = Mgr.GetAllTaskAwardStatus()

	-- dump(self.task_atas)
	-- dump(self.task_data,"福袋数据：  ")

	local i = self.selected_task + 7
	self.box_img.sprite = GetTexture("gqfd_icon_" .. i)

	if self.selected_task == 1 then
		self.box_txt.text = "最高200万金币"
		self.have_txt.text = "(<color=#fffd45>"..self.task_data.now_total_process.. "</color>/"..pay_fd[self.selected_task]..")"
	elseif self.selected_task == 2 then
		self.box_txt.text = "最高500万金币"
		self.have_txt.text = "(<color=#fffd45>"..self.task_data.now_total_process.. "</color>/"..pay_fd[self.selected_task]..")"
	elseif self.selected_task == 3 then
		self.box_txt.text = "最高1000万金币"
		self.have_txt.text = "(<color=#fffd45>"..self.task_data.now_total_process.. "</color>/"..pay_fd[self.selected_task]..")"
	end

	-------------------------------冬至福袋 气泡提示-----------------------------
	local tips_infor = {
		[1] = "买2次最高领200万", --0
		[2] = "再买1次最高领200万",
		[3] = "再买1次最高领500万",
		[4] = "再买2次最高领1000万",
		[5] = "再买1次最高领1000万",
	}

	if self.task_data.now_total_process <= 4 then
		self.tip.gameObject:SetActive(true)
		self.tips_txt.text = tips_infor[self.task_data.now_total_process + 1]
	else
		self.tip.gameObject:SetActive(false)
	end
	--------------------------------------------------------------------------------------------------------------------------------------------
	if not table_is_null(self.task_atas) then
		if self.task_atas[self.selected_task] == 0 then
			if pay_fd[self.selected_task]==2 then
				self.get_txt.text = "任购<color=#fffd45>" .. pay_fd[self.selected_task] .. "</color>个福袋\n可开启白银宝箱"
				self.get_btn.gameObject:SetActive(false)
			elseif pay_fd[self.selected_task]==3 then
				self.get_txt.text = "任购<color=#fffd45>" .. pay_fd[self.selected_task] .. "</color>个福袋\n可开启黄金宝箱"
				self.get_btn.gameObject:SetActive(false)
			elseif pay_fd[self.selected_task]==5 then
				self.get_txt.text = "任购<color=#fffd45>" .. pay_fd[self.selected_task] .. "</color>个福袋\n可开启钻石宝箱"
				self.get_btn.gameObject:SetActive(false)
			end
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
    dump(MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid))
    if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
        ServiceGzhPrefab.Create({desc="请前往公众号获取"})
    else
        PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
    end
end

function M:RefreshData()

end

function M:CurPanelShake(obj, t ,k)
	self:KillTween()
  	t = t or 1
    self.seq = DoTweenSequence.Create()
    self.seq:Append(obj.transform:DOShakePosition(t, Vector3.New(10, 10, 0), 20))
    self.seq:OnKill(function()
			-- obj.transform.localPosition = Vector3.zero
    	end)
  	self.seq:OnForceKill(function ()
		-- obj.transform.localPosition = Vector3.zero
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
	self.task_atas = Mgr.GetAllTaskAwardStatus()
	if table_is_null(self.task_atas) then return end
	self.show_sort_list = {}
	for i=1,3 do
		self.show_sort_list[#self.show_sort_list + 1] = {index = i, s = self.task_atas[i]}
		if self.selected_task == i then
			self[i.."_Label"].gameObject:SetActive(true)
		else
			self[i.."_Label"].gameObject:SetActive(false)
		end
	end

	self.box_img.sprite = GetTexture("gqfd_icon_" .. (self.selected_task+7))

	if self.selected_task == 1 then
		self.box_txt.text = "最高200万金币"
	elseif self.selected_task == 2 then
		self.box_txt.text = "最高500万金币"
	else
		self.box_txt.text = "最高1000万金币"
	end

	self.have_txt.text = "(<color=#fffd45>"..self.task_data.now_total_process.. "</color>/"..pay_fd[self.selected_task]..")"

	MathExtend.SortListCom(self.show_sort_list, function (v1, v2)
		if v1.s == v2.s then
			return false
		else
			if v1.s == 1 and v2.s ~= 1 then
				return false
			elseif v1.s ~= 1 and v2.s == 1 then
				return true
			else
				if v1.s == 0 and v2.s ~= 0 then
					return false
				else
					return true
				end
			end
		end
	end)

	for i=1,#self.show_sort_list do
		self[self.show_sort_list[i].index .. "_tge"].transform.localPosition = self.btn_pos[i]
	end

	if not table_is_null(self.task_atas) then
		local task_infor = self.task_atas[self.selected_task]
		if task_infor == 0 then
			if pay_fd[self.selected_task]==2 then
				self.get_txt.text = "任购<color=#fffd45>" .. pay_fd[self.selected_task] .. "</color>个福袋\n可开启白银宝箱"
				self.get_btn.gameObject:SetActive(false)
			elseif pay_fd[self.selected_task]==3 then
				self.get_txt.text = "任购<color=#fffd45>" .. pay_fd[self.selected_task] .. "</color>个福袋\n可开启黄金宝箱"
				self.get_btn.gameObject:SetActive(false)
			elseif pay_fd[self.selected_task]==5 then
				self.get_txt.text = "任购<color=#fffd45>" .. pay_fd[self.selected_task] .. "</color>个福袋\n可开启钻石宝箱"
				self.get_btn.gameObject:SetActive(false)
			end
			--self.tip.gameObject:SetActive(true)
			--self.tips_txt.text = "再买"..(pay_fd[self.selected_task] - self.task_data.now_total_process).."可得"..self.box_txt.text
		elseif task_infor == 1 then
			self.get_txt.text = ""
			self.have_txt.text = ""
			self.get_btn.gameObject:SetActive(true)
			--self.tip.gameObject:SetActive(false)
		elseif task_infor == 2 then
			self.get_txt.text = "明日再来"
			self.have_txt.text = ""
			self.get_btn.gameObject:SetActive(false)
			--self.tip.gameObject:SetActive(false)
		end
	end
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