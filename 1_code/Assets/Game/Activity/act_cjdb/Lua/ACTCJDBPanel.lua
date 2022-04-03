-- 创建时间:2021-05-17
-- Panel:ACTCJDBPanel
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

ACTCJDBPanel = basefunc.class()
local C = ACTCJDBPanel
C.name = "ACTCJDBPanel"
local M = ACTCJDBManager

function C.Create(parent, backcall)
	return C.New(parent, backcall)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["query_fake_data_response"] = basefunc.handler(self, self.on_query_fake_data_response)
    self.lister["cjdb_add_fake_data"] = basefunc.handler(self, self.on_add_fake_data)

    self.lister["model_super_treasure_query_base_info_msg"] = basefunc.handler(self, self.on_model_super_treasure_query_base_info_msg)
    self.lister["model_super_treasure_buy_dice_msg"] = basefunc.handler(self, self.on_model_super_treasure_buy_dice_msg)
    self.lister["model_super_treasure_use_dice_msg"] = basefunc.handler(self, self.on_model_super_treasure_use_dice_msg)
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.pmd_pre then
		self.pmd_pre:MyExit()
		self.pmd_pre = nil
	end
	
	if self.pmd_t then
		self.pmd_t:Stop()
		self.pmd_t = nil
	end
	if self.cutdown_timer then
		self.cutdown_timer:Stop()
	end

	if self.pre then
		self.pre = nil
	end

	self:RemoveListener()
	destroy(self.gameObject)
	if self.backcall then
		self.backcall()
	end
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent, backcall)
	self.backcall = backcall
	ExtPanel.ExtMsg(self)
	self.parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, self.parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.type_count = 2
	self.back_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if self.is_anim_runing then
        	LittleTips.Create("财神移动中...")
        	return
        end
		self:MyExit()
    end)
    self.rysz_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if self.is_anim_runing then
        	LittleTips.Create("财神移动中...")
        	return
        end
		self:OnRYSZClick()
    end)
    self.ysz_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if self.is_anim_runing then
        	LittleTips.Create("财神移动中...")
        	return
        end
		self:OnYSZClick()
    end)
    self.help_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if self.is_anim_runing then
        	LittleTips.Create("财神移动中...")
        	return
        end
		self:OnHelpClick()
    end)
    self.AddGold_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnAddGoldClick()
    end)

    for i = 1, self.type_count do
	    self["mybox"..i.."_btn"] = self["BoxButton"..i]:GetComponent("PolygonClick")
	    self["mybox"..i.."_btn"].PointerClick:AddListener(function()
	        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	        if self.is_anim_runing then
	        	LittleTips.Create("财神移动中...")
	        	return
	        end
			self:OnBoxClick(i)
	    end)
    	self["show_box"..i.."_btn"].onClick:AddListener(function()
	        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	        if self.is_anim_runing then
	        	LittleTips.Create("财神移动中...")
	        	return
	        end
			self:OnOpenBoxClick(i)
	    end)
    end

    self.tzsz_anim = self.sz_anim:GetComponent("Animator")
    self.player_anim = self.player_node:GetComponent("Animator")

	self.cur_type = 2
	self.move_pos = 1

	self.cutdown_timer = CommonTimeManager.GetCutDownTimer(M.GetActEndtime(), self.djs_txt)

	self.pmd_pre = CommonPMDManager.Create(self, self.CreatePMD, {actvity_mode=1, start_pos=555, end_pos=-555, time_scale=1.5})
	self.pmd_t = Timer.New(function ()
		self:QueryPMD()
	end,3,-1)

	self:RefreshAsset()
	M.QueryBaseData(self.cur_type)
end
function C:DelPathObj()
	if self.cur_path then
		for k,v in ipairs(self.cur_path) do
			v.pre:MyExit()
		end
	end
	self.cur_path = {}
end
function C:MyRefresh()
	self.base_info = M.GetBaseData(self.cur_type)
	self.config = ACTCJDBManager.GetUIConfigByTag(self.cur_type)
	self.map_config = ACTCJDBManager.GetMapConfigByGroup(self.config.group)

	self.move_pos = self.base_info.location

	self:DelPathObj()
	for i = 1, 25 do
		local data = {}
		data.pre = ACTCJDBPathPrefab.Create(self["pre_node" .. i], i, self.map_config[i])
		data.pos = data.pre:GetPos()
		self.cur_path[i] = data
	end

	for j = 1, self.type_count do
		self["show_box" .. j].gameObject:SetActive( (self.cur_type == j) )
	end

	self.player_node.localPosition = self.cur_path[self.move_pos].pos

	self.gb_key = "cjdb_" .. self.cur_type .. "_lottery"
	self.pmd_t:Start()
	self:QueryPMD()
	self.cur_path[self.base_info.location].pre:SetSelect(true)
	self.yszhf_txt.text = self.config.sz .. "金币/次"
end
function C:RefreshAsset()
	self.shop_gold_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
end
function C:on_model_super_treasure_query_base_info_msg(result)
	if result == 0 then
		self:MyRefresh()
	else
		HintPanel.ErrorMsg(result)
	end
end

function C:OnAssetChange(data)
    if data.change_type
    	and (data.change_type == "super_treasure_use_normal_dice_award" or data.change_type == "super_treasure_use_renyi_dice_award")
    	and not table_is_null(data.data) then
        self.Award_Data = data
    end

    self:RefreshAsset()
end

-- 跑马灯
function C:CreatePMD(data)
	local obj = GameObject.Instantiate(self.pmd, self.pmd_node.transform)
	local text = obj.transform:GetComponent("Text")
	text.text = "<color=#F364F8FF>恭喜【" .. data.player_name .. "】 在超级夺宝中获得 【<color=#F8F364FF>" .. data.ext_data[1] .. "</color>】奖励！</color>"
	obj.gameObject:SetActive(true)
	return obj
end
function C:QueryPMD()
	Network.SendRequest("query_fake_data", {data_type = self.gb_key})
end
function C:on_query_fake_data_response(_, data)
	if data.result == 0 and data.data_type == self.gb_key then
		self.pmd_pre:AddPMDData(data)
	end
end
function C:on_add_fake_data(data)
	self.pmd_pre:AddPMDData(data, true)	
end

function C:PlayMove()
	if self.base_info.location ~= self.move_pos then
		self.cur_path[self.base_info.location].pre:SetSelect(false)
		local index = self.base_info.location + 1
		if index > #self.cur_path then
			index = 1
		end
		local endPos = self.cur_path[index].pos

		self.player_anim:Play("run", -1, 0)
		self.move_seq = DoTweenSequence.Create()
		self.move_seq:AppendInterval(0.1)
		self.move_seq:Append(self.player_node:DOLocalMove(endPos, 0.2))
		self.move_seq:AppendInterval(0.2)
		self.move_seq:OnKill(function ()
			self.move_seq = nil
			self.base_info.location = index
			self:PlayMove()
		end)
	else
		self.move_seq = DoTweenSequence.Create()
		self.move_seq:AppendInterval(0.1)
		self.move_seq:OnKill(function ()
			self.move_seq = nil
			self:MoveFinish()
		end)
	end
end
function C:MoveFinish()
	self.is_anim_runing = false
	local data = self.cur_path[self.base_info.location]

	self.cur_path[self.base_info.location].pre:SetSelect(true)

	if self.Award_Data then
		Event.Brocast("AssetGet", self.Award_Data)
		self.Award_Data = nil
	end
end

function C:OnBoxClick(i)
	if self.cur_type ~= i and self.base_info then
		for j = 1, self.type_count do
			self["pt" .. j .. "_node"].gameObject:SetActive( not (i == j) )
			self["xz" .. j .. "_node"].gameObject:SetActive( (i == j) )
		end

		self.cur_path[self.base_info.location].pre:SetSelect(false)
		self.cur_type = i
		self.pmd_t:Stop()
		M.QueryBaseData(self.cur_type)
	end
end
function C:OnOpenBoxClick(i)
	dump(i)
	ACTCJDBBXPanel.Create(i)
end
function C:OnRYSZClick()
	if VIPManager.get_vip_level() < 2 then
		self.pre = HintPanel.Create(3,"VIP2及以上可参加~",function ()
			PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
		end)
		self.pre:SetButtonText("升级VIP")
		return
	end


	-- 是否有任意骰子可使用
	if M.GetAnyDiceUseCount(self.cur_type) > 0 then
		ACTCJDBRYSZUsePrefab.Create(self.cur_type)
		return
	end

	-- vip限制
	if M.GetAnyDiceMaxCount(self.cur_type) == 0 then	
		LittleTips.Create("金宝箱任意骰限VIP5及以上用户可购～")
		return
	end

	if M.GetAnyDiceBuyCount(self.cur_type) == 0 then
		if VIPManager.get_vip_level() < 10 then
			self.pre = HintPanel.Create(3,"您今日购买任意骰已达上限，提升VIP等级可增加购买次数~",function ()
				PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
			end)
			self.pre:SetButtonText("升级VIP")
		else
			HintPanel.Create(1, "您已达到当日购买次数上限\n请明日再来")
		end
		return
	end

	local h_money = MainModel.UserInfo.jing_bi
	local n_money = self.config.rysz + self.config.rysz_blz
	if h_money < self.config.rysz then
		LittleTips.Create("金币不足～")
	elseif h_money < n_money then
		HintPanel.Create(3,"为保障游戏体验，携带金币需达"..StringHelper.ToCash(n_money).."才能购买任意骰哦~",function ()
			PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
		end)
	else
		ACTCJDBRYSZBuyPrefab.Create(self.config)
	end
end
function C:OnYSZClick()
	if VIPManager.get_vip_level() < 2 then
		self.pre = HintPanel.Create(3,"VIP2及以上可参加~",function ()
			PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
		end)
		self.pre:SetButtonText("升级VIP")
		return
	end

	if self.config.sz <= MainModel.UserInfo.jing_bi then
		Network.SendRequest("super_treasure_use_normal_dice",{type = self.cur_type}, "")
	else
		LittleTips.Create("金币不足～")
	end
end
function C:OnHelpClick()
	ACTCJDBHelpPrefab.Create()
end

function C:on_model_super_treasure_buy_dice_msg(result)
	if result == 0 then
		ACTCJDBRYSZUsePrefab.Create(self.cur_type)
	else
        HintPanel.ErrorMsg(result)
	end
end

function C:on_model_super_treasure_use_dice_msg(data)
	self.is_anim_runing = true
	self.move_pos = self.base_info.location + data.dot
	if self.move_pos > #self.cur_path then
		self.move_pos = self.move_pos - #self.cur_path
	end

	local run = function ()
		self.tzsz_anim:SetBool("sz"..data.dot, true)
		self.tzsz_anim:Play("run", -1, 0)
		self.move_seq = DoTweenSequence.Create()
		self.move_seq:AppendInterval(1)
		self.move_seq:OnKill(function ()
			self.move_seq = nil
			self:PlayMove()
		end)
	end	
	if self.move_pos ~= data.location then
		LittleTips.Create("0点位置重置～")
		self.move_seq = DoTweenSequence.Create()
		self.move_seq:AppendInterval(0.5)
		self.move_seq:OnKill(function ()
			self.cur_path[self.base_info.location].pre:SetSelect(false)
			self.player_node.localPosition = self.cur_path[1].pos
			self.base_info.location = 1
			self.move_pos = data.location

			self.move_seq = nil
			run()
		end)
	else
		run()
	end
end

function C:OnAddGoldClick(go)
	PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
end
