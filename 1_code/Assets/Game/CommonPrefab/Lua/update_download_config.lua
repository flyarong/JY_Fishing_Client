return {
	info=
	{
		---------------------
		-- 欢乐天天捕鱼
		---------------------		
		normal=
		{
			platform = "normal",
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/hlby_android.apk",
			ios_url="itms-services://?action=download-manifest&url=https://cdndownload.game3396.com/install/ios/qiye/hlttby/normal_normal.plist",
		},
		juxiang=
		{
			platform = "normal",
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/hlby_juxiang.apk",
			ios_url="itms-services://?action=download-manifest&url=https://cdndownload.game3396.com/install/ios/qiye/hlttby/normal_juxiang.plist",
		},
		pceggs=
		{
			platform = "normal",
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/hlby_pceggs.apk",
			ios_url="itms-services://?action=download-manifest&url=https://cdndownload.game3396.com/install/ios/qiye/hlttby/normal_pceggs.plist",
		},
		xianwan=
		{
			platform = "normal",
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/hlby_xianwan.apk",
			ios_url="itms-services://?action=download-manifest&url=https://cdndownload.game3396.com/install/ios/qiye/hlttby/normal_xianwan.plist",
		},
		duoliang=
		{
			platform = "normal",
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/hlby_duoliang.apk",
		},
		aibianxian=
		{
			platform = "normal",
			ios_url = "itms-services://?action=download-manifest&url=https://cdndownload.game3396.com/install/ios/qiye/hlttby/normal_aibianxian.plist",
		},
		juxiangpc=
		{
			platform = "normal",
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/hlby_juxiangpc.apk",
		},

		---------------------
		-- 冲金鸡
		---------------------
		cjj=
		{
			platform = "cjj",
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/hlby_cjj.apk",
		},
		cjj_juxiang=
		{
			platform = "cjj",
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/hlby_cjj_juxiang.apk",
			ios_url="itms-services://?action=download-manifest&url=https://cdndownload.game3396.com/install/ios/qiye/cjj/cjj_cjj_juxiang.plist",
		},
		cjj_pceggs=
		{
			platform = "cjj",
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/hlby_cjj_pceggs.apk",
			ios_url="itms-services://?action=download-manifest&url=https://cdndownload.game3396.com/install/ios/qiye/cjj/cjj_cjj_pceggs.plist",
		},
		cjj_xianwan=
		{
			platform = "cjj",
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/hlby_cjj_xianwan.apk",
			ios_url="itms-services://?action=download-manifest&url=https://cdndownload.game3396.com/install/ios/qiye/cjj/cjj_cjj_xianwan.plist",
		},
		cjj_juxiangpc=
		{
			platform = "cjj",
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/hlby_cjj_juxiangpc.apk",
			--ios_url="itms-services://?action=download-manifest&url=https://cdndownload.game3396.com/install/ios/qiye/cjj/cjj_cjj_juxiangpc.plist",
			ios_url = "itms-services://?action=download-manifest&url=https://cdndownload.game3396.com/install/ios/qiye/cjj/cjj_aibianxian.plist",
		},
		cjj_zhuankebao=
		{
			platform = "cjj",
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/hlby_cjj_zhuankebao.apk",
		},
		cjj_aibianxian=
		{
			platform = "cjj",
			ios_url = "itms-services://?action=download-manifest&url=https://cdndownload.game3396.com/install/ios/qiye/cjj/cjj_aibianxian.plist",
		},
	},

	---------------------
	-- 默认配置，如果渠道找不到就按平台的官方url下载
	---------------------
	platform_info={
		normal={
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/hlby_android.apk",
			ios_url="itms-services://?action=download-manifest&url=https://cdndownload.game3396.com/install/ios/qiye/hlttby/normal_normal.plist",
		},
		cjj={
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/hlby_cjj_pceggs.apk",
			ios_url="itms-services://?action=download-manifest&url=https://cdndownload.game3396.com/install/ios/qiye/cjj/cjj_cjj_pceggs.plist",
		},
	},

	-------------------
	-- 落地页
	-------------------
	landing_page={
		normal="http://cwww.game3396.com/webpages/hlbyDownload.html?platform=normal&market_channel=normal&pageType=normal&category=1",
		cjj="http://cwww.game3396.com/webpages/hlbyDownload.html?platform=cjj&market_channel=cjj&pageType=cjj&category=1",
	}
}