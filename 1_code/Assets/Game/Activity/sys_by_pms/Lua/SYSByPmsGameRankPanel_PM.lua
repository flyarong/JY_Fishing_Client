-- 创建时间:2021-10-28
-- Panel:SYSByPmsGameRankPanel_PM
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

SYSByPmsGameRankPanel_PM = basefunc.class()
local C = SYSByPmsGameRankPanel_PM
C.name = "SYSByPmsGameRankPanel_PM"
local M = SYSByPmsManager

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
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["SYSByPms_query_bullet_rank_data"] = basefunc.handler(self,self.RefreshRank_pm)
    self.lister["SYSByPms_query_bullet_myrank_data"] = basefunc.handler(self,self.RefreshMyRank)    

    self.lister["SYSByPms_enter_scene"] = basefunc.handler(self,self.on_SYSByPms_enter_scene)   
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

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
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
    EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.on_BackClick)
    EventTriggerListener.Get(self.exit_btn.gameObject).onClick = basefunc.handler(self, self.on_ExitClick)
    EventTriggerListener.Get(self.help_btn.gameObject).onClick = basefunc.handler(self, self.on_HelpClick)
    self.spawn_cell_list = {}
    self.page_index = 1
    self:RefreshPage() 
    self.sv = self.ScrollView_pm.transform:GetComponent("ScrollRect")
    EventTriggerListener.Get(self.sv.gameObject).onEndDrag = function()
        local VNP = self.sv.verticalNormalizedPosition
        if VNP <= 0 then
            self:RefreshRankInfo()      
        end
    end
	self:MyRefresh()
end

function C:on_BackClick()
    self:MyExit()
end

function C:MyRefresh()
end

function C:RefreshPage()
    self:CheckShouldRefresh()
    self:DeletItemPre()
end

function C:DeletItemPre()
    self:CloseItemPrefab()
end

function C:CheckShouldRefresh()
    M.CloseRankData("hks",id)
    self:RefreshRankInfo()
end

function C:RefreshRankInfo()
    dump(self.page_index,"<color=yellow><size=15>++++++++++self.page_index++++++++++</size></color>")
    if self.page_index > 1 then
    else
        M.GetHallRank_data("hks",5, self.page_index)
    end
end

function C:CreateItemPrefab(data)
    for i=1,#data do
        local pre = SYSByPmsGameRankItem_pm.Create(self.Content_pm.transform, data[i],5,"hks")
        self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
    end
end

function C:CloseItemPrefab()
    if self.spawn_cell_list then
        for k,v in ipairs(self.spawn_cell_list) do
            v:MyExit()
        end
    end
    self.spawn_cell_list = {}
end

function C:on_ExitClick()
    SYSByPmsGameExitPanel.Create()
end


function C:RefreshMyRank(data)
    if data then
        local award_list = SYSByPmsManager.GetPMSAwardCfgByRank(FishingModel.game_id - 1,data.rank,"hks")
        if award_list then--玩家自己在榜上
            local item1 = GameItemModel.GetItemToKey(award_list[1].type)
            self.my_award_txt.text = StringHelper.ToCash(award_list[1].num)
        --[[else--玩家自己未上榜
            self.my_rank_txt.gameObject:SetActive(false)
            self.rank_img.gameObject:SetActive(true)
            self.my_name_txt.text = MainModel.UserInfo.name
            self.my_score_txt.text = ""
            self.my_award_txt.text = "--"--]]
        end
        self.my_rank_txt.gameObject:SetActive(true)
        self.rank_img.gameObject:SetActive(false)
        self.my_rank_txt.text = "第 "..data.rank.." 名"
        self.my_name_txt.text = data.player_name
        self.my_score_txt.text = data.score / 100
    else
        --初始化
        self.my_rank_txt.gameObject:SetActive(false)
        self.rank_img.gameObject:SetActive(true)
        self.my_name_txt.text = MainModel.UserInfo.name
        self.my_score_txt.text = ""
        self.my_award_txt.text = "--"
    end
end

function C:RefreshRank_pm(data)
    if data and #data > 0 then
        self:CreateItemPrefab(data)
        self.page_index = self.page_index + 1
    else
        LittleTips.Create("当前无新数据")
    end
end


function C:on_SYSByPms_enter_scene(b)
    if b then
        self:MyExit()
    end
end

function C:on_HelpClick()
    SYSByPmsGameRulesPanel.Create("hks")
end