-- 创建时间:2020-09-10
local basefunc = require "Game.Common.basefunc"

NetMsgSendManager = {}
local M = NetMsgSendManager

-- 发送消息接口
-- NetMsgSendManager.SendMsgQueue(name, args, JHData)

M.IsOnOff = true -- 功能开关
M.IsDebug = false -- 调试开关
M.send_hz = 0.05 -- 请求的频率

local update
local lister
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

    lister["main_model_finish_login_msg"] = M.on_main_model_finish_login_msg
    lister["OnLoginResponse"] = M.OnLoginResponse
    lister["EnterScene"] = M.OnEnterScene
    lister["ServerConnectException"] = M.OnServerConnectException
    lister["ServerConnectDisconnect"] = M.OnServerConnectDisconnect
    lister["ConnecteServerSucceed"] = M.OnConnecteServerSucceed
    lister["ReConnecteServerResponse"] = M.OnReConnecteServerResponse
    
end
function M.Init()
	M.Exit()
	MakeLister()
	AddLister()
	M.data = {}
	M.InitMsgData()
end
function M.Exit()
	RemoveLister()
	M.data = {}
end
function M.on_main_model_finish_login_msg()
	M.StartUpdate()
end
function M.StopUpdate()
	print("<color=red>net msg send ------- StopUpdate</color>")
	if update then
		update:Stop()
		M.data.last_send_msg_t = 0
	end
end
-- 按照一定频率请求
function M.StartUpdate()
	print("<color=red>net msg send ------- StartUpdate</color>")
	if not update then
		update = Timer.New(function (_, time_elapsed)
			M.UpdateSend(time_elapsed)
		end, 0.02, -1, nil, true)
	end
	if not update.running then
		update:Start()
		M.UpdateSend(0.02)
	end
end
function M.InitMsgData()
	if M.data then
		M.data.msg_list = {}
		M.data.last_send_msg_t = 0
		M.data.cur_send_data = nil
	end
end
-- 断线重连 登录完成
function M.OnReConnecteServerResponse()
	M.StartUpdate()
end
-- 连接建立
function M.OnConnecteServerSucceed()
	-- M.StartUpdate()
end
-- 异常断线
function M.OnServerConnectException()
	print("<color=red>net msg send ------- OnServerConnectException</color>")
	M.InitMsgData()
	M.StopUpdate()
end
-- 连接中断，或者被踢掉
function M.OnServerConnectDisconnect()
	print("<color=red>net msg send ------- OnServerConnectDisconnect</color>")
	M.InitMsgData()
	M.StopUpdate()
end
-- 正常 登录完成
function M.OnLoginResponse(result)
	if result ~= 0 then return end
end
-- 场景进入
function M.OnEnterScene()
	if MainModel.myLocation == "game_Login" then
		print("<color=red>net msg send ------- OnEnterScene</color>")
		M.InitMsgData()
		M.StopUpdate()
	end
end

function M.SortMsgList()
	MathExtend.SortListCom(M.data.msg_list, function (v1, v2)
		if v1.count < v2.count then
			return true
		else
			return false
		end
	end)
end
function M.AddMsgQueue(data)
	if not MainModel.IsConnectedServer then
		return false
	end

	if not M.data or not M.data.msg_list then
		return
	end

	if M.data.cur_send_data then
		-- 这条请求正在被执行
		if M.data.cur_send_data.name == data.name and basefunc.compare_value( M.data.cur_send_data.args , data.args , NOR_CONDITION_TYPE.EQUAL ) then
			dump(M.data.cur_send_data, "<color=red>||| abcd 这条请求正在被执行</color>")
			return
		end
	end

	local b = false
	for k,v in ipairs(M.data.msg_list) do
		if v.name == name and basefunc.compare_value( v.args , data.args , NOR_CONDITION_TYPE.EQUAL ) then
			v.count = v.count + 1 -- 请求次数增加可以导致排序靠前
			v.JHData = v.JHData or JHData
			M.SortMsgList()
			b = true
		end
	end
	if not b then
		M.data.msg_list[#M.data.msg_list + 1] = data
	end
	M.StartUpdate()
end

function M.SendMsgQueue(name, args, JHData)
	if M.IsOnOff then
		M.AddMsgQueue({name = name, args = args, JHData = JHData, count = 1})
	else
		Network.SendRequest(name , args, JHData)
	end
end
-- 优化:减少空执行
function M.ExtStopUpdate()
	M.StopUpdate()
end
function M.UpdateSend(time_elapsed)
	M.data.last_send_msg_t = M.data.last_send_msg_t + time_elapsed
	if not MainModel.IsConnectedServer then
		M.ExtStopUpdate()
		return false
	end

	if not M.data or not M.data.msg_list or #M.data.msg_list == 0 then
		M.ExtStopUpdate()
		return false
	end

	if M.data.cur_send_data then
		if M.data.last_send_msg_t > 3 then -- 一个请求3秒没有返回就放弃
			--Event.Brocast(M.data.cur_send_data.name .. "_response", M.data.cur_send_data.name, {result = 999}) -- todo:这个操作是否必要
			M.data.cur_send_data = nil
		else
			return false
		end
	end

	if not MainModel.UserInfo or not MainModel.UserInfo.user_id then
		M.ExtStopUpdate()
		return false
	end

	if M.data.last_send_msg_t < M.send_hz then
		return false
	end

	M.data.last_send_msg_t = 0
	M.data.cur_send_data = M.data.msg_list[1]
	table.remove(M.data.msg_list, 1)

	local msg = M.data.cur_send_data
	Network.SendRequest(msg.name, msg.args, msg.JHData, function (data)
		if M.IsDebug then
			dump(data, "<color=red>Update Send msg </color>")
			dump(msg)
			dump(M.data.msg_list)
			if data.result ~= 0 then
				print("<color=white>Error data.result " .. data.result .. "</color>")
			end
		end
		M.data.cur_send_data = nil
		Event.Brocast(msg.name .. "_response", msg.name, data)

		M.StartUpdate()
	end)
end

