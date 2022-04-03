-- 创建时间:2020-08-14
-- Panel:BY3DJCGameShowPanel
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

BY3DJCGameShowPanel = basefunc.class()
local C = BY3DJCGameShowPanel
C.name = "BY3DJCGameShowPanel"


local seq_layer_key = "BY3DJCGameShowPanel"
function C.Create(parm)
	return C.New(parm)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
    self.lister["now_have_jc_index_msg"] = basefunc.handler(self, self.on_now_have_jc_index_msg)
    self.lister["enter_model_get_award_pool_num_msg"] = basefunc.handler(self, self.on_enter_model_get_award_pool_num_msg)
    self.lister["change_game_show_font_color_msg"] = basefunc.handler(self,self.on_change_game_show_font_color_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	DOTweenManager.KillLayerKeyTween(seq_layer_key)
	self:StopTimer()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parm)
	self.parm = parm
	local parent = parm.parent or GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self.shuoming_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnPlayerExplainClick()
    end)


    self.gotocj_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        BY3DJCZMCDJPanel.Create()
    end)
    Network.SendRequest("fish_3d_query_geted_award_pool_num")
	self.mask.gameObject:SetActive(false)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	if MainModel.myLocation == "game_Fishing3D" and FishingModel  and FishingModel.game_id == 4 then
	  self.game_id=4
    elseif  MainModel.myLocation == "game_Fishing3D" and FishingModel  and FishingModel.game_id == 5 then
	  self.game_id=5
	end

end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	local had_get =  BY3DJCManager.GetSumTime()
	if not BY3DJCManager.IsCreateZMCJPanel() then
		if had_get <= 4 then
			for i = 1,had_get  do
				self["zi_"..i.."_img"].gameObject:SetActive(true)
			end
		else
			for i = 1,4 do
				self["zi_"..i.."_img"].gameObject:SetActive(true)
			end
		end	
	else
		for i = 1,4 do
			self["zi_"..i.."_img"].gameObject:SetActive(true)
		end
	end
	self:StartTimer()
end


--创建说明界面
function C:OnPlayerExplainClick()
	JCExplainPrefab.Create()
end


function C:on_enter_model_get_award_pool_num_msg(data)
       local curaward=BY3DJCManager.GetAwardPoolByGameID(self.game_id)
       self.score_txt.text=math.floor(curaward)
end

function C:on_change_game_show_font_color_msg()
	Network.SendRequest("fish_3d_query_geted_award_pool_num")
	local had_get = BY3DJCManager.GetSumTime()
	if had_get <= 4  and not BY3DJCManager.IsCreateZMCJPanel() then
		self.mask.gameObject:SetActive(true)
		self.transform:GetComponent("Animator").enabled = true	
	else
		self.transform:GetComponent("Animator").enabled = false	
	end
	if not BY3DJCManager.IsCreateZMCJPanel() then
		if had_get <= 4 then
			for i = 1,had_get  do
				self["zi_"..i.."_img"].gameObject:SetActive(true)
			end
			self.transform:GetComponent("Animator"):Play("BY3DJCGameShowPanel_0"..had_get)
		else
			for i = 1,4 do
				self["zi_"..i.."_img"].gameObject:SetActive(true)
			end
		end	
	elseif BY3DJCManager.IsCreateZMCJPanel() then
		self.transform:GetComponent("Animator").enabled = false
		self.mask.gameObject:SetActive(false)
		self:MyRefresh()
	end
	self:StartTimer()
end

--显示还有几次的气泡提示
function C:on_now_have_jc_index_msg()
	Network.SendRequest("fish_3d_query_geted_award_pool_num")
	local have_get = 3
	if have_get <= 3 then
		if not BY3DJCManager.IsCreateZMCJPanel() then
			have_get = have_get - BY3DJCManager.GetSumTime()
			self.txtbg.gameObject:SetActive(true)
			if have_get <= 0 and BY3DJCManager.IsZM() then
				self.info_txt.text = "点击抽取丰厚奖励"
				self.gotocj_btn.gameObject:SetActive(true)
			elseif have_get <= 0 and not BY3DJCManager.IsZM() then
				self.info_txt.text = "超级大奖，周末抽取"
			elseif have_get ~= 0 then
				self.info_txt.text = "再分"..have_get.."次奖励可抽大奖"
			end
		else
			if BY3DJCManager.IsCreateZMCJPanel() then
				self.txtbg.gameObject:SetActive(true)
				if BY3DJCManager.IsZM() then
					self.info_txt.text = "点击抽取丰厚奖励"
				else
					self.info_txt.text = "超级大奖，周末抽取"
				end
			end
		end
	end	
	local seq = DoTweenSequence.Create({dotweenLayerKey=seq_layer_key})
    seq:AppendInterval(3)
    seq:OnKill(function () 
       self.txtbg.gameObject:SetActive(false)
    end)
end


function C:StartTimer()
	self:StopTimer()
	self.main_timer = Timer.New(
        function ()
        	if self.mask.gameObject.activeSelf == true then
        		self.mask.gameObject:SetActive(false)
    		end
        end
    ,3,1)
    self.main_timer:Start()
end

function C:StopTimer()
	if self.main_timer then
        self.main_timer:Stop()
        self.main_timer = nil
    end
    if self.Main_timer then
    	self.Main_timer:Stop()
    	self.Main_timer = nil
	end
end

function C:StartTimer_CS()
	dump(self.txtbg.gameObject.activeSelf)
	self:StopTimer()
	self.Main_timer = Timer.New(
		function ()
        	if self.txtbg.gameObject.activeSelf then
        		self.txtbg.gameObject:SetActive(false)
    		end
        end
    ,3,1)
	self.Main_timer:Start()	
end