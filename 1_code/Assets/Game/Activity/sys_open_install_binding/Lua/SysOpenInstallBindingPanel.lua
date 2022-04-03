-- 创建时间:2018-11-08
local basefunc = require "Game.Common.basefunc"

SysOpenInstallBindingPanel = basefunc.class()

SysOpenInstallBindingPanel.name = "SysOpenInstallBindingPanel"

local instance
function SysOpenInstallBindingPanel.Create(parent, parm)
    SysOpenInstallBindingPanel.Exit()
    instance = SysOpenInstallBindingPanel.New(parent, parm)
    return instance
end
function SysOpenInstallBindingPanel.Exit()
    if instance then
        instance:MyExit()
    end
    instance = nil
end

function SysOpenInstallBindingPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function SysOpenInstallBindingPanel:MakeLister()
    self.lister = {}
    self.lister["model_register_by_introducer_response"] = basefunc.handler(self, self.register_by_introducer_response)
    self.lister["update_player_name_response"] = basefunc.handler(self, self.update_player_name_response)
    self.lister["set_head_image_response"] = basefunc.handler(self, self.set_head_image_response)
end

function SysOpenInstallBindingPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function SysOpenInstallBindingPanel:ctor(parent, parm)
    self.parm = parm
    ExtPanel.ExtMsg(self)
    if self.parm.goto_scene_parm =="player_info" then
        parent = GameObject.Find("HallPlayerInfoPanel").transform
    elseif self.parm.goto_scene_parm =="share" then
        parent = GameObject.Find("GameMoneyCenterSharePanel").transform
    end
    local obj = newObject(SysOpenInstallBindingPanel.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
end

--初始化UI
function SysOpenInstallBindingPanel:InitUI()
    if self.parm.goto_scene_parm == "player_info" then
        self:OpenInstallInitHall()
    elseif self.parm.goto_scene_parm == "share" then
        self:OpenInstallInitShare()
    end
end

function SysOpenInstallBindingPanel:MyClose()
	self:MyExit()
end

function SysOpenInstallBindingPanel:MyExit()
    PersonalInfo.Exit()
    self:RemoveListener()
    destroy(self.gameObject)
end

function SysOpenInstallBindingPanel:OpenInstallInitShare(  )
    if not MainModel.UserInfo then return end
    self:ChangeSharePanel()
	self.wdtgm.gameObject:SetActive(true)
	self.wdtgm_txt.text = "我的推广码：" .. MainModel.UserInfo.user_id
	self.wdtgm_copy_btn.onClick:AddListener(function()
		LittleTips.Create("已复制")
    	UniClipboard.SetText(MainModel.UserInfo.user_id)
	end)
	self.wdtgm_help_btn.onClick:AddListener(function()
		LittleTips.Create("点击头像进入个人中心可查看我的推荐人")
	end)
end

function SysOpenInstallBindingPanel:ChangeSharePanel()
    local gmcsp = GameObject.Find("GameMoneyCenterSharePanel")
    if not gmcsp then return end
    local txt = gmcsp.transform:Find("BG/Text"):GetComponent("Text")
    txt.text = "选择模板生成自己的专属推广海报"
    local rt = txt:GetComponent("RectTransform")
    rt.anchoredPosition = Vector2.New(0,403)
    rt.sizeDelta = Vector2.New(810,45)
    local sv = gmcsp.transform:Find("Scroll View")
    local rt = sv:GetComponent("RectTransform")
    rt.anchoredPosition = Vector2.New(0,0)
    rt.sizeDelta = Vector2.New(1364,557)
    local lb = gmcsp.transform:Find("@scp_left_btn")
    local rt = lb:GetComponent("RectTransform")
    rt.anchoredPosition = Vector2.New(-710,0)
    local rb = gmcsp.transform:Find("@scp_right_btn")
    local rt = rb:GetComponent("RectTransform")
    rt.anchoredPosition = Vector2.New(710,0)
    local wxb = gmcsp.transform:Find("@wx_btn")
    local rt = wxb:GetComponent("RectTransform")
    rt.anchoredPosition = Vector2.New(0,-408)
    local pyqb = gmcsp.transform:Find("@pyq_btn")
    local rt = pyqb:GetComponent("RectTransform")
    rt.anchoredPosition = Vector2.New(314,-408)
end

function SysOpenInstallBindingPanel:ChangeHallPlayerInfoPanel()
    local hpip = GameObject.Find("HallPlayerInfoPanel")
    local player_head_img = hpip.transform:Find("ImgCenter/@player_head_img")
    EventTriggerListener.Get(player_head_img.gameObject).onClick = basefunc.handler(self, self.ChangeHeadIcon)
    local player_name_txt = hpip.transform:Find("ImgCenter/ImgHeadBG/@player_name_txt"):GetComponent("Text")
    player_name_txt.fontSize = 35
    local rt = player_name_txt:GetComponent("RectTransform")
    rt.anchoredPosition = Vector2.New(250,70)
    rt.sizeDelta = Vector2.New(278,47)
    local player_id_txt = hpip.transform:Find("ImgCenter/ImgHeadBG/@player_id_txt"):GetComponent("Text")
    player_id_txt.fontSize = 35
    rt = player_id_txt:GetComponent("RectTransform")
    rt.anchoredPosition = Vector2.New(338,19)
    rt.sizeDelta = Vector2.New(330,64)
    local Text = hpip.transform:Find("ImgCenter/ImgHeadBG/Text"):GetComponent("Text")
    Text.fontSize = 35
    rt = Text:GetComponent("RectTransform")
    rt.anchoredPosition = Vector2.New(140,19)
    rt.sizeDelta = Vector2.New(66,53)
end

function SysOpenInstallBindingPanel:OpenInstallInitHall()
    if not MainModel.UserInfo then return end
    self:ChangeHallPlayerInfoPanel()

    self.change_name_btn.onClick:AddListener(function ()
        --修改昵称
        self:ChangeName()
    end)
    self.yqm_btn.onClick:AddListener(function ()
        --修改邀请码
        local input_str = self.input_id_txt.text
        if input_str == "" then
            LittleTips.Create("请输入邀请码")
            return
        end
        Network.SendRequest("register_by_introducer", {parent_id = tostring(input_str)}, "请求数据")
    end)
    -- self.yqm_ipf.onValidateInput = function (text, charIndex, addedChar)
    --     local str = text
    --     -- if utf8.len(str) == 11 then
    --     --     LittleTips.Create("输入的ID不可超过11位数")
    --     -- end
    --     return addedChar
    -- end
    

    self:OpenInstallRefresh()
end

function SysOpenInstallBindingPanel:OpenInstallRefresh()
    if not IsEquals(self.gameObject) then return end
    if not MainModel.UserInfo then 
        self.yqm_node.gameObject:SetActive(false)
        self.wdtjr_txt.gameObject:SetActive(false)
        self.change_name_btn.gameObject:SetActive(false)
        self.change_name_btn.gameObject:SetActive(false)
        return 
    end
    self.change_name_btn.gameObject:SetActive(true)
    
    if MainModel.GetMarketChannel() == "normal" or MainModel.GetMarketChannel() == "wqp" then
        --官方渠道
        if MainModel.UserInfo.parent_id then
            --有推荐人
            self.wdtjr_txt.text = "我的推荐人：" .. MainModel.UserInfo.parent_id
            self.wdtjr_txt.gameObject:SetActive(true)
            self.yqm_node.gameObject:SetActive(false)
        else
            --没有推荐人
            if tonumber(MainModel.UserInfo.register_time) and os.time() - tonumber(MainModel.UserInfo.register_time) > 7 * 86400 or MainModel.GetNewPlayer() == PLAYER_TYPE.PT_Old then
                --注册时间超过七天，不是新用户玩家
                self.wdtjr_txt.text = "我的推荐人：无"
                self.wdtjr_txt.gameObject:SetActive(true)
                self.yqm_node.gameObject:SetActive(false)
            else
                self.wdtjr_txt.gameObject:SetActive(false)
                self.yqm_node.gameObject:SetActive(true)
            end
        end
    else
        self.wdtjr_txt.text = "我的推荐人：无"
        self.wdtjr_txt.gameObject:SetActive(true)
        self.yqm_node.gameObject:SetActive(false)
    end
end

function SysOpenInstallBindingPanel:ChangeName()
    ChangeNamePanel.Create()
end

function SysOpenInstallBindingPanel:ChangeHeadIcon()
    ChangeHeadIconPanel.Create()
end

function SysOpenInstallBindingPanel:register_by_introducer_response()
    dump(nil,"<color=white>register_by_introducer_response</color>")
    self:OpenInstallRefresh()
end

function SysOpenInstallBindingPanel:update_player_name_response(_,data)
    dump(data,"<color=white>update_player_name_response</color>")
    if not data then return end
    if data.result ~= 0 then
        if data.result == 6301 or data.result == 6302 or data.result == 6303 or data.result == 6308 then
            LittleTips.Create(errorCode[data.result])
            return
        end
        HintPanel.ErrorMsg(data.result)
        return
    end
    MainModel.UserInfo.name = data.name
    if not  MainModel.UserInfo.udpate_name_num then  MainModel.UserInfo.udpate_name_num = 0 end
    MainModel.UserInfo.udpate_name_num =  MainModel.UserInfo.udpate_name_num + 1
    Event.Brocast("set_player_name")
end

function SysOpenInstallBindingPanel:set_head_image_response(_,data)
    dump(data,"<color=white>set_head_image_response</color>")
    if not data then return end
    if data.result ~= 0 then
        if data.result == 6306 or data.result == 6307 then
            LittleTips.Create(errorCode[data.result])
            return
        end
        HintPanel.ErrorMsg(data.result)
        return
    end
    MainModel.UserInfo.img_type = data.img_type
    MainModel.UserInfo.head_image = OpenInstallBindingManager.GetHeadImage()
    Event.Brocast("set_head_image")
end