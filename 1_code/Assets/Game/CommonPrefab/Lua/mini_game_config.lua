return {
	game=
	{	--
		--conditions_type解锁条件类型:"0"意为"没有玩家level限制和vip等级限制"
								--"1"意为"只有玩家level限制"
								--"2"意为"只有vip等级限制"
								--"3"意为"既有玩家level限制也有vip等级限制"
								--"4"意为"玩家level限制或vip等级限制"
		--conditions_num解锁条件数目:依次填入"玩家level限制数目","vip等级限制数目"
		MiniGameJJBYPrefab=
		{
			pre_name = "MiniGameJJBYPrefab",
			bigpre_name = "MiniGameJJBYPrefab",
			sort = 1,
			key = "by",
			is_onoff = 0,
			is_lock = 0,
			tag_mr = 0,
			codin = "",
		},
		MiniGameSGXXLPrefab=
		{
			pre_name = "MiniGameSGXXLPrefab",
			sort = 2,
			key = "xxl",
			is_onoff = 1,
			is_lock = 0,
			tag_mr = 1,
			conditions_type = 4,
			conditions_num = {7,1},
			codin = "sgxxl_level",
			-- permission = "cpl_notcjj",
			tag = "hot",
		},
		MiniGameSHXXLPrefab=
		{
			pre_name = "MiniGameSHXXLPrefab",
			sort = 3,
			key = "shxxl",
			is_onoff = 1,
			is_lock = 0,
			tag_mr = 1,
			conditions_type = 4,
			conditions_num = {11,1},
			codin = "shxxl_level",
		},
		MiniGameCSXXLPrefab=
		{
			pre_name = "MiniGameCSXXLPrefab",
			sort = 4,
			key = "csxxl",
			is_onoff = 1,
			is_lock = 0,
			tag_mr = 1,
			conditions_type = 4,
			conditions_num = {14,1},
			codin = "csxxl_level",
		},
		MiniGameXYXXLPrefab=
		{
			pre_name = "MiniGameXYXXLPrefab",
			sort = 2,
			key = "xyxxl",
			is_onoff = 1,
			is_lock = 0,
			tag_mr = 1,
			conditions_type = 4,
			conditions_num = {4,1},
			codin = "xyxxl_level",
			tag = "new",
		},
		MiniGameLHDPrefab=
		{
			pre_name = "MiniGameLHDPrefab",
			sort = 5,
			key = "lhd",
			is_onoff = 0,
			is_lock = 0,
			tag_mr = 1,
			codin = "",
		},
		MiniGamePDKPrefab=
		{
			pre_name = "MiniGamePDKPrefab",
			sort = 6,
			key = "pdk",
			is_onoff = 0,
			is_lock = 0,
			tag_mr = 0,
			codin = "",
		},
		MiniGameJBSPrefab=
		{
			pre_name = "MiniGameJBSPrefab",
			sort = 7,
			key = "jbs",
			is_onoff = 0,
			is_lock = 0,
			tag_mr = 0,
			codin = "",
		},
		MiniGameZPGPrefab=
		{
			pre_name = "MiniGameZPGPrefab",
			sort = 8,
			key = "zpg",
			is_onoff = 0,
			is_lock = 0,
			tag_mr = 1,
			conditions_type = 2,
			conditions_num = {nil,1},
			codin = "drt_guess_apple_play",
		},
		MiniGameFKBYPrefab=
		{
			pre_name = "MiniGameFKBYPrefab",
			sort = 9,
			key = "fkby",
			is_onoff = 0,
			is_lock = 0,
			tag_mr = 1,
			conditions_type = 2,
			conditions_num = {nil,2},
			codin = "jing_yu_kuai_pao_game",
		},
		MiniGameTTLPrefab=
		{
			pre_name = "MiniGameTTLPrefab",
			sort = 5,
			key = "ttl",
			is_onoff = 1,
			is_lock = 0,
			tag_mr = 1,
			conditions_type = 4,
			conditions_num = {5,1},
			codin = "tantanle_level",
		},
		MiniGameQQLPrefab=
		{
			pre_name = "MiniGameQQLPrefab",
			sort = 11,
			key = "qql",
			is_onoff = 1,
			is_lock = 0,
			tag_mr = 0,
			conditions_type = 4,
			conditions_num = {9,1},
			codin = "zjd_level",
		},
		MiniGameDDZPrefab=
		{
			pre_name = "MiniGameDDZPrefab",
			sort = 12,
			key = "ddz",
			is_onoff = 0,
			is_lock = 0,
			tag_mr = 0,
			codin = "",
		},
		MiniGameMJPrefab=
		{
			pre_name = "MiniGameMJPrefab",
			sort = 13,
			key = "mj",
			is_onoff = 0,
			is_lock = 0,
			tag_mr = 0,
			codin = "",
		},
		MiniGameWZQPrefab=
		{
			pre_name = "MiniGameWZQPrefab",
			sort = 7,
			key = "wzq",
			is_onoff = 0,
			is_lock = 0,
			tag_mr = 0,
			codin = "",
			permission = "signin_cpl",
		},
		MiniGameQHBPrefab=
		{
			pre_name = "MiniGameQHBPrefab",
			sort = 99,
			key = "qhb",
			is_onoff = 1,
			is_lock = 0,
			tag_mr = 0,
			gotoUI = {"sys_qhb",},
			codin = "",
		},
		MiniGameWaitPrefab=
		{
			pre_name = "MiniGameWaitPrefab",
			sort = 8,
			key = "Wait",
			is_onoff = 0,
			is_lock = 0,
			tag_mr = 0,
			codin = "",
		},
		MiniGameLWZBPrefab=
		{
			pre_name = "MiniGameLWZBPrefab",
			sort = 2,
			key = "lwzb",
			is_onoff = 0,
			is_lock = 0,
			tag_mr = 1,
			conditions_type = 2,
			conditions_num = {nil,1},
			codin = "lwzb_level",
			permission = "cpl_cjj",
		},
		MiniGameSGYYXXLPrefab=
		{
			pre_name = "MiniGameSGYYXXLPrefab",
			sort = 2,
			key = "sgxxl",
			is_onoff = 1,
			is_lock = 0,
			tag_mr = 1,
			-- conditions_type = 4,
			-- conditions_num = {7,1},
			--codin = "sgyyxxl_level",
			tag = "new",
			permission = "platform_limit_cjj_show",
		},
	},
}