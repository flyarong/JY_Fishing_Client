-- 创建时间:2021-03-04
-- Panel:SYSLWGPBuyPanel
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

SYSLWGPBuyPanel = basefunc.class()
local C = SYSLWGPBuyPanel
C.name = "SYSLWGPBuyPanel"
local M = SYSLWGPManager

function C.Create(config)
	return C.New(config)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
	self.lister["refresh_Lwgp_buy_item_num"]=basefunc.handler(self,self.RefreshUI)
	self.lister["bet_lwgp_success"]=basefunc.handler(self,self.on_bet_lwgp_success)

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

function C:ctor(config)
	ExtPanel.ExtMsg(self)
	self.config = config
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.num = 0

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
	EventTriggerListener.Get(self.buy_btn.gameObject).onClick = basefunc.handler(self, self.OnBuyClick)
	EventTriggerListener.Get(self.delet_btn.gameObject).onClick = basefunc.handler(self, self.OnDeletClick)
	EventTriggerListener.Get(self.all_btn.gameObject).onClick = basefunc.handler(self, self.OnAllClick)
	EventTriggerListener.Get(self.add1_btn.gameObject).onClick = basefunc.handler(self, self.OnAdd1Click)
	EventTriggerListener.Get(self.add10_btn.gameObject).onClick = basefunc.handler(self, self.OnAdd10Click)
	
	self:MyRefresh()
end

function C:MyRefresh()
	for i=2,#self.config.award do
		self["award"..(i-1).."_txt"].text = self.config.award[i]
	end
	self.icon_img.sprite = GetTexture(self.config.goods_icon)
	if  M.GetLwgpBetItemData(self.config.id).bet_num>=1000 or M.GetJlbNum()<10 then
		self.num=0
	end
	self:RefreshUI()
end

function C:RefreshUI()
	self.name_txt.text=self.config.name
	self.have_txt.text = "拥有: " .. M.GetLwgpBetItemData(self.config.id).bet_num
	self.jlb_txt.text = M.GetJlbNum()
	--dump("拥有：  ", M.GetLwgpBetItemData(self.config.id).bet_num)
	--dump("jinb   ",M.GetJlbNum())

	self.need_txt.text = self.num * 10
	self.num_txt.text = self.num
end
function C:on_bet_lwgp_success()
	LittleTips.Create("购买成功！")
	dump("购买成功！！！！！！")
	self.name_txt.text=self.config.name
	self.have_txt.text = "拥有: " .. M.GetLwgpBetItemData(self.config.id).bet_num
	self.jlb_txt.text = M.GetJlbNum()
	--dump("拥有：  ", M.GetLwgpBetItemData(self.config.id).bet_num)
	--dump("jinb   ",M.GetJlbNum())
	self.num=0
	self.need_txt.text = self.num * 10
	self.num_txt.text = self.num
end
function C:OnBackClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:MyExit()
end

function C:OnBuyClick()
	if self.num<=0 then
		LittleTips.Create("上贡数量不能为0！")
		return
	end
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	NetMsgSendManager.SendMsgQueue("lwgp_bet",{game_id=1,bet_index=self.config.id,bet_num=self.num})
end

function C:OnDeletClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self.num = 0
	self:RefreshUI()
end

function C:OnAllClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local betNum=M.GetLwgpBetItemData(self.config.id).bet_num
	local restMoneyCanBet=math.floor(M.GetJlbNum() / 10)
	local maxCanBet=1000-betNum
	if maxCanBet<=restMoneyCanBet then
		self.num=maxCanBet
	else
		self.num=restMoneyCanBet
	end
	self:RefreshUI()
end

function C:OnAdd1Click()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local betNum=M.GetLwgpBetItemData(self.config.id).bet_num
	local restMoneyCanBet=math.floor(M.GetJlbNum() / 10)
	local maxCanBet=1000-betNum
	if betNum==1000 then
		self.num=0
		LittleTips.Create("购买已到最大值！")
	elseif restMoneyCanBet<1 then
		LittleTips.Create("金龙币不足购买更多")
		self.num=0
	elseif (self.num+1)>restMoneyCanBet then
		LittleTips.Create("金龙币不足购买更多")
	elseif self.num+betNum+1>1000 then
		LittleTips.Create("购买已到最大值！")
	else
		self.num=self.num+1
	end
	

	self:RefreshUI()
end

function C:OnAdd10Click()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local betNum=M.GetLwgpBetItemData(self.config.id).bet_num
	local restMoneyCanBet=math.floor(M.GetJlbNum() / 10)
	local maxCanBet=1000-betNum

	if betNum==1000 then
		self.num=0
		LittleTips.Create("购买已到最大值！")
	elseif restMoneyCanBet<10 then
		LittleTips.Create("金龙币不足购买更多")
		self.num=0
	elseif (self.num+10)>restMoneyCanBet then
		LittleTips.Create("金龙币不足购买更多")
	elseif self.num+betNum+10>1000 then
		LittleTips.Create("购买已到最大值！")
	else
		self.num=self.num+10
	end
	self:RefreshUI()
end