-- 邮件管理
local basefunc = require "Game.Common.basefunc"
local email_config = nil
email_config = GameButtonManager.ExtLoadLua(EmailLogic.key, "email_config")

EmailModel = {}

--邮件IDs列表
EmailModel.EmailIDs = {}

--邮件列表
EmailModel.Emails = {}

local EmailDownloadFinishCall = nil
local EmailReadFinishCall = nil
local EmailGetFinishCall = nil
local EmailGetAllFinishCall = nil
local EmailDeleteFinishCall = nil

local lister
local function AddLister()
    lister={}
    lister["get_email_ids_response"] = EmailModel.OnGetEmailIdsResponse
    lister["get_email_response"] = EmailModel.OnGetEmailResponse
    lister["read_email_response"] = EmailModel.OnReadEmailResponse
    lister["get_email_attachment_response"] = EmailModel.OnGetEmailAttachmentResponse
    lister["get_all_email_attachment_response"] = EmailModel.OnGetAllEmailAttachmentResponse
    lister["delete_email_response"] = EmailModel.OnDeleteEmailResponse

    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg,cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister=nil
end


--[[a-b 数字集合 a 比 b 多了哪些
    a={1,3,5}
    b={2,3}
    more={1,5}
]]
local function tableMore(a,b)
    local bm = {}
    local ret = {}
    for k,v in ipairs(b) do
        bm[v] = 1
    end
    for k,v in ipairs(a) do
        if not bm[v] then
            ret[#ret+1]=v
        end
    end
    return ret
end

-- 表的交集
local function tableAND(a,b)
    local bm = {}
    local ret = {}
    for k,v in ipairs(b) do
        bm[v] = 1
    end
    for k,v in ipairs(a) do
        if bm[v] then
            ret[#ret + 1] = v
        end
    end
    return ret
end

--解析邮件数据
local function parseEmailData(emailData)

    local code = emailData
    local ok, ret = xpcall(function ()
        local data = json2lua(code)
        -- if type(data) ~= 'table' then
        --     data = {}
        --     print("parseEmailData error : {}")
        -- end
        return data
    end
    ,function (err)
        local errStr = "parseEmailData error : "..emailData
        print(errStr)
        print(err)
    end)

    if not ok then
        ret = nil
    end

    return ret
end


--请求邮件id列表
local function ReqEmailIDs()
    Network.SendRequest("get_email_ids")
end

--请求邮件列表
local function ReqEmail(id)
    Network.SendRequest("get_email",{email_id=id})
end

--请求所有邮件列表
local function ReqAllEmail()
    Network.SendRequest("get_all_email")
end

-- 获取邮件路径
local function getEmailPath()
    local emailPath = AppDefine.LOCAL_DATA_PATH .. "/" .. MainModel.UserInfo.user_id
    return emailPath
end
-- 邮件ID路径
local function getEmailIDPath()
    return getEmailPath() .. "/emailID.txt"
end
-- 邮件ID对应的内容路径
local function getEmailIDToDescPath(emailID)
    return getEmailPath() .. "/" .. emailID .. "_DescTag.txt"
end
-- 保存ID列表
local function SaveEmailID()
    local emailPath = getEmailPath()
    if not Directory.Exists(emailPath) then
        Directory.CreateDirectory(emailPath)
    end

    local emailIDPath = getEmailIDPath()
    local idstr = ""
    for i,v in ipairs(EmailModel.EmailIDs) do
        idstr = idstr .. v
        if i < #EmailModel.EmailIDs then
            idstr = idstr .. ","
        end
    end
    File.WriteAllText(emailIDPath, idstr)
end
-- 保存邮件内容列表
local function SaveEmailDesc(emailId)
    if type(emailId) == "table" then
        for _,v in ipairs(emailId) do
            SaveEmailDesc(v)
        end
    else
        local emailPath = getEmailIDToDescPath(emailId)
        local descStr = EmailModel.Emails[emailId]
        -- descStr = basefunc.safe_serialize(descStr)
        descStr = lua2json(descStr)
        
        if descStr then
            File.WriteAllText(emailPath, descStr)
        else
            print("<color=red>邮件内容为空 emailID = " .. emailId .. "</color>")
        end
    end
end

-- 加载本地邮件ID
local function LoadEmailID()
    local emailPath = getEmailPath()
    if not Directory.Exists(emailPath) then
        Directory.CreateDirectory(emailPath)
    end
    local emailIdPath = getEmailIDPath()
    if not File.Exists(emailIdPath) then
        return
    end
    local allID = File.ReadAllText(emailIdPath)
    if not allID or allID == "" then
        return
    end
    local ns = StringHelper.Split(allID, ",")
    for _,v in ipairs(ns) do
        if tonumber(v) then
            local bufPath = getEmailIDToDescPath(v)
            if File.Exists(bufPath) then
                EmailModel.EmailIDs[#EmailModel.EmailIDs + 1] = tonumber(v)
            end
        end
    end
    SaveEmailID()
end

-- 删除本地邮件
local function DelEmail(emailId)
    if type(emailId) == "table" then
        for _,v in ipairs(emailId) do
            DelEmail(v)
        end
    else
        EmailModel.Emails[emailId] = nil
        local bufList = {}
        for i,v in ipairs(EmailModel.EmailIDs) do
            if v ~= emailId then
                bufList[#bufList + 1] = v
            end
        end
        EmailModel.EmailIDs = bufList
        SaveEmailID()
        local emailPath = getEmailIDToDescPath(emailId)
        if File.Exists(emailPath) then     
            File.Delete(emailPath)
        end
    end
end
-- 加载本地邮件内容
local function LoadEmailDesc(emailId)
    local emailPath = getEmailPath()
    if not emailId then
        local _e_id = {}
        for _,v in pairs(EmailModel.EmailIDs) do
            local b = LoadEmailDesc(v)
            if not b then
                _e_id[#_e_id + 1] = v
            end
        end
        dump(_e_id, "<color=red>读取本地邮件失败的列表</color>")
        for k,v in ipairs(_e_id) do
            DelEmail(v)
        end
    else
        local emailPath = getEmailIDToDescPath(emailId)
        if File.Exists(emailPath) then
            local allText = parseEmailData(File.ReadAllText(emailPath))
            if not allText then
                print("<color=red>EEE 读取本地邮件失败 emailId = " .. emailId .. "</color>")
                return false
            else
                EmailModel.Emails[emailId] = allText
                return true
            end
        end
    end
end

--显示个人信息
function EmailModel.Init()
    AddLister()

    EmailModel.templateData = {}
    if email_config then
        for i,v in ipairs(email_config.config) do
            EmailModel.templateData[v.type] = v
        end
    end

    EmailDownloadFinishCall = nil
    EmailModel.EmailIDs = {}
    EmailModel.Emails = {}

    LoadEmailID()
    LoadEmailDesc()
    
    RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Email)
    RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_EmailHint)

    ReqEmailIDs()
end


function EmailModel.Exit()
    RemoveLister()
end

local function IsEmailDownloadFinish()
    for i,v in ipairs(EmailModel.EmailIDs) do
        if not EmailModel.Emails[v] then
            return false
        end
    end
    return true
end
--[[请求所有的邮件
    UI展示的时候需要调用一下然后准备展示邮件内容
]]
function EmailModel.ReqAllEmail(cbk)

    EmailDownloadFinishCall = cbk

    if IsEmailDownloadFinish() then
        if EmailDownloadFinishCall then
            EmailDownloadFinishCall()
            EmailDownloadFinishCall = nil
        end
    end
end

-- 刷新邮件
function EmailModel.RefreshEmail(emailId)
    ReqEmail(emailId)
end


function EmailModel.OnGetEmailIdsResponse(_,data)
    dump(data, "服务器返回的邮件列表")
    if data.result == 0 then
        if data.list and next(data.list) then
            local mm = {}
            for _,v in ipairs(data.list) do
                if mm[v] then
                    print("<color=red>EEEEEEEEEE 邮件ID重复</color>")
                else
                    mm[v] = 1
                end
            end
            data.list = {}
            for k,v in pairs(mm) do
                data.list[#data.list + 1] = k
            end

            local diffIDs = tableMore(data.list, EmailModel.EmailIDs)
            local delIDs = tableMore(EmailModel.EmailIDs, data.list)

            EmailModel.EmailIDs = tableAND(data.list, EmailModel.EmailIDs)

            DelEmail(delIDs)
            SaveEmailID()
            for i,id in ipairs(diffIDs) do
                ReqEmail(id)
            end
        else
            DelEmail(EmailModel.EmailIDs)
            SaveEmailID()
        end
        Event.Brocast("get_email_list_finish")
    end
    RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Email)
    RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_EmailHint)
end

function EmailModel.AddEmail(data)
    if data.email then

        -- 针对广播处理的
        local isAddId = true
        for _,v in ipairs(EmailModel.EmailIDs) do
            if v == data.email.id then
                isAddId = false
                break
            end
        end
        if isAddId then
            EmailModel.EmailIDs[#EmailModel.EmailIDs + 1] = data.email.id
            SaveEmailID()
        end


        if data.email.data then
            data.email.data = parseEmailData(data.email.data)
        end
        EmailModel.Emails[data.email.id] = data.email
        EmailModel.Emails[data.email.id].create_time = tonumber(EmailModel.Emails[data.email.id].create_time)
        EmailModel.Emails[data.email.id].valid_time = tonumber(EmailModel.Emails[data.email.id].valid_time)
        SaveEmailDesc(data.email.id)
        
        RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Email)
        RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_EmailHint)
        if IsEmailDownloadFinish() then
            if EmailDownloadFinishCall then
                EmailDownloadFinishCall()
                EmailDownloadFinishCall = nil
            end
        end

    end
end

function EmailModel.OnGetEmailResponse(_,data)
    if data.result == 0 then
        Event.Brocast("req_call_email_msg", data)
    end
end


function EmailModel.OnReadEmailResponse(_,data)
    if data.result == 0 then
        if EmailModel.Emails[data.email_id] then
            EmailModel.Emails[data.email_id].state = "read"
            SaveEmailDesc(data.email_id)
            Event.Brocast("set_email_state_change", data.email_id)
        end
        RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Email)
        RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_EmailHint)
        if EmailReadFinishCall then
            EmailReadFinishCall()
            EmailReadFinishCall = nil
        end
    else
        EmailModel.RefreshEmail(data.email_id)
        HintPanel.ErrorMsg(data.result)
    end
end


function EmailModel.OnGetEmailAttachmentResponse(_,data)
    dump(data, "<color=red>领取邮件返回</color>")
    if data.result == 0 then

       if EmailModel.Emails[data.email_id] then
            EmailModel.Emails[data.email_id].state = "read"
            SaveEmailDesc(data.email_id)
            Event.Brocast("set_email_state_change", data.email_id)
        end
        RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Email)
        RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_EmailHint)
        if EmailGetFinishCall then
            EmailGetFinishCall()
            EmailGetFinishCall = nil
        end
    else
        EmailModel.RefreshEmail(data.email_id)
        HintPanel.ErrorMsg(data.result)
    end

end


function EmailModel.OnGetAllEmailAttachmentResponse(_,data)
    dump(data, "<color=red>一键领取邮件返回</color>")
    if data.result == 0 then
        for i,id in ipairs(data.email_ids) do
           if EmailModel.Emails[id] then
                EmailModel.Emails[id].state = "read"
                SaveEmailDesc(id)
                Event.Brocast("set_email_state_change", id)
            end 
        end
        RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Email)
        RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_EmailHint)
        if EmailGetAllFinishCall then
            EmailGetAllFinishCall()
            EmailGetAllFinishCall = nil
        end
    end

end

function EmailModel.DeleteEmail(emailId)
    if EmailModel.Emails[emailId] then
        EmailModel.Emails[emailId] = nil
        DelEmail(emailId)
    end
end

function EmailModel.OnDeleteEmailResponse(_,data)
    dump(data, "<color=red>删除邮件返回</color>")
    if data.result == 0 then
        EmailModel.DeleteEmail(data.email_id)
        if EmailDeleteFinishCall then
            EmailDeleteFinishCall()
            EmailDeleteFinishCall = nil
        end
    end

end

-- UI发送读取请求
function EmailModel.SendReadEmail(id, cbk)
    EmailReadFinishCall = cbk
    Network.SendRequest("read_email", {email_id = id}, "读取邮件...")
end

-- UI发送领取请求
function EmailModel.SendGetEmail(id, cbk)
   EmailGetFinishCall = cbk
   Network.SendRequest("get_email_attachment", {email_id = id}, "领取邮件...")
end

-- UI发送一键领取请求
function EmailModel.SendGetAllEmail(cbk)
    EmailGetAllFinishCall = cbk
    Network.SendRequest("get_all_email_attachment", nil, "一键领取邮件...")
end

-- UI发送删除请求
function EmailModel.SendDeleteEmail(id, cbk)
    EmailDeleteFinishCall = cbk
    Network.SendRequest("delete_email", {email_id = id}, "删除邮件...")
end

--[[清除所有的邮件和本地缓存
    切换账号的时候需要使用
    两个不同的账号的邮件肯定会冲突
]]
function EmailModel.ClearEmail()
    EmailModel.EmailIDs = {}
    EmailModel.Emails = {}
end

-- 邮件状态
EmailModel.EmailState = {
    Read = 1,   -- 已读
    UnRead = 2,   -- 未读
    Lose = 3,   -- 过期
}
-- 邮件状态名字和状态值
function EmailModel.GetState(emailId)
    local data = EmailModel.Emails[emailId]
    if not data then
        StringHelper.PrintError("emailId" .. emailId)
        return
    end
    local currTime = os.time()
    
    if data.valid_time == 0 or data.valid_time > currTime then-- 有效
        if data.state == "read" then
            return EmailModel.EmailState.Read, "已读"
        else
            return EmailModel.EmailState.UnRead, "未读"
        end
    else-- 过期、失效
        return EmailModel.EmailState.Lose, "失效"
    end
end

-- 邮件是否读取
function EmailModel.IsReadState(emailId)
    local data = EmailModel.Emails[emailId]
    
    if data.state == "read" then
        return true
    end
end

-- 获取过期时间
function EmailModel.GetLoseTime(emailId)
    local data = EmailModel.Emails[emailId]
    local currTime = os.time()
    local tt = data.valid_time > currTime
    if data.valid_time > currTime then
        return data.valid_time - currTime
    else
        return 0
    end
end

-- 邮件是否有奖励
function EmailModel.IsExistAward(emailId)
    local data = EmailModel.Emails[emailId] 
    if data then   
        local awardTab = AwardManager.GetAwardTable(data.data)
        if next(awardTab) then
            return true
        end
    end
    return false
end

-- 邮件是否红点提示
function EmailModel.IsRedHint()
    for k,v in pairs(EmailModel.Emails) do
        local awardTab = AwardManager.GetAwardTable(v.data)
        if (next(awardTab) and v.state ~= "read") or v.state ~= "read" then
            return true
        end
    end
end
-- 邮件是否有附件未领取
function EmailModel.IsGetHint()
    for k,v in pairs(EmailModel.Emails) do
        local awardTab = AwardManager.GetAwardTable(v.data)
        if next(awardTab) and v.state ~= "read" then
            return true
        end
    end
end

-- 内容翻译
function EmailModel.GetEmailDesc(data)
    local temp = EmailModel.templateData[data.type]
    if not temp and data.type ~= "native" then
        dump(data, "<color=red>EEE 邮件模板不存在</color>")
        return data.type, data.type
    end
    local desc = ""
    local title = ""
    if data.type == "native" then
        title = data.title
        desc = data.data.content
    elseif data.type == "sys_million_award" then
        title = temp.title
        desc = temp.content
        desc = string.format( desc,data.data.issue,data.data.bonus)
    elseif data.type == "freestyle_activity_award" then
        title = temp.title
        desc = temp.content
        local aname = "游戏"
        local gname = "匹配场"
        local aid = data.data.activity_id
        local gid = data.data.game_id

        local acfg = OperatorActivityModel.GetActivityConfig(aid)
        local gcfg = GameFreeModel.GetGameIDToConfig(gid)
        if acfg then
            aname = acfg.name
        end
        if gcfg then
            gname = GameConfigToSceneCfg[gcfg.game_type].GameName .. gcfg.game_name
        end

        desc = string.format(desc, gname, aname)
    elseif data.type == "sys_shoping_gift_jing_bi" then
        
        local gt={
            goods = "钻石",
            jing_bi = "金币",
            jipaiqi = "记牌器",
            room_card = "房卡",
            tmp = "商品",
        }
        local goods_type = gt[data.data.goods_type or "tmp"]
        local goods = "商品"

        local gd = MainModel.GetShopingConfig(data.data.goods_type, data.data.goods_id)
        if gd then
            goods = gd.ui_title
        end

        title = string.format(temp.title,goods_type)
        desc = string.format(temp.content,goods)
    elseif data.type == "zjd_activity_award_evidence" then
        title = temp.title
        desc = temp.content
        desc = string.format( desc,data.data.player_name,data.data.level,data.data.time)
    elseif data.type == "vip_lb_task_auto_get_award" then
        title = temp.title
        desc = temp.content
        desc = string.format( desc,data.data.time)
    elseif data.type == "watermelon_rank_activity" or data.type == "credits_rank_activity" then
        title = temp.title
        desc = temp.content
        desc = string.format( desc,data.data.rank)
    elseif data.type == "buyu_rank_activity" then
        title = temp.title
        desc = temp.content
        local hbq = data.data.shop_gold_sum or 0
        if not data.data.shop_gold_sum and not data.data.hbq then
            hbq = 0
        else
            hbq = data.data.shop_gold_sum or data.data.hbq
        end
        desc = string.format( desc, data.data.rank, hbq, data.data.mp)
    elseif data.type == "buyu_rank_activity_dayu20" then
        title = temp.title
        desc = temp.content
        desc = string.format( desc, data.data.mp)
    elseif data.type == "sharing_by_all_auto_get_award" then
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.award_value/100,data.data.time)
    elseif data.type == "jykp_award_evidence" then
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.award)
    elseif data.type == "zhounianqing_yingjing_rank_email" then
        title = temp.title
        desc = temp.content
        local t = {
            "王者","大师","钻石","铂金","黄金","白银","青铜","黑铁"
        }
        desc = string.format(desc,t[data.data.stage_id] or "")
    elseif data.type == "supreme_ranking_rank_email"  then
        --至尊排位
        title = temp.title
        desc = temp.content
        local t = {
            [517] = "青铜1", [518] = "青铜2", [519] = "青铜3", [520] = "白银1", [521] = "白银2", [522] = "白银3", [523] = "黄金1", [524] = "黄金2",
            [525] = "黄金3", [526] = "白金1", [527] = "白金2", [528] = "白金3", [529] = "钻石1", [530] = "钻石2", [531] = "钻石3", [532] = "至尊",
        }
        desc = string.format(desc,t[data.data.stage_id] or "",data.data.award_name)       
    elseif data.type == "zhounianqing_yingjing_rank_wangzhe_email" then
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.stage_rank)
    elseif data.type == "zhounianqing_jinianbi_lottery_award" then
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.awards)
    elseif data.type == "xiaoxiaole_once_game_rank" then
        dump(data,"<color>单笔赢金========================</color>")
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.rank,data.data.award_value/100)
    elseif data.type == "new_player_lottery_shiwu_award" then
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.award_name)
    elseif data.type == "19_october_lottery_shiwu_email" then
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.award_name)
    elseif data.type == "national_day_lottery_rank_email" then
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.rank_id)
    elseif data.type == "19_october_lottery_rank_email" then
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.rank_id)
    elseif data.type == "october_19_lottery_2_shiwu_email" then
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.award_name)
    elseif data.type == "october_19_lottery_2_rank_email" then
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.rank_id)
    elseif data.type == "double_11_leiji_yingjin_email" then
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.award_name)
    elseif data.type == "hallowmas_charge_rebate_email" then
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.award_name)
    elseif data.type == "crazy_double_11_lottery_email" then
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.award_name)
    elseif data.type == "crazy_double_11_welfare_email" then
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.award_name)
    elseif data.type == "in_kind_email_notify" then
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.award_name)
    elseif data.type == "common_lottery_shiwu_email" then
        local formStr=EmailModel.FormSumShiWuStr(data.data.award_name)
        title = data.data.title
        desc = temp.content
        desc = string.format(desc, data.data.act_name, formStr)        
    elseif data.type == "task_21028_shiwu_email" then
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.award_name)
    elseif data.type == "gratitude_propriety_shiwu_email" then
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.award_name) 
    elseif data.type == "crazy_double_12_lottery_email" then
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.award_name)         
    elseif data.type == "stxt_give_props" then
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.player_name)         
    elseif data.type == "nianmo_gns_award_email" then
        dump(data, "<color=red><size=40>XXXXXXX</size></color>")
        title = temp.title
        desc = temp.content
        desc = string.format(desc, data.data.award_name)        
    elseif data.type == "stxt_ask_master" then
        title = temp.title
        desc = temp.content
        desc = string.format(desc, data.data.player_name)
    elseif data.type == "common_task_shiwu_email" then
        title = data.data.task_name
        desc = temp.content
        desc = string.format(desc, data.data.task_name,data.data.award_name)                    
    --[[elseif data.type == "all_return_lb_over_email" then 
        title = temp.title
        desc = temp.content
        desc = string.format(desc, data.data.lb_name,data.data.year,data.data.month ,data.data.day)     --]]  
    elseif data.type == "all_return_lb_overtime_award_email" then
        title = data.title
        desc = temp.content
        desc = string.format(desc)       
    elseif data.type == "xiaoxiaole_shuihu_once_game_rank" then 
        dump(data,"<color>单笔赢金========================</color>")
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.rank,data.data.award_value/100)
    elseif data.type == "bullet_rank_everyday_email" then 
        dump(data,"<color>捕魚积分賽</color>")
        title = temp.title
        desc = temp.content
        local map_name = {}
        local config = HotUpdateConfig("Game.CommonPrefab.Lua.fish3d_hall_config")
        for i=2,#config.game do
            map_name[#map_name + 1] = config.game[i].name
        end
        desc = string.format(desc,map_name[data.data.match_id],data.data.rank_id)
    elseif data.type == "bullet_vip_rank_everyday_email" then 
        dump(data,"<color>vip4回馈赛</color>")
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.rank_id,data.data.shop_gold_sum)
    elseif data.type == "xiaolongxia_boss_025_rank_email" then 
        dump(data,"<color>龙虾boss击杀榜</color>")
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.rank_id,data.data.award_name)
    elseif data.type == "xiaolongxiaquan_025_rank_email" then 
        dump(data,"<color>龙虾券榜</color>")
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.rank_id,data.data.award_name)
    elseif data.type == "true_love_026_rank_email" then 
        dump(data,"<color>真爱榜单</color>")
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.rank_id,data.data.award_name)
    elseif data.type == "leijiyingjin_rank_email" then 
        dump(data,"<color>赢金榜</color>")
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.rank_id,data.data.award_name)
    elseif data.type == "leijixiaohao_rank_email" then 
        dump(data,"<color>达人榜</color>")
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.rank_id,data.data.award_name)
    elseif data.type == "ocean_explore_week_rank_email" then 
        dump(data,"<color>深海探险榜</color>")
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.rank_id,data.data.award_name)
    elseif data.type == "xiaoxiaole_tower_week_rank_email" then 
        dump(data,"<color>水果消消乐闯关榜</color>")
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.rank_id,data.data.award_name)
    elseif data.type == "buyu_3d_yingjin_rank_email" then 
        dump(data,"<color>buyu_3d_yingjin_rank_email</color>")
        title = temp.title
        desc = temp.content
        desc = string.format(desc, data.data.month, data.data.day, data.data.rank_id)
    elseif data.type == "chang_wan_ka_award_email" then
        dump(data,"<color>------畅玩卡-----------</color>")
        title = temp.title
        desc = temp.content
        local jiangli=""
        if data.data.shop_gold_sum then
            jiangli=data.data.shop_gold_sum.."福利券"
        elseif data.data.jing_bi then
            jiangli=data.data.jing_bi.."金币"
        end
        desc = string.format(desc, jiangli )
    elseif data.type == "by_3d_fire_gift_task_auto_award_email" then 
        dump(data,"<color>by_3d_fire_gift_task_auto_award_email</color>")
        title = temp.title
        desc = temp.content
        local cfg = GameFishing3DManager.GetGameIDToConfig(data.data.game_id)   
        if cfg then
            desc = string.format(desc, cfg.name, data.data.award)
        else
            desc = string.format(desc, "", data.data.award)
        end
    elseif data.type == "s12_12_lhsjb_rank_email" then 
        dump(data,"<color>再惠双12</color>")
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.rank_id,data.data.award_name)
    elseif data.type == "dz_jzsjb_rank_email" then 
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.rank_id,data.data.award_name)
    elseif data.type == "sd_lhsjb_rank_email" then 
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.rank_id,data.data.award_name)
    elseif data.type == "yd_jyb_rank_email" then 
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.rank_id,data.data.award_name)
    elseif data.type == "hhqjnh_046_lhsjb_rank_email" then 
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.rank_id,data.data.award_name)  
    elseif data.type == "khqd_001_lzphb_rank_email" then 
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.rank_id,data.data.award_name) 
    elseif data.type == "drswn_002_ygbd_rank_email" then 
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.rank_id,data.data.award_name)   
    elseif data.type == "cjs_003_bzphb_rank_email" then 
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.rank_id,data.data.award_name)   
    elseif data.type == "sleep_act_task_auto_get_award_email" then 
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.shop_gold_sum)  
    elseif data.type == "xxlzb_004_rank_email" then 
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.rank_id,data.data.award_name)
    elseif data.type == "gdn_004_jzbd_rank_email" then 
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.rank_id,data.data.award_name)
    elseif data.type == "ycs_005_jybb_rank_email" then 
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.rank_id,data.data.award_name)
    elseif data.type == "nyx_006_yxbd_rank_email" then 
        --string,sub()
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.rank_id,data.data.award_name)    
    elseif data.type == "nsj_007_mgbd_rank_email" then 
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.rank_id,data.data.award_name) 
    elseif data.type == "xian_shi_hong_bao_reback" then 
        title = temp.title
        desc = temp.content
        local timeDate = os.date("%Y.%m.%d", data.data.unlock_time )
        desc = string.format(desc,timeDate) 
    elseif EmailModel.IsCommonType(data.type) then 
        title = temp.title
        desc = temp.content
        desc = string.format(desc,data.data.rank_id,data.data.award_name)       
                             
    else
        title = temp.title
        desc = temp.content
    end

    return desc,title
end

function EmailModel.FormSumShiWuStr(_str)
    local allshiwuData=StringHelper.Split(_str,",")
    local formShiwuData={}
    local isContain= function (list,desc)
		for index, value in ipairs(list) do
			if value.desc==desc then
				return index
			end
		end
		return -1
	end
    for index, value in ipairs(allshiwuData) do
        local containIndex=isContain(formShiwuData,value)
			if containIndex==-1 then
				formShiwuData[#formShiwuData + 1] = {num=1, desc=value}
			else
				local num=formShiwuData[containIndex].num
				formShiwuData[containIndex].num=num+1
			end
    end
    local returnStr=""
    for index, value in ipairs(formShiwuData) do
        if index~=#formShiwuData then
            returnStr=returnStr..value.desc.."x"..value.num..","
        else
            returnStr=returnStr..value.desc.."x"..value.num
        end
    end
    return returnStr

end
----通用dataType表
local commonTypeTable = { "xiaoxiaole_tower_week_rank_email" ,
                         "xxlzb_005_rank_email",   "xxlzb_005_rank_ext_email",     "kh315_008_lhphb_rank_email",       "kh315_008_lhphb_rank_ext_email", 
                         "xxlzb_006_rank_email",   "xxlzb_006_rank_ext_email" ,"   cnhk_009_thphb_rank_email",          "cnhk_009_thphb_rank_ext_email",
                         "xxlzb_007_rank_email",   "xxlzb_007_rank_ext_email",     "ymkh_010_wxphb_rank_email",         "ymkh_010_wxphb_rank_ext_email",
                         "xxlzb_008_rank_email",   "xxlzb_008_rank_ext_email",     "qmyl_011_hdphb_rank_email",         "qmyl_011_hdphb_rank_ext_email",
                         "xxlzb_009_rank_email",   "xxlzb_009_rank_ext_email",     "ltqf_012_fqdr_rank_email",          "ltqf_012_fqdr_rank_ext_email",
                         "cjj_xxlzb_rank_email",   "cjj_xxlzb_rank_ext_email",     "hlsyt_013_bsyl_rank_email",          "hlsyt_013_bsyl_rank_ext_email",
                         "wylft_014_ldxfb_rank_email",  "wylft_014_ldxfb_rank_ext_email",   "hljnh_015_yxdr_rank_email",    "hljnh_015_yxdr_rank_ext_email",
                         "hlwyt_016_fqdr_rank_email",   "hlwyt_016_fqdr_rank_ext_email",    "ymshf_017_hldr_rank_email",    "ymshf_017_hldr_rank_ext_email",
                         "hlly_018_hlbd_rank_email",    "hlly_018_hlbd_rank_ext_email",      "zqdw_019_fqdr_rank_email",  "zqdw_019_fqdr_rank_ext_email" ,
                         "fqjkh_020_yxbd_rank_email",   "fqjkh_020_yxbd_rank_ext_email","qlyx_021_xgphb_rank_email", "qlyx_021_xgphb_rank_ext_email",
                         "yqhp_022_nqdr_rank_email","yqhp_022_nqdr_rank_ext_email","xrkh_023_ygbd_rank_email","xrkh_023_ygbd_rank_ext_email",
                         "lxjkh_024_jfphb_rank_email","lxjkh_024_jfphb_rank_ext_email"
                        }
function EmailModel.IsCommonType(data_type)
    -- body
    for i, v in ipairs(commonTypeTable) do
        if v==data_type then
            return true
        end
    end
    return false
end
-- 是否有邮件可以领取
function EmailModel.IsEmailsGet()
    for k,v in pairs(EmailModel.Emails) do
        local awardTab = AwardManager.GetAwardTable(v.data)
        if next(awardTab) and v.state ~= "read" then
            return true
        end
    end
end

-- 时间显示转换
function EmailModel.GetConvertTime(val)
    return os.date("%Y-%m-%d %H:%M", val)
end