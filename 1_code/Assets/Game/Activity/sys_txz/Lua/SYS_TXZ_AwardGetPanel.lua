-- 创建时间:2021-05-08
-- Panel:SYS_TXZ_AwardGetPanel
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

SYS_TXZ_AwardGetPanel = basefunc.class()
local C = SYS_TXZ_AwardGetPanel
C.name = "SYS_TXZ_AwardGetPanel"
local M = SYS_TXZ_Manager

function C.Create(award_data)
	ExtendSoundManager.PlaySound(audio_config.game.bgm_hall_huodewupin.audio_name)
	return C.New(award_data)
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
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:MyExit()
end

function C:ctor(award_data)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.award_data=award_data
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	DOTweenManager.OpenPopupUIAnim(self.transform)

end

function C:InitUI()
	self:InitMore()
	EventTriggerListener.Get(self.confirm_btn.gameObject).onClick = basefunc.handler(self, self.MyClose)
	EventTriggerListener.Get(self.gotobuy_btn.gameObject).onClick = basefunc.handler(self, self.OnGoToBuyBtnClick)
	local itemInfo=GameItemModel.GetItemToKey(self.award_data[1].asset_type)
	dump(itemInfo,"itemInfo---->")
	GetTextureExtend(self.commonAward_img,itemInfo.image)
	self.commonAward_txt.text="x"..self.award_data[1].value
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:OnGoToBuyBtnClick()
	SYS_TXZ_ChoosePanel.Create()
	self:MyClose()
end

function C:InitMore()
	local tab = {0,0,0}
	local level = M.GetNowLevel()
	local count = math.floor(level / 10)
	tab[1] = count * 830000
	tab[2] = count * 1
	tab[3] = count * 1
	local config = M.GetTXZAwardConfigInfo()
	for i=1,level%10 do
		local str = config[i].num[2]
		if string.find(str,"金币") then
			tab[1] = tab[1] + tonumber(string.sub(str,1,string.len(str) - 9)) * 10000
		elseif string.find(str,"优惠券") then
			tab[2] = tab[2] + 1
		elseif string.find(str,"炮台加成") then
			tab[3] = tab[3] + 1
		end
	end
	local tab_icon = {"ty_icon_jb_30y","com_award_icon_czyhq4","ty_icon_debjc2"}
	for i=1,#tab do
		if tab[i] ~= 0 then
			local pre = GameObject.Instantiate(self.haiwangAward,self.more_node.transform)
			pre.gameObject:SetActive(true)
			pre.transform:Find("Award_img").gameObject:GetComponent("Image").sprite = GetTexture(tab_icon[i])
			pre.transform:Find("Award_txt").gameObject:GetComponent("Text").text = "x" .. tab[i]
			if i == 3 then
				pre.transform:Find("Award_txt").gameObject:GetComponent("Text").text = "达人榜加成"
				pre.transform:Find("tq").gameObject:SetActive(true)
			end
		end
	end
end

