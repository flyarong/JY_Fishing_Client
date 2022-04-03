-- 创建时间:2020-07-27
-- Panel:FishFarmEggPrefab
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

FishFarmEggPrefab = basefunc.class()
local C = FishFarmEggPrefab
C.name = "FishFarmEggPrefab"

function C.Create(parent_transform, index, call, panelSelf)
	return C.New(parent_transform, index, call, panelSelf)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:StopDJS()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent_transform, index, call, panelSelf)
	self.index = index
	self.call = call
	self.panelSelf = panelSelf
	local obj = newObject(C.name, parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.egg_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		if self.call then
			self.call(self.panelSelf, self.index)
		end
	end)
	self.goto_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		local pre = HintPanel.Create(2, "在龙王宝藏任意场次中捕获任意鱼，就有几率获得鱼蛋！是否前往龙王宝藏？", function ()
			GameManager.GotoSceneName("game_Fishing3DHall")
		end)
		pre:SetButtonText(nil, "前 往")
	end)

	self.egg_img = self.egg_btn.transform:GetComponent("Image")
	self:MyRefresh()
end

function C:MyRefresh()
	local data = FishFarmModel.GetEggDataByIndex(self.index)
	if data and data.type ~= 0 then
		local cfg = FishFarmModel.GetEggConfig(data.type)
		self.egg_yes.gameObject:SetActive(true)
		self.egg_no.gameObject:SetActive(false)
		self.egg_img.sprite = GetTexture(cfg.icon)
		if tonumber(data.time) > os.time() then
			self.down_val = tonumber(data.time) - os.time()
			self.time.gameObject:SetActive(true)
			self.hint.gameObject:SetActive(false)
			self:RunDJS()
		else
			self.time.gameObject:SetActive(false)
			self.hint.gameObject:SetActive(true)
		end
	else
		self:StopDJS()
		self.egg_yes.gameObject:SetActive(false)
		self.egg_no.gameObject:SetActive(true)
	end
end

function C:RunDJS()
	self:StopDJS()

	self.update_time = Timer.New(function ()
    	self:UpdateTime()
    end, 1, -1, nil, true)
    self:UpdateTime(true)
    self.update_time:Start()
end
function C:StopDJS()
	if self.update_time then
		self.update_time:Stop()
	end
	self.update_time = nil
end
function C:UpdateTime(b)
	if not b then
		if self.down_val then
			self.down_val = self.down_val - 1
		end
	end
	if not self.down_val or self.down_val <= 0 then
		self.egg_time_txt.text = "00:00:00"
		self:MyRefresh()
	else
		local hh = math.floor(self.down_val / 3600)
		local ff = math.floor((self.down_val % 3600) / 60)
		local mm = self.down_val % 60
		self.egg_time_txt.text = string.format("%02d:%02d:%02d", hh, ff, mm)
	end
end