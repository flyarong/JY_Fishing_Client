-- 创建时间:2019-06-13
-- 挑战任务

local basefunc = require "Game/Common/basefunc"

Fishing3DTZTaskPrefab = basefunc.class()
local C = Fishing3DTZTaskPrefab
C.name = "Fishing3DTZTaskPrefab"
local M = BY3DTaskManager

local act_task_icon_map = {
	obj_fish_free_bullet = {icon="by_imgf_mfzd", name="by_imgf_mfzd"},
	obj_fish_crit_bullet = {icon="by_imgf_bjsk1", name="by_imgf_bjsk1"},
	obj_fish_power_bullet = {icon="by_imgf_wlts1", name="by_imgf_wlts1"},
	obj_fish_3d_free_bullet = {icon="by_imgf_mfzd", name="by_imgf_mfzd"},
	obj_fish_3d_power_bullet = {icon="by_imgf_bjsk1", name="by_imgf_bjsk1"},
	obj_fish_3d_crit_bullet = {icon="by_imgf_wlts1", name="by_imgf_wlts1"},
}
function C.Create(parent, gameType)
	return C.New(parent, gameType)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["EnterForeGround"] = basefunc.handler(self, self.onEnterForeGround)
    self.lister["EnterBackGround"] = basefunc.handler(self, self.onEnterBackGround)
    self.lister["by3d_task_children_task_change_msg"] = basefunc.handler(self, self.on_by3d_task_children_task_change_msg)
    self.lister["by3d_task_children_task_finish_msg"] = basefunc.handler(self, self.on_by3d_task_children_task_finish_msg)    
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    if self.update_time then
    	self.update_time:Stop()
    	self.update_time = nil
    end

	self:RemoveListener()
	destroy(self.gameObject)
end
function C:OnDestroy()
	self:MyExit()
end

function C:onEnterForeGround()
	
end

function C:onEnterBackGround()
	
end

function C:ctor(parent, gameType)
	self.gameType = gameType

	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()
	LuaHelper.GeneratingVar(self.transform, self)
	self.transform.localPosition = Vector3.New(0,462,0)

	self:InitUI()
end

function C:InitUI()
	self.task_id = M.GetTZTaskID()
    self.task_cfg = M.GetTaskConfigByID(self.task_id)
    if FishingModel and FishingModel.Config and FishingModel.Config.fish_map then
		self.fish_cfg = FishingModel.Config.fish_map[self.task_cfg.fish_id]
	end

	self.get_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        Network.SendRequest("get_task_award", {id = self.task_id})
    end)
    EventTriggerListener.Get(self.BG.gameObject).onClick = basefunc.handler(self, self.OnBGClick)
    self.gameObject:SetActive(false)

    if M.m_data.get_parm then
    	local beginPos = M.m_data.get_parm.pos
    	M.m_data.get_parm = nil
		ExtendSoundManager.PlaySound(audio_config.by.bgm_by_tiaozhanrenwuchuxian.audio_name)
		local endPos = self.transform.position
		FishingAnimManager.PlayTZTaskAppear(GameObject.Find("Canvas/LayerLv2").transform, beginPos, endPos, function ()
			ExtendSoundManager.PlaySound(audio_config.by.bgm_by_tiaozhanrenxianshi.audio_name)
			self:MyRefresh()
		end)
	else
	    self:MyRefresh()
	end
end

function C:MyRefresh()
    
	local task = M.GetTZTaskData()
	if task then
		self:RefreshTask()
	    self.gameObject:SetActive(true)
	    self.fish_icon_img.sprite = GetTexture(self.fish_cfg.icon)

	    if task.award_status == 1 then
	    	self.GetRect.gameObject:SetActive(true)
	    else
	    	self.GetRect.gameObject:SetActive(false)
	    end
    	
    	if task.fix_award_data then
	    	local at_key = task.fix_award_data[1].award_data[1].asset_type
	    	local num = task.fix_award_data[1].award_data[1].asset_value or 1
	    	local item_cfg = GameItemModel.GetItemToKey(at_key)
	    	self.item_name = item_cfg.name
	    	self.award_img.sprite = GetTexture(item_cfg.image)
	    	self.award_num = num
	    	self.award_txt.text = StringHelper.ToCash(num)
    	else
    		self.item_name = "金币"
	    	self.award_num = self.task_cfg.award_value
	    	self.award_txt.text = StringHelper.ToCash(self.task_cfg.award_value)
		    if self.task_cfg.award_image then
			    self.award_img.sprite = GetTexture(self.task_cfg.award_image)
		    end
		end

	    self.time = tonumber(task.over_time) - os.time()

	    if tonumber(task.now_process) >= tonumber(task.need_process) then
	    	self.down_time_txt.gameObject:SetActive(false)
	    	self:StopTime()
	    else
	    	self.down_time_txt.gameObject:SetActive(true)
		    if self.time and self.time > 0 then
		    	self:StopTime()
			    self.update_time = Timer.New(function ()
			    	self:Update()
			    end, 1, -1)
			    self.update_time:Start()
			end
		    self:RefreshTime()
	    end
	else
		self:StopTime()
    	self.gameObject:SetActive(false)
	end
end
function C:RefreshTask()
	local task = M.GetTZTaskData()
	if task then
	    if task.award_status == 1 then
	    	self.GetRect.gameObject:SetActive(true)
	    	--self.tzrw_huo.gameObject:SetActive(true)
	    	self.jiangjin.gameObject:SetActive(true)
	    	self.chixu.gameObject:SetActive(false)
	    else
	    	self.GetRect.gameObject:SetActive(false)
	    	--self.tzrw_huo.gameObject:SetActive(false)
	    	self.jiangjin.gameObject:SetActive(false)
	    	self.chixu.gameObject:SetActive(true)
	    end

	    self.rate_txt.text = "<color=#FCF280>" .. task.now_process .. "</color>/" .. task.need_process
	end
end
function C:RefreshTime()
	if self.time and self.time >= 0 then
		local mm = math.floor(self.time / 60)
		local ss = self.time % 60
	    self.down_time_txt.text = string.format("%02d", mm) .. ":" .. string.format("%02d", ss)
	else
	    self.down_time_txt.text = "00:00"
	end
end
function C:StopTime()
	if self.update_time then
    	self.update_time:Stop()
    	self.update_time = nil
    end
end
function C:Update()
	if self.time > 0 then
		self.time = self.time - 1
		self:RefreshTime()
	end
end

function C:on_by3d_task_children_task_change_msg(data)
	self:RefreshTask()
end

function C:on_by3d_task_children_task_finish_msg(data)
	ExtendSoundManager.PlaySound(audio_config.by.bgm_by_tiaozhanrenwancheng.audio_name)
	self:RefreshTask()
end

function C:OnBGClick()
	if self.fish_cfg then
		local task = M.GetTZTaskData()
		LittleTips.Create(string.format("捕获%s条%s即可领取%s%s", task.need_process, self.fish_cfg.name, self.award_num, self.item_name))
	else
		LittleTips.Create("我也不知道是什么鱼")
	end
end