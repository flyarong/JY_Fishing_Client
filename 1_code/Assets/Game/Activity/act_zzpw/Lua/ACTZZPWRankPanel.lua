-- 创建时间:2021-09-13
-- Panel:ACTZZPWRankPanel
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

ACTZZPWRankPanel = basefunc.class()
local C = ACTZZPWRankPanel
C.name = "ACTZZPWRankPanel"
local M = ACTZZPWManager

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
    self.lister["query_rank_base_info_response"]=basefunc.handler(self,self.on_query_rank_base_info)
    self.lister["query_rank_data_response"]=basefunc.handler(self,self.on_query_rank_data)
    self.lister["model_zhizhun_exp_change_msg"] = basefunc.handler(self, self.on_model_zhizhun_exp_change_msg)
    self.lister["model_zhizhun_rank_get_data_msg"] = basefunc.handler(self, self.on_model_zhizhun_rank_get_data_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    self:DeletItemPre()
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
    self.rank_type = "supreme_ranking_rank"
    Network.SendRequest("query_rank_data", { page_index = 1, rank_type = self.rank_type })
    Network.SendRequest("query_rank_base_info", { rank_type = self.rank_type })
    Network.SendRequest("zhizhun_rank_get_data")
end

function C:InitUI()
    self.back_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:MyExit()
    end)
    self.award_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnAwardClick()
    end)
	self:MyRefresh()
end

function C:MyRefresh()
    local cur_num = M.GetCurScore()
    local need_num = M.GetCurNeedScore()
    local cur_rank = M.GetCurRank()
    local tab = {"zzpw_icon_qt","zzpw_icon_by","zzpw_icon_hj","zzpw_icon_bj","zzpw_icon_zs","zzpw_icon_zz"}
    local index1 = math.ceil(cur_rank / 3)
    local index2 = cur_rank % 3
    if index2 == 0 then
		index2 = 3
	end
    self.xx_node.gameObject:SetActive(cur_rank ~= 16)
    self.rank_img.sprite = GetTexture(tab[index1])
    for i=1,3 do
        self["xx" .. i].gameObject:SetActive(false)
    end
    for i=1,index2 do
        self["xx" .. i].gameObject:SetActive(true)
    end
    local config = M.GetConfig()
    if config[cur_rank + 1] then
        self.rank_txt.gameObject:SetActive(true) 
        self.rank_txt.text = "还差" .. (need_num - cur_num) .. "点数可以晋升到" .. config[cur_rank + 1].rank_name
    else
        self.rank_txt.gameObject:SetActive(false) 
        self.rank_txt.text = ""
    end
    
    self.score_txt.text = cur_num
    --self:CreateItemPre()
end

function C:on_query_rank_base_info(_, data)
    dump(data,"<color=yellow>+++至尊排位:排行榜基础数据 query_rank_base_info_response+++</color>")
    if data.result ~= 0 then
        HintPanel.ErrorMsg(data.result)
        return
    end
    if data.rank ~= -1 then
        self.my_rank_txt.text = data.rank
    else
        self.my_rank_txt.text = "未上榜"
    end
    self.score_txt.text = data.score
end

function C:on_query_rank_data(_, data)
    dump(data,"<color=yellow>+++至尊排位:排行榜排行数据 query_rank_data_response+++</color>")
    if data.result ~= 0 then
        HintPanel.ErrorMsg(data.result)
        return
    end

    if table_is_null(data.rank_data) then
        LittleTips.Create("无数据")
        return
    end

    self:DeletItemPre()
    for i = 1, #data.rank_data do
        local pre = ACTZZPWRankItemBase.Create(self.Content.transform,data.rank_data[i])
        self.pre_cell[#self.pre_cell + 1] = pre
    end
end

--段位和经验发生改变
function C:on_model_zhizhun_exp_change_msg()
	self:MyRefresh()
end

function C:DeletItemPre()
    if self.pre_cell then
        for k,v in pairs(self.pre_cell) do
            v:MyExit()
        end
    end
    self.pre_cell = {}
end

function C:OnAwardClick()
    ACTZZPWRankAwardPanel.Create()
end

function C:on_model_zhizhun_rank_get_data_msg()
    self:MyRefresh()
end