-- 创建时间:2020-04-15
-- Panel:ByBagPanel
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

ByBagPanel = basefunc.class()
local C = ByBagPanel
C.name = "ByBagPanel"

local panelNameMap = {
	tool = "tool",
	paotai = "paotai",
    touxiangkuang = "touxiangkuang",
}

function C.Create(parm)
	return C.New(parm)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["UpdateHallBagRedHint"] = basefunc.handler(self,self.RefreshRed)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:RefreshAssets()

end

function C:MyExit()
    if self.cur_panel then
        self.cur_panel.instance:MyExit()
        self.cur_panel = nil
    end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parm)
    PlayerPrefs.SetString(MainModel.RecentlyOpenBagTime, os.time())
    Event.Brocast("UpdateHallBagRedHint")

	self.parm = parm
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
    local channel_type = gameMgr:getMarketPlatform()
    if channel_type == "cjj" then
        self.tag.gameObject:SetActive(false)
    end

	self.back_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:MyExit()
    end)
	self.dj_on_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnDJClick()
    end)
	self.pt_on_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnPTClick()
    end)
    self.txk_on_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnTXKClick()
    end)

    self:MyRefresh()
end

function C:MyRefresh()
    if self.parm then
        if self.parm.type then -- self.parm.type ==> panelNameMap
            self:ChangePanel(self.parm.type, self.parm)
        else
            self:ChangePanel(panelNameMap.tool, self.parm)
        end
    else
        if self.cur_panel then
            self.cur_panel.instance:MyRefresh()
        end
    end
	self.parm = nil
    self:RefreshRed()
end

function C:RefreshRed()
    self.pt_red.gameObject:SetActive(false)
    if SYSByBagManager.IsHaveRad(1) or SYSByBagManager.IsHaveRad(2) then
        self.pt_red.gameObject:SetActive(true)
    end
    self.txk_red.gameObject:SetActive(SYSByBagManager.IsHaveRad(3))
    if MainModel.myLocation == "game_Fishing3D" then
        self.item_red.gameObject:SetActive(GameItemModel.IsBagRadByTag(8))
    else
        local redState=GameItemModel.IsBagRadByTag(1)
        self.item_red.gameObject:SetActive(redState)
    end
end

function C:ChangePanel(panelName, parm)
	if self.cur_panel then
        if self.cur_panel.name == panelName then
            if  self.cur_panel.instance.MyRefresh then
                self.cur_panel.instance:MyRefresh(parm)
            end 
        else
            self.cur_panel.instance:MyExit()
            self.cur_panel = nil
        end
    end

	self.dj_xz_obj.gameObject:SetActive(false)
	self.pt_xz_obj.gameObject:SetActive(false)
    self.txk_xz_obj.gameObject:SetActive(false)
    if not self.cur_panel then
    	if panelName == panelNameMap.tool then
    		self.dj_xz_obj.gameObject:SetActive(true)
            self.cur_panel = {name = panelName, instance = ByToolBagPanel.Create(self.RightRect, parm,self)}
    	elseif panelName == panelNameMap.paotai then
    		self.pt_xz_obj.gameObject:SetActive(true)
    		self.cur_panel = {name = panelName, instance = ByPaotaiBagPanel.Create(self.RightRect, parm,self)}
    	elseif panelName == panelNameMap.touxiangkaung then
            self.txk_xz_obj.gameObject:SetActive(true)
            self.cur_panel = {name = panelName, instance = ByTouXiangKuangBagPanel.Create(self.RightRect, parm,self)}
        end
    end
end


-- 道具
function C:OnDJClick(go)
    self:ChangePanel(panelNameMap.tool)
end

-- 炮台
function C:OnPTClick(go)
    self:ChangePanel(panelNameMap.paotai)
end

-- 头像框
function C:OnTXKClick(go)
    self:ChangePanel(panelNameMap.touxiangkaung)
end
