-- 创建时间:2019-08-22
-- Panel:AwardPrefab
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

AwardPrefab = basefunc.class()
local C = AwardPrefab
C.name = "AwardPrefab"

-- icon name
function C.Create(parent, data, prefab_name)
	return C.New(parent, data, prefab_name)
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
	if self.seq then
		self.seq:Kill()
		self.seq = nil
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent, data, prefab_name)
	self.data = data
	local obj = newObject(prefab_name or C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	if IsEquals(self.jiangli_LQ) then
		self.jiangli_LQ.gameObject:SetActive(false)
	end

	self:MakeLister()
	self:AddMsgListener()

	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	-- dump(self.data,"<color=red>ssssss</color>")
	if self.data.icon then
		self.AwardIcon_img.sprite = GetTexture(self.data.icon)
	else
		GetTextureExtend(self.AwardIcon_img, self.data.image, self.data.is_local_icon)
	end

	if self.data.desc then
		self.DescText_txt.text = self.data.desc	
	elseif self.data.value then
		self.DescText_txt.text = self.data.value
	end	

	if  self.iconbg_1_img and self.iconbg_2_img then
		if self.data.shiwu then
			self.iconbg_1_img.gameObject:SetActive(false)
			self.iconbg_2_img.gameObject:SetActive(true)
		else
			self.iconbg_1_img.gameObject:SetActive(true)
			self.iconbg_2_img.gameObject:SetActive(false)
		end
	end
	if self.data.desc_extra then
		self.ExtText_txt.text=self.data.desc_extra
	end
end

function C:OnDestroy()
	self:MyExit()
end

function C:RunAnim(t)
	if self.seq then
		self.seq:Kill()
		self.seq = nil
	end
	self.transform.localScale = Vector3.New(0, 0, 0)
	self.seq = DoTweenSequence.Create()
	if t then
		self.seq:AppendInterval(t)
	end
	self.seq:AppendCallback(function ()
		self.jiangli_LQ.gameObject:SetActive(true)
		ExtendSoundManager.PlaySound(audio_config.game.bgm_hall_choubiaoqing.audio_name)
	end)
    self.seq:Append(self.transform:DOScale(Vector3.New(1.2, 1.2, 1.2), 0.2))
    self.seq:Append(self.transform:DOScale(Vector3.New(0.9, 0.9, 0.9), 0.1))
    self.seq:Append(self.transform:DOScale(Vector3.New(1, 1, 1), 0.05))
	self.seq:OnKill(function ()
		self.seq = nil
		self.jiangli_LQ.gameObject:SetActive(true)
		self.transform.localScale = Vector3.New(1, 1, 1)
	end)
	self.seq:OnForceKill(function ()
		self.seq = nil
		self.jiangli_LQ.gameObject:SetActive(true)
		self.transform.localScale = Vector3.New(1, 1, 1)
	end)
end

