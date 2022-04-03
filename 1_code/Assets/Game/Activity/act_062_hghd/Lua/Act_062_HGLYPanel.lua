-- 创建时间:2021-10-11
-- Panel:Act_062_HGLYPanel
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

Act_062_HGLYPanel = basefunc.class()
local C = Act_062_HGLYPanel
C.name = "Act_062_HGLYPanel"
local M = Act_062_HGHDManager

function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
    self.lister["finish_gift_shop"] = basefunc.handler(self,self.on_finish_gift_shop)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    self:CloseItem()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
    self.slider = self.Slider.transform:GetComponent("Slider")

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
    EventTriggerListener.Get(self.buy_btn.gameObject).onClick = basefunc.handler(self, self.OnBuyClick)
	self:MyRefresh()
end


local high = {0.09,0.22,0.35,0.48,0.61,0.74,0.87,1}
function C:MyRefresh()
    if M.CheckGiftIsBoughtByTaskID() then
        self.buy_btn.gameObject:SetActive(false)
    else
        self.buy_btn.gameObject:SetActive(true)
    end
    local data = GameTaskModel.GetTaskDataByID(M.ly_config[1].task_id1)
    if data then
        self.kill_txt.text = "捕鱼数:" .. data.now_total_process
        for i=1,#M.ly_config do
            if data.now_total_process <= M.ly_config[i].kill_num then
                if i >= 2 then
                    self.slider.value = high[i - 1] + (data.now_total_process - M.ly_config[i - 1].kill_num) / (M.ly_config[i].kill_num - M.ly_config[i - 1].kill_num) * (high[i] - high[i - 1])
                else
                    self.slider.value = data.now_total_process / M.ly_config[i].kill_num * high[i]
                end
                break
            end
        end
    end
    self:CreateItem()
end

function C:CreateItem()
    self:CloseItem()
    for i=1,#M.ly_config do
        local pre = Act_062_HGLYItemBase.Create(self.Content.transform, M.ly_config[i], #M.ly_config, M.ly_gift_id)
        self.pre_cell[#self.pre_cell + 1] = pre
    end
end

function C:CloseItem()
    if self.pre_cell then
        for k,v in pairs(self.pre_cell) do
            v:MyExit()
        end
    end
    self.pre_cell = {}
end

function C:on_model_task_change_msg(data)
    for k,v in pairs(M.ly_config) do
        if v.task_id1 == data.id or v.task_id2 == data.id or data.id == M.buy_task_id then
            Event.Brocast("global_hint_state_change_msg", { gotoui = M.key , goto_scene_parm = "hgly_panel" })
            self:MyRefresh()
        end
    end
end

function C:on_finish_gift_shop(id)
    if id == M.ly_gift_id then
        LittleTips.Create("购买成功~")
        self:MyRefresh()
    end
end

function C:OnBuyClick()
    local shopid = M.ly_gift_id
    local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
    dump(MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid))
    if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
        ServiceGzhPrefab.Create({desc="请前往公众号获取"})
    else
        PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
    end
end