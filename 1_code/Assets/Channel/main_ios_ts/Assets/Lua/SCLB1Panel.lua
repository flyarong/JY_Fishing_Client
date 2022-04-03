
local basefunc = require "Game/Common/basefunc"
SCLB1Panel = basefunc.class()
local C = SCLB1Panel
C.name = "SCLB1Panel"

local instance
function C.Create(parent,backcall)
    if  instance==nil then
        instance = C.New(parent,backcall)
    end
    return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	self.lister["model_sclb1_gift_change_msg"] = basefunc.handler(self, self.on_model_sclb1_gift_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    if self.backcall then 
        self.backcall()
    end 
	self:RemoveListener()
    instance=nil
    destroy(self.gameObject)

	 
end

function C:ctor(parent, backcall)

	ExtPanel.ExtMsg(self)

    self.backcall = backcall
	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject("SCLB1Panel", parent)
	local tran = obj.transform
	self.transform = tran
    self.gameObject = obj
	self:MakeLister()
    self:AddMsgListener()
    LuaHelper.GeneratingVar(self.transform,self)
	self:InitUI()
end


function C:InitUI()
    self.close_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:MyExit()
    end)
    for i=1,#SYSSCLB1Manager.shopid do
        self["gift" .. i .. "_btn"].onClick:AddListener(function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnShopClick(SYSSCLB1Manager.shopid[i])
        end)
    end
	self:MyRefresh()
end

function C:MyRefresh()    
    
end

function C:OnShopClick(id)
	
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
	
		local goodsData = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, id)
		if not LuaHelper.OnPurchaseClicked(
			goodsData.product_id,
			function(receipt, transactionID,definition_id)
				local order = {}
				order.transactionId = transactionID
				order.productId = goodsData.product_id
				order.definition_id = definition_id
				order.receipt = receipt
				--order.convert = self.convert
				--是否用沙盒支付 0-no  1-yes
				order.isSandbox = GameGlobalOnOff.PGPayFun and 1 or 0

				IosPayManager.AddOrder(order)
			end
		)then
			HintPanel.Create(1, "暂时无法连接iTunes Store，请稍后购买")
			return
		end

	end
end

function C:on_model_sclb1_gift_change_msg()
    self:MyExit()
end

function C:OnExitScene()
	self:MyExit()
end