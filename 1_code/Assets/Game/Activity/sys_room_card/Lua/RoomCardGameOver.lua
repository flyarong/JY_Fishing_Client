-- 创建时间:2018-06-06

local basefunc = require "Game.Common.basefunc"

RoomCardGameOver = basefunc.class()

RoomCardGameOver.name = "RoomCardGameOver"

local instance
function RoomCardGameOver.Create(parent, gameover_info, playerInfo, game_type,room_owner, confirmCallback)
    if not instance then
        instance = RoomCardGameOver.New(parent, gameover_info, playerInfo, game_type,room_owner, confirmCallback)
    end
    return instance
end
-- 关闭
function RoomCardGameOver.Close()
    if instance then
        instance:RemoveListener()
        instance.confirmCallback = nil
        instance.gameover_info = nil
		instance.playerInfo = nil
		instance.game_type = nil
		instance.room_owner = nil
        GameObject.Destroy(instance.transform.gameObject)
        instance = nil
    end
end
function RoomCardGameOver:MakeLister()
    self.lister = {}
end
function RoomCardGameOver:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end
function RoomCardGameOver:ctor(parent, gameover_info, playerInfo, game_type,room_owner, confirmCallback)
    parent = GameObject.Find("Canvas/LayerLv3").transform
    self.confirmCallback = confirmCallback
    self.gameover_info = gameover_info
    self.playerInfo = playerInfo
	self.game_type = game_type
	self.room_owner = room_owner
    self:MakeLister()
    local obj = newObject(RoomCardGameOver.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj

    self.node1 = tran:Find("node1")
    self.node2 = tran:Find("node2")
    self.camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")
    LuaHelper.GeneratingVar(obj.transform, self)
    self.BackButton_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if self.confirmCallback then
                self.confirmCallback()
            end
            self:OnBackClick()
        end
    )
    self.share_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:OnShareClick()
        end
    )
    self.LogoImage = tran:Find("LogoImage")
    self.EWMImage = tran:Find("EWMImage"):GetComponent("Image")
    self.LogoImage.gameObject:SetActive(false)
    self.EWMImage.gameObject:SetActive(false)
    self.size = ShareLogic.size
    MainModel.GetShareUrl(
        function(_data)
            if _data.result == 0 then
                self.url = _data.share_url
                self:UpdateUI()
            else
                HintPanel.ErrorMsg(_data.result)
            end
        end
    )
    self:InitRect()
end
function RoomCardGameOver:UpdateUI()
    self:EWM(self.EWMImage.mainTexture, ewmTools.getEwmDataWithPixel(self.url, self.size))
end
function RoomCardGameOver:InitRect()
    local gameover_info = self.gameover_info -- MjXzFKModel.data.gameover_info
	local player_info = self.playerInfo -- MjXzFKModel.data.playerInfo
    if gameover_info and player_info then
        --数据转换
        local data = {}
        for i, v in ipairs(player_info) do
            --总分数
            local grade = 0
            for k, v_g in ipairs(gameover_info) do
                if v_g.grades[v.base.seat_num] then
                    grade = grade + v_g.grades[v.base.seat_num]
                end
            end
            v.grades = grade or 0
            if self.game_type == "DDZ" then
                --斗地主统计
                local ddz_nor_settle_info = {}
                local bomb_count = 0
                local dizhu_count = 0
                local chuntian_count = 0
                for k, v_g in ipairs(gameover_info) do
                    if v_g.ddz_nor_statistics then
                        if v_g.ddz_nor_statistics.bomb_count[v.base.seat_num] then
                            bomb_count = bomb_count + v_g.ddz_nor_statistics.bomb_count[v.base.seat_num]
                        end
                        if v_g.ddz_nor_statistics.dizhu_count[v.base.seat_num] then
                            dizhu_count = dizhu_count + v_g.ddz_nor_statistics.dizhu_count[v.base.seat_num]
                        end
                        if v_g.ddz_nor_statistics.chuntian_count[v.base.seat_num] then
                            chuntian_count = chuntian_count + v_g.ddz_nor_statistics.chuntian_count[v.base.seat_num]
                        end
                    end
                end
                ddz_nor_settle_info.bomb_count = bomb_count
                ddz_nor_settle_info.dizhu_count = dizhu_count
                ddz_nor_settle_info.chuntian_count = chuntian_count
                v.ddz_nor_settle_info = ddz_nor_settle_info
            elseif self.game_type == "MJ" then
                --麻将统计
                local mj_xzdd_settle_info = {}
                local zi_mo_count = 0
                local jie_pao_count = 0
                local dian_pao_count = 0
                local an_gang_count = 0
                local ming_gang_count = 0
                local cha_da_jiao_count = 0
                for k, v_g in ipairs(gameover_info) do
                    if v_g.mj_xzdd_statistics then
                        if v_g.mj_xzdd_statistics.zi_mo_count[v.base.seat_num] then
                            zi_mo_count = zi_mo_count + v_g.mj_xzdd_statistics.zi_mo_count[v.base.seat_num]
                        end
                        if v_g.mj_xzdd_statistics.jie_pao_count[v.base.seat_num] then
                            jie_pao_count = jie_pao_count + v_g.mj_xzdd_statistics.jie_pao_count[v.base.seat_num]
                        end
                        if v_g.mj_xzdd_statistics.dian_pao_count[v.base.seat_num] then
                            dian_pao_count = dian_pao_count + v_g.mj_xzdd_statistics.dian_pao_count[v.base.seat_num]
                        end
                        if v_g.mj_xzdd_statistics.an_gang_count[v.base.seat_num] then
                            an_gang_count = an_gang_count + v_g.mj_xzdd_statistics.an_gang_count[v.base.seat_num]
                        end
                        if v_g.mj_xzdd_statistics.ming_gang_count[v.base.seat_num] then
                            ming_gang_count = ming_gang_count + v_g.mj_xzdd_statistics.ming_gang_count[v.base.seat_num]
                        end
                        if v_g.mj_xzdd_statistics.cha_da_jiao_count[v.base.seat_num] then
                            cha_da_jiao_count = cha_da_jiao_count + v_g.mj_xzdd_statistics.cha_da_jiao_count[v.base.seat_num]
                        end
                    end
                end
                mj_xzdd_settle_info.zi_mo_count = zi_mo_count
                mj_xzdd_settle_info.jie_pao_count = jie_pao_count
                mj_xzdd_settle_info.dian_pao_count = dian_pao_count
                mj_xzdd_settle_info.an_gang_count = an_gang_count
                mj_xzdd_settle_info.ming_gang_count = ming_gang_count
                mj_xzdd_settle_info.cha_da_jiao_count = cha_da_jiao_count
                v.mj_xzdd_settle_info = mj_xzdd_settle_info
            end
        end
        data.player_infos = player_info

        local max_score = nil

        for k, v_palyer in ipairs(data.player_infos) do
            if not max_score then
                max_score = v_palyer.grades
            end
            if v_palyer.grades > max_score then
                max_score = v_palyer.grades
            end
        end

        for k, v_palyer in ipairs(data.player_infos) do
            local playerGO = self.transform:Find("Genter/Players/Player" .. k).gameObject
            local playerGOTable = {}
            LuaHelper.GeneratingVar(playerGO.transform, playerGOTable)
            URLImageManager.UpdateHeadImage(v_palyer.base.head_link, playerGOTable.head_img)
            playerGOTable.name_txt.text = v_palyer.base.name
            playerGOTable.id_txt.text = v_palyer.base.id
            local is_me = v_palyer.base.id == MainModel.UserInfo.user_id
            playerGOTable.me_img.gameObject:SetActive(is_me)
            playerGOTable.other_img.gameObject:SetActive(not is_me)

            local is_win = v_palyer.grades == max_score and v_palyer.grades > 0
            playerGOTable.win_score_txt.text = v_palyer.grades
            playerGOTable.score_txt.text = v_palyer.grades
            playerGOTable.win_score_txt.gameObject:SetActive(is_win)
            playerGOTable.win_img.gameObject:SetActive(is_win)
            playerGOTable.score_txt.gameObject:SetActive(not is_win)

            -- 房主
			if v_palyer.base.id == self.room_owner then
				playerGOTable.fang_img.gameObject:SetActive(true)		
			else
				playerGOTable.fang_img.gameObject:SetActive(false)
			end

            local DescNode = playerGO.transform:Find("DescNode")
			local DescCell = playerGO.transform:Find("DescNode/DescCell")
            self:CreateDesc(DescNode, DescCell, v_palyer,playerGOTable)

            playerGO.gameObject:SetActive(true)
        end
    else
        HintPanel.Create(1, "总结算数据异常")
    end

    self:OnOff()
end
function RoomCardGameOver:CreateDesc(node, cell, data,playerGOTable)
	if data.ddz_nor_settle_info then
		for k,v in pairs(data.ddz_nor_settle_info) do
			if k == "bomb_count" then
				playerGOTable.zd_num_txt.text = v
			elseif k == "dizhu_count" then
				playerGOTable.dz_num_txt.text = v
			elseif k == "chuntian_count" then
				playerGOTable.ct_num_txt.text = v
			end
		end
		playerGOTable.DDZDescNode.gameObject:SetActive(true)
	elseif data.mj_xzdd_settle_info then
		for k,v in pairs(data.mj_xzdd_settle_info) do
			if k == "zi_mo_count" then
				playerGOTable.zm_num_txt.text = v
			elseif k == "jie_pao_count" then
				playerGOTable.jp_num_txt.text = v
			elseif k == "dian_pao_count" then
				playerGOTable.dp_num_txt.text = v
			elseif k == "an_gang_count" then
				playerGOTable.ag_num_txt.text = v
			elseif k == "ming_gang_count" then
				playerGOTable.mg_num_txt.text = v
			elseif k == "cha_da_jiao_count" then
				playerGOTable.cdj_num_txt.text = v
			end
		end
		playerGOTable.MJDescNode.gameObject:SetActive(true)
	end
end

function RoomCardGameOver:OnOff()
    if GameGlobalOnOff.ShowOff then
        self.share_btn.gameObject:SetActive(true)
    else
        self.share_btn.gameObject:SetActive(false)
    end
end

function RoomCardGameOver:MyExit()
end

-- 分享战绩
function RoomCardGameOver:OnShareClick()
    self:WeChatShareImage(false)
end

-- 返回
function RoomCardGameOver:OnBackClick()
    RoomCardGameOver.Close()
    MainLogic.ExitGame()
    MainLogic.GotoScene("game_Hall")
end
function RoomCardGameOver:ShowBack(b)
    self.LogoImage.gameObject:SetActive(not b)
    self.EWMImage.gameObject:SetActive(not b)

    self.share_btn.gameObject:SetActive(b)
    self.BackButton_btn.gameObject:SetActive(b)
end

function RoomCardGameOver:WeChatShareImage(isCircleOfFriends)
    local strOff
    if isCircleOfFriends then
        strOff = "true"
    else
        strOff = "false"
    end

    local imageName = ShareLogic.GetImagePath()

    local sendcall =
        function()
        -- 分享链接
        local shareLink = string.format(share_link_config.share_link[4].link[1] ,imageName,strOff )
        -- local shareLink = '{"type": 7, "imgFile": "' .. imageName .. '", "isCircleOfFriends": ' .. strOff .. "}"
        ShareLogic.ShareGM(
            shareLink,
            function(str)
                print("<color=red>分享完成....str = " .. str .. "</color>")
                if str == "OK" then
                    if self.finishcall then
                        self.finishcall()
                    end
                end
            end
        )
    end

    self:ShowBack(false)
    Event.Brocast("ui_share_begin")
    local pos1 = self.node1.position
    local pos2 = self.node2.position
    local s1 = self.camera:WorldToScreenPoint(pos1)
    local s2 = self.camera:WorldToScreenPoint(pos2)
    local x = s1.x
    local y = s1.y
    local w = s2.x - s1.x
    local h = s2.y - s1.y
    local canvas = AddCanvasAndSetSort(self.gameObject, 100)
    panelMgr:MakeCameraImgAsync(x, y, w, h, imageName, function ()
        print("<color=red>部分截图完成</color>")
        Destroy(canvas)
        self:ShowBack(true)
        Event.Brocast("ui_share_end")
        sendcall()
    end,false, GameGlobalOnOff.OpenInstall)
end

function RoomCardGameOver:EWM(texture, data)
    if not texture or not data then
        return
    end
    local w = data.width
    local scale = math.floor(self.size / w)
    local py = (self.size - w * scale) / 2
    py = math.floor(py)
    print(py .. " " .. w .. " " .. scale)
    local dots = data.data
    for i = 1, w do
        for j = 1, w do
            if dots[(i - 1) * w + j] == 1 then
                texture:SetPixel(i - 1 + py, j - 1 + py, Color.New(0, 0, 0, 1))
            else
                texture:SetPixel(i - 1 + py, j - 1 + py, Color.New(1, 1, 1, 1))
            end
        end
    end
    texture:Apply()
end
