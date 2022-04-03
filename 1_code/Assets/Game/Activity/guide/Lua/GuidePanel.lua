-- 创建时间:2018-07-23

GuidePanel = {}

local basefunc = require "Game.Common.basefunc"

GuidePanel = basefunc.class()

GuidePanel.instance = nil

function GuidePanel.Show(cfg)
	if GuidePanel.instance and GuidePanel.instance.transform and IsEquals(GuidePanel.instance.transform) then
		GuidePanel.instance:ShowUI(cfg)
		return
	end
	GuidePanel.Create(cfg)
end
-- 显示
function GuidePanel:ShowUI(cfg)
	if self.guide_cfg and self.guide_cfg.id == cfg.id then
		dump(cfg, "<color=red>EEE 相同步骤正在执行</color>")
		return
	end
	local parent = GameObject.Find("Canvas/LayerLv50").transform
	if not IsEquals(parent) then
		print("GuidePanel:ShowUI exception: parent is nil")
		return
	end

	self.transform:SetParent(parent)
	self.transform.localScale = Vector3.one
	self.guide_cfg = cfg
	self:InitRect()
end
function GuidePanel.Exit()
	if GuidePanel.instance then
		GuidePanel.instance:HideUI()
		GuidePanel.instance:MyExit()
	end
	GuidePanel.instance = nil
end

-- 隐藏
function GuidePanel:HideUI()
	if IsEquals(self.targetGameObject) then
		local bclick = self.targetGameObject.gameObject:GetComponentsInChildren(typeof(UnityEngine.UI.Button))
		for i = 0, bclick.Length - 1 do
			bclick[i].onClick:RemoveListener(self.callClick)
		end
		local pclick = self.targetGameObject.gameObject:GetComponentsInChildren(typeof(PolygonClick))
		for i = 0, pclick.Length - 1 do
			pclick[i].PointerClick:RemoveListener(self.callClick2)
		end

		self.targetGameObject.transform:SetParent(self.originalParent)
		self.targetGameObject.transform:SetSiblingIndex(self.originalIndex)
		local meshs = self.targetGameObject.gameObject:GetComponentsInChildren(typeof(UnityEngine.MeshRenderer))
		for i = 0, meshs.Length - 1 do
			meshs[i].sortingOrder = meshs[i].sortingOrder - self.cha
		end
		local canvas = self.targetGameObject.gameObject:GetComponentsInChildren(typeof(UnityEngine.Canvas))
		for i = 0, canvas.Length - 1 do
			canvas[i].sortingOrder = canvas[i].sortingOrder - self.cha
		end
	end
	self.targetGameObject = nil

	self.guide_cfg = nil
	if IsEquals(self.gameObject) then
		self.transform:SetParent(GuidePanel.HideParent)
		self.gameObject:SetActive(false)
	end
end

function GuidePanel.Create(cfg)
	GuidePanel.instance = GuidePanel.New(cfg)
    return GuidePanel.instance
end

function GuidePanel:ctor(cfg)
	self.guide_cfg = cfg
    GuidePanel.HideParent = GameObject.Find("GameManager").transform
    self.parent = GameObject.Find("Canvas/LayerLv50")
    self.gameObject = newObject("GuidePanel", self.parent.transform)
    self.transform = self.gameObject.transform
    local tran = self.transform

    LuaHelper.GeneratingVar(self.transform, self)

    self.DebugText = tran:Find("DebugText"):GetComponent("Text")

    self.TopRect = self.top1_btn.transform:GetComponent("RectTransform")
    self.LeftBG = self.LeftBG:GetComponent("RectTransform")
    self.RightBG = self.RightBG:GetComponent("RectTransform")
    self.top1_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnClick()
    end)

    self.skip_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnSkipClick()
    end)

    -- 添加两个方法分别适用 Button PolygonClick, 原因：AddListener报参数长度不匹配
	self.callClick = function ()
		self:OnClick()
	end
	self.callClick2 = function ()
		self:OnClick()
	end
    self:InitRect()
end
function GuidePanel:MyExit()
	destroy(self.gameObject)
end
function GuidePanel:InitRect()
	self.gameObject:SetActive(true)

	self.skip_btn.gameObject:SetActive(false)
	self.BubbleNode.gameObject:SetActive(false)
	self.SZAnim.gameObject:SetActive(false)

	self:StepButton(self.guide_cfg)
end
function GuidePanel:StepButton(cfg)
	coroutine.start(function ( )
		Yield(0)

        -- 完成任务时可能UI不在选中状态,导致引导卡死
		if cfg.id == 4 then
	        Event.Brocast("global_select_top_index_msg", {gotoui = "by3d_kpshb"})    
		end

		self.DebugText.text = self.DebugText.text .. cfg.id .. "\n"
		self.GuideStyle2_btn.gameObject:SetActive(false)
		if cfg.type == "GuideStyle2" then
			self.targetGameObject = self:getFindObject(cfg.name)
			self.GuideStyle1.gameObject:SetActive(true)
			self.TopRect.sizeDelta = cfg.topsizeDelta
			self.LeftBG.sizeDelta = {x=3000, y=cfg.topsizeDelta.y}
			self.RightBG.sizeDelta = {x=3000, y=cfg.topsizeDelta.y}
			if IsEquals(self.targetGameObject) then
				self.Canvas.transform.position = self.targetGameObject.transform.position
				self.GuideStyle1.transform.position = self.targetGameObject.transform.position
			else
				self.Canvas.transform.position = self.GuideStyle1.transform.position
				self.GuideStyle1.transform.localPosition = cfg.topPos or Vector3.zero
				self.GuideStyle2_btn.gameObject:SetActive(true)
				self.GuideStyle2_btn.onClick:AddListener(function ()
			        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			        self:OnClick()
			    end)
			end
			self.targetGameObject = nil

			self:SetStyle(cfg)
		else
			self.targetGameObject = self:getFindObject(cfg.name)
			if IsEquals(self.targetGameObject) then
				self.originalIndex = self.targetGameObject.transform:GetSiblingIndex()
				self.originalParent = self.targetGameObject.transform.parent
				local meshs = self.targetGameObject.gameObject:GetComponentsInChildren(typeof(UnityEngine.MeshRenderer))
				local canvas = self.targetGameObject.gameObject:GetComponentsInChildren(typeof(UnityEngine.Canvas))
				local min_ceng = 10000
				for i = 0, meshs.Length - 1 do
					if min_ceng > meshs[i].sortingOrder then
						min_ceng = meshs[i].sortingOrder
					end
				end
				for i = 0, canvas.Length - 1 do
					if min_ceng > canvas[i].sortingOrder then
						min_ceng = canvas[i].sortingOrder
					end
				end

				local cha = 86 - min_ceng
				self.cha = cha
				for i = 0, meshs.Length - 1 do
					meshs[i].sortingOrder = meshs[i].sortingOrder + cha
				end
				for i = 0, canvas.Length - 1 do
					canvas[i].sortingOrder = canvas[i].sortingOrder + cha
				end
				
				self.targetGameObject.transform:SetParent(self.GuideNode)

				local gpos = self.targetGameObject.transform.position
				local size = self.targetGameObject:GetComponent("RectTransform").sizeDelta
				if IsEquals(self.Canvas) then
					if cfg.headPos then
						self.Canvas.transform.position = Vector3.New(gpos.x + cfg.headPos.x, gpos.y + cfg.headPos.y, gpos.z)
					else
						self.Canvas.transform.position = gpos
					end
				end
				if IsEquals(self.GuideStyle1) then
					if cfg.headPos then
						self.GuideStyle1.transform.position = Vector3.New(gpos.x + cfg.headPos.x, gpos.y + cfg.headPos.y, gpos.z)
					else
						self.GuideStyle1.transform.position = gpos
					end
				end
				
				self:SetStyle(cfg)
				local s = function ()
					
				end
				if cfg.type == "button" then
					self.GuideStyle1.gameObject:SetActive(false)
					local bclick = self.targetGameObject.gameObject:GetComponentsInChildren(typeof(UnityEngine.UI.Button))
					for i = 0, bclick.Length - 1 do
						if self.guide_cfg.code then
							bclick[i].onClick:RemoveAllListeners()
						end
						bclick[i].onClick:AddListener(self.callClick)
					end
					local pclick = self.targetGameObject.gameObject:GetComponentsInChildren(typeof(PolygonClick))
					for i = 0, pclick.Length - 1 do
						if self.guide_cfg.code then
							pclick[i].PointerClick:RemoveAllListeners()
						end
						pclick[i].PointerClick:AddListener(self.callClick2)
					end
				elseif cfg.type == "GuideStyle1" then
					self.GuideStyle1.gameObject:SetActive(true)
					self.TopRect.sizeDelta = size
					self.LeftBG.sizeDelta = {x=3000, y=size.y}
					self.RightBG.sizeDelta = {x=3000, y=size.y}
				else
					print("<color=red>错误的引导类型 type=" .. cfg.type .. "</color>")
					self:HideUI()
				end
			else
				dump(cfg)
				print(debug.traceback())
				self:HideUI()
				print("<color=red>查找失败</color>")
			end
		end
	end)
end

function GuidePanel:SetStyle(cfg)
	if cfg.type == "GuideStyle1" or cfg.type == "GuideStyle2" then
		self.BGImage.gameObject:SetActive(false)
	else
		if cfg.isHideBG then
			self.BGImage.gameObject:SetActive(false)
		else
			self.BGImage.gameObject:SetActive(true)
		end
	end
	if cfg.desc and cfg.desc ~= "" then
		self.BubbleNode.localPosition = cfg.descPos
		self.chat_txt.text = cfg.desc
		self.BubbleNode.gameObject:SetActive(true)
	else
		self.BubbleNode.gameObject:SetActive(false)
	end

	if cfg.descRot then
		self.BubbleNode.transform.localRotation = Quaternion:SetEuler(cfg.descRot.x, cfg.descRot.y, cfg.descRot.z)
		self.chat_txt.transform.localRotation = Quaternion:SetEuler(cfg.descRot.x, cfg.descRot.y, cfg.descRot.z)
	else
		self.BubbleNode.transform.localRotation = Quaternion:SetEuler(0, 0, 0)
		self.chat_txt.transform.localRotation = Quaternion:SetEuler(0, 0, 0)
	end

	if cfg.szPos then
		cfg.szPos.z = 0
		self.SZAnim.localPosition = cfg.szPos
		self.SZAnim.gameObject:SetActive(true)
	else
		self.SZAnim.gameObject:SetActive(false)
	end
	if cfg.npcPos then
		self.NPC.localPosition = cfg.npcPos
		self.NPC.gameObject:SetActive(true)
	else
		self.NPC.gameObject:SetActive(false)
	end
end

--查找name对应的对象
function GuidePanel:getFindObject(name)
	local obj = GameObject.Find(name)
	return obj
end

function GuidePanel:OnClick(obj)
	print("<color=red>引导点击</color>")
	dump(self.guide_cfg)
	if self.guide_cfg and self.guide_cfg.code then
		xpcall(function ()
			loadstring(self.guide_cfg.code)()
		end, function (error)
			dump(error, "<color=red>error</color>")
		end)
	end
	if self.guide_cfg and self.guide_cfg.bsdsmName then
		Event.Brocast("bsds_send_power",{key = self.guide_cfg.bsdsmName})
	end
	self:HideUI()
	GuideLogic.StepFinish()
end
function GuidePanel:OnBackClick()
    GameObject.Destroy(self.gameObject)
end

function GuidePanel:OnSkipClick()
    GuideLogic.GuideSkip()
    self:HideUI()
end

