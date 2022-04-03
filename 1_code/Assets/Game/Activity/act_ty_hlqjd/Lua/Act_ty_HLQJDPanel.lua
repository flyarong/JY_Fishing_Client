-- 创建时间:2020-06-16
-- Panel:Act_ty_HLQJDPanel
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

Act_ty_HLQJDPanel = basefunc.class()
local C = Act_ty_HLQJDPanel
C.name = "Act_ty_HLQJDPanel"
local M = Act_ty_HLQJDManager
local qd_anim_time = 1.2
local tx_time = {
	[1] = 1.2,
	[2] = 1.5,
	[3] = 6,
}

local instance
function C.Create(parent,backcall)
	if instance then
		if IsEquals(instance.gameObject) then
			return
		else
			instance:MyExit()
		end
	end
	instance = C.New(parent, backcall)
	return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
	self.lister["shop_info_get"] = basefunc.handler(self,self.shop_info_get)
	self.lister["AssetsGetPanelConfirmCallback"] = basefunc.handler(self,self.AssetsGetPanelConfirmCallback)
	self.lister["AssetChange"] = basefunc.handler(self,self.OnAssetChange)
	self.lister["get_task_award_new_response"] = basefunc.handler(self,self.get_task_award_new_response)

	self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_item_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	instance = nil
	self:TryToShow()
	if self.backcall then
		self.backcall()
	end
	if self.hx_anim_index then
		CommonHuxiAnim.Stop(self.hx_anim_index)
		self.hx_anim_index = nil
	end
	self:RemoveListener()
	if self.cutdown_timer then
		self.cutdown_timer:Stop()
	end
	if self.timer then
		self.timer:Stop()
	end
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:ctor(parent,backcall)
	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.backcall = backcall
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:RefreshAll()

	self:InitBtnListener()
	-- PlayerPrefs.SetString(M.key..MainModel.UserInfo.user_id.."change_day",os.date("%d",os.time()))
	-- self.timer=Timer.New(function()
	-- 	if 	self: CheckDayIsChange() then
	-- 		M.SetLevel()
	-- 		self:InitUI()
	-- 		self:RefreshAll()
	-- 	end
	-- end,2,-1)
	-- self.timer:Start()
end
local chuizi_str = {
	"铜","银","金"
}
function C:InitBtnListener()
	for i = 1,3 do
		self["lottery"..i.."_btn"].onClick:AddListener(
			function ()
			self:SetPointLock(false)
			--dump(best_index,"<color=yellow><size=15>++++++++++data++++++++++</size></color>")
			if M.GetCzNum(self.chuizi_level) > 0 then
				dump(self.chuizi_level,"<color=blue><size=15>++++++++++data++++++++++</size></color>")
					self:GetAward(i)
					self:SetTxTime()
				else
					HintPanel.Create(1,chuizi_str[self.chuizi_level].."锤数量不足！")
					self:SetPointLock(true)
				end
			end
		)
	end
	for i = 1,3 do
		self["change"..i.."_btn"].onClick:AddListener(function ()
			dump(self.chuizi_level,"<color=blue><size=15>++++++++++data++++++++++</size></color>")
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:SwitchBtn(i)
		end)
		self["yhd"..i].gameObject:SetActive(self:HasGetAward(i))
	end
	self.close_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	self.hx_anim_index = CommonHuxiAnim.Start(self.t,1,0.9,1.2)

end
function C:RefreshAll()
	self:InitShopUI()
	self:RefreshCzNum()
	if M.GetShopIDs() then
		Network.SendRequest("query_gift_bag_status_by_ids",{gift_bag_ids = M.GetShopIDs()})
	end
	
	
	self:RefreshEggs()
	self:RefreshTips()
	-- local TaskIDs = M.GetTaskIDs()
	-- for i = 1,#TaskIDs do
	-- 	Network.SendRequest("query_one_task_data", {task_id = TaskIDs[i]})
	-- end
end

function C:CheckDayIsChange()
    local cur = os.date("%d",os.time())
    local old = PlayerPrefs.GetString(M.key..MainModel.UserInfo.user_id.."change_day","-0")
    if cur ~= old then
		PlayerPrefs.SetString(M.key..MainModel.UserInfo.user_id.."change_day",os.date("%d",os.time()))
        return true
    end
    return false
end
function C:InitUI()
	M.SetLevel()
	local config=M.GetTimeData()
	if config.act_time and config.act_time~=""then
		local sta_t = self:GetFortTime(config.beginTime)
		local end_t = self:GetFortTime(config.endTime)
		self.time_txt.text=sta_t .."-".. end_t
	else
		self.cutdown_timer=CommonTimeManager.GetCutDownTimer(config.config_info[2].endTime,self.time_txt)
	end
	

	self:MyRefresh()
	self:SwitchBtn(self:GetBestIndes())
end

function C:MyRefresh()
end
--更改
function C:SwitchBtn(index)
	if self.is_lock_zd then
		return
	end
	
	self.chuizi_level = index
	for i = 1,3 do
		self["guan"..i].gameObject:SetActive(false)
		self["change"..i.."_btn"].enabled = true
		self["yhd"..i].gameObject:SetActive(self:HasGetAward(i))
	end
	self["change"..index.."_btn"].enabled = false
	self["guan"..index].gameObject:SetActive(true)
	self:RefreshLeftUI()
	self:RefreshEggs()
	self:RefreshTips()
end

local title_img = {"hlqjd_imgf_tcjl","hlqjd_imgf_ycjl","hlqjd_imgf_jcjl"}
function C:RefreshLeftUI()
	local data = M.GetBaseData()
	dump(data[self.chuizi_level])
	self.jiangli_img.sprite = GetTexture(title_img[self.chuizi_level])
	for i = 1,3 do
		dump(data[self.chuizi_level].image[i])
		self["award"..i.."_img"].sprite = GetTexture(data[self.chuizi_level].image[i])
		self["award"..i.."_txt"].text = data[self.chuizi_level].text[i]
	end
end

function C:HasGetAward(index)
	local task_id = M.GetTaskIDs()[self.chuizi_level]
	if task_id then
		local data = GameTaskModel.GetTaskDataByID(task_id)
		if data and data.other_data_str then
			local first_had = tonumber(data.other_data_str)
			local b = basefunc.decode_task_award_status(data.award_get_status)
			b = basefunc.decode_all_task_award_status2(b, data, 3)
			local sum = 0
			for i = 1,#b do
				sum = sum + (b[i] == 2 and 1 or 0)
			end
			if sum == 0 then
				return false
			elseif sum == 1 then
				if index == first_had then
					return true
				else
					return false
				end
			elseif sum == 2 then
				if index <= 2 then
					return true
				else
					return false
				end
			else
				return true
			end	
		end
	end
	return false
end

function C:RefreshCzNum()
	for i = 1,3 do
		self["c"..i.."_txt"].text = M.GetCzNum(i)
	end
end

function C:InitShopUI()
	self.shop_ui = {}

	self:ClearLiBoItems()
	self.libaochildItemTable={}
	for i = 1,#M.GetShopIDs() do
		local temp_ui = {}
		local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, M.GetShopIDs()[i])

		local b = GameObject.Instantiate(self.libaochild,self.libaonode)
		self.libaochildItemTable[#self.libaochildItemTable+1] = b
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform,temp_ui)
		temp_ui.award_1_1_img.sprite = GetTexture(M.GetShopImg()[i].icon[1])
		temp_ui.award_1_2_img.sprite = GetTexture(M.GetShopImg()[i].icon[2])
		temp_ui.award_1_1_txt.text = gift_config.buy_asset_count[1]
		temp_ui.award_1_2_txt.text = gift_config.buy_asset_count[2]
		self.shop_ui[M.GetShopIDs()[i]] = b
		self.shop_ui["buy_btn"..i] =temp_ui.buy_btn
		temp_ui.buy_btn.onClick:AddListener(
			function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				self:BuyShop(M.GetShopIDs()[i])
			end
		)
		temp_ui.btn_txt.text = (gift_config.price/100).."元领取"
		if i == 1 then -- 金锤子加光
			temp_ui.jcz_quan_01.gameObject:SetActive(true)
		end
	end
end

function C:ClearLiBoItems()
	if self.libaochildItemTable and #self.libaochildItemTable>0 then
		for index, value in ipairs(self.libaochildItemTable) do
			Destroy(value.gameObject)
		end
	end
end

function C:BuyShop(shopid)
    local gb =  MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
    if not gb then return end
	local price = gb.price
	if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		ServiceGzhPrefab.Create({desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
	end
end

function C:shop_info_get()
	for i = 1,#M.GetShopIDs() do
		if self.shop_ui[M.GetShopIDs()[i]] and IsEquals(self.shop_ui[M.GetShopIDs()[i]]) then
			local temp_ui = {}
			LuaHelper.GeneratingVar(self.shop_ui[M.GetShopIDs()[i]].transform,temp_ui)
			temp_ui.num_txt.text = MainModel.GetRemainTimeByShopID(M.GetShopIDs()[i])
			if MainModel.GetRemainTimeByShopID(M.GetShopIDs()[i]) > 0 then
				temp_ui.buy_mask.gameObject:SetActive(false)
			else	
				temp_ui.buy_mask.gameObject:SetActive(true)
			end
		end
	end
	self:RefreshUISort()
	Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
end

function C:AssetsGetPanelConfirmCallback()
	if M.GetShopIDs() then
		Network.SendRequest("query_gift_bag_status_by_ids",{gift_bag_ids = M.GetShopIDs()})
	end
	for i = 1,3 do
		self["yhd"..i].gameObject:SetActive(self:HasGetAward(i))
	end
end

function C:PlayQQLAnim(index)
	self.Animtion_Finsh = false
	local temp_ui = {}
	local b = GameObject.Instantiate(self.anim_item,self["anim_node"..index])
	b.gameObject:SetActive(true)
	b.transform.localPosition = Vector3.New(0,0,0)
	b.transform.localScale = Vector3.New(1.24,1.24,1.24)
	LuaHelper.GeneratingVar(self["egg_item"..index].transform, temp_ui)
	temp_ui["good"..index].gameObject:SetActive(false)
	temp_ui.anim_qd.gameObject:SetActive(true)
	temp_ui.animator = temp_ui.anim_qd.gameObject.transform:GetComponent("Animator")
	temp_ui.animator:Play("Dachui_Pt_H",-1,0)
	if self.PlayQQLAnim_Timer then 
		self.PlayQQLAnim_Timer:Stop()
	end 
	self.PlayQQLAnim_Timer = Timer.New(      
		function ()
			temp_ui.anim_qd.gameObject:SetActive(false)
			temp_ui["bad"..index].gameObject:SetActive(true)
			self:PlayQQLTX(index)
		end
	,qd_anim_time,1)
	self.PlayQQLAnim_Timer:Start()
end

function C:PlayQQLTX(index)
	local temp_ui = {}
	LuaHelper.GeneratingVar(self["egg_item"..index].transform, temp_ui)
	temp_ui["good"..index].gameObject:SetActive(false)
	temp_ui.anim_qd.gameObject:SetActive(false)
	temp_ui["tx_"..self.tx_level].gameObject:SetActive(true)
	if self.PlayQQLTX_Timer then 
		self.PlayQQLTX_Timer:Stop()
	end 
	self.PlayQQLTX_Timer = Timer.New(      
		function ()
			self:SetPointLock(true)
			temp_ui["tx_"..self.tx_level].gameObject:SetActive(false)
			self.Animtion_Finsh = true
			self:TryToShow()
		end
	,tx_time[self.tx_level],1)
	self.PlayQQLTX_Timer:Start()
end

function C:OnAssetChange(data)
    dump(data, "<color=red>----奖励类型-----</color>")
	if data and data.change_type == "task_p_029_hlqjd_hammer" then
		self.award_data = data
		self:PlayQQLAnim(self.curr_index)
		self:RefreshLeftUI()
	end
	self:RefreshCzNum()
end

function C:RefreshEggs()
	local data = GameTaskModel.GetTaskDataByID(M.GetTaskIDs()[self.chuizi_level])
	dump(data,"<color=red>任务</color>")
	if data == nil then return end
	local b = basefunc.decode_task_award_status(data.award_get_status)
	b = basefunc.decode_all_task_award_status2(b, data, 3)
	for i = 1,3 do
		if b[i] == 2 then
			self["bad"..i].gameObject:SetActive(true)
			self["good"..i].gameObject:SetActive(false)
		else
			self["bad"..i].gameObject:SetActive(false)
			self["good"..i].gameObject:SetActive(true)	
		end
	end
end

function C:GetAward(index)
	if self.is_lock_zd then
		return
	end
	self.is_lock_zd = false
	self.curr_index = index
	local data = {id = M.GetTaskIDs()[self.chuizi_level],award_progress_lv = index}
	dump(data,"<color=red>开始砸蛋</color>")
	Network.SendRequest("get_task_award_new", data, "")
end

function C:get_task_award_new_response(_,data)
	dump(data,"<color=red>成功砸蛋</color>")
	if data.result ~= 0 then
		HintPanel.ErrorMsg(data.result)
	else
		Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
	end
end

function C:GetBestIndes()
	local best_index = 3
	for i = 3,1,-1 do
		if M.GetCzNum(i) > 0 then
			best_index = i
			break
		end
	end
	return best_index
end

function C:TryToShow()
	if self.award_data then
		Event.Brocast("AssetGet", self.award_data)
		self.award_data = nil
		self:RefreshEggs()
		self.is_lock_zd = false
		self:RefreshTips()
		self:SwitchBtn(self:GetNoBoughtIndes())
	end
end

function C:SetTxTime()
	local data = GameTaskModel.GetTaskDataByID(M.GetTaskIDs()[self.chuizi_level])
	if data then
		local b = basefunc.decode_task_award_status(data.award_get_status)
		b = basefunc.decode_all_task_award_status2(b, data, 3)
		local had_zd = 0
		for i = 1,#b do
			if b[i] == 2 then
				had_zd = had_zd + 1
			end
		end
		if had_zd >= 2 then
			self.tx_level = 2
		else
			self.tx_level = 1
		end
	end
end

function C:on_model_task_item_change_msg(data)
	if data and data.id and M.IsExistTaskID(data.id) then
		self:RefreshEggs()
	end
end

--刷新提示横幅
function C:RefreshTips()
	local data = GameTaskModel.GetTaskDataByID(M.GetTaskIDs()[self.chuizi_level])
	--dump(data,"<color=red>任务</color>")
	if data == nil then return end
	local b = basefunc.decode_task_award_status(data.award_get_status)
	b = basefunc.decode_all_task_award_status2(b, data, 3)
	local temp_count = 0
	for i = 1,3 do
		if b[i] == 2 then
			temp_count = temp_count + 1
		else

		end
	end
	self["0bigaward1"].gameObject:SetActive(false)
	self["50bigaward1"].gameObject:SetActive(false)
	for i=1,3 do
		self["100bigaward"..i].gameObject:SetActive(false)
	end
	if temp_count == 0 then
		self["0bigaward1"].gameObject:SetActive(true)
	elseif temp_count == 1 then
		self["50bigaward1"].gameObject:SetActive(true)
	elseif temp_count == 2 then
		for i=1,3 do
			if b[i] ~= 2 then
				self["100bigaward"..i].gameObject:SetActive(true)
			end
		end
	end
end

--自动选中还没砸完的锤子档位
function C:GetNoBoughtIndes()
	local best_index = 3
	for i=3,1,-1 do
		local data = GameTaskModel.GetTaskDataByID(M.GetTaskIDs()[i])
		if data == nil then return end
		local b = basefunc.decode_task_award_status(data.award_get_status)
		b = basefunc.decode_all_task_award_status2(b, data, 3)
		for j = 1,3 do
			if b[j] ~= 2 and M.GetCzNum(i) > 0 then
				best_index = i
				--dump(best_index,"<color=yellow><size=15>++++++++++data++++++++++</size></color>")
				return best_index
			end
		end
	end
	--dump(best_index,"<color=yellow><size=15>++++++++++data++++++++++</size></color>")
	return best_index
end


--买完了的档次放到最底
function C:RefreshUISort()
	for i=1,#M.GetShopIDs() do
		if MainModel.GetRemainTimeByShopID(M.GetShopIDs()[i]) > 0 then
		else
			self.shop_ui[M.GetShopIDs()[i]].gameObject.transform:SetAsLastSibling()
		end
	end
end

--敲击限制，敲了以后不能点击其他的按钮出了 关闭按钮
function C:SetPointLock(is_lock)
	for i=1,3 do
		self["lottery"..i.."_btn"].enabled=is_lock
		self["change"..i.."_btn"].enabled=is_lock
		self.shop_ui["buy_btn"..i].enabled=is_lock
	end
end