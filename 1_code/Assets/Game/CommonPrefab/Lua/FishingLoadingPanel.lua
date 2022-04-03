-- 创建时间:2019-03-19
-- Panel:FishingLoadingPanel
local basefunc = require "Game/Common/basefunc"

FishingLoadingPanel = basefunc.class()
local C = FishingLoadingPanel
C.name = "FishingLoadingPanel"

C.LoadingState = 
{
	LS_Res = "加载资源",
	LS_Ready = "发送准备",
	LS_Recover = "恢复场景",
	LS_Finish = "加载完成",
}

function C.Create(call, load_type)
	return C.New(call, load_type)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_recover_finish"] = basefunc.handler(self, self.model_recover_finish)
    self.lister["ExitScene"] = basefunc.handler(self, self.onExitScene)
end

function C:onExitScene()
	self:MyExit()
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
	destroy(self.gameObject)
end

function C:ctor(call, load_type)
	self.load_type = load_type
	local prefab_name = "FishingLoadingPanel"
	if self.load_type and (self.load_type == "by3d" or self.load_type == "by3d1") then
		prefab_name = "Fishing3DLoadingPanel"
	elseif self.load_type and self.load_type == "by3d2" then
		prefab_name = "Fishing3DLoadingPanel_1"
	elseif self.load_type and self.load_type == "by3d3" then
		prefab_name = "Fishing3DLoadingPanel_2"
	elseif self.load_type and self.load_type == "by3d4" then
		prefab_name = "Fishing3DLoadingPanel_3"
	elseif self.load_type and self.load_type == "by3d5" then
		prefab_name = "Fishing3DLoadingPanel_4"
	end

	local parent = GameObject.Find("Canvas/LayerLv1").transform
	local obj = newObject(prefab_name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.call = call

	if self.load_type then
		if self.load_type == "by3d" or self.load_type == "by3d1" then

		elseif self.load_type == "by3d2" or self.load_type == "by3d3" or self.load_type == "by3d4" or self.load_type == "by3d5" then
			self.by_bg = tran:Find("UINode/com_jz_prefab/BG"):GetComponent("Image")
		end
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

	FishingModel.ReloadFishCacheConfig()
	self.allLoadCount = #FishingModel.Config.fish_cache_list
	print("self.allLoadCount:" .. self.allLoadCount)

	if self.load_type and self.load_type == "by3d" then
		-- 分场景加载鱼资源
		self.fish_map = GameFishing3DManager.GetAllFishByGameID(FishingModel.game_id)
	end
	self.timerUpdate = Timer.New(function ()
		self:Update()
	end, -1, -1, true)
	self.timerUpdate:Start()
	
	-- local f_node = self.RateNode:Find("Image")
	-- local r_f = math.random(1,23)
	-- if r_f == 20 then r_f = 1 end
	-- local name = "Fish0"
	-- if r_f <10 then name = name .. "0"end
	-- name = name .. r_f
	-- newObject(name,f_node)
end

function C:LoadAssetAsync()
	local is_fish = function (s)
		if string.len(s) == 9 and string.sub(s, 1, 6) == "Fish3D" then
			return true
		end
	end
    -- 加载
    for k,v in ipairs(FishingModel.Config.fish_cache_list) do
    	
    	if not self.fish_map or not is_fish(v.prefab) or self.fish_map[v.prefab] then
	        CachePrefabManager.InitCachePrefab(v.prefab, v.cache_count, true)
	    end
        Yield(0)
        self.currLoadCount = self.currLoadCount + 1
    end
end

function C:Update()
	if self.load_state == C.LoadingState.LS_Res then
		coroutine.start(function ( )
			self:LoadAssetAsync()
		end)
		self.load_state = C.LoadingState.LS_Res_Loading
	elseif self.load_state == C.LoadingState.LS_Res_Loading then
		if not self.allLoadCount or self.allLoadCount <= 0 then
			self.load_state = C.LoadingState.LS_Ready
			return
		end
		self.rate_val = self.currLoadCount / self.allLoadCount * 0.9
		self:UpdateRate(self.rate_val)
		if self.rate_val >= 0.899999 then
			self.load_state = C.LoadingState.LS_Ready
		end
	elseif self.load_state == C.LoadingState.LS_Ready then
	    self.load_state = C.LoadingState.LS_Recover
		coroutine.start(function ( )
			Yield(0)
			FishingModel.IsLoadRes = false
			FishingModel.SendAllInfo()
		end)
	elseif self.load_state == C.LoadingState.LS_Recover then

	else
		Event.Brocast("loding_finish")
		self:MyExit()
	end
end

function C:model_recover_finish()
	self.load_state = C.LoadingState.LS_Finish
end

function C:UpdateRate(val)
	self.Rate.fillAmount = val
	self.RateText.text = string.format("%.2f", val * 100) .. "%"

	self.RateNode.localPosition = Vector3.New(-self.width/2 + self.width * val, 0, 0)
end
