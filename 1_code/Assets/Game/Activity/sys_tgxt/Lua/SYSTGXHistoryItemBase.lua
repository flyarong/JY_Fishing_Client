-- 创建时间:2020-08-29
-- Panel:SYSTGXHistoryItemBase
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

SYSTGXHistoryItemBase = basefunc.class()
local C = SYSTGXHistoryItemBase
C.name = "SYSTGXHistoryItemBase"

local RECORD_CODE = {
	[0] = "审核中",
	[1] = "已通过",
	[2] = "未通过",
	[3] = "提现成功",
	[4] = "提现失败",
}
function C.Create(parent,data)
	return C.New(parent,data)
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

function C:ctor(parent,data)
	self.data = data
	dump(self.data,"<color=red>XXXXXXXXXXXXXXXXXXXXX</color>")
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
	self.time_txt.text = os.date("%Y/%m/%d  %H:%M", self.data.time or self.data.extract_time)
	self.ID_txt.text = self.data.id
	self:GetJLInforByNumber()
end

--数据结构  我的ID 105509
--收入
-- - "<color=red>XXXXXXXXXXXXXXXXXXXXX</color>" = {
-- -     "id"             = "105530"
-- -     "is_active"      = 1
-- -     "name"           = "游客8718"
-- -     "time"           = 1598251170
-- -     "treasure_type"  = 302
-- -     "treasure_value" = 900
-- - }

--提现
-- - "<color=red>XXXXXXXXXXXXXXXXXXXXX</color>" = {
-- -     "extract_time"  = 1598251712
-- -     "extract_value" = -200
-- -     "id"            = 1
-- - }
function C:GetJLInforByNumber()

	local status_str = ""
	if self.data and self.data.extract_status then
		status_str = "<color=black>（" .. RECORD_CODE[self.data.extract_status] .. "）</color>"
	end

	if self.data and self.data.treasure_type and self.data.treasure_value then
		self.number_txt.text = (self.data.treasure_value /100) .."元奖金"
		local v = basefunc.string.string_to_vec(self.data.name)
		dump(v,"<color=red>RRRRRRRR</color>")
		self.ID_txt.text = ""
		if #v > 7  then
			for  i=1,#v do
				if i <= 7 then
					self.ID_txt.text = self.ID_txt.text..v[i]
				end	
			end
			self.ID_txt.text = self.ID_txt.text.."..."
		else
			self.ID_txt.text = self.data.name	
		end
		if self.data.treasure_type == 301 then
			local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "cpl_notcjj", is_on_hint = true}, "CheckCondition")
			if a and b then
				self.name_txt.text = "兑换3元奖励金的奖励"
			else
				self.name_txt.text = "兑换商城任意兑换的奖励"
			end
			
		elseif self.data.treasure_type == 302 then
			self.name_txt.text = "升级vip2的奖励" 
		elseif self.data.treasure_type == 303 then
			self.name_txt.text = "升级vip3的奖励"	
		end
		self.name_txt.text = self.name_txt.text .. status_str
	elseif self.data then
		self.number_txt.text = (self.data.extract_value /100) .."元奖金"
		self.name_txt.text = "提取奖金" .. status_str
		self.ID_txt.text = ""
	end
end
