-- 创建时间:2021-02-02
-- CommonMiniGameManager 管理器

local basefunc = require "Game/Common/basefunc"
CommonMiniGameManager = {}
local M = CommonMiniGameManager
local config = ext_require("Game.CommonPrefab.Lua.mini_game_config")

local this
local lister

function M.Init()
	M.Exit()

	this = CommonMiniGameManager
	this.m_data = {}
	M.InitUIConfig()
end
function M.Exit()
	if this then
		this = nil
	end
end

function M.InitUIConfig()
    this.UIConfig = {}

    this.UIConfig.config_map = {}
    for k,v in pairs(config.game) do
        this.UIConfig.config_map[v.pre_name] = v
        this.UIConfig.config_map[v.key] = v
        if v.bigpre_name then this.UIConfig.config_map[v.bigpre_name] = v end
    end
end

--检查该小游戏应该显示还是隐藏
function M.CheckMiniGameIsCanShow(tag)
    if this.UIConfig.config_map[tag].permission then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = this.UIConfig.config_map[tag].permission, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    else
        return true
    end
end

--检查进入小游戏的条件并弹出提示
function M.CheckMiniGameIsOnHint(tag)
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = this.UIConfig.config_map[tag].codin, is_on_hint = false}, "CheckCondition")
    if a and not b then
        return false
    end
    return true
end

--初始化小游戏入口的遮罩(HintLock_lv = 遮罩,btn_fun = 遮罩的按钮监听的方法)
function M.InitMiniGameEnterMask(tag,HintLock_lv,btn_fun)
    local v = this.UIConfig.config_map[tag]
    local lock_txt = HintLock_lv.transform:Find("@lock_txt").transform:GetComponent("Text")
    if v.conditions_type == 1 and v.conditions_num then
        lock_txt.text = "Lv"..v.conditions_num[1].."解锁"
    elseif v.conditions_type == 2 then
        lock_txt.text = "VIP"..v.conditions_num[2].."解锁"
    elseif v.conditions_type == 3 then
        lock_txt.text = "Lv"..v.conditions_num[1].."且VIP"..v.conditions_num[2].."解锁" 
    elseif v.conditions_type == 4 then
        lock_txt.text = "Lv"..v.conditions_num[1].."或VIP"..v.conditions_num[2].."解锁" 
    end
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = v.codin, is_on_hint = true}, "CheckCondition")
    if a and not b then
        HintLock_lv.gameObject:SetActive(true)
    else
        HintLock_lv.gameObject:SetActive(false)
    end
    local btn = HintLock_lv.transform:Find("@tip_btn").gameObject:GetComponent("Button")
    btn.onClick:AddListener(btn_fun)
end

