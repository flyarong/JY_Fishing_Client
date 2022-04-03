-- 创建时间:2021-03-30
-- Panel:SYSLWGPSettlementPanel
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

SYSLWGPSettlementPanel = basefunc.class()
local C = SYSLWGPSettlementPanel
C.name = "SYSLWGPSettlementPanel"

function C.Create(award_num)
	return C.New(award_num)
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

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(award_num)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.award_num=award_num
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:PlayXGYFishDead()
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:PlayXGYFishDead()
	ExtendSoundManager.PlaySound(audio_config.by.bgm_by_jiangli5.audio_name)
	local number_to_array = function(number, len)
		local tbl = {}
		local nn = number
		while nn > 0 do
			tbl[#tbl + 1] = nn % 10
			nn = math.floor(nn / 10)
		end

		local array = {}
		if len then
			if len > #tbl then
				for idx = len, 1, -1 do
					if idx > #tbl then
						array[#array + 1] = 0
					else
						array[#array + 1] = ""..tbl[idx]
					end
				end
			else
				for idx = #tbl, 1, -1 do
					array[#array + 1] = ""..tbl[idx]
				end
				print("<color=red>EEE 长度定义不合理 number = " .. number .. "  len = " .. len .. "</color>")
			end
		else
			for idx = #tbl, 1, -1 do
				array[#array + 1] = ""..tbl[idx]
			end
		end
		return array
	end
	dump(self.award_num,"self.award_num--->")

	local arr = number_to_array(self.award_num, 9)
	-- 滚动数据
	local item_list = {}
	for i = 1, 9 do
		item_list[#item_list + 1] = self["Mask"..i].gameObject
	end
	local seq = DoTweenSequence.Create()
	local delta_t = nil
	if delta_t and delta_t > 0 then
		seq:AppendInterval(delta_t)
		seq:AppendCallback(function ()
			FishingAnimManager.ScrollLuckyChangeToFiurt(item_list,arr,function ()
				print("<color=red>滚动完成XXXXXXXXXXXXX</color>")
			end)
		end)
	else
		GameComAnimTool.ScrollLuckyChangeToFiurt(item_list,arr)
	end
	seq:AppendInterval(5)
	--seq:Append(tran:DOMove(endPos, 0.6):SetEase(DG.Tweening.Ease.InQuint))
	-- seq:AppendCallback(
	-- 	function()
	-- 		if backcall then
	-- 			backcall()
	-- 		end
	-- 	end
	-- )
	seq:OnForceKill(function ()
		self:MyExit()
	end)
end

