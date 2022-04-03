-- 创建时间:2021-05-19
-- Panel:ACTCJDBBXPanel
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

ACTCJDBBXPanel = basefunc.class()
local C = ACTCJDBBXPanel
C.name = "ACTCJDBBXPanel"
local M = ACTCJDBManager

function C.Create(award_type)
	return C.New(award_type)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["box_exchange_response"] = basefunc.handler(self, self.on_box_exchange_response)
	self.lister["AssetChange"] = basefunc.handler(self,self.OnAssetChange)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	VIPManager.is_waite(false)
	self.wait_award_data = nil
	self.out_lottery()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(award_type)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.wait_award_data = nil
	self.award_type=award_type
	self.data = {}
	self.config = M.GetAllConfigByXYBX(self.award_type)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	if self.award_type == 1 then
		self.hhbx_BG_img.sprite = GetTexture("bx_bg_hhbx")
		self.bottom_txt.text="消耗一把金钥匙可领取一次宝箱"
	else
		self.hhbx_BG_img.sprite = GetTexture("bx_bg_ptbx")
		self.bottom_txt.text="消耗一把银钥匙可领取一次宝箱"
	end
	
	self:RefreshUI()
	self:InitRotat()
end

function C:InitRotat()
	local parent = self.box_rect.transform
	self.fist_tab = self:X_Scroll(nil,function() 
		self:EndLottery() 
	end,self.config,"ACTCJDB_box_prefab",9,parent)
	self.turn_list = self.fist_tab.bk_list
	self:RefreshUI()
	self.out_lottery = self.fist_tab.Exit
	self.lottery_btn.onClick:AddListener(function()
		if self.award_type == 1 then
			Network.SendRequest("box_exchange", {id = 95,num = 1}, "")
		else
			Network.SendRequest("box_exchange", {id = 94,num = 1}, "")
		end
    end)
	self.back_btn.onClick:AddListener(function()
        self:MyExit()
    end)
end

function C:RefreshUI()
	local key_num = GameItemModel.GetItemCount("prop_super_treasure_key_"..self.award_type)
	self.key_num_txt.text = key_num
	--dump(key_num,"<color=blue>----钥匙数目-----</color>")
	if key_num == 0 or key_num == -1 then
		self.lottery_btn.gameObject:SetActive(false)
		self.gray_btn.gameObject:SetActive(true)
	else
		self.lottery_btn.gameObject:SetActive(true)
		self.gray_btn.gameObject:SetActive(false)
	end
end

-- award_data 奖励物品对应 配置表里面的序号 index，
-- func_endlottery 结束 抽奖的回调
-- cfg 这组所有奖品的配置文件
-- box_pre_list 滚动的预制体物体队列（如果有就给，没有就不给，后面的名字必须给，没有不需要给nil）（是为了二次调用这个方法时，把第一次创建了的滚动的预制体物体传参进去，进行滚动）
-- 第一次调用此方法 box_pre_list可以不传直接传 box_prefb_name 预制体名字， count 多少个预制体， box_pre_parent预制体队列的父节点， 调用后 队列一直匀速滚动
--	这样调用第一次 会返回一个 tab 里面有一个box_pre_list队列和一个 结束匀速运动 到加速的抽奖方法
-- 第二次调用时候 只需要award_data、func_endlottery、cfg以及第一次调用返回的那个滚动物体队列（box_pre_list）
function C:X_Scroll(award_data,func_endlottery,cfg,box_pre_list,box_prefb_name,count,box_pre_parent)
	local runTimer
	local delayTimer

	local bk_list = {}
	local my_func = {}
	local is_first=true

	if type(box_pre_list) == "table" then
		bk_list = box_pre_list
		is_first = false
	else
		box_pre_parent = count
		count = box_prefb_name
		box_prefb_name = box_pre_list

		for i = 1, count do
			local pre = {}
			pre.obj = newObject(box_prefb_name, box_pre_parent.transform)
			function pre:setIndex(my_index) 
				local ui_table = {}
				self.index = my_index
				LuaHelper.GeneratingVar(self.obj.transform, ui_table)
				if  ui_table.icon_img and cfg[my_index].icon then
					ui_table.icon_img.sprite = GetTexture(cfg[my_index].icon)
				end
				if ui_table.name_txt and cfg[my_index].dec then
					ui_table.name_txt.text = string.format("%s", cfg[my_index].dec)
				end
				if ui_table.num_txt and cfg[my_index].num then
					ui_table.num_txt.text = string.format("%s", StringHelper.ToCash(cfg[my_index].num))
				end
			end
			function pre:getIndex() 
				return self.index
			end
			bk_list[#bk_list + 1] = pre
			pre:setIndex(i)
		end
	end
	local boxPanel = bk_list[1].obj
	local box_width = boxPanel.gameObject.transform.rect.width
	--box_width = 215
	local curPos = 0
	if not count then
		count=#bk_list
	end
	local returnPos = -(count-1)/2 * box_width
	my_func.RefreshScrollPos = function(diff)
		diff = diff or 0
		for i = 1, #bk_list do
			local b = bk_list[i].obj
	
			local index = i - (count-1)/2
			b.gameObject.transform.localPosition = Vector3.New(index * box_width + diff, 0, 0)
		end
		curPos = bk_list[(count-1)/2]:getIndex()
	end

	if is_first then
		my_func.RefreshScrollPos()
	else
		curPos = bk_list[(count-1)/2]:getIndex()
	end

	local award_tick = 0.1
	local timeout = 3
	
	local t1 = 1    --1阶段的时间
	local t2 = 3    --2阶段的时间
	local v2 = 4000 --2阶段的速度（匀速）
	local loop_count3 = 2 -- 3阶段的循环次数
	-- 长度 
	local total_count = #cfg
	-- 获取代码运行时间
	local last_tick = os.clock()

	local a1 = v2 / t1   --  4000/1
	local a3 = 0
	local cur_time = 0
	local cur_speed = 0
	if is_first then
		cur_speed = 300
		v2 = 400 
		a1 = v2 / t1
	end

	my_func.lottery = function(award)
		award_data = award
		cur_speed = 400
		a1 = 4000
		v2 = 4000
	end
	my_func.looping = function()
		cur_time = cur_time
	end
	my_func.out_lottery = function()
		if bk_list then
			bk_list=nil
		end
		if delayTimer then
			delayTimer:Stop()
			delayTimer = nil
		end
		if runTimer then
			runTimer:Stop()
			runTimer = nil
		end
		return
	end

	runTimer = Timer.New(function()
		local cur_tick = os.clock()

		--已经运行的时间
		local dt = cur_tick - last_tick
		--local dt = 0.016
		
		local s = 0

		if cur_time < t1 then
			-- 第一阶段 匀加速
			s = cur_speed * dt + 0.5 * a1 * dt * dt
			cur_speed = cur_speed + a1 * dt
			if cur_speed > v2 then
				cur_speed = v2
			end
		elseif cur_time < t2 then
			-- 第二阶段 匀速
			cur_speed = v2	
			s = cur_speed * dt
		else
			-- 第三阶段 匀加速
			if a3 == 0 then
				s = cur_speed * dt
			else
				s = cur_speed * dt + 0.5 * a3 * dt * dt
				cur_speed = cur_speed + a3 * dt
				if cur_speed <= 0 then
					print("end a3")
					cur_speed = 0
					a3 = 0
					--dump(bk_list,"<color=red>----sssssssssssssssssss-----</color>")
					if runTimer then
						runTimer:Stop()
						runTimer = nil
					end
				
					delayTimer = Timer.New(function()
						if delayTimer then
							delayTimer:Stop()
							delayTimer = nil
						end
						if runTimer then
							runTimer:Stop()
							runTimer = nil
						end
						if  func_endlottery() then
							func_endlottery()
						end
					end, 1, -1, nil, true)
					
					delayTimer:Start()
				end
			end
		end

		if not award_data and is_first then
			my_func.looping()
		else
			cur_time = cur_time + dt
		end
		
		for i = 1, #bk_list do
			local b = bk_list[i].obj
			local x = b.gameObject.transform.localPosition.x - s
			b.gameObject.transform.localPosition = Vector3.New(x, 0, 0)
		end


		--self.returnPos   结束位置
		local first = bk_list[1] 		
		if bk_list[1].obj.gameObject.transform.localPosition.x <= returnPos then
			local diff = math.abs(returnPos - bk_list[1].obj.gameObject.transform.localPosition.x)
			local first = table.remove(bk_list, 1)
			table.insert(bk_list, first)

			-- for i = 1, #bk_list do
			-- 	local b = bk_list[i]
			-- 	print(b:getIndex())
			-- end

			local new_first_index = bk_list[1]:getIndex()
			local idx = new_first_index + 8
			if idx > total_count then
				idx = idx - total_count
			end

			first:setIndex(idx)

			my_func.RefreshScrollPos(-diff)
			if  award_data then
				if cur_time >= t2  then
					if a3 == 0 then
						local need_s = 0
						local dis = 0
						local endPos = award_data.index
						if endPos >= curPos then
							dis = endPos - curPos
						else
							dis = total_count - curPos + endPos
						end
						local half = math.ceil(total_count / 2)
						if dis <= half then
							need_s = (loop_count3 * total_count + dis) * box_width - diff
						else
							need_s = (loop_count3 * total_count + dis) * box_width - diff
							--need_s = dis * box_width - diff
						end
			
						a3 = -cur_speed * cur_speed / (2 * need_s)
					end
				end		
			end
		end
		last_tick = cur_tick
	end, 0.016, -1, nil, true)

	runTimer:Start()

	local tab = {}
	tab.bk_list = bk_list
	if not award_data and is_first then
		tab.lottery_start = function (award)
			my_func.lottery(award)
			--dump("<color=red>----sssssssssssssssss-----</color>")
		end
		tab.Exit=function ()
			my_func.out_lottery()
		end
	end
	return tab
end

function C:BeginLottery()
    if self.fist_tab.lottery_start then
		--dump(self.data,"<color=red>----first-----</color>")
		self.fist_tab.lottery_start(self.data)
		self.fist_tab.lottery_start = nil
		self.lottery_btn.gameObject:SetActive(false)
		self.gray_btn.gameObject:SetActive(true)
		self.back_btn.enabled=false
	else
		--dump(self.data,"<color=red>----not_first-----</color>")
		local tab =	self:X_Scroll(self.data,function() 
			self:EndLottery() 
		end,self.config,self.turn_list)
		self.turn_list = tab.bk_list
		self.lottery_btn.gameObject:SetActive(false)
		self.gray_btn.gameObject:SetActive(true)
		self.back_btn.enabled=false
	end
	self.key_num_txt.text=self.key_num_txt.text-1
end

function C:EndLottery()
	self:show_asset_change()
	self:RefreshUI()
	self.back_btn.enabled=true
end

function C:show_asset_change()
	self.lottery_btn.gameObject:SetActive(true)
	self.gray_btn.gameObject:SetActive(false)
	if self.is_vip_creat then
		VIPManager.is_waite(false)
		local data=VIPManager.get_data()
		Event.Brocast("on_player_hb_limit_convert",data.other,data.data)
		self.is_vip_creat=false
	end
	if self.wait_award_data then
		dump(self.wait_award_data,"<color=red>----资产数据-----</color>")
		Event.Brocast("AssetGet", self.wait_award_data)
	end
	self.wait_award_data = nil

	-- 广播
	local data = {}
	data.player_name = MainModel.UserInfo.name
	data.ext_data = {}
	if self.config and self.data.index and self.config[self.data.index] then
		if self.config[self.data.index].asset_type then
			data.ext_data[1] = StringHelper.ToCash( self.config[self.data.index].num ) .. self.config[self.data.index].dec
		else
			data.ext_data[1] = self.config[self.data.index].dec

			-- 获得实物奖励的提示
			local string1 = "实物奖励请关注公众号《"..Global_GZH.."》联系在线客服领取。"
			local pre = HintCopyPanel.Create({desc=string1, isQQ=false,copy_value = Global_GZH})
			pre:SetCopyBtnText("复制公众号")

		end
		Event.Brocast("cjdb_add_fake_data", data)
	end
end

function C:OnAssetChange(data)
	if data.change_type == "hb_limit_convert" then
		self.after_lottery_func = data
		VIPManager.is_waite(true)
		self.is_vip_creat=true
		return
	end
end

function C:on_box_exchange_response(_,data)
	dump(data,"<color=red>----------抽奖数据-----------</color>")
	if data.result == 0 and (data.id == 94 or data.id == 95) then
		self.data.index = nil
		for i,v in ipairs(self.config) do
			if v.real_award_id == data.award_id[1] then
				self.data.index = i
				break
			end
		end
		if self.data.index then
			if self.config[self.data.index].asset_type then
				self.wait_award_data = {data = {{asset_type = self.config[self.data.index].asset_type, value = self.config[self.data.index].num}}, change_type = "box_exchange"}
			end

			self:BeginLottery()
		end
	else
		HintPanel.ErrorMsg(data.result)
	end
end