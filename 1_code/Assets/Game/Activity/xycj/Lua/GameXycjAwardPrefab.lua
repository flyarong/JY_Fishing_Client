-- 创建时间:2020-05-21
-- Panel:GameXycjAwardPrefab
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

GameXycjAwardPrefab = basefunc.class()
local C = GameXycjAwardPrefab
C.name = "GameXycjAwardPrefab"

function C.Create(parent_transform, config, panelSelf)
	return C.New(parent_transform, config, panelSelf)
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

function C:ctor(parent_transform, config, panelSelf)
	self.config = config
	self.panelSelf = panelSelf
	local obj
	if config.is_dj == 0 then
		
		local prfabType=config.id%10
		if prfabType==0 then
			-- body
			prfabType=10
		end
		obj = newObject("xycj_jp"..prfabType.."_prefab", parent_transform)

	else
		obj = newObject("xycj_jps_prefab", parent_transform)
	end
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.transform.localPosition = Vector3.zero
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end
imagArg={0,45}
desArg={0,45,}
function C:MyRefresh()
	self.icon_img.sprite = GetTexture(self.config.icon)
	self.award_txt.text = self.config.desc
end

function C:OnDestroy()
	self:MyExit()
end