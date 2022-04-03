-- 创建时间:2021-03-04
-- Panel:SYSLWGPStorePanel
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

SYSLWGPStorePanel = basefunc.class()
local C = SYSLWGPStorePanel
C.name = "SYSLWGPStorePanel"
local M = SYSLWGPManager

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
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["refresh_Lwgp_store_item_num"]=basefunc.handler(self,self.MyRefresh)
	self.lister["AssetChange"] = basefunc.handler(self, self.on_asset_change)
	
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
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

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
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
	self:CreateItemPre()
	self:MyRefresh()
	M.request_lwgp_query_bet_data()
end

function C:MyRefresh()
	self.jlb_txt.text = M.GetJlbNum()
end

function C:CreateItemPre()
	self:ClearItemPre()
	local tab = M.GetStoreCfg()
	--dump(tab,"龙王贡品itemconfig:  ")
	for i=1,#tab do
		local pre = SYSLWGPStoreItemBase.Create(self["item_node"..tab[i].row].transform,tab[i])
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
function C:on_asset_change(_data)
	dump(_data,"<color=yellow>+++++on_asset_change+++++</color>")
    if _data.change_type and _data.change_type=="lwgp_check_jinglong_bi_time" then
		self:MyRefresh()
    end
end