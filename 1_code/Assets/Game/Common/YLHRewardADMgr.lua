YLHRewardADMgr = {}
local M = YLHRewardADMgr

local config = require "Game.Common.ylhad_config"

local lister
local this

local mask_obj 
local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg,cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister=nil
end
local function MakeLister()
    lister = {}
    lister["AssetsGetPanelClose"] = this.CloseBannerAd  --关闭banner
    lister["ylh_ad_create_msg"] = this.CreateAdInScene

end


function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end


--激励视频加载 and 播放激励视频
function M.OnRewarded(coid_id, msg)
	dump({coid_id,msg})
	--加载成功
	if msg == "OnAdLoaded" then
		local d = sdkMgr:YLH_GetExpireTimestamp()
		--播放
		sdkMgr:YLH_ShowRewardVideoAd(callback)
	elseif msg == "OnRewarded" then
		if coid_id == config.RewardVideoAd.mfcj.coid_id then
			Network.SendRequest("fsg_3d_use_free_lottery", nil, "")
		elseif coid_id == config.RewardVideoAd.ggy.coid_id then
			Network.SendRequest("fsg_3d_use_ad_fish", nil, "")
		else
			if coid_id == config.RewardVideoAd.jjj.coid_id then
	        	Network.SendRequest("broke_subsidy", nil, "请求数据", function (data)
		        	if data.result == 0 then
				        MainModel.UserInfo.shareCount = MainModel.UserInfo.shareCount - 1
						Event.Brocast("global_hint_state_change_msg", { gotoui = "sys_jjj" })
		        	else
		        		HintPanel.ErrorMsg(data.result)
		        	end
	       		end)
       		end
		end
	else
		if string.sub(msg,1,7) == "OnError" then
			HintPanel.ErrorMsg("广告观看失败,请重新观看!")
			dump(msg,"<color=red>激励视频错误信息</color>")
		end
	end
end

---插屏广告奖励 and 领取奖励
function M.OnIntersititial(coid_id, msg)
	dump(msg)
	if msg == "OnAdLoaded" then
		sdkMgr:YLH_ShowNoVideoAd(callback)
		dump("广告加载成功！！！！！！！！！！")
	else
	end
	
	if mask_obj then
		destroy(mask_obj.gameObject)
		mask_obj = nil
	end
end

--banner广告奖励
function M.OnBanner(coid_id, msg)
	if msg == "OnAdLoaded" then
		dump({_cond_id=_cond_id, msg=msg}, "<color=red>|||OnAdLoaded</color>")	
	else
	end
end

-- 限制 播放频率P X秒最多播Y次
function M.YLHAdLimit(key)
   --CD
    local ad_cd = config[key].ad_cd
   	--次数
    local limit_num = config[key].all_time_limit_num
    --时间范围
    local all_time = config[key].all_time
	M.data[key] = M.data[key] or {}

	local now_time = os.time()
	local cur_num = 0
	for time,_ in pairs(M.data[key]) do
		if time < now_time - all_time then
			table.remove(M.data[key],time)
		end
	end
	for time,_ in pairs(M.data[key]) do
		if time >= now_time-ad_cd then
			return true
		end
		if time >= now_time-all_time then
			cur_num = cur_num + 1
		end
	end
	
	if cur_num > limit_num then
		return true
	end
	
	return false
end

function M.YLHAdQX()
	local _permission_key = "banner_ggxt"
	if _permission_key then
		local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = _permission_key, is_on_hint = true}, "CheckCondition")
		if a and b then
			return true
		else
			return false
		end
	end
	return true
end
---banner广告
function M.YHLBannerAd(coid_id, callback)

	--if M.YLHAdLimit("banner") then return end
	-- if not M.YLHAdQX() then return end
	print("<color=white>[AD] BANNER_AD</color>")
	reward_tbl = {}
	reward_tbl.coid_id = config.banner.coid_id --coid_id
	reward_tbl.x = config.banner.x
	reward_tbl.y = config.banner.y
	reward_tbl.autoSwitchInterval = config.banner.autoSwitchInterval

	--M.data.banner[os.time()] = true
	--sdkMgr:YLH_LoadAndShowBanner(lua2json(reward_tbl), M.OnBanner)
	sdkMgr:YLH_LoadAndShowBanner(lua2json(reward_tbl),M.OnBanner)
end


function M.CloseBannerAd()
	print("<color=white>[AD] 退出_Banner_AD</color>")
	sdkMgr:YLH_CloseBannerAdView()
end
--插屏广告
function M.YLHLoadVideoAd(coid_id, callback)
	-- 限制 播放频率P X秒最多播Y次
	--if M.YLHAdLimit("Intersititial") then return end
	if not M.YLHAdQX() then return end
	print("<color=white>[AD] 插屏_插屏_AD</color>")
	reward_tbl = {}
	reward_tbl.coid_id = config.Intersititial.coid_id--coid_id
	reward_tbl.isVideoMuted = config.Intersititial.isVideoMuted
	reward_tbl.isDetailVideoMuted = config.Intersititial.isDetailVideoMuted
	reward_tbl.minV = config.Intersititial.minV
	reward_tbl.maxV = config.Intersititial.maxV
	--M.data.Intersititial[os.time()] = true
	--创建遮罩
	if not AppDefine.IsEDITOR() then
		local self = {}
		local parent = GameObject.Find("Canvas/LayerLv50").transform
		mask_obj = newObject("YLHADMaskPrefab", parent)
		LuaHelper.GeneratingVar(mask_obj.gameObject.transform, self)
		-- self.ts_btn.onClick:AddListener(function ()
		-- 	LittleTips.Create("广告正在填充中！")
		-- end)
	end
	sdkMgr:YLH_LoadNoVideoAd(lua2json(reward_tbl), M.OnIntersititial)

end

--加载激励视频  广告点在调用处添加的
function M.YLHLoadRewardVideoAd(_type, callback)
	print("<color=white>[AD] YLHLoadRewardVideoAd</color>")
	reward_tbl = {}
	reward_tbl.coid_id = config.RewardVideoAd[_type].coid_id
	reward_tbl.volumeOn = true
	sdkMgr:YLH_LoadRewardVideoAd(lua2json(reward_tbl), M.OnRewarded)
end

--播放激励视频
function M.YLHShowRewardVideoAd(callback)
	sdkMgr:YLH_ShowRewardVideoAd(lua2json(reward_tbl), callback)
end

function M.YLHInit(app_id)
	local platform = gameMgr:getMarketPlatform()
	if gameRuntimePlatform ~= "Android" or platform ~= "normal" or AppDefine.IsEDITOR() then
		return
	end
	M.data = {}
	M.Exit()
	this = YLHRewardADMgr
	MakeLister()
    AddLister()
	local is_showAd = sdkMgr:YLH_InitAD(app_id)
	if not is_showAd then
		dump("初始化广告SDK失败！！！！！！")
		return
	end
	dump("初始化广告SDK成功！！！！！！")
end

function M.CreateAdInScene(data)
	-- body
	local mini_game_scene = {"game_Eliminate","game_LWZBHall","game_LWZB","game_EliminateXY",
		"game_EliminateSH","game_EliminateCS","game_TTL","game_ZPG","game_FishingDR","game_Zjd","game_Fishing3D","game_EliminateSG"}
	dump(data,"<color=red>|||||</color>")
	coroutine.start(
	function()
		Yield(5)
			if data._type == "chaping" then
				for k,v in pairs(mini_game_scene) do
					if MainModel.lastmyLocation == v then
						YLHRewardADMgr.YLHLoadVideoAd()
						break
					end
				end
			elseif data._type == "banner" then
				YLHRewardADMgr.YHLBannerAd()
			end
	end)
end

--初始化广告
M.YLHInit("1111512039")
