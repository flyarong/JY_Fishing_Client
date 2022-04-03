-- 创建时间:2020-09-14
-- Panel:Act_Ty_ZP1Panel
--[[
/**
 *               ii.                                         ;9ABH,          
 *              SA391,                                    .r9GG35&G          
 *              &#ii13Gh;                               i3X31i;:,rB1         
 *              iMs,:,i5895,                         .5G91:,:;:s1:8A         
 *               33::::,,;5G5,                     ,58Si,,:::,sHX;iH1        
 *                Sr.,:;rs13BBX35hh11511h5Shhh5S3GAXS:.,,::,,1AG3i,GG        
 *                .G51S511sr;;iiiishS8G89Shsrrsh59S;.,,,,,..5A85Si,h8        
 *               :SB9s:,............................,,,.,,,SASh53h,1G.       
 *            .r18S;..,,,,,,,,,,,,,,,,,,,,,,,,,,,,,....,,.1H315199,rX,       
 *          ;S89s,..,,,,,,,,,,,,,,,,,,,,,,,....,,.......,,,;r1ShS8,;Xi       
 *        i55s:.........,,,,,,,,,,,,,,,,.,,,......,.....,,....r9&5.:X1       
 *       59;.....,.     .,,,,,,,,,,,...        .............,..:1;.:&s       
 *      s8,..;53S5S3s.   .,,,,,,,.,..      i15S5h1:.........,,,..,,:99       
 *      93.:39s:rSGB@A;  ..,,,,.....    .SG3hhh9G&BGi..,,,,,,,,,,,,.,83      
 *      G5.G8  9#@@@@@X. .,,,,,,.....  iA9,.S&B###@@Mr...,,,,,,,,..,.;Xh     
 *      Gs.X8 S@@@@@@@B:..,,,,,,,,,,. rA1 ,A@@@@@@@@@H:........,,,,,,.iX:    
 *     ;9. ,8A#@@@@@@#5,.,,,,,,,,,... 9A. 8@@@@@@@@@@M;    ....,,,,,,,,S8    
 *     X3    iS8XAHH8s.,,,,,,,,,,...,..58hH@@@@@@@@@Hs       ...,,,,,,,:Gs   
 *    r8,        ,,,...,,,,,,,,,,.....  ,h8XABMMHX3r.          .,,,,,,,.rX:  
 *   :9, .    .:,..,:;;;::,.,,,,,..          .,,.               ..,,,,,,.59  
 *  .Si      ,:.i8HBMMMMMB&5,....                    .            .,,,,,.sMr
 *  SS       :: h@@@@@@@@@@#; .                     ...  .         ..,,,,iM5
 *  91  .    ;:.,1&@@@@@@MXs.                            .          .,,:,:&S
 *  hS ....  .:;,,,i3MMS1;..,..... .  .     ...                     ..,:,.99
 *  ,8; ..... .,:,..,8Ms:;,,,...                                     .,::.83
 *   s&: ....  .sS553B@@HX3s;,.    .,;13h.                            .:::&1
 *    SXr  .  ...;s3G99XA&X88Shss11155hi.                             ,;:h&,
 *     iH8:  . ..   ,;iiii;,::,,,,,.                                 .;irHA  
 *      ,8X5;   .     .......                                       ,;iihS8Gi
 *         1831,                                                 .,;irrrrrs&@
 *           ;5A8r.                                            .:;iiiiirrss1H
 *             :X@H3s.......                                .,:;iii;iiiiirsrh
 *              r#h:;,...,,.. .,,:;;;;;:::,...              .:;;;;;;iiiirrss1
 *             ,M8 ..,....,.....,,::::::,,...         .     .,;;;iiiiiirss11h
 *             8B;.,,,,,,,.,.....          .           ..   .:;;;;iirrsss111h
 *            i@5,:::,,,,,,,,.... .                   . .:::;;;;;irrrss111111
 *            9Bi,:,,,,......                        ..r91;;;;;iirrsss1ss1111
 --]]

local basefunc = require "Game/Common/basefunc"

Act_Ty_ZP1Panel = basefunc.class()
local C = Act_Ty_ZP1Panel
C.name = "Act_Ty_ZP1Panel"
C.XXCJState = 
{
	Nor = "正常",
	Anim_Ing = "动画中",
	Anim_Finish = "动画完成",
}
local M = Act_Ty_ZP1Manager

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
    self.lister["act_ty_zp1_data_finish_msg"] = basefunc.handler(self, self.MyRefresh)
    self.lister["AssetChange"] = basefunc.handler(self, self.on_AssetChange)
    self.lister["finish_gift_shop"] = basefunc.handler(self, self.on_finish_gift_shop)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	
	Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
	if self.cutdown_timer then
		self.cutdown_timer:Stop()
	end
	self:ClearGiftItem()
	self:KillSeq()
	self:CloseAnimSound()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv5").transform
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
	self.pj = 60 -- 平均角度
	local help = M.GetHelpInfo()
	if help then
		self.help_btn.gameObject:SetActive(true)
	else
		self.help_btn.gameObject:SetActive(false)
	end

	self.back_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnBackClick()
    end)
    self.help_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnHelpClick()
	end)
    self.cj_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnGetAwardClick()
    end)
    self.cj10_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnGetAwardClick(10)
    end)

	self:CreateCJAwardItem()
	
	self.cjq_img.sprite = GetTexture(GameItemModel.GetItemToKey(M.cjq_item).image)
	self.cjq_img:SetNativeSize()

	--模板时间显示方式
	local timeShowType=M.GetActTimeShowType()
	if timeShowType and timeShowType~="" then
		self.hint_time_txt.text = timeShowType
	else
		self.cutdown_timer=CommonTimeManager.GetCutDownTimer(M.GetActEndTime(),self.hint_time_txt)
	end
	---背景图片更换
	local cur_path=M.GetActCurPath()
	if cur_path then
		SetTextureExtend(self.bg_img,cur_path.."_bg")
	end
	self.hint_txt.text = M.GetXg_Desc()
	M.QueryData()
end

function C:MyRefresh()
	self:RefreshAssets()
	self:CreateGiftItem()
end

function C:RefreshAssets(data)
	local n = GameItemModel.GetItemCount(M.cjq_item)
	self.cjq_txt.text = "抽奖券x" .. n
end

function C:RefreshGift()
	self.gift_list = M.GetIsSort() and M.GetGiftConfigAndSort() or M.GetGiftConfig()
end

function C:OnBackClick()
	self:MyExit()
end

function C:OnHelpClick()
	local help_info = M.GetHelpInfo()
	local sta_t = self:GetStart_t()
	local end_t = self:GetEnd_t()
	help_info[1] = "1.活动时间：".. sta_t .."-".. end_t
	local str = help_info[1]
	for i = 2, #help_info do
		str = str .. "\n" .. help_info[i]
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt }, GameObject.Find("Canvas/LayerLv5").transform, "IllustratePanel_New")
end

function C:OnGetAwardClick(cj_num)
	cj_num = cj_num or 1 -- 抽奖次数
	if self.xycj_state ~= C.XXCJState.Nor then
		print("当前状态= " .. self.xycj_state)
		return
	end
	local n = GameItemModel.GetItemCount(M.cjq_item)
	if n < cj_num then
		LittleTips.Create("抽奖券不足～")
		return
	end
	dump(M.box_exchange_id,"box_exchange_id:  ")
	Network.SendRequest("box_exchange", {id = M.box_exchange_id , num = cj_num}, "请求数据", function (data)
		dump(data, "<color=red>---------box_exchange-------</color>")
		if data.result == 0 then
			self.xycj_state = C.XXCJState.Anim_Ing
			self:SetAwardData(data.award_id)
			if #data.award_id == 1 then
				self.last_selectIndex = self.selectIndex
				self.selectIndex = M.GetAwardConfigByAwardID(data.award_id[1]).line
				self:RunAnim()
			else
				self:RunAnimFinish()
			end
		else
			HintPanel.ErrorMsg(data.result)
		end
	end)
end

function C:SetAwardData(list)
	self.cur_award = {}
	self.cur_award.data = {}
	self.cur_award.skip_data = true
	local hb = 0
	local jb = 0
	local hf=0
	for i = 1, #list do
		local cfg = M.GetAwardConfigByAwardID(list[i])
		if cfg then
			self.cur_award.data[#self.cur_award.data + 1] = {image=cfg.icon, desc=cfg.name, asset_type=cfg.asset_type, value=cfg.value}
			if cfg.asset_type == "shop_gold_sum" then
				hb = hb + cfg.value
			elseif cfg.asset_type == "jing_bi" then
				jb = jb + cfg.value
			elseif cfg.asset_type=="prop_web_chip_huafei" then
				hf=hf+cfg.value
			end
		end
	end
	if #list > 1 then
		if hf>0 then
			-- body
			self.cur_award.tips = string.format("恭喜您在十连抽中共获得 %s金币 + %s福利券 +  %s话费碎片", StringHelper.ToCash(jb), StringHelper.ToCash(hb),StringHelper.ToCash(hf))
		else
			self.cur_award.tips = string.format("恭喜您在十连抽中共获得 %s金币 + %s福利券 ", StringHelper.ToCash(jb), StringHelper.ToCash(hb))

		end
	end
end

function C:KillSeq()
	if self.seq then
		self.seq:Kill()
	end
	self.seq = nil
end

function C:RunAnim(delay)
	self:KillSeq()

	self:CloseAnimSound()
	self.curSoundKey = ExtendSoundManager.PlaySound(audio_config.game.bgm_duijihongbao.audio_name, 1, function ()
		self.curSoundKey = nil
	end)
	local rota = -360 * 18 - self.pj * (self.selectIndex-1)

	self.seq = DoTweenSequence.Create()
	if delay and delay > 0 then
		self.seq:AppendInterval(delay)
	end
	self.seq:Append(self.zz_node:DORotate( Vector3.New(0, 0 , rota), 6, DG.Tweening.RotateMode.FastBeyond360):SetEase(DG.Tweening.Ease.InOutCubic))
	self.seq:OnKill(function ()
		self.seq = nil
		if IsEquals(self.gameObject) then
			self.zz_node.localRotation = Quaternion:SetEuler(0, 0, rota)
			self.g_node.localRotation = Quaternion:SetEuler(0, 0, rota)	
			self:RunAnimG()
		end
	end)
	self.seq:OnForceKill(function (is_force)
		if is_force then
			self.zz_node.localRotation = Quaternion:SetEuler(0, 0, rota)
			self.g_node.localRotation = Quaternion:SetEuler(0, 0, rota)	
			self:RunAnimFinish()
		end
	end)
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
	self.seq:OnForceKill(function (is_force)
		if is_force then
			self.seq = nil
			self.g_node.gameObject:SetActive(false)
			self:RunAnimFinish()
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

function C:ShowAwardBrocast()
	dump(self.cur_award, "<color=red>EEE cur_award</color>")
	if self.cur_award then
		if #self.cur_award.data == 1 then--单抽奖励展示
			Event.Brocast("AssetGet", self.cur_award)
		else--十连抽奖励展示
			local pre = AssetsGet10Panel.Create(self.cur_award.data, function ()
				print("<color=red>确定</color>")
			end)
			pre.info_desc_txt.transform.localPosition = Vector3.New(0, -325, 0)
			pre.info_desc_txt.text = self.cur_award.tips
		end
		self.cur_award = nil
	end
end

function C:GetStart_t()
	return string.sub(os.date("%m月%d日%H:%M",M.GetActStartTime()),1,1) ~= "0" and os.date("%m月%d日%H:%M",M.GetActStartTime()) or string.sub(os.date("%m月%d日%H:%M",M.GetActStartTime()),2)
end

function C:GetEnd_t()
	return string.sub(os.date("%m月%d日%H:%M:%S",M.GetActEndTime()),1,1) ~= "0" and os.date("%m月%d日%H:%M:%S",M.GetActEndTime()) or string.sub(os.date("%m月%d日%H:%M:%S",M.GetActEndTime()),2)
end

function C:CreateGiftItem()
	self:RefreshGift()
    self:ClearGiftItem()
    for k,v in ipairs(self.gift_list) do
		local pre = Act_Ty_ZP1GiftPrefab.Create(self.content, self, v.gift_id)
		self.gift_cell_map[v.gift_id] = pre
    end
end

function C:ClearGiftItem()
	if self.gift_cell_map then
		for k,v in pairs(self.gift_cell_map) do
			v:MyExit()
		end
	end
	self.gift_cell_map = {}
end

function C:CreateCJAwardItem()
	local award_list = M.GetAwardConfig()
	for k,v in ipairs(award_list) do
		local obj = GameObject.Instantiate(self.cwlb_jp_prefab, self["jp_node"..k])
		obj.gameObject:SetActive(true)
		local tran = obj.transform
		tran.localPosition = Vector3.zero
		local JPImage = tran:Find("JPImage"):GetComponent("Image")
		local JPText = tran:Find("JPText"):GetComponent("Text")
		JPImage.sprite = GetTexture(v.icon)
		JPText.text = v.name
	end
end

function C:on_finish_gift_shop(id)
	if id and M.UIConfig.gift_map[id] and M.GetIsSort() then
		M.QueryRemainTimeById(id)
	end
end

function C:on_AssetChange()
	self:RefreshAssets()
end