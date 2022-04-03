-- 创建时间:2020-07-23
-- Panel:Fishing3DBossHallGamePanel
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

Fishing3DBossHallGamePanel = basefunc.class()
local C = Fishing3DBossHallGamePanel
C.name = "Fishing3DBossHallGamePanel"

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
    self.lister["AssetChange"] = basefunc.handler(self, self.UpdateAssetInfo)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
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
function C:GetEnterText(min, max)
	if (not min or min < 0) and (not max or max < 0) then
		return "无限制"
	elseif (not min or min < 0) and max > 0 then
		return "" .. StringHelper.ToCash(max) .. "以下"
	elseif min > 0 and (not max or max < 0) then
		return "" .. StringHelper.ToCash(min) .. "以上"
	else
		return "" .. StringHelper.ToCash(min) .. "-" .. StringHelper.ToCash(max)
	end
end

function C:InitUI()
	self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)
	self.add_yb_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnAddGold()
	end)
	self.add_jb_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnAddGold()
	end)


	self.boss_btn = {}
	self.boss_btn[#self.boss_btn + 1] = self.boss1_polygon:GetComponent("PolygonClick")
	self.boss_btn[#self.boss_btn + 1] = self.boss2_polygon:GetComponent("PolygonClick")
	self.boss_btn[#self.boss_btn + 1] = self.boss3_polygon:GetComponent("PolygonClick")

	self.config = {{game_id=6}, {game_id=7}, {game_id=8}}
	for i = 1, #self.config do
		local cfg = GameFishing3DManager.GetGameIDToConfig(self.config[i].game_id)
		self["enter" .. i .. "_txt"].text = self:GetEnterText(cfg.enter_min, cfg.enter_max)
		self.boss_btn[i].PointerClick:AddListener(function (obj)
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:OnEnterClick(i)
		end)
	end
	MainModel.SetGameBGScale(self.BG)
	self:MyRefresh()
end

function C:MyRefresh()
	self:UpdateAssetInfo()
end

function C:UpdateAssetInfo()
	if IsEquals(self.jb_txt) and  IsEquals(self.yb_txt) then
		self.jb_txt.text =  StringHelper.ToCash(MainModel.UserInfo.jing_bi)
		self.yb_txt.text = StringHelper.ToCash(MainModel.UserInfo.fish_coin)
	end
end

-- 关闭
function C:OnBackClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	GameManager.GotoSceneName("game_Hall")	
end
function C:OnEnterClick(i)
	local game_id = self.config[i].game_id
	
	local can_sign = GameFishing3DManager.CheckCanBeginGameIDByGold(game_id)
	if can_sign == 0 then
		Network.SendRequest("fsg_3d_signup", {id = game_id}, "请求报名", function (data)
			if data.result == 0 then
				GameManager.GotoSceneName("game_Fishing3D", {game_id = game_id})
			else
				HintPanel.ErrorMsg(data.result)
			end
		end)
	elseif can_sign == -1 then
		local data = {}
		data.game_id = game_id
		GameButtonManager.RunFun({ gotoui="sys_jjj"}, "CheckAndRunJJJ", function ()
			PayPanel.Create(GOODS_TYPE.jing_bi)
		end)
	else
		LittleTips.Create("你太富有了，请前往对应场")
	end
end

function C:OnAddGold()
	PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
end