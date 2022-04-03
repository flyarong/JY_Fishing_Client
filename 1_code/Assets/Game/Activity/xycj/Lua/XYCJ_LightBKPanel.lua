-- 创建时间:2020-05-22
-- Panel:XYCJ_LightBKPanel
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

XYCJ_LightBKPanel = basefunc.class()
local C = XYCJ_LightBKPanel
C.name = "XYCJ_LightBKPanel"

function C.Create(parent,cur_index,num,selectIndex)
	return C.New(parent,cur_index,num,selectIndex)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.seq then
		self.seq:Kill()
		self.seq = nil
	end
	if self.seq1 then
		self.seq1:Kill()
		self.seq1 = nil
	end
	if self.seq2 then
		self.seq2:Kill()
		self.seq2 = nil
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent,cur_index,num,selectIndex)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:DoTween(cur_index,num,selectIndex)

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.cell_list = {}
	for i = 1, 10 do
		local pre = GameObject.Instantiate(self.XYCJPanel_g_node,self.transform)
		self.cell_list[#self.cell_list + 1] = pre
		pre.transform.rotation = Quaternion:SetEuler(0, 0, -36*(i-1))
	end

	self:MyRefresh()
end

function C:MyRefresh()
	
end

function C:OnExitScene()
	self:MyExit()
end

function C:DoTween(cur_index,num,selectIndex)
	self.cur_index = cur_index--开始是第几个
	self.num = num--经过的总个数
	self.selectIndex = selectIndex--最终结果是第几个
	dump(self.selectIndex,"<color>=================selectIndex===========</color>")
	dump(self.cur_index,"<color>===============cur_index=============</color>")
	dump(self.num,"<color>===============num=============</color>")
	self:DestroyPre()
	self.XYCJPanel_g_node_qr.gameObject:SetActive(false)
	self.seq = DoTweenSequence.Create()
	local t = 0
	local s_num = math.floor(self.num / 6)
	local e_num = math.floor(self.num / 6)
	local j = self.cur_index - 1
	for i=1,self.num do
		if i <= s_num then--加速
			t = 2 / (self.num ) + (s_num - i) * 2 / (self.num )
		elseif i > s_num and i < (self.num - e_num) then--匀速
			t = 2 / (self.num )
		elseif i >= (self.num - e_num) then--减速
			t = 2 / (self.num ) + (i + e_num - self.num) * 2 / (self.num )
		end
		j = j + 1
		if j > 10 then
			j = 1
		end
		local jj = j
		self.seq:AppendInterval(t)
		self.seq:AppendCallback(function ()
			self.cell_list[jj].gameObject:SetActive(false)
			self.cell_list[jj].gameObject:SetActive(true)
			if i >= self.num then
				local rota = -36 * (self.selectIndex-1)
				self.XYCJPanel_g_node_qr.gameObject:SetActive(true)
				self.XYCJPanel_g_node_qr.transform.localRotation = Quaternion:SetEuler(0, 0, rota)
				self.seq1 = DoTweenSequence.Create()
				self.seq1:AppendInterval(0.5)
				self.seq1:AppendCallback(function ()
					Event.Brocast("XYCJ_LightBKPanel_msg")
					self.seq2 = DoTweenSequence.Create()
					self.seq2:AppendInterval(1)
					self.seq2:AppendCallback(function ()
						self.XYCJPanel_g_node_qr.gameObject:SetActive(false)
						self.seq2:Kill()
						self.seq2 = nil
						Event.Brocast("change_flqzpzz_show_state",true)
					end)
					self.seq1:Kill()
					self.seq1 = nil
				end)	
				self.seq:Kill()
				self.seq = nil	
			end
		end)
	end
end


function C:DestroyPre()
	if self.spawn_cell_list then
		for k,v in ipairs(self.spawn_cell_list) do
			Destroy(v.gameObject)
		end
	end
	self.spawn_cell_list = {}
end