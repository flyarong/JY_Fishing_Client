-- 创建时间:2020-03-26
-- Panel:DdzZJFRuleChangeNoticePrefab
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

DdzZJFRuleChangeNoticePrefab = basefunc.class()
local C = DdzZJFRuleChangeNoticePrefab
C.name = "DdzZJFRuleChangeNoticePrefab"
local xishu  = 0.01

function C.Create(data,yes_callback,no_callback)
	return C.New(data,yes_callback,no_callback)
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
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(data,yes_callback,no_callback)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.data = data
	self.yes_callback = yes_callback
	self.no_callback = no_callback
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self.old_df_txt.text = DdzFKModel.get_ori_game_cfg_byOption("init_stake")
	self.new_df_txt.text = self.data.diff_cfg.init_stake

	self.old_bs_txt.text = DdzFKModel.GetCurrBeiShu()
	self.new_bs_txt.text = self.data.diff_cfg.feng_ding  

	self.old_jrtj_txt.text =(DdzFKModel.get_ori_game_cfg_byOption("enter_limit") + xishu) * DdzFKModel.get_ori_game_cfg_byOption("init_stake") + 10000
	self.new_jrtj_txt.text = (self.data.diff_cfg.enter_limit + xishu) * self.data.diff_cfg.init_stake + 10000

	self.fwf_txt.text = self.data.diff_cfg.fangzhu_pay == 1 and "服务费为房主包("..self.data.diff_cfg.init_stake* 3 * xishu ..")金币" or "服务费为AA制（每位玩家每局服务费"..self.data.diff_cfg.init_stake * xishu .."金币"

	self.yfd_txt.text = self.data.diff_cfg.yingfengding == 1 and "赢封顶" or " "


	self.no_btn.onClick:AddListener(
		function ()
			if self.no_callback then 
				self.no_callback()
			end
			self:MyExit()
		end
	)
	self.yes_btn.onClick:AddListener(
		function ()
			if MainModel.UserInfo.jing_bi >= (self.data.diff_cfg.enter_limit + xishu) * self.data.diff_cfg.init_stake + 10000 then 
				if self.yes_callback then 
					self.yes_callback()
				end
			else
				Event.Brocast("show_gift_panel")
			end 
			self:MyExit()
		end
	)
	self:MyRefresh() 
end

function C:MyRefresh()

end
