-- 创建时间:2020-05-06
-- Panel:Act_TY_BY_HHLItemBase
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

Act_TY_BY_HHLItemBase = basefunc.class()
local C = Act_TY_BY_HHLItemBase
C.name = "Act_TY_BY_HHLItemBase"
local M = Act_TY_BY_HHLManager
function C.Create(parent, data, cfg)
	return C.New(parent, data, cfg)
end

function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
	self.lister["hhl_sw_kfpanel_msg"] = basefunc.handler(self,self.on_hhl_sw_kfpanel_msg)
	self.lister["hhl_tips_msg"] = basefunc.handler(self,self.on_hhl_tips_msg)
end

function C:OnDestroy()
	self:MyExit()
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

function C:ctor(parent, data, cfg)
	self.data = data
	self.config_info = cfg
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self.config = M.GetAwardByID(self.config_info.config[self.data.ID])
	
	self.item_ani = self.blue1_btn.transform:GetComponent("Animator")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.xianliang_img.gameObject.transform.localPosition = Vector2.New(-88.5,-3.6)
	self.xianliang_img.gameObject.transform.localScale = Vector2.New(0.70,0.70)
end

function C:InitUI()
	EventTriggerListener.Get(self.blue1_btn.gameObject).onClick = basefunc.handler(self, self.on_enough_click)
	EventTriggerListener.Get(self.yellow_btn.gameObject).onClick = basefunc.handler(self, self.on_not_enough_click)
	EventTriggerListener.Get(self.tips_btn.gameObject).onClick = basefunc.handler(self,self.OnClickTips)

	local rect = self.title_txt.transform:GetComponent("RectTransform")
	rect.sizeDelta = Vector2.New(rect.rect.width + 100, rect.rect.height)

	local item_cfg = M.GetInforByItemConfig()
	if item_cfg then
		self.yellow_txt.text = "获取"..item_cfg.name
		self.item_img.sprite = GetTexture(item_cfg.image)
	end
	SetTextureExtend(self.gift_image_img, self.config_info.cur_path .. self.config.award_image)
	self.gift_image_img:SetNativeSize()
	self.title_txt.text = self.config.award_name
	self.item_cost_text_txt.text = " "..StringHelper.ToCash(self.config.item_cost_text)
	self.blue_txt.text = "兑   换"
	if self.config_info.jf_icon then
		self.jf_icon_img.gameObject:SetActive(true)
		self.jf_txt.gameObject:SetActive(true)
	else
		self.jf_icon_img.gameObject:SetActive(false)
		self.jf_txt.gameObject:SetActive(false)
	end
	if self.config_info.jf_icon then
		self.jf_icon_img.sprite = GetTexture(self.config_info.jf_icon)
		self.jf_txt.text = "x" .. self.config.jf_num
	end
	self.remain_txt.text = self.data.remain_time == -1 and "无限" or "剩"..self.data.remain_time
	if GameItemModel.GetItemCount(self.config_info.item_key) < tonumber(self.config.item_cost_text) then--道具不足
		if self.data.remain_time > 0 or self.data.remain_time == -1 then--有剩余次数
			self.gray_img.gameObject:SetActive(false)
			self.blue1_btn.gameObject:SetActive(false)
			self.yellow_btn.gameObject:SetActive(true)
		else--没有剩余次数
			self.gray_img.gameObject:SetActive(true)
			self.blue1_btn.gameObject:SetActive(false)
			self.yellow_btn.gameObject:SetActive(false)		
		end
	else--道具足
		if self.data.remain_time > 0 or self.data.remain_time == -1 then
			self.gray_img.gameObject:SetActive(false)
			self.blue1_btn.gameObject:SetActive(true)
			self.item_ani:Play("blue1_ani",-1,0)
			self.yellow_btn.gameObject:SetActive(false)
		else--没有剩余次数
			self.gray_img.gameObject:SetActive(true)
			self.blue1_btn.gameObject:SetActive(false)
			self.yellow_btn.gameObject:SetActive(false)
		end
	end
	if not self.config.tips then
		self.tips_btn.gameObject:SetActive(false)
	end

	self:MyRefresh()
end

function C:MyRefresh()
end



function C:on_enough_click()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	------特殊实物兑换 有VIP等级要求情况
	if self.config.condiy_key then
		if not self:JudgeCondition(self.config.condiy_key) then
            local  viplevel = string.sub(self.config.condiy_key,-1)
			LittleTips.Create("该奖品为VIP"..viplevel.."及以上用户专享奖励。",{x = 160,y =150})
			return
		end
	end

	local iss = PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."hhl_ty_by"..os.date("%Y%m%d",os.time()), 0)
	if iss == 1 then
		iss = true
	else
		iss = false
	end
	if not iss then
        local str = string.format("是否兑换%s",self.config.award_name)
        local pre = HintPanel.Create(2, str, function (b)
          		Network.SendRequest("activity_exchange",{ type = self.config_info.change_type , id = self.data.ID })
	            if b then
	                PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."hhl_ty_by"..os.date("%Y%m%d",os.time()), 1)
	            else
	                PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."hhl_ty_by"..os.date("%Y%m%d",os.time()), 0)
	            end
        end)
        pre:ShowGou()
    else
		Network.SendRequest("activity_exchange",{ type = self.config_info.change_type , id = self.data.ID })
	end
end

function C:on_not_enough_click()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local parm = {}
	SetTempParm(parm, self.config_info.GotoUI, "panel")

   	GameManager.GuideExitScene(parm, function ()
   		Event.Brocast("exit_fish_scene")
   	end)
end

function C:OnClickTips()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	if self.config.tips then
		if self.tips.gameObject.activeSelf then
			self.tips.gameObject:SetActive(false)
		else	
			self.tips.gameObject:SetActive(true)
			self.tips_txt.text = self.config.tips
			Event.Brocast("hhl_tips_msg",self.data.ID)
		end
	end
end
function C:JudgeCondition(_permission_key)
	if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and  b then    
            return true
        end
        return false
    else
        return false
    end
end
function C:on_hhl_sw_kfpanel_msg(id)
	if id == self.data.ID then
		if self.config.type == 1 then
			local string1
	        string1 = "实物奖励请联系客服QQ号4008882620领取。"
			print(debug.traceback())
			local pre = HintCopyPanel.Create({desc=string1, isQQ=true,copy_value = Global_GZH})
			pre:SetCopyBtnText("复制QQ号")
		end
	end
end

function C:on_hhl_tips_msg(id)
	if id == self.data.ID then
		return
	else
		if self.config.tips then
			self.tips.gameObject:SetActive(false)
		end
	end
end