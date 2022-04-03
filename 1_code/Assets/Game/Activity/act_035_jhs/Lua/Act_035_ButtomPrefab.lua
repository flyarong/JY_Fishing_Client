-- 创建时间:2020-10-30
-- Panel:Act_035_ButtomPrefab
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

Act_035_ButtomPrefab = basefunc.class()
local C = Act_035_ButtomPrefab
C.name = "Act_035_ButtomPrefab"

local M = Act_035_JHSManager



function C.Create(parent, index, id, infor, parentPanel)
	return C.New(parent, index, id, infor, parentPanel)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["main_change_gift_bag_data_msg"] = basefunc.handler(self,self.main_change_gift_bag_data_msg) --礼包数据改变
    self.lister["main_query_gift_bag_data_msg"] = basefunc.handler(self,self.main_change_gift_bag_data_msg) --查询数据改变
    self.lister["finish_gift_shop"] = basefunc.handler(self,self.on_finish_gift_shop) --完成礼包购买
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

function C:ctor(parent, index, id, infor, parentPanel)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.infor = infor
	self.parentPanel = parentPanel
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.index = index or 1
	self.id = id 
	self.gift_id = self.infor.shop_id
	dump(self.gift_id)
	-- self.gift_id = {88,89,10045}

	self.get_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:BuyShop()
    end)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	Network.SendRequest("query_gift_bag_status",{gift_bag_id = self.gift_id[2]})
	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshTime()
	self:GetCurInforByIndex()
	self:RefreshBtn()
end


function C:RefreshBtn()
	self.get2.gameObject:SetActive(false)

	if not MainModel.IsCanBuyGiftByID(self.gift_id[1]) then
		self.get_txt.text = "再次购买"
		if not M.IsCanGetGift(self.gift_id) then
			self.get2.gameObject:SetActive(true)
			self.djs_txt.text = "00:00"
		end
	end		
end


function C:GetCurInforByIndex()
	self.zs_txt.text = self.infor.ten_min[1]
end


function C:RefreshTime()
	if MainModel.IsCanBuyGiftByID(self.gift_id[2]) then
		self.mb_x = MainModel.GetGiftEndTimeByID(self.gift_id[2])
		self:StartTimer()
	end
end

function C:StartTimer()

	local func = function ()
		if self.mb_x and IsEquals(self.gameObject) then
			if os.time() >= self.mb_x then
				self.djs_txt.text = "00:00"
				self:StopTimer()
			else
				local cha_x = self.mb_x - os.time()
				self.djs_txt.text =self:ShowTime(cha_x)
			end
		end
	end
	func()
	self:StopTimer()
	self.main_time = Timer.New(function ()
		func()
	end,1,-1) 
	self.main_time:Start()
	func()
end


function C:StopTimer()

	if self.main_time then
		self.main_time:Stop()
		self.main_time = nil
	end
end


function C:BuyShop()

	local index = M.GetCanGetGiftIndex(self.gift_id)
	if not index then

		return
	end
	local shopid = self.gift_id[index]
	dump(shopid,"<color=red>===========================</color>")

    local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
  
    if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
        ServiceGzhPrefab.Create({desc="请前往公众号获取"})
    else
        PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
    end
end

-- 
function C:main_change_gift_bag_data_msg(id)
	dump(id,"<color=yellow>6666666666666666666666</color>")
	dump(self.gift_id)
	if id == self.gift_id[2] then
		self.parentPanel:CreateCenterPrefab(self.id)
		self:RefreshBtn()
		-- 倒计时
		self:RefreshTime()
	end
end
function C:on_finish_gift_shop(data)
	if data == self.gift_id[1] or data == self.gift_id[3] then
		MainModel.UserInfo.GiftShopStatus[self.gift_id[2]].status = 1
		MainModel.UserInfo.GiftShopStatus[ data ].status = 0
	end
	if data == self.gift_id[2] then
		MainModel.UserInfo.GiftShopStatus[ self.gift_id[3] ].status = 0
	end
	self.parentPanel:CreateCenterPrefab(self.id)
	self:RefreshBtn() 
end

function C:ShowTime(second)

    if not second or second < 0 then
        return "0秒"
    end
    local timeDay = math.floor(second/86400)
    local timeHour = math.fmod(math.floor(second/3600), 24)
    local timeMinute = math.fmod(math.floor(second/60), 60)
    local timeSecond = math.fmod(second, 60)
    if timeDay > 0 then
        return string.format("%d天%02d:%02d:%02d", timeDay, timeHour, timeMinute, timeSecond)
    elseif timeHour > 0 then
        return string.format("%02d:%02d", timeHour, timeMinute, timeSecond)
    elseif timeMinute > 0 then
        return string.format("%02d:%02d", timeMinute, timeSecond)
    else
        return string.format("%02d:%02d",0, timeSecond)
    end
end