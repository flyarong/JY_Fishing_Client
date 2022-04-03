-- 创建时间:2020-08-05

mine_close_lib = {}

local C = mine_close_lib

C.tag = {
	["l"] = "雷",
	["n"] = "空",
}
C.wall_pos = {{x=-1,y=1}, {x=0,y=1}, {x=1,y=1}, {x=-1,y=0}, {x=1,y=0}, {x=-1,y=-1}, {x=0,y=-1}, {x=1,y=-1}}
-- @require "Game/Common/mine_close_lib"   mine_close_lib.init(5,5,10)
function C.init(w, h, lei)
	local map = {}
	local n = w * h
	for i = 1, w do
		for j = 1, h do
			local r = math.random()
			if (r * n) <= lei then
				lei = lei - 1
				map[#map + 1] = {is_open=false, val=C.tag.l, prob=0, tag=nil} -- prob有雷的概率(初始值)  tag标记上雷或者空
			else
				map[#map + 1] = {is_open=false, val=nil, prob=0, tag=nil}
			end
			n = n - 1
		end
	end
	for y = 1, h do
		for x = 1, w do
			local index = C.pos_index({x=x,y=y}, w, h)
			if map[index].val ~= C.tag.l then
				map[index].val = C.calc_wall(map, w, h, x, y)
			end
		end
	end
	C.print(map, w, h)
	return map
end
function C.index_pos(index, w, h)
	if index > 0 and index <= (w*h) then
		local pos = {}
		pos.y = math.floor( (index-1) / w ) + 1
		pos.x = math.floor( (index-1) % w ) + 1
		return pos
	end
end
function C.pos_index(pos, w, h)
	if pos.y > 0 and pos.y <= h and pos.x > 0 and pos.x <= w then
		local index = (pos.y-1) * w + pos.x
		return index
	else
		return -1
	end
end
-- 获取周围的点位
function C.get_wall_pos(map, w, h, i, j)
	local x = 0
	local y = 0
	local index
	local n = w * h
	local wall = {}
	for k,v in ipairs(C.wall_pos) do
		x = v.x + i
		y = v.y + j
		index = C.pos_index({x=x,y=y}, w, h)
		if index > 0 and index <= n then
			wall[#wall + 1] = index
		end
	end
	return wall
end

-- 计算周围的雷数
function C.calc_wall(map, w, h, i, j)
	local x = 0
	local y = 0
	local index
	local n = w * h
	local a = 0
	local wall = C.get_wall_pos(map, w, h, i, j)
	for k,v in ipairs(wall) do
		if map[v].val == C.tag.l then
			a = a + 1
		end
	end
	return a
end
function C.print(map, w, h, is_zs)
	if is_zs then
		local s = "\n"
		local n = 1
		for i = 1, w do
			for j = 1, h do
				if not map[n].is_open then
					if map[n].tag == C.tag.l then
						s = s .. "^" .. "(1.00) "
					elseif map[n].tag == C.tag.n then
						s = s .. "n" .. "(1.00) "
					else
						if map[n].prob then
							s = s .. "x" .. "(" .. string.format("%.2f", map[n].prob) .. ")  "
						else
							s = s .. "x" .. "(6.66)  "
						end
					end
				else
					s = s .. map[n].val .. "(0.00)  "
				end
				n = n + 1
			end
			s = s .. "\n"
		end
		dump(s)
	else
		local s = "\n"
		local n = 1
		for i = 1, w do
			for j = 1, h do
				if map[n].val == C.tag.l then
					s = s .. "#"
				else
					s = s .. map[n].val
				end
				n = n + 1
			end
			s = s .. "\n"
		end
		dump(s)
	end
end

-- 评估概率 todo
function C.assess_prob(map, w, h, lei)
	local _no_open_num = 0
	local len = w * h
	for i = 1, len do -- 初始化
		if not map[i].is_open and not map[i].tag then
			map[i].prob = nil
			_no_open_num = _no_open_num + 1
		end
	end
	local calc_wall_list -- 计算需要处理的list
	local tag_lei -- 标记雷
	local calc_prob -- 计算概率
	local tag_lei_prob

	local _buf_list
	calc_wall_list = function ()
		_buf_list = {}
		for i = 1, len do
			local _lei_val = tonumber(map[i].val)
			if map[i].is_open and _lei_val and _lei_val > 0 then
				local pos = C.index_pos(i, w, h)
				local wall = C.get_wall_pos(map, w, h, pos.x, pos.y)
				local gb_list = {}
				for k,v in ipairs(wall) do
					if not map[v].is_open then
						if not map[v].tag then
							gb_list[#gb_list + 1] = v
						else
							_lei_val = _lei_val - 1
						end
					end
				end
				if #gb_list > 0 then
					_buf_list[#_buf_list + 1] = {wall_list = gb_list, lei=_lei_val, index=i}
				end
			end
		end
	end

	tag_lei = function ()
		local dirty = false
		calc_wall_list()
		for kk,vv in ipairs(_buf_list) do
			if vv.lei > 0 and #vv.wall_list == vv.lei then
				dirty = true
				for k,v in ipairs(vv.wall_list) do
					map[v].tag = C.tag.l
				end
			end
		end
		if dirty then
			tag_lei()
		end
	end
	tag_lei()

	calc_prob = function ()
		local dirty = false
		calc_wall_list()
		for kk,vv in ipairs(_buf_list) do
			if vv.lei > 0 then
				local gl = vv.lei / #vv.wall_list
				for k,v in ipairs(vv.wall_list) do
					if not map[v].prob then
						map[v].prob = gl
					else
						if map[v].prob < gl then
							map[v].prob = gl
							dirty = true
						end
					end
				end
			end
		end
		if dirty then
			calc_prob()
		end
	end
	calc_prob()

	-- #a < #b
	local function tableAND(a, b)
	    local bm = {}
	    for k,v in ipairs(b) do
	        bm[v] = 1
	    end
	    local is_no_all = true
	    for k,v in ipairs(a) do
	        if bm[v] then
	            bm[v] = nil
	        else
	        	return
	        end
	    end
	    local ret = {}
	    for k,v in pairs(bm) do
	    	ret[#ret + 1] = k
	    end
	    return ret
	end

	-- 标记空
	calc_wall_list()
	for i = 1, #_buf_list do
		for j = i+1, #_buf_list do
			if #_buf_list[i].wall_list ~= #_buf_list[j].wall_list then
				local xiao = i
				local da = j
				if #_buf_list[i].wall_list > #_buf_list[j].wall_list then
					xiao = j
					da = i
				end
				local aa = tableAND(_buf_list[xiao].wall_list, _buf_list[da].wall_list)
				if aa then
					local cha = _buf_list[da].lei - _buf_list[xiao].lei
					dump(aa, "<color=red>aa</color>")
					if cha == 0 then
						for k,v in ipairs(aa) do
							map[v].tag = C.tag.n
						end
					else
						if cha == #aa then
							for k,v in ipairs(aa) do
								map[v].tag = C.tag.l
							end
						else
							local gl = cha / #aa
							for k,v in ipairs(aa) do
								if not map[v].prob then
									map[v].prob = gl
								else
									if map[v].prob < gl then
										map[v].prob = gl
									end
								end
							end
						end
					end
				end
			end
		end
	end

	-- 剩余未标记的区域
	local _add_prob = 0
	for i = 1, len do
		if not map[i].is_open and not map[i].tag and map[i].prob then
			_add_prob = _add_prob + map[i].prob
		end
		if not map[i].is_open and map[i].tag then
			_add_prob = _add_prob + 1
		end
	end
	print(_add_prob)
	local _sy = lei - _add_prob
	if _sy < 0 then
		_sy = 0.5
	end
	local sy_wbj_list = {}
	for i = 1, len do
		if not map[i].is_open and not map[i].tag and not map[i].prob then
			sy_wbj_list[#sy_wbj_list + 1] = i
		end
	end
	if #sy_wbj_list > 0 then
		local _ys_gl = _sy / #sy_wbj_list
		print(_ys_gl)
		for k,v in ipairs(sy_wbj_list) do
			map[v].prob = _ys_gl
		end
	end
end
-- 获取被标记的雷数
function C.get_tag_lei_num(map, w, h)
	local len = w * h
	local n = 0
	for i = 1, len do
		if not map[i].is_open and map[i].tag == C.tag.l then
			n = n + 1
		end
	end
	return n
end

-- 搜索0区域
function C.rad_click0(map, w, h, x, y)
	local index = 0
	local x1 = 0
	local y1 = 0
	local n = w * h
	local new_0pos = {} -- 新的0点位

	local wall = C.get_wall_pos(map, w, h, x, y)
	for k,v in ipairs(wall) do
		if not map[v].is_open and map[v].val ~= C.tag.l then
			map[v].is_open = true
			if tonumber(map[v].val) == 0 then
				new_0pos[#new_0pos + 1] = v
			end
		end
	end
	return new_0pos
end

-- 点击返回
function C.back_click(map, w, h, x, y)
	local index = C.pos_index({x=x, y=y}, w, h)
	local mm = {}
	map[index].is_open = true

	if map[index].val == C.tag.l then
		mm.is_lose = true
	else
		mm.is_lose = false
		if tonumber(map[index].val) == 0 then
			local pos0_list = {index}
			while (#pos0_list > 0) do
				local _pos0_list = {}
				for k,v in ipairs(pos0_list) do
					local pos = C.index_pos(v, w, h)
					local pp = C.rad_click0(map, w, h, pos.x, pos.y)
					if #pp > 0 then
						for _,v1 in ipairs(pp) do
							_pos0_list[#_pos0_list + 1] = v1
						end
					end
				end
				pos0_list = _pos0_list
			end
		end
	end

	return mm
end

function C.tuijian_pos(map, w, h, lei)
	local index
	local len = w * h
	for i = 1, len do
		if not map[i].is_open and map[i].prob and (not map[i].tag or (map[i].tag and map[i].tag ~= C.tag.l)) then
			if map[i].prob == 0 or (map[i].tag and map[i].tag == C.tag.n) then
				dump(map[i])
				index = i
				break
			else
				if not index then
					index = i
				else
					if map[i].prob < map[index].prob then
						index = i
					end
				end
			end
		end
	end
	return index
end

-- @require "Game/Common/mine_close_lib"   mine_close_lib.run_ai(mine_close_lib.init(10,10,10), 10,10,10)
-- @require "Game/Common/mine_close_lib"   mine_close_lib.run_ai(mine_close_lib.init(5,5,10), 5,5,10)
function C.run_ai(map, w, h, lei)
	local len = w * h
	local tag_lei_num = 0

	for y = 1, h do
		for x = 1, w do
			local index = C.pos_index({x=x,y=y}, w, h)
			if map[index].val ~= C.tag.l then
				map[index].val = C.calc_wall(map, w, h, x, y)
			end
		end
	end

	local step_list = {}
	while (tag_lei_num < lei) do
		local index = C.tuijian_pos(map, w, h, lei)
		local pos = C.index_pos(index, w, h)
		local jg = C.back_click(map, w, h, pos.x, pos.y)
		dump(pos)
		dump(index)
		step_list[#step_list + 1] = pos
		if jg.is_lose then
			break
		end
		
		C.assess_prob(map, w, h, lei)
		tag_lei_num = C.get_tag_lei_num(map, w, h)

		C.print(map, w, h, true)
	end

	if tag_lei_num < lei then
		print(string.format("失败!!! %d / %d", tag_lei_num, lei))
		C.print(map, w, h)
	else
		print("成功!!!")
		dump(step_list)
	end
end

-- @require "Game/Common/mine_close_lib"   mine_close_lib.run_test(2)
function C.run_test(n)
	local map = {}
	local w = 5
	local h = 5
	local lei = 5
	local len = w * h
	for i = 1, len do
		map[#map + 1] = {is_open=false, prob=0}
	end
	map[3].val=C.tag.l
	map[9].val=C.tag.l
	map[10].val=C.tag.l
	map[22].val=C.tag.l
	map[24].val=C.tag.l

	for y = 1, h do
		for x = 1, w do
			local index = C.pos_index({x=x,y=y}, w, h)
			if map[index].val ~= C.tag.l then
				map[index].val = C.calc_wall(map, w, h, x, y)
			end
		end
	end

	for ii = 1, n do
		local index = C.tuijian_pos(map, w, h, lei)
		local pos = C.index_pos(index, w, h)
		dump(pos)
		local jg = C.back_click(map, w, h, pos.x, pos.y)
		C.assess_prob(map, w, h, lei)
		C.print(map, w, h, true)
	end
end
