-- 创建时间:2020-12-11
-- Panel:VIPMZFLChildPrefab
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

VIPMZFLChildPrefab = basefunc.class()
local C = VIPMZFLChildPrefab
C.name = "VIPMZFLChildPrefab"

function C.Create(parent, index, type)
	return C.New(parent, index, type)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
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

function C:ctor(parent, index, type)
	self.index = index
    self.type = type
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
    if type == "xyhl" then

    else
        self.config = VIPManager.GetVIPMzflCfgByIndex(self.index)
    end
	
	self:InitUI()
end

function C:InitUI()
    if self.type == "xyhl" then
        self.GOButton_btn.onClick:AddListener(function ()
            Act_061_XYHLPanel.Create()
        end)
    else
    	self.GOButton_btn.onClick:AddListener(function ()
            if MainModel.UserInfo.ui_config_id == 1 and MainModel.UserInfo.vip_level < 1 then
                GameManager.GotoUI({gotoui="hall_activity", goto_scene_parm="panel"})
            else
                PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
            end
            Event.Brocast("TRY_VIP_SHOW_TASK_COLSE")
        end)
        self.LQButton_btn.onClick:AddListener(function ()
        	local task_data = GameTaskModel.GetTaskDataByID(self.config.task_id)
            if not task_data or task_data.award_status == 0 then
                HintPanel.Create(1, self.config.desc, function ()
                    PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
                    Event.Brocast("TRY_VIP_SHOW_TASK_COLSE")
                end)
            else
                if os.date("%w", os.time()) == "0"  then
                    Network.SendRequest("get_task_award_new", { id = self.config.task_id, award_progress_lv = 1 })
                else
                    HintPanel.Create(1,"请在周日的0点到24点期间领取奖励！")
                end 
            end
        end)
    end
	self:MyRefresh()
end

function C:MyRefresh()
    if self.type == "xyhl" then
        self.GOButton_btn.gameObject:SetActive(true)
        self.MASK.gameObject:SetActive(false)
        self.title_txt.text = "新游豪礼"
        local obj = GameObject.Instantiate(self.AwardChild, self.Content)
        obj.gameObject:SetActive(true)
        local ui = {}
        LuaHelper.GeneratingVar(obj.transform, ui)
        ui.icon_img.sprite = GetTexture("xyhl_icon_bwfl")
        ui.award_txt.text = "海量福利"
    else
        if self.config then
        	self.title_txt.text = self.config.title
        	local n = #self.config.image
        	for i = 1, n do
        		local obj = GameObject.Instantiate(self.AwardChild, self.Content)
                obj.gameObject:SetActive(true)
                local ui = {}
                LuaHelper.GeneratingVar(obj.transform, ui)

                ui.icon_img.sprite = GetTexture(self.config.image[i])
                ui.award_txt.text = self.config.text[i]
                if self.config.tips and self.config.tips[i] and self.config.tips[i] ~= "" then
        	        PointerEventListener.Get(ui.icon_img.gameObject).onDown = function ()
        	            GameTipsPrefab.ShowDesc(self.config.tips[i], UnityEngine.Input.mousePosition)
        	        end
        	        PointerEventListener.Get(ui.icon_img.gameObject).onUp = function ()
        	            GameTipsPrefab.Hide()
        	        end
                end
        	end
            self:RefreshTask()
        end
    end
end

function C:RefreshTask()
	local task_data = GameTaskModel.GetTaskDataByID(self.config.task_id)
    local vip_data = VIPManager.get_vip_data()
    if not vip_data then
        self.gameObject:SetActive(false)
        return
    end

    if IsEquals(self.GOButton_btn) then
        self.GOButton_btn.gameObject:SetActive(false)
    end
    if IsEquals(self.LQButton_btn) then
        self.LQButton_btn.gameObject:SetActive(false)
    end
    if IsEquals(self.MASK) then
        self.MASK.gameObject:SetActive(false)
    end
	if task_data then
        if task_data.award_status == 0 then
            self.GOButton_btn.gameObject:SetActive(true)
        elseif task_data.award_status == 1 then 
            self.LQButton_btn.gameObject:SetActive(true)
        elseif task_data.award_status == 2 then
            self.MASK.gameObject:SetActive(true)
        end 
    else
        self.GOButton_btn.gameObject:SetActive(true)
    end
    
    if vip_data then
    	if vip_data.vip_level <= self.config.vip then
    		self.gameObject:SetActive(true)
    	else
    		self.gameObject:SetActive(false)
    	end
    else
        self.gameObject:SetActive(false)
    end

    if not task_data and vip_data.vip_level >= self.config.vip and self.config.vip == 2 then
        self.gameObject:SetActive(false)
    end
end

function C:UpdateData(index)
	self:RefreshTask()
	self.transform:SetSiblingIndex(index)
end
