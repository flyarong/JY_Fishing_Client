-- 创建时间:2021-03-04
-- Panel:SYSLWGPHistoryItemBase
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

SYSLWGPHistoryItemBase = basefunc.class()
local C = SYSLWGPHistoryItemBase
C.name = "SYSLWGPHistoryItemBase"
local M = SYSLWGPManager

function C.Create(parent,data)
	return C.New(parent,data)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:ClearItemPre()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent,data)
	ExtPanel.ExtMsg(self)
	self.data = data
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
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
	self:MyRefresh()
end

function C:MyRefresh()
	self.time_txt.text =self:FormTimer(self.data.kaijiang_time)
	self.name_txt.text = self.data.first_player_info.name
	self.jlb_txt.text =StringHelper.ToCash( self.data.first_player_info.award_num)
	local headImgUrl=""
	local isNumber=tonumber(self.data.first_player_info.head_image)
	if isNumber then 
		headImgUrl=M.GetDefaltHeadUrl(isNumber)
	else
		headImgUrl=self.data.first_player_info.head_image
	end 
	self.head_pre = CommonHeadInstancePrafab.Create({type = 1,
							parent = self.headBG_img.transform,
							style = 2,
							head_url = headImgUrl,
    						head_frame_id  = "",
							scale = 0.8, 
							not_self = true,
							vip=self.data.first_player_info.vip_level,
							})
	self:CheckRefreshUI()
	self:CreateItemPre()
end
function C:FormTimer(_time)
    return os.date("%Y/%m/%d\n%H:%M",_time) 
end
function C:CreateItemPre()
	self:ClearItemPre()
	local tab = self.data.kaijiang_index
	for i=1,#tab do
		local pre = GameObject.Instantiate(self.item,self.item_node)
		local configData=M.GetStoreCfg()[tab[i]]
		pre.gameObject:SetActive(true)
		pre.transform:Find("icon_img").gameObject:GetComponent("Image").sprite = GetTexture(configData.goods_icon)
		pre.transform:Find("name_txt").gameObject:GetComponent("Text").text =configData.name
		self.pre_cell[#self.pre_cell + 1] = pre
	end
end

function C:ClearItemPre()
	if self.pre_cell then
		for k,v in pairs(self.pre_cell) do
			destroy(v.gameObject)
		end
	end
	self.pre_cell = {}
end

function C:CheckRefreshUI()
	if is_myself then
		self.bg_img.sprite = GetTexture("lwgp_bg_200")

		self.bg1_img.sprite = GetTexture("lwgp_bg_5")
		self.bg2_img.sprite = GetTexture("lwgp_bg_5")
	
		self.jlb_bg_img.sprite = GetTexture("lwgp_bg_400")
	else
		self.bg_img.sprite = GetTexture("lwgp_bg_100")

		self.bg1_img.sprite = GetTexture("lwgp_bg_6")
		self.bg2_img.sprite = GetTexture("lwgp_bg_6")
		
		self.jlb_bg_img.sprite = GetTexture("lwgp_bg_8")
	end
end