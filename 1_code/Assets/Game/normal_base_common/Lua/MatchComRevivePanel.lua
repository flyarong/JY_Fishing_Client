-- 创建时间:2019-03-01
local basefunc = require "Game.Common.basefunc"
MatchComRevivePanel = basefunc.class()
local C = MatchComRevivePanel
C.name = "MatchComRevivePanel"
--可以使用的其他复活的门票，优先考虑
local other_revive_key = {
    [1]= "prop_7",
    [2]= "obj_qys_match_revive_ticket",
}
local instance
function C.Create(parm, gameCfg)
	if not instance then
		instance = C.New(parm, gameCfg)
	end
    return instance
end

function C.Close()
	if instance then
		instance:OnClose()
	end
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
    self.lister["close_gift_shop_shopid_13"] = basefunc.handler(self, self.close_gift_shop_shopid_13)
    self.lister["call_finish_gift_shop_shopid_13"] = basefunc.handler(self, self.call_finish_gift_shop_shopid_13)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:ctor(parm, gameCfg)

	ExtPanel.ExtMsg(self)

	dump(parm, "<color=yellow>MatchComRevivePanel 复活界面 参数</color>")
    dump(gameCfg, "<color=yellow>MatchComRevivePanel 复活界面 配置</color>")

    self.gameCfg = gameCfg
    self.assets_map = {}
    for k,v in ipairs(parm.revive_assets) do
		self.assets_map[v.asset_type] = {value = v.value, index = k}
    end
	self.sx_list = {
        [1] = {itemkey = "shop_gold_sum", is_true = false, text = ""},
        [2] = {itemkey = "prop_2", is_true = false, text = ""},
        [3] = {itemkey = "prop_3", is_true = false, text = ""},
		[4] = {itemkey = "jing_bi", is_true = false, text = ""},
	}
	for k,v in ipairs(self.sx_list) do
		if self.assets_map[v.itemkey] then
			if v.itemkey == "shop_gold_sum" then
				v.text = "x" .. (self.assets_map[v.itemkey].value/100)
			else
				v.text = "x" .. StringHelper.ToCash(self.assets_map[v.itemkey].value)
			end
		end
	end

    self:MakeLister()
    self:AddMsgListener()

    self.parent = GameObject.Find("Canvas/LayerLv5").transform
    self.gameObject = newObject(C.name, self.parent)
    self.transform = self.gameObject.transform
    LuaHelper.GeneratingVar(self.transform, self)
    self.Revive = self.transform:Find("Revive")
    self.IconImage1 = self.revive1_btn.transform:Find("IconImage"):GetComponent("Image")
    self.IconImage2 = self.revive2_btn.transform:Find("IconImage"):GetComponent("Image")
    self.NumberText1 = self.revive1_btn.transform:Find("NumberText"):GetComponent("Text")
    self.NumberText2 = self.revive2_btn.transform:Find("NumberText"):GetComponent("Text")

    self.revive1_btn.onClick:AddListener(basefunc.handler(self, self.OnRevive1Clicked))
    self.revive2_btn.onClick:AddListener(basefunc.handler(self, self.OnRevive2Clicked))
    self.close_btn.onClick:AddListener(basefunc.handler(self, self.OnBackClicked))
    self:SetAutoClose(parm.revive_time)
    self:MyRefresh()

    DOTweenManager.OpenPopupUIAnim(self.Revive)
end

function C:MyRefresh()
    if not table_is_null(other_revive_key) then
        for i,v in ipairs(other_revive_key) do
            if self:SetReviveOther(v) then return end
        end
    end
    
    for k,v in ipairs(self.sx_list) do
        if self.assets_map[v.itemkey] then
            local num = GameItemModel.GetItemCount(v.itemkey)
            if num >= self.assets_map[v.itemkey].value then
                v.is_true = true
            end
        end
    end

	self.revive_type = {}
	for _,v in ipairs(self.sx_list) do
		if v.is_true then
			self.revive_type[#self.revive_type + 1] = v
		end
		if #self.revive_type == 2 then
			break
		end
	end
	if #self.revive_type == 0 then
		self.revive_type[#self.revive_type + 1] = self.sx_list[4]
	end
	if #self.revive_type == 1 then
		self.revive1_btn.gameObject:SetActive(true)
		self.revive1_btn.transform.localPosition = Vector3.New(0, -130, 0)
		self.revive2_btn.gameObject:SetActive(false)
		local item = GameItemModel.GetItemToKey(self.revive_type[1].itemkey)
		GetTextureExtend(self.IconImage1, item.image, item.is_show_bag)
		self.NumberText1.text = self.revive_type[1].text
	else
		self.revive1_btn.gameObject:SetActive(true)
		self.revive1_btn.transform.localPosition = Vector3.New(-228, -130, 0)
		self.revive2_btn.gameObject:SetActive(true)
		self.revive2_btn.transform.localPosition = Vector3.New(228, -130, 0)
		local item1 = GameItemModel.GetItemToKey(self.revive_type[1].itemkey)
		GetTextureExtend(self.IconImage1, item1.image, item1.is_show_bag)
		self.NumberText1.text = self.revive_type[1].text
		local item2 = GameItemModel.GetItemToKey(self.revive_type[2].itemkey)
		GetTextureExtend(self.IconImage2, item2.image, item2.is_show_bag)
		self.NumberText2.text = self.revive_type[2].text
	end
end

function C:OnAssetChange()
    if instance then
        self:MyRefresh()
    end
end
function C:close_gift_shop_shopid_13()
    if instance then
        PayPanel.Create(GOODS_TYPE.jing_bi)
    end
end
function C:call_finish_gift_shop_shopid_13()
    if instance then
        print("<color=white>call_finish_gift_shop_shopid_13</color>")
        if self.giftPanel then
            self.giftPanel:MyClose()
            self.giftPanel = nil
        end
        self:MyRefresh()
    end
end

function C:SetAutoClose(delay)
    self.countDown = delay or 10
    self.hint_time_txt.text = self.countDown .. "s"
    self.autoClose = Timer.New(function ()
        self.countDown = self.countDown - 1
        self.hint_time_txt.text = self.countDown .. "s"
        
        if self.countDown == 0 then
            Network.SendRequest("nor_mg_revive", {opt = 0}, "")
            self:OnClose()
        end
    end, 1, delay, false)
    self.autoClose:Start()
end

function C:MyExit()
    self:RemoveListener()
    instance = nil
    if self.autoClose then
        self.autoClose:Stop()
        self.autoClose = nil
    end
    if self.giftPanel then
        self.giftPanel:MyClose()
        self.giftPanel = nil
    end

    if IsEquals(self.gameObject) then
        destroy(self.gameObject)
    end
end

function C:OnClose()
    self:MyExit()
end

function C:OnRevive1Clicked()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if not table_is_null(other_revive_key) then
        for i,v in ipairs(other_revive_key) do
            if self:OnReviveOther(v) then return end
        end
    end

    if self.revive_type[1].is_true then
	    Network.SendRequest("nor_mg_revive", {opt = self.assets_map[self.revive_type[1].itemkey].index}, "请求复活")
    else
        if self.gameCfg.game_tag and self.gameCfg.game_tag == "ges" then
            PayPanel.Create(GOODS_TYPE.jing_bi)
            return
        end
        if self.gameCfg.iswy and self.gameCfg.iswy == 1 then
            PayPanel.Create(GOODS_TYPE.jing_bi)
        else
            local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, 13)
            local status = MainModel.GetGiftShopStatusByID(gift_config.id)
            if GameGlobalOnOff.LIBAO and status == 1 then
                self.giftPanel = GameManager.GotoUI({gotoui = "gift_13",goto_scene_parm = "panel",parent = self.parent})
            else
                PayPanel.Create(GOODS_TYPE.jing_bi)
            end
        end
    end
end

function C:OnRevive2Clicked()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    Network.SendRequest("nor_mg_revive", {opt = self.assets_map[self.revive_type[2].itemkey].index}, "请求复活")
end

function C:OnBackClicked()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self:OnClose()
end

function C:SetVIPRevive()
    local vip_prop = "obj_qys_match_revive_ticket"
    if self.assets_map[vip_prop] then
        --免费复活道具
        local num = GameItemModel.GetItemCount(vip_prop)
        local need_num = self.assets_map[vip_prop].value
        if num >= need_num then
            self.revive1_btn.gameObject:SetActive(true)
            self.revive1_btn.transform.localPosition = Vector3.New(0, -130, 0)
            self.revive2_btn.gameObject:SetActive(false)
            local item = GameItemModel.GetItemToKey(vip_prop)
            GetTextureExtend(self.IconImage1, item.image, item.is_show_bag)
            self.NumberText1.text = "x" .. need_num
            return true
        end
    end
    return false
end

function C:OnReviveVIP()
    local vip_prop = "obj_qys_match_revive_ticket"
    if self.assets_map[vip_prop] then
        --免费复活道具
        local num = GameItemModel.GetItemCount(vip_prop)
        local need_num = self.assets_map[vip_prop].value
        local opt = self.assets_map[vip_prop].index
        if num >= need_num then
            Network.SendRequest("nor_mg_revive", {opt = opt}, "请求复活")
            return true
        end
    end
    return false
end

function C:SetReviveOther(other_key)
    local prop = other_key
    local set_prop_ui = function(need_num)
        self.revive1_btn.gameObject:SetActive(true)
        self.revive1_btn.transform.localPosition = Vector3.New(0, -130, 0)
        self.revive2_btn.gameObject:SetActive(false)
        local item = GameItemModel.GetItemToKey(prop)
        GetTextureExtend(self.IconImage1, item.image, item.is_show_bag)
        self.NumberText1.text = "x" .. need_num
    end
    if self.assets_map[prop] then
        --免费复活道具
        local num = GameItemModel.GetItemCount(prop)
        local need_num = self.assets_map[prop].value
        if num >= need_num then
            set_prop_ui(need_num)
            return true
        else
            if prop == other_revive_key[1] then
                --感恩赛门票
                set_prop_ui(need_num)
                return true
            end
        end
    end
    return false
end

function C:OnReviveOther(other_key)
    local prop = other_key
    if self.assets_map[prop] then
        --免费复活道具
        local num = GameItemModel.GetItemCount(prop)
        local need_num = self.assets_map[prop].value
        local opt = self.assets_map[prop].index
        if num >= need_num then
            Network.SendRequest("nor_mg_revive", {opt = opt}, "请求复活")
            return true
        else
            if prop == other_revive_key[1] then
                --感恩赛门票
                LittleTips.Create("您的感恩赛门票不足，不能复活。")
                return true
            end
        end
    end
    return false
end