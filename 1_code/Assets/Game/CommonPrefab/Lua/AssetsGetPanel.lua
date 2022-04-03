-- 创建时间:2018-06-06
local basefunc = require "Game.Common.basefunc"
AssetsGetPanel = basefunc.class()
AssetsGetPanel.name = "AssetsGetPanel"

local instance
function AssetsGetPanel.Create(data,is_force)
	dump(data, "<color=green>获得物品</color>")
	if not is_force then
		MainModel.asset_change_list = MainModel.asset_change_list or {}
		table.insert(MainModel.asset_change_list,data)	
	end

	if not is_force and (not table_is_null(MainModel.asset_change_list) and #MainModel.asset_change_list > 1 ) then
		return
	end
	ExtendSoundManager.PlaySound(audio_config.game.bgm_hall_huodewupin.audio_name)
	if MainLogic.IsHideAssetsGetPanel then
		MainLogic.IsHideAssetsGetPanel = nil
	else
		if instance then
			AssetsGetPanel.Close()
		end
		instance = AssetsGetPanel.New(data)
		Event.Brocast("AssetsGetPanelCreating", data, instance)
		return instance
	end
end

function AssetsGetPanel.Close()
	MainLogic.AssetsGetCallback = nil
	Event.Brocast("AssetsGetPanelClose")
	if instance then
		instance.data = nil
		instance:RemoveListener()
		if IsEquals(instance.gameObject) then
			GameObject.Destroy(instance.gameObject)
		end
		instance = nil
	end
end

function AssetsGetPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function AssetsGetPanel:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
    self.lister["EnterScene"] = basefunc.handler(self, self.OnExitScene)
    self.lister["CloseAssetsPanel"] = basefunc.handler(self, self.OnExitScene)
end

function AssetsGetPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function AssetsGetPanel:ctor(data)
	self.data = data
	local parent = GameObject.Find("Canvas/LayerLv50")
	if not parent then
		parent = GameObject.Find("Canvas/LayerLv5")
	end
	if not parent then
		parent = GameObject.Find("Canvas")
	end
	self:MakeLister()
	self:AddMsgListener()
	local obj = newObject(AssetsGetPanel.name, parent.transform)
	self.gameObject = obj
	self.transform = obj.transform

	LuaHelper.GeneratingVar(self.transform,self)
	self.AwardCellList = {}
	--VIP提示
	if self:is_jingbi_in_shop(data.change_type) then
		self.tips_txt.text = ""--"提高vip等级可额外获得充值加成~"
		self.tips_txt.gameObject:SetActive(true)	
	else
		self.tips_txt.gameObject:SetActive(false)
	end
	self:InitRect()

	local platform = gameMgr:getMarketPlatform()
	--优量汇banner广告
	if platform~="cjj" then
		if (SYSQXManager.IsNeedWatchAD() and not AppDefine.IsEDITOR()) then
			self.back_btn.gameObject:SetActive(true)
			self.root.transform:GetComponent("RectTransform").offsetMin = Vector2.New(0,440)
			Event.Brocast("ylh_ad_create_msg",{_type = "banner",})
		end
	end
	
	DOTweenManager.OpenPopupUIAnim(self.root.transform)
end

function AssetsGetPanel:InitRect()
	local func_back = function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		if MainLogic.AssetsGetCallback then
			MainLogic.AssetsGetCallback ()
		end
		Event.Brocast("AssetsGetPanelConfirmCallback",self.data)

		local waitFrame = false
		if self.data then
			local callback = self.data.callback
			if callback ~= nil then
				waitFrame = callback() or true
			end
			self.data.callback = nil
		end
		if waitFrame then
			coroutine.start(function ()
				Yield(0)
				AssetsGetPanel.Close()
			end)
		else
			AssetsGetPanel.Close()
		end

		if not table_is_null(MainModel.asset_change_list) then
			table.remove( MainModel.asset_change_list,1)
			if not table_is_null(MainModel.asset_change_list[1]) then
				AssetsGetPanel.Create(MainModel.asset_change_list[1],true)
			end
		end
	end

	self.confirm_btn.onClick:AddListener(func_back)
	self.BG_btn.onClick:AddListener(func_back)
	self.back_btn.onClick:AddListener(func_back)

	local change_type = self.data.change_type
	self.zyj_desc_txt.gameObject:SetActive(false)
	self.title_img.gameObject:SetActive(true)
	self.title_zyj.gameObject:SetActive(false)
	if change_type then
		local title = ""
		local cc = SysJJJManager.GetCurCount() - 1
		if change_type == "free_broke_subsidy" or change_type == "broke_share_pop" then
			self.title_img.gameObject:SetActive(false)
			self.title_zyj.gameObject:SetActive(true)
			if Act_062_HGHDManager and Act_062_HGHDManager.IsActive() then
				self.tips2_txt.text = "回归特权，转运金已翻倍"
				self.tips2_txt.gameObject:SetActive(true)
			end
			if change_type == "broke_share_pop" then
				self.zyj_desc_txt.text = "还可领<color=#20D1FF>"..cc.."</color>次，".."提高vip等级可领取更多转运金~"
				self.zyj_desc_txt.gameObject:SetActive(true)
				self.confirm_btn.transform:Find("ImgOneMore"):GetComponent("Text").text = "分享领取"
			else
				self.tips_txt.text = "还可领"..cc.."次"
				self.zyj_desc_txt.gameObject:SetActive(true)
				self.zyj_desc_txt.text = "还可领<color=#20D1FF>"..cc.."</color>次，"..(OneYuanGift.isProtected and "新手特权" or "提高vip等级可领取更多转运金~")
			end
		elseif change_type == "broke_subsidy" then
			self.title_img.gameObject:SetActive(false)
			self.title_zyj.gameObject:SetActive(true)
			local ss = ""
			if cc <= 0 then 
				ss = "今日已领完,"
			else
				ss = "还可领<color=#20D1FF>"..cc.."</color>次,"
			end 
			self.tips_txt.gameObject:SetActive(false)
			self.zyj_desc_txt.gameObject:SetActive(true)
			self.zyj_desc_txt.text = ss.."提高vip等级可领取更多转运金~"
		elseif change_type == "bind_phone_award" then
			title = "com_imgf_sjbdjl"
		elseif change_type == "box_exchange_active_award_110_local" then
			self.tips2_txt.text = "福利券宝箱已自动开启~"
			self.tips2_txt.gameObject:SetActive(true)
			title = "com_imgf_gxhd"
		else
			title = "com_imgf_gxhd"
		end
		if change_type == "vip_charge_award" then
			self.info_desc_txt.text = "VIP等级加成"
		end
		self:ChangeTitle(title)
	end

	local data = self.data.data
	local skip_data = self.data.skip_data or false
	if not skip_data then
		data = AwardManager.GetAssetsList(data)
	end

	self:CloseAwardCell()
	for i=1,#data do
		local v = data[i]
		self.AwardCellList[#self.AwardCellList + 1] = self:CreateItem(v)
	end

	--荣誉解锁道具
	if change_type and change_type == "glory_award" then
		local unlock_assets =  AwardManager.GetLockAssetList(self.data.unlock_assets)
		if unlock_assets then
			for i,v in ipairs(unlock_assets) do
				self.AwardCellList[#self.AwardCellList + 1] = self:CreateItem(v)
			end
		end
	end

	--等级解锁新炮台添加分享按钮
	for k,v in pairs(self.data.data) do
		if v.asset_type and string.sub(v.asset_type,1,11) == "gun_barrel_" then
			self.confirm_btn.transform.localPosition = Vector3.New(-200,self.confirm_btn.transform.localPosition.y,self.confirm_btn.transform.localPosition.z)
			self.share_btn.gameObject:SetActive(true)
			self.share_btn.onClick:AddListener(function ()
				local curBgCoNfig = {"bossqsb_bg_2","hlqkdhb_bg_2","mrbxl_bg_1"}
				local index = math.random(1,#curBgCoNfig)
				GameButtonManager.RunFunExt("sys_fx", "TYShareImage", nil, {fx_type="pt_get", share_bg = curBgCoNfig[index]}, function (str)
					func_back()
				end)	
			end)
		end
	end

	-- 支持自定义tips描述
	if self.data.tips then
		self.tips_txt.text = self.data.tips
		self.tips_txt.gameObject:SetActive(true)
		-- 支持自定义tips位置
		if self.data.tips_pos then
			self.tips_txt.transform.localPosition = self.data.tips_pos
		end
	end

	-- 支持自定义标题图片
	if self.data.title_img then
		self:ChangeTitle(self.data.title_img)
		-- 支持自定义title_img缩放比例
		if self.data.title_scale then
			self.title_img.transform.localScale = self.data.title_scale
		end
	end

	-- 支持自定义确定按钮文字
	if self.data.confirm_text then
		self.confirm_btn.transform:Find("ImgOneMore"):GetComponent("Text").text = self.data.confirm_text
	end

	local animation = self.data.animation or false
	if animation then
		self:AnimationList(self.AwardCellList)
	end
	
	--dump(self.data, "<color=green>获得物品</color>")
	self.include_prop_xycj_coin=false
	for i = 1, #self.data.data, 1 do
		----如果获得的物品内存在幸运转盘抽奖券,则跳到幸运转盘界面
		if self.data.data[i].asset_type=="prop_xycj_coin" then
			-- body
			self.include_prop_xycj_coin=true
			self.confirm_btn.onClick:AddListener(function ()
				dump("关闭一个存在抽奖券的界面！！！")
				GameManager.GotoUI({gotoui="sys_flqcj", goto_scene_parm="panel",open_type="open_guide"})
			end)
		end
	end
	if self.include_prop_xycj_coin then
		-- body

	end

	if Act_042_XSHBManager then
		if Act_042_XSHBManager.CheckCanOpen(self.data) then
			self.confirm_btn.onClick:AddListener(function ()
				GameManager.GotoUI({gotoui="act_042_xshb", goto_scene_parm="panel"})
			end)
		end
	end
	GuideLogic.CheckRunGuide("get_award")
end

function AssetsGetPanel:CloseAwardCell()
	for i,v in ipairs(self.AwardCellList) do
		GameObject.Destroy(v.gameObject)
	end
	self.AwardCellList = {}
end

function AssetsGetPanel:CreateItem(data)
	local obj = GameObject.Instantiate(self.AwardPrefab)
	obj.transform:SetParent(self.AwardNode)
	obj.transform.localScale = Vector3.one
	local obj_t = {}
	LuaHelper.GeneratingVar(obj.transform,obj_t)
	obj_t.DescText_txt.text = "x" .. (data.value or 1)
	if data.desc_extra then
		obj_t.DescExtra_txt.text = data.desc_extra
	else
		obj_t.DescExtra_txt.text = ""
	end
	GetTextureExtend(obj_t.AwardIcon_img, data.image, data.is_local_icon)
	obj_t.NameText_txt.text = data.name or ""
	obj.gameObject:SetActive(true)
	return obj
end

function AssetsGetPanel:OnExitScene()
	MainModel.asset_change_list = {}
	AssetsGetPanel.Close()
end

function AssetsGetPanel:ChangeTitle(titleFile)
	if self.title_img == nil then return end
	self.title_img.sprite = GetTexture(titleFile)
	self.title_img:SetNativeSize()
end

function AssetsGetPanel:AnimationList(list)
	for k, v in pairs(list) do
		v.gameObject:SetActive(false)
	end

	local interval = 0.5
	local loop = #list

	local cursor = 0
	Timer.New(function()
		cursor = cursor + 1
		local ui = list[cursor]

		local tween1 = ui.transform:DOScale(0.3, 0.3):OnComplete(function()
			if IsEquals(ui.gameObject) then
				ui.gameObject:SetActive(true)
			end
		end)
		local tween2 = ui.transform:DOScale(1.3, 0.3)
		local tween3 = ui.transform:DOScale(1.0, 0.3)
		local seq = DoTweenSequence.Create()
		seq:Append(tween1):Append(tween2):Append(tween3):OnForceKill(function()
			if IsEquals(ui.gameObject) then
				ui.transform.localScale = Vector3.one
				ui.gameObject:SetActive(true)
			end
		end)
	end, interval, loop):Start()
end
--是不是在商城买的金币
function AssetsGetPanel:is_jingbi_in_shop(change_type)
	if not change_type or change_type == "" then
		return
	end
	if change_type == "buy" then 
		return  true
	end 
	local key = string.gsub(change_type,"buy_gift_bag_","")
	if shoping_config and shoping_config.goods then 
		for i=1, #shoping_config.goods do
			if shoping_config.goods[i].gift_id and shoping_config.goods[i].gift_id == 	tonumber(key)  then
				return  true
			end 
		end
	end
	return false
end
--实物奖励混合在虚拟奖励一起展示，由MixAwardPopManager调用 type  qq 或者 微信
function AssetsGetPanel.CreatRealAwardItem(data,WXorQQ)
	if instance then
		if type(data.image) == "table" then
			for i = 1, #data.image do
				instance:CreateItem({desc = data.desc[i],image = data.image[i]})
			end		
		else
			instance:CreateItem(data)
		end 
		local WXorQQ = WXorQQ or {qq = "4008882620"}
		if WXorQQ.qq then 
			instance.tips_txt.text = "实物奖励请联系QQ:"..WXorQQ.qq.. "领取奖励"
			instance.tips_txt.gameObject:SetActive(true)
			instance.confirm_btn.transform:Find("ImgOneMore"):GetComponent("Text").text = "复制QQ"
			instance.confirm_btn.onClick:AddListener(
				function ()
					UniClipboard.SetText(WXorQQ.qq)
					LittleTips.Create("已复制QQ号请前往QQ进行添加")
				end
			)
		elseif WXorQQ.wx then 
			instance.tips_txt.text = "实物奖励请联系微信:"..WXorQQ.wx.. "领取奖励"
			instance.tips_txt.gameObject:SetActive(true)
			instance.confirm_btn.transform:Find("ImgOneMore"):GetComponent("Text").text = "复制微信"
			instance.confirm_btn.onClick:AddListener(
				function ()
					UniClipboard.SetText(WXorQQ.wx)
					LittleTips.Create("已复制微信号请前往微信进行添加")
				end
			)
		end 
	else
		print("<color=red>面板不存在</color>")
	end 
end 