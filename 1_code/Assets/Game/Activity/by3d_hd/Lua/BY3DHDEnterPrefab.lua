-- 创建时间:2020-09-22
-- Panel:BY3DHDEnterPrefab
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

BY3DHDEnterPrefab = basefunc.class()
local C = BY3DHDEnterPrefab
C.name = "BY3DHDEnterPrefab"
local M = BY3DHDManager
local EnterState = {
	hide = "hide",
	hide_ing = "hide_ing",
	show = "show",
	show_ing = "show_ing",
}

local fx_prefab = {
	[1] = {boom="3dby_hedan4_01", fly="3dby_hedan4_02"},
	[2] = {boom="3dby_hedan5_01", fly="3dby_hedan5_02"},
	[3] = {boom="3dby_hedan1_01", fly="3dby_hedan1_02"},
	[4] = {boom="3dby_hedan2_01", fly="3dby_hedan2_02"},
	[5] = {boom="3dby_hedan3_01", fly="3dby_hedan3_02"},
}

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
    self.lister["EnterForeGround"] = basefunc.handler(self, self.on_backgroundReturn_msg)
    self.lister["AssetChange"] = basefunc.handler(self, self.MyRefresh)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:KillDotween()
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
	self.hd_type_count = 5

	self.canvas_group = self.mask.transform:GetComponent("CanvasGroup")
	self.enter_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnEnterClick()
    end)

    for i = 1, self.hd_type_count do
		self["hd" .. i .. "_btn"].onClick:AddListener(function ()
	        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	        self:OnHDClick(i)
	    end)
    end
    self:SetMaskShow(false)
	self:MyRefresh()
end

function C:MyRefresh()
	for i = 1, self.hd_type_count do
		self["hd" .. i .. "_num_txt"].text = M.GetHDNumByIndex(i)
	end
end

function C:on_backgroundReturn_msg()
	self:KillDotween()
	self:SetMaskShow(false)
end

function C:OnEnterClick()
	print("OnEnterClick  ")
	if self.EnterState == EnterState.show or self.EnterState == EnterState.show_ing then
		self:hide()
	else
		self:show()
	end
end
function C:OnHDClick(index)
	print("OnHDClick  ")
	local n = GameItemModel.GetItemCount("prop_3d_fish_nuclear_bomb_give_" .. index)
	if n > 0 then
		self:UseHD("prop_3d_fish_nuclear_bomb_give_" .. index)
	else
		n = GameItemModel.GetItemCount("prop_3d_fish_nuclear_bomb_" .. index)
		if n > 0 then
			self:UseHD("prop_3d_fish_nuclear_bomb_" .. index)
		else
			local cfg = GameItemModel.GetItemToKey("prop_3d_fish_nuclear_bomb_" .. index)
			if cfg and cfg.name then
				LittleTips.Create(cfg.name.."不足")
			else
				LittleTips.Create("道具不足")
			end
		end
	end
	
	if n > 0 then
		self:KillDotween()
		self:SetMaskShow(false)
	end
end

function C:UseHD(key)
	if self.is_lock then
		return
	end
	self.is_lock = true

	local index = M.GetItemIndex(key)
	GameComAnimTool.PlayShowAndHideAndCall(self.transform, fx_prefab[index].fly, Vector3.zero, 2.5, 0.5, function ()
        Event.Brocast("ui_shake_screen_msg")
    end, nil, nil, function ()
    	local parm = {1}

	    Network.SendRequest("use_independent_item", {item = key, data = parm}, "", function (data)
	    	dump(data, "<color=red>use_independent_item  </color>")
			self.is_lock = false
   			if data.result == 0 then
   				self:ShowAward(data)
   			else
   				HintPanel.ErrorMsg(data.result)
   			end
   		end) 
    end)
end

function C:SetMaskShow(b)
	if b then
		self.EnterState = EnterState.show
		self.canvas_group.alpha = 1
		self.bg.transform.localPosition = Vector3.New(35, 0, 0)
	else
		self.EnterState = EnterState.hide
		self.canvas_group.alpha = 0
		self.bg.transform.localPosition = Vector3.New(650, 0, 0)
	end
end
function C:show()
	self.EnterState = EnterState.show_ing
	self:KillDotween()
	self.seq1 = DoTweenSequence.Create()
	self.seq1:Append(self.bg.transform:DOLocalMoveX(35, 0.3))
	self.seq1:Join(self.canvas_group:DOFade(1, 0.3))
	self.seq1:AppendCallback(function ()
		self:SetMaskShow(true)
	end)
	self.seq1:AppendInterval(3)
	self.seq1:OnKill(function ()
		self:hide()
	end)
end

function C:hide()
	self.EnterState = EnterState.hide_ing
	self:KillDotween()
	self.seq1 = DoTweenSequence.Create()
	self.seq1:Append(self.bg.transform:DOLocalMoveX(650, 0.3))
	self.seq1:Join(self.canvas_group:DOFade(0, 0.3))
	self.seq1:OnKill(function ()
		self:SetMaskShow(false)
	end)
end
function C:KillDotween()
	if self.seq1 then
		self.seq1:Kill()
		self.seq1 = nil
	end
end

function C:ShowAward(data)
	local index = M.GetItemIndex(data.item)
	local score = tonumber(data.data[1])
	GameComAnimTool.PlayShowAndHideAndCall(self.transform, fx_prefab[index].boom, Vector3.zero, 3, nil, function ()
		
	end, function (obj)
		local text = obj.transform:Find("caidai/Text"):GetComponent("Text")
		text.text = StringHelper.ToAddDH( score )
	end)
end

