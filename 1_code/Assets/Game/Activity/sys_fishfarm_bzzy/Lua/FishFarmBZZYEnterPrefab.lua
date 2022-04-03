-- 创建时间:2020-11-22
-- Panel:FishFarmBZZYEnterPrefab
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

FishFarmBZZYEnterPrefab = basefunc.class()
local C = FishFarmBZZYEnterPrefab
C.name = "FishFarmBZZYEnterPrefab"

local M = FishFarmBZZYManager

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
    self.lister["EnterForeGround"] = basefunc.handler(self, self.on_backgroundReturn_msg)
    self.lister["EnterBackGround"] = basefunc.handler(self, self.on_background_msg)
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()

	if self.fd_objs then
		self.fd_objs = nil 
	end

	self:StopTimer()
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
	local parent =  GameObject.Find("FishFarmUI/FishNodeTran").transform
	local obj = newObject("Fish3D031", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	-- LuaHelper.GeneratingVar(self.transform, self)
	self.transform.localRotation = Quaternion.Euler(45, 0, 90)
	self.zz = 300

	self.transform.localScale = Vector3.New(0.7, 0.7, 0.7)

	if IsEquals(self.gameObject) then
		GameObject.Find("Fish3D031/fish3d/fish_131/model/cjb/cjb").transform:GetComponent("SkinnedMeshRenderer").material.shader = UnityEngine.Shader.Find("fish3d_opt_no_shadow")
  	end

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	-- self.enter_btn.onClick:AddListener(
	-- 	function ()
	-- 		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	-- 		FishFarmBZZYPanel.Create()
	-- 	end
	-- )


end
--self.ui_transform.position = FishFarmModel.Get2DToUIPoint(self.transform.position)
function C:InitUI()
	local b = {}
	self.fd_objs = newObject(C.name,GameObject.Find("Canvas/GUIRoot/FishFarmGamePanel/@fishui_node").transform)
	LuaHelper.GeneratingVar(self.fd_objs.transform, b)
	b.enter_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		FishFarmBZZYPanel.Create()
	end)

	self:MyRefresh()
	self:StartTimer()
end

function C:StartTimer()
	self:StopTimer()
	self.main_time = Timer.New(function ()
		if not M.IsCanCreatEnter() then
			self:MyExit()
		-- else
		-- 	if IsEquals(self.gameObject) then
		-- 		self.enter_btn.transform.localPosition = Vector3.New(math.random(-810,550), math.random(-230,260), 0)
		-- 	end
		end
	end,1,-1) 
	self.update_time = Timer.New(function()
        self:FrameUpdate()
    end, 0.033, -1, nil, true)
	self.main_time:Start()
	self.update_time:Start()
end

function C:StopTimer()
	if self.main_time then
		self.main_time:Stop()
		self.main_time = nil
	end
	if self.update_time then
		self.update_time:Stop()
		self.update_time = nil
	end
end

function C:MyRefresh()
	self.width = Screen.width
	self.height = Screen.height
	if self.width / self.height < 1 then
		self.width,self.height = self.height,self.width
	end
	self.width = self.width - 400
	self.height = self.height - 400
	local x = math.random(1, self.width) - self.width/2
	local y = math.random(1, self.height) - self.height/2
	self.transform.localPosition = Vector3.New(x/100, y/100, self.zz)
	self:MoveAnim()
end

function C:MoveAnim()
	local x = 0
	local y = 0
	local p = self.transform.localPosition
	if p.x > 0 and p.y > 0 then
		local r = math.random(1, 200)
		if r > 100 then
			x = -1 * self.width/2
			y = math.random(1, self.height) - self.height/2
		else
			x = math.random(1, self.width) - self.width/2
			y = -1 * self.height/2
		end
	elseif p.x < 0 and p.y > 0 then
		local r = math.random(1, 200)
		if r > 100 then
			x = self.width/2
			y = math.random(1, self.height) - self.height/2
		else
			x = math.random(1, self.width) - self.width/2
			y = -1 * self.height/2
		end
	elseif p.x < 0 and p.y < 0 then
		local r = math.random(1, 200)
		if r > 100 then
			x = self.width/2
			y = math.random(1, self.height) - self.height/2
		else
			x = math.random(1, self.width) - self.width/2
			y = self.height/2
		end
	else
		local r = math.random(1, 200)
		if r > 100 then
			x = -1 * self.width/2
			y = math.random(1, self.height) - self.height/2
		else
			x = math.random(1, self.width) - self.width/2
			y = self.height/2
		end
	end

	local endPos = Vector3.New(x/100, y/100, self.zz)
	self:MoveBezier(endPos)
end

function C:MoveBezier(endPos)
	local beginPos = self.transform.localPosition
	self.seq = DoTweenSequence.Create()
	local len = math.sqrt( (beginPos.x - endPos.x) * (beginPos.x - endPos.x) + (beginPos.y - endPos.y) * (beginPos.y - endPos.y) )
	local t = len / 0.75
	local h = math.random(1, 2)
	self.seq:Append(self.transform:DOMoveBezier(endPos, h, t):SetEase(DG.Tweening.Ease.Linear))
	self.seq:OnKill(function ()
		self.seq = nil
		if IsEquals(self.gameObject) then
			self:MoveAnim()
		end
	end)
end

function C:on_backgroundReturn_msg()
	if self.seq then
		self.seq:Kill()
	end
	if IsEquals(self.gameObject) then
		self:MoveAnim()
	end
end

function C:on_background_msg()
	if self.seq then
		self.seq:Kill()
	end
end

function C:FrameUpdate()
	if self.transform and self.fd_objs then
		self.fd_objs.transform.position = FishFarmModel.Get2DToUIPoint(self.transform.position)
	end
end