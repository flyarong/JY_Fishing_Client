-- 创建时间:2020-11-22
-- Panel:FishFarmBZZYPanel
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

FishFarmBZZYPanel = basefunc.class()
local C = FishFarmBZZYPanel
C.name = "FishFarmBZZYPanel"
local M = FishFarmBZZYManager

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
    self.lister["fish_farm_bzzy_infor_msg"] = basefunc.handler(self, self.on_fish_farm_bzzy_infor_msg)
    self.lister["AssetChange"] = basefunc.handler(self, self.InitUI)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:StopTimer()
	self:DeleteItemPre()
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
	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	self.back_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:MyExit()
		end
	)
	
	self.sx_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		    local iss = PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."fish_farm_bzzy_infor_user_key"..os.date("%Y%m%d",os.time()), 0)
		    if iss == 1 then
		        iss = true
		    else
		        iss = false
		    end

			if not iss then
		        local rr = M.GetFreshNeedInfors()
		        local str = string.format("是否花费%s金币，刷新本次宝藏章鱼携带的道具？",rr)
		        local pre = HintPanel.Create(2, str, function (b)
		           Network.SendRequest("fishbowl_shop_info",{fresh = 1,},"",function (data)
			           	if data.result ~= 0 then
			           		LittleTips.Create("当前所需物品不足，不能刷新！")
		           		end
		            end)
		            if b then
		                PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."fish_farm_bzzy_infor_user_key"..os.date("%Y%m%d",os.time()), 1)
		            else
		                PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."fish_farm_bzzy_infor_user_key"..os.date("%Y%m%d",os.time()), 0)
		            end
		        end)
		        pre:ShowGou()
		        --pre:SetButtonText(nil, "立即兑换")
		    else
				Network.SendRequest("fishbowl_shop_info",{fresh = 1,},"请求数据",function (data)
					dump(data)
					if data.result == 0 then
						--1 是请求刷新 0 是自动刷新
						if data.fresh == 1 then
							
						end
					else
						LittleTips.Create("当前所需物品不足，不能刷新！")
					end	
				end)
			end
		end
	)

	self.jb_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
	end)
	self.xx_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		LittleTips.Create("养鱼和售卖鱼苗可获得星星！")
	end)
	self.gz_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		IllustratePanel.Create({self.introduce_txt}, GameObject.Find("Canvas/LayerLv5").transform, "IllustratePanel_New")
	end)
	
end

function C:InitUI()
	Network.SendRequest("fishbowl_shop_info",{fresh = 0,})
	--self:MyRefresh()
end

function C:MyRefresh()
	self.djs = tonumber(M.GetCurBzzyInfor().time)
	self:RefreshUI()
	self:CreateItemPre()
	self:StartTimer()
end


function C:CreateItemPre()
	self:DeleteItemPre()
	local sort_infor = self:GetGiftConfigAndSort()

	for i = 1, #sort_infor do
		local pre = FishFarmBZZYItemPrefab.Create(self.Content.transform, sort_infor[i])
		self.item_pre_list[i] = pre
	end 
end


function C:DeleteItemPre()
	if self.item_pre_list then
		for i,v in ipairs(self.item_pre_list) do
			v:MyExit()
		end
	end
	self.item_pre_list = {}
end


function C:RefreshUI()
	local xx = GameItemModel.GetItemCount("prop_fishbowl_stars")
	self.jb_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	self.xx_txt.text = StringHelper.ToCash(xx)
end
function C:on_fish_farm_bzzy_infor_msg()
	self:MyRefresh()
	dump(M.GetGiftInforByConfig(),"<color=red>數據數據數據數據</color>")
end


function C:GetGiftConfigAndSort()
    local list = M.GetGiftInforByConfig()
    return list
end


function C:StartTimer()
	local function Djs()
		if self.djs >= os.time() then
			self.djs_txt.text = StringHelper.formatTimeDHMS4(self.djs - os.time())
		else
			self.djs_txt.text = ""
			--Network.SendRequest("fishbowl_shop_info",{fresh = 0,})
			self:StopTimer()
		end
	end
	Djs()
	self:StopTimer()
	self.main_time = Timer.New(function ()
		Djs()
 	end,1,-1) 
	self.main_time:Start()
end

function C:StopTimer()
	if self.main_time then
		self.main_time:Stop()
		self.main_time = nil
	end
end