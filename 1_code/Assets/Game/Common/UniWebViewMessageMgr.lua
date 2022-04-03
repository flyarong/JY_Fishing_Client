local basefunc = require "Game.Common.basefunc"
UniWebViewMessageMgr = {}
local M = UniWebViewMessageMgr                      --webview的消息管理
local this
local lister

local lister_convey                                 --向Web转发的消息
local positive_message_name = "PositiveMessage"     --Web主动推送函数名
local passive_message_name = "PassiveMessage"       --Web请求响应函数名
local passive_readuuid_str = "Read"                 --客户端收到消息返回的标识

--[[
    Web端发送(客户端转发)消息格式
    添加监听
    webmessage://addlisten?1=""&2=""
    移除监听
    webmessage://removelisten?1=""&2=""
    进行请求
    webmessage://request?name="funcName"&uuid="123"&params="{}"
    
    Web端执行客户端方法消息
    执行Uniwebview对象方法
    uniwebviewFun://funcName
    执行unity本地(自定义)方法
    unityfun://funcName?1=""
]]

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
    lister["webview_notify"] = this.on_webview_notify
end

function M.Init()
    this = UniWebViewMessageMgr
    lister_convey = {}
    MakeLister()
    AddLister()
end

function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

function M.AddMessageListenerToView(view)
    view:AddMessage(
        function(view, message)  
            if UniWebViewMgr.IsWebOld() then
                M.HandleOldMessage(view, message)
            else
                M.HandleMessage(view, message)
            end
        end)

    view:AddMessageErrorReceived(
        function(view, error, message)  
            M.HandleMessageErrorReceived(view, error, message)
        end)

    view:AddMessageShouldClose(
        function(view)  
            M.HandleMessageShouldClose(view)
            return false
        end)

    view:AddMessagePageFinish(
        function(view, statusCode, url)
            M.HandleMessagePageFinish(view, statusCode, url)
        end)
        
end

function M.RemoveMessageListenerToView(view)
    view:RemoveAllMessageReceive()
end

--在加载过程中遇到错误时引发
function M.HandleMessageErrorReceived(view, error, message)
    print("UniWebViewMessageMgr ErrorReceived")
    print("UniWebViewMessageMgr ErrorReceived" .. message)
end
--在Web视图即将关闭时引发，Andorid的返回键
function M.HandleMessageShouldClose(view)
    print("UniWebViewMessageMgr ShouldClose" )
    Event.Brocast("uniwebview_should_close_msg")
end
--当网络视图成功加载网址时引发
function M.HandleMessagePageFinish(view, statusCode, url)
    print("UniWebViewMessageMgr PageFinish" )
    Event.Brocast("uniwebview_page_finish_msg")
end
--在网络视图开始加载网址时引发
function M.HandleMessagePageStarted(view, url)
    print("UniWebViewMessageMgr:PageStarted")
end

--在收到来自Web视图的消息时引发
function M.HandleMessage(_view, _message)
    local iter = _message.Args:GetEnumerator()
    local parm_tab = {}
    local key = _view.Key
    while iter:MoveNext() do  
        local k = iter.Current.Key
        local v = iter.Current.Value
        parm_tab[k] = v
    end

    dump(parm_tab, "UniwebViewMessage HandleMessage parm_tab")
    dump(_message.Scheme, "UniwebViewMessage HandleMessage _message.Scheme:")
    dump(_message.Path, "UniwebViewMessage HandleMessage _message.Path:")
    
    if parm_tab.readuuid then
        local _data = {}
        _data[1] = parm_tab.readuuid
        _data[2] = passive_readuuid_str
        UniWebViewMgr.EvaluateJsToWeb(nil, passive_message_name, _data)
        table.remove(parm_tab.readuuid)
    end
    
    if _message.Scheme == "uniwebviewfun" then
        UniWebViewMgr.DoWebViewFunc(key, _message.Path)
    elseif _message.Scheme == "unityfun" then
        UniWebViewMgr.DoLocalFun(_message.Path, parm_tab)
    elseif _message.Scheme == "webmessage" then
        M.HandleWebMessage(_message.Path, parm_tab)
    end
end

function M.AddListenerConvey(messageName)
    if lister_convey[messageName] then
        return
    end
    this["on_" .. messageName] = function(_, data)
        M.ConveyToWebPositive(messageName,data)
    end
    lister_convey[messageName] = this["on_" .. messageName]
    Event.AddListener(messageName, lister_convey[messageName])
end

function M.RemoveListenerConvey(messageName)
    if not lister_convey[messageName] then
        return
    end
    this["on_" .. messageName] = nil
    Event.RemoveListener(messageName, lister_convey[messageName])
    lister_convey[messageName] = nil
end

function M.AddListenersConvey(all_message)
    for k,v in pairs(all_message) do
        M.AddListenerConvey(v)
    end
end

function M.RemoveListenersConvey(all_message)
    for k,v in pairs(all_message) do
        M.RemoveListenerConvey(v)
    end
end

function M.HandleWebMessage(path, param_tab)
    if path == "addlisten" then
        M.AddListenersConvey(param_tab)
    elseif path == "removelisten" then
        M.RemoveListenersConvey(param_tab)
    elseif path == "request" then
        M.HandleWebRequest(param_tab)
    end
end

function M.HandleWebRequest(_parm_tab)
    if not _parm_tab.name then
        dump("UniWebViewMessageMgr FuncName Undefined")
        return
    end
    local mesName = _parm_tab.name
    local params
    if _parm_tab.params then
        params = json2lua(_parm_tab.params)
    end
    if not _parm_tab.uuid then
        dump("UniWebViewMessageMgr Uuid Undefined")
    end
    dump(mesName, "UniWebViewMessageMgr HandleWebRequest mesName:")
    dump(params, "UniWebViewMessageMgr HandleWebRequest params:")
    Network.SendRequest(mesName, params, "请求数据", function(data)
        M.ConveyToWebPassive(mesName, _parm_tab.uuid, data)
    end)
end

--发送请求后返回的消息
function M.ConveyToWebPassive(messageName, uuid, luaData)
    local json_data = lua2json(luaData)
    local _data = {}
    _data[1] = uuid
    _data[2] = json_data
    dump(json_data, "<color=red>UniWebViewMessageMgr ConveyToWebPassive json_data:</color>")
    UniWebViewMgr.EvaluateJsToWeb(nil, passive_message_name, _data)
end

--主动推送的消息
function M.ConveyToWebPositive(messageName, luaData)
    local json_data = lua2json(luaData)
    local _data = {}
    _data[1] = "\"" .. messageName .. "\""
    _data[2] = json_data
    UniWebViewMgr.EvaluateJsToWeb(nil, positive_message_name, _data)
end

function  M.on_webview_notify(_, data)
    if UniWebViewMgr.IsWebOld() then
        return 
    end
    local funcName = data.name
    local json_data = lua2json(data.data)
    dump(data, "UniWebViewMessageMgr on_webview_notify data:")
    dump(json_data, "UniWebViewMessageMgr on_webview_notify json_data:")
    UniWebViewMgr.DoLocalFun(funcName, json_data)
end

--旧代码兼容:消息处理
function M.HandleOldMessage(_view,_message)
    if _message.Scheme == "uniwebviewfun" then
        if _message.Path == "Hide" then
            UniWebViewMgr.ChangeState(nil, "HIDE")
        end
    end
end