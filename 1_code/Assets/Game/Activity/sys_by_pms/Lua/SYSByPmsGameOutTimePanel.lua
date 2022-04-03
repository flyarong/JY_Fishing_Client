-- 创建时间:2020-05-07
-- Panel:SYSByPmsGameOutTimePanel
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

SYSByPmsGameOutTimePanel = basefunc.class()
local C = SYSByPmsGameOutTimePanel
C.name = "SYSByPmsGameOutTimePanel"

function C.Create(data)
	return C.New(data)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
    self.lister["model_pms_game_info_change_msg"] = basefunc.handler(self,self.on_model_pms_game_info_change_msg)
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

function C:ctor(data)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.score_txt.text = SYSByPmsManager.GetCurScore()

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.retry_btn.gameObject).onClick = basefunc.handler(self, self.On_Retry)
	EventTriggerListener.Get(self.continue_btn.gameObject).onClick = basefunc.handler(self, self.On_Continue)
	self.share_btn.onClick:AddListener(function ()
	    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:On_Share()
	end)
	local config = SYSByPmsManager.GetCurBSData()
	local id = SYSByPmsManager.GetSignupData()
	local item_index = SYSByPmsManager.CheckPMSIsCanSignup(id).result
	if item_index == -1 then--三种报名物品都不足
		self.enter_icon_img.sprite = GetTexture(GameItemModel.GetItemToKey(config.enter_condi_itemkey[#config.enter_condi_itemkey]).image)
		self.enter_hint_txt.text = config.enter_condi_item_count[#config.enter_condi_itemkey]
	elseif item_index == 0 then--免费报名类型
		self.enter_icon_img.gameObject:SetActive(false)
		self.enter_hint_txt.text = "免费报名"
	else--至少满足一种报名物品
		self.enter_icon_img.sprite = GetTexture(GameItemModel.GetItemToKey(config.enter_condi_itemkey[item_index]).image)
		self.enter_hint_txt.text = config.enter_condi_item_count[item_index]
	end
	M.QueryCurPMSGameInfo()
	self:MyRefresh()

	if GameGlobalOnOff.InternalTest then
		self.share_btn.gameObject:SetActive(false)
		self.continue_btn.transform.localPosition = Vector3.New(-340,self.continue_btn.transform.localPosition.y,0)
		self.retry_btn.transform.localPosition = Vector3.New(340,self.retry_btn.transform.localPosition.y,0)
	end
end

function C:MyRefresh()
end


--[[function C:ExitGame()
	Network.SendRequest("fsg_3d_quit_game", nil, "请求退出", function (data)
		if data.result == 0 then
            GameManager.GotoSceneName("game_FishingMatchHall")
        end
    end)
end--]]

function C:On_Retry()
	self.bool = false
	local id = SYSByPmsManager.GetSignupData()
	GameButtonManager.RunFun({gotoui = "sys_by_pms", data={id = id}}, "signup")
	self:MyExit()
end

function C:On_Continue()
	self.bool = false
	self:MyExit()
end

function C:On_Share()
	SYSByPmsGameSharePanel.Create()
	self:MyExit()
end


function C:on_model_pms_game_info_change_msg()
	self.pms_game_info = M.GetCurPMSGameInfo()
	self.remain_time_txt.text = "剩余次数:"..self.pms_game_info.num
end