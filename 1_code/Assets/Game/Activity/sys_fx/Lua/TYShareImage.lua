-- 创建时间:2018-07-16

local basefunc = require "Game.Common.basefunc"

TYShareImage = basefunc.class()
local C = TYShareImage
C.name = "TYShareImage"

function C.Create(parm)
    return C.New(parm)
end

function C:MyExit()
    destroy(self.gameObject)
end

function C:ctor(parm)
    self.parm = parm

    local parent = GameObject.Find("Canvas/LayerLv5").transform
    local obj = newObject(C.name, parent)
    local tran = obj.transform
    self.gameObject = obj
    self.transform = obj.transform
    LuaHelper.GeneratingVar(self.transform, self)
    self:InitUI()
end
function C:InitUI()
    self.yqm_txt.text = "玩家ID：" .. MainModel.UserInfo.user_id
    SYSFXManager.EWM(self.ewm_img.mainTexture, self.parm.url)
    if self.parm.msg.share_bg then
        self.share_img.sprite = GetTexture(self.parm.msg.share_bg)
    end
end
function C:RunMake(path, call)
    SYSFXManager.CreateShareImage(self.gameObject, self.node1.position, self.node2.position, function ()
        self:MyExit()
        if call then
            call()
        end
    end, nil, path)
end

