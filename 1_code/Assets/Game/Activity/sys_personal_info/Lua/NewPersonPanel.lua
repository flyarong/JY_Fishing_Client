-- 个人中心
local basefunc = require "Game.Common.basefunc"

NewPersonPanel = basefunc.class()

NewPersonPanel.name = "NewPersonPanel"


local instance
function NewPersonPanel.Create(parm)
    if instance then
        return instance
    end
    instance = NewPersonPanel.New(parm)
    return instance
end
function NewPersonPanel.Exit()
    if instance then
        instance:MyExit()
    end
end

function NewPersonPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function NewPersonPanel:MakeLister()
    self.lister = {}
   -- self.lister["AssetChange"] = basefunc.handler(self, self.RefreshMoney)
    self.lister["update_verifide"] = basefunc.handler(self, self.UpdateVerifide)
    self.lister["update_query_bind_phone"] = basefunc.handler(self, self.UpdateBindPhone)

    self.lister["SYSChangeHeadAndNameManager_Change_Name_Success_msg"] = basefunc.handler(self,self.on_SYSChangeHeadAndNameManager_Change_Name_Success_msg)
    self.lister["SYSChangeHeadAndNameManager_Change_Head_Success_msg"] = basefunc.handler(self,self.on_SYSChangeHeadAndNameManager_Change_Head_Success_msg)
    --绑定上级
    self.lister["SYSTGXT_bind_up_person_msg"] = basefunc.handler(self, self.on_SYSTGXT_bind_up_person_msg)
end

function NewPersonPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function NewPersonPanel:ctor(parm)

   

	ExtPanel.ExtMsg(self)

    self.parm = parm
    local parent = GameObject.Find("Canvas/LayerLv3").transform
    local obj = newObject(NewPersonPanel.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

    self:MakeLister()
    self:AddMsgListener()
    self.BackButton = tran:Find("BackButton"):GetComponent("Button")

    self.BackButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnBackClick()
    end)

    --self.CenterRect = tran:Find("CenterRect").transform
--------------------------------------------------
    --DOTweenManager.OpenPopupUIAnim(self.transform)
    self:InitUI()

    EventTriggerListener.Get(self.certified_btn.gameObject).onClick = basefunc.handler(self, self.OnClickCertified)
    EventTriggerListener.Get(self.binding_btn.gameObject).onClick = basefunc.handler(self, self.OnClickBindingPhone)
    EventTriggerListener.Get(self.change_binding_btn.gameObject).onClick = basefunc.handler(self, self.OnClickBindingPhone)
   -- self:RefreshMoney()

    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="drt_block_binding_phone_num", is_on_hint = true}, "CheckCondition")
    local bindphone = (not a or (a and not b)) and GameGlobalOnOff.BindingPhone
    self.Binding.gameObject:SetActive(bindphone)
    local Certified = tran:Find("Certified")
    if IsEquals(Certified) then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="drt_block_real_name_verify", is_on_hint = true}, "CheckCondition")
        if (a and b) or not GameGlobalOnOff.Certification then
            Certified.gameObject:SetActive(false)
        end
    end

    if gameMgr:getMarketChannel() == "hw_cymj" then
        local position = self.certified_btn.transform.position
        self.binding_btn.transform.position = position
        self.change_binding_btn.transform.position = position
	self.certified_btn.gameObject:SetActive(false)
    end

   local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="drt_block_binding_phone_num", is_on_hint = true}, "CheckCondition")
    if (not a or (a and not b)) and GameGlobalOnOff.BindingPhone and parm and parm.open_award then
        if not MainModel.UserInfo.phoneData or not MainModel.UserInfo.phoneData.phone_no then
            print("<color=red>？？？？？？22222</color>")
            GameManager.GotoUI({gotoui = "sys_binding_phone",goto_scene_parm = "panel"})
        end
    end
-----------------------------------------------------------------
    
-----------------------------------------------------------------👇
--创建修改昵称和设置头像的按钮
    Event.Brocast("NewPersonPanel_to_SYSChangeHeadAndNameManager_msg",{head_node = self.SYSChangeHead_node.transform, name_node = self.SYSChangeName_node.transform})

    --告诉推广的消息
    --Event.Brocast("Create_tgxt_info_msg",{head_node = self.bd_node.transform})
     Event.Brocast("global_game_panel_open_msg", {ui="NewPersonPanel"})
-----------------------------------------------------------------👆

    self.head_pre = CommonHeadInstancePrafab.Create({type = 1,
                                    parent = self.player_head_img.transform,
                                    scale = 2.14, 
                                    style = 3,
                                    })
    
end

--初始化UI
function NewPersonPanel:InitUI()
    self:OnZLClick()
    self.player_name_txt.text = MainModel.UserInfo.name
    self.player_id_txt.text = MainModel.UserInfo.user_id

    URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.player_head_img)
   -- PersonalInfoManager.SetHeadFarme(self.player_headframe_img)

    self:UpdateVerifide()
    self:UpdateBindPhone()
   -- self:CreateItemPrefab()

    self.shop_txt.text = StringHelper.ToRedNum(MainModel.GetHBValue())
    self.gold_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
 
    self.by_lvl_pre = GameManager.GotoUI({gotoui = "sys_by_level",goto_scene_parm = "panel", parent=self.by_lvl_node})
    self.bott_trasform_node = GameManager.GotoUI({gotoui = "sys_by_bag", goto_scene_parm="panel2",parent=self.Bottom_node})
    self.right_trasfotm_node=GameManager.GotoUI({gotoui = "sys_by_bag", goto_scene_parm="panel3",parent=self.Right_node})
   

end
function NewPersonPanel:MyExit()
    if self.head_pre then
        self.head_pre:MyExit()
        self.head_pre = nil
    end
    if self.cur_panel then
        self.cur_panel.instance:MyClose()
        self.cur_panel = nil
    end
    Event.Brocast("global_game_panel_close_msg", {ui="NewPersonPanel"})

   -- self:CloseItemPrefab()
    self:RemoveListener()
    destroy(self.gameObject)
    instance = nil
end

function NewPersonPanel:ChangePanel(panelName)
    if self.cur_panel then
        if self.cur_panel.name == panelName then
            self.cur_panel.instance:MyRefresh()
        else
            self.cur_panel.instance:MyClose()
            self.cur_panel = nil
        end
    end
    if not self.cur_panel then
        if panelName == panelNameMap.hallplayer then
            self.cur_panel = {name = panelName, instance = HallPlayerInfoPanel.Create(self.CenterRect, self.parm)}
        else
            dump(panelName, "<color=red>没有这个Panel</color>")
        end
    end
    self.parm = nil
end

-- 返回
function NewPersonPanel:OnBackClick(go)
    Event.Brocast("NewPersonPanel_OnBackClik_msg")
    self:MyExit()
end

-- 资料
function NewPersonPanel:OnZLClick(go)
   -- self:ChangePanel(panelNameMap.hallplayer)
end


function NewPersonPanel:UpdateVerifide()
    if not IsEquals(self.certified_btn) then
        return
    end
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="drt_block_real_name_verify", is_on_hint = true}, "CheckCondition")
    if (a and b) or not GameGlobalOnOff.Certification then
        self.certified_btn.gameObject:SetActive(false)
        return
    end

    if MainModel.UserInfo.verifyData and MainModel.UserInfo.verifyData.status then
        local status = MainModel.UserInfo.verifyData.status == 4
        if IsEquals(self.certified_btn) then
            self.certified_btn.gameObject:SetActive(not status)
        end
        if IsEquals(self.certified_end_img) then
            self.certified_end_img.gameObject:SetActive(status)
        end
    else
        local status = false
        if IsEquals(self.certified_btn) then
            self.certified_btn.gameObject:SetActive(not status)
        end
        if IsEquals(self.certified_end_img) then
            self.certified_end_img.gameObject:SetActive(status)
        end
    end
end


function NewPersonPanel:UpdateBindPhone()
    if MainModel.UserInfo.phoneData and MainModel.UserInfo.phoneData.phone_no then
        self.binding_btn.gameObject:SetActive(false)
        self.binding_end_img.gameObject:SetActive(true)
    else
        self.binding_btn.gameObject:SetActive(true)
        self.binding_end_img.gameObject:SetActive(false)
    end
end
--[[点击实名认证]]
function NewPersonPanel:OnClickCertified(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    GameManager.GotoUI({gotoui = "sys_binding_verifide",goto_scene_parm = "panel"})
end

--绑定手机
function NewPersonPanel:OnClickBindingPhone(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    GameManager.GotoUI({gotoui = "sys_binding_phone",goto_scene_parm = "panel"})
end


--修改昵称成功,刷新昵称显示
function NewPersonPanel:on_SYSChangeHeadAndNameManager_Change_Name_Success_msg()
    self.player_name_txt.text = MainModel.UserInfo.name
end

--设置头像成功,刷新头像显示
function NewPersonPanel:on_SYSChangeHeadAndNameManager_Change_Head_Success_msg()
    --URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.player_head_img)
    self.head_pre:MyRefresh()
end

--绑定上级,并进行界面调整
function NewPersonPanel:on_SYSTGXT_bind_up_person_msg()
    GameManager.GotoUI({gotoui = "sys_tgxt",goto_scene_parm = "panel2", node = self.bd_node.transform})
    self.IDtxt.transform.localPosition = Vector3.New(131,-10,0)
    self.player_id_txt.transform.localPosition = Vector3.New(286,-10,0)
    self.player_name_txt.transform.localPosition = Vector3.New(88,40,0)
    self.player_head_img.transform.localPosition = Vector3.New(-564,230,0)
    self.player_headframe_img.transform.localPosition = Vector3.New(-564,230,0)

    self.player_head_img.transform.localScale = Vector3.New(0.7, 0.7, 1)
    self.player_headframe_img.transform.localScale = Vector3.New(0.7, 0.7, 1)
    self.BG_shop.transform.localPosition = Vector3.New(-220 ,100,0)
    self.Imgshop.transform.localPosition = Vector3.New(-327,100,0)
    self.BG_gold.transform.localPosition = Vector3.New(-516,100,0)
    self.ImgGold.transform.localPosition = Vector3.New(-620,100,0)
    self.Binding.transform.localPosition = Vector3.New(175,116,0)
    self.Certified.transform.localPosition = Vector3.New(175,210,0)
    self.by_lvl_node.transform.localPosition = Vector3.New(54.5,242,0)
end
