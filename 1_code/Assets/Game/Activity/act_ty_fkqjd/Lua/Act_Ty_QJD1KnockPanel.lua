-- 创建时间:2021-01-11
-- Panel:Act_Ty_QJD1KnockPanel
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

Act_Ty_QJD1KnockPanel = basefunc.class()
local C = Act_Ty_QJD1KnockPanel
C.name = "Act_Ty_QJD1KnockPanel"
local M = Act_Ty_QJD1Manager

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
    self.lister["qjd1_get_task_award_msg"] = basefunc.handler(self,self.on_qjd1_get_task_award_msg)
    self.lister["qjd1_finish_gift_msg"] = basefunc.handler(self,self.on_qjd1_finish_gift_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	M.SetCurStatusIsKnocking(false)
	M.ShowAssetTip(self.index)
	self:StopTimer()
	self:CloseHammerItem()
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
	EventTriggerListener.Get(self.knock_btn.gameObject).onClick = basefunc.handler(self, self.OnKnockClick)
	self.hammer_ani = self.hammer.transform:GetComponent("Animator")
	self.hammer_img = self.hammer.transform:Find("chuizi/chuizi_1").transform:GetComponent("Image")
	self:MyRefresh()
end

function C:MyRefresh()
	self:CreateHammerItem()
	self:Selet(nil,nil)
end

function C:CreateHammerItem()
	self:CloseHammerItem()
	self.eggs_cfg = M.GetEggsCfg()
	for i=1,#self.eggs_cfg do
		local pre = Act_Ty_QJD1HammerItemBase.Create(self.hammer_node.transform,self,i,self.eggs_cfg[i])
		self.hammer_pre_list[#self.hammer_pre_list + 1] = pre
	end
end

function C:CloseHammerItem()
	if self.hammer_pre_list then
		for k,v in pairs(self.hammer_pre_list) do
			v:MyExit()
		end
	end
	self.hammer_pre_list = {}
end

function C:Selet(index,type_)
	if M.GetCurStatusIsKnocking() then
		LittleTips.Create("正在砸蛋中")
	else
		if type_ == "selet_hammer" then
			self.index = index
		elseif type_ == "get_task_award" then
			if M.GetHammerCount(index) > 0 then
				self.index = index
			else
				self.index = M.GetTJIndex()
			end
		elseif type_ == "finish_gift" then
			self.index = M.GetTJIndex()
		else
			self.index = M.GetTJIndex()
		end
		self:SeletRefreshItemHammer(self.index)
		self:SeletRefreshKnockHammer(self.index)
		self:SeletRefreshEgg(self.index)
	end
end

function C:SeletRefreshItemHammer(index)
	for k,v in pairs(self.hammer_pre_list) do
		v:SeletRefresh(index)
	end
end

function C:SeletRefreshKnockHammer(index)
	self.hammer_img.sprite = GetTexture(GameItemModel.GetItemToKey(self.eggs_cfg[index].item_key).image)
end

function C:SeletRefreshEgg(index)
	local data = M.GetEggData(self.eggs_cfg[index].task_id)
	local x = data.hit_num + 1
	dump(x,"<color=yellow><size=15>++++++++++x++++++++++</size></color>")
	self.egg_img.sprite = GetTexture(self.eggs_cfg[index].eggs_img[x])
	self.award_txt.text = self.eggs_cfg[index].award_txt.."金币"
end

function C:OnKnockClick()
	if M.GetCurStatusIsKnocking() then
		LittleTips.Create("正在砸蛋中")
	else
		if M.GetHammerCount(self.index) > 0 then
			M.KnockEgg(self.eggs_cfg[self.index].task_id)
			self:KnockAnim_First_Half()
		else
			local str = GameItemModel.GetItemToKey(self.eggs_cfg[self.index].item_key).name.."不足"
			LittleTips.Create(str)
		end
	end
end

--砸蛋的上半段动画
function C:KnockAnim_First_Half()
	M.SetCurStatusIsKnocking(true)
	self.hammer.gameObject:SetActive(true)
	self.hammer_ani:Play("Dachui_Pt_zd",-1,0)
	self.anim_timer1 = Timer.New(function ()
		self.chuizi_Za.gameObject:SetActive(true)
	end,1,1,false)
	self.anim_timer1:Start()
	self.anim_timer2 = Timer.New(function ()
		self.chuizi_Za.gameObject:SetActive(false)
	end,1,1,false)
	self.anim_timer2:Start()
end

function C:StopTimer()
	if self.anim_timer1 then
		self.anim_timer1:Stop()
		self.anim_timer1 = nil
	end
	if self.anim_timer2 then
		self.anim_timer2:Stop()
		self.anim_timer2 = nil
	end
	if self.anim_timer3 then
		self.anim_timer3:Stop()
		self.anim_timer3 = nil
	end
	if self.anim_timer4 then
		self.anim_timer4:Stop()
		self.anim_timer4 = nil
	end
	if self.anim_timer5 then
		self.anim_timer5:Stop()
		self.anim_timer5 = nil
	end
end

--砸蛋的后半段动画
function C:KnockAnim_Second_Half()
	local data = M.GetEggData(self.eggs_cfg[self.index].task_id)
	dump(data,"<color=yellow><size=15>++++++++++88888888888++++++++++</size></color>")
	local x
	if data.hit_num == 0 then
		x = 6
	else
		x = data.hit_num + 1
	end
	self.anim_timer3 = Timer.New(function ()
		if data.hit_num == 0 then
			self.tx_3.gameObject:SetActive(true)
		end
	end,1,1,false)
	self.anim_timer3:Start()
	local m
	if data.hit_num == 0 then
		m = 5
	else
		m = 0.8
	end
	self.anim_timer4 = Timer.New(function ()
		self.egg_img.sprite = GetTexture(self.eggs_cfg[self.index].eggs_img[x])
	end,m,1,false)
	self.anim_timer4:Start()
	local n
	if 0 == data.hit_num then
		n = 6
	else
		n = 1.2
	end
	self.anim_timer5 = Timer.New(function ()
		self.hammer.gameObject:SetActive(false)
		self.tx_3.gameObject:SetActive(false)
		M.SetCurStatusIsKnocking(false)
		M.ShowAssetTip(self.index)
		self:Selet(self.index,"get_task_award")
	end,n,1,false)
	self.anim_timer5:Start()
end

function C:on_qjd1_get_task_award_msg()
	self:KnockAnim_Second_Half()
	self:CreateHammerItem()
end

function C:on_qjd1_finish_gift_msg()
	self:CreateHammerItem()
	self:Selet(self.index,"finish_gift")
end