-- 创建时间:2020-08-11

local basefunc = require "Game/Common/basefunc"

SYSTGXTBDPanel = basefunc.class()
local C = SYSTGXTBDPanel
C.name = "SYSTGXTBDPanel"

local M = SYSTGXTManager
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
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["success_player_parent_id_msg"] = basefunc.handler(self,self.success_player_parent_id_msg)
    self.lister["query_one_player_head_image_and_name_response"] = basefunc.handler(self,self.query_one_player_head_image_and_name_response)
	self.lister["global_game_panel_close_msg"] = basefunc.handler(self,self.on_global_game_panel_close_msg)
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

function C:ctor(parent)
	
	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:tgxt_player_new_change_to_old()

	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.sure_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnGetSureClick()
	end)
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
end

--
function C:GetPlayParentID()
	if M.GetMyParentID()  then
		self.no_bd_root.gameObject:SetActive(false)
		self.bd_root.gameObject:SetActive(true)
		self.parentID_txt.text = M.GetMyParentID()
	else
		self.parentID_txt.text = "无"
	end
end

function C:IsHaveParent()
	if M.IsHaveParent() then
	end
end

function C:OnGetSureClick()
	if self.parent_txt.text  and  self.parent_txt.text ~= "" then
		if self.parent_txt.text == MainModel.UserInfo.user_id then
			LittleTips.Create("不可添加自己的邀请码！")
		else
			Network.SendRequest("query_one_player_head_image_and_name",{player_id = self.parent_txt.text})
		end
	else 
		LittleTips.Create("请输入邀请码")
 	end	
end

--MainModel.UserInfo.ui_config_id = 1 是old a是否存在  b 结果
function C:tgxt_player_new_change_to_old()
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key= "gfpt_tgxt", is_on_hint = true}, "CheckCondition")
	if a and  b then
		if M.GetMyParentID() and  MainModel.UserInfo.ui_config_id ~= 1 then
			self:GetPlayParentID()
		elseif not M.GetMyParentID() and  MainModel.UserInfo.ui_config_id == 1 then
			self.no_bd_root.gameObject:SetActive(false)
			self.bd_root.gameObject:SetActive(true)
			self.parentID_txt.text = "无"
		elseif M.GetMyParentID() and MainModel.UserInfo.ui_config_id == 1 then
			self:GetPlayParentID()
		end	
	else
		self.no_bd_root.gameObject:SetActive(false)
		self.bd_root.gameObject:SetActive(true)
		self.parentID_txt.text = "无"
	end
end

function C:query_one_player_head_image_and_name_response(_,data)
	dump(data,"<color=red>PPPPPPPPPPPPP</color>")
	if data.result == 0 then
		SYSTGXTMakeSurePanle.Create()
		Event.Brocast("player_parent_id_msg",{parent_id = self.parent_txt.text,data = data})
	else
		if data.result == 4410 then
			LittleTips.Create("输入有误")
		elseif data.result == 1001 then
			LittleTips.Create("请输入邀请码")
		elseif data.result == 4411 then
			LittleTips.Create("不可添加自己的邀请码")
		else
			HintPanel.ErrorMsg(data.result)
		end
	end
end

function C:success_player_parent_id_msg()
	self:GetPlayParentID()
end

function C:on_global_game_panel_close_msg(data)
	if data.ui == "NewPersonPanel" then
		self:MyExit()
	end
end