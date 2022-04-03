-- 创建时间:2021-01-29
-- Panel:SYS_3DBY_XYXTGYJPanel
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

SYS_3DBY_XYXTGYJPanel = basefunc.class()
local C = SYS_3DBY_XYXTGYJPanel
C.name = "SYS_3DBY_XYXTGYJPanel"
local M = SYS_3DBY_XYXTGManager

function C.Create(award_num)
	return C.New(award_num)
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

function C:ctor(award_num)
	dump(award_num,"<color=yellow><size=15>++++++++++dat++++//////////a++++++++++</size></color>")
	ExtPanel.ExtMsg(self)
	self.target_num = award_num
	local parent = GameObject.Find("Canvas/LayerLv5").transform
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
	--self:PlayYJ(self.target_num)
	
	self:RefreshNum()--新改版(直接显示,无滚动)
end

function C:RefreshNum()
	local tran = self.transform
	tran.localScale = Vector3.one
	tran.position = Vector3.zero
	local ui = {}
	LuaHelper.GeneratingVar(tran, ui)
	local number_to_array = function(number, len)
		local tbl = {}
		local nn = number
		while nn > 0 do
			tbl[#tbl + 1] = nn % 10
			nn = math.floor(nn / 10)
		end

		local array = {}
		if len then
			if len > #tbl then
				for idx = len, 1, -1 do
					if idx > #tbl then
						array[#array + 1] = 0
					else
						array[#array + 1] = ""..tbl[idx]
					end
				end
			else
				for idx = #tbl, 1, -1 do
					array[#array + 1] = ""..tbl[idx]
				end
				print("<color=red>EEE 长度定义不合理 number = " .. number .. "  len = " .. len .. "</color>")
			end
		else
			for idx = #tbl, 1, -1 do
				array[#array + 1] = ""..tbl[idx]
			end
		end
		return array
	end

	local arr = number_to_array(self.target_num, 9)
	local item_list = {}
	for i = 1, 9 do
		item_list[#item_list + 1] = ui["Mask"..i].gameObject
	end
	local item_map = {}
	for x=1,#item_list do
		item_map[x] = item_map[x] or {}
		item_map[x][1] = {}
		item_map[x][1].data = {id=arr[x], x=x, y=1}
		item_map[x][1].ui = {}
		item_map[x][1].ui.gameObject = item_list[x]
		item_map[x][1].ui.transform = item_map[x][1].ui.gameObject.transform
		LuaHelper.GeneratingVar(item_map[x][1].ui.transform, item_map[x][1].ui)
		item_map[x][1].ui.num_txt.text = item_map[x][1].data.id
	end
	self:StopTimer()
	self.timer = Timer.New(function ()
		self:MyExit()
	end,2,1,false)
	self.timer:Start()
end

function C:StopTimer()
	if self.timer then
		self.timer:Stop()
		self.timer = nil
	end
end

function C:MyRefresh()
end

function C:PlayYJ(score)
	ExtendSoundManager.PlaySound(audio_config.by.bgm_by_jiangli5.audio_name)
	local obj = self.gameObject
	local tran = self.transform
	tran.localScale = Vector3.one
	tran.position = Vector3.zero
	local ui = {}
	LuaHelper.GeneratingVar(tran, ui)
	obj:SetActive(false)
	
	local number_to_array = function(number, len)
		local tbl = {}
		local nn = number
		while nn > 0 do
			tbl[#tbl + 1] = nn % 10
			nn = math.floor(nn / 10)
		end

		local array = {}
		if len then
			if len > #tbl then
				for idx = len, 1, -1 do
					if idx > #tbl then
						array[#array + 1] = 0
					else
						array[#array + 1] = ""..tbl[idx]
					end
				end
			else
				for idx = #tbl, 1, -1 do
					array[#array + 1] = ""..tbl[idx]
				end
				print("<color=red>EEE 长度定义不合理 number = " .. number .. "  len = " .. len .. "</color>")
			end
		else
			for idx = #tbl, 1, -1 do
				array[#array + 1] = ""..tbl[idx]
			end
		end
		return array
	end

	local arr = number_to_array(score, 9)
	dump(arr,"<color=yellow><size=15>++++++++++arr++++++++++</size></color>")

	-- 滚动数据
	local item_list = {}
	for i = 1, 9 do
		item_list[#item_list + 1] = ui["Mask"..i].gameObject
	end

	local seq = DoTweenSequence.Create()
	local delta_t = 2
	--[[if delta_t and delta_t > 0 then
		seq:AppendInterval(delta_t)
		seq:AppendCallback(function ()
			obj:SetActive(true)
			self:ScrollLuckyChangeToFiurt(item_list,arr,function ()
				print("<color=red>滚动完成XXXXXXXXXXXXX</color>")
			end)
		end)
	else--]]
		obj:SetActive(true)
		self:ScrollLuckyChangeToFiurt(item_list,arr,function ()
			print("<color=red>滚动完成XXXXXXXXXXXXX</color>")
		end)
	--end
	seq:AppendInterval(5)
	--seq:Append(tran:DOMove(endPos, 0.6):SetEase(DG.Tweening.Ease.InQuint))
	seq:AppendCallback(
		function()
			if backcall then
				backcall()
			end
		end
	)
	seq:OnForceKill(function ()
		self:MyExit()
	end)
end

function C:ScrollLuckyChangeToFiurt(item_list,data_list,callback)
	local item_map = {}--数据转换
	for x=1,#item_list do
		item_map[x] = item_map[x] or {}
		item_map[x][1] = {}
		item_map[x][1].data = {id=data_list[x], x=x, y=1}
		item_map[x][1].ui = {}
		item_map[x][1].ui.gameObject = item_list[x]
		item_map[x][1].ui.transform = item_map[x][1].ui.gameObject.transform
		LuaHelper.GeneratingVar(item_map[x][1].ui.transform, item_map[x][1].ui)
		item_map[x][1].ui.num_txt.text = item_map[x][1].data.id
	end

	local change_up_t = 0.2 --加速时间
	local change_uni_t = 0.02 --每一次滚动时间
	local change_down_t = 0.2 --减速时间
	local change_uni_d = 2 --匀速滚动时长
	local change_up_d = 0.04 --滚动加速间隔

	local speed_status = {
		speed_up = "speed_up",
		speed_uniform = "speed_uniform",
		speed_down = "speed_down",
		speed_end = "speed_end",
	}
	local material_FrontBlur = GetMaterial("FrontBlur")
	local spacing = 85 + 0
	local add_y_count = 3
	local down_count = 0
	local all_count = 0
	local all_fruit_map = {}
	for x,_v in pairs(item_map) do
		for y,v in pairs(_v) do
			all_count = all_count + 1
		end
	end
	all_count = all_count * add_y_count

	local speed_uniform
	local speed_up
	local speed_down

	local function get_pos_by_index(x,y,size_x,size_y,spac_x,spac_y)
		size_x = size_x or 46
		size_y = size_y or 85
		spac_x = spac_x or 0
		spac_y = spac_y or 0
		local pos = {x = 0,y = 0}
		pos.x = (x - 1) * (size_x + spac_x)
		pos.y = (y - 1) * (size_y + spac_y)
		return pos
	end

	local function get_index_by_pos(x,y,size_x,size_y,spac_x,spac_y)
		size_x = size_x or 46
		size_y = size_y or 85
		spac_x = spac_x or 0
		spac_y = spac_y or 0
		local index = {x = 1,y = 1}
		index.x = math.floor(x / (size_x + spac_x)) + 1
		index.y = math.floor(y / (size_y + spac_y)) + 1
		return index
	end

	local function create_obj(data)
		local _obj = {}
		_obj.ui = {}
		_obj.data = data
		local parent = _obj.data.parent
		if not parent then return end
		_obj.ui.gameObject = GameObject.Instantiate(data.obj, parent)
		_obj.ui.transform = _obj.ui.gameObject.transform
		_obj.ui.transform.localPosition = get_pos_by_index(_obj.data.x,_obj.data.y)
		_obj.ui.gameObject.name = _obj.data.x .. "_" .. _obj.data.y
		LuaHelper.GeneratingVar(_obj.ui.transform, _obj.ui)
		_obj.ui.num_txt.text = data.id
		return _obj
	end

	local function call(v)
		if not v.obj.ui or not v.obj.ui.transform or not IsEquals(v.obj.ui.transform) then return end
		if v.status == speed_status.speed_up or v.status == speed_status.speed_uniform or v.status == speed_status.speed_down then
			if v.status == speed_status.speed_up then
				v.obj.ui.num_txt.material = material_FrontBlur
			elseif v.status == speed_status.speed_down then
				v.obj.ui.num_txt.material = nil
			end
			if v.obj.ui.transform.localPosition.y < -spacing then
				v.obj.ui.transform.localPosition = get_pos_by_index(1,2)
				v.obj.ui.num_txt.text = math.random( 0,9)
			end
		elseif v.status == speed_status.speed_end then
			down_count = down_count + 1
			if down_count == all_count then
				for x,_v in pairs(item_map) do
					for y,v in pairs(_v) do
						v.ui.num_txt.gameObject:SetActive(true)
					end
				end
				for x1,_v1 in pairs(all_fruit_map) do
					for y1,v1 in pairs(_v1) do
						for x2,_v2 in pairs(v1) do
							for y2,v2 in pairs(_v2) do
								Destroy(v2.obj.ui.gameObject)
							end
						end
					end
				end
				all_fruit_map = {}
				if callback and type(callback) == "function" then
					callback()
				end
			end
		end
		if v.status == speed_status.speed_up then
			v.status = speed_status.speed_uniform --加速完成进入匀速状态
		end
		if v.status == speed_status.speed_uniform then
			speed_uniform(v)
		elseif v.status == speed_status.speed_up then
			speed_up(v)
		elseif v.status == speed_status.speed_down then
			speed_down(v)
		end
	end

	speed_up = function  (v)
		v.status = speed_status.speed_up
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, change_up_t))
		seq:SetEase(DG.Tweening.Ease.InCirc)
		seq:OnForceKill(function ()
			call(v)
		end)
	end

	speed_uniform = function (v)
		v.status = speed_status.speed_uniform
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, change_uni_t))
		seq:SetEase(DG.Tweening.Ease.Linear)
		seq:OnForceKill(function ()
			call(v)
		end)
	end

	speed_down = function (v)
		v.status = speed_status.speed_down
		local index = get_index_by_pos(v.obj.ui.transform.localPosition.x,v.obj.ui.transform.localPosition.y)
		if index.y == 2 then
			local id = item_map[v.real_x][v.real_y].data.id
			v.obj.ui.num_txt.text = id
		end
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, change_down_t))
		seq:SetEase(DG.Tweening.Ease.OutCirc)
		seq:OnForceKill(function ()
			v.status = speed_status.speed_end
			call(v)
		end)
	end

	local function lucky_chang_to_fruit(v_obj,index_x)
		if not IsEquals(item_map[index_x][1].ui.gameObject) then
			return
		end
		local fruit_map = {}
		local id
		local ins_obj = GameObject.Instantiate(item_map[index_x][1].ui.gameObject)
		for y=1,add_y_count do
			if y == 1 then
				id = v_obj.data.id
			else
				id = math.random(0,9)
			end
			fruit_map[1] = fruit_map[1] or {}
			fruit_map[1][y] ={obj = create_obj({obj = ins_obj,x = 1,y = y,id = id ,parent = v_obj.ui.transform}),status = speed_status.speed_up,real_x = v_obj.data.x,real_y = v_obj.data.y}
			local v = fruit_map[1][y]
			if v.obj.ui.transform.localPosition.y < -spacing then
				v.obj.ui.transform.localPosition = get_pos_by_index(1,2)
				v.obj.ui.num_txt.text = math.random(0,9)
			end
			speed_up(fruit_map[1][y])
		end
		--隐藏自己
		v_obj.ui.num_txt.gameObject:SetActive(false)
		Destroy(ins_obj)
		return fruit_map
	end

	--一列一列加速改变
	local x = 1
	local change_up_timer
	if change_up_timer then change_up_timer:Stop() end
	change_up_timer = Timer.New(function()
		if item_map[x] then
			for y=1,9 do
				local v = item_map[x][y]
				if v then
					all_fruit_map[x] = all_fruit_map[x] or {}
					all_fruit_map[x][y] = lucky_chang_to_fruit(v,x)
				end
			end
		end
		x = x + 1
		if x == 9 then
			local m_callback = function(  )
				for x,_v in pairs(all_fruit_map) do
					for y,v in pairs(_v) do
						for x1,v1 in pairs(v) do
							for y1,v2 in pairs(v1) do
								v2.status = speed_status.speed_down
							end
						end
					end
				end
			end
			local change_uni_timer = Timer.New(function ()
				m_callback()
			end,change_uni_d,1)
			change_uni_timer:Start()
		end
	end,change_up_d,9)
	change_up_timer:Start()
end