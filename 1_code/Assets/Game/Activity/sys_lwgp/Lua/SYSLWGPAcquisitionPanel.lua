-- 创建时间:2021-03-04
-- Panel:SYSLWGPAcquisitionPanel
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

SYSLWGPAcquisitionPanel = basefunc.class()
local C = SYSLWGPAcquisitionPanel
C.name = "SYSLWGPAcquisitionPanel"
local M = SYSLWGPManager
local oneShowTime=3
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
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:TimerStop()	
	self:ClearItemPre()
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
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self.data=M.GetLwgpKaiJiangData()
	dump(self.data,"--------->开奖界面数据：  ")
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	-- self:DelayCloseWindow()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.OnCloseClick)

	self.tipRoot.gameObject:SetActive(false)
	self:CreateItemPre()
	self:MyRefresh()
	self.delayShowTimer= Timer.New(function ()
		self:ShowLikeAnim()
	end,1,false)
	self.delayShowTimer:Start()
end

function C:MyRefresh()
end

function C:ShowLikeAnim()
	if self.data.kaijiang_type==1 then
		self:AnimType_1()
	elseif self.data.kaijiang_type==2 then
		self:AnimType_2()
	elseif self.data.kaijiang_type==3 or self.data.kaijiang_type==4 or self.data.kaijiang_type==5 then
		self:AnimType_3()
	elseif self.data.kaijiang_type==11 then
		self:AnimType_11()
	else
		self:AnimType_Common()
	end
end
----普通模式    喜欢数量  1个
function C:AnimType_1()
	if #self.data.kaijiang_data ~=1 then
		--dump(self.data.kaijiang_data,"<color=red>普通模式时开奖数据长度不为1</color>")
		return
	end
	dump(self.data.kaijiang_level,"开奖喜欢等级：  ")

	self:ItemLikeTipShow(self.data.kaijiang_data[1].kaijiang_index,self.data.kaijiang_level)

	self:DelayCloseWindow(oneShowTime+1)
end
----喜爱提升    喜欢数量  1个
function C:AnimType_2()
	if #self.data.kaijiang_data ~=1 then
		dump(self.data.kaijiang_data,"<color=red>喜爱提升时开奖数据长度不为1</color>")
		return
	end
	dump(self.data.kaijiang_level,"开奖喜欢等级：  ")
	local itemShowFuc_second=function ()
		self:LWTipShow(self.data.kaijiang_type)
		self:ItemLikeTipShow(self.data.kaijiang_data[1].kaijiang_index,self.data.kaijiang_level)
	end
	self:ItemLikeTipShow(self.data.kaijiang_data[1].kaijiang_index,self.data.kaijiang_level-1,itemShowFuc_second)
	self:DelayCloseWindow(oneShowTime*2+1)
end
----爱屋及乌
function C:AnimType_3()
	dump(self.data.kaijiang_level,"爱屋及乌开奖喜欢等级：  ")

	local firstShowIndex=math.random(#self.data.kaijiang_data)
	local itemShowFuc_second=function ()
		for index, value in ipairs(self.data.kaijiang_data) do
			self:ItemLikeTipShow(value.kaijiang_index,self.data.kaijiang_level)
		end
		self:LWTipShow(self.data.kaijiang_type)
	end
	self:ItemLikeTipShow(self.data.kaijiang_data[firstShowIndex].kaijiang_index,self.data.kaijiang_level,itemShowFuc_second)
	self:DelayCloseWindow(oneShowTime*2+1)
end
---龙王震怒   不喜欢七个
function C:AnimType_11()
	dump(self.data.kaijiang_level,"开奖喜欢等级：  ")

	local function LWTipShow_function()
		self:LWTipShow(self.data.kaijiang_type)
	end
	for i = 1, 7, 1 do
		if i==1 then
			self:ItemLikeTipShow(i,0,LWTipShow_function)
		else
			self:ItemLikeTipShow(i,0)
		end
	end
	
	self:DelayCloseWindow(oneShowTime*2+1)
end
---其他通用情况
function C:AnimType_Common()
	dump(self.data.kaijiang_level,"开奖喜欢等级：  ")
	if #self.data.kaijiang_data>0 then
		--dump(self.data,"----------111>self.data")
		--dump(self.data.kaijiang_data,"---------->self.data.kaijiang_data")
		for index, value in ipairs(self.data.kaijiang_data) do
			--dump(value,"value-------->")
			if index==1 then
				self:ItemLikeTipShow(value.kaijiang_index,self.data.kaijiang_level)
			else
				self:ItemLikeTipShow(value.kaijiang_index,self.data.kaijiang_level)
			end
			self:LWTipShow(self.data.kaijiang_type)
		end
	else
		self:MyExit()
	end
	self:DelayCloseWindow(oneShowTime+1)
end

local LWTips={"普通模式","喜爱提升","爱屋及乌","爱屋及乌","爱屋及乌",
			  "贝类偏爱","珍品偏爱","胃口小开","胃口大开","非常喜欢","龙王震怒",}
function C:LWTipShow(kaijiangtype,callback)
	local tipStr=LWTips[kaijiangtype]
	self.tipRoot.gameObject:SetActive(true)
	self.tip_txt.text=tipStr
	self.LWdelayTimer=Timer.New(function ()
		self.tipRoot.gameObject:SetActive(false)
		if callback then
			callback()	
		end
	end,oneShowTime)
	self.LWdelayTimer:Start()
end

function C:ItemLikeTipShow(itemtype,likeLevel,callback)
	if self.pre_cell and self.pre_cell[itemtype] then
		self.pre_cell[itemtype]:ShowLikeTip(likeLevel,oneShowTime,callback)
	end
end
function C:DelayCloseWindow(_time)
	self.delayTimer=Timer.New(function ()
		self:TimerStop()
		self:MyClose()
		M.OnCloseAcquisitionPanel()
	end,_time,-1)
	self.delayTimer:Start()
end

function C:TimerStop()
	if self.delayTimer then
		self.delayTimer:Stop()
		self.delayTimer=nil
	end
	if self.delayShowTimer then
		self.delayShowTimer:Stop()
		self.delayShowTimer=nil
	end
	if self.LWdelayTimer then
		self.LWdelayTimer:Stop()
		self.LWdelayTimer=nil
	end
end
function C:CreateItemPre()
	self:ClearItemPre()
	local tab = M.GetStoreCfg()
	for i=1,7 do
		local pre = SYSLWGPAcquisitionItemBase.Create(self.item_node.transform,i)
		self.pre_cell[#self.pre_cell + 1] = pre
	end
end

function C:ClearItemPre()
	if self.pre_cell then
		for k,v in pairs(self.pre_cell) do
			v:MyExit()
		end
	end
	self.pre_cell = {}
end


function C:OnCloseClick()
	M.OnCloseAcquisitionPanel()

	self:MyClose()
end