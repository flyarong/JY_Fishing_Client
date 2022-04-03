-- 创建时间:2019-06-04
-- Panel:ActXRCDJCJCellPrefab
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

ActXRCDJCJCellPrefab = basefunc.class()
local C = ActXRCDJCJCellPrefab
C.name = "ActXRCDJCJCellPrefab"

function C.Create(parent_transform, config)
	return C.New(parent_transform, config)
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
	destroy(self.transform.gameObject)
end

function C:ctor(parent_transform, config)
	self.config = config
	local obj = newObject(C.name, parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()
    LuaHelper.GeneratingVar(obj.transform, self)

    self.zoumadeng = newObject("choujiang_zoumadeng_jin", tran)
    self.zoumadeng.gameObject:SetActive(false)
    self.zoumadeng_anim = self.zoumadeng.transform:GetComponent("Animator")

	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	self.award_img.sprite = GetTexture(self.config.icon)
	self.award_txt.text = self.config.desc
	if self.config.is_dj == 1 then
		self.big_hint.gameObject:SetActive(true)
	else
		self.big_hint.gameObject:SetActive(false)
	end
end
function C:OnDestroy()
	self:MyExit()
	destroy(self.gameObject)
end
function C:SetPos(pos)
	self.transform.localPosition = pos
end
function C:RunFX()
	self.zoumadeng.gameObject:SetActive(false)
	self.zoumadeng.gameObject:SetActive(true)
end
function C:PlayXZ()
	self.zoumadeng_anim:Play("choujiang_zoumadeng_xuanzhong", -1, 0)
end
function C:RunEnd()
	self.zoumadeng.gameObject:SetActive(false)
end


