

local basefunc = require "Game.Common.basefunc"

BY3DJCPrefab = basefunc.class()

local instance = nil
function BY3DJCPrefab.Create(data, parent)
	instance = BY3DJCPrefab.New(data, parent)
	return instance
end
function BY3DJCPrefab:ctor(data, parent)
	self.data = data
    self.gameObject = newObject("BY3DJCPrefab", parent)
    self.transform = self.gameObject.transform
    local tran = self.transform
    tran.localPosition = Vector3.New(700, 0, 0)
	local text = tran:Find("Text"):GetComponent("Text")
	text.text = data.msg.content
	local ww = text.preferredWidth + 20

	self.seqMove = DoTweenSequence.Create()

	local is_complete = false
	-- 移动速度固定 计算移动时间
	local tt1 = (1290 + ww)/1290 * 6
	-- 400是两条滚动广播的距离
	local tt2 = (400 + ww)/1290 * 6
	local pos1 = Vector3.New(-1290/2-ww, 0, 0)
	self.seqMove:AppendInterval(tt2)
	self.seqMove:AppendCallback(function ()
		GameBroadcastManager.PlayJCInforFinish(data.key)
	end)
	self.seqMove:AppendInterval(-1 * tt2)
	self.seqMove:Append(tran:DOLocalMoveX(pos1.x, tt1):SetEase(DG.Tweening.Ease.Linear))
	self.seqMove:OnComplete(function ()
		is_complete = true
		BY3DPmdPrefabPanel.PlayEnd(data.key)
	end)
	self.seqMove:OnForceKill(function ()
		self.seqMove = nil
		if not is_complete then
			is_complete = true
			BY3DPmdPrefabPanel.PlayEnd(data.key)
		end
	end)
end
function BY3DJCPrefab:Destroy()
	if IsEquals(self.gameObject) then
		if self.seqMove then
			self.seqMove:Kill()
		end
		GameObject.Destroy(self.gameObject)
	end
end

