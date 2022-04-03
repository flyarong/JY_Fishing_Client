-- 创建时间:2019-05-16
-- Panel:New Lua
local basefunc = require "Game/Common/basefunc"
EliminateMoneyPanel = basefunc.class()
--local Money_Btn=EliminateButtonPrefab
local C = EliminateMoneyPanel
C.name = "EliminateMoneyPanel"
local jiaqian=
{
	-- [1]=500,
	-- [2]=1000,
	-- [3]=2000,
	-- [4]=4000,
	-- [5]=8000,
	-- [6]=16000,
	-- [7]=32000,
	-- [8]=64000,
	-- [9]=128000,
	-- [10]=256000,
	-- [11]=512000,
    -- [12]=1024000,
	-- [13]=2048000,

}
local instance
function C.Create()
	if not instance then
		instance = C.New()
	else
		instance:MyRefresh()
	end
	return instance
end
function C:MakeLister()
	self.lister={}
	self.lister["view_eliminate_lottery_start"]=basefunc.handler(self,self.eliminate_lottery_start)
	self.lister["view_lottery_end"]= basefunc.handler(self,self.eliminate_lottery_end)
	self.lister["view_lottery_end_lucky"]=basefunc.handler(self,self.eliminate_lottery_end)
	self.lister["PayPanelClosed"]=basefunc.handler(self,self.OnClosePayPanel)	
	self.lister["eliminate_quit_game"]=basefunc.handler(self,self.Close)	
	self.lister["model_lottery_error"]=basefunc.handler(self,self.eliminate_model_lottery_error)
	self.lister["eliminate_Refresh_UserInfoGoldText"]=basefunc.handler(self,self.eliminate_Refresh_UserInfoGoldText)	
	self.lister["view_lottery_error"]=basefunc.handler(self,self.view_lottery_error) 
	self.lister["AssetChange"] = basefunc.handler(self, self.onAssetChange)
	self.lister["view_lottery_start_yxcard"] = basefunc.handler(self, self.view_lottery_start_yxcard)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

--开奖错误1
function C:eliminate_model_lottery_error()
    self.Addbutton.gameObject:SetActive(true)
	self.Redubutton.gameObject:SetActive(true)
	if self.index==1 then
		self.Redubutton.gameObject:SetActive(false)
	end
    if self.index==#self.jiaqian then
		self.Addbutton.gameObject:SetActive(false)
	end

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

function C:Close()
	self:MyExit()
end

function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/GUIRoot").transform
	--冲金鸡有水果消消乐爬塔,此界面布局不一样
	if self:CheckIsCjj() then
		C.name = "EliminateMoneyPanel_cjj"
	end
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.gameObject.name = "EliminateMoneyPanel"
	self.jiaqian=jiaqian
	self.index=self:GetUserBet()
    self.GoldText=self.gameObject.transform:Find("GoldInfo/GoldText"):GetComponent("Text")
    self.jiaqianText=self.gameObject.transform:Find("AddMoney/Text"):GetComponent("Text")
	self.ps=self.gameObject.transform:Find("AddMoney/shanguang"):GetComponent("ParticleSystem")	
	LuaHelper.GeneratingVar(self.transform, self)
	self:Initjiaqian()
	self:eliminate_Refresh_UserInfoGoldText()
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.MaxIndex = #self.jiaqian
	if self.index >= self.MaxIndex then 
        self.index = self.MaxIndex
    end  
	if self.index==1 then
		self.Redubutton.gameObject:SetActive(false)
	end
    if self.index==self.MaxIndex then
		self.Addbutton.gameObject:SetActive(false)
	end	
end
--根据用户的金币数量获得一个初始档位
function C:GetUserBet()
	local data=EliminateModel.xiaoxiaole_defen_cfg.auto
	local qx_max = self.MaxIndex
    for i=#data,1,-1 do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="xxl_bet_".. i, is_on_hint=true}, "CheckCondition")
        if not a or b then
            qx_max = i
            break
        end 
    end
    for i = qx_max,1,-1 do
        if not data[i].min or MainModel.GetMiniGameCoinAndJingBiAllNum() >= data[i].min then 
            return i
        end 
    end
    return 1
end

function C:onAssetChange(data)
	if table_is_null(EliminateModel.data) or EliminateModel.data.status_lottery == EliminateModel.status_lottery.run then return end
	if data.change_type and data.change_type ~= "xxl_game_award" and data.change_type ~= "task_award_no_show" then
		self:eliminate_Refresh_UserInfoGoldText()
	end
end
function C:eliminate_Refresh_UserInfoGoldText()
	if EliminateModel.data.status_lottery ~= EliminateModel.status_lottery.run then
	   self.GoldText.text=StringHelper.ToCash(MainModel.UserInfo.jing_bi)--刷新金币显示
	   self.coin_txt.text = StringHelper.ToCash(GameItemModel.GetItemCount("prop_tiny_game_coin"))--刷新小游戏币显示
	end
end

function C:InitUI()
    local gold=0
	local betdata=EliminateModel.GetBet()
	self.childs={}
	for i = 1, 5 do
	    local child= EliminateButtonPrefab.Create(i,self.jiaqian[1]/5)
		gold=gold+self.jiaqian[1]/5		
		self.childs[i]=child
	end		
	self.gameObject.transform:Find("AddMoney/Text"):GetComponent("Text").text=gold
	local addbutton=self.gameObject.transform:Find("AddMoney/AddButton"):GetComponent("Button")
	self.Addbutton=addbutton
	local redubutton=self.gameObject.transform:Find("AddMoney/ReduButton"):GetComponent("Button")
	self.Redubutton=redubutton
	local openpaypanel=self.gameObject.transform:Find("GoldInfo/OpenPayPanel"):GetComponent("Button")
	local openpaypanel_=self.gameObject.transform:Find("CoinInfo/OpenPayPanel_"):GetComponent("Button")
	--self.Redubutton.gameObject:SetActive(false)
	self.jiaqianText.text=self.jiaqian[self.index]
	Event.Brocast("EliminateMoneyPanel_change_bet_msg",self.jiaqian[self.index])
	EliminateModel.SetBet({
		[1]=self.jiaqian[1]/5,
		[2]=self.jiaqian[1]/5,
		[3]=self.jiaqian[1]/5,
		[4]=self.jiaqian[1]/5,
		[5]=self.jiaqian[1]/5,
	})
	for i = 1, 5 do
		self.childs[i]:eliminate_change_yazhu_one(nil,self.jiaqian[self.index]/5)
	end
	EventTriggerListener.Get(addbutton.gameObject).onClick = basefunc.handler(self, self.OnAddOnClick)
	EventTriggerListener.Get(redubutton.gameObject).onClick = basefunc.handler(self, self.OnReduOnClick)
	EventTriggerListener.Get(openpaypanel.gameObject).onClick = basefunc.handler(self, self.OpenPayPanel)
	EventTriggerListener.Get(openpaypanel_.gameObject).onClick = basefunc.handler(self, self.OpenPayPanel)
	EliminateClearPanel.Create()
end
function C:Initjiaqian()
	for key, value in pairs(EliminateModel.xiaoxiaole_defen_cfg.yazhu) do  
		self.jiaqian[value.dw]=value.jb	
	end 
end
--增加押注
function C:OnAddOnClick()
	if (self.index+1) <= self.MaxIndex  then		
		self.index=self.index+1
		self.Redubutton.gameObject:SetActive(true)
		ExtendSoundManager.PlaySound(audio_config.xxl.bgm_xxl_jiazhu.audio_name)
		self.yazhu=self.jiaqian[self.index]

        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="xxl_bet_".. self.index}, "CheckCondition")
        if a and not b then
			self.index=self.index-1	
            return
        end
	    if MainModel.GetMiniGameCoinAndJingBiAllNum() <	self.yazhu then
	    	dump(MainModel.GetMiniGameCoinAndJingBiAllNum(),"<color>+++++++++++++++++++all+++++++++++++</color>")
	    	dump(self.yazhu,"<color>+++++++++++++++++++self.yazhu+++++++++++++</color>")
			self.index=self.index-1
			C:OpenPayPanel()		
			return 
	    end
	    self.jiaqianText.text=self.jiaqian[self.index]
	    Event.Brocast("EliminateMoneyPanel_change_bet_msg",self.jiaqian[self.index])
	    for i = 1, 5 do
		 self.childs[i]:eliminate_change_yazhu_one(nil,self.jiaqian[self.index]/5)
	    end
	    self.ps:Stop()
	    self.ps:Play()		
	end
	if self.index ==self.MaxIndex then
		self.Addbutton.gameObject:SetActive(false)
	end
end
--减少押注
function C:OnReduOnClick()
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="cpl_cjj", is_on_hint = true}, "CheckCondition")
    if a and b then
		Event.Brocast("sgxxl_guide_check")
	end
	if self.index-1==1 then
		self.Redubutton.gameObject:SetActive(false)
	end
	if (self.index-1)>0 then
		self.Addbutton.gameObject:SetActive(true)
        ExtendSoundManager.PlaySound(audio_config.xxl.bgm_xxl_jianzhu.audio_name)
		self.index=self.index-1
		self.ps:Stop()
	    self.ps:Play()
	    self.yazhu=self.jiaqian[self.index]
	    self.jiaqianText.text=self.jiaqian[self.index]
	    Event.Brocast("EliminateMoneyPanel_change_bet_msg",self.jiaqian[self.index])
	--Event.Brocast("eliminate_change_yazhu_one","eliminate_change_yazhu_one",self.jiaqian[self.index]/5)
	    for i = 1, 5 do
		   self.childs[i]:eliminate_change_yazhu_one(nil,self.jiaqian[self.index]/5)
	    end
	else
 
	end
end
--开奖状态下禁止按钮
function C:eliminate_lottery_start()
	self.Addbutton.gameObject:SetActive(false)
	self.Redubutton.gameObject:SetActive(false)
	dump(self.jiaqian[self.index],"<color>++++++++++++加钱+++++++++++</color>")
	--local data = MainModel.GetMiniGameCurCoinAndJingBiTXT(self.jiaqian[self.index])
	--self.GoldText.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi-self.jiaqian[self.index])
	self.GoldText.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)--刷新金币显示
	self.coin_txt.text = StringHelper.ToCash(GameItemModel.GetItemCount("prop_tiny_game_coin"))--刷新小游戏币显示
end
--开奖结束恢复按钮
function C:eliminate_lottery_end()
	if not EliminateModel.GetAuto() then	  	
     self.Addbutton.gameObject:SetActive(true)
	 self.Redubutton.gameObject:SetActive(true)
	else
	   self.yazhu=self.jiaqian[self.index]
	   if  self.yazhu > MainModel.GetMiniGameCoinAndJingBiAllNum() then
		--self:OnClosePayPanel()
	   end
	--	self.yazhu=self.jiaqian[ self.index]
	--  if MainModel.UserInfo.jing_bi<self.yazhu then
	-- 	for i = #self.jiaqian,1 ,-1 do
	-- 		if  self.jiaqian[i] < MainModel.UserInfo.jing_bi then
	-- 		  self.index=i
	-- 		  break
	-- 		end
	-- 	end
	-- 	if self.index<1 then
	-- 	  self.index =1
	-- 	end
	-- 	self.yazhu=self.jiaqian[self.index]
	-- 	self.jiaqianText.text=self.jiaqian[self.index]
	-- 	for i = 1, 5 do
	-- 		self.childs[i]:eliminate_change_yazhu_one(_,self.jiaqian[self.index]/5)
	-- 	end
	--  end
	end
	
	if self.index==1  then
		self.Redubutton.gameObject:SetActive(false)
	end
    if self.index==self.MaxIndex then
		self.Addbutton.gameObject:SetActive(false)
	end

end
--开奖错误
function C:view_lottery_error()
	self.Addbutton.gameObject:SetActive(true)
	self.Redubutton.gameObject:SetActive(true)
	self.yazhu=self.jiaqian[self.index]
	if  self.yazhu > MainModel.GetMiniGameCoinAndJingBiAllNum() then
    -- for i = #self.jiaqian,1 ,-1 do
	-- 	if  self.jiaqian[i] < MainModel.UserInfo.jing_bi then
	-- 	  self.index=i
	-- 	  break
	-- 	end
	-- end
	   --self:OnClosePayPanel()
	end
	if self.index<1 then
	  self.index =1
	end
	self.yazhu=self.jiaqian[self.index]
	self.jiaqianText.text=self.jiaqian[self.index]
    for i = 1, 5 do
		self.childs[i]:eliminate_change_yazhu_one(nil,self.jiaqian[self.index]/5)
	end
	if self.index==1 then
		self.Redubutton.gameObject:SetActive(false)
	end
    if self.index==self.MaxIndex then
		self.Addbutton.gameObject:SetActive(false)
	end
	self.GoldText.text= StringHelper.ToCash(MainModel.UserInfo.jing_bi)--刷新金币显示
	self.coin_txt.text = StringHelper.ToCash(GameItemModel.GetItemCount("prop_tiny_game_coin"))--刷新小游戏币显示
end
--打开商城
function C:OpenPayPanel()
	GameButtonManager.RunFun({ gotoui="sys_jjj"}, "CheckAndRunJJJ", function ()
        Event.Brocast("show_gift_panel")
    end)
end
--当商城关闭时候
function C:OnClosePayPanel()
	self:eliminate_Refresh_UserInfoGoldText()
end

function C:CheckIsCjj()
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "cpl_cjj", is_on_hint = true}, "CheckCondition")
	if a and b then
		return true
	end
	return false
end

--用游戏卡抽奖时
function C:view_lottery_start_yxcard()
	local jiaqian_card = EliminateModel.data.bet[1] * 5
	if self.jiaqian[self.index] ~= jiaqian_card then
		for k,v in ipairs(self.jiaqian) do
			if v == jiaqian_card then
				self.index = k
			end
		end
	end
	self.jiaqianText.text = self.jiaqian[self.index]
	for i = 1, 5 do
		self.childs[i]:eliminate_change_yazhu_one(nil, self.jiaqian[self.index]/5)
	end
end