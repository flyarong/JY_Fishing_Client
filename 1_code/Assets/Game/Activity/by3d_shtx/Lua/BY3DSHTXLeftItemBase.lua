-- 创建时间:2020-10-28
-- Panel:BY3DSHTXLeftItemBase
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

BY3DSHTXLeftItemBase = basefunc.class()
local C = BY3DSHTXLeftItemBase
C.name = "BY3DSHTXLeftItemBase"
local M = BY3DSHTXManager
function C.Create(parent,index)
	return C.New(parent,index)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
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

function C:ctor(parent,index)
	self.index = index
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.transform.localScale = Vector3.New(1,-1,1)
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.extra_btn.gameObject).onClick = basefunc.handler(self, self.on_ExtraClick)
	self:MyRefresh()
end

function C:MyRefresh()
	self.tips.transform:Find("Image").transform:GetComponent("Image").sprite = GetTexture("shtx_3dby_dhk_bg_1")
	self.layer_cur_txt.text = self.index
	self.layer_normal_txt.text = self.index
	self:CheckIsextraAward()
	self:CheckIsShowOtherPlayerTips()
end

function C:CheckIsextraAward()
	local config = M.GetExtraAwardCfg()
	for i=1,#config do
		if self.index == config[i].layer and M.GetCurLayer() ~= self.index then
			self.extra.gameObject:SetActive(true)
			return
		else
			self.extra.gameObject:SetActive(false)
		end
	end
end

function C:CheckIsShowOtherPlayerTips()
	if self.index%10 == 0 then
		--显示其他玩家进度提示
		self.tips.gameObject:SetActive(true)
		--tonumber(os.date("%Y%m%d", os.time()))
		self.tips_txt.text = "有95%的玩家已经超越此高度"
	end
end

function C:on_ExtraClick()
	--展示额外奖励
	local config = M.GetExtraAwardCfg()
	for i=1,#config do
		if self.index == config[i].layer and M.GetCurLayer() ~= self.index then
			self.tip.gameObject:SetActive(true)
			local str = config[i].extra_award_txt[1]
			for i=2,#config[i].extra_award_txt do
				str = str..","..config[i].extra_award_txt[i]
			end
			self.tip_txt.text = str
			self:StartTimer()
		end
	end
	
end

function C:GetLayer()
	return self.index
end

function C:CheckLayer(type)
	self.normal.gameObject:SetActive(type == "normal")
	self.cur.gameObject:SetActive(type == "cur")
	if type == "cur" then
		local rect = self.transform:GetComponent("RectTransform")
		rect.sizeDelta = Vector2.New(100,305.5)
	end
end

function C:StartTimer()
	self:StopTimer()
	self.main_time = Timer.New(function ()
		if self.tip.gameObject.activeSelf then
			self.tip.gameObject:SetActive(false)
		end
	end,3,-1) 
	self.main_time:Start()
end

function C:StopTimer()
	if self.main_time then
		self.main_time:Stop()
		self.main_time = nil
	end
end