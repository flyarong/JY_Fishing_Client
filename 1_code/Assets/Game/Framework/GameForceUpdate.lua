--[[
	消息模板
		data = {
            {
                platform="normal",
                version="1.1.1",
                hash="jfqwieourqpwerwq",

                text="哈哈发生的废弃物额",
                button_ok="quit",
                button_cancel="relogin",
            },
            {
                platform="cjj",
                version="1.1.1",
                hash="jfqwieourqpwerwq",

                text="哈哈发生的废弃物额",
                button_ok="quit",
                button_cancel="relogin",
            },
        }
--]]

GameForceUpdate = {}

local map = {
    relogin = {btn="重新登陆"},
    quit = {btn="重新启动"},
    back = {btn="确定"},
}
local click_call = function (code)
	if code and code ~= "" then
		if code == "back" then
			
		elseif code == "relogin" then
			GameButtonManager.UnloadLua()
			MainLogic.GotoScene( "game_Login" )
		elseif code == "quit" then
			gameMgr:QuitAll()
		end
	end
end
GameForceUpdate.Call = function(data)
	local style = 1 -- 弹出的面板样式
	local left_code
	local right_code
    if data.button_ok and data.button_ok ~= "" then
        if data.button_cancel and data.button_cancel ~= "" then
        	left_code = data.button_ok
        	right_code = data.button_cancel
        	style = 6
        else
        	left_code = data.button_ok
        	style = 2
        end
    else
        if data.button_cancel and data.button_cancel ~= "" then
        	left_code = data.button_cancel
        	style = 2
        end
    end
	local pre = HintPanel.Create(style, data.text or "客户端有更新!",
	function ()
        click_call(left_code)
    end,function ()
        click_call(right_code)
    end)
    -- 1确定(改成关闭) 2确定加关闭 6确定加关闭加购买
    if style == 1 then
    	pre.cancelBtnEntity.gameObject:SetActive(true)
    	pre.confirmBtnEntity.gameObject:SetActive(false)
    end
    pre:SetButtonText(map[left_code] or "确定", map[right_code] or "确定")
end
