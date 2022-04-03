-- 创建时间:2020-05-21
-- Panel:GameNew2XYCJPanel
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

GameNew2XYCJPanel = basefunc.class()
local C = GameNew2XYCJPanel
C.name = "GameNew2XYCJPanel"
local M = XYCJActivityManager
C.XXCJState = 
{
	Nor = "正常",
	Anim_Ing = "动画中",
	Anim_Finish = "动画完成",
}

function C.Create(parm, parent)
	return C.New(parm, parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
	self.lister["model_query_luck_lottery_data"] = basefunc.handler(self, self.RefreshCJCS)
	self.lister["XYCJ_LightBKPanel_msg"] = basefunc.handler(self,self.XYCJ_LightBKPanel_msg)
	self.lister["change_flqzpzz_show_state"] = basefunc.handler(self,self.on_change_flqzpzz_show_state)

end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.xycj_lightbkpanel_pre then
		self.xycj_lightbkpanel_pre:MyExit()
	end
	if self.seq then
		self.seq:Kill()
		self.seq = nil
	end
	self:CloseAnimSound()
	self:ClearCellList()
	self:ClearDHCellList()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parm, parent)
	self.parm = parm
	ExtPanel.ExtMsg(self)
	M.SetHintState()

	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.xycj_state = C.XXCJState.Nor
	self.pj = 36 -- 平均角度

	self.get_award_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnGetAwardClick()
	end)
	self.get_award10_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnGetAwardClick(10)
	end)
	self.help_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnHelpClick()
	end)
	self.get_award_txt.text = "抽 1 次"
	self.get_award10_txt.text = "抽 10 次"

	self.jpnode_list = {}
	self.dj_list = {}
	for i = 1, 10 do
		self.jpnode_list[#self.jpnode_list + 1] = self["jp_node" .. i]
		self.dj_list[#self.dj_list + 1] = self["dj" .. i]
	end
	self.dhnode_list = {}
	for i = 1, 4 do
		self.dhnode_list[#self.dhnode_list + 1] = self["dh" .. i]
	end

	M.QueryCJNum()

	if self.parm.type == 1 then
		self:OnSelectClick(1)
	else
		self:OnSelectClick(2)
	end
	self.zz_node.gameObject:SetActive(true)

end

function C:MyRefresh()
	self:KillSeq()
	self.g_node.gameObject:SetActive(false)
	self:ClearCellList()
	self.award_list = M.GetAwardListByType(self.type)
	-- dump(self.award_list)
	self.parm_money = M.GetCJMoneyByType(self.type)
	-- dump(self.parm_money)
	self.cur_award_map = {}
	for k,v in ipairs(self.award_list) do
		self.cur_award_map[v.id] = v
	end

	for k,v in ipairs(self.award_list) do
		local pre = GameXycjAwardPrefab.Create(self.jpnode_list[k].transform, v, self)
		self.CellList[#self.CellList + 1] = pre
		if v.is_dj == 0 then
			self.dj_list[k].gameObject:SetActive(false)
		else
			self.dj_list[k].gameObject:SetActive(true)
		end
	end
	self:ClearDHCellList()
	self.dh_list = M.GetDHByType(self.type)
	for k,v in ipairs(self.dh_list) do
		local pre = GameXycjDHPrefab.Create(self.dhnode_list[k], v, self)
		self.DHCellList[#self.DHCellList + 1] = pre
	end
	if self.parm_money.money == 300000 then
		self.get_money_txt.text = "消耗:" .. StringHelper.ToCash(self.parm_money.money) .. "金币+抽奖券x1"
	else
		self.get_money_txt.text = "消耗:" .. StringHelper.ToCash(self.parm_money.money) .. "金币"
	end
	self.get_money10_txt.text = "消耗：" .. StringHelper.ToCash(self.parm_money.money * 10) .. "金币"
	if self.type == 1 then
		self.get_award_btn.transform.localPosition = Vector3.New(362, -280, 0)
		self.get_award10_btn.gameObject:SetActive(false)
	else
		self.get_award10_btn.gameObject:SetActive(true)
		self.get_award_btn.transform.localPosition = Vector3.New(148, -280, 0)
		self.get_award10_btn.transform.localPosition = Vector3.New(572, -280, 0)
	end
	self:RefreshCJCS()

	if self.type == 2 then
		self.introduce_txt.text = "活动规则\n"..
		"1、Vip超级转盘只有成为Vip2后才可使用；\n"..
		"2、Vip等级越高，每天可在Vip超级转盘抽奖的次数越多；\n"..
		"3、本公司保留在法律规定范围内对上述规则解释的权利。\n"
	else
		self.introduce_txt.text = "活动规则\n"..
		"1、小福利转盘抽奖需要消耗抽奖券；\n"..
		"2、充值6元及以上可获得抽奖券。\n"
	end

end
function C:ClearDHCellList()
	if self.DHCellList then
		for k,v in ipairs(self.DHCellList) do
			v:OnDestroy()
		end
	end
	self.DHCellList = {}
end
function C:ClearCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:OnDestroy()
		end
	end
	self.CellList = {}
end
function C:RefreshCJCS()
	if self.type == 2 then
		self.cjcs_txt.text = "当日剩余抽奖次数:" .. (M.m_data.get_num or 0)
	else
		self.cjcs_txt.text = ""
	end
end

function C:OnExitScene()
	self:MyExit()
end
function C:OnBackClick()
	self:ShowAwardBrocast()
	self:MyExit()
end
function C:OnDHClick(cfg)
	local parm = {}
	parm.gotoui = cfg.goto_ui[1]
	parm.goto_scene_parm = cfg.goto_ui[2]
	GameManager.GotoUI(parm)
end

function C:KillSeq()
	if self.seq then
		self.seq:Kill()
	end
	self.seq = nil
end
-- 动画
function C:RunAnim(delay)
	self:KillSeq()

	self:CloseAnimSound()
	self.curSoundKey = ExtendSoundManager.PlaySound(audio_config.game.bgm_duijihongbao.audio_name, 1, function ()
		self.curSoundKey = nil
	end)

	local jj = self.last_selectIndex or 1
	local num = 6 * 10 + (self.selectIndex + 10 - jj + 1)
	local cur_index = 1
	if not self.xycj_lightbkpanel_pre then
		self.xycj_lightbkpanel_pre = XYCJ_LightBKPanel.Create(self.LightBk_Node.transform,cur_index,num,self.selectIndex)
	else
		if self.last_selectIndex % 10 == 0 then
			self.last_selectIndex = 10
		else	
			self.last_selectIndex = self.last_selectIndex % 10
		end
		local offset=self.last_selectIndex-1
		self.xycj_lightbkpanel_pre:DoTween(1,num+offset,self.selectIndex)
	end
end

function C:RunAnimG()
	self:KillSeq()
	self.g_node.gameObject:SetActive(true)
	self.seq = DoTweenSequence.Create()
	self.seq:AppendInterval(1)
	self.seq:OnKill(function ()
		self.seq = nil
		self.g_node.gameObject:SetActive(false)
		self:RunAnimFinish()
	end)	
end

function C:OnSelectClick(tt)
	if self.xycj_state ~= C.XXCJState.Nor then
		print("当前状态= " .. self.xycj_state)
		return
	end

	self.type = tt
	self:MyRefresh()
end

function C:OnHelpClick()
	if self.xycj_state ~= C.XXCJState.Nor then
		print("当前状态= " .. self.xycj_state)
		return
	end
	IllustratePanel.Create({self.introduce_txt}, self.transform)
end

function C:OnGetAwardClick(cj_num)
	cj_num = cj_num or 1 -- 抽奖次数
	if self.xycj_state ~= C.XXCJState.Nor then
		print("当前状态= " .. self.xycj_state)
		return
	end
	if self.type == 1 then
		local n = GameItemModel.GetItemCount("prop_xycj_coin")
		if n < 1 then
			if M.m_data.ptcj_num > 0 then
				local pre = HintPanel.Create(2, "请前往VIP超级转盘，抽取更高的福利吧！", function ()
					Event.Brocast("sys_flqcj_select_tag_msg", 2)
				end)
				pre:SetButtonText(nil, "前 往")
				self.is_goto_open = false
				return
			end
		end
	end


	if self.type == 2 then
		--【优先级】（VIP等级>消耗金币数>携带金币数）
		local a,vip = GameButtonManager.RunFun({gotoui="vip"}, "get_vip_level")
		if a and vip < 2 then -- VIP2开放
			GameManager.GotoUI({gotoui="vip", goto_scene_parm="hint", data={desc="VIP2开放",call=function ()
				Event.Brocast("close_flqcj_pannel")
			end}})
			return
		end
	end

	-- 消耗提示
	local xh_money = cj_num * self.parm_money.money
	if MainModel.UserInfo.jing_bi < xh_money then
		local ss = StringHelper.ToCash(xh_money)
		local pre = HintPanel.Create(2, "您携带的金币不足" .. ss .."，是否前往商城获得金币？", function ()
			PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
		end)
		pre:SetButtonText(nil, "前 往")
		return
	end
	-- 体验提示
	local min_money = (cj_num+1) * self.parm_money.money
	if MainModel.UserInfo.jing_bi < min_money then
		local ss = StringHelper.ToCash(min_money)
		local pre = HintPanel.Create(2, "为保障您的游戏体验，携带金币数达" .. ss .. "才能抽奖哦～", function ()
			PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
		end)
		pre:SetButtonText(nil, "前 往")
		return
	end

	-- 福利抽奖
	if self.type == 1 then
		local n = GameItemModel.GetItemCount("prop_xycj_coin")
		if n < 1 then
			local pre = HintPanel.Create(2, "在商城累计充值6元可获得抽奖券，是否前往商城充值？", function ()
				PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
			end)
			pre:SetButtonText(nil, "前 往")
			return
		end
	else
		local a,vip = GameButtonManager.RunFun({gotoui="vip"}, "get_vip_level")
		if a and vip > 1 then -- VIP2开放
			if M.m_data.get_num <= 0 then
				if vip == 12 then
					HintPanel.Create(1, "尊敬的VIP12，您当日的抽奖次数已用完，请明日再来！")
				else
					GameManager.GotoUI({gotoui="vip", goto_scene_parm="hint", data={desc="升级VIP可增加抽奖次数！"}})
				end
				return
			end
			if cj_num == 10 and cj_num > M.m_data.get_num then
				HintPanel.Create(1, "十连抽需要消耗10次抽奖次数，您当日的抽奖次数不足，提升Vip可增加次数！",function ()
					PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
				end)
				return
			end
		else
            GameManager.GotoUI({gotoui="vip", goto_scene_parm="hint", data={desc="VIP2开放",call=function ()
				Event.Brocast("close_flqcj_pannel")
			end}})
			return
		end
	end

	Network.SendRequest("pay_luck_lottery", {id=self.type, num = cj_num}, "请求数据", function (data)
		dump(data, "<color=red>pay_luck_lottery</color>")
		if data.result == 0 then
			self.xycj_state = C.XXCJState.Anim_Ing
			self:SetAwardData(data.indexs)
			if #data.indexs == 1 then
				self.last_selectIndex = self.selectIndex
				self.selectIndex = data.indexs[1]
				self.zz_node.gameObject:SetActive(false)
				self:RunAnim()
			else
				self:RunAnimFinish()
			end
			if self.type == 2 then
				M.m_data.get_num = M.m_data.get_num - #data.indexs
				self:RefreshCJCS()
			else
				M.m_data.ptcj_num = M.m_data.ptcj_num + 1
			end
			Event.Brocast("prop_xycj_coin_has_change_msg")
		else
			HintPanel.ErrorMsg(data.result)
		end
	end)
end

function C:RunAnimFinish()
	self.xycj_state = C.XXCJState.Anim_Finish
	self.xycj_state = C.XXCJState.Nor
	self:CloseAnimSound()

	self:ShowAwardBrocast()
end
function C:CloseAnimSound()
	if self.curSoundKey then
		soundMgr:CloseLoopSound(self.curSoundKey)
		self.curSoundKey = nil
	end
end

function C:SetAwardData(list)
	self.cur_award = {}
	self.cur_award.data = {}
	self.cur_award.skip_data = true
	for i = 1, #list do
		local cfg = self.cur_award_map[ list[i] ]
		if cfg then
			self.cur_award.data[#self.cur_award.data + 1] = {image=cfg.icon, desc=cfg.desc, asset_type=cfg.asset_type, value=cfg.value}
		end
	end
end

function C:OnAssetChange(data)
	-- if data.change_type and data.change_type == "lottery_luck_box" then
	-- 	self.cur_award = data
	-- end
end
function C:ShowAwardBrocast()
	dump(self.cur_award, "<color=red>EEE cur_award</color>")

	
	if self.cur_award then
		---记录当前使用vip转盘的次数
		if self.type==2 then
			local useVipCJTime=PlayerPrefs.GetInt("VipCJTime" .. MainModel.UserInfo.user_id, 0)
			useVipCJTime=useVipCJTime+1
			PlayerPrefs.SetInt("VipCJTime" .. MainModel.UserInfo.user_id, useVipCJTime)
		end
		if #self.cur_award.data == 1 then
			if self.type==1 then
				self.cur_award.callback=function ()
					Event.Brocast("sys_flqcj_select_tag_msg", 2)
				end
			end
			----抽到了实物
			dump(self.cur_award.data[1].asset_type,"实物奖励获取：  ")
			if not self.cur_award.data[1].asset_type then
				local string1
				string1 = "恭喜获得"..self.cur_award.data[1].desc.."请关注公众号《"..Global_GZH.."》联系在线客服领取。"
				local pre = HintCopyPanel.Create({desc=string1, isQQ=false,copy_value = Global_GZH})
				pre:SetCopyBtnText("复制公众号")
			else
				Event.Brocast("AssetGet", self.cur_award)
			end
		else
			local hb = 0
			local jb = 0
			local sj = 0
			local bx = 0

			for k,v in ipairs(self.cur_award.data) do
				if v.asset_type == "shop_gold_sum" then
					hb = hb + v.value
				elseif v.asset_type == "jing_bi" then
					jb = jb + v.value
				elseif v.asset_type == "prop_xyzp_flqbx" then
					bx = bx + v.value
				else
					sj=sj+v.value
				end
			end
			local pre = AssetsGet10Panel.Create(self.cur_award.data, function () M.ShowFlqbxAward() end)
			pre.info_desc_txt.transform.localPosition = Vector3.New(0, -325, 0)
			
			if sj>0 then
				pre.info_desc_txt.text = "总共获得：" .. StringHelper.ToCash(sj) .. "台华为mate40 RS  " .. StringHelper.ToCash(hb) .. "福利券    " .. StringHelper.ToCash(jb) .. "金币    " .. StringHelper.ToCash(bx) .. "福利券宝箱"
			else
				pre.info_desc_txt.text = "总共获得：" .. StringHelper.ToCash(hb) .. "福利券    " .. StringHelper.ToCash(jb) .. "金币    " .. StringHelper.ToCash(bx) .. "福利券宝箱"
			end
		end
		self.cur_award = nil
	end
end


function C:XYCJ_LightBKPanel_msg()
	self:RunAnimFinish()
end

function C:on_change_flqzpzz_show_state(parm)
	-- dump(parm,"改变转盘指针状态：  ")
	self.zz_node.gameObject:SetActive(true)
end
