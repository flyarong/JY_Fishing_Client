-- 创建时间:2020-05-06
-- Panel:Act_TY_BY_HHLPanel
--[[
*      ┌─┐       ┌─┐
*   ┌──┘ ┴───────┘ ┴──┐
*   │                 │
*   │       ───       │
*   │  ─┬┘       └┬─  │
*   │                 │
*   │       ─┴─       │
*   │                 │
*   └───┐         ┌───┘
*       │         │
*       │         │
*       │         │
*       │         └──────────────┐
*       │                        │
*       │                        ├─┐
*       │                        ┌─┘
*       │                        │
*       └─┐  ┐  ┌───────┬──┐  ┌──┘
*         │ ─┤ ─┤       │ ─┤ ─┤
*         └──┴──┘       └──┴──┘
*                神兽保佑
*               代码无BUG!
--]]

local basefunc = require "Game/Common/basefunc"

Act_TY_BY_HHLPanel = basefunc.class()
local C = Act_TY_BY_HHLPanel
C.name = "Act_TY_BY_HHLPanel"
local M = Act_TY_BY_HHLManager
C.instance = nil


function C.Create(parent, backcall, cfg)
	return C.New(parent, backcall, cfg)
end

function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	-- 数据的初始化和修改
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
	self.lister["model_hhl_data_change_msg"] = basefunc.handler(self,self.MyRefresh)
end

function C:OnDestroy()
	self:MyExit()
end


function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	self:CloseItemPrefab()
	self:RemoveListener()
	if self.cutdown_timer then
		self.cutdown_timer:Stop()
	end
	C.instance = nil
	destroy(self.gameObject)
end

function C:ctor(parent, backcall, cfg)
	self.config = cfg
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	
	local config=M.GetActivityConfig()
	if config.act_time and config.act_time~=""then
		local sta_t = self:GetFortTime(config.beginTime)
		local end_t = self:GetFortTime(config.endTime)
		self.cutdown_txt.text=sta_t .."-".. end_t
	else
		self.cutdown_timer=CommonTimeManager.GetCutDownTimer(config.endTime,self.cutdown_txt)
	end
	EventTriggerListener.Get(self.help_btn.gameObject).onClick = basefunc.handler(self, self.OnHelpClick)
	M.QueryGiftData()
end
function C:GetFortTime(_time)
    return string.sub(os.date("%m月%d日%H:%M",_time),1,1) ~= "0" and os.date("%m月%d日%H:%M",_time) or string.sub(os.date("%m月%d日%H:%M",_time),2)
end
function C:MyRefresh()
	self.cur_data = M.GetCurData()
	local infor_tab = GameItemModel.GetItemToKey(self.config.item_key)
	self.my_txt.text = "我的"..infor_tab.name..":"
 	local sta_t = string.sub(os.date("%m月%d日%H:%M",self.config.beginTime),1,1) ~= "0" and os.date("%m月%d日%H:%M",self.config.beginTime) or string.sub(os.date("%m月%d日%H:%M",self.config.beginTime),2)
 	local end_t = string.sub(os.date("%m月%d日%H:%M:%S",self.config.endTime),1,1) ~= "0" and os.date("%m月%d日%H:%M:%S",self.config.endTime) or string.sub(os.date("%m月%d日%H:%M:%S",self.config.endTime),2)
	self.title_txt.text = "活动时间：".. sta_t .."-".. end_t
	self.myitem_img.sprite = GetTexture(infor_tab.image)
	self.myitem_img.gameObject:SetActive(true)
	self.user_has_item_txt.text = GameItemModel.GetItemCount(self.config.item_key)
	self.btm_desc_txt.text = "充值商城中每日首次购买金币，必得"..infor_tab.name.."！"
	if self.cur_data then
		SetTextureExtend(self.help_btn.transform:GetComponent("Image"),self.config.cur_path.."imgf_hdgz")
		self.bg_img.sprite = GetTexture(self.config.cur_path.."bg_1")
		self:CreateItemPrefab()
	end

	--根据平台显示不同Ui
	self.tip_txt.gameObject:SetActive(false)

	local cur_config=M.GetCurConfig()
	if cur_config.tip_str and cur_config.tip_str~="" then
		self.tip_txt.text=cur_config.tip_str
		self.tip_txt.gameObject:SetActive(true)
	end
end

function C:CreateItemPrefab()
	local m_sort = function(v1,v2)
		if v1.is_min_cost and not v2.is_min_cost then
			return false
		elseif not v1.is_min_cost and v2.is_min_cost then
			return true
		else
			if v1.remain_time == 0 and v2.remain_time ~= 0 then
				return true
			elseif v1.remain_time ~= 0 and v2.remain_time == 0 then
				return false
			else
				if v1.ID < v2.ID then
					return false
				else
					return true
				end

			end
		end
	end

	MathExtend.SortListCom(self.cur_data, m_sort)
	self:CloseItemPrefab()
	for i=1, #self.cur_data do
		local pre = Act_TY_BY_HHLItemBase.Create(self.Content.transform, self.cur_data[i], self.config)
		self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
	end
end

function C:CloseItemPrefab()
	if self.spawn_cell_list then
		for k,v in ipairs(self.spawn_cell_list) do
			v:MyExit()
		end
	end
	self.spawn_cell_list = {}
end

function C:OnHelpClick()
	self:OpenHelpPanel()
end

function C:GetCurHelpInfor()
	local infor_tab = GameItemModel.GetItemToKey(self.config.item_key)
    local name = infor_tab.name
    local help_desc = {
	"1.活动期间，所有游戏中随机掉落"..name.."，积累"..name.."可兑换奖励。玩高倍场可获得更多"..name.."！",
	"2.活动结束后，所有"..name.."统一清除，请及时进行奖励兑换。",
	"3.实物奖励请关注公众号4008882620联系在线客服领取。",
	"4.5万福利券为VIP5及以上专享，1万福利券为VIP4及以上专享，700万金币为VIP3及以上专享。",
	--"4.笔记本电脑为VIP5及以上用户专享奖励。",
	--"5.实物图片仅供参考，请以实际发出的奖励为准。",
	}
    -- local sta_t = self:GetStart_t()
    -- local end_t = self:GetEnd_t()
    -- help_desc[1] = "1.活动时间：".. sta_t .."-".. end_t
    return help_desc
end

function C:GetStart_t()
    return string.sub(os.date("%m月%d日%H:%M",self.config.beginTime),1,1) ~= "0" and os.date("%m月%d日%H:%M",self.config.beginTime) or string.sub(os.date("%m月%d日%H:%M",self.config.beginTime),2)
end

function C:GetEnd_t()
    return string.sub(os.date("%m月%d日%H:%M:%S",self.config.endTime),1,1) ~= "0" and os.date("%m月%d日%H:%M:%S",self.config.endTime) or string.sub(os.date("%m月%d日%H:%M:%S",self.config.endTime),2)
end

function C:OpenHelpPanel()
	local str
	local help_info = self:GetCurHelpInfor()
	str = help_info[1]
	for i = 2, #help_info do
		str = str .. "\n" .. help_info[i]
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform, "IllustratePanel_New")
end
