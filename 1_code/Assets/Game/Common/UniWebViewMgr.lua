
local basefunc = require "Game.Common.basefunc"
UniWebViewMgr = {}
local M = UniWebViewMgr
local lister
local this

local UniWebViewHash = {}
local UniWebViewStateHash = {}
local cur_webview_key --当前正在加载的key
local timer_loading
M.load_jh_key = "webview_loading"
M.load_max_time = 20

local webViewBgPanel
local isOldWeb

local UniWebViewPool = {}
M.pool_limit = 5

local WebviewState = {
    None = "NONE",
    Load = "LOAD",
    View = "VIEW",
    Hide = "HIDE",
}

local url_schemes = {
    "uniwebviewfun",
    "unityfun",
    "webmessage",
}

local local_func = {
    --打开外部Url
    openurl = "UnityEngine.Application.OpenURL",
}

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
    lister["uniwebview_should_close_msg"] = this.on_uniwebview_should_close_msg
    lister["uniwebview_page_finish_msg"] = this.on_uniwebview_page_finish_msg
    lister["Client_SendBreakdownInfoToServer"] = this.On_Client_SendBreakdownInfoToServer
end

function M.IsWebOld()
    if isOldWeb == nil then
        local channel_type = gameMgr:getMarketPlatform()
        if channel_type ~= "normal" or (channel_type == "normal" and gameRuntimePlatform == "Ios") then
            isOldWeb = true
        else
            isOldWeb = false
        end
    end
    return isOldWeb
end

function M.CheckIsMissFunc(key)
    xpcall(function ()
        UniWebViewHash[key]:ShowToEvaluateJS()
    end
    ,function (err)
        -- HintPanel.Create(1,"isOldWeb Set false")
        isOldWeb = false
    end)
end

function M.Init()
    this = UniWebViewMgr
    RemoveLister()
    MakeLister()
    AddLister()
    if M.IsWebOld() and GameGlobalOnOff.ActByWebView then
        GameGlobalOnOff.ActByWebView = false    
    end
    M.CleanCacheAll()
    M.CleanCookies()
    --UniWebView.SetWebContentsDebuggingEnabled(true)
end

function M.Exit()
    isOldWeb = nil
    if this then
		RemoveLister()
		this = nil
	end
end

local function ShowJH()
    FullSceneJH.Create("", M.load_jh_key)
    timer_loading = Timer.New(function()
        LittleTips.Create("加载失败，请稍后再试")
        M.ChangeState(cur_webview_key, WebviewState.None)
    end, M.load_max_time, 1)
    timer_loading:Start()
end

local function CloseJH()
    FullSceneJH.RemoveByTag(M.load_jh_key)
    if timer_loading then
        timer_loading:Stop()
        timer_loading = nil
    end
end

local function GetWH()
    local w,h
    local matchWidthOrHeight = MainModel.GetScene_MatchWidthOrHeight(Screen.width, Screen.height)
    if matchWidthOrHeight == 0 then
        h = 1080 * (1920 / Screen.width)
        w = 1920
    else
        h = 1080
        w = 1080 * (Screen.width / Screen.height)
    end
    return w,h
end

local function ShowWebviewBg(rect)
    if not rect then
		--默认全屏截图
		rect = UnityEngine.Rect.New(0, 0, Screen.width, Screen.height)
	end
	if not rect then return end
	if not rect.x or not rect.y or not rect.width or not rect.height then return end
    if not Directory.Exists(resMgr.DataPath) then
        Directory.CreateDirectory(resMgr.DataPath)
    end
	local imageName = resMgr.DataPath .. "WebViewBg.png"
    dump("<color=white>UniWebViewMgr ShowWebviewBg screen_shot_begin</color>")
    dump(imageName, "<color=white>UniWebViewMgr ShowWebviewBg imageName</color>")
	panelMgr:MakeCameraImgAsync(rect.x, rect.y, rect.width, rect.height, imageName, function ()
        dump("<color=white>UniWebViewMgr ShowWebviewBg screen_shot_end</color>")
        local tex = panelMgr:GetTexture2DFromPath(imageName, Screen.width, Screen.height)
        local _parent = GameObject.Find("Canvas/LayerLv50").transform
        webViewBgPanel = newObject("UniWebBGPanel", _parent)
        local p_w,p_h = GetWH()
        --webViewBgPanel:GetComponent("RectTransform").sizeDelta = {x = rect.width, y = rect.height}
        webViewBgPanel:GetComponent("RectTransform").sizeDelta = {x = p_w, y = p_h}
        webViewBgPanel:GetComponent("Image").sprite = Sprite.Create(tex, Rect.New(0, 0, tex.width, tex.height), Vector2.New(0.5,0.5))
    end, false, false)
end

local function CloseWebviewBg()
    if webViewBgPanel then
        destroy(webViewBgPanel.gameObject)
        webViewBgPanel = nil
    end
end

function M.ShowOrHideWebviewBg(is_show)
    if M.IsWebOld() then
        return 
    end
    if is_show then
        ShowWebviewBg()
    else
        CloseWebviewBg()
    end
end

function M.ShowOrHideJH(is_show)
    if is_show then
        ShowJH()
    else
        CloseJH()
    end
end
-----------------------------------------------------------------------------------------------------------
function M.OpenUrl(key, url)
    dump(url, "<color=red>UniWebViewMgr OpenUrl url:</color>")
    dump(key, "<color=red>UniWebViewMgr OpenUrl key:</color>")
    if UniWebViewStateHash[key] and UniWebViewStateHash[key] == WebviewState.Hide then
        M.ChangeState(key, WebviewState.View)
        return
    end
    if UniWebViewStateHash[key] and UniWebViewStateHash[key] == WebviewState.Load then
        return
    end
    local obj = GameObject.New("UniWebView_" .. key)
    GameObject.DontDestroyOnLoad(obj)
    UniWebViewHash[key] = obj:AddComponent(typeof(UniWebView))
    M.CheckIsMissFunc(key)
    UniWebViewStateHash[key] = WebviewState.None
    UniWebViewMessageMgr.AddMessageListenerToView(UniWebViewHash[key])
    obj = nil
    M.SetAttribute(key)
    M.Load(key, url)
    M.ChangeState(key, WebviewState.Load)
end

function M.SetAttribute(key)
    UniWebViewHash[key]:SetFrame()
    if not M.IsWebOld() then
        UniWebViewHash[key].Key = key
    end
    UniWebViewHash[key].BackgroundColor = Color.New(0, 0, 0, 0.6)
    --UniWebViewHash[key].Frame = Rect.New(0, 0, 300, 300)
    --UniWebViewHash[key].Alpha = 0.5
    --添加通讯协议
    for i = 1, #url_schemes do
        UniWebViewHash[key]:AddUrlScheme(url_schemes[i])
    end
end

function M.Load(key, url)
    UniWebViewHash[key]:Load(url, true)
end

function M.ShowOrHide(key, is_show)
    if not UniWebViewHash[key] then
        return
    end
    if UniWebViewStateHash[key] and UniWebViewStateHash[key] == WebviewState.Load then
        return
    end
    if is_show then
        UniWebViewHash[key]:Show()
        if M.IsWebOld() then
            UniWebViewHash[key]:ShowToEvaluateJS()
        else
            M.EvaluateJsToWeb(cur_webview_key, "webviewWillAppear")
        end
    else
        cur_webview_key = nil
        UniWebViewHash[key]:Hide()
    end
end

function M.ChangeState(key, new_state)
    if not key then
        key = cur_webview_key
    end
    local old_state = UniWebViewStateHash[key]
    if not old_state then
        return
    end
    if old_state ~= new_state then
        UniWebViewStateHash[key] = new_state
        M.HandleChangeState(key, old_state, new_state)
    end
end

function M.HandleChangeState(key, old_state, new_state)
    if new_state == WebviewState.Load then
        cur_webview_key = key
        M.ShowOrHideJH(true)
    elseif new_state == WebviewState.View then
        cur_webview_key = key
        M.ShowOrHideWebviewBg(true)
        M.ShowOrHideJH(false)
        M.ShowOrHide(cur_webview_key, true)
    elseif new_state == WebviewState.Hide then
        M.ShowOrHideWebviewBg(false)
        M.ShowOrHide(cur_webview_key, false)
        cur_webview_key = nil
    elseif new_state == WebviewState.None then
        M.ShowOrHideJH(false)
        M.ShowOrHideWebviewBg(false)
        M.DestroyUniwebviewObj(cur_webview_key)
        cur_webview_key = nil
    end
end

function M.IsInViewing()
    if cur_webview_key and UniWebViewStateHash[cur_webview_key] == WebviewState.View then
        return true
    end
end

function M.AddJsToWeb(key, actFunStr, success_func)
    UniWebViewHash[key]:AddJS(actFunStr, function ()
        if success_func then
            dump("UniWebViewMgr AddJsToWeb Success")
            success_func()
        end
    end, function ()
        HintPanel(1, "UniWebViewMgr AddJsToWeb Failed")
        M.ChangeState(key, WebviewState.None)
    end)
end

function M.EvaluateJsToWeb(key, actName, actData, success_func)
    local _key
    if not key then
        _key = cur_webview_key
    else
        _key = key
    end

    local actStr = actName .. "("
    if actData and not table_is_null(actData) then
        for i = 1, #actData do
            actStr = actStr .. actData[i] 
            if i ~= #actData then
                actStr = actStr .. ","
            end
        end
    end
    actStr = actStr .. ");"
    dump(actStr, "UniWebViewMgr EvaluateJsToWeb actStr:")
    if not UniWebViewHash[_key] then
        return
    end
    UniWebViewHash[_key]:EvaluateJS(actStr, function ()
        if success_func then
            success_func()
        end
    end, function ()
        HintPanel(1, "EvaluateJsTo_Web Fail!!!")
        M.ChangeState(key, WebviewState.None)
    end)
end

--WebView对象的方法
function M.DoWebViewFunc(key, funcName)
    dump(key, "UniWebViewMgr DoWebViewFunc key:")
    dump(funcName, "UniWebViewMgr DoWebViewFunc funcName:")
    if funcName == "Hide" then
        M.ChangeState(key, WebviewState.Hide)
        return
    end
    UniWebViewHash[key][funcName](UniWebViewHash[key])
end

--Unity端的方法
function M.DoLocalFun(funcNameStr, parm_tab)
    local parm_type = {}
    local parm_content = {}

    for k,v in pairs(parm_tab) do
        local spli_tab = basefunc.string.split(k, "_")
        parm_type[tonumber(spli_tab[1])] = spli_tab[2]
        parm_content[tonumber(spli_tab[1])] = v
    end

    local parmStr = ""
    for i = 1, #parm_type do
        if parm_type[i] == "int" then
            parmStr = parmStr .. tonumber(parm_content[i]) .. "\"" 
        elseif parm_type[i] == "url" then
            parmStr = parmStr .. "\"" .. parm_content[i] .. "\"" 
        else
            parmStr = parmStr .. "\"" .. parm_content[i] .. "\"" 
        end
        if i < #parm_type then
            parmStr = parmStr .. ","
        end
    end
    if not local_func[funcNameStr] then
        return
    end
    local do_code = local_func[funcNameStr] .. "(" .. parmStr .. ")"
    dump(do_code, "UniWebViewMgr DoLocalFun do_code:")
    loadstring(do_code)()
end

function M.on_uniwebview_page_finish_msg()
    if cur_webview_key and UniWebViewStateHash[cur_webview_key] and UniWebViewStateHash[cur_webview_key] == WebviewState.Load then
        M.ChangeState(cur_webview_key, WebviewState.View)
    end
end

function M.on_uniwebview_should_close_msg()
    if cur_webview_key and UniWebViewStateHash[cur_webview_key] and UniWebViewStateHash[cur_webview_key] == WebviewState.View then
        M.ChangeState(cur_webview_key, WebviewState.Hide)
    end
end

--客户端报错的时候关闭WebView显示
function M.On_Client_SendBreakdownInfoToServer()
    if cur_webview_key and UniWebViewStateHash[cur_webview_key] and UniWebViewStateHash[cur_webview_key] == WebviewState.View then
        M.ChangeState(cur_webview_key, WebviewState.None)
    end
end

--销毁Uniwebview对象
function M.DestroyUniwebviewObj(key)
    if not UniWebViewHash[key] then
        return
    end
    UniWebViewMessageMgr.RemoveMessageListenerToView(UniWebViewHash[key])
    destroy(UniWebViewHash[key].gameObject)
    UniWebViewHash[key] = nil
    UniWebViewStateHash[key] = nil
end

--清除所有WebView的缓存
function M.CleanCacheAll()
    dump("<color=red>UniWebViewMgr CleanCacheAll</color>")
    for k,v in pairs(UniWebViewHash) do
        UniWebViewHash[k]:CleanCache()
        M.ChangeState(k, WebviewState.None)
    end
end

--清除所有来自WebView的Cookies
function M.CleanCookies()
    UniWebView.ClearCookies()
end

----------------Pool----------------
local function HandlePoolLimitOut()
    M.ChangeState(UniWebViewPool[1], WebviewState.None)
    for i = 1, #UniWebViewPool - 1 do
        UniWebViewPool[i] = UniWebViewPool[i + 1]
    end
    UniWebViewPool[#UniWebViewPool] = nil
end

local function AddPool(key)
    UniWebViewPool[#UniWebViewPool + 1] = key
    if #UniWebViewPool > M.pool_limit then
        HandlePoolLimitOut()
    end
end