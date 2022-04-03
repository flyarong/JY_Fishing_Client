-- 创建时间:2018-12-19

local basefunc = require "Game/Common/basefunc"

OneYuanGift = basefunc.class()

OneYuanGift.name = "OneYuanGift"

OneYuanGift.instance = nil
-- 什么都没有执行的回调 no_run_call
-- 已经写成这样了，我就不改了wqp
function OneYuanGift.Create(cb, no_run_call)
    if GameGlobalOnOff.InternalTest then
        GameButtonManager.RunFun({ gotoui="sys_jjj", type="ldb", no_run_call=function ()
            
        end}, "CheckAndRunJJJ")

        return
    end

    if not OneYuanGift.instance then
        OneYuanGift.instance = true
        OneYuanGift.New(cb, no_run_call)
    else
        print("<color=red>sssssssssssssssssssssssssssssss</color>")
    end
	return OneYuanGift.instance
end

--启动事件--
function OneYuanGift:ctor(cb, no_run_call)
    self.queryFinished = false
    self.shareCount = 0
    self.canBuy = false
    self.doShareOrBuy = false
    self.reqCallBack = cb
    self.no_run_call = no_run_call

    self:MakeListener()
    self:AddMsgListener()

    self:InitUI()
end

function OneYuanGift:OnExitScene()
    self:OnDestroy()
end

function OneYuanGift:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function OneYuanGift:MakeListener()
    self.lister = {}
    self.lister["query_broke_subsidy_num_response"] = basefunc.handler(self, self.query_broke_subsidy_num)
    self.lister["query_free_broke_subsidy_num_response"] = basefunc.handler(self, self.query_free_broke_subsidy_num_response)

    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
    self.lister["OnLoginResponse"] = basefunc.handler(self, self.OnExitScene)
    self.lister["will_kick_reason"] = basefunc.handler(self, self.OnExitScene)
    self.lister["DisconnectServerConnect"] = basefunc.handler(self, self.OnExitScene)
end

function OneYuanGift:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function OneYuanGift:InitUI()
    if MainModel.UserInfo.freeSubsidyNum then
        if MainModel.UserInfo.shareCount then
            self:OnQueryFinished()
        else
            Network.SendRequest("query_broke_subsidy_num", nil, "请求数据")
        end
    else
        Network.SendRequest("query_free_broke_subsidy_num", nil, "请求数据")
    end
end
function OneYuanGift:query_free_broke_subsidy_num_response(_, data)
    dump(data, "<color=white>query_free_broke_subsidy_num_response</color>")
    MainModel.UserInfo.freeSubsidyNum = data.num or 0
    if MainModel.UserInfo.shareCount then
        self:OnQueryFinished()
    else
        Network.SendRequest("query_broke_subsidy_num", nil, "请求数据")
    end
end
function OneYuanGift:query_broke_subsidy_num(_, data)
    dump(data, "<color=white>query_broke_subsidy_num</color>")
    MainModel.UserInfo.shareCount = data.num or 0
    self.queryFinished = true
    self:OnQueryFinished()
end
--去掉现有的3元福利礼包，将现有的1元福利进行调整：
--(1)礼包价格改为3元；
--(2)礼包内容改为3.5万鲸+0.1元至10元随机红包
--(3)红包随机概率，进行2次随机：
--因此现在的status1yuan是三元礼包了  11.6.2019
function OneYuanGift:OnQueryFinished()
    MainModel.UserInfo.shareCount = MainModel.UserInfo.shareCount or 0
    MainModel.UserInfo.freeSubsidyNum = MainModel.UserInfo.freeSubsidyNum or 0
    self.status1yuan = MainModel.GetGiftShopStatusByID(10)
    self.status3yuan = 0--MainModel.GetGiftShopStatusByID(72)
    -- 不能购买一元礼包 没有新手特权 没有转运金
    if self.status1yuan == 0 and self.status3yuan == 0 and MainModel.UserInfo.freeSubsidyNum <= 0 and MainModel.UserInfo.shareCount <= 0 then
        if self.no_run_call then
            self.no_run_call()
        end
        self:OnDestroy()
    else
        if self.status1yuan == 1 then
            GameShop1YuanPanel.Create(nil, function ()
                self.status1yuan = MainModel.GetGiftShopStatusByID(10)
                if self.status1yuan == 1 then
                    self:ShowFreeSubsidy()
                else
                    self:OnDestroy()
                end
            end)
        elseif self.status3yuan == 1 then
            GameShop3YuanPanel.Create(nil, function ()
                self.status3yuan = MainModel.GetGiftShopStatusByID(72)
                if self.status3yuan == 1 then
                    self:ShowFreeSubsidy()
                else
                    self:OnDestroy()
                end
            end)            
        else
            self:ShowFreeSubsidy()
        end
    end
end
-- 发送请求 领取免费津贴
function OneYuanGift:ShowFreeSubsidy()
    GameButtonManager.RunFun({ gotoui="sys_jjj", type="ldb", no_run_call=function ()
        if self.status1yuan == 1 or self.status3yuan == 1 then
            -- self:OnDestroy()
            -- 捕鱼不提示去比赛场
            Event.Brocast("show_gift_panel")

            -- todo 去掉比赛导流
            -- if MainModel.myLocation ~= "game_Fishing" and MainModel.myLocation ~= "game_TTL" then
            --     GameManager.GotoUI({gotoui = "guide_to_match",goto_scene_parm = "panel"})
            -- end
        else
            if self.no_run_call then
                self.no_run_call()
            end
            -- self:OnDestroy()
        end
    end}, "CheckAndRunJJJ")
    self:OnDestroy()
end
function OneYuanGift:OnDestroy()
    self:RemoveListener()
    OneYuanGift.instance = nil
end

function OneYuanGift:Close()
    if self.reqCallBack then
        self.reqCallBack()
    end
    self:OnDestroy()
end
