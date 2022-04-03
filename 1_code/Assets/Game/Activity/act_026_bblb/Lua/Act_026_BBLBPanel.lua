-- 创建时间:2020-05-06
-- Panel:Act_026_BBLBPanel
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

Act_026_BBLBPanel = basefunc.class()
local C = Act_026_BBLBPanel
C.name = "Act_026_BBLBPanel"
local M = Act_026_BBLBManager

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
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
	self.lister["AssetsGetPanelConfirmCallback"] = basefunc.handler(self,self.AssetsGetPanelConfirmCallback)
	self.lister["get_task_award_response"] = basefunc.handler(self,self.on_get_task_award_response)
	self.lister["Act_026_BBLBManager_status_change_msg"] = basefunc.handler(self,self.on_Act_026_BBLBManager_status_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	M.QueryDataTimer(false)
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)
	local parent = parent or GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:SetTime()
	M.QueryDataTimer(true)
end
function C:InitUI()
	self.items = {}
	self.ui_items = {}
	for i = 1,#M.config do
		local temp_ui = {}
		local b = GameObject.Instantiate(self.item,self.Content)
		LuaHelper.GeneratingVar(b.transform, temp_ui)
		self.items[#self.items + 1] = b
		b.gameObject:SetActive(true)
		temp_ui.title_txt.text = M.config[i].title
		temp_ui.award1_txt.text = M.config[i].award1_txt
		temp_ui.award2_txt.text = M.config[i].award2_txt
		temp_ui.award3_txt.text = M.config[i].award3_txt
		temp_ui.price_txt.text = M.config[i].price.."元领取"
		temp_ui.buy_btn.onClick:AddListener(
			function ()
				M.BuyShop(M.config[i].shop_id)
			end
		)
		self.ui_items[#self.ui_items + 1] = temp_ui
	end
	self.tips = GameObject.Instantiate(self.sw_item,self.ui_items[2].sw_node)
	self.tips.gameObject:SetActive(true)
	local temp_ui = {}
	LuaHelper.GeneratingVar(self.tips.transform,temp_ui)
	temp_ui.sw_btn.onClick:AddListener(
		function ()
			local data = GameTaskModel.GetTaskDataByID(1000018)
			dump(data,"<color=red>任务数据------</color>")
			if data and data.award_status == 1 then
				Network.SendRequest("get_task_award",{id = 1000018})
				self.real = {image = "bblb_icon_df1",text = "德芙巧克力"}
			end
		end
	)
	self.huxiAnim = self.tips.transform:GetComponent("Animator")
	PointerEventListener.Get(self.tips.gameObject).onDown = function ()
		GameTipsPrefab.ShowDesc('德芙巧克力:\n   当天内购买"我爱你"礼包和"一生一世"礼包可领取德芙巧克力一份,奖\n励在公众号《畅游新世界》联系在线客服领取。', UnityEngine.Input.mousePosition)
	end
	PointerEventListener.Get(self.tips.gameObject).onUp = function ()
		GameTipsPrefab.Hide()
	end
	self:MyRefresh()
end

function C:MyRefresh()
	local temp_ui = {}
	LuaHelper.GeneratingVar(self.tips.transform,temp_ui)
	for i = 1,#M.config do
		local status = MainModel.GetGiftShopStatusByID(M.config[i].shop_id)
		dump({id= M.config[i].shop_id,status =status},"<color=yellow>3333333333333333333</color>")
		if status == 0 then
			self.ui_items[i].buy_btn.enabled = false
			self.ui_items[i].buy_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("ty_btn_ywc")
		end
	end
	local s1 = MainModel.GetGiftShopStatusByID(M.config[1].shop_id)
	local s2 = MainModel.GetGiftShopStatusByID(M.config[2].shop_id)
	self.huxiAnim.enabled = false
	temp_ui.sw_btn.gameObject:SetActive(false)
	if s1 + s2 == 2 then
		temp_ui.sw_img.sprite = GetTexture("bblb_icon_df3")
	elseif s1 + s2 == 0 then
		self.huxiAnim.enabled = true
		temp_ui.sw_btn.gameObject:SetActive(true)
		temp_ui.sw_img.sprite = GetTexture("bblb_icon_df1")
	elseif s1 > s2 then
		temp_ui.sw_img.sprite = GetTexture("bblb_icon_df4")
	elseif s2 > s1 then
		temp_ui.sw_img.sprite = GetTexture("bblb_icon_df2")
	end
	local task_data = GameTaskModel.GetTaskDataByID(1000018)
	temp_ui.yhd.gameObject:SetActive(false)
	if task_data and task_data.award_status == 2 then
		self.huxiAnim.enabled = false
		temp_ui.yhd.gameObject:SetActive(true)
	end
end

function C:OnAssetChange()
	self:MyRefresh()
end

function C:OnDestroy()
	self:MyExit()
end

function C:on_get_task_award_response(_,data)
	if data and data.result == 0 then
		if self.real then
			local pre = RealAwardPanel.Create({image = self.real.image,text = self.real.text,qq = "畅游新世界"})
			pre:SetQQtext("请在公众号《畅游新世界》联系在线客服领奖。")
			pre:SetButtonTitle("复制公众号")
			self.real = nil
		end
	end
end

function C:AssetsGetPanelConfirmCallback(  )
	self:MyRefresh()
end

function C:SetTime()
	local d = os.date("%Y/%m/%d", now)
    local strs = {}
    string.gsub(d, "[^-/]+", function(s)
        strs[#strs + 1] = s
    end)
    local et = os.time({year = strs[1], month = strs[2], day = strs[3], hour = "23", min = "59", sec = "59"})
    et = et + 1
    PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."BBLB",et)
end

function C:on_Act_026_BBLBManager_status_change_msg()
	self:MyRefresh()
end