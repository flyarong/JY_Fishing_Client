-- 创建时间:2020-10-22

return {
	title = {"神秘海域","海底宝藏","藏宝海湾","深海沉船"},
	refreshtime = "每日10:00刷新",
	help_list = 
	{	
		[1] = {
			LeftName = "积分规则",
			RightPrefab = "by3dphb_rules_hgb_pre1",
		},
		[2] = {
			LeftName = "排名奖励",
			RightPrefab = "by3dphb_rules_hgb_pre2",
		},
	},
	rank_list = 
	{
		[1] = {
			rank = {1,1},
			award_img = {"ty_icon_flq3"},
			award_txt = {"10000福利券"},
		},
		[2] = {
			rank = {2,2},
			award_img = {"ty_icon_flq2"},
			award_txt = {"9000福利券"},
		},
		[3] = {
			rank = {3,3},
			award_img = {"ty_icon_flq2"},
			award_txt = {"8000福利券"},
		},
		[4] = {
			rank = {4,10},
			award_img = {"ty_icon_flq1"},
			award_txt = {"5000福利券"},
		},
		[5] = {
			rank = {11,20},
			award_img = {"ty_icon_flq1"},
			award_txt = {"3000福利券"},
		},
		[6] = {
			rank = {21,30},
			award_img = {"ty_icon_flq1"},
			award_txt = {"2000福利券"},
		},
	}
}