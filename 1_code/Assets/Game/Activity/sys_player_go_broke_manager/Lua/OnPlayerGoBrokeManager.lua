-- 创建时间:2019-11-05
-- Panel:OnPlayerGoBrokeManager
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
OnPlayerGoBrokeManager = basefunc.class()
local C = OnPlayerGoBrokeManager
C.name = "OnPlayerGoBrokeManager"
local this
local lister

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
    lister["show_gift_panel_once_in1day"] = this.show_gift_panel_once_in1day
    lister["show_gift_panel"] = this.ShowGiftPanel
end

function C.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

function C.Init()
	C.Exit()
	this = OnPlayerGoBrokeManager
	MakeLister()
    AddLister()
end

function C.OnBroke(parm)
	C.ShowGift(nil,parm)
end

function C.ShowGiftPanel(parm)
	C.OnBroke(parm)
end

function C.show_gift_panel_once_in1day()
	C.OnBackToHall()
end

function C.OnBackToHall(parm)
	print("<color=red>退返回大厅-------------------------</color>")
	if PlayerPrefs.GetInt("OnBackToHall"..MainModel.UserInfo.user_id..os.date("%Y%m%d", os.time()),0) ~= 1 then	
		C.ShowGift(function ()
			PlayerPrefs.SetInt("OnBackToHall"..MainModel.UserInfo.user_id..os.date("%Y%m%d", os.time()),1)
		end)	
	end   
end

function C.ShowGift(backcall,parm)
	local pay_cb = (parm and parm.pay_cb) and parm.pay_cb or nil
	if GuideLogic.IsHaveGuide() and MainModel.myLocation == "game_Free" then return end 
	local open_paypanel = backcall or  function ()
		if os.time() > 1585611000 and os.time() < 1586188799   then 
			GameButtonManager.RunFun({gotoui="act_fxlx",backcall = function ( )
				PayPanel.Create(GOODS_TYPE.jing_bi, "pc",pay_cb)
			end ,}, "ShowPanel")
		else
			PayPanel.Create(GOODS_TYPE.jing_bi, "pc",pay_cb)	
		end 
	end
	if MainModel.UserInfo.ui_config_id == 2 then
		if SYSSCLBManager and SYSSCLBManager.GetCurrentShopID() and (not parm or not parm.isduring_xsth) then
			GameButtonManager.GotoUI({gotoui="sys_sclb",backcall=open_paypanel,goto_scene_parm = "panel"} )
		else
			open_paypanel()
		end 
	elseif  MainModel.UserInfo.ui_config_id == 1 then   --老玩家
		local data = MainModel.GetConventionalGift()
		local can_buy = false
		if data then 
			for i=1,#data do
				if data[i].state == 1 then 
					can_buy =true
				end  
			end
		end 
		if can_buy and (not parm or not parm.isduring_xsth) then
			local a,b = GameButtonManager.RunFun({gotoui="ty_gift", gift_key = "gift_kllb"}, "get_giftkey_by_cfg")
			if a and b then
				GameManager.GotoUI({gotoui="ty_gift", goto_scene_parm = "gift_kllb", backcall=open_paypanel})
			else
				GameManager.GotoUI({gotoui="ty_gift", goto_scene_parm = "gift_cglb", backcall=open_paypanel})
			end 
		else
			open_paypanel()
		end 
	end 
end