-- 创建时间:2020-10-27
-- Panel:XRQTLTaskItemPrefab
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

XRQTLTaskItemPrefab = basefunc.class()
local C = XRQTLTaskItemPrefab
C.name = "XRQTLTaskItemPrefab"
local M = XRQTLManager

local task_id_ = 
	{
		[1000079] = true,
		[1000080] = true,
		[1000086] = true,
		[1000088] = true,
		[1000089] = true,
	}

function C.Create(parent, infor, index, parentPanel, day)
	return C.New(parent, infor, index, parentPanel, day)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["model_task_change_msg"] = basefunc.handler(self,self.MyRefresh)
    self.lister["XRQTL_DownCount_msg_new"] = basefunc.handler(self,self.MyRefresh)

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

function C:ctor(parent, infor, index, parentPanel, day)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.parentPanel = parentPanel
	self.day = day
	self.task_infor = infor
	self.index = index
	self.task_id = self.task_infor[self.index].task_id

	self.jd = self.task_infor[self.index].jd
	LuaHelper.GeneratingVar(self.transform, self)

	self.go_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:GetCurTaskJL(self.task_infor[self.index].goto_scene)
	end)


	self.get_btn.onClick:AddListener(function ()	
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			if task_id_[self.task_id] then
				Network.SendRequest("get_task_award_new", {id = self.task_id , award_progress_lv = self.jd},"请求奖励",
					function(data)
						if data.result == 0 then
							self:MyRefresh()
							self.parentPanel:RefreshShowRed()
							self.parentPanel:ShowTopTaskProgress()
						end
					end
				)
			else
				Network.SendRequest("get_task_award",{id = self.task_id},"请求奖励",
					function(data)
						if data.result == 0 then
							self:MyRefresh()
							self.parentPanel:RefreshShowRed()
							self.parentPanel:ShowTopTaskProgress()
						end
					end
				)
			end
		end)

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	self.task_ = GameTaskModel.GetTaskDataByID(self.task_id)
	if not self.task_ then self.task_ = GameTaskModel.GetTaskDataByID(self.task_id)	end
	if self.task_ then
		local b = basefunc.decode_task_award_status(self.task_.award_get_status)
		self.b = basefunc.decode_all_task_award_status(b, self.task_ , 7)

	end
	self:ShowUIByIndex(self.index)
	self:ShowBtnByTaskStarts(self.task_id)
end

--先获取天数，在获取第几个任务
function C:ShowUIByIndex(index)
  if self.task_ and IsEquals(self.gameObject) then
  --通过接口获取任务相关信息
    self.task_title_txt.text = self.task_infor[self.index].task_info 
    if self.task_ then
      if self.task_.id == 30031 then
        self.task_progress_now_txt.text = tostring(self.task_.now_total_process/100).."/"..self.task_infor[self.index].task_need
        if self.task_.now_total_process/100 >= tonumber(self.task_infor[self.index].task_need) then
          self.task_progress_now_txt.text = self.task_infor[self.index].task_need.. "/"..self.task_infor[self.index].task_need
        end
      else
        self.task_progress_now_txt.text = StringHelper.ToCash(self.task_.now_total_process).."/"..StringHelper.ToCash(self.task_infor[self.index].task_need)
        if self.task_.now_total_process >= tonumber(self.task_infor[self.index].task_need) then
          self.task_progress_now_txt.text = StringHelper.ToCash(self.task_infor[self.index].task_need).. "/"..StringHelper.ToCash(self.task_infor[self.index].task_need)
        end
      end
    else
      self.task_progress_now_txt.text = "0/0"
    end
    local x = tonumber(self.task_infor[self.index].task_need)
    self.Slider.gameObject:GetComponent("Slider").value = 
      self.task_.id == 30031 and self.task_.now_total_process/100/x or self.task_.now_total_process/x

    for i=1,2 do
      self["award"..i.."_txt"].text = self.task_infor[self.index].task_award_number[i]
      self["award"..i.."_img"].sprite = GetTexture(self.task_infor[self.index].task_award_image[i])
    end
  end
end

function C:ShowBtnByTaskStarts(task_id)
	if self.task_ and IsEquals(self.gameObject) then
	-- # 0-不能领取 | 1-可领取 | 2-已完成 | 3- 未启用
		if self.b[self.jd] == 0 then
			self.go_btn.gameObject:SetActive(true)
			self.already_get_img.gameObject:SetActive(false)
			self.get_btn.gameObject:SetActive(false)
		elseif self.b[self.jd] == 2 then
			self.go_btn.gameObject:SetActive(false)
			self.already_get_img.gameObject:SetActive(true)
			self.get_btn.gameObject:SetActive(false)
		else
			self.go_btn.gameObject:SetActive(false)
			self.already_get_img.gameObject:SetActive(false)
			self.get_btn.gameObject:SetActive(true)
		end
	end
	-- if self.b and task_id_[self.task_id] then
	-- 	for i=1,#self.b do
	-- 		if self.b[i] == 1 then
	-- 			self.parentPanel:ShowRed(self.day,true)
	-- 			return
	-- 		else
	-- 			self.parentPanel:ShowRed(self.day)
	-- 		end
	-- 	end
	-- else
	-- 	if self.task_.award_status == 1 then
	-- 		self.parentPanel:ShowRed(self.day,true)
	-- 	else
	-- 		self.parentPanel:ShowRed(self.day)
	-- 	end
	-- end
end

function C:GetCurTaskJL(goto_scene)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		--场景
		if goto_scene then
			--local parm = {gotoui=task_infor.gotoui[1], goto_scene_parm=config.gotoui[2]}
			GameManager.GuideExitScene({gotoui = goto_scene}, function ()
	            self:MyExit()
	            self.parentPanel:MyExit()      
	        end)
		else
			--默认前往3d捕鱼大厅
			GameManager.GuideExitScene({gotoui =  "game_Fishing3DHall"}, function ()
	            self:MyExit() 
	            self.parentPanel:MyExit()        
	        end)
		end
end

function C:GetData()
	if self.b then
		local d = {}
		d.index = self.index
		d.status = self.b[self.jd]
		d.pre = self
		return d
	end
end

function C:SetSiblingIndex(index)
	self.transform:SetSiblingIndex(index)
end
