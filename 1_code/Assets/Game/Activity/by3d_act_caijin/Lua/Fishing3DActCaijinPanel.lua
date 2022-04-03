-- 创建时间:2020-02-19
-- Panel:Fishing3DActCaijinPanel
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


Fishing3DActCaijinPanel = basefunc.class()
local C = Fishing3DActCaijinPanel
C.name = "Fishing3DActCaijinPanel"
local M = BY3DActCaijinManager

local award_round = 3
local award_tick = 0.1

local delayTimer

function C.Create()
	return C.New()

end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self, self.ExitScene)
	self.lister["model_by3d_act_caijin_all_info"] = basefunc.handler(self, self.on_all_info)
	self.lister["model_by3d_act_caijin_lottery"] = basefunc.handler(self, self.on_caijin_lottery)
	self.lister["nor_fishing_3d_panel_active_finish"] = basefunc.handler(self, self.OnAssetChange)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if delayTimer then
        delayTimer:Stop()
        delayTimer=nil
	end
	
    self:BoxExit()
	self:RemoveListener()
	destroy(self.gameObject)
end
function C:ExitScene()
	self:MyExit()
end

function C:ctor()
	print("Fishing3DActCaijinPanel init!")
	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.choose_type = 1
	self.is_wait = false
	self._curChooseAward = 0
	self.wait_award_data = nil

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	
	self.timer_count = 10
end

function C:InitUI()
	self.prog_default_rect = self.prog_bar.rect
	self.back_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnBackClick()
	end)
	self.lottery_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnLotteryBtnClick()
    end)
	self.help_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnHelpClick()
    end)
    self.guize_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnGuiZeClick()
    end)

	for i = 1, 6 do
		self[string.format("type_btn%d_tge",i)].onValueChanged:AddListener(function(val)
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:OnTypeClick(val, i)
		end)
	end

	self.bk_list = {}
    for i = 1, 8 do
    	local pre = Fishing3DActCaijinBoxPrefab.Create(self, self["box_node"..i], i)
		self.bk_list[#self.bk_list + 1] = pre
	end
	self:chooseType(1)
	
	self:enableLottery(false)
	
	self:RefreshInfo()

	self.is_wait = true
	
	M.QueryCaijinAllInfo()
end

function C:on_all_info()
	dump( "<color=red>on_all_info</color>")
	
	local data = M.GetCaijinData()

	if data.all_info_result ~= 0 then 
		self:MyExit()
		return
	end

	self.is_wait = false

	local type = self:findCurentType()
	self:chooseType(type)
		
	self:RefreshEnableLottery()
	self:RefreshInfo()
end

function C:findCurentType()
	local d = M.GetCaijinData()

	local total = #M.caijin_config.caijin_type_config[d.game_id]
	for i = total, 1, -1 do
		if d.score >= M.caijin_config.caijin_type_config[d.game_id][i].score_limit then
			return M.caijin_config.caijin_type_config[d.game_id][i].type
		end
    end

    return 1
end

function C:RefreshEnableLottery()
	-- 积分限定
	local d = M.GetCaijinData()
	--[[local data = M.caijin_config.caijin_type_config[self.choose_type]
	local enable = d.score >= data.score_limit
	if not enable then
		if self.choose_type > 1 then
			local last_data = M.caijin_config.caijin_type_config[self.choose_type - 1]
			enable = d.score >= last_data.score_limit
		else
			enable = true
		end
	else
		local next_data = M.caijin_config.caijin_type_config[self.choose_type + 1]
		enable = d.score >= next_data.score_limit
		enable = not enable
	end--]]
	local enable = true
	if self.choose_type ~= 6 then
		local next_data = M.caijin_config.caijin_type_config[d.game_id][self.choose_type + 1]
		enable = d.score >= next_data.score_limit
		enable = not enable
	end
	self:enableLottery(enable)
end

function C:chooseType(type)
	local d = M.GetCaijinData()
	if not M.caijin_config.caijin_type_config[d.game_id] or type < 1 or type > #M.caijin_config.caijin_type_config[d.game_id] then
		return
	end

	self.choose_type = type

	-- 按钮
	self[string.format("type_btn%d_tge",type)].isOn = true

	-- 刷新奖励信息
	local awards = M.caijin_config.caijin_type_config[d.game_id][type].award
	for i = 1, #self.bk_list do
		if awards[i] then
			self.bk_list[i]:setVisible(true)
			self.bk_list[i]:setName(awards[i].name)
			self.bk_list[i]:setIcon(awards[i].icon)
			self.bk_list[i]:setChoosed(false)
		else
			self.bk_list[i]:setVisible(false)
			self.bk_list[i]:setName("")
			self.bk_list[i]:setChoosed(false)
		end
	end

	self:chooseAward(0)
end

function C:chooseAward(index)
	for i = 1, #self.bk_list do
		self.bk_list[i]:setChoosed(index == i)
	end

	self._curChooseAward = index
end

function C:on_caijin_lottery()
	dump( "<color=red>on_caijin_lottery</color>")

	local data = M.GetCaijinData()

	if data.result ~= 0 then 
		self:MyExit() 
		return
	end

	self:chooseType(data.type)

	if data.award_index >= 1 and data.award_index <= #self.bk_list then

		local total_count = award_round * 8 + data.award_index - 1

		local cur_count = 0
		self:chooseAward(1)

		delayTimer = Timer.New(function()

			cur_count = cur_count + 1
			
			if cur_count <= total_count then
				self._curChooseAward = self._curChooseAward + 1
				if self._curChooseAward > 8 then
					self._curChooseAward = 1
				end
				self:chooseAward(self._curChooseAward)

			elseif cur_count >= total_count + 10 then
				-- 结束
				if delayTimer then
					delayTimer:Stop()
					delayTimer=nil
				end
		
				self.is_wait = false

				self:show_asset_change()
		
				self:chooseAward(data.award_index)

				local type = self:findCurentType()
				self:chooseType(type)
					
				self:RefreshEnableLottery()
				self:RefreshInfo()
			end
			
		end, award_tick, -1, nil, true)
	
		delayTimer:Start()
	end
end

function C:RefreshInfo()
	local d = M.GetCaijinData()
	local data = M.caijin_config.caijin_type_config[d.game_id][self.choose_type]
	local enable = d.score >= data.score_limit
	if not enable then
		if self.choose_type > 1 then
			local last_data = M.caijin_config.caijin_type_config[d.game_id][self.choose_type - 1]
			enable = d.score >= last_data.score_limit
		else
			enable = true
		end
	end
	-- 名字
	self.fish_name_txt.text = M.caijin_config.caijin_type_config[d.game_id][self.choose_type].name..":"
	
	-- 进度条
	local cfg = M.caijin_config.caijin_type_config[d.game_id][self.choose_type]
	self:SetProgress(d.score, cfg.score_limit,enable)
end

function C:SetProgress(cur, total,bool)
	if bool then
		self.percent_txt.text = string.format("%d/%d", cur, total)
	else
		self.percent_txt.text = cur
	end
	percent = cur / total

	if percent < 0 then
		percent = 0
	elseif percent > 1 then
		percent = 1
	end

	if percent > 0 and percent < 0.08 then
		percent = 0.08
	end 

	self.prog_bar.sizeDelta = {x = self.prog_default_rect.width * percent, y = self.prog_default_rect.height}
end

function C:BoxExit()
	if self.bk_list then
		for k,v in ipairs(self.bk_list) do
			v:MyExit()
		end
	end
	self.bk_list = {}
end

function C:OnBackClick()
	if self.is_wait then return end

	self:MyExit()
end

function C:OnTypeClick(val, type)
	self["type_tge_no" .. type].gameObject:SetActive(val)
	self["type_tge_yes" .. type].gameObject:SetActive(not val)
	if val then
		dump( "<color=red>OnTypeClick</color>")

		if self.is_wait then return end
		
		self:chooseType(type)
		self:RefreshEnableLottery()

		self:RefreshInfo()
	end
end

function C:enableLottery(enable)
	--self.lottery_btn.enabled = enable
	self.lottery_btn.gameObject:SetActive(enable)
end

function C:OnLotteryBtnClick()
	if self.is_wait then return end
	local d = M.GetCaijinData()
	local data = M.caijin_config.caijin_type_config[d.game_id][self.choose_type]
	if d.score < data.score_limit then
		LittleTips.Create("奖池金币不满足当前抽奖")
		return 
	end

	local nextType = 0
	local total = #M.caijin_config.caijin_type_config[d.game_id]
	for i = 1, total, 1 do
		if d.score < M.caijin_config.caijin_type_config[d.game_id][i].score_limit then
			nextType = i
			break
		end
	end
	if nextType > 0 then
		local cfg = M.caijin_config.caijin_type_config[d.game_id][nextType]
		local diff = cfg.score_limit - d.score

		HintPanel.Create(2, string.format("您距离%s仅差%d金币，您确定继续抽奖吗？",cfg.name, diff), function()
			M.RequestLottery()
			self.is_wait = true
		end, nil, nil, "温馨提示")
	else
		M.RequestLottery()
		self.is_wait = true
	end
end

function C:OnHelpClick()
    Fishing3DBKPanel.Create({type=2})
end

function C:OnAssetChange(_, data)
	dump(data, "<color=red>----奖励类型-----</color>")
	if data.type and data.type == 1000 then
		self.wait_award_data = {data = data.assets, change_type = "nor_fishing_3d_panel_active_finish_" .. data.type}
	end
end

function C:show_asset_change()
	if self.wait_award_data then
		Event.Brocast("AssetGet", self.wait_award_data)
	end

	self.wait_award_data = nil
end

local help_info = {
"1.玩家在游戏内击杀奖金鱼：黄金狮子鱼，黄金灯笼鱼，黄金海龟，黄金河豚，金蟾，大金鲨，黄金锤头鲨，会有5%的金币进入奖池，用于抽奖。",
"2.免费抽奖分为6档：普通抽奖、青铜抽奖、白银抽奖、黄金抽奖、铂金抽奖、至尊抽奖。",
"3.消耗对应档次的奖池金币进行免费抽奖，获得对应奖品。",
}

function C:OnGuiZeClick()
	local str = help_info[1]
	for i = 2, #help_info do
		str = str .. "\n" .. help_info[i]
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end