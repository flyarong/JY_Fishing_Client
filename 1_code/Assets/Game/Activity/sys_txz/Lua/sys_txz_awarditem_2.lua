-- 创建时间:2021-05-06
-- Panel:sys_txz_awarditem_2
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

 local basefunc = require "Game/Common/basefunc"

 sys_txz_awarditem_2 = basefunc.class()
 local C = sys_txz_awarditem_2
 C.name = "sys_txz_awarditem_2"
 local M=SYS_TXZ_Manager
 
 function C.Create(parent,config)
     return C.New(parent,config)
 end
 
 function C:AddMsgListener()
     for proto_name,func in pairs(self.lister) do
         Event.AddListener(proto_name, func)
     end
 end
 
 function C:MakeLister()
     self.lister = {}
     self.lister["refresh_txz_buytype"] = basefunc.handler(self,self.OnRefreshBuyBagType)
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
 
 function C:ctor(parent,config)
     ExtPanel.ExtMsg(self)
     local parent =parent or GameObject.Find("Canvas/GUIRoot").transform
     local obj = newObject(C.name, parent)
     local tran = obj.transform
     self.transform = tran
     self.gameObject = obj
     self.config=config
     LuaHelper.GeneratingVar(self.transform, self)
     
     self:MakeLister()
     self:AddMsgListener()
     self:InitUI()
 end
 
 function C:InitUI()
     GetTextureExtend(self.icon_img,self.config.icon)
     self.icon_txt.text=self.config.num
     self.icon_img.gameObject:GetComponent("Button").onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnTaskItemClcik()
    end)
	 self.animtor=self.icon_img.transform:GetComponent("Animator")
     
     self:MyRefresh()
 end
 
 function C:MyRefresh()
    local buytxztype=M.GetBuyBagType()
  
    if buytxztype==0 then
        self.award_state=M.GetAwardItemGotState(self.config.level,2)
    else
        self.award_state=M.GetAwardItemGotState(self.config.level,buytxztype)
    end
    self.lock_img.gameObject:SetActive(buytxztype==0)
	self.bg_img.gameObject:SetActive(self.award_state==1)
	self.have_got_img.gameObject:SetActive(self.award_state==2)
    self.mask.gameObject:SetActive(false)
	self.animtor.enabled = self.award_state==1 and buytxztype~=0;

 end

 function C:OnRefreshBuyBagType()
    local buytxztype=M.GetBuyBagType()
    if buytxztype>0 then
        local levelAward=M.GetTXZAwardConfigInfo()
        if self.config.level%10~=0 then
            GetTextureExtend(self.icon_img,levelAward[self.config.level%10].icon[buytxztype+1])
            self.icon_txt.text=levelAward[self.config.level%10].num[buytxztype+1]
        else
            GetTextureExtend(self.icon_img,levelAward[10].icon[buytxztype+1])
            self.icon_txt.text=levelAward[10].num[buytxztype+1]
        end
    end
    self.config.task_id=M.GetHaiWangLevelTaskID()
    
 end
 function C:OnTaskItemClcik()
    local buytxztype = M.GetBuyBagType()
    if buytxztype == 0 then
    else
    	if self.award_state == 1 then
            local award_state = M.GetAwardItemGotState(self.config.level,0)
            if award_state == 1 then
                Network.SendRequest("get_task_award_new", {id = M.GetCommonLevelTaskID(), award_progress_lv = self.config.level},function (data)
                    if data.result == 0 then
                        Event.Brocast("sys_exit_ask_refresh_msg")
                    end
                end)
            else
        		dump(self.config.level,self.config.task_id.."领取一个海王奖励")
        		Network.SendRequest("get_task_award_new", {id = self.config.task_id, award_progress_lv = self.config.level},function (data)
                    if data.result == 0 then
                        Event.Brocast("sys_exit_ask_refresh_msg")
                    end
                end)
    	   end
        end
    end
end
 
 function C:on_refresh_txzaward_listitem()
    self:MyRefresh()
 end