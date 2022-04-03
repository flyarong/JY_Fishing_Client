-- 创建时间:2018-07-16

local basefunc = require "Game.Common.basefunc"

GameMoneyCenterSharePanel = basefunc.class()
GameMoneyCenterSharePanel.name = "GameMoneyCenterSharePanel"
local PAGE_TBL = {
	"share_1.png", "share_4.png", "share_13.png", "share_14.png"
}

function GameMoneyCenterSharePanel.Create(parent)
	return GameMoneyCenterSharePanel.New(parent)
end

function GameMoneyCenterSharePanel:MyExit()
	self:ClearAll()
	destroy(self.gameObject)
end
function GameMoneyCenterSharePanel:Close()
	self:MyExit()
end

function GameMoneyCenterSharePanel:MyClose()
	self:MyExit()
end

function GameMoneyCenterSharePanel:ctor(parent)

	ExtPanel.ExtMsg(self)

	if parent == nil then
		parent = GameObject.Find("Canvas/LayerLv5").transform
	end
	local obj = newObject(GameMoneyCenterSharePanel.name, parent)
	local tran = obj.transform
	self.gameObject = obj
	self.transform = obj.transform
	LuaHelper.GeneratingVar(self.transform, self)
	self.camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")

	self.page_weights = {}
	self.page_count = math.ceil(#PAGE_TBL / 4)
	if self.page_count > 1 then
		local step = 1 / (self.page_count - 1)
		for idx = 1, self.page_count, 1 do
			self.page_weights[idx] = (idx - 1) * step
		end
	else
		self.page_weights[1] = 0
	end
	self.page_index = 1
	self.dragPosition = 0
	self.select_index = -1

	self.pageList = {}
	--self.dotList = {}

	self:InitRect()
end

function GameMoneyCenterSharePanel:InitRect()
	local transform = self.transform

	self.scrollView = transform:Find("Scroll View"):GetComponent("ScrollRect")
	EventTriggerListener.Get(self.scrollView.gameObject).onBeginDrag = basefunc.handler(self, self.OnBeginDrag)
	EventTriggerListener.Get(self.scrollView.gameObject).onEndDrag = basefunc.handler(self, self.OnEndDrag)

	self.scp_left_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		
		self.page_index = Mathf.Clamp(self.page_index - 1, 1, self.page_count);
		self:UpdatePageButtons()
		self:AnimationScroll(self.page_weights[self.page_index])
		--self.scrollView.horizontalNormalizedPosition = self.page_weights[self.page_index]
	end)
	self.scp_right_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		
		self.page_index = Mathf.Clamp(self.page_index + 1, 1, self.page_count);
		self:UpdatePageButtons()
		self:AnimationScroll(self.page_weights[self.page_index])
		--self.scrollView.horizontalNormalizedPosition = self.page_weights[self.page_index]
	end)

	self.wx_btn.onClick:AddListener(function ()
		self:WeChatShareImage(false)
	end)

	self.pyq_btn.onClick:AddListener(function ()
		self:WeChatShareImage(true)
	end)

	-- 朋友圈链接被屏蔽，暂时关闭朋友圈分享
	self.wx_btn.transform.localPosition = Vector3.New(0, -334, 0)
	self.pyq_btn.gameObject:SetActive(false)

	--[[self.close_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:Close()
	end)]]--

	self:Refresh()

	HandleLoadChannelLua("GameMoneyCenterSharePanel", self)
end

function GameMoneyCenterSharePanel:Refresh()
	self:ClearItemList(self.pageList)
	self.pageList = {}
	
	--self:ClearItemList(self.dotList)
	--self.dotList = {}

	self:FillItemList(PAGE_TBL)
	self:UpdatePageButtons()
end

function GameMoneyCenterSharePanel:ClearItemList(list)
	for k, v in ipairs(list) do
		GameObject.Destroy(v.gameObject)
		list[k] = nil
	end
end

function GameMoneyCenterSharePanel:ClearAll()
	self:ClearItemList(self.pageList)
	self.pageList = {}
	--self:ClearItemList(self.dotList)
	--self.dotList = {}

	self.currentIndex = 0
	self.currentPage = 0
	self.select_index = -1
end

function GameMoneyCenterSharePanel:FillItemList()
	local page_count = #PAGE_TBL

	for idx = 1, page_count, 1 do
		self.pageList[#self.pageList + 1] = self:CreateShareItem(idx)
	end

	--[[for idx = 1, page_count, 1 do
		local btnNode = self:CreateItem(self.dot_list, self.dot_tmpl)
		local image = btnNode.transform:Find("icon"):GetComponent("Image")
		EventTriggerListener.Get(image.gameObject).onClick = function()
			self.page_index = idx
			self:UpdatePageButtons()
			self.scrollView.horizontalNormalizedPosition = self.page_weights[self.page_index]
		end

		self.dotList[#self.dotList + 1] = btnNode
	end]]--
end

function GameMoneyCenterSharePanel:OnBeginDrag()
	local page_count = self.page_count
	if page_count <= 1 then return end

	self.dragPosition = self.scrollView.horizontalNormalizedPosition
end

function GameMoneyCenterSharePanel:OnEndDrag()
	local page_count = self.page_count
	if page_count <= 1 then return end

	local currentPosition = self.scrollView.horizontalNormalizedPosition
	if currentPosition > self.dragPosition then
		currentPosition = currentPosition + 0.1
	else
		currentPosition = currentPosition - 0.1
	end

	local page_index = 1
	local offset = math.abs(self.page_weights[page_index] - currentPosition)
	for idx = 2, page_count, 1 do
		local tmp = math.abs(currentPosition - self.page_weights[idx])
		if tmp < offset then
			page_index = idx
			offset = tmp
		end
	end
	self.page_index = page_index
	self:UpdatePageButtons()
	self:AnimationScroll(self.page_weights[self.page_index])
	--self.scrollView.horizontalNormalizedPosition = self.page_weights[self.page_index]
end

function GameMoneyCenterSharePanel:UpdatePageButtons()
	local page_count = self.page_count
	if page_count <= 1 then
		self.scp_left_btn.gameObject:SetActive(false)
		self.scp_right_btn.gameObject:SetActive(false)

		--[[for _, v in ipairs(self.dotList) do
			v.gameObject:SetActive(false)
		end]]--
	else
		self.scp_left_btn.gameObject:SetActive(true)
		self.scp_right_btn.gameObject:SetActive(true)
		if self.page_index <= 1 then
			self.scp_left_btn.gameObject:SetActive(false)
        end
		if self.page_index >= page_count then
			self.scp_right_btn.gameObject:SetActive(false)
		end

		--[[for k, v in ipairs(self.dotList) do
			local image = v.transform:Find("icon"):GetComponent("Image")
			if k == self.page_index then
				image.color = Color.white
			else
				image.color = Color.New(1, 1, 1, 0.3)
			end
		end]]--
	end
end

function GameMoneyCenterSharePanel:AnimationScroll(dst)
	if not IsEquals(self.scrollView) then return end

	local callbacks = {}

	local CNT = 5
	local current = self.scrollView.horizontalNormalizedPosition
	local step = (dst - current) / CNT

	for idx = 1, CNT, 1 do
		callbacks[idx] = {}
		callbacks[idx].stamp = 0.03
		callbacks[idx].method = function()
			if IsEquals(self.scrollView) then
				self.scrollView.horizontalNormalizedPosition = current + step * idx
			end
		end
	end

	ShatterGoldenEggLogic.TweenDelay(callbacks, function()
		if IsEquals(self.scrollView) then
			self.scrollView.horizontalNormalizedPosition = dst
		end
	end)
end

function GameMoneyCenterSharePanel:CreateShareItem(index)
	local go = self:CreateItem(self.scp_list, self.share_tmpl)
	local go_table = {}
	LuaHelper.GeneratingVar(go.transform, go_table)
	go_table.share_img.sprite = GetTexture(PAGE_TBL[index])
	local share_parm = {}
	share_parm.share_type = "tgfx_" .. index
	MainModel.GetShareUrl(function(data)
		self.url = data.share_url
		self:EWM(go_table.EWM_img.mainTexture,ewmTools.getEwmDataWithPixel(self.url, ShareLogic.size))
	end,share_parm)
	--URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, go_table.head_img)
	PointerEventListener.Get(go_table.share_img.gameObject).onUp = function()
		self:SetFocus(index)
	end
	return go
end

function GameMoneyCenterSharePanel:CreateItem(parent, tmpl)
	local obj = GameObject.Instantiate(tmpl)
	obj.transform:SetParent(parent)
	obj.transform.localPosition = Vector3.zero
	obj.transform.localScale = Vector3.one
	obj.transform:SetAsLastSibling()
	obj.gameObject:SetActive(true)
	return obj
end

function GameMoneyCenterSharePanel:SetFocus(index)
	local selected_img = nil
	for i = 1, #PAGE_TBL do
		selected_img = self.pageList[i].transform:Find("selected_img")
		if i == index then
			selected_img.gameObject:SetActive(true)
		else
			selected_img.gameObject:SetActive(false)
		end
	end
	self.select_index = index
end

function GameMoneyCenterSharePanel:GetImagePath()
	return ShareLogic.GetImagePath()
end

function GameMoneyCenterSharePanel:WeChatShareImage(isCircleOfFriends)
	local select_index = self.select_index
	if select_index <= 0 then
		select_index = math.random(1, #PAGE_TBL)
		self:SetFocus(select_index)
	end
	local image_name = PAGE_TBL[select_index]
	local select_node = self.pageList[select_index]
	if not IsEquals(select_node) then
		print("GameMoneyCenterSharePanel:WeChatShareImage not ready!")
		return
	end

	if true then
		local sendcall = function (shareLink)
			ShareLogic.ShareGM(shareLink, function (str)
				if str == "OK" then
					if self.finishcall then
						self.finishcall()
					end
				end
			end)
		end

		local share_parm = {
			share_type = "tgfx_" .. select_index
		}
		if isCircleOfFriends then 
			share_parm = {
				share_type = "ljwdtgm" .. select_index
			}
		end 
		MainModel.GetShareUrl(function(data)
			if data.result ~= 0 then
				HintPanel.ErrorMsg(data.result)
				return
			end

			local name = MainModel.UserInfo.name
			local url = data.share_url
			local img_path = self:GetImagePath()

			local shareLink = ""
			if isCircleOfFriends then
				shareLink = string.format(share_link_config.share_link[3].link[1], url, "true")
				sendcall(shareLink)
			else
				shareLink = string.format(share_link_config.share_link[4].link[1], img_path, "false")
				local SI = ShareImage.Create(share_parm.shareType, {name = name, url = url, image = image_name})
				SI:MakeImage(img_path, function ()
					sendcall(shareLink)
				end)
			end
		end, share_parm)

		return
	end


	local share_parm = {}
	share_parm.share_type = "tgfx_" .. select_index
	MainModel.GetShareUrl(function(_data)
		dump(_data, "<color=red>分享数据</color>")
		if _data.result == 0 then
			local strOff
			if isCircleOfFriends then
				strOff = "true"
			else
				strOff = "false"
			end
			local sendcall = function ()
				-- 分享链接
                local shareLink
                if isCircleOfFriends then
                    shareLink = string.format(share_link_config.share_link[3].link[1] ,url,strOff)
                else
                    shareLink = string.format(share_link_config.share_link[4].link[1] ,self:GetImagePath(),strOff )
                end

				ShareLogic.ShareGM(shareLink, function (str)
					print("<color=red>分享完成....str = " .. str .. "</color>")
					if str == "OK" then
						if self.finishcall then
							self.finishcall()
						end
						if self.shareType == "hall" then
							if isCircleOfFriends then
								MainModel.SendShareFinish("shared_pyq")
							else
								MainModel.SendShareFinish("shared_hy")
							end
						end
					end
				end)
			end
			if isCircleOfFriends then
				sendcall()
			else
				self:RunMake(select_node, sendcall)
			end
		else
			HintPanel.ErrorMsg(_data.result)
		end
	end, share_parm)
end

function GameMoneyCenterSharePanel:RunMake(select_node, sendcall)
    if not IsEquals(select_node) then return end

    local node1 = select_node.transform:Find("@share_img/node1")
    local node2 = select_node.transform:Find("@share_img/node2")
    local pos1 = node1.position
    local pos2 = node2.position
    local s1 = self.camera:WorldToScreenPoint(pos1)
    local s2 = self.camera:WorldToScreenPoint(pos2)
    local x = s1.x
    local y = s1.y
    local w = s2.x - s1.x
	local h = s2.y - s1.y
	Event.Brocast("ui_share_begin")
	local canvas = AddCanvasAndSetSort(self.gameObject, 100)
	panelMgr:MakeCameraImgAsync(x, y, w, h, self:GetImagePath(), function ()
		Destroy(canvas)
		--self:Close()
		Event.Brocast("ui_share_end")
		print("<color=white>退出</color>")
        if self.call then
            self.call()
		end
		if sendcall and type(sendcall) == "function" then
			sendcall()
		end
    end,false, GameGlobalOnOff.OpenInstall)
end

function GameMoneyCenterSharePanel:EWM(texture, data)    
    if not texture or not data then
        return
    end
    local w = data.width
    local scale = math.floor(ShareLogic.size/w)
    local py = (ShareLogic.size-w*scale)/2
    py = math.floor(py)
    print(py .. " " .. w .. " " .. scale)
    local dots = data.data
    for i = 1, w do
        for j = 1, w do
            if dots[(i-1)*w + j] == 1 then
                texture:SetPixel(i-1+py, j-1+py, Color.New(0,0,0,1))
            else
                texture:SetPixel(i-1+py, j-1+py, Color.New(1,1,1,1))
            end
        end
    end
    texture:Apply()
end