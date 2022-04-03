-- 创建时间:2021-01-19
-- Panel:Act_Ty_UNIVERSAL_DHPanel
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

Act_Ty_UNIVERSAL_DHPanel = basefunc.class()
local C = Act_Ty_UNIVERSAL_DHPanel
C.name = "Act_Ty_UNIVERSAL_DHPanel"
local M = Act_Ty_UNIVERSAL_DHManager

function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["model_universal_data_change_msg"] = basefunc.handler(self,self.MyRefresh)
    self.lister["universal_activity_all_exchange_msg"] = basefunc.handler(self,self.MyRefresh)
    self.lister["universal_box_exchange_msg"] = basefunc.handler(self,self.MyRefresh)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:CloseItemPrefab()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.duihuan_btn.gameObject).onClick = basefunc.handler(self, self.OnDuiHuanClick)
	EventTriggerListener.Get(self.help_btn.gameObject).onClick = basefunc.handler(self, self.OnHelpClick)
	EventTriggerListener.Get(self.fudai_btn.gameObject).onClick = basefunc.handler(self, self.OnFudaiClick)
	M.QueryGiftData()
end

function C:MyRefresh()
	self.cur_data = M.GetCurData()
	if self.cur_data then
		SetTextureExtend(self.bg_img,M.GetCurBG())
		local sta_t = M.GetStart_t()
		local end_t = M.GetEnd_t()
		self.top_txt.text = "活动时间：".. sta_t .."-".. end_t
		self.btm_tip_txt.text = M.GetBtmTip()
		self:RefreshFuDai()
		self:RefreshButton()
		self:CreateItemPrefab()
		self:CreateItemKeyPrefab()
	end
end

--一鍵兑换
function C:OnDuiHuanClick()
	HintPanel.Create(2, "一键兑换功能会根据道具组合从多到少自动匹配兑换，是否确认兑换？",function ()
		Network.SendRequest("activity_all_exchange",{type = M.type})
	end)
end

function C:OnHelpClick()
	local str
	local help_info = M.GetCurHelpInfor()
	str = help_info[1]
	for i = 2, #help_info do
		str = str .. "\n" .. help_info[i]
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform, "IllustratePanel_New")
end

function C:CreateItemPrefab()
	--获取当前 最低能换的道具 ---->放在第一个位置
	local temp
	for i=#self.cur_data,1,-1 do
		if M.CheckItemIsEnough(self.cur_data[i].ID) and self.cur_data[i].remain_time ~= 0 then
			local count = 0
			for k,v in pairs(self.cur_data[i].cost_item_num) do
				count = count + v
			end
			if not temp or temp > count then
				temp = count
				self.line = self.cur_data[i].line
			end
		end
	end
	local m_sort = function(v1,v2)
		if v1.line == self.line and v2.line ~= self.line and self.line then
			return false
		elseif v1.line ~= self.line and v2.line == self.line and self.line then
			return true
		else
			if v1.remain_time == 0 and  (v2.remain_time > 0 or v2.remain_time == -1) then--前无次数后有次数
				return true
			elseif v1.remain_time == 0 and v2.remain_time == 0 then--都没次数
				if v1.line < v2.line then
					return false
				else
					return true
				end
			elseif (v1.remain_time > 0 or v1.remain_time == -1) and v2.remain_time == 0 then--前有次数后无次数
				return false
			else--都有次数	
				if v1.line < v2.line then
					return false
				elseif v1.line > v2.line then
					return true
				end
			end
		end
	end

	MathExtend.SortListCom(self.cur_data, m_sort)
	self:CloseItemPrefab()
	dump(self.cur_data)
	for i=1,#self.cur_data do
		local pre = Act_Ty_UNIVERSAL_DHItemBase.Create(self.Content.transform,self.cur_data[i])
		if pre then
			self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
		end
	end

	self.line = nil
end

function C:CloseItemPrefab()
	if self.spawn_cell_list then
		for k,v in ipairs(self.spawn_cell_list) do
			v:MyExit()
		end
	end
	self.spawn_cell_list = {}
end

function C:CreateItemKeyPrefab()
	self:CloseItemKeyPrefab()
	local tips_tab = M.GetItemTips()
	local keys_tab = M.GetItemKeys()
	local universal_key = M.GetUniversalKey()
	keys_tab[#keys_tab + 1] = universal_key
	for i=1,#keys_tab do
		local pre = GameObject.Instantiate(self.item, self.item_node.transform)
		pre.gameObject:SetActive(true)
		local item_img = pre.transform:Find("item_img").transform:GetComponent("Image")
		local item_txt = pre.transform:Find("item_txt").transform:GetComponent("Text")
		item_img.sprite = GetTexture(M.GetCurPath() .. GameItemModel.GetItemToKey(keys_tab[i]).image)
		item_txt.text = GameItemModel.GetItemCount(keys_tab[i])
		if tips_tab[i] ~= "" then
			local tip_btn = pre.transform:Find("tip_btn")
			tip_btn.gameObject:SetActive(true)
			pre.transform:Find("tip_btn/tip/tip_txt").transform:GetComponent("Text").text = tips_tab[i]
			EventTriggerListener.Get(tip_btn.gameObject).onDown = function ()
				pre.transform:Find("tip_btn/tip").gameObject:SetActive(true)
			end
			EventTriggerListener.Get(tip_btn.gameObject).onUp = function ()
				pre.transform:Find("tip_btn/tip").gameObject:SetActive(false)
			end
		end
		self.item_key_list[#self.item_key_list + 1] = pre
	end
end

function C:CloseItemKeyPrefab()
	if self.item_key_list then
		for k,v in pairs(self.item_key_list) do
			destroy(v.gameObject)
		end
	end
	self.item_key_list = {}
end

function C:RefreshButton()
	self.duihuan_btn.gameObject:SetActive(M.CheckIsCanExchangeByOneKey())
	self.duihuan_mask.gameObject:SetActive(not M.CheckIsCanExchangeByOneKey())
end

function C:OnFudaiClick()
	local fudaikeys = M.GetFuDaiExchangeKeys()
	local fudaiids = M.GetFuDaiExchangeIds()
	local num = 0
	for i=1,#fudaikeys do
		num = num + GameItemModel.GetItemCount(fudaikeys[i])
	end
	if num > 0 then
		for i=1,#fudaikeys do
			if GameItemModel.GetItemCount(fudaikeys[i]) > 0 then
				Network.SendRequest("box_exchange_new",{id = fudaiids[i],num = GameItemModel.GetItemCount(fudaikeys[i]),is_merge_asset = 1 })
			end
		end
	else
		local fudaikeys = M.GetFuDaiExchangeKeys()
		local name = GameItemModel.GetItemToKey(fudaikeys[1]).name
		LittleTips.Create("您的"..name.."不足")
	end
end

function C:RefreshFuDai()
	local fudaikeys = M.GetFuDaiExchangeKeys()
	local num = 0
	for i=1,#fudaikeys do
		num = num + GameItemModel.GetItemCount(fudaikeys[i])
	end
	self.fudai_txt.text = "x"..num
	self.fudai_img.sprite = GetTexture(GameItemModel.GetItemToKey(fudaikeys[1]).image)
end