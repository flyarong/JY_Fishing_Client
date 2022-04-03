-- 创建时间:2020-03-23
-- Panel:ZJFDdzPrefab
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

ZJFDdzPrefab = basefunc.class()
local C = ZJFDdzPrefab
C.name = "ZJFDdzPrefab"
local df_tb = {}
local jrtj_tb = {}
local fz_pay = 200
local aa_pay = 50

local xishu = 0.01


local types = {
	"nor_ddz_nor",
	"nor_ddz_lz",
	"nor_ddz_er",
	"nor_ddz_boom",				
}

function C.Create(parent,type_index)
	return C.New(parent,type_index)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
	self.lister["zijianfang_create_room_response"] = basefunc.handler(self,self.on_zijianfang_create_room_response)
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

function C:ctor(parent,type_index)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.type_index = type_index
	LuaHelper.GeneratingVar(self.transform, self)
	self:InitDf_tb()
	self:InitJRTJ_tb()
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.df_slider = self.dfSlider:GetComponent("Slider")
	self.jrtj_slider = self.jrtjSlider:GetComponent("Slider")
	self:RefreshText()
	self.df_slider.onValueChanged:AddListener(
		function (val)
			self:RefreshText()
		end
	)
	self.jrtj_slider.onValueChanged:AddListener(
		function (val)
			self:RefreshText()
		end
	)
	self.fwq1_tge.onValueChanged:AddListener(
		function (val)	
			self:RefreshText()
		end
	)
	self.fwq2_tge.onValueChanged:AddListener(
		function (val)
			self:RefreshText()
		end
	)
end

function C:InitUI()
	self.create_btn.onClick:AddListener(
		function ()
			if MainModel.UserInfo.jing_bi >= self:GetJRTJText() then 
				Network.SendRequest("zijianfang_create_room",
					{
						game_type= types[self.type_index],
						game_cfg={
							{option="enter_limit",value =  self:GetEnterLimitRate(),},
							{option="init_stake",value = self:GetDiFen(),},
							{option=self:GetBs(),value = 1,},
							{option=self:GetFuWModel(),value = 1},
							{option="yingfengding",value = self:GetIsYFD()},
						},
						password = self:GetIsOpenModel()
					}, "")
			else
				Event.Brocast("show_gift_panel")
			end 
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:on_zijianfang_create_room_response(_,data)
	dump(data,"<color=red>创建房间的返回</color>")
	if data.result == 0 then
		GameManager.GotoSceneName("game_DdzZJF" , false)
	else
		HintPanel.ErrorMsg(data.result)
	end
end

function C:InitDf_tb()
	for i = 1 , 100 do 
		df_tb[i] = i
	end
end

function C:InitJRTJ_tb()
	jrtj_tb[1] = 0
	jrtj_tb[2] = 2
	jrtj_tb[3] = 5
	for i = 1, 20 do 
		jrtj_tb[i+3] = 10 * i
	end
end
-- 底分 * 倍数
function C:GetEnterLimit()
	return jrtj_tb[self.jrtj_slider.value + 1] * self:GetDiFen()
end

-- 进入条件 倍数
function C:GetEnterLimitRate()
	return jrtj_tb[self.jrtj_slider.value + 1] 
end

function C:GetDiFen()
	return df_tb[self.df_slider.value + 1] * 1000
end
--房间类型 1:有密码 0:没有密码
function C:GetIsOpenModel()
	if self.fjlx1_tge.isOn == true then 
		return 0
	else
		return 1
	end
end
-- 服务费模式 1:房主付费 0：平摊付费
function C:GetFuWModel()
	if self.fwq1_tge.isOn == true then 
		return "fangzhu_pay"
	else
		return "aa_pay"
	end
end
--倍数
function C:GetBs()
	local beishu = {"feng_ding_32b","feng_ding_64b","feng_ding_128b","feng_ding_256b"}
	for i = 1,4 do 
		if self["bs"..i.."_tge"].isOn == true then 
			return beishu[i]
		end 
	end
end
-- 总的进入条件
function C:GetJRTJText()
	--AA制基础房费
	local base = aa_pay + 10000
	-- 房主付款 基础房费
	if self:GetFuWModel() == "fangzhu_pay" then 
		base = 10000
	end

	return self:GetEnterLimit() + base
end
-- 赢封顶
function C:GetIsYFD()
	if self.tx_tge.isOn == true then 
		return 1
	else
		return 0
	end
end

function C:RefreshText()
	self.df_txt.text = StringHelper.ToCash(self:GetDiFen()).."金币"
	self.jrtj_txt.text = StringHelper.ToCash(self:GetJRTJText()).."金币"
	self.fzb_txt.text = "房主包（<color=#F87935FF>"..StringHelper.ToCash(self:GetDiFen() * xishu * 3).."金币</color>".."/局）"
	self.aa_txt.text = "AA制（<color=#F87935FF>"..StringHelper.ToCash(self:GetDiFen() * xishu).."金币</color>".."/局/人）"
end

