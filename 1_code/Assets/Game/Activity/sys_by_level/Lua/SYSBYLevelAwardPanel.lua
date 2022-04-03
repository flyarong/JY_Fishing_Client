-- 创建时间:2020-05-26
-- Panel:SYSBYLevelAwardPanel
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

SYSBYLevelAwardPanel = basefunc.class()
local C = SYSBYLevelAwardPanel
C.name = "SYSBYLevelAwardPanel"
local Award2Str = {
	jing_bi = "金币",
	prop_3d_fish_lock = "锁定(3D捕鱼)",
	prop_fish_lock = "锁定",
}
function C.Create(data, is_gxsj, level)
	return C.New(data, is_gxsj, level)
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
	CommonAwardPanelManager.DelPanel(self)
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(data, is_gxsj, level)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.data = data
	self.is_gxsj = is_gxsj or false
	LuaHelper.GeneratingVar(self.transform, self)
	self.gxsj.gameObject:SetActive(self.is_gxsj)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.level_txt.text = level or "0"
	CommonAwardPanelManager.AddPanel(self)
end

function C:InitUI()
	local temp_ui = {}
	if self.data.award_info then
		for i = 1,#self.data.award_info.asset_type do
			local obj = GameObject.Instantiate(self.award_item,self.award_node)
			obj.gameObject:SetActive(true)
			LuaHelper.GeneratingVar(obj.transform, temp_ui)
			temp_ui.award_num_txt.text = self.data.award_info.asset_count[i]
			temp_ui.award_img.sprite = GetTexture(self.data.award_info.asset_image[i])
		end
	end
	self:MyRefresh()
end

function C:MyRefresh()
	local pos = Vector3.zero
	if MainModel.myLocation == "game_Fishing3D" then
		local pan = FishingLogic.GetPanel()
	    local uipos = FishingModel.GetSeatnoToPos(FishingModel.data.seat_num)
	    local p_pre = pan.PlayerClass[uipos]
		pos = FishingModel.Get2DToUIPoint(p_pre:GetLaserFXPos())
	end

	self.node.transform.position = pos + Vector3.New(0, 200, 0)

	local tran = self.node.transform
	tran.localScale = Vector3.zero
    local seq = DoTweenSequence.Create()
    self.is_exit = true
    seq:Append(tran:DOScale(1.2, 0.3))
    seq:Append(tran:DOScale(0.8, 0.2))
    seq:Append(tran:DOScale(1, 0.1))
    seq:AppendInterval(2)
    seq:OnKill(function()
    	if self.is_exit then
	        self:MyExit()
	        self.is_exit = false
    	end
    end)
    seq:OnForceKill(function()
    	if self.is_exit then
	        self:MyExit()
	        self.is_exit = false
    	end
    end)
end
