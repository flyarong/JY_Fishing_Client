-- 创建时间:2020-09-07
-- Panel:Act_Ty_LB1Panel
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

Act_Ty_LB1Panel = basefunc.class()
local C = Act_Ty_LB1Panel
C.name = "Act_Ty_LB1Panel"
local M = Act_Ty_LB1Manager

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
    self.lister["ty_lb1_gift_data_had_got_msg"] = basefunc.handler(self,self.on_ty_lb1_gift_data_had_got_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:StopMoveTimer()
	self:DeleteItem()
	self:StopTimer()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.sv = self.transform:Find("Scroll View"):GetComponent("ScrollRect")
	self.back_btn.onClick:AddListener(
		function () 
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self.MyExit()
		end
	)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.right_btn.gameObject).onClick = basefunc.handler(self, self.OnRightClick)
	EventTriggerListener.Get(self.left_btn.gameObject).onClick = basefunc.handler(self, self.OnLeftClick)
	self.hint_txt.text = M.config.other_data[1].xg_desc
	local sta_t = self:GetStart_t()
	local end_t = self:GetEnd_t()
	self.hint_time_txt.text = "活动时间：".. sta_t .."-".. end_t
	
	-- print("背景图片路径：  "..M.cur_path.."bg_1")

	SetTextureExtend(self.bg_img,M.cur_path.."bg_1")
	SetTextureExtend(self.right_btn:GetComponent("Image"),M.cur_path.."btn_zxj")
	SetTextureExtend(self.left_btn:GetComponent("Image"),M.cur_path.."btn_zxj")


	-- self.bg_img.sprite=GetTexture(M.cur_path.."bg_1")
	-- self.right_btn:GetComponent("Image").sprite=GetTexture(M.cur_path.."btn_zxj")
	-- self.left_btn:GetComponent("Image").sprite=GetTexture(M.cur_path.."btn_zxj")
	PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
	M.SetHintState()
	M.QueryGiftData()
end

function C:MyRefresh()
	self:CreateItemPrefab()
	self:StartTimer()
end

function C:CreateItemPrefab()
	self:DeleteItem()
	local list = {}
	for i=1,#M.GetCurrConfig() do
		local d = {}
		list[#list + 1] = d
		d.cfg = M.GetCurrConfig()[i]
		d.status = MainModel.GetGiftShopStatusByID(d.cfg.shop_id)
	end
	MathExtend.SortListCom(list, function (v1, v2)
		if v1.status == 1 and v2.status == 0 then
			return false
		elseif v1.status == 0 and v2.status == 1 then
			return true
		else
			if v1.cfg.id > v2.cfg.id then
				return true
			else
				return false
			end
		end
	end)

	for i=1, #list do
		local pre = Act_Ty_LB1ItemPanel.Create(self.Content, list[i].cfg.shop_id)
		self.game_cell_list[i] = pre
	end	
	
end

function C:DeleteItem()
	if self.game_cell_list then
		for i,v in ipairs(self.game_cell_list) do
			v:MyExit()
		end
	end
	self.game_cell_list = {}
end

function C:StartTimer()
	self:StopTimer()
	self.main_time = Timer.New(function ()
		local pos = self.Content.transform.localPosition.x 
		if pos >= -34 then
			self.left_btn.gameObject:SetActive(false)
			self.right_btn.gameObject:SetActive(true)
		else
			self.right_btn.gameObject:SetActive(false)
			self.left_btn.gameObject:SetActive(true)
		end
	end,0.02,-1) 
	self.main_time:Start()
end

function C:StopTimer()
	if self.main_time then
		self.main_time:Stop()
		self.main_time = nil
	end
end

function C:OnDestroy()
	self:MyExit()
end

function C:GetStart_t()
	return string.sub(os.date("%m月%d日%H:%M",M.GetActStartTime()),1,1) ~= "0" and os.date("%m月%d日%H:%M",M.GetActStartTime()) or string.sub(os.date("%m月%d日%H:%M",M.GetActStartTime()),2)
end

function C:GetEnd_t()
	return string.sub(os.date("%m月%d日%H:%M:%S",M.GetActEndTime()),1,1) ~= "0" and os.date("%m月%d日%H:%M:%S",M.GetActEndTime()) or string.sub(os.date("%m月%d日%H:%M:%S",M.GetActEndTime()),2)
end

function C:OnRightClick()
	self:MoveTween(true,1)
end

function C:OnLeftClick()
	self:MoveTween(true,0)
end

function C:MoveTween(b,target_num)
	self:StopMoveTimer()
	if b then
		self.movetimer = Timer.New(function ()
			if self.sv.horizontalNormalizedPosition == target_num then
				self:StopMoveTimer()
			else
				self.sv.horizontalNormalizedPosition = Mathf.Lerp(self.sv.horizontalNormalizedPosition,target_num,0.1)
			end
		end,0.0005,30,false)
		self.movetimer:Start()
	end
end

function C:StopMoveTimer()
	if self.movetimer then
		self.movetimer:Stop()
		self.movetimer = nil
	end
end

function C:on_ty_lb1_gift_data_had_got_msg()
	self:MyRefresh()
end