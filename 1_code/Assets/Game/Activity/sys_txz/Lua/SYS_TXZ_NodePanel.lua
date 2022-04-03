-- 创建时间:2021-05-06
-- Panel:SYS_TXZ_NodePanel
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

SYS_TXZ_NodePanel = basefunc.class()
local C = SYS_TXZ_NodePanel
C.name = "SYS_TXZ_NodePanel"
local M=SYS_TXZ_Manager
local perCreatNum=10

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
	self.lister["refresh_txz_buytype"] = basefunc.handler(self,self.MyRefresh)
	self.lister["refresh_txz_level_task_data"] = basefunc.handler(self,self.MyRefresh)
	self.lister["aquaman_passport_get_all_task_award_response"] = basefunc.handler(self,self.on_aquaman_passport_get_all_task_award_response)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	for index, value in ipairs(self.AwardListPre) do
		value:MyExit()
	end
	if self.progress_pre then
		self.progress_pre:MyExit()
	end
	if self.loopTimer then
		self.loopTimer:Stop()
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
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.buybag_btn.gameObject).onClick = basefunc.handler(self, self.OnBuybagBtnClick)
	EventTriggerListener.Get(self.getall_btn.gameObject).onClick = basefunc.handler(self, self.OnGetAllBtnClick)
	EventTriggerListener.Get(self.goto_btn.gameObject).onClick = basefunc.handler(self, self.OnGoToBtnClick)
	EventTriggerListener.Get(self.banner_btn.gameObject).onClick = basefunc.handler(self, self.OnBannerBtnClick)

	self.progress_pre=SYS_TXZ_ProgresPanel.Create(self.top_center_node.transform)
	self.loading_obj.gameObject:SetActive(false)


	local minShowLevel = M.GetMinCanGetAwardLevel()
	self.leftIndex = math.floor(  (minShowLevel-1) / perCreatNum ) + 1
	self.rightIndex = self.leftIndex
	self.maxIndex = math.floor(  (M.MaxLevel-1) / perCreatNum ) + 1
	self.ScrollRect = self.sv:GetComponent("ScrollRect")
	self.ScrollRect.horizontalNormalizedPosition = 0
	EventTriggerListener.Get(self.ScrollRect.gameObject).onEndDrag = function()
		local HNP = self.ScrollRect.horizontalNormalizedPosition  
		if HNP <= 0 and self.leftIndex > 1 then 
			self.leftIndex = self.leftIndex - 1
			self:CreateItem(self.leftIndex,true)
		end
		if HNP >= 1 and self.rightIndex < self.maxIndex  then 
			self.rightIndex = self.rightIndex + 1
			self:CreateItem(self.rightIndex,false)
		end
	end

	local commonAward=M.GetTXZAwardConfigInfo()
	self.myAwardInfo={}
	for i=1,#commonAward do
		local item={}
		item.commonAward=commonAward[i]
		self.myAwardInfo[#self.myAwardInfo+1] = item
	end
	self.AwardListPre={}
	self.creatPreIndex=0

	self:CreateItem(self.leftIndex)
	local scrowBar=self.scrow_bar:GetComponent("Scrollbar")
	local canGotValue=(M.GetMinCanGetAwardLevel()%perCreatNum)/perCreatNum
	scrowBar.value=canGotValue
	self:MyRefresh()
end
-- index ： 分段索引 perCreatNum 一个分段
function C:CreateItem(index,isLeft)
	local beginIndex = (index-1) * perCreatNum + 1
	local endIndex = index * perCreatNum
	if endIndex > M.MaxLevel then
		endIndex = M.MaxLevel
	end
	if isLeft then
		for level = endIndex, beginIndex,-1 do
			local pre
			if level%10~=0 then
				pre=sys_txz_listitem.Create(self.content.transform,level,self.myAwardInfo[level%10])
			else
				pre=sys_txz_listitem.Create(self.content.transform,level,self.myAwardInfo[10])
			end
			self.AwardListPre[#self.AwardListPre+1] = pre
			pre:ResetPosInParent()
			-- dump(#self.AwardListPre,"-------->self.AwardListPre:  ")
			-- local scrowBar=self.scrow_bar:GetComponent("Scrollbar")
			-- dump(scrowBar.value,"scrowBar.value:  ")
		end
		
	else
		for level = beginIndex, endIndex do
			local pre
			if level%10~=0 then
				pre=sys_txz_listitem.Create(self.content.transform,level,self.myAwardInfo[level%10])
			else
				pre=sys_txz_listitem.Create(self.content.transform,level,self.myAwardInfo[10])
			end
			self.AwardListPre[#self.AwardListPre+1] = pre
		end
	end	
end
function C:MyRefresh()
	local buytxztype=M.GetBuyBagType()
	--self.haiwangbigmask_img.gameObject:SetActive(buytxztype==0)
	--self.haiwangsamalmask_img.gameObject:SetActive(buytxztype==0)
	self.tip_pre.gameObject:SetActive(buytxztype == 0)
	self.haiwang_lock_img.gameObject:SetActive(buytxztype==0)
	self.addflag_img.gameObject:SetActive(buytxztype>1)
	local nextTenInfo,nextlevel=M.GetNextTenLevelInfo()
	if nextlevel<=190 then
		if buytxztype<2 then
			GetTextureExtend(self.node1_icon_img,nextTenInfo.icon[1])
			GetTextureExtend(self.node2_icon_img,nextTenInfo.icon[2])
			self.node1_name_txt.text=nextTenInfo.num[1]
			self.node2_name_txt.text=nextTenInfo.num[2]
		else
			GetTextureExtend(self.node1_icon_img,nextTenInfo.icon[1])
			GetTextureExtend(self.node2_icon_img,nextTenInfo.icon[3])
			self.node1_name_txt.text=nextTenInfo.num[1]
			self.node2_name_txt.text=nextTenInfo.num[3]
		end
		self.nextten_txt.text=nextlevel .."级可领"
	else
		self.nextaward_node1.gameObject:SetActive(false)
		self.nextaward_node2.gameObject:SetActive(false)
		self.nextten_txt.gameObject:SetActive(false)
	end
	
	self.buybag_btn.gameObject:SetActive(buytxztype==0)
	self.goto_btn.gameObject:SetActive(buytxztype>0)
	self.banner_btn.gameObject:SetActive(buytxztype==0)
	if gameRuntimePlatform=="Ios" or gameRuntimePlatform=="Android" then
		self:CheckGotoInfo()
	elseif gameRuntimePlatform=="WindowsEditor" then
		if buytxztype==0 then
			GetTextureExtend(self.banner_img,"banner_hwlb")
		else
			local pt = gameMgr:getMarketPlatform()
			if pt == "byam" then
				GetTextureExtend(self.banner_img,"banner_ljyj2")
				self.downLoadType=2
			else
				GetTextureExtend(self.banner_img,"banner_ljyj")
				self.downLoadType=1
			end
		end
	end
end

function C:OnBuybagBtnClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	SYS_TXZ_ChoosePanel.Create()
end
function C:OnGetAllBtnClick()
	local commonTaskID=M.GetCommonLevelTaskID()
	Network.SendRequest("aquaman_passport_get_all_task_award", {id = commonTaskID})

end
function C:on_aquaman_passport_get_all_task_award_response(_,data)
	dump(data,"on_aquaman_passport_get_all_task_award_response:  ")
	if data and data.result==0 then
		-- local scrowBar=self.scrow_bar:GetComponent("Scrollbar")
		-- local canGotValue=M.GetMinCanGetAwardLevel()/197
		-- scrowBar.value=canGotValue
	else

		HintPanel.Create(1,errorCode[data.result])
	end
end

function C:CheckGotoInfo()
	
	self.downLoadType=0  --1: android  欢乐捕鱼-->捕鱼奥秘  3： android  捕鱼奥秘-->欢乐捕鱼
						  --2：Ios  欢乐捕鱼--->捕鱼奥秘     4： Ios 捕鱼奥秘--->欢乐捕鱼	
	local conditionKeyTable={"hlttby_type_plat1","hlttby_type_plat2","hlttby_type_plat3","hlttby_type_plat4"}
	local platform = gameMgr:getMarketPlatform()
	local channel = gameMgr:getMarketChannel()
	local checkFuc=function (_condi)
		local _permission_key=_condi
		if _permission_key then
			local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
			if a and not b then
				return false
			end
			return true
		else
			return true
		end
	end
	for index, value in ipairs(conditionKeyTable) do
		if checkFuc(value) then
			self.downLoadType=index
			break
		end
	end
	local buytxztype=M.GetBuyBagType()

	if buytxztype==0 then
		GetTextureExtend(self.banner_img,"banner_hwlb")
	else
		if self.downLoadType==1 or self.downLoadType==2 then
			GetTextureExtend(self.banner_img,"banner_ljyj")
		elseif self.downLoadType==3 or self.downLoadType==4 then
			GetTextureExtend(self.banner_img,"banner_ljyj2")
		end
	end
	self.goto_btn.gameObject:SetActive(buytxztype~=0 and self.downLoadType~=0)

end
---1.捕鱼奥秘Android下载地址
---2.捕鱼奥秘Ios下载地址
---3.欢乐捕鱼Android下载地址
---4.欢乐捕鱼Ios下载地址
local gotoDownPathTabel={"http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/byam_byam.apk",
						"itms-services://?action=download-manifest&url=https://cdndownload.game3396.com/install/ios/qiye/byam/byam_byam_aibianxian.plist",
						"http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/hlby_android.apk",
						"itms-services://?action=download-manifest&url=https://cdndownload.game3396.com/install/ios/qiye/hlttby/normal_normal.plist"}
---游戏跳转功能
function C:OnGoToBtnClick()
	if self.downLoadType~=0 then
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		UnityEngine.Application.OpenURL(gotoDownPathTabel[self.downLoadType])
	end
end
function C:OnBannerBtnClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local des="海王之力：瞬间提高子弹280%的杀伤力,\n被动效果：提高击杀BOSS的概率,\n排名加成：通行证中领取加成权限后当周达人榜数据加成。"
	LTTipsPrefab.Show2(self.banner_btn.transform,"属性:",des)
end
