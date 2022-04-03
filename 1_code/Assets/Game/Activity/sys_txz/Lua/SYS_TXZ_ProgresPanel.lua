-- 创建时间:2021-05-06
-- Panel:SYS_TXZ_ProgresPanel
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

SYS_TXZ_ProgresPanel = basefunc.class()
local C = SYS_TXZ_ProgresPanel
C.name = "SYS_TXZ_ProgresPanel"
local M=SYS_TXZ_Manager
function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["refresh_txz_buytype"] = basefunc.handler(self,self.MyRefresh)
	
	self.lister["refresh_txz_level_task_data"] = basefunc.handler(self,self.MyRefresh)

end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.cutdown_timer then
		self.cutdown_timer:Stop()
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent =parent or GameObject.Find("Canvas/GUIRoot").transform
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
	self.help_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OpenHelpPanel()
	end)
	self:MyRefresh()
end
local PROGRESS_HEIGHT=22
local PROGRESS_WIDTH=829
function C:MyRefresh()
	local endTime=M.GetTXZActEndTime()
	if endTime then
		self.cutdown_timer =CommonTimeManager.GetCutDownTimer(endTime,self.cut_down_txt)
	else
		self.cut_down_txt.text=""
	end
	self.nowlevel_txt.text = "LV." .. M.GetNowLevel()
	local progressInfo=M.GetTXZProgressInfo()
	-- dump(progressInfo,"通行证进度数据：  ")
	if M.GetBuyBagType()==0 then
		GetTextureExtend(self.txz_name_img,"hwtxz_imgf_pt")
		GetTextureExtend(self.txz_icon_img,"hwtxz_icon_bttxz")
	else
		GetTextureExtend(self.txz_name_img,"hwtxz_imgf_hw")
		GetTextureExtend(self.txz_icon_img,"hwtxz_icon_hwtxz")
	end
	self.txz_icon_img:SetNativeSize()
	self.progress_txt.text="经验值".. progressInfo.now_process .."/".. progressInfo.need_process
	local value=progressInfo.now_process/progressInfo.need_process
	self.pregross_front_img:GetComponent("RectTransform").sizeDelta = {x = value * PROGRESS_WIDTH, y = PROGRESS_HEIGHT}
end

function C:OpenHelpPanel()
	local str
	local help_info = self:GetCurHelpInfor()
	str = help_info[1]
	for i = 2, #help_info do
		str = str .. "\n" .. help_info[i]
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform, "IllustratePanel_New")
end
function C:GetCurHelpInfor()
    local help_desc = {
	"1.完成通行证任务可获得通行证经验用来升级通行证。",
	"2.升级通行证后可获得对应等级奖励。",
	"3.日常任务为每日凌晨0点刷新，周常任务为每周日凌晨0点刷新。",
	"4.购买海王礼包可获得更多奖励。海王礼包普通版与至尊版仅购买其一且周期内限购一次。",
	"5.拥有海王炮台获得达人榜加成，当周内加成效果可叠加。"}
    return help_desc
end
