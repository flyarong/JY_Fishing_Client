-- 创建时间:2020-04-15
-- Panel:ByToolBagPanel
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

ByToolBagPanel = basefunc.class()
local C = ByToolBagPanel
C.name = "ByToolBagPanel"

function C.Create(parent, parm, panelSelf)
	return C.New(parent, parm, panelSelf)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["AssetChange"] = basefunc.handler(self, self.MyRefresh)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.timer then
        self.timer:Stop()
        self.timer = nil
    end
	self:CloseCellList()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent, parm, panelSelf)
	self.parm = parm
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.panelSelf = panelSelf
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.use_btn.onClick:AddListener(function()
		self:OnUseClick()
	end)
	self.name_txt.horizontalOverflow = self.sy_time_txt.horizontalOverflow
	self:MyRefresh()
end

function C:MyRefresh()
	if MainModel.myLocation == "game_Fishing3D" then
		self.cell_data = GameItemModel.GetBagItem(8)
	else
		self.cell_data = GameItemModel.GetBagItem(1)
	end
	self:Begin()

	if self.cell_data and #self.cell_data > 0 then
		self.select_index = 1
		self.CellList[self.select_index]:SetSelect(true)
	end
	self:RefreshDesc()
end

-- 详情界面
function C:RefreshDesc()
	if self.select_index then
		self.desc_node.gameObject:SetActive(true)
		local data = self.cell_data[self.select_index]
		dump(data)
		if not data then return end
		-- 根据数据显示详细信息
		if data.btn_img then
			self.btn_img.sprite = GetTexture(data.btn_img)
		else
			self.btn_img.sprite = GetTexture("bb_imgf_sy")
		end
		if data.image then
			self.icon_img.sprite = GetTexture(data.image)
		end
		if data.desc then 
			self.desc_txt.text = data.desc
		end
		if data.num and data.num > 0 then
			self.num_txt.text = "拥有数量：".. data.num
		else
			self.num_txt.text = "拥有数量：1"
		end
		if data.name then
			self.name_txt.text = data.name
		end
		if data.use_parm and next(data.use_parm) then
			self.use_btn.gameObject:SetActive(true)
		else
			self.use_btn.gameObject:SetActive(false)
		end
		self:SpecialHandling(data)
	    if data.date then
	        if data.date >= 24 then
	            if data.date >= 50 * 24 * 365 then
	                self.time.gameObject:SetActive(false)
	            else
	            	self.time.gameObject:SetActive(true)
	                self.sy_time_txt.text = "有效期 剩" .. math.ceil(data.date/24) .. "天"
	            end
	        else
	        	self.time.gameObject:SetActive(true)
	            self.sy_time_txt.text = "有效期 剩" .. data.date .. "小时"
	        end
	    else
	    	self.time.gameObject:SetActive(false)
	    end
	else
		self.desc_node.gameObject:SetActive(false)
	end
end

-- 道具
function C:CloseCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:MyExit()
		end
	end
	self.CellList = {}
end

function C:OnToggleClick(index)
	if self.select_index ~= index then
		self.CellList[self.select_index]:SetSelect(false)
	end
	self.select_index = index
	self.CellList[self.select_index]:SetSelect(true)
	self:RefreshDesc()
end

function C:OnUseClick()
	if not self.select_index then return end
	local config = self.cell_data[self.select_index]
	if config.use_parm then
        if (not config.beginTime or config.beginTime <= os.time()) or (not config.endTime or config.endTime >= os.time()) then
        	
            GameManager.GuideExitScene({gotoui=config.use_parm[1], goto_scene_parm=config.use_parm[2], data=config.use_parm[3], call=function ()
                self.panelSelf:MyExit()
            end,enter_scene_call=function(  )
                FishingManager.SignFishing(config)
            end})
        else
            HintPanel.Create(1, config.desc)
        end
	end
end

-- 延迟创建
function C:Begin()
	self.ci = 0
    self.pci = 16
    self.delayCreateFunc = function ()
        self.ci = self.ci + 1
        local ok = self:CreateBagItem(self.ci)
        if ok then
            local t = 0.03 * math.floor(self.ci/10)
            t = math.min(t,0.12)
            self.timer = Timer.New(self.delayCreateFunc,t)
            self.timer:Start()
        end
    end
    self:RefreshAssets()
end
function C:CreateBagItem(index)
    if not self.cell_data then
        return false
    end

    local v = self.cell_data[index]

    if not v then
        return false
    end

	local pre = ByItemPrefab.Create(self, self.cell_data[index], self.Content, self.OnToggleClick, index)
	self.CellList[#self.CellList + 1] = pre

    return true
end

function C:RefreshAssets()
    self:CloseCellList()

    if table_is_null(self.cell_data) then return end
    if self.timer then
        self.timer:Stop()
        self.timer = nil
    end
    self.ci = 0

    for k, v in ipairs(self.cell_data) do
        self.ci = self.ci + 1
        self:CreateBagItem(self.ci)
        if self.ci >= self.pci then
            break
        end
    end
    
    self.delayCreateFunc()

end


--2021.8.10版本运营需求--欢乐天天捕鱼&捕鱼奥秘小优化-余洪铭.docx
function C:SpecialHandling(data)
	if data.item_key == "prop_xycj_coin" then
		local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "cpl_notcjj", is_on_hint = true}, "CheckCondition")
		if a and b then
			self.use_btn.gameObject:SetActive(true)
		else
			self.use_btn.gameObject:SetActive(false)
		end
	end
end