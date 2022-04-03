local basefunc = require "Game/Common/basefunc"

EliminateSGInfoPanel = basefunc.class()
local M = EliminateSGInfoPanel
M.name = "EliminateSGInfoPanel"
local instance_Info
function M.Create()
    instance_Info = M.New()
    return instance_Info
end

function M:MakeLister()
    self.lister = {}
    self.lister["view_lottery_award"] = basefunc.handler(self, self.view_lottery_award)
    self.lister["eliminate_refresh_yazhu"] = basefunc.handler(self, self.eliminate_refresh_yazhu)
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
    self.lister["view_lottery_start"] = basefunc.handler(self, self.FreshList)
    self.lister["view_lottery_end"] = basefunc.handler(self, self.view_lottery_end)
	self.lister["view_lottery_error"] = basefunc.handler(self, self.view_lottery_error)
end

function M:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

--开奖错误
function M:view_lottery_error()
    --if EliminateSGModel.data.state ~= EliminateSGModel.xc_state.nor then return end
    self:FreshList()
end

--一个一个消灭
function M:view_lottery_award(data)
    if (EliminateSGModel.data.state == EliminateSGModel.xc_state.nor)
    or (EliminateSGModel.data.state == EliminateSGModel.xc_state.null)
    or (EliminateSGModel.data.state == EliminateSGModel.xc_state.select) then
    --if EliminateSGModel.data.state ~= EliminateSGModel.xc_state.nor then return end
     --dump(data,"<color>单次消除的信息</color>")
        if data then
        	self.AllInfoList[#self.AllInfoList + 1] = data
        	--对于当前的游戏规则来说，没有单独对每种元素进行押注。因此所有元素的押注都是一样的
            local rate = 1
            self:AddGold(self.BetList[1] * data.cur_rate * rate)
            data.cur_del_list = data.cur_del_map
            if table_is_null(data.cur_del_list) then return  end 
            local data2 = self:SoringData(data.cur_del_list)
            for k, v in pairs(data2) do
                self:DesPrefabInto(k, v, false)
            end
        end
    end 
end

--把信息整理成 （类型：个数）的形式
function M:SoringData(cur_del_list)
    local data = {}
    for k, v in pairs(cur_del_list) do
        for m, n in pairs(v) do
            if data[n] then
                data[n] = data[n] + 1
            else
                data[n] = 1
            end
        end
    end
    return data
end

--断线重连获取数据 或者 结束的时候 重新刷新一次数据
function M:view_lottery_end(data)
    if (EliminateSGModel.data.state == EliminateSGModel.xc_state.nor)
     or (EliminateSGModel.data.state == EliminateSGModel.xc_state.null)
      or (EliminateSGModel.data.state == EliminateSGModel.xc_state.select) then
        self:MyRefresh(data)
    end
end

function M:DesPrefabInto(id, num, IsReConnect)
    local num = "x" .. num
    EliminateSGDesPrefab.Create(id, num, IsReConnect, self.Content)
end

function M:AddGold(S)
    if self.gold + S > EliminateSGModel.GetAwardMoney() then
        return
    end
    self.gold = self.gold + S
    -- if  self.gold>=EliminateSGModel.GetAwardMoney() then
    -- 	self.gold=EliminateSGModel.GetAwardMoney()
    -- end
    self.goldtext.text = StringHelper.ToCash(self.gold)
end

--重置各种记录数据
function M:FreshList()
    --if EliminateSGModel.data.state ~= EliminateSGModel.xc_state.nor then return end
    self.gold = 0
    self.goldtext.text = 0
    self.AllInfoList = {}
    destroyChildren(self.Content)
end

function M:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
    self:RemoveListener()
    if self.WS_Timer then
        self.WS_Timer:Stop()
    end
    self.WS_Timer = nil
    destroy(self.gameObject)
    instance_Info=nil
end


function M:ctor()

	ExtPanel.ExtMsg(self)

    self.profablist = {}
    self.gold = 0
    self.BetList = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
        [4] = 0,
        [5] = 0
    }
    self.parent = GameObject.Find("Canvas/LayerLv1").transform
    self.gameObject = newObject(M.name, self.parent)
    self.gold = 0
    self.AllInfoList = {}
    self.goldtext = self.gameObject.transform:Find("bgs/GoldInfo/GoldText"):GetComponent("Text")
    self.goldtext.text = 0
    self.Content = self.gameObject.transform:Find("bgs/Viewport/TaskNode")
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
end

function M:InitUI()
    local btn_map = {}
	btn_map["left_down"] = {self.left_down}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "xxlsg_game")

    self.gameObject.transform:Find("bgs/Help"):GetComponent("Button").onClick:AddListener(
        function()
            EliminateSGHelpPanel.Create()
        end
    )
end

function M:eliminate_refresh_yazhu(data)
    self.BetList[data[1]] = data[2]
    EliminateSGModel.SetBet(self.BetList)
end

function M:MyRefresh(data)
    dump(self.gold, "由每次累计算出的鲸币")
    local sum = 0
    if not table_is_null(self.AllInfoList) then
        for i = 1, #self.AllInfoList do
            sum = sum + self.AllInfoList[i].cur_rate
        end
    end
    dump(sum, "<color=red>由每次累计算出的倍率</color>")

    self:FreshList()
    dump(data, "<color=red>结算数据</color>")
    for i = 1, #data.all_del_list do
        local data2 = self:SoringData(data.all_del_list[i])
        for k, v in pairs(data2) do
            self:DesPrefabInto(k, v, true)
        end
    end
    self:AddGold(data.all_money)
end
