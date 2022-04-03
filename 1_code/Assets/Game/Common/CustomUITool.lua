-- 创建时间:2020-07-01
-- 定制UI的工具

CustomUITool = {}
local M = CustomUITool

M.UIType = {
	Ret = typeof(UnityEngine.RectTransform),
	Img = typeof(UnityEngine.UI.Image),
	Txt = typeof(UnityEngine.UI.Text),
}
--[[
	name:"abc"
--]]

M.CreateUI = function (parm, parent)
	local obj
	if parm.type == "Rect" then
		obj = M.CreateRect(parm, parent)
	elseif parm.type == "Image" then
		obj = M.CreateImage(parm, parent)
	elseif parm.type == "Text" then
		obj = M.CreateText(parm, parent)
	end

	if parm.child and #parm.child > 0 then
		for k,v in ipairs(parm.child) do
			M.CreateUI(v, obj.transform)
		end
	end
	return obj
end
M.CreateRect = function (parm, parent)
	local obj = GameObject.New()
	obj.name = parm.name
	obj.transform:SetParent(parent)

	local rect = obj.gameObject:AddComponent(M.UIType.Ret)
	rect.sizeDelta = parm.size
	rect.transform.position = parm.pos or Vector3.zero
	rect.transform.localScale = parm.scale or Vector3.one

	return obj
end

-- CustomUITool.CreateImage({name="obj_img", size={x=600,y=600},pos={x=0,y=300,z=0},sprite="pay_icon_gold11"})
M.CreateImage = function (parm, parent)
	local obj = M.CreateRect(parm, parent)

	local img = obj.gameObject:AddComponent(M.UIType.Img)
	img.sprite = GetTexture(parm.sprite)
	if parm.color then
		img.color = parm.color
	end

	return obj
end

M.CreateText = function (parm, parent)
	local obj = M.CreateRect(parm, parent)

	local txt = obj.gameObject:AddComponent(M.UIType.Txt)
	if parm.font then
		txt.font = GetFont(parm.font)
	else
		txt.font = GetFont("FZY4JW.TTF")
	end
	txt.text = parm.text or ""
	if parm.color then
		txt.color = parm.color
	end
	if parm.dq then
		txt.alignment = parm.dq
	else
		txt.alignment = UnityEngine.TextAnchor.MiddleCenter
	end
	txt.fontSize = 50

	txt.horizontalOverflow = UnityEngine.HorizontalWrapMode.Overflow

	return obj
end
