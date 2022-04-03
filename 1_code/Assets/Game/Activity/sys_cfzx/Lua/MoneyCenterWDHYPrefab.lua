-- 创建时间:2018-12-21

local basefunc = require "Game.Common.basefunc"

MoneyCenterWDHYPrefab = basefunc.class()

local C = MoneyCenterWDHYPrefab

C.name = "MoneyCenterWDHYPrefab"


function C.Create(parent_transform, config, call, panelSelf)
	return C.New(parent_transform, config, call, panelSelf)
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
	if self.lister then
		for proto_name,func in pairs(self.lister) do
			Event.RemoveListener(proto_name, func)
		end
	end
    self.lister = {}
end

function C:OnDestroy()
	GameObject.Destroy(self.gameObject)
	self:MyExit()
end

function C:MyExit()
	self:RemoveListener()
end

function C:ctor(parent_transform, config, call, panelSelf)
	self.config = config 
	if self.config.is_buy_vip_lb==nil then
		self.config.is_buy_vip_lb=0
	end 
	if self.config.is_buy_goldpig1 == nil then 
		self.config.is_buy_goldpig1=0
	end 
	if self.config.is_buy_goldpig2==nil then
		self.config.is_buy_goldpig2=0
	end 
	if self.config.vip_lb_contribution_num == nil then 
		self.config.vip_lb_contribution_num=0
	end 
	if self.config.goldpig_lb1_contribution_num== nil then
		self.config.goldpig_lb1_contribution_num=0
	end 
	if self.config.goldpig_lb2_contribution_num==nil then
		self.config.goldpig_lb2_contribution_num=0
	end 

	if self.config.is_buy_all_return_bag_1 ==nil then
		self.config.is_buy_all_return_bag_1 =0
	end
	if self.config.is_buy_all_return_bag_2 ==nil then
		self.config.is_buy_all_return_bag_2 =0
	end
	if self.config.is_buy_all_return_bag_3 ==nil then
		self.config.is_buy_all_return_bag_3 =0
	end

	self.call = call
	self.panelSelf = panelSelf
	local obj = newObject(C.name, parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()
    LuaHelper.GeneratingVar(self.transform, self)

    self.lock_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnClick()
    end)

    self:InitUI()
end

function C:InitUI()
	dump(self.config, "<color=yellow>玩家数据</color>")
	-- dump(GameMoneyCenterModel.data, "<color=white>玩家数据</color>")
	self.id_txt.text = string.format( "ID:%s",self.config.id)
	self.name_txt.text = StringHelper.SubCN(self.config.name, 5) .. "..."
	self.create_time_txt.text = string.format( "%s\n%s",os.date("%Y/%m/%d", self.config.m_register_time),os.date("%H:%M", self.config.m_register_time) )
	if self.config.last_login_time then
		self.lastlogin_time_txt.text = string.format( "%s\n%s",os.date("%Y/%m/%d", self.config.last_login_time),os.date("%H:%M", self.config.last_login_time))
		if os.time() - self.config.last_login_time >= 72 * 60 * 60 then
			self.share_btn.gameObject:SetActive(true)
		end
	else
		self.lastlogin_time_txt.text = string.format( "未登录")
		self.share_btn.gameObject:SetActive(true)
	end
	self.money_txt.text = StringHelper.ToRedNum(self.config.my_all_gx) .. "元"
	self.share_btn.onClick:AddListener(function ()
		self:OnShareClick()
	end)

	for i=1,3 do
		self["gift" .. i .. "_not"].gameObject:SetActive(self.config["is_buy_all_return_bag_" .. i] == 0)
	end
	--老版本比赛奖功能屏蔽
	if true then return end

	--测试数据
	local MCData = GameMoneyCenterModel.data
	local my_data = {}
	my_data.player = {}
	my_data.player.status = self.config.now_bbsc_big_step > 2 or (self.config.now_bbsc_big_step == 2 and self.config.bbsc_big_step_is_complete == 1) and self.config.m_register_time > 1557763200
	my_data.player.day = self.config.now_bbsc_big_step
	my_data.player.award = MCData.xj_award_num or 0
	my_data.match = {}
	my_data.match.status = (self.config.now_bbsc_big_step > 2   or (self.config.now_bbsc_big_step == 2 and self.config.bbsc_big_step_is_complete == 1)) and self.config.is_join_qys == 1 and self.config.bisai_contribution_num > 0
	my_data.match.day = 2
	my_data.match.award = MCData.bisai_award_num or 0
	my_data.gift = {}
	my_data.gift.vip_status = self.config.is_buy_vip_lb == 1
	my_data.gift.vip_award = MCData.vip_lb_award_num or 0
	my_data.gift.pig1_status = self.config.is_buy_goldpig1 == 1 or self.config.is_buy_goldpig1_old == 1
	my_data.gift.pig1_award = MCData.goldpig1_award_num or 0
	my_data.gift.pig2_status = self.config.is_buy_goldpig2 == 1
	my_data.gift.pig2_award = MCData.goldpig2_award_num or 0
	-- my_data.is_buy_all_return_bag_1 
	-- dump(my_data, "<color=white>my_data</color>")

	if GameMoneyCenterModel.data.is_activate_bisai_profit == 1 then
		self.match_img.gameObject:SetActive(not my_data.match.status)
	else
		self.match_img.gameObject:SetActive(true)
	end
	if GameMoneyCenterModel.data.is_activate_xj_profit == 1  then
		self.player_img.gameObject:SetActive(not my_data.player.status)
	else
		self.player_img.gameObject:SetActive(true)
	end
	if GameMoneyCenterModel.data.is_active_tglb1_profit == 1 then
		self.gift_img.gameObject:SetActive(not (my_data.gift.vip_status and my_data.gift.pig1_status and my_data.gift.pig2_status and self.config.m_register_time >1557763200 and self:GetStages_gift(my_data)))
	else
		self.gift_img.gameObject:SetActive(true)
	end

	PointerEventListener.Get(self.player_img.gameObject).onDown = basefunc.handler(self,function (  )
		if MCData.is_activate_xj_profit and MCData.is_activate_xj_profit == 1 then
			GameTipsPrefab.ShowDesc(string.format("新人红包第%s天，好友再完成1天，您可增加%s元收益！",my_data.player.day, StringHelper.ToCash(my_data.player.award / 100)) ,nil,GameTipsPrefab.TipsShowStyle.TSS_4)
		else
			GameTipsPrefab.ShowDesc(string.format("您还没有开通玩家奖，请联系客服开通"),nil,GameTipsPrefab.TipsShowStyle.TSS_4)
		end
	end)
	PointerEventListener.Get(self.player_img.gameObject).onUp = basefunc.handler(self, function (  )
		GameTipsPrefab.Hide()
	end)

	PointerEventListener.Get(self.match_img.gameObject).onDown = basefunc.handler(self,function (  )
		if MCData.is_activate_bisai_profit and MCData.is_activate_bisai_profit == 1 then
			if self.config.is_join_qys  >0 and  self.config.bisai_contribution_num ==0  then
				if not   (self.config.now_bbsc_big_step >2 or (self.config.now_bbsc_big_step==2 and self.config.bbsc_big_step_is_complete==1)) then
					GameTipsPrefab.ShowDesc(string.format( "好友完成新人红包第%s天任务且参与千元赛取得任意名次，您可增加%s元收益！",my_data.match.day,StringHelper.ToCash(my_data.match.award / 100)),nil,GameTipsPrefab.TipsShowStyle.TSS_4)	
				else
					GameTipsPrefab.ShowDesc("该好友非首次参加千元赛，无法贡献此奖励。",nil,GameTipsPrefab.TipsShowStyle.TSS_4)
				end
			else 
				GameTipsPrefab.ShowDesc(string.format( "好友完成新人红包第%s天任务且参与千元赛取得任意名次，您可增加%s元收益！",my_data.match.day,StringHelper.ToCash(my_data.match.award / 100)),nil,GameTipsPrefab.TipsShowStyle.TSS_4)
			end	
		else
			GameTipsPrefab.ShowDesc(string.format("比赛奖权限未开通，详情查看【如何赚钱】页面"),nil,GameTipsPrefab.TipsShowStyle.TSS_4)
		end
	end)
	PointerEventListener.Get(self.match_img.gameObject).onUp = basefunc.handler(self, function (  )
		GameTipsPrefab.Hide()
	end)

	PointerEventListener.Get(self.gift_img.gameObject).onDown = basefunc.handler(self,function ()
		if self.config.vip_lb_contribution_num > 0 and self.config.goldpig_lb1_contribution_num >0 and self.config.goldpig_lb2_contribution_num >0  then 
			self.gift_img.gameObject:SetActive(false)
		elseif self:GetStages_gift2(my_data) then
			local s1 = my_data.gift.vip_status and "已购买" or "未购买"
			local s2 = my_data.gift.pig1_status and "已购买" or "未购买"
			local s3 = my_data.gift.pig2_status and "已购买" or "未购买"	
			GameTipsPrefab.ShowDesc(self:GetStr_gift(s1,s2,s3,my_data),nil,GameTipsPrefab.TipsShowStyle.TSS_4)
		elseif MCData.is_active_tglb1_profit and MCData.is_active_tglb1_profit == 1 then
			local s1 = my_data.gift.vip_status and "已购买" or "未购买"
			local s2 = my_data.gift.pig1_status and "已购买" or "未购买"
			local s3 = my_data.gift.pig2_status and "已购买" or "未购买"	
			GameTipsPrefab.ShowDesc(self:GetStr_gift(s1,s2,s3,my_data),nil,GameTipsPrefab.TipsShowStyle.TSS_4)
		else
			GameTipsPrefab.ShowDesc(string.format("礼包奖权限未开通，详情查看【如何赚钱】页面"),nil,GameTipsPrefab.TipsShowStyle.TSS_4)
		end
	end)
	PointerEventListener.Get(self.gift_img.gameObject).onUp = basefunc.handler(self, function (  )
		GameTipsPrefab.Hide()
	end)
end


function C:GetStr_gift(s,ss,sss,my_data)
	dump(my_data,"<color=red>my_datamy_datamy_datamy_datamy_datamy_data</color>")
	local s1=string.format("VIP礼包：%s，贡献%s元;",s,StringHelper.ToCash(my_data.gift.vip_award / 100)) 
	local s2=string.format("金猪199：%s，购买后您可增加%s元收益！",ss,StringHelper.ToCash(my_data.gift.pig1_award / 100))
	local s3=string.format("金猪499：%s，购买后您可增加%s元收益！",sss,StringHelper.ToCash(my_data.gift.pig2_award / 100))
	
	if self.config.is_buy_vip_lb > 0 and self.config.vip_lb_contribution_num ==0 then
		s1="VIP礼包：该好友在您权限开通前已购买礼包，无法贡献此奖励。"
	end 
	if self.config.m_register_time <1557763200  then
		s1="VIP礼包：该好友非新玩家，无法贡献此奖励。"
	end 
	if ss=="已购买" then
		local s2=string.format("金猪199：%s，为您贡献%s元收益!",ss,StringHelper.ToCash(my_data.gift.pig1_award / 100))
	end
	if sss=="已购买" then
		local s3=string.format("金猪499：%s，为您贡献%s元收益!",sss,StringHelper.ToCash(my_data.gift.pig2_award / 100))
	end 
	if self.config.is_buy_goldpig1 > 0 and self.config.goldpig_lb1_contribution_num ==0 then
		dump(self.config,"")
		s2="金猪199：该好友在您权限开通前已购买礼包，无法贡献此奖励。"
	end 
	if self.config.is_buy_goldpig2   > 0 and self.config.goldpig_lb2_contribution_num  ==0 then
		s3="金猪499：该好友在您权限开通前已购买礼包，无法贡献此奖励。"
	end 
	return  s1.."    \n"..s2.."    \n"..s3
end

function C:GetStages_gift(my_data)
	local b1 = true
	local b2 = true
	local b3 = true
	if self.config.is_buy_vip_lb > 0 and self.config.vip_lb_contribution_num ==0 then
		b1=false
	end 
	if self.config.is_buy_goldpig1 > 0 and self.config.goldpig_lb1_contribution_num ==0 then
		b2 =false
	end 
	if self.config.is_buy_goldpig2   > 0 and self.config.goldpig_lb2_contribution_num   ==0 then
		b3 =false
	end 
	return  b1 and b2 and b3
end

--如果某个玩家因为某些原因关闭了礼包奖权限，则判断这部分
function C:GetStages_gift2(my_data)
	local b1 = false
	local b2 = false
	local b3 = false
	if self.config.is_buy_vip_lb > 0 or  self.config.vip_lb_contribution_num >0 then
		b1=true
	end 
	if self.config.is_buy_goldpig1 > 0 or   self.config.goldpig_lb1_contribution_num >0 then
		b2 =true
	end 
	if self.config.is_buy_goldpig2  > 0 or   self.config.goldpig_lb2_contribution_num   >0 then
		b3 =true
	end 
	return  b1 or  b2 or  b3
end


function C:MyRefresh()
end

function C:OnShareClick()
	local share_parm = {}
    share_parm.share_type = "tgfx_" .. ShareImage.CreateRandomImgId()
    MainModel.GetShareUrl(function(_data)
            dump(_data, "<color=red>分享数据</color>")
            if _data.result == 0 then
                local strOff = "false"
                local url = _data.share_url
                local sendcall = function ()
                    -- 分享链接
                    local shareLink
                    shareLink = string.format(share_link_config.share_link[10].link[1] ,url,strOff)
                    ShareLogic.ShareGM(shareLink, function (str)
                        print("<color=red>分享完成....str = " .. str .. "</color>")
                        if str == "OK" then
                            if self.finishcall then
                                self.finishcall()
                            end
                        end
                    end)
                end
				sendcall()
            else
                HintPanel.ErrorMsg(_data.result)
            end
    end,share_parm)
end



