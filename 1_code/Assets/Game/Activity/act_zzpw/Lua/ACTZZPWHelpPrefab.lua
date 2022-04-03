-- 创建时间:2021-05-21
-- Panel:ACTZZPWHelpPrefab
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

ACTZZPWHelpPrefab = basefunc.class()
local C = ACTZZPWHelpPrefab
C.name = "ACTZZPWHelpPrefab"
local M = ACTZZPWManager

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
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.close_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:MyExit()
    end)


	self:CheckTime()
	self:MyRefresh()
end

function C:MyRefresh()
	local config = M.GetConfig()
	for k,v in ipairs(config) do
		local obj = GameObject.Instantiate(self.cell, self.node)
		obj.gameObject:SetActive(true)
		local ui = {}
		LuaHelper.GeneratingVar(obj.transform, ui)
		ui.rank_txt.text = v.rank_name
		ui.num_txt.text = v.num
		ui.jc_txt.text = StringHelper.ToCash(v.jc_ogrin)
		ui.award_txt.text = v.rank_award
	end
end

function C:CheckTime()
	local _sta = self:GetStart_t()
	local _end = self:GetEnd_t()
	local text = 
	"通过完成至尊排位的任务可获得骰子，使用骰子可在方格上行走，从起点走完一圈即可进行奖池开奖，奖池金额会根据段位及游戏奖励进行提升，奖池越大开出的奖励越大，完成任务即可提升段位，快来完成任务开启高额奖池吧！\n"..
    "                                            一、活动时间\n" ..
	_sta .. "—" .. _end .. "\n" ..
    "                                            二、骰子说明\n" ..
	"1、完成任务即可获得骰子。\n" ..
	"2、每次摇骰子消耗1个。\n" ..
    "                                            三、奖励说明\n" ..
	"1、每跳到1个格子上可获得该格子上的奖励，格子上的奖励会随段位升级而提升。\n" ..
	"2、每跑完一圈可开启奖池奖励，段位越高奖池金额越高。\n" ..
    "                                            四、任务说明\n" ..
	"1、每跑完一圈将重置所有任务，不同段位的任务不同。\n" ..
	"2、当所有任务已完成，且骰子数为0时，重置所有任务。\n" ..
	"3、新手场不计入任务数据。\n" ..
    "                                           五、段位说明\n"
    self.introduce_txt.text = text
end

function C:GetStart_t()
    return string.sub(os.date("%m月%d日%H:%M",M.GetActStaTime()),1,1) ~= "0" and os.date("%m月%d日%H:%M",M.GetActStaTime()) or string.sub(os.date("%m月%d日%H:%M",M.GetActStaTime()),2)
end

function C:GetEnd_t()
    return string.sub(os.date("%m月%d日%H:%M:%S",M.GetActEndtime()),1,1) ~= "0" and os.date("%m月%d日%H:%M:%S",M.GetActEndtime()) or string.sub(os.date("%m月%d日%H:%M:%S",M.GetActEndtime()),2)
end