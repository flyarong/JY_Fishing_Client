
local basefunc = require "Game.Common.basefunc"

ActivityTaskItem = basefunc.class()

local C = ActivityTaskItem
C.name = "ActivityTaskItem"

local PROGRESS_WIDTH = 232
local PROGRESS_HEIGHT = 26

function C.Create(parent_transform, config,goto_scene_call)
	return C.New(parent_transform, config,goto_scene_call)
end

function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["AssetChange"] = basefunc.handler(self,self.OnAssetChange)
	self.lister["finish_gift_shop"] = basefunc.handler(self,self.finish_gift_shop)
	self.lister["query_activity_exchange_response"] = basefunc.handler(self,self.on_query_activity_exchange_response)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:ctor(parent, config,goto_scene_call)
	self.config = config
	self.goto_scene_call = goto_scene_call
	local obj = newObject(C.name, parent)
	self.gameObject = obj
	self.transform = obj.transform
	self.gameObject.name = config.id
	self.uilist = {}

	self:MakeLister()
	self:AddMsgListener()
	LuaHelper.GeneratingVar(self.transform, self)

	
	self.title =self.title_txt
	if self.config.gotoUI and self.config.gotoUI[1]=="shop_bay" then
	  self.title=self.title_2_txt
	end
	self.progress = self.transform:Find("progress/bar"):GetComponent("RectTransform")
	self.progress.sizeDelta = {x = 0, y = PROGRESS_HEIGHT}
	self.progress_title = self.transform:Find("progress/title"):GetComponent("Text")

	self.item_tmpl = self.transform:Find("item_tmpl")
	self.item_N_tmpl = self.transform:Find("item_N_tmpl")
	self.list_N_node = self.transform:Find("list_N_node")
	self.list_node = self.transform:Find("list_node")

	local btn_node = self.transform:Find("btn_node")
	self.remark_txt = self.transform:Find("remark_txt"):GetComponent("Text")
	self.complete_img = btn_node:Find("complete_img")
	self.complete_img.gameObject:SetActive(false)

	self.reward_btn = btn_node:Find("reward_btn"):GetComponent("Button")
	self.reward_txt = btn_node:Find("reward_btn/title"):GetComponent("Text")
	self.swreward_btn=btn_node:Find("swreward_btn"):GetComponent("Button")
	self.N_reward_btn = btn_node:Find("N_reward_btn"):GetComponent("Button")
	self.N_reward_btn.onClick:AddListener(function ()
		self:GetTaskAward()
		if self.config.N_chose_1_img and self.config.N_chose_1_text then
			local string1
			string1="恭喜您获得实物奖励\n请关注公众号《%s》联系在线客服领取"				
			HintCopyPanel.Create({desc=string1, isQQ=false})
		end
	end)
	self.reward_btn.onClick:AddListener(function()
		if self.config.shop_id then 
			self:GoBuy(self.config.shop_id)
		elseif self.config.activity_exchange then
			self:ExchangeItem(self.config.activity_exchange)
		else
			self:GetTaskAward()
		end 
	end)
	self.reward_btn.gameObject:SetActive(false)
	self.swreward_btn.onClick:AddListener(function()
				if config.isreal then
					local string1
					string1="奖品:"..config.item[1].."，请关注公众号《%s》联系在线客服领取"				
					HintCopyPanel.Create({desc=string1, isQQ=false})
				end 
	end)
	self.recharge_btn = btn_node:Find("recharge_btn"):GetComponent("Button")
	if self.config.online then
		btn_node:Find("recharge_btn"):GetComponent("Image").sprite = GetTexture("ty_btn_ywc")
		btn_node:Find("recharge_btn/title"):GetComponent("Text").text = "领   取"
		self.recharge_btn.enabled = false
	else
		btn_node:Find("recharge_btn"):GetComponent("Image").sprite = GetTexture("ty_btn_lan")
		self.recharge_btn.enabled = true
		if self.config.link then
			btn_node:Find("recharge_btn/title"):GetComponent("Text").text = "立即下载"
		else
			btn_node:Find("recharge_btn/title"):GetComponent("Text").text = "前   往"
		end
	end
	self.recharge_btn.onClick:AddListener(function()
		if not table_is_null(self.config.gotoUI)  then
			----当没有跳转场景时弹出配置tip
			if self.config.gotoUI[1]=="no_goto_ui" then
				LittleTips.Create(self.config.gotoUI[2])
				return
			end
			GameManager.CommonGotoScence({gotoui = self.config.gotoUI[1], goto_scene_parm = self.config.gotoUI[2] or true},function ()
				Event.Brocast("exit_fish_scene")
			end)
		elseif self.config.link then
			UnityEngine.Application.OpenURL(self.config.link[1])
		else
			LittleTips.Create("参数错误")
		end
	end)
	self.recharge_btn.gameObject:SetActive(false)

	self:InitUI()
end

function C:InitUI()
	self.state = 0

	local config = self.config

	self.title.text = config.task_name
	----N选1
	if config.N_chose_1_img and config.N_chose_1_text and #config.N_chose_1_img ~=1  then
		for i=1,#config.N_chose_1_img do
			local inst = GameObject.Instantiate(self.item_N_tmpl, self.list_N_node)
			inst.gameObject:SetActive(true)
			local tab_inst = LuaHelper.GeneratingVar(inst.transform)
			tab_inst.icon_img.sprite = GetTexture(config.N_chose_1_img[i])
			tab_inst.name_txt.text = config.N_chose_1_text[i]
			if i == 1 and #config.N_chose_1_img > 1 then
				local txt = ""
				local pos_x = tab_inst.BG_img.transform.localPosition.x
				local rect = tab_inst.BG_img.transform:GetComponent("RectTransform").rect
				local width = rect.width
				if #config.N_chose_1_img == 2 then
					txt = "二选一"
					pos_x = 75*(#config.N_chose_1_img - 1)
					width = 150*(#config.N_chose_1_img-1 ) + width+100
				elseif #config.N_chose_1_img == 3 then
					txt = "三选一"
					pos_x = 75*(#config.N_chose_1_img - 1)
					width = 150*(#config.N_chose_1_img ) + width
				end
				tab_inst.tag_txt.text = txt
				tab_inst.tag.gameObject:SetActive(true)
				tab_inst.BG_img.transform.localPosition = Vector3.New(tab_inst.BG_img.transform.localPosition.x + pos_x,tab_inst.BG_img.transform.localPosition.y,0)
				tab_inst.BG_img.transform:GetComponent("RectTransform").sizeDelta = Vector2.New(width,rect.height)
				tab_inst.BG_img.gameObject:SetActive(true)
				self.list_node.transform.localPosition = Vector3.New((#config.N_chose_1_img - 3) * 150+50,-40,0)
			end
		end
	end
	for i = 1, #config.item, 1 do
		local item = GameItemModel.GetItemToKey(config.item[i])
		local count = config.count[i]
		local desc
		if config.desc and config.desc[i] then
			desc = config.desc[i]
		end
		if  count then
			local inst = GameObject.Instantiate(self.item_tmpl, self.list_node)
			local icon = inst.transform:Find("icon"):GetComponent("Image")
			local uicount = inst.transform:Find("icon/count"):GetComponent("Text")
			local add_txt = inst.transform:Find("@add_txt"):GetComponent("Text")
			if config.connect_txt then
				add_txt.text = config.connect_txt
			end
			if config.N_chose_1_img and #config.N_chose_1_img > 1 then
				add_txt.gameObject:SetActive(true)
			else
				if i <= 1 then 
					add_txt.gameObject:SetActive(false)
				else
					add_txt.gameObject:SetActive(true)
				end
			end
			if item == nil then
				icon.sprite = GetTexture(config.item[i])
				if not desc or desc == "" then
					uicount.text = StringHelper.ToCash(count)
				else
					uicount.text = desc .. "*" .. StringHelper.ToCash(count)
				end
			else
				icon.sprite = GetTexture(item.image)
				if not desc or desc == "" then
					uicount.text = StringHelper.ToCash(count)
				else
					uicount.text = desc .. "*" .. StringHelper.ToCash(count)
				end
			end	

			inst.gameObject:SetActive(true)
			self.uilist[#self.uilist + 1] = inst
			if  config.hint_item and next(config.hint_item) then
				local v
				for j=1,#config.hint_item do
					v = config.hint_item[j]
					if config.item[i] == v then
						PointerEventListener.Get(inst.gameObject).onDown = function ()
							GameTipsPrefab.ShowDesc(config.hint_desc[j], UnityEngine.Input.mousePosition)
						end
						PointerEventListener.Get(inst.gameObject).onUp = function ()
							GameTipsPrefab.Hide()
						end
					end
				end
			end
			----tips------------------------------
			self.tips_btn = inst:Find("bg"):GetComponent("Button")
			if config.Tips and config.Tips[i] and config.Tips[i] ~= "" then
				self.tips_btn.onClick:AddListener(function()
					LittleTips.Create(config.Tips[i])
				end)
			else
				self.tips_btn.enabled = false
			end
		else
			print("[TASK] recharge reward config error:" .. config.id)
		end
	end
	if config.remarks then
		self.remark_txt.text = config.remarks
	end
	if config.shop_id then
		local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, config.shop_id)
		local price = gift_config.price / 100
		self.reward_txt.text = price.."元领取"
		Network.SendRequest("query_gift_bag_status",{gift_bag_id = self.config.shop_id})
	end
end

function C:MyExit()
	self:RemoveListener()
	self:ClearUIList()
	self.item_tmpl = nil
	self.list_node = nil
	self.recharge_btn = nil
	self.reward_btn = nil
	self.complete_img = nil
end

function C:OnDestroy()
	self:MyExit()
	Destroy(self.gameObject)
end

function C:ClearUIList()
	for k, v in pairs(self.uilist) do
		if IsEquals(v) then
			Destroy(v.gameObject)
		end
	end
	self.uilist = {}
end

function C:GetID()
	return self.config.id	
end

function C:SetState(state)
	self.state = state
	if state == 1 then
		if self.config.N_chose_1_img and self.config.N_chose_1_text then
			self.N_reward_btn.gameObject:SetActive(true)
			self.recharge_btn.gameObject:SetActive(false)
			self.reward_btn.gameObject:SetActive(false)
			self.complete_img.gameObject:SetActive(false)
		else
			self.N_reward_btn.gameObject:SetActive(false)
			self.recharge_btn.gameObject:SetActive(false)
			self.reward_btn.gameObject:SetActive(true)
			self.complete_img.gameObject:SetActive(false)
		end
	elseif state == 2 then
		self.N_reward_btn.gameObject:SetActive(false)
		self.recharge_btn.gameObject:SetActive(false)
		self.reward_btn.gameObject:SetActive(false)
		self.complete_img.gameObject:SetActive(true)
		if self.config.isreal then 
			self.complete_img.gameObject:SetActive(false)
			self.swreward_btn.gameObject:SetActive(true)
		else
			self.swreward_btn.gameObject:SetActive(false)
		end 
	else
		self.N_reward_btn.gameObject:SetActive(false)
		self.recharge_btn.gameObject:SetActive(true)
		self.reward_btn.gameObject:SetActive(false)
		self.complete_img.gameObject:SetActive(false)
	end
end

--0/1/2
function C:GetState()
	return self.state
end

function C:IsComplete()
	return self:GetState() == 2
end

function C:SetProgress(id,value,value2)
	local cfg_total = self.config.total
	if self.config.is_money and self.config.is_money == 1 then
		cfg_total = cfg_total / 100
	end
	if self.config.is_cz and self.config.is_cz == 1 then
		value = value / 100
	end
	local total = value2 or cfg_total or 0
	if total <= 0 then return end
	if id == 1000734 then
		value = math.floor(value / 60)
	end
	value = Mathf.Clamp(value, 0, total)
	self.progress_title.text = StringHelper.ToCash(value) .. "/" .. StringHelper.ToCash(total)
	value = value / total
	self.progress.sizeDelta = {x = value * PROGRESS_WIDTH, y = PROGRESS_HEIGHT}
end

function C:MyRefresh(data,count,show_in_one)
	local show_in_one = self.config.show_in_one or show_in_one
	local b = basefunc.decode_task_award_status(data.award_get_status)
	b = basefunc.decode_all_task_award_status(b, data, count)
	if show_in_one and show_in_one == 1 then 
		self:SetState(data.award_status)
		if data.award_status == 0 then
			self:SetProgress(data.id,data.now_process,data.need_process)
		else
			self:SetProgress(data.id,data.need_process,data.need_process)
		end
	else
		self:SetState(b[self.config.level])
		self:SetProgress(data.id,data.now_total_process)
	end
	Event.Brocast("activity_task_item_refresh_end",{item = self,task_data = data})
end

function C:MyRefresh_Shop(shop_id)
	self.progress.gameObject.transform.parent.gameObject:SetActive(false)
	
	if MainModel.GetGiftShopStatusByID(shop_id) == 1 or  MainModel.GetRemainTimeByShopID(self.config.shop_id) > 0 then 
		if self.config.N_chose_1_img and self.config.N_chose_1_text then
			self.N_reward_btn.gameObject:SetActive(true)
			self.reward_btn.gameObject:SetActive(false)
		else
			self.N_reward_btn.gameObject:SetActive(false)
			self.reward_btn.gameObject:SetActive(true)
		end
		self.recharge_btn.gameObject:SetActive(false)
		self.complete_img.gameObject:SetActive(false)
		--self.transform:SetSiblingIndex(1)
	else
		self.N_reward_btn.gameObject:SetActive(false)
		self.recharge_btn.gameObject:SetActive(false)
		self.reward_btn.gameObject:SetActive(false)
		self.complete_img.gameObject:SetActive(true)
		self.complete_img:Find("title"):GetComponent("Text").text = "领 取"
		self.transform:SetAsLastSibling()
	end
	self:RefreshNum()
end

function C:GetTaskAward()
	local show_in_one = self.config.show_in_one
	if show_in_one and show_in_one == 1 then 
		Network.SendRequest("get_task_award", {id = self.config.task})
	else
		Network.SendRequest("get_task_award_new", {id = self.config.task, award_progress_lv = self.config.level},"")
	end
	if self.config.real_img then
		if #self.config.real_img < #self.config.item then 
			MixAwardPopManager.Create({image = self.config.real_img,text = self.config.real_txt},nil,2)
		else
			RealAwardPanel.Create({image = self.config.real_img,text = self.config.real_txt})
		end 
	end 
end

function C:GoBuy(shopid)
	local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
	if gift_config then 
		if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
			GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请前往公众号获取"})
		else
			PayTypePopPrefab.Create(gift_config.id, "￥" .. (gift_config.price / 100))
		end
	else
		print("<color=red>没有此商品ID！！！</color>")
	end 
end

--刷新交换的数量
function C:RefreshNum()
	if MainModel.GetGiftShopStatusByID(self.config.shop_id) == 1 or  MainModel.GetRemainTimeByShopID(self.config.shop_id) > 0 then
		local can_buy = true
		if  self.config.cheak_item then
			for i = 1,#self.config.cheak_item do
				if GameItemModel.GetItemCount(self.config.cheak_item[i]) < self.config.cheak_num[i] then
					can_buy = false
					break
				end
			end
		end
		if	not can_buy then
			self.N_reward_btn.gameObject:SetActive(false)
			self.recharge_btn.gameObject:SetActive(true)
			self.reward_btn.gameObject:SetActive(false)
			self.complete_img.gameObject:SetActive(false)
		end
		--self.transform:SetSiblingIndex(1)
	end
end

function C:OnAssetChange()
	--self:RefreshNum() -- ActivityTaskPanel刷新了，不需要再刷新
end

function C:Refresh_Exchange()
	self.progress.gameObject.transform.parent.gameObject:SetActive(false)
	Network.SendRequest("query_activity_exchange",{type = self.config.activity_exchange[1]})
end

function C:ExchangeItem(data)
	Network.SendRequest("activity_exchange",{type = data[1],id = data[2]},"",function (data)
		self:Refresh_Exchange()
		if data and data.result == 0 then
			if self.config.real_img then
				RealAwardPanel.Create({image = self.config.real_img,text = self.config.real_txt})
			end
		end
	end)
end

-- 1，兑换所需数量充足并且剩余兑换次数充足的情况下
-- 2，兑换次数不足的情况下
-- 3，所需数量不足
function C:on_query_activity_exchange_response(_,data)
	--dump(data,"<color=red>物品交换的数据-------------</color>")
	if data and data.result == 0 then
		local can_exchange = true
		if  self.config.cheak_item then
			for i = 1,#self.config.cheak_item do
				if GameItemModel.GetItemCount(self.config.cheak_item[i]) < self.config.cheak_num[i] then
					can_exchange = false
					break
				end
			end
		end
		--		dump(self.config.activity_exchange)

		if self.config.activity_exchange and self.config.activity_exchange[1] == data.type  then
			if can_exchange and	data.exchange_day_data[self.config.activity_exchange[2]] > 0 then
				self.recharge_btn.gameObject:SetActive(false)
				self.reward_btn.gameObject:SetActive(true)
				self.complete_img.gameObject:SetActive(false)
			
			elseif not can_exchange and data.exchange_day_data[self.config.activity_exchange[2]] > 0 then
				self.recharge_btn.gameObject:SetActive(true)
				self.reward_btn.gameObject:SetActive(false)
				self.complete_img.gameObject:SetActive(false)
			else
				self.recharge_btn.gameObject:SetActive(false)
				self.reward_btn.gameObject:SetActive(false)
				self.complete_img.gameObject:SetActive(true)
				self.complete_img:Find("title"):GetComponent("Text").text = "领 取"
				self.transform:SetAsLastSibling()
			end
		end	
	end
end

function C:finish_gift_shop(id)
	if id == self.config.shop_id then
		Network.SendRequest("query_gift_bag_status",{gift_bag_id = self.config.shop_id})
	end
end