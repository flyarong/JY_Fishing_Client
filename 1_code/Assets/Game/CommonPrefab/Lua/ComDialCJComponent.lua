-- 创建时间:2019-12-05
-- Panel:ComDialCJComponent
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

ComDialCJComponent = basefunc.class()
local C = ComDialCJComponent
C.name = "ComDialCJComponent"

ComDialCJComponent.XXCJState = 
{
	Nor = "正常",
	Anim_Ing = "动画中",
	Anim_Finish = "动画完成",
}
--[[
	CellList 所有预制体
	cell_size 预制体的大小
	map_size 布局的大小
	pos_list 预制体的显示坐标
--]]
function C.Create(parm)
	return C.New(parm)
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
	self:StopBeginCJAnim()
	self:StopWaitAnim()

	self:CloseAnimSound()
	self:RemoveListener()
end
function C:MyClose()
	self:MyExit()
	destroy(self.gameObject)
end


function C:ctor(parm)
	self.parm = parm

	self:MakeLister()
	self:AddMsgListener()

	self:InitUI()
end

function C:InitUI()
	self.xycj_state = ComDialCJComponent.XXCJState.Nor

	self:InitPos()
	self:MyRefresh()
end

function C:InitPos()
	if self.parm.pos_list then
		self.pos_list = self.parm.pos_list
	else
		self:CreateSquarePos()
	end
end
-- 创建方形转盘
function C:CreateSquarePos()
	self.cell_size = self.parm.cell_size or {w = 160, h = 140}
	self.map_size = self.parm.map_size or {w = 6, h = 4}

	local py_w = (self.map_size.w + 1) / 2
	local py_h = (self.map_size.h + 1) / 2
	local py_h2 = (self.map_size.h - 1) / 2
	self.pos_list = {}
	-- 上
	for i = 1, self.map_size.w do
		local x = self.cell_size.w * (i-py_w)
		local y = self.cell_size.h * (py_h-1)
		local pos = Vector3.New(x, y, 0)
		self.pos_list[#self.pos_list + 1] = pos
	end
	-- 右
	for i = 1, self.map_size.h-2 do
		local x = self.cell_size.w * (self.map_size.w-py_w)
		local y = self.cell_size.h * (py_h2-i)
		local pos = Vector3.New(x, y, 0)
		self.pos_list[#self.pos_list + 1] = pos
	end
	-- 下
	for i = self.map_size.w, 1, -1 do
		local x = self.cell_size.w * (i-py_w)
		local y = self.cell_size.h * (py_h-self.map_size.h)
		local pos = Vector3.New(x, y, 0)
		self.pos_list[#self.pos_list + 1] = pos
	end
	-- 左
	for i = 1, self.map_size.h-2 do
		local x = self.cell_size.w * (1-py_w)
		local y = self.cell_size.h * (i-py_h2)
		local pos = Vector3.New(x, y, 0)
		self.pos_list[#self.pos_list + 1] = pos
	end
end
function C:MyRefresh()
	self.CellList = self.parm.CellList
	if #self.CellList ~= #self.pos_list then
		HintPanel.Create(1, "点位和预制体个数不匹配")
		return
	end
	self.max_count = #self.CellList

	for k,v in ipairs(self.CellList) do
		v.pre:SetPos(self.pos_list[k])
	end
	self:WaitAnim()
end

function C:IsCanCJ()
	if self.xycj_state == ComDialCJComponent.XXCJState.Nor then
		return true
	else
		return false
	end
end

function C:CloseAnimSound()
	if self.curSoundKey then
		soundMgr:CloseLoopSound(self.curSoundKey)
		self.curSoundKey = nil
	end
end
function C:StopBeginCJAnim()
	if self.run_seq then
		self.run_seq:Kill()
		self.run_seq = nil
	end
end
function C:BeginCJAnim(end_index)
	if self.xycj_state ~= ComDialCJComponent.XXCJState.Nor then
		return
	end

	self:CloseAnimSound()
	self.curSoundKey = ExtendSoundManager.PlaySound(audio_config.game.bgm_duijihongbao.audio_name, 1, function ()
		self.curSoundKey = nil
	end)
	
	self:StopBeginCJAnim()
	self:StopWaitAnim()

	local step
	local begin_index = self.anim_begin_index or 1
	local quanshu = 10-- 转圈数
	if end_index > begin_index then
		step = self.max_count * quanshu + end_index - begin_index + 1
	else
		step = self.max_count * quanshu + self.max_count - begin_index + end_index + 1
	end

	local max_speed = 0.02
	local min_speed = 0.3

	local all_t = 6.3 -- 秒
	local qianzou = 1.6 -- 秒
	local zhongjian = self.max_count * quanshu * max_speed
	local houzou = all_t - qianzou - zhongjian - 0.3

	local frame = 7
	local end_frame = 17
	self.xycj_state = ComDialCJComponent.XXCJState.Anim_Ing
	self.run_seq = DoTweenSequence.Create()
	for i = 1, step do
		local k = begin_index + i - 1
		if k % self.max_count ~= 0 then
			k = k % self.max_count
		else
			k = self.max_count
		end
		local t
		if i <= frame then
			t = qianzou / frame
		elseif i >= (step - end_frame) then
			t = houzou / end_frame
		else
			t = max_speed
		end
		self.run_seq:AppendInterval(t)
		self.run_seq:AppendCallback(function ()
			self.CellList[k].pre:RunFX()
		end)
	end
	self.run_seq:AppendInterval(0.1)
	self.run_seq:AppendCallback(function ()
		self.CellList[end_index].pre:PlayXZ()
	end)
	self.run_seq:AppendInterval(1)
	self.run_seq:OnKill(function ()
		self:RunAnimFinish()
	end)
	self.run_seq:OnForceKill(function (force_kill)
		if force_kill then
			self:RunAnimFinish()
		end
	end)
	self.anim_begin_index = end_index
end

function C:RunAnimFinish()
	self.run_seq = nil
	self.xycj_state = ComDialCJComponent.XXCJState.Anim_Finish
	for i = 1, #self.CellList do
		self.CellList[i].pre:RunEnd()
	end
	self.xycj_state = ComDialCJComponent.XXCJState.Nor
	self:CloseAnimSound()

	Event.Brocast("com_dial_cj_anim_finish_msg", {key=self.parm.key})
	self:WaitAnim()
end

-- 待机表现
function C:StopWaitAnim()
	if self.wait_time then
		self.wait_time:Stop()
		self.wait_time = nil
	end
end
function C:WaitAnim()
	if self.parm.wait_style then
		if not self.parm.wait_style.pmd or self.parm.wait_style.pmd == 1 then
			self.wait_cur_index = self.wait_cur_index or 1
			local tt1 = self.parm.wait_style.step or 1
			self:StopWaitAnim()
			self.wait_time = Timer.New(function ()
				self.wait_cur_index = self.wait_cur_index + 1
				if self.wait_cur_index > #self.CellList then
					self.wait_cur_index = 1
				end
				self.CellList[self.wait_cur_index].pre:RunFX()
			end, tt1, -1, nil, true)
			self.wait_time:Start()
			self.CellList[self.wait_cur_index].pre:RunFX()
		else
		end
	end
end


