-- 创建时间:2020-05-06
-- Panel:Act_012_LMLHItemBase
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

Act_025_LXDHItemBase = basefunc.class()
local C = Act_025_LXDHItemBase
C.name = "Act_025_LXDHItemBase"
local M = Act_025_LXDHManager
function C.Create(parent,data)
	return C.New(parent,data)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["LXDH_sw_kfPanel_msg"] = basefunc.handler(self,self.on_LXDH_sw_kfPanel_msg)
    self.lister["xgdh_tips_msg"] = basefunc.handler(self,self.on_xgdh_tips_msg)
end

function C:OnDestroy()
	self:MyExit()
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

function C:ctor(parent,data)
	--dump(data,"<color>+++++++++++++++_cur_data++++++++++++</color>")
	self.data = data
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.item_ani = self.blue1_btn.transform:GetComponent("Animator")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.blue1_btn.gameObject).onClick = basefunc.handler(self, self.on_enough_BuyClick)
	EventTriggerListener.Get(self.yellow_btn.gameObject).onClick = basefunc.handler(self, self.on_not_enough_BuyClick)
	self.tips_btn.onClick:AddListener(
        function()
            self:on_tips()
        end
	)

	self.gift_image_img.sprite = GetTexture(self.data.award_image)
	--self.gift_image_img:SetNativeSize()
	self.title_txt.text = self.data.award_name
	self.item_cost_text_txt.text = "  "..self.data.item_cost_text
	self.blue_txt.text = "兑换"
	self.yellow_txt.text = "兑换"

	if M.GetItemCount() < tonumber(self.data.item_cost_text) then--道具不足
		if self.data.remain_time > 0 or self.data.remain_time == -1 then--有剩余次数
			self.gray_img.gameObject:SetActive(false)
			self.blue1_btn.gameObject:SetActive(false)
			self.yellow_btn.gameObject:SetActive(true)
		else--没有剩余次数
			self.gray_img.gameObject:SetActive(true)
			self.blue1_btn.gameObject:SetActive(false)
			self.yellow_btn.gameObject:SetActive(false)		
		end
	else--道具足
		if self.data.remain_time > 0 or self.data.remain_time == -1 then
			self.gray_img.gameObject:SetActive(false)
			self.blue1_btn.gameObject:SetActive(true)
			CommonHuxiAnim.Start(self.blue1_btn.gameObject,1)
			--self.item_ani:Play("blue1_ani",-1,0)
			self.yellow_btn.gameObject:SetActive(false)
		else--没有剩余次数
			self.gray_img.gameObject:SetActive(true)
			self.blue1_btn.gameObject:SetActive(false)
			self.yellow_btn.gameObject:SetActive(false)
		end
	end
	if not self.data.tips then
		self.tips_btn.gameObject:SetActive(false)
	end

	self:MyRefresh()
end

function C:MyRefresh()
end



function C:on_enough_BuyClick()
	local set_func = function(index)
		PlayerPrefs.SetInt(MainModel.UserInfo.user_id..M.key..os.date("%Y%m%d",os.time()),index)
	end
	if PlayerPrefs.GetInt(MainModel.UserInfo.user_id..M.key..os.date("%Y%m%d",os.time()),0) == 0 then
		local b = HintPanel.Create(2,"是否兑换"..self.data.award_name,function ()
			Network.SendRequest("activity_exchange",{ type = 3 , id = self.data.ID })
		end)
		b:ShowGou()
		b:SetGouCall(function()
			set_func(1)
		end,function()
			set_func(0)
		end)
	else
		Network.SendRequest("activity_exchange",{ type = 3 , id = self.data.ID })
	end
end

function C:on_not_enough_BuyClick()
	HintPanel.Create(1, "龙虾兑换券不足")
end

function C:on_tips()
	if self.data.tips then
		if self.tips.gameObject.activeSelf then
			self.tips.gameObject:SetActive(false)
		else	
			self.tips.gameObject:SetActive(true)
			self.tips_txt.text = self.data.tips
			Event.Brocast("xgdh_tips_msg",self.data.ID)
		end
	end
end

function C:on_LXDH_sw_kfPanel_msg(id)
	--dump(self.data,"<color>+++++++++++++self.data+++++++++++</color>")
	--dump(id,"<color>+++++++++++++id+++++++++++</color>")
	if id == self.data.ID then
		if self.data.type == 1 then
			local string1
			string1="奖品:"..self.data.award_name.."，请关注公众号《畅游新世界》联系客服领取实物奖励。"				
			local pre = HintCopyPanel.Create({desc=string1, isQQ=false,copy_value = "畅游新世界"})
			pre:SetCopyBtnText("复制公众号")
		end
	end
end

function C:on_xgdh_tips_msg(id)
	if id == self.data.ID then
		return
	else
		if self.data.tips then
			self.tips.gameObject:SetActive(false)
		end
	end
end