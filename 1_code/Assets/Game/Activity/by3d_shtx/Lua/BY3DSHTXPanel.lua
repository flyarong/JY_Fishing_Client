-- 创建时间:2020-10-27
-- Panel:BY3DSHTXPanel
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

BY3DSHTXPanel = basefunc.class()
local C = BY3DSHTXPanel
C.name = "BY3DSHTXPanel"
local M = BY3DSHTXManager
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
    self.lister["by3d_shtx_cur_task_data_is_queried"] = basefunc.handler(self,self.on_by3d_shtx_cur_task_data_is_queried)
    self.lister["by3d_shtx_on_auto_response"] = basefunc.handler(self,self.on_by3d_shtx_on_auto_response)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:CloseItemPrefab()
	if self.phb_pre then
		self.phb_pre:MyExit()
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

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.Slider = self.slider.transform:GetComponent("Slider")

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.on_BackClick)
	EventTriggerListener.Get(self.rank_btn.gameObject).onClick = basefunc.handler(self, self.on_RankClick)
	EventTriggerListener.Get(self.changetask_btn.gameObject).onClick = basefunc.handler(self, self.On_ChangeTaskClick)
	EventTriggerListener.Get(self.vip3auto_btn.gameObject).onClick = basefunc.handler(self, self.On_Vip3AutoClick)
	self.spawn_cell_list = {}
	self.page = 1
	self.sv = self.ScrollView.transform:GetComponent("ScrollRect")
	EventTriggerListener.Get(self.sv.gameObject).onEndDrag = function()
		local VNP = self.sv.verticalNormalizedPosition
		if VNP <= 0 then
			self:CreateItemPrefab()		
		end
	end
	if false--[[M.CheckIsInGuide()--]] then
		self.changetask_btn.gameObject:SetActive(false)
		self.vip3auto_btn.gameObject:SetActive(false)
		self:RefreshRightNode()
	else
		self.changetask_btn.gameObject:SetActive(true)
		self.vip3auto_btn.gameObject:SetActive(true)
		M.QueryCurLayerTaskId()
	end

	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshAutoButton()
end

function C:on_BackClick()
	self:MyExit()
end

function C:on_RankClick()
	self.phb_pre = BY3DPHBGamePanel.Create()
	self.phb_pre:Selet(3)--默认选中爬塔榜
end


function C:On_ChangeTaskClick()
	HintPanel.Create(2,"是否花费"..M.refresh_cost.."金币，进行刷新任务？（当前任务进度清空）",function ()
		if MainModel.UserInfo.jing_bi >= M.refresh_cost then
			local data = M.GetCurTaskData()
			dump(data,"<color=green><size=15>++++++++++data++++++++++</size></color>")
			if data then
				if data.now_total_process > 0 then
					if data.award_status == 0 then
						local b = HintPanel.Create(7,"<color=#7C4114>刷新后已累计的任务进度会被清空\n是否确定刷新？</color>",function ()
							Network.SendRequest("refresh_ocean_explore_task",{parent_id  = M.father_task_id})
						end)
						b:SetBtnTitle("考虑一下","刷新")
					elseif data.award_status == 1 then
						LittleTips.Create("此任务已完成,不可刷新,请领取奖励")
					end
				else
					Network.SendRequest("refresh_ocean_explore_task",{parent_id  = M.father_task_id})
				end
			end
		else
			HintPanel.Create(1,"您的金币不足！")
		end
	end)
end


function C:on_by3d_shtx_cur_task_data_is_queried()
	--dump("<color=blue><size=15>+++++++++dasd+dsadsdsafasgagagasgasg++++++++++</size></color>")
	local config = M.GetCurTaskConfig()
	local data = M.GetCurTaskData()
	self.taskicon_img.sprite = GetTexture(config.task_icon)
	self.taskdesc_txt.text = config.text
	self.Slider.value = data.now_process / data.need_process
	self.process_txt.text = StringHelper.ToCash(data.now_process) .. "/" .. StringHelper.ToCash(data.need_process)
	for i=1,#config.award_img do
		self["rank_award_icon"..i.."_img"].gameObject:SetActive(true)
		self["rank_award"..i.."_img"].sprite = GetTexture(config.award_img[i])
		self["rank_award"..i.."_txt"].text = config.award_txt[i]
	end
	if config.random == 0 then
		self.is_random_txt.gameObject:SetActive(false)
	elseif config.random == 1 then
		self.is_random_txt.gameObject:SetActive(true)
		self.is_random_txt.text = "(奖励随机三选一)"
	end
	self.layer_txt.text = "第"..M.GetCurLayer().."层"
	self:RefreshIconSizeAndPosition()
	self:CreateItemPrefab()
	self:CheckIsExtra()
	self.right_node.gameObject:SetActive(true)--后开启显示是为了防止数据未到时的显示效果不佳
end

function C:On_Vip3AutoClick()
	if not M.CheckIsVip3() then
		LittleTips.Create("Vip3及以上可开启自动领奖")
		return
	end
	M.SetAuto()
end

function C:RefreshAutoButton()
	self.gou_img.gameObject:SetActive(M.GetAuto())
end

function C:CreateItemPrefab()
	if #self.spawn_cell_list >= 20 then
		return
	end
	dump(self.page,"<color=yellow><size=15>++++++++++page++++++++++</size></color>")
	dump(M.GetCurLayer(),"<color=yellow><size=15>++++++++++GetCurLayer++++++++++</size></color>")
	local cur_layer = (self.page - 1) * 10 + M.GetCurLayer()
	for i=cur_layer,cur_layer + 20 do
		local pre = BY3DSHTXLeftItemBase.Create(self.Content.transform,i)
		pre:CheckLayer("normal")
		self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
	end
	self.spawn_cell_list[1]:CheckLayer("cur")
	self.page = self.page + 1
end

function C:CloseItemPrefab()
	if self.spawn_cell_list then
		for k,v in ipairs(self.spawn_cell_list) do
			v:MyExit()
		end
	end
	self.spawn_cell_list = {}
end

function C:on_by3d_shtx_on_auto_response()
	self:RefreshAutoButton()
end

function C:CheckIsExtra()
	local config = M.GetExtraAwardCfg()
	for i=1,#config do
		if config[i].layer == M.GetCurLayer() then
			for j=1,#config[i].extra_award_img do
				self["rank_award_icon_extra"..j.."_img"].gameObject:SetActive(true)
				self["rank_award_extra"..j.."_img"].sprite = GetTexture(config[i].extra_award_img[j])
				self["rank_award_extra"..j.."_txt"].text = config[i].extra_award_txt[j]
			end
		end
	end
end

function C:RefreshIconSizeAndPosition()
	local config = M.GetCurTaskConfig()
	self.taskicon_img:SetNativeSize()
	local rect = self.taskicon_img.gameObject:GetComponent("RectTransform")
	if config.icon_id == 1 then	
		rect.sizeDelta = Vector2.New(347.2,288.4)
		self.taskicon_img.transform.localPosition = Vector3.New(-235,118,0)
	elseif config.icon_id == 2 then
		rect.sizeDelta = Vector2.New(150,150)
		self.taskicon_img.transform.localPosition = Vector3.New(-235,118,0)
	end
end

function C:RefreshRightNode()
	local data = GameTaskModel.GetTaskDataByID(M.guide_task)
	self.taskicon_img.sprite = GetTexture("rw_icon_mrzz")
	self.taskdesc_txt.text = "消耗金币3万"
	self.Slider.value = data.now_process / data.need_process
	self.process_txt.text = StringHelper.ToCash(data.now_process) .. "/" .. StringHelper.ToCash(data.need_process)
	self.rank_award_icon1_img.gameObject:SetActive(true)
	self.rank_award1_img.sprite = GetTexture("3dby_btn_sd")
	self.rank_award1_txt.text = "锁定*3"
	self.layer_txt.text = "第1层"
	self:CreateItemPrefab()
	self:CheckIsExtra()
	self.taskicon_img:SetNativeSize()
	local rect = self.taskicon_img.gameObject:GetComponent("RectTransform")
	rect.sizeDelta = Vector2.New(347.2,288.4)
	self.taskicon_img.transform.localPosition = Vector3.New(-235,118,0)
	self.right_node.gameObject:SetActive(true)
end