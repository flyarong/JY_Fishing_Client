-- 创建时间:2021-03-08
-- Panel:SYSLWGPAcquisitionItemBase
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

SYSLWGPAcquisitionItemBase = basefunc.class()
local C = SYSLWGPAcquisitionItemBase
C.name = "SYSLWGPAcquisitionItemBase"
local M = SYSLWGPManager

local itemPosTable={
	[1]={-622,151},
	[2]={-454,72},
	[3]={-253.5,13.8},
	[4]={-12,-11},
	[5]={233,12},
	[6]={438.8,66.4},
	[7]={615,163},
}
function C.Create(parent,index)
	return C.New(parent,index)
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

function C:ctor(parent,index)
	ExtPanel.ExtMsg(self)
	self.index = index
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.config=M.GetStoreCfg()
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.transform.localPosition=Vector3.New(itemPosTable[self.index][1],itemPosTable[self.index][2],0)
	GetTextureExtend(self.icon_img,self.config[self.index].goods_icon)
	
	self.name_txt.text=self.config[self.index].name
	self.like_txt.gameObject:SetActive(false)
	-- self:ShowFXItemShow(-1)
	self:MyRefresh()
end
function C:MyRefresh()
end

local likeLevelTip={"不喜欢","喜欢","很喜欢","非常喜欢"}

local isopentest=false
---comment
---@param level any 喜欢等级  0：不喜欢  1：喜欢  2：很喜欢  3：非常喜欢
---@param time any  展示时间
---@param callback any  回调
function C:ShowLikeTip(level,time,callback)

	self:StopTimer()
	self:ShowFXItemShow(-1)

	self:ShowFXItemShow(level)
	if isopentest then
		self.like_txt.text=likeLevelTip[level+1]
		self.like_txt.gameObject:SetActive(true)
	end
	self.show_timer=Timer.New(function ()
		if isopentest then
			self.like_txt.gameObject:SetActive(false)
		end
		-- self:ShowFXItemShow(-1)
		self:StopTimer()
		if callback then
			--dump("执行回调！！！！！！！！！")
			callback()
		end
	end,time)
	self.show_timer:Start()
end
function C:ShowFXItemShow(_level)
	--dump(_level,"喜欢等级：  ")
	self.buxihuan.gameObject:SetActive(_level==0)
	self.xihuan.gameObject:SetActive(_level==1)
	self.henxihuan.gameObject:SetActive(_level==2)
	self.feichangxihuan.gameObject:SetActive(_level==3)
end
function C:StopTimer()
	if self.show_timer then
		self.show_timer:Stop()
	end
end

