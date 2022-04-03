-- 创建时间:2020-06-11
-- 捕鱼AI

local basefunc = require "Game.Common.basefunc"
FishingComPlayerAI = basefunc.class()

local C = FishingComPlayerAI

function C.Create(panelSelf)
    return C.New(panelSelf)
end
function C:FrameUpdate(time_elapsed)
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
	if self.run_time then
		self.run_time:Stop()
		self.run_time = nil
	end
    self:RemoveListener()
end
function C:ctor(panelSelf)
	self.panelSelf = panelSelf

	self:MakeLister()
    self:AddMsgListener()

    self.time_elapsed = 1

    self.run_time = Timer.New(function ()
    	self:RunCheck(self.time_elapsed)
    end, self.time_elapsed, -1, nil, true)
end

function C:Start()
	if FishingModel.isChangeAI then
		self.run_time:Start()
	end
end
function C:Stop()
	self.run_time:Stop()
end

function C:RunCheck(time_elapsed)
	if self.panelSelf.userdata and self.panelSelf.userdata.base then
		local seat_num = self.panelSelf.userdata.base.seat_num
		if not self.panelSelf.userdata.is_auto then
			self:SetAutoClick(true)
		else
		    if seat_num > 2 then
			    self.panelSelf.gun.GunAnim.transform.rotation = Quaternion.Euler(0, 0, math.random(0, 180)+90)
			else
			    self.panelSelf.gun.GunAnim.transform.rotation = Quaternion.Euler(0, 0, math.random(0, 180)-90)
		    end
		end

		self.run_t = self.run_t or 0
		self.run_t = self.run_t + time_elapsed
		if self.run_t > 10 and seat_num ~= 1 then
			self.run_t = 0
		    local rr = self.panelSelf.gun.GunAnim.transform.eulerAngles.z + 90
		    if FishingModel.IsRotationPlayer() then
		        rr = rr + 180
		    end

		    local Deg2Rad = (3.1415926 * 2) / 360
		    local vec = Vector3(math.cos(rr * Deg2Rad), math.sin(rr * Deg2Rad), 0)

			FishingLogic.GetPanel():GunSkillShoot({vec=vec, seat_num=seat_num})
		end
	end
end

function C:SetAutoClick(is_auto)
    if is_auto then
        self.panelSelf.userdata.is_auto = true
        self.panelSelf.userdata.auto_index = 1
    else
        self.panelSelf.userdata.is_auto = false
        self.panelSelf.userdata.auto_index = 1
    end
    self.panelSelf:SetAuto(self.panelSelf.userdata.is_auto)
end

