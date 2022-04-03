-- 创建时间:2020-06-05
-- Panel:HallPtShowPanel
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

HallPtShowPanel = basefunc.class()
local C = HallPtShowPanel
C.name = "HallPtShowPanel"
local M = SYSByBagManager

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
    --self.lister["sys_by_bag_gun_info_change_msg"] = basefunc.handler(self,self.MyRefresh)
    self.lister["sys_by_choose_change_msg"] = basefunc.handler(self,self.RefreshShow)
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["NewPersonPanel_OnBackClik_msg"] = basefunc.handler(self,self.MyExit)
    self.lister["EnterForeGround"] = basefunc.handler(self, self.on_backgroundReturn_msg)
    self.lister["OnePanel_had_been_Open_msg"] = basefunc.handler(self,self.on_OnePanel_had_been_Open_msg)
    self.lister["OnePanel_had_been_Close_msg"] = basefunc.handler(self,self.on_OnePanel_had_been_Close_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:KillSeq()
	self:StopShowTimer()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:ctor(parent)
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.cell = {}
	self.id = M.GetCurChosePtID()
	self.name = M.GetCurChosePtName()
	self.bed_id = M.GetCurChoseBedID()
	self.bed_img = self.ptdz_node.transform:GetComponent("Image")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:InitConfig()
	self:MyRefresh()
	self:RefreshGun(self.id)
	
end

function C:InitConfig()
    local fish3d_gun_barrel_config = HotUpdateConfig("Game.game_Fishing3D.Lua.fish3d_gun_barrel_config")
    local Config = {}
    Config.gun_style_map = {}
    for k,v in ipairs(fish3d_gun_barrel_config.main) do
        Config.gun_style_map[v.id] = Config.gun_style_map[v.id] or {}
        for k1,v1 in ipairs(fish3d_gun_barrel_config.skin) do
            if v1.skin_id == v.skin_id then
                for i=v1.gun_index[1], v1.gun_index[2] do
                    Config.gun_style_map[v.id][i] = v1
                end
            end
        end
    end

    self.Config = Config

    local x = SYSByBagManager.item_gun_config.config
    self.bed_config = {}
    for i=1,#x do
    	if x[i].type == 2 then
    		self.bed_config[#self.bed_config + 1] = x[i]
    	end
    end
end

function C:MyRefresh()
	
end

function C:RefreshGun(skin_id)
	if self.gun_obj then
		destroy(self.gun_obj)
		self.gun_obj = nil
	end

	local cfg = self.Config.gun_style_map[skin_id][1]
	local obj = GameObject.Instantiate(GetPrefab(cfg.gunprefab.."_ui"), self.pt_node)
	self.gun_obj = obj.gameObject
	self:SetLayer(4)
	self.gun_obj.transform.localPosition = Vector3.zero
	self.gun_obj.transform.localScale = Vector3.New(1, 1, 0)
	self.anim = self.gun_obj.transform:Find("Gun"):GetComponent("Animator")
	self.name_pt_txt.text = self.name
	local bed = 0
	for i=1,#self.bed_config do
		if self.bed_config[i].item_id == self.bed_id then
			bed = self.bed_config[i].image
			break
		end
	end
	self.bed_img.sprite = GetTexture(bed)
	self:UpdataShowTimer()
end

function C:Shoot(skin_id)

	
	local cfg = self.Config.gun_style_map[skin_id][1]
	self:KillSeq()
	self.obj = GameObject.Instantiate(GetPrefab(cfg.bullet_prefab.."_ui"), self.bullet_node.transform)

	self.anim:Play("gun_kp",-1,0)
	self.seq = DoTweenSequence.Create()
	self.seq:Append(self.obj.transform:DOLocalMove(Vector3.New(self.obj.transform.localPosition.x,self.obj.transform.localPosition.y+300,self.obj.transform.localPosition.z),0.3))
	self.seq:AppendCallback(function ()
		self.net_obj = GameObject.Instantiate(GetPrefab(cfg.net_prefab), self.gun_obj.transform)
		self.net_obj.transform.localPosition = Vector3.New(self.obj.transform.localPosition.x,self.obj.transform.localPosition.y+50,self.obj.transform.localPosition.z)
		self.net_obj.transform.localScale = Vector3.New(1,1,1)
		destroy(self.obj.gameObject)
	end)
	self.seq:AppendInterval(1)
	self.seq:AppendCallback(function ()
		destroy(self.net_obj.gameObject)
	end)
end


function C:RefreshShow(data)
	self.name = data.name
	self.id = data.id
	self:RefreshGun(self.id)
end

function C:KillSeq()
	if IsEquals(self.obj) then
		destroy(self.obj.gameObject)
	end
	if IsEquals(self.net_obj) then
		destroy(self.net_obj.gameObject)
	end
	if self.seq then
		self.seq:Kill()
		self.seq = nil
	end
end


function C:UpdataShowTimer()
	self:StopShowTimer()
	self.show_timer = Timer.New(function ()
		self:Shoot(self.id)
	end,1.5,-1,false,true)
	self.show_timer:Start()
end

function C:StopShowTimer()
	if self.show_timer then
		self.show_timer:Stop()
		self.show_timer = nil
	end
end


function C:on_backgroundReturn_msg()
    self:RefreshGun(self.id)
end

function C:on_OnePanel_had_been_Open_msg()
	self.ImageBg.gameObject:SetActive(false)
	self.ptdz_node.gameObject:SetActive(false)
	self.pt_node.gameObject:SetActive(false)
end

function C:on_OnePanel_had_been_Close_msg()
	self.ImageBg.gameObject:SetActive(true)
	self.ptdz_node.gameObject:SetActive(true)
	self.pt_node.gameObject:SetActive(true)
end

-- 设置层级
function C:SetLayer(sort_index)
	local ps = self.gun_obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.Renderer), true)
	for i = 0, ps.Length - 1 do
		ps[i].sortingOrder = sort_index
	end
end