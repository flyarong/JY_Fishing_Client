-- 创建时间:2020-11-25
-- Panel:JLSpringPanel
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

JLSpringPanel = basefunc.class()
local C = JLSpringPanel
C.name = "JLSpringPanel"
local M = FishFarmJlSpringManager

function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["have_on_fishbowl_lottery_info_msg"] = basefunc.handler(self, self.have_on_fishbowl_lottery_info_msg)
    self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)

end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:StopTime()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv1").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	--jing_bi
	self.jb_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
	end)

	self.xx_btn.onClick:AddListener(function ()
		-- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		
	end)

	--饲料
	self.sl_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		FishFarmFeedPanel.Create()
	end)

	--规则
	self.gz_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
   		IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform, "IllustratePanel_New")
    end)

	--广告抽奖
	self.ad_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if self.pt_infor then
        	if M.GetCDTime() ~= 0 then return end
        	dump("111111111111111111111111111")
    		--看广告
	   		if SYSQXManager.IsNeedWatchAD() and self.pt_infor.ad > 0 then
				AdvertisingManager.RandPlay("jlspring", nil, self:WatchAD())
			end 
		else
			HintPanel.ErrorMsg("广告抽奖次数为0") 
    	end	
	end)

	--免费抽奖
	self.mf_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if self.pt_infor then
        	if self.pt_infor.free == 0 then
				Network.SendRequest("fishbowl_lottery", {id = 1 ,type = 1, num = 1}, "请求数据", function (data)
					dump(data, "<color=red>---------mf-------</color>")
					if data.result == 0 then
						self:SetAwardData(data.ids,1)
					else
						--HintPanel.ErrorMsg(data.result)
						FishFarmNoCanCJPanel.Create(1, 1, self)
					end
				end)
			else
				--有无免费次数
				Network.SendRequest("fishbowl_lottery", {id = 1 ,type = 2, num = 1},"请求数据", function (data)
					dump(data)
					if data.result == 0 then
						self:SetAwardData(data.ids,1)
					else
						HintPanel.ErrorMsg(data.result)
					end
				end)
			end
    	end
	end)

	--普通10连抽
	self.ten1_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
   		Network.SendRequest("fishbowl_lottery", {id = 1 ,type = 1, num = 10}, "请求数据", function (data)
		dump(data, "<color=red>---------box_exchange-------</color>")
			if data.result == 0 then
				self:SetAwardData(data.ids,1)
			else
				--HintPanel.ErrorMsg(data.result)
				FishFarmNoCanCJPanel.Create(1, 10, self)
			end
		end)
    end)
	--高级单次抽奖
	self.dc_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
   		Network.SendRequest("fishbowl_lottery", {id = 2 ,type = 1, num = 1}, "请求数据", function (data)
		dump(data, "<color=red>---------fishbowl_lottery_单次-------</color>")
			if data.result == 0 then
				self:SetAwardData(data.ids,2)
			else
				--HintPanel.ErrorMsg(data.result)
				FishFarmNoCanCJPanel.Create(2, 1, self)
			end
		end)
    end)

	--高级10连抽
    self.ten_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
   		Network.SendRequest("fishbowl_lottery", {id = 2 ,type = 1 , num = 10}, "请求数据", function (data)
		dump(data, "<color=red>---------box_exchange-------</color>")
			if data.result == 0 then
				self:SetAwardData(data.ids,2)
			else
				--HintPanel.ErrorMsg(data.result)
				FishFarmNoCanCJPanel.Create(2, 10, self)
			end
		end)
    end)

    self.back_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
   		self:MyExit()
    end)

end

function C:InitUI()
	MainModel.SetGameBGScale(self.bg)
	Network.SendRequest("fishbowl_lottery_info")
end

function C:MyRefresh()

	self:RefreshAsset()
	--剩余抽奖次数
	self.symf_txt.text = GameItemModel.GetItemCount("prop_fishbowl_coin1") or 0
	self.sygj_txt.text = GameItemModel.GetItemCount("prop_fishbowl_coin2") or 0

	self.count =  M.GetNum()
	self.time_num = M.GetCDTime()
	if self.count > 0 then
		if self.time_num > 0 then
			self:StartTime()
		end
	end

	dump(self.pt_infor,"<color=red>pppppppppppppppppppp</color>")
	if self.pt_infor then
		if self.pt_infor.free > 0 then
			self.sy_txt.text = string.format("今日剩余免费次数1次")
		elseif self.pt_infor.ad > 0 then
			self.sy_txt.text = string.format("今日还可观看广告抽%s次", self.count)
		else
			self.sy_txt.text = "今日免费次数已全部使用"
		end

		if self.pt_infor.free == 0 and self.pt_infor.ad == 0 then
			self.ad_btn.gameObject:SetActive(false)
			self.mf_btn.gameObject:SetActive(true)
			self.root.gameObject:SetActive(true)
		elseif self.pt_infor.free == 0 and self.pt_infor.ad ~= 0 then
			self.mf_btn.gameObject:SetActive(false)
			self.ad_btn.gameObject:SetActive(true)
		else
			self.mf_txt.gameObject:SetActive(true)
			self.root.gameObject:SetActive(false)
			self.mf_txt.text = "免费抽奖"
		end
	end
end



function C:SetAwardData(list, _type)
	local _type = _type
	self.cur_award = {}
	self.cur_award.data = {}
	local hb = 0
	local jb = 0
	local jl_type = M.GetAwardType(_type)
	dump(jl_type)

	if _type == 1 then
		self.big_list = self.big_list_pt
	else
		self.big_list = self.big_list_gj
	end
	dump(self.big_list)
	if self.value_lottery and self.type_lottery then
		for i = 1, #list do
			local cfg = M.GetAwardConfigByAwardID(self.type_lottery[i])
			if cfg then
				if self.big_list then
					 for j,v in pairs(jl_type) do
					 	if jl_type[self.type_lottery[i]] >= self.big_list[1] then
							self.cur_award.data[i] = 
								{image=cfg.image, desc=cfg.name.."x"..self.value_lottery[i], 
									asset_type=cfg.item_key, value=self.value_lottery[i], big_award = 1,}
						else
							self.cur_award.data[i] = 
								{image=cfg.image, desc=cfg.name.."x"..self.value_lottery[i], 
									asset_type=cfg.item_key, value=self.value_lottery[i], big_award = 0,}

						end
					 end
				end
			end
		end
	end
	-- if #list > 1 then
	-- 	self.cur_award.tips = string.format("恭喜您在十连抽中共获得 %s金币 + %s福利券", StringHelper.ToCash(jb), StringHelper.ToCash(hb))
	-- end
	self:ShowAwardBrocast(_type)
end

function C:ShowAwardBrocast(_type)
	dump(self.cur_award,"<color=red>xxxxxxxxxxxxxxxxxxxxxxxxx</color>")
	if self.cur_award then
		if #self.cur_award.data == 1 then
			Event.Brocast("AssetGet", self.cur_award)
		else
			local pre = AssetsGet10Panel.Create(self.cur_award.data, function ()
				print("<color=red>确定</color>")
			end, true, function ()
				Network.SendRequest("fishbowl_lottery", {id = _type ,type = 1, num = 10}, "请求数据", function (data)
				if data.result == 0 then
					self:SetAwardData(data.ids, 1)
				else
					FishFarmNoCanCJPanel.Create(_type, 10, self)
				end
				end)
			end)
			pre.info_desc_txt.transform.localPosition = Vector3.New(0, -325, 0)
			pre.info_desc_txt.text = self.cur_award.tips
		end
		self.cur_award = nil
	end
	Network.SendRequest("fishbowl_lottery_info")
end

function C:WatchAD()
	dump("<color=red>进来了《，，，，，，，，，，，，，</color>")
        Network.SendRequest("fishbowl_lottery", {id = 1,type = 3 ,num = 1 ,}, "请求数据", function (data)
        	dump(data, "<color=white>fishbowl_lottery_广告</color>")
        	if data.result == 0 then
		        self:SetAwardData(data.ids)
        	end
        end)
end


function C:StartTime()
	self:StopTime()
	self.update_time = Timer.New(function ()
		self:UpdateUI(true)
	end, 1, -1)
	self.update_time:Start()
	self:UpdateUI()
end

function C:StopTime()
	if self.update_time then
		self.update_time:Stop()
		self.update_time = nil
	end
end
function C:UpdateUI(b)
	if b then
		self.time_num = self.time_num - 1
	end

	if self.time_num <= 0 then
		self:StopTime()
		self.down_txt.text = "广告抽奖"
		Network.SendRequest("fishbowl_lottery_info")
		return
	end

	local mm = math.floor(self.time_num / 60)
	local ss = self.time_num % 60
    self.down_txt.text = string.format("%02d", mm) .. ":" .. string.format("%02d", ss)
end


function C:have_on_fishbowl_lottery_info_msg()
	self.pt_infor =  M.GetCJTime().pt
	self.gj_infor =  M.GetCJTime().gj
	self:MyRefresh()
end


function C:RefreshAsset()
	self.jb_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	self.xx_txt.text = GameItemModel.GetItemCount("prop_fishbowl_stars")
	self.sl_txt.text = GameItemModel.GetItemCount("prop_fishbowl_feed")
end


function C:OnAssetChange(data)
	self.value_lottery = {}
	self.type_lottery = {}
	self.big_list_pt = M.GetBigAwardPTList()
	self.big_list_gj = M.GetBigAwardGJList()
	dump(self.big_list_pt,"<color=red>8888888888888888888888888888</color>")
	dump(self.big_list_gj,"<color=red>8888888888888888888888888888</color>")
	if data and data.data and data.change_type == "fishbowl_lottery" then
		for i,v in ipairs(data.data) do
			self.value_lottery[i] = v.value
			self.type_lottery[i] = v.asset_type
		end
	end
	self:RefreshAsset()
end