-- 创建时间:2021-05-06
-- Panel:sys_txz_listitem
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

sys_txz_listitem = basefunc.class()
local C = sys_txz_listitem
C.name = "sys_txz_listitem"
local M=SYS_TXZ_Manager

function C.Create(parent,level,data)
	return C.New(parent,level,data)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["refresh_txzaward_listitem"] = basefunc.handler(self,self.MyRefresh)

end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	for index, value in ipairs(self.awardpre_list) do
		value:MyExit()
	end
	self.awardpre_list=nil
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent,level,data)
	ExtPanel.ExtMsg(self)
	local parent =parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.data=data
	self.level=level
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.level_txt.text = self.level .. "级"
	self.awardpre_list={}
	if self.data.commonAward then
		local task_id=M.GetCommonLevelTaskID()
		local data={icon=self.data.commonAward.icon[1],num=self.data.commonAward.num[1],
					level=self.level,speci=0,task_id=task_id}
		local pre=sys_txz_awarditem_1.Create(self.awardnode_1,data)
		self.awardpre_list[#self.awardpre_list+1] = pre
	end
	local buytxztype=M.GetBuyBagType()  ---1:海王  2： 海王至尊版
	local showType=2
	if buytxztype>0 then
		showType=buytxztype+1
	end
	local task_id=M.GetHaiWangLevelTaskID()
	local data={icon=self.data.commonAward.icon[showType],num=self.data.commonAward.num[showType],
				level=self.level,speci=1,task_id=task_id}
	local pre=sys_txz_awarditem_2.Create(self.awardnode_2,data)
	self.awardpre_list[#self.awardpre_list+1] = pre
	

	self:MyRefresh()
end

function C:ResetPosInParent()
	self.gameObject.transform:SetSiblingIndex(0);

end
function C:MyRefresh()
	local awrardState=M.GetAwardItemGotState(self.level)
	self.klqbg_img.gameObject:SetActive(awrardState==1)
	for index, value in ipairs(self.awardpre_list) do
		value:MyRefresh()
	end
end
