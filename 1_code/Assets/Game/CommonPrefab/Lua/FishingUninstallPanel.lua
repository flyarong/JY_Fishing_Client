-- 创建时间:2019-03-19
-- Panel:FishingUninstallPanel
local basefunc = require "Game/Common/basefunc"

FishingUninstallPanel = basefunc.class()
local C = FishingUninstallPanel
C.name = "FishingUninstallPanel"

C.LoadingState = 
{
	LS_Res = "加载资源",
	LS_Ready = "发送准备",
	LS_Recover = "恢复场景",
	LS_Finish = "加载完成",
}

local instance
function C.Create(call, load_type)
	return C.New(call, load_type)
end
function C.Close()
	if instance then
		instance:MyExit()
	end
	instance = nil
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.timerUpdate then
		self.timerUpdate:Stop()
		self.timerUpdate = nil
	end
	if self.call then
		if type(self.call) == "function" then
			self.call()
			self.call = nil
		end
	end
	self:RemoveListener()
	-- GameObject.Destroy(self.transform.gameObject)
end

function C:ctor(call, load_type)
ExtPanel.ExtMsg(self)
	self.dot_del_obj = true
	local prefab_name = "FishingLoadingPanel"
	if load_type and load_type == "by3d" then
		prefab_name = "Fishing3DLoadingPanel"
	end
	local parent = GameObject.Find("Canvas/LayerLv1").transform
	local obj = newObject(prefab_name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.call = call

	if load_type and load_type == "by3d" then
		self.by_bg = nil  --更改加载页面无背景图
	else
		self.by_bg = tran:Find("UINode/BGImage"):GetComponent("Image")
	end
	self.RateText = tran:Find("UINode/RateText"):GetComponent("Text")
	self.Rate = tran:Find("UINode/Rate"):GetComponent("Image")
	self.RateNode = tran:Find("UINode/Rate/RateNode")
	self.width = 1000
	self.load_state = C.LoadingState.LS_Res
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	if self.by_bg then
		MainModel.SetGameBGScale(self.by_bg)
	end

	self.Rate.fillAmount = 0
	self.RateText.text = "0%"
	self.RateNode.localPosition = Vector3.New(-self.width/2, 0, 0)

	self.rate_val = 0
	self.currLoadCount = 0
	self.timerUpdate = Timer.New(function ()
		self:Update()
	end, -1, -1, true)
	self.timerUpdate:Start()
end

function C:UninstallAssetAsync()
	-- 卸载
	local map = CachePrefabManager.GetCacheMap()
	local list = {}
	for k,v in pairs(map) do
		list[#list + 1] = v
	end
	self.allLoadCount = #list

	for k,v in ipairs(list) do
		CachePrefabManager.DelCachePrefab(v)
		Yield(0)
        self.currLoadCount = self.currLoadCount + 1
	end
end

function C:Update()
	if self.load_state == C.LoadingState.LS_Res then
		FishingModel.IsLoadRes = true
		coroutine.start(function ( )
			self:UninstallAssetAsync()
		end)
		self.load_state = C.LoadingState.LS_Res_Loading
	elseif self.load_state == C.LoadingState.LS_Res_Loading then
		self.rate_val = self.currLoadCount / self.allLoadCount
		self:UpdateRate(self.rate_val)
		if self.rate_val >= 1 then
			self.load_state = C.LoadingState.LS_Ready
		end
	else
		FishingModel.IsLoadRes = false
		self:MyExit()
	end
end

function C:UpdateRate(val)
	if IsEquals(self.Rate) then
		self.Rate.fillAmount = val
	end

	if IsEquals(self.RateText) then
		self.RateText.text = string.format("%.2f", val * 100) .. "%"
	end

	if IsEquals(self.RateNode) then
		self.RateNode.localPosition = Vector3.New(-self.width/2 + self.width * val, 0, 0)
	end
end
