-- 创建时间:2020-06-02
-- Panel:Act_Ty_JRTHItemBase
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

Act_Ty_JRTHItemBase = basefunc.class()
local C = Act_Ty_JRTHItemBase
C.name = "Act_Ty_JRTHItemBase"
local M = Act_Ty_JRTHManager

function C.Create(parent,index,ids)
	return C.New(parent,index,ids)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["CJLB_itembase_change_msg"] = basefunc.handler(self,self.isAlreadyGet)
    self.lister["CJLB_on_box_exchange_response"] = basefunc.handler(self,self.isAlreadyGet)
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

function C:ctor(parent,index,ids)
	self.ids = ids
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	local config = M.GetConfig()
	self.config = config[index]

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	if self.ids == 6 then--头奖
		self.best_img.gameObject:SetActive(true)
		self.award_txt.fontSize = 37
		self.BG_best.gameObject:SetActive(true)
		self.BG_normal.gameObject:SetActive(false)
		self.award_txt.transform.localPosition = Vector3.New(-31,-65,0)
	else
		self.best_img.gameObject:SetActive(false)
		self.award_txt.fontSize = 34
		self.BG_best.gameObject:SetActive(false)
		self.BG_normal.gameObject:SetActive(true)
		self.award_txt.transform.localPosition = Vector3.New(-5,-83,0)
	end
	self.award_img.sprite = GetTexture(self.config.award_images[self.ids])
	self.award_txt.text = self.config.award_descs[self.ids].."金币"
end

function C:MyRefresh()

end

--是否已经领取过
function C:isAlreadyGet(data,ID)
	--dump(data,"<color=green>+++++++++++ids++++++++++</color>")
	--dump(ID,"<color=red>++++++++++++++ID+++++++++++++++</color>")
	local ids = data[ID].exchange_record
	for i=1,#ids do
		if ids[i].id == self.ids then
			self.already_img.gameObject:SetActive(true)
		end
	end
end


