-- 创建时间:2020-07-30
-- Panel:SYSTGXTMyAwardItemBase
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

SYSTGXTMyAwardItemBase = basefunc.class()
local C = SYSTGXTMyAwardItemBase
C.name = "SYSTGXTMyAwardItemBase"
local M = SYSTGXTManager
function C.Create(parent,data,index)
	return C.New(parent,data,index)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
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

function C:ctor(parent,data,index)
	self.data = data
	self.index = index
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
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
	self:MyRefresh()
end

function C:MyRefresh()
	self.index_txt.text = (self.index or "1") .. "."
	local v = basefunc.string.string_to_vec(self.data.name)
	dump(v,"<color=red>RRRRRRRR</color>")
	self.name_txt.text = ""
	if #v > 7  then
		for  i=1,#v do
			if i <= 7 then
				self.name_txt.text = self.name_txt.text..v[i]
			end	
		end
		self.name_txt.text = self.name_txt.text.."..."
	else
		self.name_txt.text = self.data.name	
	end


	self.ID_txt.text = self.data.id
	self.time_txt.text =  os.date("%Y-%m-%d", self.data.m_register_time)

	--[[if self:CheckIsCJJ() then
		local x = self.data.first_shop_exchange_state
		if x == 2 then
			self.duihuan_txt.text = "<color=#019209>已完成</color>"
		else
			self.duihuan_txt.text = "<color=#ED5C15>未完成</color>"
		end

		x = self.data.vip2_state
		if x == 2 then
			self.vip2_txt.text = "<color=#019209>已完成</color>"
		else
			self.vip2_txt.text = "<color=#ED5C15>未完成</color>"
		end

		x = self.data.vip3_state
		if x == 2 then
			self.vip3_txt.text = "<color=#019209>已完成</color>"
		else
			self.vip3_txt.text = "<color=#ED5C15>未完成</color>"
		end
	else
		-- 0 无效 1未完成 2已完成 
		local x = self.data.first_shop_exchange_state
		if x == 2 then
			self.duihuan_txt.text = "<color=#019209>已完成</color>"
		elseif x == 1 then
			self.duihuan_txt.text = "<color=#ED5C15>未完成</color>"
		else
			self.duihuan_txt.text = "<color=#6D6863>无效</color>"
		end

		x = self.data.vip2_state
		if x == 2 then
			self.vip2_txt.text = "<color=#019209>已完成</color>"
		elseif x == 1 then
			self.vip2_txt.text = "<color=#ED5C15>未完成</color>"
		else
			self.vip2_txt.text = "<color=#6D6863>无效</color>"
		end

		x = self.data.vip3_state
		if x == 2 then
			self.vip3_txt.text = "<color=#019209>已完成</color>"
		elseif x == 1 then
			self.vip3_txt.text = "<color=#ED5C15>未完成</color>"
		else
			self.vip3_txt.text = "<color=#6D6863>无效</color>"
		end
	end--]]

	--  2021/3/16   捕鱼要求和冲金鸡一样不显示邀请码,除非不支持微信了(不支持微信的话,就用上面被注释的代码)
	local x = self.data.first_shop_exchange_state
	local y = self.data.web_store_exchange_2_hongbao_num
	if x == 2 or y > 0 then
		self.duihuan_txt.text = "<color=#019209>已完成</color>"
	else
		self.duihuan_txt.text = "<color=#ED5C15>未完成</color>"
	end

	x = self.data.vip2_state
	if x == 2 then
		self.vip2_txt.text = "<color=#019209>已完成</color>"
	else
		self.vip2_txt.text = "<color=#ED5C15>未完成</color>"
	end

	x = self.data.vip3_state
	if x == 2 then
		self.vip3_txt.text = "<color=#019209>已完成</color>"
	else
		self.vip3_txt.text = "<color=#ED5C15>未完成</color>"
	end
end

function C:CheckIsCJJ()
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "cpl_cjj", is_on_hint = true}, "CheckCondition")
	if a and b then
		return true
	end
	return false
end