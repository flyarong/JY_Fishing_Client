-- 创建时间:2020-12-14
-- Panel:VIPYJTZChildPrefab
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

VIPYJTZChildPrefab = basefunc.class()
local C = VIPYJTZChildPrefab
C.name = "VIPYJTZChildPrefab"

function C.Create(parent, index)
	return C.New(parent, index)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
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

function C:ctor(parent, index)
	self.index = index
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.slider = self.Progress:GetComponent("Slider")

	self:MakeLister()
	self:AddMsgListener()

	self.config = VIPManager.GetVIPYjtzCfgByIndex(self.index)
	self:InitUI()
end

function C:InitUI()
	self.GOButton_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		Event.Brocast("TRY_VIP_SHOW_TASK_COLSE")
		if MainModel.myLocation ~= "game_MiniGame" then
			local gotoparm = {gotoui = "game_MiniGame"}
	        GameManager.GuideExitScene(gotoparm, function ()
	            self:MyExit() 
	        end)
		end            
	end)
	self.LQButton_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		Network.SendRequest("get_task_award_new", { id = VIPManager.GetVIPYjtzTaskID(), award_progress_lv = self.index }, "", function (data)
			if data.result == 0 then
				if self.config.isreal == 1 then
					local string1 = "恭喜您获得" .. self.config.text .. "！\n，请联系客服QQ号4008882620领取！"
					HintCopyPanel.Create({ desc = string1 })
				end
			else
				HintPanel.ErrorMsg(data.result)
			end
		end)
	end)
	self.SWLQButton_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		if self.config.isreal == 1 then
			local string1 = "奖品:" .. self.config.text .. "\n，抽到奖励后请联系客服QQ号4008882620领取！"
			HintCopyPanel.Create({ desc = string1 })
		end
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	self.hint1_txt.text = "所有游戏累计赢金"
	self.hint2_txt.text = StringHelper.ToCash(self.config.need)

	local image = {}
	local text = {}
	if type(self.config.image) == "string" then
		image[#image + 1] = self.config.image
		text[#text + 1] = self.config.text
	else
		image = self.config.image
		text = self.config.text
	end
	for i = 1, #image do
		local obj = GameObject.Instantiate(self.AwardChild, self.content)
		obj.gameObject:SetActive(true)
		local ui = {}
		LuaHelper.GeneratingVar(obj.transform, ui)
		ui.icon_img.sprite = GetTexture(image[i])
    	ui.award_txt.text = text[i]
	end

	self:RefreshTask()
end

function C:RefreshTask()
	local task_data = GameTaskModel.GetTaskDataByID( VIPManager.GetVIPYjtzTaskID() )
	if not task_data then
		self.slider.value = 0
		self.jd_txt.text = StringHelper.ToCash(0) .. "/" .. StringHelper.ToCash(self.config.need)
		return
	end
	local award_status = basefunc.decode_task_award_status(task_data.award_get_status)
	award_status = basefunc.decode_all_task_award_status2(award_status, task_data, #VIPManager.GetVIPYjtzConfig())

	if self.index < task_data.now_lv then
		self.slider.value = 1
		self.jd_txt.text = StringHelper.ToCash(self.config.need) .. "/" .. StringHelper.ToCash(self.config.need)
	else
		self.slider.value = task_data.now_total_process / self.config.need
		self.jd_txt.text = StringHelper.ToCash(task_data.now_total_process) .. "/" .. StringHelper.ToCash(self.config.need)
	end

    self.GOButton_btn.gameObject:SetActive(false)
    self.LQButton_btn.gameObject:SetActive(false)
    self.SWLQButton_btn.gameObject:SetActive(false)
    self.MASK.gameObject:SetActive(false)
	if award_status[self.index] == 0 then
        self.GOButton_btn.gameObject:SetActive(true)
    elseif award_status[self.index] == 1 then 
        self.LQButton_btn.gameObject:SetActive(true)
    elseif award_status[self.index] == 2 then
        self.MASK.gameObject:SetActive(true)
    end
end

function C:UpdateData(index)
	self:RefreshTask()
	self.transform:SetSiblingIndex(index)
end
