-- 创建时间:2020-10-30
-- Panel:Act_035_CenterPrefab
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

Act_035_CenterPrefab = basefunc.class()
local C = Act_035_CenterPrefab
C.name = "Act_035_CenterPrefab"

function C.Create(parent, parentPanel, index, id, infor)
	return C.New(parent, parentPanel, index, id, infor)
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

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

--index是第几个 ，ID是第几页
function C:ctor(parent, parentPanel, index, id, infor)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.id = id
	self.infor = infor 
	self.index = index
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	
	if self.index ==1 then
		self.top_txt.text = "当日首次购买"
		self.center_txt.text = self.infor.first_buy[1].."金币"
		self.buttom_txt.text = self.infor.first_buy[2].."金币"
		self.jb_img.sprite = GetTexture(self.infor.image[1])
	else
		self.top_txt.text = "当日再次购买"
		self.center_txt.text = self.infor.twoce_buy[1].."金币"
		self.buttom_txt.text = self.infor.twoce_buy[2].."金币"
		self.jb_img.sprite = GetTexture(self.infor.image[2])
	end
	self:RefreshHadBuy()
end

function C:RefreshHadBuy()
	if self.index == 1 then
		if MainModel.GetGiftShopStatusByID(self.infor.shop_id[1]) == 0 then
			self.had_img.gameObject:SetActive(true)
		else
			self.had_img.gameObject:SetActive(false)
		end
	else
		if not Act_035_JHSManager.IsCanGetGift(self.infor.shop_id) then
			self.had_img.gameObject:SetActive(true)
		else
			self.had_img.gameObject:SetActive(false)
		end
	end
end