-- 创建时间:2019-12-20
-- Panel:SYSJJJ_JYFLEnterPrefab
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

SYSJJJ_JYFLEnterPrefab = basefunc.class()
local C = SYSJJJ_JYFLEnterPrefab
C.name = "SYSJJJ_JYFLEnterPrefab"

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
	self.lister["global_hint_state_change_msg"] = basefunc.handler(self,self.on_global_hint_state_change_msg)
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.main_timer then 
		self.main_timer:Stop()
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.slider = self.HBSlider:GetComponent("Slider")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:GetData()
end

function C:InitUI()
	self.BG_btn.onClick:AddListener(
		function ()
			self:Go()
		end
	)
	self.get_btn.onClick:AddListener(
		function ()
			self:Go()
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	if IsEquals(self.gameObject) then 
		if SysJJJManager.GetHintState() == ACTIVITY_HINT_STATUS_ENUM.AT_Get  then
			self.get_btn.transform:GetComponent("Image").sprite = GetTexture("ty_btn_huang1")
			self.get_btn.enabled = true
		else
			self.get_btn.transform:GetComponent("Image").sprite = GetTexture("ty_btn_ywc")
			self.get_btn.enabled = false
		end
		self.time_txt.text = "还可领".. SysJJJManager.GetCurCount() .."次"
		local totalnum = SysJJJManager.GetAllCount()
		self.slider.value = (totalnum-SysJJJManager.GetCurCount()) / totalnum 
		self.slider_txt.text = "<color=#007EFF>" .. (totalnum-SysJJJManager.GetCurCount()).."</color>".."<color=#3C6DA7>" .. "/"..totalnum .. "</color>"
	end 
end

function C:OnDestroy()
	self:MyExit()
end

function C:Go()
	if SysJJJManager.GetCurCount() < 0 then 
		HintPanel.Create(1,"今天的次数已领完")
		return 
	end
	if MainModel.UserInfo.jing_bi >= GAME_Di_Bao_limit then 
		HintPanel.Create(1,"金币少于" .. GAME_Di_Bao_limit .. "时，可免费领取")
		return
	end
	GameButtonManager.RunFun({ gotoui="sys_jjj", type="ldb"}, "CheckAndRunJJJ")
end

function C:GetData()
	SysJJJManager.SentQ()
	if self.main_timer then 
		self.main_timer:Stop()
	end
	self.main_timer = Timer.New(function()
		if self.totalnum == 0 then 
			SysJJJManager.SentQ()
		else
			if self.main_timer then 
				self.main_timer:Stop()
			end
		end 
	end,5,-1)
	self.main_timer:Start()
end

function C:on_global_hint_state_change_msg(parm)
	if parm and parm.gotoui == SysJJJManager.key then
		self:MyRefresh()
	end
end