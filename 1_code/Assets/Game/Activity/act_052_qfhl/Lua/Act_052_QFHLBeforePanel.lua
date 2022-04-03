-- 创建时间:2021-04-25
-- Panel:Act_052_QFHLBeforePanel
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

Act_052_QFHLBeforePanel = basefunc.class()
local C = Act_052_QFHLBeforePanel
C.name = "Act_052_QFHLBeforePanel"
local  M = Act_052_QFHLManager
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
	self.lister["query_fake_data_response"] = basefunc.handler(self, self.AddPMD)
	self.lister["multicast_msg"] = basefunc.handler(self,self.AddRealPMD)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.UpdatePMDTimer then
		self.UpdatePMDTimer:Stop()
	end
	if self.pmd_cont then
		self.pmd_cont:MyExit()
		self.pmd_cont = nil
	end
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
	ExtPanel.ExtMsg(self)
	local parent =parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.chooseIndex=0
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:OnChooseItemClick(0)
	dump(self,"beforeChosePre")
	self.chooseItem1_btn.onClick:AddListener(function ()
		self:OnChooseItemClick(1)
	end)
	self.chooseItem2_btn.onClick:AddListener(function ()
		self:OnChooseItemClick(2)
	end)
	self.chooseItem3_btn.onClick:AddListener(function ()
		self:OnChooseItemClick(3)
	end)
	self.confirm_btn.onClick:AddListener(function ()
		self:OnConfirmBtnClick()
	end)
	for i=1,3 do
		local img_str=M.GetAwardSwInfo(i).image
		self["iconimg_"..i.."_img"].sprite = GetTexture(img_str)
	end
	self.pmd_cont = CommonPMDManager.Create(self,self.CreatePMD,{ parent = self.pmd_node, speed = 18, space_time = 10, start_pos = 1000 , dotweenLayerKey = "qfhl_before" })
	self:UpDatePMD()
	self:MyRefresh()
end
function C:CreatePMD(data)
	-- dump(data,"pmddata:   ")
	local obj = GameObject.Instantiate(self.pmd_item, self.pmd_node.transform)
	local text = obj.transform:Find("@t1_txt"):GetComponent("Text")
	if data.have_string then
		text.text=data.have_string
	else
		text.text = "恭喜【 " .. data.player_name .. " 】完成任务获得了" .. data.ext_data[1] .. "！"
	end
	obj.gameObject:SetActive(true)
	return obj
end
function C:UpDatePMD()
	if self.UpdatePMDTimer then
		self.UpdatePMDTimer:Stop()
	end
	local type = M.GetDataOtherType()
	Network.SendRequest("query_fake_data", { data_type = type })
	self.UpdatePMDTimer = Timer.New(
		function()
			Network.SendRequest("query_fake_data", { data_type = type })
		end
	, 10, -1)
	self.UpdatePMDTimer:Start()
end
function C:AddRealPMD(_,data)
	if table_is_null(data) then return end
	if  data.type ~= 101 or  data.format_type ~= 1 then return end
	local _data_info = {}
	_data_info["result"] = 0
	_data_info["have_string"] = data.content
	_data_info["data_type"]=M.GetDataOtherType()
	self:AddPMD(0, _data_info)
end
function C:AddPMD(_, data)
	if not IsEquals(self.gameObject) then return end
	if data and data.result == 0 and data.data_type and data.data_type==M.GetDataOtherType() then
		self.pmd_cont:AddPMDData(data)
	end
end
function C:OnChooseItemClick(index)
	self.chooseIndex=index
	self["choseFlag_img_1"].gameObject:SetActive(index==1)
	self["choseFlag_img_2"].gameObject:SetActive(index==2)
	self["choseFlag_img_3"].gameObject:SetActive(index==3)
end
function C:OnConfirmBtnClick()
	if self.chooseIndex==0 then
		LittleTips.Create("请先选择实物奖励～")
		return
	end
	local sw_str=""
	local level_str=""
	if self.chooseIndex==1 then
		level_str="[简单]"
	elseif self.chooseIndex==2 then
		level_str="[中等]"
	elseif self.chooseIndex==3 then
		level_str="[挑战]"
	end
	sw_str=M.config.Award_sw[self.chooseIndex].tex
	local tips="您选择的奖励为"..sw_str..",\n任务难度为"..level_str.."\n确定后不可更改，是否确认？"

	HintPanel.Create(4,tips,function ()
		self:OnConfirmCallBack()
	end,self.OnCancelCallBack)
end
function C:OnConfirmCallBack()
	---发送确定难度类型到服务器
	dump(self.chooseIndex,"确定开始一个挑战任务：  ")
	if self.chooseIndex==0 then
		dump(0,"<color=red>当前未选择挑战类型！！！<color>")
		return 
	end
	M.ChooseIndexBuff(self.chooseIndex)
	Network.SendRequest("set_xsyd_status", {xsyd_type="qfhl_lottery",status = self.chooseIndex })
end
function C:OnCancelCallBack()
	
end
function C:MyRefresh()
end
