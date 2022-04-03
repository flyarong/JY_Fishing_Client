-- 创建时间:2019-10-24
-- 分享管理器

local basefunc = require "Game/Common/basefunc"
SYSFXManager = {}
local M = SYSFXManager
M.key = "sys_fx"
share_link_config = GameButtonManager.ExtLoadLua(M.key, "share_link_config")
GameButtonManager.ExtLoadLua(M.key, "ShareLogic")
GameButtonManager.ExtLoadLua(M.key, "SharePanel")
GameButtonManager.ExtLoadLua(M.key, "FXEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "TYShareImage")

local this
local lister

function M.CheckIsShow()
    return true
end
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return SharePanel.Create()
    elseif parm.goto_scene_parm == "enter" then
    	return FXEnterPrefab.Create(parm.parent, parm.cfg)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end
function M.SetHintState()
end


local function AddLister()
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
local function MakeLister()
    lister = {}
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = SYSFXManager
	this.m_data = {}
	MakeLister()
    AddLister()
    M.InitUIConfig()
    
    --分享替换
    M.ReplaceWebSeverShare()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
end

function M.OnLoginResponse(result)
	if result == 0 then
	end
end
function M.OnReConnecteServerSucceed()
end

function M.ReplaceWebSeverShare()
    dump(MainModel.UserInfo.web_server,"<color=green>web_server >>>>>>>>></color>")
    if not MainModel.UserInfo.web_server then return end
    local slc = {}
    for i=1,#share_link_config.share_link do
        if share_link_config.share_link[i].link[1] and string.find(share_link_config.share_link[i].link[1],"http://es-caller.jyhd919.cn",1,true) then
            share_link_config.share_link[i].link[1] = string.gsub(share_link_config.share_link[i].link[1],"http://es%-caller%.jyhd919%.cn",MainModel.UserInfo.web_server)
        end
    end
    dump(share_link_config,"<color=green>分享配置</color>")
end

-- 二维码
function M.EWM(texture, url)
    if not texture or not url then
        return
    end
    local data = ewmTools.getEwmDataWithPixel(url, ShareLogic.size)

    local w = data.width
    local scale = math.floor(ShareLogic.size / w)
    local py = (ShareLogic.size - w * scale) / 2
    py = math.floor(py)
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

-- 分享的图片生成
function M.CreateShareImage(obj, pos1, pos2, call, camera, path)
    Event.Brocast("ui_share_begin")

    camera = camera or GameObject.Find("Canvas/Camera"):GetComponent("Camera")
    path = path or ShareLogic.GetImagePath()

    local s1 = camera:WorldToScreenPoint(pos1)
    local s2 = camera:WorldToScreenPoint(pos2)
    local x = s1.x
    local y = s1.y
    local w = s2.x - s1.x
    local h = s2.y - s1.y
    local canvas = AddCanvasAndSetSort(obj, 100)
    panelMgr:MakeCameraImgAsync(x, y, w, h, path, function ()
        destroy(canvas)
        Event.Brocast("ui_share_end")
        if call then
            call()
        end
    end, false, GameGlobalOnOff.OpenInstall)
end

-- 
function M.Share(parm)
    
end

function M.GetShareLink(parm)
    return share_link_config.share_link[2].link[1]
end


function M.TYShareImage(parm, call)
    -- 分享的埋点数据
    local share_parm = {share_type = "hlttby"}

    MainModel.GetShareUrl(function(_data)
        dump(_data, "<color=red>分享数据</color>")
        if _data.result == 0 then
            local strOff = "false"

            local userid = MainModel.UserInfo.user_id
            local url = MainModel.UserInfo.shareURL.share_url
            local imageName = ShareLogic.GetImagePath()

            local sendcall = function ()
                -- 分享链接
                local shareLink = string.format(share_link_config.share_link[4].link[1], imageName, strOff )
                ShareLogic.ShareGM(shareLink, function (str)
                    print("<color=red>分享完成....str = " .. str .. "</color>")
                    if call then
                        call(str)
                    end
                end)
            end

            local SI = TYShareImage.Create({msg=parm, url=url})
            SI:RunMake(imageName, function ()
                sendcall()
            end)
        else
            HintPanel.ErrorMsg(_data.result)
            if call then
                call()
            end
        end
    end, share_parm)
end
