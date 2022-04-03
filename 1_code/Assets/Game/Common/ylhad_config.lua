return 
{
	---banner广告
	banner = 
	{
		coid_id = "3041660617527441",
		ad_cd = 10,  --广告cd
		all_time_limit_num = 3,   --在限定范围的最大次数
		all_time = 60, --范围60s
		x = 640,
		y = 100,
		autoSwitchInterval = 0, --是否自动刷新banner  0= false
	},
	----插屏广告
	Intersititial = 
	{
		coid_id = "4011262677825395",
		ad_cd = 10,  --广告cd
		all_time_limit_num = 5,   --在限定范围的最大次数
		all_time = 60, --范围60s
		isVideoMuted = true,   --是否静音
		isDetailVideoMuted = true,
		minV = 5,	--设置拉取视频的最短时长 s
		maxV = 10,	--设置拉取视频的最长时长 s
	},
	-----激励视频
	RewardVideoAd = 
	{
		jjj =     				--低保
		{
			coid_id = "4061881405143578",
		},
		ggy = 				--广告鱼
		{
			coid_id = "5071683405342660",
		},
		mfcj = 			--免费抽奖
		{
			coid_id = "9091981415649529",
		},
	}
}