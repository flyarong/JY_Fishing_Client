-- 创建时间:2021-10-12
-- Panel:Act_062_HGQDPanel
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

Act_062_HGQDPanel = basefunc.class()
local C = Act_062_HGQDPanel
C.name = "Act_062_HGQDPanel"
local M = Act_062_HGHDManager

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
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    if self.cutdown_timer then
        self.cutdown_timer:Stop()
    end
    if self.Update_Timer then 
        self.Update_Timer:Stop()
    end
    self:CloseItem()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
    for k,v in pairs(M.qd_config) do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = v.condi_key, is_on_hint = true}, "CheckCondition")
        if a and b then
            self.tab = v
            break
        end
    end
    self.index=1
    self.canMove=true
    self.ChildSize={
        x=1040,--子物体宽度
        y=544,--子物体高度
    }
    EventTriggerListener.Get(self.ScrollView.gameObject).onDown = basefunc.handler(self, self.OnBeginDrag)
    EventTriggerListener.Get(self.ScrollView.gameObject).onUp = basefunc.handler(self, self.OnEndDrag)
    self.right_btn.onClick:AddListener(
        function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:GoRightAnim()
        end
    )
    self.left_btn.onClick:AddListener(
        function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:GoLeftAnim()
        end
    )
    
    self:InitRemainTime()
    self:InitTimer()
	self:MyRefresh()
end

function C:MyRefresh()
    self:CreateItem()
    local target_index = 1
    local data = GameTaskModel.GetTaskDataByID(self.tab.task_id)
    if data then
        local b = basefunc.decode_task_award_status(data.award_get_status)
        b = basefunc.decode_all_task_award_status(b, data, #self.tab.award_img)
        for i=1,#b do
            if b[i] == 0 then
                target_index = i
                break
            end
        end
        for i=1,#b do
            if b[i] == 1 then
                target_index = i
                break
            end
        end
    end
    self:SetIndex(target_index)
end

function C:CreateItem()
    self:CloseItem()
    for i=1,#self.tab.award_img do
        local data = {task_id = self.tab.task_id,award_img = self.tab.award_img[i],award_txt = self.tab.award_txt[i]}
        local pre = Act_062_HGQDItemBase.Create(self.Content.transform, data, i, #self.tab.award_img)
        self.pre_cell[#self.pre_cell + 1] = pre
    end
end

function C:CloseItem()
    if self.pre_cell then
        for k,v in pairs(self.pre_cell) do
            v:MyExit()
        end
    end
    self.pre_cell = {}
end

function C:on_model_task_change_msg(data)
    if data.id and self.tab.task_id == data.id then
        Event.Brocast("global_hint_state_change_msg", { gotoui = M.key , goto_scene_parm = "hgqd_panel" })
        self:MyRefresh()
    end
end

function C:SetOder()
    local task_data = GameTaskModel.GetTaskDataByID(self.tab.task_id)
    if task_data then
        if task_data.award_status == 2 then
            SYSACTBASEManager.ForceToChangeIndex(M.key,100,nil,"hgqd_panel")
        else
            SYSACTBASEManager.ForceToChangeIndex(M.key,1,nil,"hgqd_panel")
        end
    end
end


function C:InitTimer()
    if self.Update_Timer then 
        self.Update_Timer:Stop()
    end
    self.Update_Timer=Timer.New(function ()     
        self:SetRightAnim()
    end,0.016,-1,nil,true)  
    self.Update_Timer:Start()
end

--矫正动画
function C:SetRightAnim()
    if self.index==1 then
        self.left_btn.gameObject:SetActive(false)
    end
    if self.index==7  then
        self.right_btn.gameObject:SetActive(false)
    end
    if   1 <self.index and  self.index < 7  then
        self.left_btn.gameObject:SetActive(true)
        self.right_btn.gameObject:SetActive(true)
    end 
    if self.canMove == false then 
        return 
    end 
    local data=self:GetNearNode()
    self:MoveAnim(data)
end

function C:SetIndex(index)
    self.index=index
    self.Content.transform.localPosition=Vector3.New(-self.ChildSize.x*(self.index-1),self.Content.transform.localPosition.y,self.Content.transform.localPosition.z)
end

function C:MoveAnim(data)
    if data==nil then 
        return 
    end 
    if math.abs(-self.Content.transform.localPosition.x-self.ChildSize.x*data.ind)>1 then 
        if data.direction=="left" then 
            self.Content.transform:Translate(Vector3.left * 32 )
        elseif  data.direction=="right" then 
            self.Content.transform:Translate(Vector3.right * 32 )
        end 
    end 
end
-- end
--当前位置是-self.ChildSize.x*(self.index-1)，所以向左就是（self.index-1）-1，向右则是（self.index-1）+1
function C:GoRightAnim()
    if  self.index < 7 then 
        self.canMove=false
        local seq = DoTweenSequence.Create()
        seq:Append(self.Content.transform:DOLocalMoveX(-self.ChildSize.x*(self.index), 0.2):SetEase(DG.Tweening.Ease.Linear))--OutBack
        seq:OnForceKill(function()--这里报过异常
            self.canMove=true
            if IsEquals(self.Content) then
                SafaSetTransformPeoperty(self.Content.transform, "localPosition" ,Vector3.New(-self.ChildSize.x*(self.index),self.Content.transform.localPosition.y,self.Content.transform.localPosition.z)) 
            end
        end)
    end     
end

function C:GoLeftAnim()
    if  self.index>=2 then 
        self.canMove=false
        local seq = DoTweenSequence.Create()
        seq:Append(self.Content.transform:DOLocalMoveX(-self.ChildSize.x*(self.index-2), 0.2):SetEase(DG.Tweening.Ease.Linear))--OutBack
        seq:OnForceKill(function()--这里报过异常
            self.canMove=true
            if IsEquals(self.Content) then
                SafaSetTransformPeoperty(self.Content.transform, "localPosition" ,Vector3.New(-self.ChildSize.x*(self.index-2),self.Content.transform.localPosition.y,self.Content.transform.localPosition.z)) 
            end
        end)
    end     
end
function C:OnBeginDrag()
    self.canMove=false
    --print("关闭")
end
function C:OnEndDrag()
    self.canMove=true
    --print("开启")
end


--获取最近的节点
function C:GetNearNode()
    if self.canMove ==false then 
        return 
    end 
    for i = 1, #self.tab.award_img do
        if math.abs(-self.ChildSize.x*(i-1)-self.Content.transform.localPosition.x)<20 then 
            self.index=i
            self.Content.transform.localPosition=Vector3.New(-self.ChildSize.x*(self.index-1),self.Content.transform.localPosition.y,self.Content.transform.localPosition.z)
        end 

        if  self.ChildSize.x*(i-1)< -self.Content.transform.localPosition.x and 
             -self.Content.transform.localPosition.x<self.ChildSize.x*i then  
                local b = (self.ChildSize.x*i+ self.Content.transform.localPosition.x)/self.ChildSize.x 
                if   b <0.49999 and  b >0.02  then              
                    return  {direction="left",ind=i}   
                elseif b>0.50001 and b<0.98 then 
                    return  {direction="right",ind=i+1}                     
                end                 
        end 
    end

end

function C:InitRemainTime()
    self.cutdown_timer = CommonTimeManager.GetCutDownTimer(M.GetEndTime(),self.remain_txt)
end
