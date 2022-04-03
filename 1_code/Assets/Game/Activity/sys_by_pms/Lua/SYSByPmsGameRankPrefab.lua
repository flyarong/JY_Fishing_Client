-- 创建时间:2020-04-27
-- Panel:SYSByPmsGameRankPrefab
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

SYSByPmsGameRankPrefab = basefunc.class()
local C = SYSByPmsGameRankPrefab
C.name = "SYSByPmsGameRankPrefab"

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
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)

    self.lister["model_sys_by_pms_game_data"] = basefunc.handler(self, self.model_sys_by_pms_game_data)
    self.lister["query_bullet_rank_part_response"] = basefunc.handler(self,self.on_query_bullet_rank_part)		

end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:Stop_Timer()
	self:ClearCellList()
	self:RemoveListener()
	destroy(self.gameObject)
end
function C:OnDestroy()
	self:MyExit()
end
function C:ctor(parent)
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.bsdata = SYSByPmsManager.GetCurBSData()
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.rank_btn.onClick:AddListener(function ()
	    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnRankClick()
	end)
	EventTriggerListener.Get(self.top_button.gameObject).onClick = basefunc.handler(self, self.OnRankClick)
	self.exit_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:ExitGame()
	end)
	self:Query_bullet_rank_part_Timer(true)
	self.pms_name_txt.text = (self.bsdata.game_name or "")
	self:MyRefresh()
end

function C:MyRefresh()
	self.is_open = false
	self.is_lock = false

	if self.is_open then
		self.rectui.transform.localPosition = Vector3.New(-610, 0, 0)
		self.top_button.gameObject:SetActive(true)
	else
		self.rectui.transform.localPosition = Vector3.zero
		self.top_button.gameObject:SetActive(false)
	end

	self:RefreshRank()
end
function C:model_sys_by_pms_game_data()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:SetData(SYSByPmsManager.GetCurDotNum(k))
		end
	end
end
function C:RefreshRank()
	-- todo
	--[[self.rank_data = {}
	for i = 1, 10 do
		self.rank_data[#self.rank_data + 1] = {rank=i, name = "12312_"..i, score=123*i}
	end
	if not self.CellList then
		self.CellList = {}
		for k,v in ipairs(self.rank_data) do
			local pre = SYSByPmsGameRankItem.Create(self.Content, v, nil, self)
			self.CellList[#self.CellList + 1] = pre
		end
	end

	if self.CellList then
		for k,v in ipairs(self.rank_data) do
			if self.CellList[k] then
				self.CellList[k]:MyRefresh(v)
			end
		end
	end--]]
	self.CellList = {}
	for i=1,4 do
		local pre = SYSByPmsGameRankItem.Create(self.Content,i)
		self.CellList[#self.CellList + 1] = pre
	end
end

function C:ClearCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:MyExit()
		end
	end
	self.CellList = {}
end

function C:OnRankClick()
	if self.is_lock then
		return
	end
	self.is_open = not self.is_open

	local end_pos
	if self.is_open then
		end_pos = Vector3.New(0-670, 0, 0)
		self.top_button.gameObject:SetActive(true)
	else
		end_pos = Vector3.New(0, 0, 0)
		self.top_button.gameObject:SetActive(false)
	end

	self.is_lock = true
	self.icon_triangle.transform.localScale = Vector3.New(-1*self.icon_triangle.transform.localScale.x,1,1)
	local seq = DoTweenSequence.Create()
	seq:Append(self.rectui:DOLocalMove(end_pos, 0.3))
	seq:OnKill(function ()
		self.is_lock = false
	end)
end

function C:OnExitScene()
	self:MyExit()
end

function C:ExitGame()
	SYSByPmsGameExitPanel.Create()
end




function C:Query_bullet_rank_part()
	dump("<color=yellow>+++++++++++++++++++++++++++++</color>")
	Network.SendRequest("query_bullet_rank_part",{id = M.GetSignupData()})
end

function C:Query_bullet_rank_part_Timer(b)
	self:Stop_Timer()
	if b then
		dump("<color=yellow>+++++++++++++++++++++++++++++</color>")
		self.timer_rank = Timer.New(function ()
			self:Query_bullet_rank_part()
		end,30,-1,false,true)
		self.timer_rank:Start()
	end
end

function C:Stop_Timer()
	if self.timer_rank then
		self.timer_rank:Stop()
		self.timer_rank = nil
	end
end


function C:on_query_bullet_rank_part(_,data)
	dump(data,"<color>++++++++++++++on_query_bullet_rank_part+++++++++++++++</color>")
	if data then
		if data.result == 0 then
			for i=2,4 do
				self.CellList[i]:Refresh(data.part_data[data.part_data[i-1].rank_id])
			end
			Event.Brocast("BYPMS_on_query_bullet_rank_part",data.cur_rank)
		else
			HintPanel.ErrorMsg(data.result)
		end
	end
end

