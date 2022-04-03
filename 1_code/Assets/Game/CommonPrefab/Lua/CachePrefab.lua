-- 创建时间:2019-01-10

local basefunc = require "Game.Common.basefunc"

CachePrefab = basefunc.class()
local C = CachePrefab

function C.Create(prefabname, parent, tmp)
	return C.New(prefabname, parent, tmp)
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

function C:ctor(prefabname, parent, tmp)
    -- ExtPanel.ExtMsg(self)
    if tmp then
        self.prefabObj = GameObject.Instantiate(tmp, parent)
    else
        self.prefabObj = GameObject.Instantiate(GetPrefab(prefabname), parent)
    end
    self.gameObject = self.prefabObj
end

function C:MyExit()
    destroy(self.gameObject)
end

function C:GetObj()
	return self.prefabObj
end

function C:SetObjName(name)
    if IsEquals(self.prefabObj) then
        self.prefabObj.name = name
    end
end
function C:SetParent(parent)
	if IsEquals(parent) and IsEquals(self.prefabObj) then
		self.prefabObj.transform:SetParent(parent)
	end
end
