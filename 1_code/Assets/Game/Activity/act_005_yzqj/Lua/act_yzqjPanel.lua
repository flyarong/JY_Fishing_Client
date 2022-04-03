-- 创建时间:2020-03-17
-- Panel:act_yzqjPanel
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

act_yzqjPanel = basefunc.class()
local C = act_yzqjPanel
C.name = "act_yzqjPanel"
--local seq
local M = Act_005YZQJManager

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
    --self.lister["click_like_activity_collect_advise_response"] = basefunc.handler(self, self.on_advise_response)
    --self.lister["get_task_award_response"] = basefunc.hander(self,self.on_award_response)

    self.lister["model_one_task_data_act_yzqj"]=basefunc.handler(self,self.on_model_one_task_data_act_yzqj)
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

function C:ctor(parent)

	ExtPanel.ExtMsg(self)

	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self.bx_anim = self.bx_btn.transform:GetComponent("Animator")
	self.bx_img = self.bx_btn.transform:GetComponent("Image")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
--提交按钮(判断字数是否不少于20字，且两次提交间隔时间是否大于5分钟)
	self.tj_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnTJClick()
	end)


--宝箱按钮
	self.bx_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnGetAwardClick()
	end)
	M.QueData()

	self:MyRefresh()
end

function C:MyRefresh()
--宝箱添加抖动效果
    --[[if M.IsCanGetAward()==2 then
		self.bx_btn.transform:GetComponent("Animator").enabled=false
		self.bx_btn.transform.localScale=Vector3.New(1,1,1)
		self.bx_btn.transform:GetComponent("Image").sprite=GetTexture("yzqj_iocn_ylq")
		self.Light_img.transform:GetComponent("Animator").enabled=false
		self.Light_img.transform.localRotation=Vector3.New(0,0,0)
	end--]]
	self.user_txt.text = M.GetLocalJY() or ""
	self.Inputfield_ipf.text = M.GetLocalJY() or ""
	self:RefreshAnimAndImage()
end

function C:on_model_one_task_data_act_yzqj()
	self:MyRefresh()
end

function C:OnTJClick()
	self.user_input_txt = self.user_txt.text
	if self.user_input_txt then
		local txt = basefunc.string.trim(self.user_input_txt)
		dump(#txt,"<color=yellow>+++++++++++++++++++++</color>")
		if #txt > 0 and #txt <= 1000 then 	
	      	if not PlayerPrefs.HasKey(MainModel.UserInfo.user_id.."yzqj_1020")  then
				print("第一次提交")
				PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."yzqj_1020",os.time())
				M.SaveJY(self.user_txt.text)
				self:SendTJ()
			else 
				--if (os.time() - PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."yzqj_1020"))>300 then
					print("非第一次提交")
					PlayerPrefs.DeleteKey(MainModel.UserInfo.user_id.."yzqj_1020")
					PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."yzqj_1020",os.time())
					M.SaveJY(self.user_txt.text)
					self:SendTJ()
				--[[else
					LittleTips.Create("提交失败,两次提交时间间隔不得少于5分钟")
				end--]]
			end
		elseif #txt <= 0 then
			LittleTips.Create("请认真填写后再提交！")
		elseif #txt > 1000 then
			LittleTips.Create("字数过多!")
		end

		--[[if not self.user_input_txt or self.user_input_txt == "" then
			
		else
			LittleTips.Create("请认真填写，少于20个字没有奖励哦！")
		end--]]
	end

	self:MyRefresh()
end
function C:SendTJ()
	print("<color=green>+++++++++提交+++++++++++++++</color>")
	Network.SendRequest("click_like_activity_collect_advise", {advise=self.user_txt.text}, "提交建议", function (data)
		if data.result ==0 then
			if M.IsCanGetAward()==1 then
				LittleTips.Create("提交成功,请点击宝箱领取奖励")
			else
				LittleTips.Create("提交成功")
			end
			self:MyRefresh()
		else
			HintPanel.ErrorMsg(data.result)
		end
		self:RefreshAnimAndImage()
	end)
end

function C:RefreshAnimAndImage()
	dump(M.IsCanGetAward(),"<color=yellow>+++++++++++一字千金+++++++++++</color>")
	if M.IsCanGetAward()==1 then
		self.bx_anim:Play("bx_ani",-1,0)
		self.bx_img.sprite = GetTexture("yzqj_iocn_klq")--可领取
	elseif M.IsCanGetAward()==2 then
		self.bx_anim:Play("null",-1,0)
		self.bx_img.sprite = GetTexture("yzqj_iocn_ylq")--已领取
	elseif M.IsCanGetAward()==0 then
		self.bx_anim:Play("null",-1,0)
		self.bx_img.sprite = GetTexture("yzqj_iocn_ddlq")--待领取
	end
end


function C:OnGetAwardClick()
	print("<color=green>++++++++++++++++++++宝箱++++++++++++++++</color>")
	if M.IsCanGetAward()==1 then	
		Network.SendRequest("get_task_award", {id = M.task_id}, "领取奖励")
		LittleTips.Create("领取成功")
	else
		if M.IsCanGetAward()==2 then
			LittleTips.Create("请勿重复领取")
		else
			LittleTips.Create("不符合领奖要求，大于20字可领奖！")
		end
	end
end

function C:OnDestroy()
	self:MyExit()
end
