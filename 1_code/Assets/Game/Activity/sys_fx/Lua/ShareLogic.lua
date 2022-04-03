
ShareLogic = {}
ShareLogic.size = 300
-- 获取分享的图片路径
function ShareLogic.GetImagePath()
    if not Directory.Exists(resMgr.DataPath) then
        Directory.CreateDirectory(resMgr.DataPath)
    end

    local path = resMgr.DataPath .. "wx_share.jpg"
    return path
end

local function HandleShareCallback(json_data, callback, key)
	local parm_lua = json2lua(json_data)
	if parm_lua == nil then
		print(string.format("[Share] %s result invalid", key))
		return
	end

	dump(parm_lua, "[Share] " .. key)

	if parm_lua.result == 0 and callback then
		callback("OK")
	elseif parm_lua.result < 0 then
		if parm_lua.result == -5 then
			if parm_lua.errno == -2 then
				HintPanel.ErrorMsg(3046)
			else
				local channel = MainModel.LoginInfo.channel_type or ""
				HintPanel.Create(1, "分享异常(" .. channel .. ":" .. parm_lua.errno .. ")")
			end
		elseif parm_lua.result == -8 then
			HintPanel.ErrorMsg(3046)
		else
			HintPanel.ErrorMsg(parm_lua.result)
		end
	end
end

-- 主版本
local ShareImage_main = function (parm, callback)
	local parm_lua = json2lua(parm)
	local type = parm_lua.type or 7
	dump(parm,"<color=white>分享图片？？？？？</color>")
	if type == 7 and not parm_lua.icon then
		parm_lua.icon = ShareLogic.GetImagePath()
		dump(parm_lua.icon,"<color=white>保存的图片？？？？？</color>")
	end
	if not ShareLogic.CheckIsCJJ() then

		local pre = HintPanel.Create(1,"已成功将图片保存到相册，请前往微信打开相册进行分享",function (  )
			if gameRuntimePlatform == "Ios" then
				Application.OpenURL("weixin://")
			elseif gameRuntimePlatform == "Android" then
				sdkMgr:OpenApp("com.tencent.mm","http://weixin.qq.com/")
			end
		end)
		callback("OK")
	    local father = GameObject.Instantiate(GetPrefab("LayerLv50"), GameObject.Find("Canvas").transform)
		father.transform:GetComponent("Canvas").sortingOrder = 100
		pre.transform:SetParent(father.transform)
		return
	end

	if gameRuntimePlatform ~= "Ios" and gameRuntimePlatform ~= "Android" then
		if callback then callback("OK") end
		return
	end
	parm = lua2json(parm_lua)
	sdkMgr:Share(parm, function (json_data)
		HandleShareCallback(json_data, callback, "ShareImage_main")
	end)
end
local ShareURL_main = function (parm, callback)
	if not ShareLogic.CheckIsCJJ() then
		if gameRuntimePlatform == "Ios" then
			Application.OpenURL("weixin://");
		elseif gameRuntimePlatform == "Android" then
			sdkMgr:OpenApp("com.tencent.mm","http://weixin.qq.com/")
		end
		callback("OK")
		return
	end

	if gameRuntimePlatform ~= "Ios" and gameRuntimePlatform ~= "Android" then
		if callback then callback("OK") end
		return
	end
	sdkMgr:Share(parm, function (json_data)
		HandleShareCallback(json_data, callback, "ShareURL_main")
	end)
end

-- 分享的统一接口
function ShareLogic.ShareGM(parm, callback)
	local channel = MainModel.LoginInfo.channel_type

	channel = channel or ""
	if channel == "" then
		print("[Share] ShareURL failed: channel invalid")
		return
	end
	local parm_lua = json2lua(parm)
	local type = parm_lua.type or 3
	if type == 7 then
		ShareImage_main(parm, callback)
	else
		ShareURL_main(parm, callback)
	end
end


function ShareLogic.CheckIsCJJ()
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "cpl_cjj", is_on_hint = true}, "CheckCondition")
	if a and b then
		return true
	end
	return false
end