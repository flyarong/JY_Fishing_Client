local basefunc = require "Game/Common/basefunc"

Act_015_YYBJSJPanel = basefunc.class()
local C = Act_015_YYBJSJPanel
C.name = "Act_015_YYBJSJPanel"
local M = Act_015_YYBJSJManager

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
	self.lister["AssetsGetPanelConfirmCallback"] = basefunc.handler(self,self.AssetsGetPanelConfirmCallback)
	self.lister["model_task_change_msg"] = basefunc.handler(self,self.model_task_change_msg)
	self.lister["manager_multicast_msg"] = basefunc.handler(self,self.manager_multicast_msg)
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	DSM.PopAct()
	if self.timer then
		self.timer:Stop()
		self.timer = nil
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:ctor(parent)
	M.SetHintState({gotoui = M.key})

	ExtPanel.ExtMsg(self)
	DSM.PushAct({panel = C.name})
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.bro_state = 0
	PlayerPrefs.SetInt(M.key .. MainModel.UserInfo.user_id  ..os.date("%x",os.time()),1)
end

function C:InitUI()
	self.help_btn.onClick:AddListener(
		function ()
			Act_015_YYBJSJHelpPanel.Create(self.transform,Act_015_YYBJSJManager.GetCurTaskData())
		end
	)
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self.goto_btn.onClick:AddListener(
		function ()		
			if self.config.game == 1 then
					--判断种苹果显示权限
					local CheckZPGPermission = function()
						local _permission_key = "drt_guess_apple_play"
						if _permission_key then
							local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = false}, "CheckCondition")
							if a and not b then
								return false
							end
							return true
						else
							return true
						end
					end
					if CheckZPGPermission() then
						GameManager.GuideExitScene({gotoui="game_ZPG", goto_scene_parm=true}, function ()
							
						end)
					end
			
			elseif self.config.game == 2 then
				local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "cpl_cjj", is_on_hint = true}, "CheckCondition")
				if a and b then
					GameManager.GuideExitScene({gotoui="game_EliminateXY", goto_scene_parm=true, enter_scene_call=function()
						if not Network.SendRequest("xxl_xiyou_enter_game", nil ,"正在进入") then
							HintPanel.Create(1, "网络异常", function()
								GameManager.GotoSceneName("game_MiniGame")
							end)
						end
					end})
				else
					GameManager.GuideExitScene({gotoui="game_Fishing3DHall"})
				end
			elseif self.config.game == 3 then
				local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "sgxxl_level", is_on_hint = false}, "CheckCondition")
				if a and b then
					GameManager.GuideExitScene({gotoui="game_Eliminate", goto_scene_parm=true, enter_scene_call=function()
						if not Network.SendRequest("xxl_enter_game", nil ,"正在进入") then
							HintPanel.Create(1, "网络异常", function()
								GameManager.GotoUI({gotoui = "game_MiniGame"})
							end)
						end
					end})
				end			
			end
			self:MyExit()
			Event.Brocast("exit_fish_scene")
		end
	)
	self.get_btn.onClick:AddListener(
		function ()
			Network.SendRequest("get_task_award",{id = Act_015_YYBJSJManager.task_id})
		end
	)
	self.end_btn.onClick:AddListener(
		function ()
			local et = StringHelper.GetTodayEndTime()
            if et - os.time() < 2.5 * 3600 then
                LittleTips.Create("请于明晚21:30来拆福利券")
            elseif et - os.time() > 10 * 3600 then
                LittleTips.Create("请于今晚21:30来拆福利券")
            end
		end
	)
	self.determine_btn.onClick:AddListener(
		function ()
			dump(self.choose_game_id,"<color=yellow>self.choose_game_id???</color>")

			if MainModel.GetItemCount("jing_bi") < 10000 then
				LittleTips.Create("您的金币不足")
				return
			end

			if not self.choose_game_id then
				LittleTips.Create("请选择一个目标")
				return
			end
			Network.SendRequest("sleep_act_choose_game",{choose_game_id = tonumber(self.choose_game_id)},function(data)
				if data.result ~= 0 then
					HintPanel.ErrorMsg(data.result)
					return
				end
				self:MyRefresh()
			end)
		end
	)
	for i=1,3 do
		self[i .. "_tge"].onValueChanged:AddListener(
        function(val)
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if val then
                self.choose_game_id = i
            end
        end
    )
	end
	self.pmd_ret = self.pmd_txt.transform:GetComponent("RectTransform")
	self:MyRefresh()
end

function C:MyRefresh()
	---------------------第二条任务不同-------------
	local _str = "在海底宝藏及以上场次中任意捕获1只boss"
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "cpl_cjj", is_on_hint = true}, "CheckCondition")
	if a and b then
		_str = "西游消消乐同时消除3个唐僧"
	end

	self.Label2_txt.text = "2." .. _str
	---------------------------------------------
	self.config = Act_015_YYBJSJManager.GetCurTaskData()
	dump(self.config)
	local state = Act_015_YYBJSJManager.GetActState()
	self.hb_txt.text = self.config.cfg.hb
	if state == Act_015_YYBJSJManager.state.not_sign_up then
		self.not_start.gameObject:SetActive(true)
		self.running.gameObject:SetActive(false)
	else
		self.not_start.gameObject:SetActive(false)
		local s = ""
		if self.config.game == 1 then
			s = "苹果大战种出1次金苹果"
			self.target_yq_txt.text = self.config.cfg.game_zpg
		elseif self.config.game == 2 then
			s = _str
			self.target_yq_txt.text = self.config.cfg.game_by
		elseif self.config.game == 3 then
			s = "水果消消乐出1次幸运时刻"
			self.target_yq_txt.text = self.config.cfg.game_xxl_sg
		end
		self.target_txt.text = string.format("%s  %s<color=#38f35bff>/%s</color>",s,self.config.td.now_process,self.config.td.need_process)
		self.goto_btn.gameObject:SetActive(self.config.td.award_status == 0)
		self.get_btn.gameObject:SetActive(self.config.td.award_status == 1)
		self.end_btn.gameObject:SetActive(self.config.td.award_status == 2)
		self.time_txt.text = StringHelper.formatTimeDHMS(self.config.td.over_time - os.time())
		if self.timer then
			self.timer:Stop()
			self.timre = nil
		end
		self.timer = Timer.New(function()
			self.time_txt.text = StringHelper.formatTimeDHMS(self.config.td.over_time - os.time())
		end,1,-1,false,false)
		self.timer:Start()
		self.running.gameObject:SetActive(true)
	end
end

function C:AssetsGetPanelConfirmCallback(data)
	self:MyRefresh()
end

function C:model_task_change_msg(data)
	if not data or data.id ~= Act_015_YYBJSJManager.task_id then return end
	self:MyRefresh()
end

function C:manager_multicast_msg()
	if self.bro_state == 1 then return end
	if not IsEquals(self.pmd_txt) then return end
	local bd = GameBroadcastManager.GetWinSleepFront()
	if not bd then return end
	if table_is_null(bd) then return end
	self.pmd_txt.text = bd.msg.content
	self:RunBoradcast()
end

function C:RunBoradcast()
	self.bro_state = 1
	local seq = DoTweenSequence.Create()
	seq:Append(self.pmd_txt.transform:DOLocalMoveY(-30,2))
	seq:SetEase(DG.Tweening.Ease.OutCirc)
	seq:AppendInterval(5)
	seq:Append(self.pmd_txt.transform:DOLocalMoveY(30,2))
	seq:OnForceKill(function ()
		self.bro_state = 0
		if IsEquals(self.pmd_ret) then
			self.pmd_ret.anchoredPosition = Vector2.New(0,-60)
			self:manager_multicast_msg()
		end
	end)
	seq:OnKill(function ()
		self.bro_state = 0
		if IsEquals(self.pmd_ret) then
			self.pmd_ret.anchoredPosition = Vector2.New(0,-60)
		end
		-- self:manager_multicast_msg()
	end)
end

function C:OnExitScene(  )
	self:MyExit()
end