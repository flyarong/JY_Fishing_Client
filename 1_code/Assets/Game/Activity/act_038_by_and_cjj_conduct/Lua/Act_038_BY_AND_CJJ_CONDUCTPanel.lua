-- 创建时间:2020-11-23
-- Panel:Act_038_BY_AND_CJJ_CONDUCTPanel
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

Act_038_BY_AND_CJJ_CONDUCTPanel = basefunc.class()
local C = Act_038_BY_AND_CJJ_CONDUCTPanel
C.name = "Act_038_BY_AND_CJJ_CONDUCTPanel"
local M = Act_038_BY_AND_CJJ_CONDUCTManager
function C.Create(name)
	return C.New(name)
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

function C:ctor(name)
	self.name = name
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.per = M.CheckPermission(self.name)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
	EventTriggerListener.Get(self.download_by_btn.gameObject).onClick = basefunc.handler(self, self.OnDownLoadClick)
	EventTriggerListener.Get(self.download_cjj_btn.gameObject).onClick = basefunc.handler(self, self.OnDownLoadClick)
	self:MyRefresh()
end

function C:MyRefresh()
	if self.per == "normal" then
		--self.bg_img.sprite = GetTexture("yxhd_by_bg")
		--self.download_by_btn.gameObject:SetActive(true)
		--self.download_cjj_btn.gameObject:SetActive(false)
		--2021.11.16版本运营需求(游戏小优化需求)
		self.bg_img.sprite = GetTexture("xyhd_cjj_bg")
		self.download_by_btn.gameObject:SetActive(false)
		self.download_cjj_btn.gameObject:SetActive(true)
	elseif self.per == "cjj" then
		self.bg_img.sprite = GetTexture("xyhd_cjj_bg")
		self.download_by_btn.gameObject:SetActive(false)
		self.download_cjj_btn.gameObject:SetActive(true)
	end
	self.bg_img:SetNativeSize()
end

function C:OnBackClick()
	self:MyExit()
end

function C:OnDownLoadClick()
	local url
	if self.per == "normal" then
		--未下载cjj
		--url = "http://cwww.game3396.com/webpages/hlbyDownload.html?platform=cjj&market_channel=cjj&pageType=cjj&category=1"
		--2021.11.16版本运营需求(游戏小优化需求)
		url = "http://cwww.game3396.com/webpages/hlbyDownload.html?platform=normal&market_channel=normal&pageType=normal&category=1"
	elseif self.per == "cjj" then
		--未下载捕鱼
		url = "http://cwww.game3396.com/webpages/hlbyDownload.html?platform=normal&market_channel=normal&pageType=normal&category=1"
	end
	UnityEngine.Application.OpenURL(url)
end