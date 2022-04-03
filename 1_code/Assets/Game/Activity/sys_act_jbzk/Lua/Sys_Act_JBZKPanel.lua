-- 创建时间:2021-02-08
-- Panel:Sys_Act_JBZKPanel
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

Sys_Act_JBZKPanel = basefunc.class()
local C = Sys_Act_JBZKPanel
C.name = "Sys_Act_JBZKPanel"
local M = Sys_Act_JBZKManager
local shopId = 10496
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
    self.lister["watch_ad_jbzk_response"] = basefunc.handler(self,self.on_watch_ad_jsbk_response)
    self.lister["award_jbzk_response"] = basefunc.handler(self,self.on_award_jbzk_response)
    self.lister["query_jbzk_info_response"]=basefunc.handler(self,self.on_query_jbzk_info_response)
	self.lister["AssetChange"] = basefunc.handler(self, self.on_asset_change)


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

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.config=Sys_Act_JBZKManager.GetJbzkCfg()
	dump(self.config,"获取金币周卡配置表：  ")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.OnCloseBtnClick)
	EventTriggerListener.Get(self.video_btn.gameObject).onClick = basefunc.handler(self, self.OnVideoBtnClick)
	EventTriggerListener.Get(self.get_btn.gameObject).onClick = basefunc.handler(self, self.OnGetBtnClick)
	EventTriggerListener.Get(self.buyshop_btn.gameObject).onClick = basefunc.handler(self, self.OnShopClick)


    --是否已经看了广告解锁
    --累计领取的次数
    --今日是否已经领取(与上次领取时间是否是同一天)
	self.isunlock,self.gotday,self.isgot =Sys_Act_JBZKManager.GetJbzkMdataInfo()	 
	-- dump(self.isunlock,"是否已解锁金币周卡：   ")
	if self.isgot then
		self.nowDay=self.gotday;
	else
		self.nowDay=self.gotday+1  --今日第几天
	end
	

    self.platformType= Sys_Act_JBZKManager.GetPlatformInfo()
    -- if  self.platformType.unlockType==0 then
    -- 	print("非冲金鸡平台")
    -- else
    -- 	print("当前是冲金鸡平台")
    -- end

	self.video_btn.gameObject:SetActive(not self.isunlock and self.platformType.unlockType~=0)
	self.buyshop_btn.gameObject:SetActive(not self.isunlock and self.platformType.unlockType==0)
	self.get_btn.gameObject:SetActive(self.isunlock and not self.isgot)
	self.haveGot_img.gameObject:SetActive(self.isunlock and self.isgot)

	self.dayItemMap={}

	local dayItems = {self.dayItem_1,self.dayItem_2,self.dayItem_3,self.dayItem_4,self.dayItem_5,self.dayItem_6,self.dayItem_7}
	for i,v in ipairs(dayItems) do
		
		local itemTab = {}
		LuaHelper.GeneratingVar(v.transform,itemTab)
		self:RefreshOnDayItem(itemTab,i,self.nowDay)
		self.dayItemMap[i]=itemTab
		EventTriggerListener.Get(v.transform.gameObject).onClick = basefunc.handler(self, self.OnDayItemClcik)

	end
	-- dump(self.dayItemMap,"天数item数组：  ")
    local day,hour,min=Sys_Act_JBZKManager.GetCurRemainTime()
    self.remainDay=day
	if day==0 then
		self.restTime_txt.text="剩余时间：".. hour .. "小时".. min .."分"
	else
		self.restTime_txt.text="剩余时间：".. day .. "天".. hour .."小时"
	end
	self:MyRefresh()
end

function C:OnDayItemClcik()
	self.isunlock=Sys_Act_JBZKManager.GetJbzkMdataInfo()	 
	if not self.isunlock then
		LittleTips.Create("激活金币周卡后可领取")
	end
end
function C:RefreshOnDayItem(itemTab,cofigday,compareDay)
	-- body
	itemTab.value_txt.text=self.config[cofigday].info
	itemTab.icon_img.sprite=GetTexture(self.config[cofigday].img)
	if self.isgot then
		itemTab.bg_today.gameObject:SetActive(false)
		itemTab.bg_normal.gameObject:SetActive(true)
		itemTab.got_flag.gameObject:SetActive(cofigday<=compareDay)
		-- dump(cofigday<=compareDay,"每天显示状态：  "..cofigday)
	else
		itemTab.bg_today.gameObject:SetActive(cofigday==self.nowDay)
		itemTab.bg_normal.gameObject:SetActive(cofigday~=self.nowDay)
		itemTab.got_flag.gameObject:SetActive(cofigday<compareDay)

	end
	
end
function C:MyRefresh()
end

function C:OnCloseBtnClick()
	-- body
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)

	self:MyExit()
end

function C: on_watch_ad_jsbk_response(_,data)
 	-- body
 	if data.result ~= 0 then
		HintPanel.ErrorMsg(data.result)
	else
		self.video_btn.gameObject:SetActive(false)
		self.buyshop_btn.gameObject:SetActive(false)
		self.get_btn.gameObject:SetActive(true)
		Network.SendRequest("query_jbzk_info")
		Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
	end
 end 
function C:OnVideoBtnClick()
	-- body
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	print("点击观看广告按钮！")
	local callback = function ()
		-- body
		Network.SendRequest("watch_ad_jbzk")
	end
	if SYSQXManager.IsNeedWatchAD() then
		AdvertisingManager.RandPlay("jbzk", nil, function ()
				callback()
			end)
	else
		callback()
	end
end
function C:OnGetBtnClick()
	-- body 
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	Network.SendRequest("award_jbzk")   --通知服务器获取奖励
	self.isgot=true
	self.haveGot_img.gameObject:SetActive(self.isgot)
	self.get_btn.gameObject:SetActive(not self.isgot)
	self:RefreshOnDayItem(self.dayItemMap[self.nowDay],self.nowDay,self.nowDay)
end

function C: on_award_jbzk_response(_,data)
	-- body
	if data and data.result ~= 0 then
		HintPanel.ErrorMsg(data.result)
	else
		self.isgot=true
		self.haveGot_img.gameObject:SetActive(self.isgot)
		self.get_btn.gameObject:SetActive(not self.isgot)
		self:RefreshOnDayItem(self.dayItemMap[self.nowDay],self.nowDay,self.nowDay)

 		Network.SendRequest("query_jbzk_info") 
 		--最后一天领取后关闭当前弹窗
 		if self.remainDay==0 then
			self:MyExit()
		end

	end
end

local triggerGetInfo=false
function C:on_query_jbzk_info_response(_,data)
	-- body

	if not triggerGetInfo then
		return
	end
	if data and data.can_award==1 then
		self.video_btn.gameObject:SetActive(false)
		self.buyshop_btn.gameObject:SetActive(false)
		self.get_btn.gameObject:SetActive(true)
		triggerGetInfo=false
		return
	end
	 
	  dump(data,"<color=red>支付成功后 data.can_award数据更新！！！！</color>")
end
function C:OnShopClick()
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请关注“%s”公众号领取0.01元超值礼包"})
	else

		local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopId)
		PayTypePopPrefab.Create(gift_config.id, "￥" .. (gift_config.price / 100),
			function (result)
		 
			end)
	end
end

function C:on_asset_change(_data)
	-- dump(_data,"<color=white>+++++on_asset_change+++++</color>")
	if _data.change_type and (string.find(_data.change_type, "jbzk_activity", 1)) then
		if table_is_null(_data.data) then
			return 
		end
         Event.Brocast("AssetGet", _data)
		--self:TryToShow()
    end
    if _data.change_type and _data.change_type=="buy_gift_bag_10496" then
    		-- dump(111,"<color=yellow>购买成功！！！再次获取数据！！！！</color>")
			triggerGetInfo=true
 			Network.SendRequest("query_jbzk_info")
    end
end
