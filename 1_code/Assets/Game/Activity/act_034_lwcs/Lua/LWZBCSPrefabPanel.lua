-- 创建时间:2020-11-03
-- Panel:LWZBCSPrefabPanel
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

LWZBCSPrefabPanel = basefunc.class()
local C = LWZBCSPrefabPanel
C.name = "LWZBCSPrefabPanel"

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
    self.lister["lwzb_query_qlcf_info_response"] = basefunc.handler(self, self.on_lwzb_query_qlcf_info_response)
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

function C:ctor(parent)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject("LWZBCSPrefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	local Rect_x = self.transform.localPosition.x
	local Rect_y = self.transform.localPosition.y
	self.gameObject.transform.localPosition = Vector3.New(Rect_x, (Rect_y-57), 0)
	self:MyRefresh()
end

function C:MyRefresh()
	self:ShowCSDJUIInMiniGame()
end

function C:ShowCSDJUIInMiniGame()
	self:StopSendTime()
       --self.csdj_node.gameObject:SetActive(true)
       if MainModel.myLocation == "game_MiniGame"then
       		self:SendCSDJData()
        	send_time = Timer.New(function ()
	            	self:SendCSDJData()
	        	end, 10, -1, nil, true)
	        	send_time:Start()	
   		end
end

function C:StopSendTime()
    if send_time then
        send_time:Stop()
        send_time = nil
    end
end


function C:SendCSDJData()
	Network.SendRequest("lwzb_query_qlcf_info",{game_id = 2})
end

function C:on_lwzb_query_qlcf_info_response(_,data)
	dump(data,"<color=red>on_lwzb_query_qlcf_info_response</color>")
	if data.result == 0 then
		self.award_pool = data.value 
		if not self.cur_num then
			self.cur_num = math.floor(tonumber(self.award_pool)* 0.4)
		end
		self:RunChange()
	end	
end

function C:RunChange()
	if self.is_animing then
		return
	end
	self.mb_num = self.award_pool
	GameComAnimTool.stop_number_change_anim(self.anim_tab)
	if not self.cur_num or not self.mb_num or self.cur_num == self.mb_num then
		return
	end
	self.is_animing = true
	self.anim_tab = GameComAnimTool.play_number_change_anim(self.award_txt, tonumber(self.cur_num), tonumber(self.mb_num), 40, function ()
		self.cur_num = self.mb_num
		self.is_animing = false
		self:RunChange()
	end)
end
