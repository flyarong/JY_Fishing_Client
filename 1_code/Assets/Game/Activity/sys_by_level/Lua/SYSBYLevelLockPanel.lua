-- 创建时间:2020-05-26
-- Panel:SYSBYLevelLockPanel
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

SYSBYLevelLockPanel = basefunc.class()
local C = SYSBYLevelLockPanel
C.name = "SYSBYLevelLockPanel"
local Award2Str = {
	jing_bi = "金币",
	prop_3d_fish_lock = "锁定(3D捕鱼)",
	prop_fish_lock = "锁定",
}
function C.Create(data,is_gxsj)
	return C.New(data,is_gxsj)
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

function C:ctor(data,is_gxsj)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.data = data
	self.is_gxsj = is_gxsj
	LuaHelper.GeneratingVar(self.transform, self)
	self.gxsj.gameObject:SetActive(not (not self.is_gxsj))
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	CommonAwardPanelManager.AddPanel(self)
end

function C:InitUI()
	self.yes_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	local temp_ui = {}
	if self.data.award_info then
		for i = 1,#self.data.award_info.asset_type do
			local obj = GameObject.Instantiate(self.award_item,self.node)
			obj.gameObject:SetActive(true)
			LuaHelper.GeneratingVar(obj.transform, temp_ui)
			temp_ui.award_num_txt.text = self.data.award_info.asset_count[i]
			temp_ui.award_img.sprite = GetTexture(self.data.award_info.asset_image[i])
			temp_ui.award_name_txt.text = Award2Str[self.data.award_info.asset_type[i]]
		end
	end
	self:MyRefresh()
end

function C:MyRefresh()

end
