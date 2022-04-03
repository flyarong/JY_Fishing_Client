-- 创建时间:2019-12-11
-- Panel:AssetsGet50Panel
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

 AssetsGet50Panel = basefunc.class()
 local C = AssetsGet50Panel
 C.name = "AssetsGet50Panel"
 
 function C.Create(assets_data, call, bool,agin_call,show_copy)
     return C.New(assets_data, call, bool,agin_call,show_copy)
 end
 
 function C:AddMsgListener()
     for proto_name,func in pairs(self.lister) do
         Event.AddListener(proto_name, func)
     end
 end
 
 function C:MakeLister()
     self.lister = {}
 end
 
 function C:RemoveListener()
     for proto_name,func in pairs(self.lister) do
         Event.RemoveListener(proto_name, func)
     end
     self.lister = {}
 end
 
 function C:MyExit()
    if self.timer then
        -- body
        self.timer:Stop()
    end
     self:CloseAwardCell()
     self:RemoveListener()
     destroy(self.gameObject)
 
      
 end
 
 function C:ctor(assets_data, call, bool,agin_call,show_copy)
 
     ExtPanel.ExtMsg(self)
 
     ExtendSoundManager.PlaySound(audio_config.game.bgm_hall_huodewupin.audio_name)
 
     self.assets_data = assets_data
     self.call = call
     self.ui_ceng = 5 -- ui层级
     local parent = GameObject.Find("Canvas/LayerLv5").transform
     local obj = newObject(C.name, parent)
     local tran = obj.transform
     self.transform = tran
     self.gameObject = obj
 
     self.b = bool or false
     self.agin_call = agin_call
	self.show_copy=show_copy

 
     LuaHelper.GeneratingVar(self.transform, self)
     local canvas = self.center.transform:GetComponent("Canvas")
     canvas.sortingOrder = self.ui_ceng + 2
 
     change_renderer(self.lingqu_GC, self.ui_ceng + 2, true)
     change_renderer(self.lingqu_ZT, self.ui_ceng + 2)
     self.lingqu_GC.gameObject:SetActive(true)
     self.lingqu_ZT.gameObject:SetActive(true)
 
     self:MakeLister()
     self:AddMsgListener()
     self:InitUI()
 end
 
 function C:InitUI()
     dump(self.assets_data,"<color>++++++++++++++++++++</color>")
     self.cell_data = self.assets_data
     self.BG_btn.onClick:AddListener(function ()
        if self.call then
             self.call()
         end
         self.call=nil
         self:OnClick()
         self:MyExit()
     end)
 
 
 
     self.confirm_btn.onClick:AddListener(function ()
         ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
         if self.call then
             self.call()
         end
         self.call=nil
         self:OnClick()
         self:MyExit()
     end)
     self.copy_btn.onClick:AddListener(function ()	
         ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
         LittleTips.Create("已复制微信号请前往微信进行添加")
         UniClipboard.SetText(Global_GZH_ID)
         self:MyExit()
     end)
 
 
     self.agin_btn.onClick:AddListener(function ()	
         ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
         if self.agin_call then
             self.agin_call()
         end
         self:MyExit()
     end)
 
 
     for i=1,#self.assets_data do
        --  if self.assets_data[i].asset_type ~= "shop_gold_sum" and self.assets_data[i].asset_type ~= "jing_bi"
        --   and self.assets_data[i].asset_type~= "prop_web_chip_huafei" then
        --      self.copy_btn.gameObject:SetActive(true)
        --      break
        --  end
        if not self.assets_data[i].asset_type and self.show_copy then
			self.copy_btn.gameObject:SetActive(true)
			break
		end
     end
 
     if self.b then
         self.confirm_btn.transform.localPosition = Vector3.New(500, -419.3, 0)
         self.agin_btn.gameObject:SetActive(self.b)
         self.copy_btn.gameObject:SetActive(not self.b)
     end
 
     self:MyRefresh()

     self.scrowbar=self.Scrollbar.transform:GetComponent("Scrollbar")
     self.scrowbar.value=1
     self.timer=Timer.New(function ()
         if self.scrowbar.value<0.02 then
             self.scrowbar.value=0
             self.timer:Stop()
         end
         self.scrowbar.value=self.scrowbar.value-0.01
     end,0.02,-1,true)
     self.timer:Start()
 end
 
 function C:MyRefresh()
     self:CloseAwardCell()
     
     for k,v in ipairs(self.cell_data) do
         local pre
         if self.b then
             pre = AwardPrefab_FishFarm.Create(self.AwardNode, v)
         else
             pre = AwardPrefab.Create(self.AwardNode, v)
         end
        --  pre:RunAnim(k*0.2)
         self.AwardCellList[#self.AwardCellList + 1] = pre
     end
 
 end
 function C:CloseAwardCell()
     if self.AwardCellList then
         for i,v in ipairs(self.AwardCellList) do
             v:OnDestroy()
         end
     end
     self.AwardCellList = {}
 end
 
 function C:StopTimer()
     if self.timer then
         self.timer:Stop()
         self.timer=nil
     end
 end
 function C:OnClick()
     if self.call then
         self.call()
     end
 end