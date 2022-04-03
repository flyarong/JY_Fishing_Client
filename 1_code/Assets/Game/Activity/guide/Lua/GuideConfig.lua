-- 创建时间:2018-07-24

-- 顺序引导(暂时不支持非顺序引导)
-- isSkip 是否可以点击跳过
GuideConfig = {
	{stepList= {{step={1,}, cfPos="hall"}}, next=2, isSkip=0},
	{stepList= {{step={2}, cfPos="by3d"}}, next=3, isSkip=0},
	{stepList= {{step={3}, cfPos="by3d"}}, next=4, isSkip=0},
	{stepList= {{step={4,5}, cfPos="by3d"}}, next=5, isSkip=0},
	{stepList= {{step={6,7}, cfPos="by3d"}}, next=-1, isSkip=0},
	-- [2] = {stepList= {{step={4,5,12,6,7,8,9}, cfPos="by3d"}, {step={11,5,12,6}, cfPos="hall"}}, next=3, isSkip=0},
}
--[[
1、选择游戏
2、大厅匹配场按钮，匹配场第一个场次
3、结算界面兑换按钮，确认兑换按钮
4、匹配场大厅返回按钮
5、大厅是兑换商城按钮
--]]

--[[
type= char对话 button按钮点击 GuideStyle1选择一块区域(功能描述引导)
name=内容
auto=是否连续执行
isHideBG=是否隐藏黑色背景
descPos=描述的位置
szPos=手指的偏移值
uiName=步骤所在UI的名字
topsizeDelta=区域大小
npcPos=NPC的位置
--]]
GuideNorStepConfig = {
	
	[1] = {
		id = 1,
		type="button",
		name="@Fishing3D",
		auto=false, 
		isSave=true,
		
		desc="欢迎来到捕鱼的世界\n让我们一起来体验全新的捕鱼吧",
		descPos={x=680, y=330, z=0},
		descRot={x=0, y=0, z=180},
		szPos={x=77, y=-137},
		npcPos={x=622, y=38, z=0},
		topsizeDelta = {x=526.3, y=628.2},
		code="Network.SendRequest(\"fsg_3d_signup\", {id = 1}, \"请求报名\", function (data) \
			if data.result == 0 then \
				GameManager.GotoSceneName(\"game_Fishing3D\", {game_id = 1}) \
			else \
				HintPanel.ErrorMsg(data.result) \
			end \
		end)",
		bsdsmName = "click_xsyd_djby",
	},
	
	--[[[2] = {
		id = 2,
		type="GuideStyle2",
		auto=false,
		isSave=false,
		
		desc="开炮就送福利券!快行动起来吧!",
		descPos={x=689, y=440, z=0},
		descRot={x=0, y=0, z=180},
		szPos={x=123, y=-24},
		npcPos={x=622, y=150, z=0},
		topsizeDelta = {x=328.3, y=150.9},
	},--]]
	[2] = {
		id = 2,
		type="GuideStyle2",
		name="",
		auto=false, 
		isSave=true,
		
		desc="欢迎来到海底世界,\n点击屏幕开始探险吧~",
		descPos={x=646, y=222, z=0},
		descRot={x=0, y=0, z=180},
		szPos={x=428, y=-50},
		npcPos={x=834, y=-46, z=0},
		topsizeDelta = {x=0, y=0},
		bsdsmName = "click_xsyd_kp",
	},	
	[3] = {
		id = 3,
		type="button",
		name="BY3DSHTXEnterPrefab",
		auto=false, 
		isSave=true,
		
		desc="太棒了,恭喜您完成任务!\n赶快领取奖励吧~",
		descPos={x=540, y=-160, z=0},
		descRot={x=0, y=0, z=180},
		szPos={x=39, y=-34},
		npcPos={x=614, y=-340, z=0},
		topsizeDelta = {x=262.1, y=201.1},
		bsdsmName = "click_xsyd_shtx",
	},
	[4] = {
		id = 4,
		type="button",
		name="@confirm_btn",--奖励弹窗确定按钮
		auto=false, 
		isSave=false,
		
		desc="点击确定获得奖励",
		descPos={x=285, y=131, z=0},
		descRot={x=0, y=0, z=180},
		szPos={x=39, y=-34},
		npcPos={x=422, y=-34, z=0},
		topsizeDelta = {x=262.1, y=201.1},
		--bsdsmName = "click_xsyd_jltc1",
	},
	[5] = {
		id = 5,
		type="button",
		name="XRQTLEnterPrefab_Old",
		auto=true, 
		isSave=true,
		
		desc="",
		descPos={x=540, y=-160, z=0},
		descRot={x=0, y=0, z=180},
		szPos={x=39, y=-34},
		npcPos={x=601, y=-127, z=0},
		topsizeDelta = {x=262.1, y=201.1},
		--bsdsmName = "click_xsyd_shtx",
	},	
	[6] = {
		id = 6,
		type="button",
		name="@confirm_btn",--奖励弹窗确定按钮
		auto=false, 
		isSave=false,
		
		desc="点击确定获得奖励",
		descPos={x=285, y=131, z=0},
		descRot={x=0, y=0, z=180},
		szPos={x=39, y=-34},
		npcPos={x=422, y=-34, z=0},
		topsizeDelta = {x=262.1, y=201.1},
		--bsdsmName = "click_xsyd_jltc1",
	},
	[7] = {
		id = 7,
		type="GuideStyle2",
		name="",
		auto=true, 
		isSave=true,
		
		desc="恭喜您完成全部新手任务!\n请前往更高场次继续挑战吧!",
		descPos={x=305, y=477, z=0},
		descRot={x=0, y=0, z=180},
		szPos={x=0, y=288},
		npcPos={x=442, y=200, z=0},
		topsizeDelta = {x=0, y=0},
		code="FishingModel.GotoFishingByID(2)",
		--bsdsmName = "click_xsyd_shtx",
	},			
}