local basefunc = require "Game/Common/basefunc"
Act_ty_LDFDFDItem = basefunc.class()
local M = Act_ty_LDFDFDItem
M.name = "act_ty_ldfd_fd"
local Mgr = Act_ty_LDFDManager
function M.Create(parent,offsetPos)
	return M.New(parent,offsetPos)
end

function M:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function M:MakeLister()
	self.lister = {}
end

function M:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function M:MyExit()
	self:RemoveListener()
    destroy(self.gameObject)
    instance = nil
end

function M:ctor(parent,offsetPos)
    ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.offsetPos=offsetPos
	self.transform = tran
	self.gameObject = obj
	-- self.gift_id = gift_id
	-- self.gift_data = MainModel.GetGiftDataByID(self.gift_id)
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function M:InitUI()
    self:MyRefresh()
	-- self.line_img.Height=self.index*20+240
	-- dump(self.line_img.Height,"福袋绳长： ")
	-- self.line_img.gameObject:GetComponent("RectTransform").sizeDelta = Vector2.New(18,240+self.index*20) 
	self.fd_img.transform.localPosition= Vector3.New(0, self.offsetPos, 0) 
	
end

function M:MyRefresh()
	
end

function M:OnDestroy()
	self:MyExit()
end