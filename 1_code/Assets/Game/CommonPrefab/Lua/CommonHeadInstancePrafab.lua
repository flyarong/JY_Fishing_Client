-- 创建时间:2020-08-27
-- Panel:CommonHeadInstancePrafab
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

CommonHeadInstancePrafab = basefunc.class()
local C = CommonHeadInstancePrafab
C.name = "CommonHeadInstancePrafab"

--[[
parm包含参数:
    type = 1(方) 2(圆)
    parent = Vector3父节点
    pos = Vector3位置
    scale = Vector3缩放比例
    head_url = ""头像链接
    head_img = ""头像
    head_frame_id  = ""头框id
    not_self = false(是自己) true(不是自己)
    vip

    style = 1(显示:头像,vip,头像框)  2(显示:头像,vip)  3(显示:头像,头像框)  4(显示:头像)
--]]


function C.Create(parm)
	return C.New(parm)
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
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parm)
	self.not_self = parm.not_self
	self.style = parm.style or 1
	self.parent = parm.parent
    self.pos = parm.pos or Vector3.New(0,0,0)
    local scale = parm.scale or 1
    self.scale = Vector3.New(scale,scale,scale)
    self.head_url = parm.head_url
    self.head_img = parm.head_img
    self.vip = parm.vip
    -- 讲道理头像id至少是1,但是服务器会发来0,策划说0按1处理
    if parm.head_frame_id == 0 then
    	parm.head_frame_id = 1
    end
    self.head_frame_id = parm.head_frame_id
    local prefab_name = parm.prefab_name or C.name
	local parent = self.parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(prefab_name, parent)
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
	self.transform.localPosition = self.pos
	self.transform.localScale = self.scale
	if self.head_url then
		URLImageManager.UpdateHeadImage(self.head_url, self.head_pre_img)
	else	
		if not self.head_img then
			URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.head_pre_img)
		else
			self.head_pre_img.sprite = GetTexture(self.head_img)
		end
	end
	self.head_frame_pre_img.gameObject:SetActive(self.style == 1 or self.style == 3)
	if self.style == 1 or self.style == 3 then
		if IsEquals(self.head_frame_pre_img) then
			if self.not_self then
				GameButtonManager.RunFunExt("sys_by_bag", "SetHeadFrame", nil, self.head_frame_pre_img , self.head_frame_id)
			else
				GameButtonManager.RunFunExt("sys_by_bag", "SetHeadFrame", nil, self.head_frame_pre_img)
			end
		end
	end

	if self.style == 1 or self.style == 2 then
		if IsEquals(self.vip_txt) then
			if self.vip then
				VIPManager.set_vip_text(self.vip_txt, self.vip) 
			else
				VIPManager.set_vip_text(self.vip_txt)
			end
		end
	end


end

function C:SetStyle(style)
	self.style = style
	self:MyRefresh()
end


