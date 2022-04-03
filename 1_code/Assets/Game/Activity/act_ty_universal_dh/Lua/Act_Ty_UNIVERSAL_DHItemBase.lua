-- 创建时间:2021-01-19
-- Panel:Act_Ty_UNIVERSAL_DHItemBase
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

Act_Ty_UNIVERSAL_DHItemBase = basefunc.class()
local C = Act_Ty_UNIVERSAL_DHItemBase
C.name = "Act_Ty_UNIVERSAL_DHItemBase"
local M = Act_Ty_UNIVERSAL_DHManager

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
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["universal_sw_kfpanel_msg"] = basefunc.handler(self,self.on_universal_sw_kfpanel_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	CommonHuxiAnim.Stop(1,Vector3.New(1, 1, 1))
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent,data)
	ExtPanel.ExtMsg(self)
	self.data = data
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
	EventTriggerListener.Get(self.get_btn.gameObject).onClick = basefunc.handler(self, self.OnGetClick)
	EventTriggerListener.Get(self.go_btn.gameObject).onClick = basefunc.handler(self, self.OnGoClick)
	self:MyRefresh()
end

function C:MyRefresh()
	self.remain_txt.text = self.data.remain_time == -1 and "兑换次数无限" or "兑换次数剩"..self.data.remain_time
	CommonHuxiAnim.Start(self.get_btn.gameObject)
	if not M.CheckItemIsEnough(self.data.ID) then--道具不足
		if self.data.remain_time > 0 or self.data.remain_time == -1 then--有剩余次数
			self.gray_img.gameObject:SetActive(false)
			self.get_btn.gameObject:SetActive(false)
			self.go_btn.gameObject:SetActive(true)
		else--没有剩余次数
			self.gray_img.gameObject:SetActive(true)
			self.get_btn.gameObject:SetActive(false)
			self.go_btn.gameObject:SetActive(false)		
		end
	else--道具足
		if self.data.remain_time > 0 or self.data.remain_time == -1 then
			self.gray_img.gameObject:SetActive(false)
			self.get_btn.gameObject:SetActive(true)
			self.go_btn.gameObject:SetActive(false)
		else--没有剩余次数
			self.gray_img.gameObject:SetActive(true)
			self.get_btn.gameObject:SetActive(false)
			self.go_btn.gameObject:SetActive(false)
		end
	end
	self:CreateAwardPrefab()
	self:CreateItemPrefab()
end

function C:OnGetClick()
	Network.SendRequest("activity_exchange",{ type = M.type , id = self.data.ID})
end

function C:OnGoClick()
	GameManager.GuideExitScene({gotoui = M.GetCurGotoUI()},function ()
   		Event.Brocast("exit_fish_scene")
   	end)
end

function C:CreateAwardPrefab()
	for i=1,#self.data.award_name do
		local pre = GameObject.Instantiate(self.award, self.award_node.transform)
		pre.gameObject:SetActive(true)
		local award_img = pre.transform:Find("award_img").transform:GetComponent("Image")
		local award_txt = pre.transform:Find("award_txt").transform:GetComponent("Text")
		award_img.sprite = GetTexture(M.GetCurPath() .. self.data.award_image[i])
		award_img:SetNativeSize()
		award_txt.text = self.data.award_name[i]
	end
end

function C:CreateItemPrefab()
	local num = 0
	for i=1,#self.data.cost_item_num do
		if self.data.cost_item_num[i] ~= 0 then
			num = num + 1
		end
	end
	for i=1,#self.data.cost_item_key do
		if self.data.cost_item_num[i] ~= 0 then
			local pre = GameObject.Instantiate(self.item,self.item_node.transform)
			pre.gameObject:SetActive(true)
			local item_img = pre.transform:Find("item_img").transform:GetComponent("Image")
			local item_txt = pre.transform:Find("item_txt").transform:GetComponent("Text")
			item_img.sprite = GetTexture(M.GetCurPath() .. GameItemModel.GetItemToKey(self.data.cost_item_key[i]).image)
			item_txt.text = self.data.cost_item_num[i]
			if i >= num then
				pre.transform:Find("add").gameObject:SetActive(false)
			end
		end
	end
end

function C:RefreshButton()
	
end

function C:on_universal_sw_kfpanel_msg(id)
	if id == self.data.ID then
		if self.data.type == 1 then
			local string1
	        string1 = "实物奖励请关注公众号《"..Global_GZH.."》联系在线客服领取。"
			print(debug.traceback())
			local pre = HintCopyPanel.Create({desc=string1, isQQ=false,copy_value = Global_GZH})
			pre:SetCopyBtnText("复制公众号")
		end
	end
end