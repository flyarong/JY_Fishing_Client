-- 创建时间:2020-10-30
-- Panel:Act_035_JHSPanel
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

Act_035_JHSPanel = basefunc.class()
local C = Act_035_JHSPanel
C.name = "Act_035_JHSPanel"
local M = Act_035_JHSManager


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
    self.lister["finish_gift_shop"] = basefunc.handler(self,self.on_finish_gift_shop) --完成礼包购买
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:DeleteItemRigthPrefab()
	self:DeleteItemLeftPrefab()
	self:DeleteItemBtmPrefab()
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
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	

	self.config = M.GetCurConfigInfor()


	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.back_btn.onClick:AddListener(
            	function()
                ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				self:MyExit()
            end)
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	self:CreateLeftPrefab()
	self:CreateCenterPrefab()
	self:CreateButtomPrefab()
end


function C:CreateLeftPrefab()
	self:DeleteItemLeftPrefab()
	for i=1,7 do
		local pre  = Act_035_LeftPrefab.Create(self.L_content.transform, self, i, self.config[i])
		self.gift_cell_list[i] = pre
	end
end


function C:CreateCenterPrefab(index)
	self:DeleteItemRigthPrefab()
	local _index = index or M.GetCurHaveBuyFirstId()
	for i=1,2 do
		local pre = Act_035_CenterPrefab.Create(self.C_content.transform, self, i, _index, self.config[_index])
		self.day_btn_cell_list[i] = pre
	end

end


--获取当前选择的左边按钮的位置，传递index 
function C:ShowButtomInforByIndex(index)
	for i,v in ipairs(self.gift_cell_list) do
		v:RefreshSelet(index)
	end

end

function C:CreateButtomPrefab(index)
	self:DeleteItemBtmPrefab()
	local _index = index or M.GetCurHaveBuyFirstId()
	--[[if not MainModel.IsCanBuyGiftByID(self.config[_index].shop_id[1]) then
		--self.get_txt.text = "再次购买"
		if not M.IsCanGetGift(self.config[_index].shop_id) then
			self.get2.gameObject:SetActive(true)
			self.djs_txt.gameObject:SetActive(false)
			self.parentPanel:MyRefresh()
		end
	end		--]]
	local pre = Act_035_ButtomPrefab.Create(self.b_content.transform, self.cur_bottom, _index, self.config[_index], self)
	self.btm_cell_prefab[#self.btm_cell_prefab + 1] = pre
end


function C:DeleteItemRigthPrefab()
	if self.day_btn_cell_list then
		for i,v in ipairs(self.day_btn_cell_list) do
			v:MyExit()
		end
	end
	self.day_btn_cell_list = {}
end


function C:DeleteItemLeftPrefab()


	if self.gift_cell_list then
		for i,v in ipairs(self.gift_cell_list) do
			v:MyExit()
		end
	end
	self.gift_cell_list = {}	
end

function C:DeleteItemBtmPrefab( )
	if not table_is_null(self.btm_cell_prefab) then
		for k,v in pairs(self.btm_cell_prefab) do
			v:MyExit()
		end
	end
	--[[if self.btm_cell_prefab then
		dump(data,"<color=yellow><size=15>++++++++++data++++++++++</size></color>")
		self.btm_cell_prefab:MyExit()
	end--]]
	self.btm_cell_prefab = {}
end

function C:on_finish_gift_shop()
	dump("<color=red>xxxxxxxxxxxxxxxxxxxxxxxxxxxxx</color>")
	self:MyRefresh()	
end