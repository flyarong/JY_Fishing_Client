-- 创建时间:2018-07-14

----------------------------------------正常开关------------------------------------------
local GameGlobalOnOff_Default = 
 {
 	QIYE = false,	--企业版
	LIBAO = true,	--礼包开关
	IOSTS = false,	--IOS提审
	InternalTest = false, --内测

	AppleHall 	= false, --大厅显示方式
 	WXLoginChangeToYK = false, --微信登录改为游客
 	Diversion = true, --导流
	Share = true,--分享
	ShowOff = true, --炫耀
	InviteFriends = true,--邀请好友
 	Notify = true, --广播
	IsOpenGuide = false, -- 是否开启新手引导
	IsOpenFishingGuide = true, --是否开启捕鱼新手引导 
	
	LoginProxy		= false,-- 登陆代理
 	WXLogin 		= false,-- 微信登录
 	YKLogin 		= true,-- 游客登录
 	PhoneLogin 		= true,-- 电话号码登录
 	Version 		= true,-- 版本信息
 	PGPay 			= false,-- 苹果支付
 	PGPayFun 		= false,-- 苹果支付是否是沙盒
 	WXPay 			= true,-- 微信支付
 	ZFBPay 			= true,-- 支付宝支付
 	JPQTool 		= true,-- 记牌器
 	PlayerInfo		= true,-- 个人中心
 	Banner			= true,-- 大厅左侧广告页
 	RedPacket		= true,-- 福利券
 	Million			= true,-- 百万大奖赛
	Exchange		= true,-- 兑换
	GetGlod			= true,--赚金币
	CityActivity	= false,--城市杯活动
 	Store			= false,-- 实体店
	FPS				= true,-- FPS Log 清楚帐号
	ChangeCity     	= true,--切换城市
	CharityFund		= false,--公益基金
	DDZFree 		= true,--练习场
	Fishing			= true,--捕鱼
	FishingTask		= true,--捕鱼任务
	FishingMatch		= true,--捕鱼大奖赛
	FishingDR		= true,--疯狂捕鱼
	Activity_XYCJ	= true,--幸运抽奖
	MatchUrgencyClose	= false,--比赛场紧急关闭

 	-- 商城
 	Shop			= true,-- 商城入口
 	ShopJB			= true,-- 商城金币
 	ShopZS			= true,-- 商城钻石
 	ShopDJ			= true,-- 商城道具
	ShopFK			= true,-- 商城房卡
	ShopBQ			= true,-- 商城表情
	ShopExpressionHintXYCJ      = true,--购买50万金币弹出提示
	-- 快速充值
	PayZS			= true,--快速购买钻石
	--城市杯决赛排行榜
	CityFinalRank = true,
	Shop_10_gift_bag = true,--1元福利礼包

	Activity = true,
	Honor = true,--荣誉开关
	Task = false,--任务开关
	Vip = true,--vip开关
	BBSC_Task = true,--新人红包
	Money_Center = false,--财富中心
	GoldenPig = true,--金猪大礼包
	VIPGift = true,--VIP礼包
	ZJD = true,--砸金蛋
	ZJD_EVE = true,	--砸金蛋活动

	LayerGroup = false,	--ui层级管理

	XXLSkipAllAni = false,	--消消乐跳过所有动画

	
	MulticastMsg = true, --广播消息
	BindingPhone = true, --绑定手机
	Certification = true, --实名认证
	OpenInstall = false,--openinstall
	TestSendPostBSDS = true,--上传web数据测试地址
	ActByWebView = false, --运营活动WebView显示
}

----------------------------------------ios热更新------------------------------------------

local GameGlobalOnOff_Ios = 
 {
 	QIYE = false,	--企业版
	LIBAO = true,	--礼包开关
	IOSTS = false,	--IOS提审
	InternalTest = false, --内测

	AppleHall 	= false, --大厅显示方式
 	WXLoginChangeToYK = false, --微信登录改为游客
 	Diversion = true, --导流
	Share = true,--分享
	ShowOff = true, --炫耀
	InviteFriends = true,--邀请好友
 	Notify = true, --广播
	IsOpenGuide = false, -- 是否开启新手引导
	IsOpenFishingGuide = true, --是否开启捕鱼新手引导 
	
 	WXLogin 		= false,-- 微信登录
	YKLogin 		= false,-- 游客登录
	PhoneLogin 		= true,-- 电话号码登录
 	Version 		= true,-- 版本信息
 	PGPay 			= false,-- 苹果支付
 	PGPayFun 		= false,-- 苹果支付是否是沙盒
 	WXPay 			= true,-- 微信支付
 	ZFBPay 			= true,-- 支付宝支付
 	JPQTool 		= true,-- 记牌器
 	PlayerInfo		= true,-- 个人中心
 	Banner			= true,-- 大厅左侧广告页
 	RedPacket		= true,-- 福利券
 	Million			= true,-- 百万大奖赛
	Exchange		= true,-- 兑换
	GetGlod			= true,--赚金币
	CityActivity	= false,--城市杯活动
 	Store			= true,-- 实体店
	FPS				= false,-- FPS Log 清楚帐号
	ChangeCity     	= true,--切换城市
	CharityFund		= false,--公益基金
	DDZFree 		= true,--练习场
	Fishing			= true,--捕鱼
	FishingTask		= true,--捕鱼任务
	FishingMatch		= true,--捕鱼大奖赛
	FishingDR		= true,--疯狂捕鱼
	Activity_XYCJ	= true,--幸运抽奖
	MatchUrgencyClose	= false,--比赛场紧急关闭

 	-- 商城
 	Shop			= true,-- 商城入口
 	ShopJB			= true,-- 商城金币
 	ShopZS			= true,-- 商城钻石
 	ShopDJ			= true,-- 商城道具
	ShopFK			= true,-- 商城房卡
	ShopBQ			= true,-- 商城表情
	ShopExpressionHintXYCJ      = true,--购买50万金币弹出提示
	-- 快速充值
	PayZS			= true,--快速购买钻石
	--城市杯决赛排行榜
	CityFinalRank = false,
	Shop_10_gift_bag = true,--1元福利礼包

	Activity = true,
	Honor = true,--荣誉开关
	Task = false,--任务开关
	Vip = true,--vip开关
	BBSC_Task = true,--新人红包
	Money_Center = false,--财富中心
	GoldenPig = true,--金猪大礼包
	VIPGift = true,--VIP礼包
	ZJD = true,--砸金蛋
	ZJD_EVE = true,	--砸金蛋活动

	LayerGroup = false,	--ui层级管理

	XXLSkipAllAni = false,	--消消乐跳过所有动画
	
	MulticastMsg = true, --广播消息
	BindingPhone = true, --绑定手机
	Certification = true, --实名认证
	OpenInstall = false,--openinstall
	TestSendPostBSDS = false,--上传web数据测试地址
	ActByWebView = true, --运营活动WebView显示
}

----------------------------------------安卓开关------------------------------------------

local GameGlobalOnOff_Android = 
 {
 	QIYE = false,	--企业版
	LIBAO = true,	--礼包开关
	IOSTS = false,	--IOS提审
	InternalTest = false, --内测

	AppleHall 	= false, --大厅显示方式
 	WXLoginChangeToYK = false, --微信登录改为游客
 	Diversion = true, --导流
	Share = true,--分享
	ShowOff = true, --炫耀
	InviteFriends = true,--邀请好友
 	Notify = true, --广播
	IsOpenGuide = false, -- 是否开启新手引导
	IsOpenFishingGuide = true, --是否开启捕鱼新手引导 
	
 	WXLogin 		= false,-- 微信登录
	YKLogin 		= false,-- 游客登录
	PhoneLogin 		= true,-- 电话号码登录
 	Version 		= true,-- 版本信息
 	PGPay 			= false,-- 苹果支付
 	PGPayFun 		= false,-- 苹果支付是否是沙盒
 	WXPay 			= true,-- 微信支付
 	ZFBPay 			= true,-- 支付宝支付
 	JPQTool 		= true,-- 记牌器
 	PlayerInfo		= true,-- 个人中心
 	Banner			= true,-- 大厅左侧广告页
 	RedPacket		= true,-- 福利券
 	Million			= true,-- 百万大奖赛
	Exchange		= true,-- 兑换
	GetGlod			= true,--赚金币
	CityActivity	= false,--城市杯活动
 	Store			= true,-- 实体店
	FPS				= false,-- FPS Log 清楚帐号
	ChangeCity     	= true,--切换城市
	CharityFund		= false,--公益基金
	DDZFree 		= true,--练习场
	Fishing			= true,--捕鱼
	FishingTask		= true,--捕鱼任务
	FishingMatch		= true,--捕鱼大奖赛
	FishingDR		= true,--疯狂捕鱼
	Activity_XYCJ	= true,--幸运抽奖
	MatchUrgencyClose	= false,--比赛场紧急关闭

 	-- 商城
 	Shop			= true,-- 商城入口
 	ShopJB			= true,-- 商城金币
 	ShopZS			= true,-- 商城钻石
 	ShopDJ			= true,-- 商城道具
	ShopFK			= true,-- 商城房卡
	ShopBQ			= true,-- 商城表情
	ShopExpressionHintXYCJ      = true,--购买50万金币弹出提示
	-- 快速充值
	PayZS			= true,--快速购买钻石
	--城市杯决赛排行榜
	CityFinalRank = true,
	Shop_10_gift_bag = true,--1元福利礼包

	Activity = true,
	Honor = true,--荣誉开关
	Task = false,--任务开关
	Vip = true,--vip开关
	BBSC_Task = true,--新人红包
	Money_Center = false,--财富中心
	GoldenPig = true,--金猪大礼包
	VIPGift = true,--VIP礼包
	ZJD = true,--砸金蛋
	ZJD_EVE = true,	--砸金蛋活动

	LayerGroup = false,	--ui层级管理

	XXLSkipAllAni = false,	--消消乐跳过所有动画
	
	MulticastMsg = true, --广播消息
	BindingPhone = true, --绑定手机
	Certification = true, --实名认证
	OpenInstall = false,--openinstall
	TestSendPostBSDS = false,--上传web数据测试地址
	ActByWebView = true, --运营活动WebView显示
}

if gameRuntimePlatform == "Ios" then
	GameGlobalOnOff = GameGlobalOnOff_Ios
elseif gameRuntimePlatform == "Android" then
	GameGlobalOnOff = GameGlobalOnOff_Android
else
	GameGlobalOnOff = GameGlobalOnOff_Default
end

--force
-- GameGlobalOnOff = GameGlobalOnOff_Ios
-- GameGlobalOnOff = GameGlobalOnOff_Android
-- GameGlobalOnOff = GameGlobalOnOff_Default
