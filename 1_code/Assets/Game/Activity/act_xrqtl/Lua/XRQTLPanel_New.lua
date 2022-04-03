-- 创建时间:2020-10-27
-- Panel:XRQTLPanel_New
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

XRQTLPanel_New = basefunc.class()
local C = XRQTLPanel_New
C.name = "XRQTLPanel_New"
local M = XRQTLManager

function C.Create(parent,backcall)
	return C.New(parent,backcall)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)

    --self.lister["global_hint_state_set_msg"] = basefunc.handler(self,self.on_global_hint_state_set_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.backcall then 
		self.backcall()
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

function C:ctor(parent,backcall)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.backcall = backcall
	LuaHelper.GeneratingVar(self.transform, self)

	self.task_list = M.GetCurDayTaskInfor()

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	self.close_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:MyExit()
	end)
	
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	self:CreateTopPrefab()
	self:CreateLeftPrefab()
	self:CreateRightPrefab()
	self:ShowTopTaskProgress()
	self:RefreshShowRed()
end

function C:CloseLeftPrefab()
	-- if self.day_btn_cell_map then
	-- 	for k,v in ipairs(self.day_btn_cell_map) do
	-- 		v:MyExit()
	-- 	end
	-- end

	if self.gift_cell_map then
		for i,v in ipairs(self.gift_cell_map) do
			v:MyExit()
		end
	end
	-- self.day_btn_cell_map = {}
	self.gift_cell_map = {}
end
function C:CreateLeftPrefab()
    self:CloseLeftPrefab()
    for i=1,7 do
    	destroyChildren(self["root"..i])
    end
   
	self.day_btn_cell_map = {}
	for i=1,7 do
		local pre_daybtn = XRQTLDayBtnItemPrefab.Create(self["root"..i], self, i)
		self.day_btn_cell_map[i] = pre_daybtn
	end
end



function C:CreateRightPrefab(index)
	self:CloseLeftPrefab()
	destroyChildren(self.content)
	local index = index or M.GetDayIndex()
	
	index = index > 7 and 7 or index
	
    self.gift_cell_map = {}
	for i=1,#self.task_list[1]do
		local pre = XRQTLTaskItemPrefab.Create(self.content.transform, self.task_list[index], i ,self , index)
		self.gift_cell_map[i] = pre
	end
	self:RefreshTaskSort()
end

function C:CreateTopPrefab()
	destroyChildren(self.Content_jl)
	--local self_b = {}
	for i=1,6 do
		-- local b = newObject("XRQTLJLItemPrefab", self.Content_jl)
		-- local tran_b = b.transform
		-- LuaHelper.GeneratingVar(tran_b, self_b)
		-- self_b.jl_btn.onClick:AddListener(function ()
  --          	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
  --       	self:MyExit()
		-- end)
		XRQTLJLItemPrefab.Create(self.Content_jl.transform, i)
	end
end

function C:ShowTopTaskProgress()
	local task_infor = GameTaskModel.GetTaskDataByID(30032)
	if not task_infor then return end
	self.jf_txt.text = tostring(task_infor.now_total_process)
	local progress = task_infor.now_process
		/(task_infor.need_process + task_infor.now_process)	

	--
	local x = task_infor.now_total_process

	local _lengrh = {68,228,378,538,698,858,} 

	self._i = 1
	for i=1,6 do
		if x >= self.task_list[#self.task_list][i].stage then
			self["dian"..i].gameObject:SetActive(true)
			self._i = i +1
		end
	end
	if self._i > 1 and self._i< 7 then
		local _lengrh_p = _lengrh[self._i-1]+(_lengrh[self._i] - _lengrh[self._i-1])*progress
		self.p_lengh.gameObject:GetComponent("RectTransform").sizeDelta = Vector2.New(_lengrh_p,29) 
	else
		if self._i ==  1 then 
			self.p_lengh.gameObject:GetComponent("RectTransform").sizeDelta = Vector2.New(68*progress,29)
		else
		 	self.p_lengh.gameObject:GetComponent("RectTransform").sizeDelta = Vector2.New(858,29)
	 	end
	end
end

-- function C:on_global_hint_state_set_msg(data)

-- 	if data and data.gotoui == M.key and IsEquals(self.gameObject) then 
-- 		self:MyRefresh()
-- 	end 
-- end




function C:RefreshSelet(index)

	local index = index or M.GetDayIndex()
	index = index > 7 and 7 or index
	for k,v in pairs(self.day_btn_cell_map) do
		v:RefreshSelet(index)	
	end
	print(debug.traceback())
	dump(index,"<color=yellow><size=15>++++++++++data++++++++++</size></color>")
	for i=1,7 do
		if index == i then
			self["click_"..index].gameObject:SetActive(true)
		else
			self["click_"..i].gameObject:SetActive(false)
		end
	end	
end


function C:RefreshShowRed()
	-- if IsEquals(self.gameObject) then
	-- 	if index  and index <= M.GetDayIndex() then
	-- 	    if b then    
	-- 	    	self["Red"..index].gameObject:SetActive(true)
	-- 	    	return
	--     	else
	--     		self["Red"..index].gameObject:SetActive(false)
	-- 		end
	--     end
 	--    end

 	for i = 1, 7 do
 		self["Red"..i].gameObject:SetActive(M.IsAwardCanGet(i))
 	end
end

function C:RefreshTaskSort()
	if self.gift_cell_map then

		local ll = {}
		for i,v in ipairs(self.gift_cell_map) do
			ll[#ll + 1] = v:GetData()
		end

	    local callSortGun = function(v1,v2)
	        if v1.status == 1 and v2.status ~= 1 then
	            return false
	        elseif v1.status ~= 1 and v2.status == 1 then
	            return true
	        else
	            if v1.status ~= 2 and v2.status == 2 then
	                return false
	            elseif v1.status == 2 and v2.status ~= 2 then
	                return true
	            else
	                if v1.index < v2.index then
	                    return false
	                else
	                    return true
	                end
	            end
	        end
	    end

    	MathExtend.SortListCom(ll, callSortGun)

		for i,v in ipairs(ll) do
			v.pre:SetSiblingIndex(i)
		end
	end
end

function C:on_model_task_change_msg(task)
	if M.IsCareTask(task.id) then
		self:RefreshTaskSort()
	end
end