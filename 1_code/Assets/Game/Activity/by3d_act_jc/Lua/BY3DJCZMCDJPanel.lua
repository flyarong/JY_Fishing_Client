-- 创建时间:2020-08-14
-- Panel:BY3DJCZMCDJPanel
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

BY3DJCZMCDJPanel = basefunc.class()
local C = BY3DJCZMCDJPanel
C.name = "BY3DJCZMCDJPanel"
local  M = BY3DJCManager

local seq_layer_key = "BY3DJCZMCDJPanel"
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
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
    
    self.lister["fish_3d_get_lottery_pool_num_response"] = basefunc.handler(self, self.on_get_lottery_pool_num_response)
    self.lister["get_award_time_num_msg"] = basefunc.handler(self, self.get_award_time_num_msg)
   self.lister["enter_model_get_award_pool_num_msg"] = basefunc.handler(self, self.RefreshZMCJAwarPool)
    --self.lister["model_get_award_pool_num_msg"] = basefunc.handler(self, self.model_get_award_pool_num_msg)
    self.lister["model_fish_3d_query_geted_award_pool_num"] = basefunc.handler(self, self.MyRefresh)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
   
end

function C:MyExit()
	DOTweenManager.KillLayerKeyTween(seq_layer_key)
	GameComAnimTool.stop_number_change_anim(self.anim_tab)
	GameComAnimTool.stop_number_change_anim(self.anim_tab_1)
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
	
	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	Network.SendRequest("fish_3d_query_geted_award_pool_num")
	LuaHelper.GeneratingVar(self.transform, self)
	self.BackButton_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:MyExit()
    end)
    self.choujiang_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:CJButtonOnclick()
    end)

    self.no_choujiang_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:CJButtonOnclick()
    end)

    self.shuoming_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
       	BY3DJCGameRulesPanel.Create()
 	end)

    self.bg1_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
       	LittleTips.Create("在藏宝海湾获得鸿福巨奖后可参与抽奖")
 	end)

 	self.bg2_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
       	LittleTips.Create("在深海沉船获得鸿福巨奖后可参与抽奖")
 	end)
 	self.Animator_yg = self.bg.gameObject:GetComponent("Animator")
	self.Animator_1 = self.huojiang_1_img.transform:GetComponent("Animator")
	--self.Animator_2 = self.huojiang_2_img.transform:GetComponent("Animator")

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

end

function C:InitUI()
	M.QueryData()
	self.Animator_1:Play("BY3DJCHL2")
	--self.Animator_2:Play("BY3DJCJL_2_NO")
	self:MyRefresh()
end

function C:MyRefresh()
 	self.bzyhd_money = M.GetZMJCAward()
	GameComAnimTool.stop_number_change_anim(self.anim_tab)
	self.not_can_cj = true
	self.can_play_golw = true
	

	self:RefreshBZYHB()
	self:RefreshAwarPool(M.GetAwardPoolAll())
	self:ShowDiffBtn()
	self:ShowDJS()
	self:StartTimer()
	--self:BtnHuXiAnim()
end

function C:RefreshBZYHB(b)
	self.award_txt.text = self.bzyhd_money
	if b then
		self.seq = DoTweenSequence.Create({dotweenLayerKey=seq_layer_key})
		self.seq:Append(self.award_txt.gameObject.transform:DOScale(Vector3.New(1.3, 1.3, 1), 0.4):SetLoops(2, DG.Tweening.LoopType.Yoyo))
		self.seq:OnKill(function ()
       		self.award_txt.transform.localScale = Vector3.New(1,1,1)
    	end)
	end
end


function C:get_award_time_num_msg()
	local  zmcj_time = BY3DJCManager.GetZMCJTime()
	if zmcj_time then
		for i=1,#zmcj_time do
			self["can_"..i.."_txt"].text = zmcj_time[i]
		end
	else
		self.can_1_txt.text = "0"
		self.can_2_txt.text = "0"
		self:RefreshBZYHB(false)
	end
	self:ShowDiffBtn()
end

function C:RefreshAwarPool(data)
	self.sumaward_txt.text = tostring(data)	
end

function C:RefreshZMCJAwarPool(data)
	if self.not_can_cj then
		self.sumaward_txt.text = tostring(data.award)
	end
end

function C:StartTimer()
	self:StopTimer()
	self.main_timer = Timer.New(
        function ()
        self:ShowDJS()
        end
    ,1,-1)
    self.main_timer_1 = Timer.New(
        function ()
        end
    ,9,-1)
    self.main_timer_2 = Timer.New(
        function ()
        	if self.add_award_txt.gameObject.activeSelf  then
        		self.add_award_txt.gameObject:SetActive(false)
    		end
        end
    ,1,-1)

    self.main_timer:Start()
    self.main_timer_1:Start()
    self.main_timer_2:Start()
end

function C:StopTimer(  )
	if self.main_timer then
        self.main_timer:Stop()
        self.main_timer = nil
    end
    if self.main_timer_1 then
        self.main_timer_1:Stop()
        self.main_timer_1 = nil
    end
    if self.main_timer_2 then
        self.main_timer_2:Stop()
        self.main_timer_2 = nil
    end
end

function C:GetOverTime()
	local now_time = os.time()
	local day = math.floor((now_time - 3600 * 16) / 86400) 
	dump((day + 1) * 86400 + 3600 * 16)
	return (day + 1) * 86400 + 3600 * 16
end

function C:ShowDJS()
	if BY3DJCManager.IsZM() then
		self.daojishi_txt.text = "剩余时间"..StringHelper.formatTimeDHMS2(self:GetOverTime() - os.time())
	else
		self.daojishi_txt.text = "请于本周日前往抽奖" 
	end
end

function C:CJButtonOnclick()

	if BY3DJCManager.IsCreateZMCJPanel() then
		self.choujiang_btn.gameObject:SetActive(false)
		self.no_choujiang_btn.gameObject:SetActive(true)	
		Network.SendRequest("fish_3d_get_lottery_pool_num",{lottery_num = BY3DJCManager.GetSumTime()}, "")
		self.Animator_yg.enabled = true
		self.Animator_yg:Play("BY3DJCZMCDJPanel_bg",-1)
	else
		if BY3DJCManager.IsZM() then 
			LittleTips.Create("抽奖次数不足")
		else
			LittleTips.Create("请于本周日前往抽奖")
		end
	end
end


function C:on_get_lottery_pool_num_response(_,data)
	if data.result == 0 then
		self.not_can_cj = false
		self.award_4 = 0
		self.award_5 = 0
		self.award_money_4 = {}
		self.award_money_5 = {}
		for i = 1, #data.game_id do
			if data.game_id[i] == 4 then
				self.award_money_4 [#self.award_money_4 +1] = tonumber(data.money[i])
				self.award_4 = self.award_4 + tonumber(data.money[i])
			elseif data.game_id[i] == 5 then
				self.award_money_5 [#self.award_money_5 +1] = tonumber(data.money[i])
				self.award_5 = self.award_5 + tonumber(data.money[i])
			end
		end
		self:PlayAnimGold(1)
	else
		if data.result == 6401 then
			LittleTips.Create("抽奖条件不满足")
		elseif data.result == 6402 then
			LittleTips.Create("抽奖次数不足")
		end
	end
end

--动画
function C:PlayAnimGold(index)
	self.zhuanhuan.gameObject:SetActive(false)
	if index <= #self.award_money_4 then
			-- if index == 1 then
				self:PlayAnimGold1(self.sumaward_txt, self.award_money_4[index], index, self.bg1_btn.transform, self.node1.transform.position,1, nil)
			-- else
			-- 	self:PlayAnimGold2(self.award_1_txt, self.award_money_4[index], index)
			-- end	
	else
		if index <= (#self.award_money_5 + #self.award_money_4) then
				--if index == (1 + #self.award_money_4) then
					self:PlayAnimGold1(self.sumaward_txt, self.award_money_5[index-#self.award_money_4],
					 index,self.bg2_btn.transform,self.node2.transform.position, 2, nil)
				--else
				--	self:PlayAnimGold2(self.award_2_txt, self.award_money_5[index-#self.award_money_4], index)
				--end
		else
			-- 完成
			self:EndAnimPlay(self.award_4 + self.award_5)
		end
	end
end


--流光特效
function C:PlayAnimGold1(txt, money, index, parent, endPostion, number, call)
	--self.tx.gameObject:SetActive(true)
	self.fx_prefab = {"BY3DJCFXPrefab_CBHW","BY3DJCFXPrefab_SHCC"}
	local seq = DoTweenSequence.Create({dotweenLayerKey=seq_layer_key})
	--seq:AppendInterval(1.6)
	seq:OnKill(function ()
		self.tx.gameObject:SetActive(false)
       	-- GameComAnimTool.PlayShowAndHideAndCall(parent, "BY3DJCZMCDJ_glow", parent.position, 1, 0.12, function ()
		GameComAnimTool.PlayMoveAndHideFX(parent, self.fx_prefab[number], parent.position, endPostion, 0.6, 1, function ()
			self.xing1.gameObject:SetActive(false)
			self.xing2.gameObject:SetActive(false)
			self.jingbi.gameObject:SetActive(false)
			self.add_award_txt.gameObject:SetActive(false)
			self:PlayAnimGold2(txt, money, index, number)
	
			if number == 1 then
				self.can_1_txt.text = tonumber(self.can_1_txt.text) - 1
			elseif number == 2  then
				self.can_2_txt.text = tonumber(self.can_2_txt.text) - 1
			end
		end, nil,{dotweenLayerKey=seq_layer_key})
	-- end, nil, {dotweenLayerKey=seq_layer_key})	
    end)	
end


--数字动画
function C:PlayAnimGold2(txt, money, index, number)
	self.kuang.gameObject:SetActive(true)
	self.item_list = {}
	local LayerLv5 = GameObject.Find("Canvas/LayerLv5").transform
	if number == 1 then
		self._jingbi_1.gameObject:SetActive(true)
		self.deng1.gameObject:SetActive(true)
		self.Animator_1:Play("BY3DJCJLHX")
		self.nextPostion = self.node1.transform.position
		self.arr = MathExtend.SplitNumberToString(money, 8)
		-- for i = 1, 8 do
		-- 	self.item_list[#self.item_list + 1] = self["Mask"..number.."_"..i].gameObject
		-- end
	elseif number == 2 then
		self._jingbi_1.gameObject:SetActive(true)
		self.deng1.gameObject:SetActive(true)
		--self.Animator_2.enabled = true
		--self.Animator_2:Play("BY3DJCJL2")
		self.Animator_1:Play("BY3DJCJLHX")
		self.nextPostion = self.node2.transform.position
		self.arr = MathExtend.SplitNumberToString(money, 9)
		-- for i = 1, 9 do
		-- 	self.item_list[#self.item_list + 1] = self["Mask"..number.."_"..i].gameObject
		-- end
	end
	GameComAnimTool.stop_number_change_anim(self.anim_tab)
	GameComAnimTool.stop_number_change_anim(self.anim_tab_1)

	ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_count_1.audio_name)
	self.anim_tab = BY3DJCAnimManager.play_number_change_anim_samlltobig(txt, 0, money, 2, function ()
        self.anim_tab = nil
		local seq = DoTweenSequence.Create({dotweenLayerKey=seq_layer_key})
	    seq:AppendInterval(1)
	    seq:OnKill(function ()
	    	self._jingbi_1.gameObject:SetActive(false)
	    	local seq3=DoTweenSequence.Create({dotweenLayerKey=seq_layer_key})
      		seq3:AppendInterval(1)
      		seq3:OnKill(function()
    		ExtendSoundManager.PlaySound(audio_config.game.bgm_by_jiangchijinbi_fly.audio_name)
      		end)
    		BY3DJCAnimManager.PlayTYJBFly(LayerLv5, self.nextPostion, Vector3.New(120,220,0), nil, 2, function ()
    			local seq2 = DoTweenSequence.Create({dotweenLayerKey=seq_layer_key})
	    		seq2:AppendInterval(1)
	    		seq2:OnKill(function ()
    				self.zhuanhuan.gameObject:SetActive(true)
					self:RefreshAwarPool(M.GetAwardPoolAll())
				end)
	    	end, { dotweenLayerKey=seq_layer_key})
	    	end)
	    	local seq1 = DoTweenSequence.Create({dotweenLayerKey=seq_layer_key})
	    	seq1:AppendInterval(2)
	    	seq1:OnKill(function ()
		    
		    	self.anim_tab_1 = nil
		    	self.anim_tab_1 = BY3DJCAnimManager.play_number_change_anim(txt, money, 0, 0.8, function ()
					if IsEquals(self.gameObject) then
				    	self._jingbi_1.gameObject:SetActive(false)
		    			--self._jingbi_2.gameObject:SetActive(false)
		    			self.xing1.gameObject:SetActive(true)
		    			self.xing2.gameObject:SetActive(true)
		    			self.jingbi.gameObject:SetActive(true)
		    			self.add_award_txt.gameObject:SetActive(true)
		    			self:CurPanelShake()
		    			self.Animator_1:Play("BY3DJCHL2")
		    			--self.Animator_2:Play("BY3DJCJL_2_NO")
		    			self.deng1.gameObject:SetActive(false)
		    			self.kuang.gameObject:SetActive(false)
		    			--self.award_1_txt.text = 0 
						--self.award_2_txt.text = 0 
		    			ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_jiangli2.audio_name)
		    			self.bzyhd_money = self.bzyhd_money + money
		    			self.add_award_txt.text = "+"..money
		    			self:RefreshBZYHB(true)
						self:PlayAnimGold(index + 1)
					else
						return
					end	
		    	 end)
	    	end)
	    seq:OnForceKill(function (force_kill)
	    	if force_kill then
		    	-- 动画强制停止
		    	self:MyRefresh()
	    	end
	    end)
	end, function ()
    	-- 动画强制停止
    	self:MyRefresh()
    end) 
end


function C:EndAnimPlay(award)
	self.zhuanhuan.gameObject:SetActive(true)
	self.not_can_cj = true
	Network.SendRequest("fish_3d_query_geted_award_pool_num")
    self:RefreshBZYHB()
    self:StartTimer()
    --self.add_award_txt.gameObject:SetActive(false)
    --self.award_1_txt.gameObject:SetActive(true)
	--self.award_2_txt.gameObject:SetActive(true)
	-- self.award_1_txt.text = 0 
	-- self.award_2_txt.text = 0 
end

function C:CurPanelShake(t)
	t = t or 1
    local seq = DoTweenSequence.Create({ dotweenLayerKey=seq_layer_key})
    seq:Append(self.transform:DOShakePosition(t, Vector3.New(5, 5, 0), 20))
    seq:OnKill(function ()
        self.transform.position = Vector3.zero
    end)
end

function C:ShowDiffBtn()
	if BY3DJCManager.GetSumTime() > 0 and BY3DJCManager.IsCreateZMCJPanel() then
		self.choujiang_btn.gameObject:SetActive(true)
		self.no_choujiang_btn.gameObject:SetActive(false)
	else
		self.choujiang_btn.gameObject:SetActive(false)
		self.no_choujiang_btn.gameObject:SetActive(true)
	end
end
