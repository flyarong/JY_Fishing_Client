-- 创建时间:2018-07-24

-- 顺序引导(暂时不支持非顺序引导)
-- isSkip 是否可以点击跳过
GuideConfig = {
	[1] = {stepList= {{step={1}, cfPos="hall"}}, next=-1, isSkip=0},
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
		name="@lwzb",
		auto=false, 
		isSave=true,
		
		desc="欢迎来到冲金鸡,让我们来消除萌宠获得奖励吧！",
		descPos={x=680, y=330, z=0},
		descRot={x=0, y=0, z=180},
		szPos={x=77, y=-137},
		npcPos={x=622, y=38, z=0},
		topsizeDelta = {x=526.3, y=628.2},
		bsdsmName = "click_xsyd_hyldcjj",
	},
}