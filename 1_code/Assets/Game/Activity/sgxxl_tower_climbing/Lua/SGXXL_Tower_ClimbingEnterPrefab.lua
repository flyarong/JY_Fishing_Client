-- 创建时间:2021-02-26
-- Panel:SGXXL_Tower_ClimbingEnterPrefab
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

SGXXL_Tower_ClimbingEnterPrefab = basefunc.class()
local C = SGXXL_Tower_ClimbingEnterPrefab
C.name = "SGXXL_Tower_ClimbingEnterPrefab"
local M = SGXXL_Tower_ClimbingManager
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
    self.lister["sgxxl_tower_climbing_cur_task_data_is_queried"] = basefunc.handler(self,self.on_sgxxl_tower_climbing_cur_task_data_is_queried)
    self.lister["sgxxl_tower_climbing_cur_task_data_is_change"] = basefunc.handler(self,self.on_sgxxl_tower_climbing_cur_task_data_is_change)
    self.lister["sgxxl_tower_climbing_fx_msg"] = basefunc.handler(self,self.on_sgxxl_tower_climbing_fx_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:StopHuxi()
	self:StopHuxi2()
	self:ClearTaskIcon()
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
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.slider = self.Slider.transform:GetComponent("Slider")

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.enter_btn.gameObject).onClick = basefunc.handler(self, self.OnEnterClick)
	EventTriggerListener.Get(self.get_btn.gameObject).onClick = basefunc.handler(self, self.OnGetClick)
	EventTriggerListener.Get(self.phb_btn.gameObject).onClick = basefunc.handler(self, self.OnPHBClick)
	self.ItemContent = GameObject.Find("Canvas/GUIRoot/EliminateGamePanel/Center/Viewport/ItemContent")
	M.QueryCurLayerTaskId()
end

function C:MyRefresh()
	local l_data = M.GetLastTaskData()
    if not l_data then
        Event.Brocast("sgxxl_tower_climbing_last_task_data_save")
    end
	self:RefreshUI()
end

function C:OnEnterClick()
	SGXXL_Tower_ClimbingPanel.Create()
end

function C:RefreshUI()
	local config = M.GetCurTaskConfig()
	if M.GetLastTaskCfg() then
		config = M.GetLastTaskCfg()
	end
	local data = M.GetCurTaskData()
	if M.GetLastTaskData() then
		data = M.GetLastTaskData()
	end
	if not data.other then
		local other = basefunc.parse_activity_data(data.other_data_str)
	    data.other = other
	end
	self.layer_txt.text = "第".. M.GetCurLayer() .."关"
	if not config then return end
	self.task_desc_txt.text = config.text
	self.slider.value = data.now_process / data.need_process
	self.progress_txt.text = data.now_process.."/"..data.need_process
	self:StopHuxi2()
	if data.award_status == 1 then
		M.SetIsShow("enter",true)
		self.can_get.gameObject:SetActive(true)
		self.cant_get.gameObject:SetActive(false)
		self.huxi_index2 = CommonHuxiAnim.Start(self.lq.gameObject)
	else
		self.can_get.gameObject:SetActive(false)
		self.cant_get.gameObject:SetActive(true)
	end
	self:ClearTaskIcon()
	for i=1,#config.task_icon do
		local pre = GameObject.Instantiate(self.icon,self.icon_node.transform)
		pre.gameObject:SetActive(true)
		pre.transform:Find("icon_img").gameObject:GetComponent("Image").sprite = GetTexture(config.task_icon[i])
		pre.transform:Find("need_txt").gameObject:SetActive(false)
		pre.transform:Find("gou").gameObject:SetActive(false)
		if config.limit_num[i] ~= -1 then
			if table_is_null(data.other) then
				if data.award_status == 1 then
					pre.transform:Find("gou").gameObject:SetActive(true)
				else
					pre.transform:Find("need_txt").gameObject:SetActive(true)
					pre.transform:Find("need_txt").gameObject:GetComponent("Text").text = config.limit_num[i]
				end
			else
				for k,v in pairs(data.other) do
					pre.transform:Find("need_txt").gameObject:SetActive(true)
					if k == M.index_map[tonumber(string.sub(config.task_icon[i],-1))] then
						local num = config.limit_num[i] - data.other[M.index_map[tonumber(string.sub(config.task_icon[i],-1))]]
						pre.transform:Find("need_txt").gameObject:GetComponent("Text").text = num
						pre.transform:Find("need_txt").gameObject:SetActive(num > 0)
						pre.transform:Find("gou").gameObject:SetActive(num <= 0)
						--dump(data.other[M.index_map[string.sub(config.task_icon[i],-1)]],"<color=yellow><size=15>+++++++++77777777+data++++++++++</size></color>")
						--dump(config.limit_num[i],"<color=yellow><size=15>++++++++++8888888config.limit_num[i]++++++++++</size></color>")
						--dump(num,"<color=yellow><size=15>++9999999999999++++++++data++++++++++</size></color>")
						
						break
					else
						pre.transform:Find("need_txt").gameObject:GetComponent("Text").text = config.limit_num[i]
					end
				end
			end
		end
		self.task_icon_cell[#self.task_icon_cell + 1] = pre
	end
	self:StopHuxi()
	self.flq.gameObject:SetActive(false)
	if not table_is_null(config.award_img) then
		for k,v in pairs(config.award_img) do
			if string.sub(v,1,11) == "ty_icon_flq" then
				self.huxi_pre = CommonHuxiAnim.Start(self.flq.gameObject)
				self.flq.gameObject:SetActive(true)
			end
		end
	end
end

function C:ClearTaskIcon()
	if self.task_icon_cell then
		for k,v in pairs(self.task_icon_cell) do
			destroy(v.gameObject)
		end
	end
	self.task_icon_cell = {}
end

function C:StopHuxi()
	if self.huxi_pre then
		CommonHuxiAnim.Stop(self.huxi_pre)
	end
	self.huxi_pre = nil
end

function C:StopHuxi2()
	if self.huxi_index2 then
		CommonHuxiAnim.Stop(self.huxi_index2)
	end
	self.huxi_index2 = nil
end

function C:on_sgxxl_tower_climbing_cur_task_data_is_queried()
	self:MyRefresh()
end

function C:on_sgxxl_tower_climbing_cur_task_data_is_change()
	if M.GetIsShow("enter") then
		--动画
		M.SetIsShow("enter",false)
		self.particle.gameObject:SetActive(true)
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(2)
		seq:OnForceKill(function ()
			if IsEquals(self.particle) then
				self.particle.gameObject:SetActive(false)
			end
			self:MyRefresh()
		end)
	else
		self:MyRefresh()
	end
end

function C:OnGetClick()
	M.GetAward()
end

function C:OnPHBClick()
	self.phb_pre = BY3DPHBGamePanel.Create()
	-- self.phb_pre:Selet(3)--默认选中水果消消乐爬塔榜
end

function C:on_sgxxl_tower_climbing_fx_msg(data)
	if IsEquals(self.ItemContent) then
		self:FxFlytoSS(self.ItemContent.transform,"sgxxl_tower_fx_prefab",Vector3.New(data.pos.x,data.pos.y,0),self.task_icon_cell[data.fly_index].transform.position,function ()
			Event.Brocast("sgxxl_tower_climbing_cur_task_data_is_change")
		end)
	else
		Event.Brocast("sgxxl_tower_climbing_cur_task_data_is_change")
	end
end


function C:FxFlytoSS(parent, prefab_name, beginPos, endPos, finish_call)
    local obj = GameObject.Instantiate(GetPrefab(prefab_name), parent).gameObject
    local path = {}
    local a = beginPos
    local b = endPos
    obj.transform.localPosition = beginPos
    path[0] = a
    --path[1] = Vector3.New((a.x > b.x and math.random(a.x,b.x) or math.random(b.x,a.x)) + 60,(a.y > b.y and math.random(a.y,b.y) or math.random(b.y,a.y)) + 60,0)
    path[1] = Vector3.New(b.x,b.y,0)
    local seq = DoTweenSequence.Create()
    seq:Append(obj.transform:DOPath(path,0.5,DG.Tweening.PathType.CatmullRom))
    seq:OnKill(function ()
        if finish_call and type(finish_call) == "function" then
            finish_call()
        end
    end)
    seq:OnForceKill(function ()
        destroy(obj)
    end)
end