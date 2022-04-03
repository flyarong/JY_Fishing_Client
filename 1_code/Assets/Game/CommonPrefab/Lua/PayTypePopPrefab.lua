-- 创建时间:2018-09-20
-- 支付方式界面

local basefunc = require "Game.Common.basefunc"

PayTypePopPrefab = basefunc.class()

local instance = nil
function PayTypePopPrefab.Create(goodsid, desc, createcall,convert)
    MainModel.GetVerifyStatus( function ()
        -- 防沉迷
        local b,c = GameButtonManager.RunFunExt("sys_fcm", "IsPopupHint", nil, {type="chong_zhi"})
        if b and c then
            GameManager.GotoUI({gotoui="sys_fcm", goto_scene_parm="panel"})
            return
        end

        if instance then
            PayTypePopPrefab.Close()
        end
        PayTypePopPrefab.New(goodsid, desc, createcall,convert)
        return instance
    end, "")
end

function PayTypePopPrefab.Close()
    if instance then
        MainLogic.IsHideAssetsGetPanel = nil
        destroy(instance.gameObject) 
        instance = nil
    end
end

function PayTypePopPrefab:ctor(goodsid, desc, createcall,convert)
    instance = self
    ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv50").transform
    self.gameObject = newObject("UIPayType", parent)
    self.transform = self.gameObject.transform
    local tran = self.transform
    self.goodsid = goodsid
    self.convert = convert
    self.desc = desc
    self.createcall = createcall
    self.goods_data = PayTypePopPrefab.GetGoodsDataByID(goodsid)
    dump(self.goods_data, "<color=yellow>购买商品：：：：：</color>")
	self.goTable = {}
    LuaHelper.GeneratingVar(tran, self.goTable)

    self:InitRect()
    self:InitYHQ()
end
function PayTypePopPrefab:InitRect()
	self.goTable.goods_price_txt.text = self.desc

    self.goTable.pay_type_close_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        PayTypePopPrefab.Close()
    end)
    self.goTable.zfb_btn.onClick:AddListener(function ()
        if self.goods_data and self.goods_data.zfb_pay and self.goods_data.zfb_pay == 2 then
            local str = self.goods_data.zfb_pay_desc or "暂不支持支付宝购买"
            LittleTips.Create(str)
            return
        end
        self:OnAlipayClick()
	end)

    self.goTable.wx_btn.onClick:AddListener(function ()
        if self.goods_data and self.goods_data.wx_pay and self.goods_data.wx_pay == 2 then
            local str = self.goods_data.wx_pay_desc or "暂不支持微信购买"
            LittleTips.Create(str)
            return
        end
      	self:OnWeixinClick()
    end)

    self.goTable.union_btn.onClick:AddListener(function ()
        if self.goods_data and self.goods_data.union_pay and self.goods_data.union_pay == 2 then
            local str = self.goods_data.union_pay_desc or "暂不支持银联购买"
            LittleTips.Create(str)
            return
        end
        self:OnUnionPayClick()
    end)

    if self.goods_data then
        local v = self.goods_data
        self.goTable.wx_doc_txt.text = v.wx_pay_desc or ""
        self.goTable.zfb_doc_txt.text = v.zfb_pay_desc or ""
    end

    self.pay_channel_map = {}
    self.pay_type_map = {}
    self.pay_type_map["alipay"] = {obj=self.goTable.zfb_btn}
    self.pay_type_map["weixin"] = {obj=self.goTable.wx_btn}
    self.pay_type_map["UnionPay"] = {obj=self.goTable.union_btn}

    for k,v in pairs(self.pay_type_map) do
        v.obj.gameObject:SetActive(false)
    end

    Network.SendRequest("get_pay_types",{goods_id = self.goods_data.id},"",function(data)
        dump(data,"<color=green>当前支持的支付方式</color>")
        if data.result ~= 0 then
            HintPanel.ErrorMsg(errorCode[data.result])
            PayTypePopPrefab.Close()
            return
        end
        if not IsEquals(self.gameObject) then
            PayTypePopPrefab.Close()
            return
        end

        if data.types and #data.types > 0 then
            local b = false
            for k,v in ipairs(data.types) do
                if v.channel then
                    self.pay_channel_map[v.channel] = v
                    if self.pay_type_map[v.channel] then
                        b = true
                        self.pay_type_map[v.channel].obj.gameObject:SetActive(true)
                    end
                end
            end

            if not b then
                local call = function ()
                    local local_cfgs = {"localconfig"}
                    for _, v in pairs(local_cfgs) do
                        local dir = gameMgr:getLocalPath(v)
                        if Directory.Exists(dir) then
                            Directory.Delete(dir, true)
                        end
                    end
                end
                call()

                HintPanel.Create(1, "支付方式已升级，请重新登陆，若遇异常情况请联系客服", function ()
                    gameMgr:QuitAll()
                end)
                return
            end

            if #data.types > 2 then
                --修改适配
                local ui = self.transform:Find("PayType/ImgCenter/Image"):GetComponent("HorizontalLayoutGroup")
                if IsEquals(ui) then
                    ui.spacing = 60
                end
                ui = nil
            end
        else
            HintPanel.Create(1, "当前不能支付",function(  )
                PayTypePopPrefab.Close()
            end)
        end
    end)
end

function PayTypePopPrefab:OnAlipayClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if not GameGlobalOnOff.ZFBPay then
        --支付宝没有开启
        HintPanel.Create(1, "支付宝支付尚未开通")
        return
    end
    --到网页购买
    self:SendPayRequest("alipay")
    destroy(self.gameObject)
end

function PayTypePopPrefab:OnWeixinClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	if not GameGlobalOnOff.WXPay then
        --微信支付没有开启
        HintPanel.Create(1, "微信支付尚未开通")
        return
    end
    --到网页购买
    self:SendPayRequest("weixin")
    destroy(self.gameObject)
end

function PayTypePopPrefab:OnUnionPayClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    --到网页购买 银联支付
    self:SendPayRequest("UnionPay")
    destroy(self.gameObject)
end

function PayTypePopPrefab:SendPayRequest(channel_type)
    local request = {}
    request.goods_id = self.goodsid

    if self.yhq_id then
        request.goods_id = self.yhq_id --购买优惠券
    end
    request.channel_type = channel_type
    request.geturl = MainModel.pay_url and "n" or "y"
    request.convert = self.convert
    dump(request, "<color=green>创建订单</color>")
    Network.SendRequest(
        "create_pay_order",
        request,
        function(_data)
            dump(_data, "<color=green>返回订单号</color>")
            if _data.result == 0 then
                if self.createcall then
                    self.createcall(_data.result)
                end
                MainModel.pay_url = _data.url or MainModel.pay_url
				MainModel.pay_channel_type = channel_type

                local url = string.gsub(MainModel.pay_url, "@(%g-)@", {
                    order_id=_data.order_id,
                    child_channel=self.pay_channel_map[channel_type].child_channel,
                })
                UnityEngine.Application.OpenURL(url)
            else
                HintPanel.ErrorMsg(_data.result)
            end
        end
    )
end

function PayTypePopPrefab.GetGoodsDataByID(id)
    local goods_data
    goods_data = MainModel.GetShopingConfig(GOODS_TYPE.goods, id)
    if table_is_null(goods_data) then
        goods_data = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, id)
    end
    return goods_data
end

--充值优惠券  
function PayTypePopPrefab:InitYHQ()
    dump(self.goods_data,"<color=red>|||||||||||||||</color>")
    if not self.goods_data or not self.goods_data.coupon_gift_id then return end
    if not CZYHQ or not CZYHQ[self.goods_data.price] then return end
    local yhq_price = CZYHQ[self.goods_data.price]
    local item_count = GameItemModel.GetItemCount(CZYHQ_ITEM[yhq_price])
    if not item_count or item_count < 1 then return end
    dump({yhq_price = yhq_price, item_count = item_count},"<color=green>充值优惠券</color>")
    self.goTable.yhq_txt.text = "<color=#ED8813FF>" .. (yhq_price / 100) .. "元</color>代金券"
    self.goTable.yhq_tge.onValueChanged:AddListener(
        function(val)
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if val then
                self.yhq_id = self.goods_data.coupon_gift_id
                self.goTable.goods_price_txt.text = "￥" .. (self.goods_data.price - yhq_price) / 100
            else
                self.yhq_id = nil
                self.goTable.goods_price_txt.text = "￥" .. self.goods_data.price / 100
            end
        end
    )
    self.yhq_id = self.goods_data.coupon_gift_id
    self.goTable.goods_price_txt.text = "￥" .. (self.goods_data.price - yhq_price) / 100
    self.goTable.yhq_tge.gameObject:SetActive(true)
end