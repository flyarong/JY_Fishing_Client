-- 创建时间:2020-04-15
-- Panel:ByItemPrefab
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

ByItemPrefab = basefunc.class()
local C = ByItemPrefab
C.name = "ByItemPrefab"

function C.Create(panelSelf, data, parent_transform, call, index)
	return C.New(panelSelf, data, parent_transform, call, index)
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
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(panelSelf, data, parent_transform, call, index)
	self.panelSelf = panelSelf
	self.data = data
	self.call = call
	self.index = index
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
	self.item_btn.onClick:AddListener(function ()
		if self.call then
			self.call(self.panelSelf, self.index)
		end
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	GetTextureExtend(self.icon_img, self.data.image, self.data.is_local_icon)
	if self.data.num and self.data.num > 0 then
		self.num_txt.text = "x " .. StringHelper.ToCash(self.data.num)
	else
		self.num_txt.text = "x 1"
	end
	if self.data.id then
		self.red.gameObject:SetActive(GameItemModel.GetItemRadByKey(self.data.id))
	else
		self.red.gameObject:SetActive(GameItemModel.GetItemRadByKey(self.data.item_key))
	end
	self:SpecialHandling()
end

-- 设置选中
function C:SetSelect(b)
	self.xz_obj.gameObject:SetActive(b)
	dump(self.data,"self.data:  ")
	if self.data.id then
		GameItemModel.SetItemRadByKey(self.data.id, false)
	else
		GameItemModel.SetItemRadByKey(self.data.item_key, false)
	end
	self.red.gameObject:SetActive(false)
end

--2021.8.10版本运营需求--欢乐天天捕鱼&捕鱼奥秘小优化-余洪铭.docx
function C:SpecialHandling()
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "cpl_notcjj", is_on_hint = true}, "CheckCondition")
	if self.data.small_tip and a and b then
		self.tip.gameObject:SetActive(true)
		self.tip_txt.text = self.data.small_tip
	else
		self.tip.gameObject:SetActive(false)
	end
end