-- 创建时间:2020-10-28
-- Panel:XRQTLJLItemPrefab
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

XRQTLJLItemPrefab = basefunc.class()
local C = XRQTLJLItemPrefab
C.name = "XRQTLJLItemPrefab"
local M = XRQTLManager

function C.Create(parent, index)
	return C.New(parent, index)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["XRQTL_DownCount_msg_new_top"] = basefunc.handler(self,self.MyRefresh)
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

function C:ctor(parent, index)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.index = index
	LuaHelper.GeneratingVar(self.transform, self)
	self.infor = M.GetCurDayTaskInfor()
	--表中在8的位置
	self.infor_jl = self.infor[8]

	self.tips_txt = self.infor_jl[index].des


	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	self.jl_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:ShowTipsByIndex(self.index)
	end)
end

function C:InitUI()
	self:MyRefresh()
	self:ShowContentInJL(self.index)
end

function C:MyRefresh()
	self.task_ = GameTaskModel.GetTaskDataByID(30032)
	if self.task_ then 
		local b = basefunc.decode_task_award_status(self.task_.award_get_status)
		self.b = basefunc.decode_all_task_award_status(b, self.task_ , 6)
		dump(self.b)
		if IsEquals(self.gameObject) then
			for i=1,#self.b do
				if self.b[self.index] == 2 then
					self.lq.gameObject:SetActive(true)
					self.tx.gameObject:SetActive(false)
				elseif self.b[self.index] == 1 then
					self.tx.gameObject:SetActive(true)
				end
			end
			if self.index == 6 then
				self.jcz_quan_01.gameObject:SetActive(true)
			end
		end
	end
end

function C:ShowTipsByIndex(index)

	Network.SendRequest("get_task_award_new", 
		{id = 30032, award_progress_lv = index},"请求奖励",function(data)
					if data.result == 0 then
						if index == 1 then
							Network.SendRequest("query_fish_3d_gun_info",nil,"请求数据",
									function (_data)
										-- dump(_data,"<color=yellow><ddddddddddddddddddddddddd></color>")
										-- if _data and _data.result == 0 then
										-- 	for i,v in ipairs(_data.barrel_list) do
										-- 		if v.id == 6 and v.time == "0" then
										-- 			HintPanel.Create(1, "您当前已有永久死灵之光，不再获得新的死灵之光")
										-- 			return
										-- 		end
										-- 	end	
										-- end
									end)
						end
						self:MyRefresh()
					else
						LittleTips.Create("当前积分不足，不可以领取奖励")
					end
				end)
	
end

function C:ShowContentInJL(index)
	self.jl_txt.text = self.infor_jl[index].des
	self.jl_img.sprite = GetTexture(self.infor_jl[index].image_dj)
end
