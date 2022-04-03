-- 创建时间:2018-10-15
GameMatchLogic = {}
local this -- 单例
local model

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
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["OnLoginResponse"] = this.OnLoginResponse
end

function GameMatchLogic.Init()
    GameMatchLogic.Exit()
    this = GameMatchLogic
    MakeLister()
    AddLister()
    return this
end

function GameMatchLogic.Exit()
	if this then
		model.Exit()
		model = nil
		RemoveLister()
		this = nil
	end
end

--正常登录成功
function GameMatchLogic.OnLoginResponse(result)
    print("<color=red>GameMatchLogic:正常登录成功</color>")
    if result==0 then
    	if model then
    		model.Exit()
    	end
    	model = GameMatchModel.Init()
    else
    end
end

--断线重连后登录成功
function GameMatchLogic.OnReConnecteServerSucceed(result)
end
