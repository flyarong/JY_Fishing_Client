-- 创建时间:2021-09-26
-- Panel:Act_061_XYHLChild2Panel
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

Act_061_XYHLChild2Panel = basefunc.class()
local C = Act_061_XYHLChild2Panel
C.name = "Act_061_XYHLChild2Panel"
local M = Act_061_XYHLManager

function C.Create(parent,index)
	return C.New(parent,index)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["061_xyhl_bdid_success_msg"] = basefunc.handler(self,self.on_061_xyhl_bdid_success_msg)
    self.lister["061_xyhl_task_change_msg"] = basefunc.handler(self,self.on_061_xyhl_task_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    self:StopTimer()
    self:CloseItemPrefab()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent,index)
	ExtPanel.ExtMsg(self)
    self.index = index - 1
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
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
    EventTriggerListener.Get(self.help_btn.gameObject).onClick = basefunc.handler(self, self.OnHelpClick)
    EventTriggerListener.Get(self.bd_btn.gameObject).onClick = basefunc.handler(self, self.OnBDClick)
	self:MyRefresh()
end

function C:MyRefresh()
    self:RefreshStyle()
    self:CreateItemPrefab()
end

local m_sort = function (v1,v2)
    local priority_tab = {2,1,3}
    local status_v1 = 0
    local status_v2 = 0
    local data1 = GameTaskModel.GetTaskDataByID(v1.task_id)
    if data1 then
        if v1.level then
            local b = basefunc.decode_task_award_status(data1.award_get_status)
            b = basefunc.decode_all_task_award_status(b, data1, M.get_count(v1.task_id))
            status_v1 = b[v1.level]
        else
            status_v1 = data1.award_status
        end
    end
    local data2 = GameTaskModel.GetTaskDataByID(v2.task_id)
    if data2 then
        if v2.level then
            local b = basefunc.decode_task_award_status(data2.award_get_status)
            b = basefunc.decode_all_task_award_status(b, data2, M.get_count(v2.task_id))
            status_v2 = b[v2.level]
        else
            status_v2 = data2.award_status
        end
    end
    status_v1 = priority_tab[status_v1 + 1]
    status_v2 = priority_tab[status_v2 + 1]
    if status_v1 < status_v2 then
        return false
    elseif status_v1 > status_v2 then
        return true
    else
        if v1.index < v2.index then
            return false
        else
            return true
        end
    end
end

function C:CreateItemPrefab()
    self:CloseItemPrefab()
    local temp_tab = basefunc.deepcopy(M.GetTaskConfig()[self.index])
    local config = {}
    for i=1,#temp_tab do
        if temp_tab[i].condi_key then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = temp_tab[i].condi_key, is_on_hint = true}, "CheckCondition")
            if a and b then
                config[#config + 1] = temp_tab[i]
            end
        else
            config[#config + 1] = temp_tab[i]
        end
    end
    MathExtend.SortListCom(config, m_sort)
    for i=1,#config do
        local pre = Act_061_XYHLTaskItem.Create(self.Content.transform,config[i])
        self.pre_cell[#self.pre_cell + 1] = pre
    end
end

function C:CloseItemPrefab()
    if self.pre_cell then
        for k,v in pairs(self.pre_cell) do
            v:MyExit()
        end
    end
    self.pre_cell = {}
end

local help_info = {
"1.成功绑定新游戏中的游戏ID即可激活任务，绑定即得300福利券；",
"2.在新游戏中参与游戏、充值等可积攒任务进度；",
"3.在新游中联系客服QQ：4008882620可直升VIP3；",
"4.累计赢金范围包括所有游戏，捕鱼类游戏赢金按50%计算，苹果大战只计算纯赢；",
"5.累计充值任务中购买带有“超值标签”的商品不计入任务；",
"6.玩新游，可两边领奖励，更多福利请在新游中发现吧！",
}
function C:OnHelpClick()
    local str = help_info[1]
    for i = 2, #help_info do
        str = str .. "\n" .. help_info[i]
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:on_061_xyhl_bdid_success_msg()
    self:MyRefresh()
end

function C:StopTimer()
    if self.cutdown_timer then
        self.cutdown_timer:Stop()
        self.cutdown_timer = nil
    end
end

function C:RefreshStyle()
    if M.GetNewID() then
        self.bg_img.sprite = GetTexture("xyshl_bg_ksdk")
        self:StopTimer()
        self.cutdown_timer = CommonTimeManager.GetCutDownTimer(M.GetTaskEndTime(),self.remain_txt)
        self.help_btn.transform:GetComponent("Image").sprite = GetTexture("xyshl_btn_gzks")
        self.xyid_txt.text = M.GetNewID()
        self.vipdj_txt.text = M.GetNewVIP()
        self.ljyj_txt.text = StringHelper.ToCash(M.GetNewLJYJ())
        self.ljcz_txt.text = M.GetNewLJCZ()
        self.bd_btn.gameObject:SetActive(false)
        self.remain_txt.color = Color.New(237/255,254/255,1,1)
        self.xyid.transform:GetComponent("Outline").effectColor = Color.New(167/255,66/255,17/255,1)
        self.vipdj.transform:GetComponent("Outline").effectColor = Color.New(167/255,66/255,17/255,1)
        self.ljyj.transform:GetComponent("Outline").effectColor = Color.New(167/255,66/255,17/255,1)
        self.ljcz.transform:GetComponent("Outline").effectColor = Color.New(167/255,66/255,17/255,1)
    else
        self.bg_img.sprite = GetTexture("xyshl_bg_wksdk")
        self.remain_txt.text = "未开始"
        self.help_btn.transform:GetComponent("Image").sprite = GetTexture("xyshl_btn_gzwks")
        self.bd_btn.gameObject:SetActive(true)
        self.remain_txt.color = Color.New(32/255,82/255,175/255,1)
        self.xyid_txt.gameObject:SetActive(false)
        self.vipdj_txt.gameObject:SetActive(false)
        self.ljyj_txt.gameObject:SetActive(false)
        self.ljcz_txt.gameObject:SetActive(false)
        self.xyid.transform:GetComponent("Outline").effectColor = Color.New(32/255,82/255,175/255,1)
        self.vipdj.transform:GetComponent("Outline").effectColor = Color.New(32/255,82/255,175/255,1)
        self.ljyj.transform:GetComponent("Outline").effectColor = Color.New(32/255,82/255,175/255,1)
        self.ljcz.transform:GetComponent("Outline").effectColor = Color.New(32/255,82/255,175/255,1)
    end
end

function C:OnBDClick()
    Act_061_XYHLBDIDPanel.Create()
end

function C:on_061_xyhl_task_change_msg()
    self:MyRefresh()
end