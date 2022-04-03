-- 创建时间:2020-04-29
-- Panel:Fishing3DFZ_HF
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

Fishing3DFZ_HF = basefunc.class()
local C = Fishing3DFZ_HF
C.name = "Fishing3DFZ_HF"

local vip_gun_list = {}
vip_gun_list[#vip_gun_list + 1] = {min_vip=0, max_vip=2, gun_list={1,800, 2,200} }
vip_gun_list[#vip_gun_list + 1] = {min_vip=3, max_vip=7, gun_list={1,100, 2,600, 3,400, 4,200} }
vip_gun_list[#vip_gun_list + 1] = {min_vip=8, max_vip=-1, gun_list={1,50, 2,200, 3,400, 4,800, 5,200, 6,100, 7,50} }

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
    self.lister["model_fsg_join_msg_sub_sys"] = basefunc.handler(self, self.model_fsg_join_msg_sub_sys)
    self.lister["model_fsg_leave_msg_sub_sys"] = basefunc.handler(self, self.on_model_fsg_leave_msg_sub_sys)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
end

function C:ctor()
	for k,v in ipairs(vip_gun_list) do
		local aa = 0
		for i=1, #v.gun_list, 2 do
			aa = aa + v.gun_list[i+1]
		end
		v.all_rect = aa
	end
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:GetVipByGunCfg(vip)
	for k,v in ipairs(vip_gun_list) do
		if (v.min_vip == -1 or vip >= v.min_vip) and (v.max_vip == -1 or vip <= v.max_vip) then
			return v
		end
	end
end

function C:model_fsg_join_msg_sub_sys(seat_num)
	local player = FishingModel.GetSeatnoToUser(seat_num)
	if player and player.base then
		self.old_data = self.old_data or {}
		if self.old_data[player.base.id] and self.old_data[player.base.id].time > os.time() then
			FishingModel.SetGunSkinID(seat_num, self.old_data[player.base.id].skin_id)
			FishingModel.SetBedSkinID(seat_num, self.old_data[player.base.id].bed_id)
			return
		end
		local vip = player.base.vip_level or 1
		local cfg = self:GetVipByGunCfg(vip)
		local rr = math.random(1, cfg.all_rect)
		local nn = 0
		local skin_id = 1
		for i=1, #cfg.gun_list, 2 do
			nn = nn + cfg.gun_list[i+1]
			if rr <= nn then
				skin_id = cfg.gun_list[i]
				break
			end
		end
		local bed_id = math.random(1, 4)
		self.old_data[player.base.id] = {skin_id=skin_id, bed_id=bed_id, time=os.time() + 600}
		FishingModel.SetGunSkinID(seat_num, skin_id)
		FishingModel.SetBedSkinID(seat_num, bed_id)
	end
end
function C:on_model_fsg_leave_msg_sub_sys(seat_num)
	
end