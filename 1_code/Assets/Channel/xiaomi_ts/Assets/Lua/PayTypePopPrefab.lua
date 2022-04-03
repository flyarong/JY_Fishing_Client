-- 创建时间:2018-09-20
-- 华为支付方式界面

local basefunc = require "Game.Common.basefunc"

PayTypePopPrefab = basefunc.class()

local instance = nil

function PayTypePopPrefab.Create(goodsid, desc, createcall,convert)
	local iconFile = "com_icon_diamond.png"
	local imgFile = resMgr.DataPath .. iconFile
	if not File.Exists(imgFile) then
		if not resMgr:ExtractSprite(iconFile, imgFile) then
			print("[Pay] extract sprite failed:" .. iconFile)
			return
		end
	end

    local goods_data = PayTypePopPrefab.GetGoodsDataByID(goodsid)

	local request = {}

    request.goods_id = goodsid
    if PayTypePopPrefab.IsCanUseYHQ(goods_data) then
        request.goods_id = goods_data.coupon_gift_id
    end

	request.convert = convert
	if PayPanel.IsTest() then
		request.is_test = 1
	else
		request.is_test = 0
    end
    
    print("PayTypePopPrefab.Create" .. request.goods_id)
    dump(request,"<color=red>||||||||||||||</color>")
	Network.SendRequest("xiaomi_create_pay_order", request, function(_data)
		dump(_data, "<color=green>返回订单号</color>")
        if _data.result == 0 then

			local userid = MainModel.UserInfo.user_id or 0
			local username = MainModel.UserInfo.name or ""
			local balance = MainModel.UserInfo.jing_bi or 0
            
			local userlv = 0
            local a,b = GameButtonManager.RunFun({gotoui="sys_by_level"}, "GetLevel")
            if a and b then
                userlv = b
            end

			local luaData = {
				orderId = _data.order_id,
				userInfo = tostring(request.goods_id),
				amount = goods_data.price * 0.01,
				balance = tostring(balance),
				vip = "0",
				level = tostring(userlv),
				roleId = tostring(userid),
				roleName = username,
				party = "by",
				serverName = "by"
			}
			--if convert then
			--	luaData.productName = luaData.productName .. "-->鲸币"
			--end
		    
            dump(luaData)

            sdkMgr:Pay(lua2json(luaData), function(json_data)
				local lua_tbl = json2lua(json_data)
				dump(lua_tbl, "[debug] xiaomi pay result")
				if lua_tbl.result ~= 0 then
					if lua_tbl.result == -5 and lua_tbl.errno == -18003 then
						HintPanel.Create(1, "用户取消支付")
					else
						HintPanel.Create(1, "支付异常(" .. lua_tbl.result .. ":" .. lua_tbl.errno .. ")")
					end
				end
			end)
		else
			HintPanel.ErrorMsg(_data.result)
		end
	end)

	-- instance = PayTypePopPrefab.New(goodsid, desc, createcall,convert)
    -- return instance
end

function PayTypePopPrefab:ctor(goodsid, desc, createcall,convert)
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
end
function PayTypePopPrefab:InitRect()
	self.goTable.goods_price_txt.text = self.desc

    self.goTable.pay_type_close_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        MainLogic.IsHideAssetsGetPanel = nil
        destroy(self.gameObject)
    end)
    self.goTable.zfb_btn.onClick:AddListener(function ()
        if self.goods_data and self.goods_data.zfb_pay and self.goods_data.zfb_pay == 2 then
            local str = self.goods_data.zfb_pay_desc or "暂不微信支持购买"
            LittleTips.Create(str)
            return
        end
        self:OnAlipayClick()
	end)

    self.goTable.wx_btn.onClick:AddListener(function ()
        if self.goods_data and self.goods_data.wx_pay and self.goods_data.wx_pay == 2 then
            local str = self.goods_data.wx_pay_desc or "暂不微信支持购买"
            LittleTips.Create(str)
            return
        end
      	self:OnWeixinClick()
    end)
    if self.goods_data then
        local v = self.goods_data
        if v.wx_pay then
            if v.wx_pay == 0 then
                self.goTable.wx_btn.gameObject:SetActive(false)
            elseif v.wx_pay == 1 then
                self.goTable.wx_btn.gameObject:SetActive(true)
            elseif v.wx_pay == 2 then
                self.goTable.wx_btn.gameObject:SetActive(true)
                local img = self.goTable.wx_btn.transform:GetComponent("Image")
                if img then
                    img.material = GetMaterial("imageGrey")
                end
            end
        end
        self.goTable.wx_doc_txt.text = v.wx_pay_desc or ""

        if v.zfb_pay then
            if v.zfb_pay == 0 then
                self.goTable.zfb_btn.gameObject:SetActive(false)
            elseif v.zfb_pay == 1 then
                self.goTable.zfb_btn.gameObject:SetActive(true)
            elseif v.zfb_pay == 2 then
                self.goTable.zfb_btn.gameObject:SetActive(true)
                local img = self.goTable.zfb_btn.transform:GetComponent("Image")
                if img then
                    img.material = GetMaterial("imageGrey")
                end
            end
        end
        self.goTable.zfb_doc_txt.text = v.zfb_pay_desc or ""

        if v.wx_pay and v.zfb_pay then
            if v.wx_pay == 0 and v.zfb_pay ~= 0 then
                self.goTable.zfb_btn.transform.localPosition = Vector3.New(0,-105,0)
            elseif v.wx_pay ~= 0 and v.zfb_pay == 0 then
                self.goTable.wx_btn.transform.localPosition = Vector3.New(0,-105,0)
            end
        end
    end
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

                local url = string.gsub(MainModel.pay_url, "@order_id@", _data.order_id)
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
function PayTypePopPrefab.IsCanUseYHQ(goods_data)
    local _goods = goods_data
    if not _goods or not _goods.coupon_gift_id then 
        return false 
    end
    if not CZYHQ or not CZYHQ[_goods.price] then
        return false
    end
    local yhq_price = CZYHQ[_goods.price]
    local item_count = GameItemModel.GetItemCount(CZYHQ_ITEM[yhq_price])
    if not item_count or item_count < 1 then 
        return false 
    end
    return true
end