-- 创建时间:2021-10-11
-- Panel:Act_062_HGLYItemBase
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

Act_062_HGLYItemBase = basefunc.class()
local C = Act_062_HGLYItemBase
C.name = "Act_062_HGLYItemBase"
local M = Act_062_HGHDManager

function C.Create(parent, config, all_count, gift_id)
	return C.New(parent, config, all_count, gift_id)
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

function C:ctor(parent, config, all_count, gift_id)
	ExtPanel.ExtMsg(self)
    self.config = config
    self.all_count = all_count
    self.gift_id = gift_id
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
    EventTriggerListener.Get(self.get_btn.gameObject).onClick = basefunc.handler(self, self.OnGetClick)
    EventTriggerListener.Get(self.go_btn.gameObject).onClick = basefunc.handler(self, self.OnGoClick)
    EventTriggerListener.Get(self.unlock_btn.gameObject).onClick = basefunc.handler(self, self.OnUnLockClick)
	self:MyRefresh()
end

function C:MyRefresh()
    self.kill_txt.text = self.config.kill_num_txt
    for i=1,3 do
        self["award" .. i .. "_img"].sprite = GetTexture(self.config.award_img[i])
        self["award" .. i .. "_txt"].text = self.config.award_txt[i]
        self["gou" .. i].gameObject:SetActive(false)
    end
    local data1 = GameTaskModel.GetTaskDataByID(self.config.task_id1)
    local data2 = GameTaskModel.GetTaskDataByID(self.config.task_id2)
    if data1 then
        local b = basefunc.decode_task_award_status(data1.award_get_status)
        b = basefunc.decode_all_task_award_status(b, data1, self.all_count)
        if b[self.config.level] == 1 then
            self.get_btn.gameObject:SetActive(true)
            self.go_btn.gameObject:SetActive(false)
            self.already_img.gameObject:SetActive(false)
            self.unlock_btn.gameObject:SetActive(false)
        elseif b[self.config.level] == 0 then
            self.get_btn.gameObject:SetActive(false)
            self.go_btn.gameObject:SetActive(true)
            self.already_img.gameObject:SetActive(false)
            self.unlock_btn.gameObject:SetActive(false)
        elseif b[self.config.level] == 2 then
            if data2 and M.CheckGiftIsBoughtByTaskID() then
                local c = basefunc.decode_task_award_status(data2.award_get_status)
                c = basefunc.decode_all_task_award_status(c, data2, self.all_count)
                if c[self.config.level] ~= 2 then
                    self.get_btn.gameObject:SetActive(true)
                    self.go_btn.gameObject:SetActive(false)
                    self.already_img.gameObject:SetActive(false)
                    self.unlock_btn.gameObject:SetActive(false)
                    self.gou1.gameObject:SetActive(true)
                else
                    self.get_btn.gameObject:SetActive(false)
                    self.go_btn.gameObject:SetActive(false)
                    self.already_img.gameObject:SetActive(true)
                    self.unlock_btn.gameObject:SetActive(false)
                    self.gou1.gameObject:SetActive(true)
                    self.gou2.gameObject:SetActive(true)
                    self.gou3.gameObject:SetActive(true)
                end
            else
                self.get_btn.gameObject:SetActive(false)
                self.go_btn.gameObject:SetActive(false)
                self.already_img.gameObject:SetActive(false)
                self.unlock_btn.gameObject:SetActive(true)
                self.gou1.gameObject:SetActive(true)
            end
        end
    end
end


function C:OnGetClick()
    local data1 = GameTaskModel.GetTaskDataByID(self.config.task_id1)
    local data2 = GameTaskModel.GetTaskDataByID(self.config.task_id2)
    if data1 then
        local b = basefunc.decode_task_award_status(data1.award_get_status)
        b = basefunc.decode_all_task_award_status(b, data1, self.all_count)
        if b[self.config.level] == 1 then
            Network.SendRequest("get_task_award_new", {id = self.config.task_id1, award_progress_lv = self.config.level})
        end
    end
    if data2 then
        local b = basefunc.decode_task_award_status(data2.award_get_status)
        b = basefunc.decode_all_task_award_status(b, data2, self.all_count)
        if b[self.config.level] == 1 then
            Network.SendRequest("get_task_award_new", {id = self.config.task_id2, award_progress_lv = self.config.level})
        end
    end
end

function C:OnUnLockClick()
    local shopid = self.gift_id
    local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
    dump(MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid))
    if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
        ServiceGzhPrefab.Create({desc="请前往公众号获取"})
    else
        PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
    end
end


function C:OnGoClick()
    GameManager.CommonGotoScence({gotoui = "game_Fishing3DHall"})
end