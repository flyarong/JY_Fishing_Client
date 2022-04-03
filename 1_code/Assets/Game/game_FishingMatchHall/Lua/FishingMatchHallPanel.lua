-- 创建时间:2020-04-23
-- Panel:FishingMatchHallPanel
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

FishingMatchHallPanel = basefunc.class()
local C = FishingMatchHallPanel
C.name = "FishingMatchHallPanel"

local panelNameMap = {
    pms = "pms",
    qys = "qys",
    djs = "djs",
    hks = "hks",
}

function C.Create(parm)
	return C.New(parm)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["AssetChange"] = basefunc.handler(self, self.onAssetChange)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.cur_panel then
        self.cur_panel.instance:MyExit()
        self.cur_panel = nil
    end
	self:RemoveListener()
end

function C:ctor(parm)
	self.parm = parm
	local parent = GameObject.Find("Canvas/GUIRoot").transform
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
	self.back_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnBackClick()
    end)
    self.shop_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnAddGoldClick()
    end)

    self.help_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnHelpClick()
    end)
    self.history_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnRankClick()
    end)
    self.yesterday_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnYesterdayRankClick()
    end)
    MainModel.SetGameBGScale(self.BG)
	self:MyRefresh()
end

function C:MyRefresh()
	self.player_name_txt.text = MainModel.UserInfo.name
	self:RefreshLeft()
	self.select_index = self.parm and self.parm.index or 1
	self:OpenRight()
	self:onAssetChange()
end
function C:onAssetChange()
	self.ticker_num_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	--VIPManager.set_vip_text(self.head_vip_txt)
end

function C:OpenRight()
	self.LeftCellList[self.select_index]:SetSelect(true)
	self:RefreshRight()	
end

function C:RefreshLeft()
	self:ClearLeftCellList()
	self.hall_cfg = FishingManager.GetMatchHallConfigAndSort()
	for k,v in ipairs(self.hall_cfg) do
		local pre = FishingMatchHallTagPrefab.Create(self.ContentLeft, v, self.OnLeftClick, self, k)
		self.LeftCellList[#self.LeftCellList + 1] = pre
	end
end
function C:ClearLeftCellList()
	if self.LeftCellList then
		for k,v in ipairs(self.LeftCellList) do
			v:MyExit()
		end
	end
	self.LeftCellList = {}
end
function C:OnLeftClick(index)
	dump(index)
	if self.select_index and self.select_index == index then
		return
	end
	if self.select_index then
		self.LeftCellList[self.select_index]:SetSelect(false)
	end
	self.select_index = index
	self:OpenRight()
end

function C:RefreshRight()
	local cfg = self.hall_cfg[self.select_index]
	self:ChangePanel(cfg.game_key)
end
function C:ChangePanel(panelName)
    if self.cur_panel then
        if self.cur_panel.name == panelName then
            if  self.cur_panel.instance.MyRefresh then
                self.cur_panel.instance:MyRefresh()
            end 
        else
            self.cur_panel.instance:MyExit()
            self.cur_panel = nil
        end
    end
    if not self.cur_panel then
        if panelName == panelNameMap.pms then
            self.cur_panel = {name = panelName, instance = FishingMatchHallPMSPanel.Create(self.RightNode)}
        elseif panelName == panelNameMap.qys then
            self.cur_panel = {name = panelName, instance = FishingMatchHallQYSPanel.Create(self.RightNode)}
        elseif panelName == panelNameMap.djs then
            self.cur_panel = {name = panelName, instance = FishingMatchHallDJSPanel.Create(self.RightNode)}
        elseif panelName == panelNameMap.hks then
            self.cur_panel = {name = panelName, instance = FishingMatchHallHKSPanel.Create(self.RightNode)}
        else
            dump(panelName, "<color=red>没有这个Panel</color>")
        end
        self:RefreshRightTop()
    end
end
function C:RefreshRightTop()
	self.help_btn.gameObject:SetActive(false)
	self.history_btn.gameObject:SetActive(false)
	self.yesterday_btn.gameObject:SetActive(false)
	if self.cur_panel and self.cur_panel.name == panelNameMap.pms then
    	self.help_btn.gameObject:SetActive(true)
    	self.history_btn.gameObject:SetActive(true)
    	self.yesterday_btn.gameObject:SetActive(true)
    end
end
function C:OnBackClick()
	self:MyExit()
	if MainModel.lastmyLocation and MainModel.lastmyLocation == "game_Fishing3DHall" then
		GameManager.GotoSceneName("game_Fishing3DHall")
	else
		GameManager.GotoSceneName("game_Hall")
	end
end

function C:OnAddGoldClick()
	PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
end

function C:OnHelpClick()
	print("OnHelpClick")
	if self.cur_panel and self.cur_panel.name == panelNameMap.pms then
		SYSByPmsGameRulesPanel.Create("pms")
	end
end

function C:OnRankClick()
	print("OnRankClick")
	if self.cur_panel and self.cur_panel.name == panelNameMap.pms then
		SYSByPmsHallRankPanel.Create("pms",1)
	end
end

function C:OnYesterdayRankClick()
	print("OnYesterdayRankClick")
	if self.cur_panel and self.cur_panel.name == panelNameMap.pms then
		SYSByPmsHallYesterdayRankPanel.Create(1)
	end
end