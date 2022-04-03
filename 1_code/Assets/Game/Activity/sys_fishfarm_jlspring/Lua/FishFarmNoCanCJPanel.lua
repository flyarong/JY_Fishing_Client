-- 创建时间:2020-11-17
-- Panel:FishFarmNoCanCJPanel
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

FishFarmNoCanCJPanel = basefunc.class()
local C = FishFarmNoCanCJPanel
C.name = "FishFarmNoCanCJPanel"

local M = FishFarmJlSpringManager


 -- gift_index 1/2 普通/高级    _type  1/10 单抽/10连抽
function C.Create(gift_index, _type, parent_panel)
	return C.New(gift_index, _type, parent_panel)
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
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(gift_index, _type, parent_panel)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

    ---参数
	self.gift_index = gift_index
    self.type = _type
    self.parent_panel = parent_panel

	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	self.back_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:MyExit()
    end)


    self.exit_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:MyExit()
    end)

    self.go_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:BuyShop()
    end)
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
    self:RefreshUI()
end


function C:BuyShop()
    ----------------------------------普通单次抽奖和10连-------------------
    if self.gift_index and self.gift_index == 1 then
        if self.type == 1 then
            Network.SendRequest("fishbowl_lottery_buy", {id = self.gift_index, num = 1},"请求数据",function(data)
                dump(data,"<color=red>fishbowl_lottery_buy 普通单次</color>")
                if data.result == 0 then
                    Network.SendRequest("fishbowl_lottery", {id = 1 ,type = 1, num = 1},"请求数据", function (data)
                        if data.result == 0 then
                            self.parent_panel:SetAwardData(data.ids, self.gift_index)
                            self:MyExit()
                        end
                    end)
                else
                    LittleTips.Create("当前星星不足，养鱼和售卖鱼苗获得星星")
                end
            end)
        else
            Network.SendRequest("fishbowl_lottery_buy", {id = self.gift_index, num = (10 - GameItemModel.GetItemCount("prop_fishbowl_coin1"))},"请求数据",function(data)
                dump(data,"<color=red>fishbowl_lottery_buy 普通10连</color")
                if data.result == 0 then
                    Network.SendRequest("fishbowl_lottery", {id = self.gift_index ,type = 1, num = 10},"请求数据", function (data)
                        if data.result == 0 then
                            self.parent_panel:SetAwardData(data.ids, self.gift_index)
                            self:MyExit()
                        end
                    end)
                else
                     LittleTips.Create("当前星星不足，养鱼和售卖鱼苗获得星星")
                end
            end)
        end
    end
    
 -----------------------------------高级单次 和 10连--------------------------------------------------
    if self.gift_index and self.gift_index == 2 then
        if self.type == 1 then
            Network.SendRequest("fishbowl_lottery_buy", {id = self.gift_index, num = 1},"请求数据",function(data)
                dump(data,"<color=red>fishbowl_lottery_buy 高级单次</color>")
                if data.result == 0 then
                    Network.SendRequest("fishbowl_lottery", {id = self.gift_index ,type = 1, num = 1},"请求数据", function (data)
                        if data.result == 0 then
                            self.parent_panel:SetAwardData(data.ids, self.gift_index)
                            self:MyExit()
                        end
                    end)
                else
                    LittleTips.Create("金币不足")
                end
            end)
        else
            Network.SendRequest("fishbowl_lottery_buy", {id = self.gift_index, num = (10 - GameItemModel.GetItemCount("prop_fishbowl_coin2"))},"请求数据",function(data)
                dump(data,"<color=red>fishbowl_lottery_buy 高级10连</color>")
                if data.result == 0 then
                    Network.SendRequest("fishbowl_lottery", {id = self.gift_index ,type = 1, num = 10},"请求数据", function (data)
                        if data.result == 0 then
                            self.parent_panel:SetAwardData(data.ids, self.gift_index)
                            self:MyExit()
                        end
                    end)
                else
                    LittleTips.Create("金币不足")
                end
            end)
        end
    end
end


function C:RefreshUI()
    dump(self.gift_index)
    -- gift_index 1/2 普通/高级    _type  1/10 单抽/10连抽
    if self.gift_index == 1 then
        self.ic1_img.sprite = GetTexture("szg_iocn_xx")
        self.type_img.sprite =  GetTexture("szg_iocn_xx")
        self.dj_img.sprite =  GetTexture("szg_iocn_jlyb")
        self.ts_txt.text = "普通精灵币不足，需购买饲料进行召唤"
        if self.type == 1 then
            self.jg_txt.text = M.GetSpringBuyInfor()[self.gift_index].cost_num.."购买"
            self.number_txt.text = "x1"
            self.ds1_txt.text = M.GetSpringBuyInfor()[self.gift_index].cost_num
            self.ds2_txt.text = M.GetSpringBuyInfor()[self.gift_index].item_num
        else
            local num = 10 - GameItemModel.GetItemCount("prop_fishbowl_coin1")
            self.number_txt.text = "x"..num
            self.ds2_txt.text = num * M.GetSpringBuyInfor()[self.gift_index].item_num
            self.jg_txt.text =  num * M.GetSpringBuyInfor()[self.gift_index].cost_num.."购买"
            self.ds1_txt.text = num * M.GetSpringBuyInfor()[self.gift_index].cost_num
        end
    else 
        self.ic1_img.sprite = GetTexture("szzg_iocn_yb")
        self.type_img.sprite =  GetTexture("szzg_iocn_yb")
        self.dj_img.sprite =  GetTexture("szg_iocn_gjjlyb")
        self.ts_txt.text = "高级精灵币不足，需购买饲料进行召唤"
        if self.type == 1 then
            self.jg_txt.text = M.GetSpringBuyInfor()[self.gift_index].cost_num.."购买"
            self.number_txt.text = "x1"
            self.ds1_txt.text = M.GetSpringBuyInfor()[self.gift_index].cost_num
            self.ds2_txt.text = M.GetSpringBuyInfor()[self.gift_index].item_num
        else
            local num = 10 - GameItemModel.GetItemCount("prop_fishbowl_coin2")
            self.number_txt.text = "x"..num
            self.ds2_txt.text = num * M.GetSpringBuyInfor()[self.gift_index].item_num
            self.jg_txt.text =  num * M.GetSpringBuyInfor()[self.gift_index].cost_num.."购买"
            self.ds1_txt.text = num * M.GetSpringBuyInfor()[self.gift_index].cost_num
        end
    end
end