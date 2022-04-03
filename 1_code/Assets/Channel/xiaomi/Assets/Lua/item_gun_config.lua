return {
	config=
	{
		[1]=
		{
			id = 1,
			item_id = 1,
			item_key = "gun_barrel_1",
			type_colour = 1,
			type = 1,
			is_local_icon = 1,
			image = "3dby_icon_p0",
			order = 1,
			name = "小钢炮",
			desc = "激光炮：直线方向释放激光，有几率捕获激光所发射范围内的任意鱼类",
			desc_get = "系统赠送",
		},
		[2]=
		{
			id = 2,
			item_id = 2,
			item_key = "gun_barrel_2",
			type_colour = 1,
			type = 1,
			is_local_icon = 1,
			image = "3dby_icon_p1",
			order = 2,
			name = "雷霆幻影",
			desc = "激光炮：直线方向释放激光，有几率捕获激光所发射范围内的任意鱼类",
			desc_get = "连续签到获得",
			use_parm = {"sys_qd","panel"},
			buy_anniu_hint = "获取",
		},
		[3]=
		{
			id = 3,
			item_id = 3,
			item_key = "gun_barrel_3",
			type_colour = 1,
			type = 1,
			is_local_icon = 1,
			image = "3dby_icon_p2",
			order = 3,
			name = "闪耀风暴",
			desc = "激光炮：直线方向释放激光，有几率捕获激光所发射范围内的任意鱼类",
			desc_get = "VIP3开启",
			use_parm = {"vip","hint"},
			buy_anniu_hint = "获取",
			buy_parm = {"gift",10345},
			ext_buy_parm = {"item",29},
			attribute = {"<color=#fff173>激光炮：直线方向释放激光，有几率捕获激光所发射范围内的任意鱼类</color>",},
			attribute_img = {"3dby_icon_jg_skill",},
			pre_name = "GunPrefab6_ui",
			net_prefab = "FishNetPrefab_3d_3",
			bullet_prefab = "BulletPrefab_3d_6_ui",
		},
		[4]=
		{
			id = 4,
			item_id = 4,
			item_key = "gun_barrel_4",
			type_colour = 2,
			type = 1,
			is_local_icon = 1,
			image = "3dby_icon_p3",
			order = 4,
			name = "金币使者",
			desc = "穿透弹：发射一发穿透弹，可捕获同移动线上的任意鱼类",
			desc_get = "VIP5开启",
			use_parm = {"vip","hint"},
			buy_anniu_hint = "获取",
			buy_parm = {"gift",10344},
			ext_buy_parm = {"item",30},
			attribute = {"<color=#fff173>穿透弹：发射一发穿透弹，可捕获同移动线上的任意鱼类</color>",},
			attribute_img = {"3dby_icon_ct_skill",},
			pre_name = "GunPrefab9_ui",
			net_prefab = "FishNetPrefab_3d_4",
			bullet_prefab = "BulletPrefab_3d_7_ui",
		},
		[5]=
		{
			id = 5,
			item_id = 5,
			item_key = "gun_barrel_5",
			type_colour = 2,
			type = 1,
			is_local_icon = 1,
			image = "3dby_icon_p4",
			order = 5,
			name = "核能风暴",
			desc = "核能炮：在屏幕中间释放一颗小型原子弹，随机捕获炸弹范围内的任意鱼类",
			desc_get = "购买礼包获得",
			use_parm = {"buygift",10343,},
			buy_hint = "是否花费98元购买【核能风暴】永久使用权",
			buy_anniu_hint = "获取",
			buy_parm = {"gift",10343},
			ext_buy_parm = {"item",31},
			attribute = {"<color=#fff173>核能炮：在屏幕中间释放一颗小型原子弹，随机捕获炸弹范围内的任意鱼类</color>",},
			attribute_img = {"3dby_icon_hn_skill",},
			pre_name = "GunPrefab8_ui",
			net_prefab = "FishNetPrefab_3d_5",
			bullet_prefab = "BulletPrefab_3d_8_ui",
			tag = "热销",
		},
		[6]=
		{
			id = 6,
			item_id = 6,
			item_key = "gun_barrel_6",
			type_colour = 3,
			type = 1,
			is_local_icon = 1,
			image = "3dby_icon_p5",
			order = 6,
			name = "死灵之光",
			desc = "死灵之光：攻击指定点，捕获周围鱼类\n被动效果：提高捕获奖金鱼后获得高倍的几率",
			desc_get = "金币购买",
			use_parm = {"buyitem",26,},
			buy_hint = "是否花费30万金币购买【死灵之光】30天使用权",
			buy_anniu_hint = "获取",
			buy_parm = {"gift",10342},
			ext_buy_parm = {"item",32},
			attribute = {"<color=#fff173>死亡之灵：攻击指定点，捕获周围鱼类</color>","<color=#00fff0>被动效果：提高捕获奖金鱼后获得高倍的几率</color>"},
			attribute_img = {"3dby_icon_sw_skill",},
			pre_name = "GunPrefab10_ui",
			net_prefab = "FishNetPrefab_3d_6",
			bullet_prefab = "BulletPrefab_3d_9_ui",
		},
		[7]=
		{
			id = 7,
			item_id = 7,
			item_key = "gun_barrel_7",
			type_colour = 3,
			type = 1,
			is_local_icon = 1,
			image = "3dby_icon_p6",
			order = 7,
			name = "神龙之力",
			desc = "神龙杀：瞬间提高子弹250%的杀伤力\n被动效果：提高击杀龙王的概率",
			desc_get = "购买礼包获得",
			use_parm = {"buygift",10341,},
			buy_hint = "是否花费498元购买【神龙之力】永久使用权",
			buy_anniu_hint = "获取",
			buy_parm = {"gift",10341},
			ext_buy_parm = {"item",33},
			attribute = {"<color=#fff173>神龙杀：瞬间提高子弹250%的杀伤力</color>","<color=#00fff0>被动效果：提高击杀龙王的概率</color>"},
			attribute_img = {"3dby_icon_sl_skill",},
			pre_name = "GunPrefab11_ui",
			net_prefab = "FishNetPrefab_3d_7",
			bullet_prefab = "BulletPrefab_3d_10_ui",
			tag = "热销",
		},
		[8]=
		{
			id = 8,
			item_id = 8,
			item_key = "gun_barrel_8",
			type_colour = 1,
			type = 1,
			is_local_icon = 1,
			image = "3dby_icon_djpt1",
			order = 8,
			name = "圣光  I",
			desc_get = "25级解锁",
			use_parm = {"game_Fishing3DHall",},
		},
		[9]=
		{
			id = 9,
			item_id = 9,
			item_key = "gun_barrel_9",
			type_colour = 1,
			type = 1,
			is_local_icon = 1,
			image = "3dby_icon_djpt2",
			order = 9,
			name = "圣光  II",
			desc_get = "40级解锁",
			use_parm = {"game_Fishing3DHall",},
		},
		[10]=
		{
			id = 10,
			item_id = 10,
			item_key = "gun_barrel_10",
			type_colour = 2,
			type = 1,
			is_local_icon = 1,
			image = "3dby_icon_djpt3",
			order = 10,
			name = "圣光  III",
			desc_get = "60级解锁",
			use_parm = {"game_Fishing3DHall",},
		},
		[11]=
		{
			id = 11,
			item_id = 11,
			item_key = "gun_barrel_11",
			type_colour = 2,
			type = 1,
			is_local_icon = 1,
			image = "3dby_icon_djpt4",
			order = 11,
			name = "圣光  IV",
			desc_get = "80级解锁",
			use_parm = {"game_Fishing3DHall",},
		},
		[12]=
		{
			id = 12,
			item_id = 12,
			item_key = "gun_barrel_12",
			type_colour = 3,
			type = 1,
			is_local_icon = 1,
			image = "3dby_icon_djpt5",
			order = 12,
			name = "圣光  V",
			desc_get = "100级解锁",
			use_parm = {"game_Fishing3DHall",},
		},
		[13]=
		{
			id = 13,
			item_id = 13,
			item_key = "gun_barrel_13",
			type_colour = 3,
			type = 1,
			is_local_icon = 1,
			image = "3dby_icon_phw",
			order = 13,
			name = "海王炮台",
			desc = "海王之力：瞬间提高子弹280%的杀伤力\n被动效果：提高击杀BOSS的概率",
			desc_get = "购买礼包获得",
			use_parm = {"sys_txz","choose",},
			attribute = {"<color=#fff173>海王之力：瞬间提高子弹280%的杀伤力</color>","<color=#00fff0>被动效果：提高击杀BOSS的概率</color>"},
			attribute_img = {"3dby_icon_sl_skill",},
			pre_name = "GunPrefab_hw",
			net_prefab = "FishNetPrefab_3d_7",
			bullet_prefab = "BulletPrefab_3d_10_ui",
		},
		[14]=
		{
			id = 14,
			item_id = 1,
			item_key = "gun_bed_1",
			type_colour = 1,
			type = 2,
			is_local_icon = 1,
			image = "3dby_icon_pt_1",
			order = 1,
			name = "青柠",
			desc = "系统赠送基础炮座",
			desc_get = "系统赠送",
		},
		[15]=
		{
			id = 15,
			item_id = 2,
			item_key = "gun_bed_2",
			type_colour = 1,
			type = 2,
			is_local_icon = 1,
			image = "3dby_icon_xy_1",
			order = 2,
			name = "绿芒",
			desc = "限制：稀有品质以上炮台可用",
			desc_get = "VIP1开启",
			use_parm = {"vip","hint"},
			buy_anniu_hint = "获取",
		},
		[16]=
		{
			id = 16,
			item_id = 3,
			item_key = "gun_bed_3",
			type_colour = 2,
			type = 2,
			is_local_icon = 1,
			image = "3dby_icon_ss_1",
			order = 3,
			name = "寒霜",
			desc = "装备后效果：捕鱼命中率提升千分之二\n限制：史诗品质以上炮台可用",
			desc_get = "VIP3开启",
			use_parm = {"vip","hint"},
			buy_anniu_hint = "获取",
		},
		[17]=
		{
			id = 17,
			item_id = 4,
			item_key = "gun_bed_4",
			type_colour = 3,
			type = 2,
			is_local_icon = 1,
			image = "3dby_icon_cs_1",
			order = 4,
			name = "金焰",
			desc = "装备后效果：捕鱼子弹威力提高千分之五\n限制：传说品质以上炮台可用",
			desc_get = "金币购买",
			use_parm = {"buyitem",27,},
			buy_hint = "是否花费30万金币购买【金焰】30天使用权",
			buy_anniu_hint = "获取",
		},
		[18]=
		{
			id = 18,
			item_id = 1,
			item_key = "head_frame_1",
			type_colour = 1,
			type = 3,
			is_local_icon = 1,
			image = "dt_tx_bg1",
			order = 1,
			name = "基础",
			desc = "基础头像框",
		},
		[19]=
		{
			id = 19,
			item_id = 2,
			item_key = "head_frame_2",
			type_colour = 1,
			type = 3,
			is_local_icon = 1,
			image = "dt_tx_mx1",
			order = 1,
			name = "探险 I",
			desc_get = "30级解锁",
			use_parm = {"game_Fishing3DHall",},
		},
		[20]=
		{
			id = 20,
			item_id = 3,
			item_key = "head_frame_3",
			type_colour = 1,
			type = 3,
			is_local_icon = 1,
			image = "dt_tx_mx2",
			order = 2,
			name = "探险 II",
			desc_get = "50级解锁",
			use_parm = {"game_Fishing3DHall",},
		},
		[21]=
		{
			id = 21,
			item_id = 4,
			item_key = "head_frame_4",
			type_colour = 2,
			type = 3,
			is_local_icon = 1,
			image = "dt_tx_mx3",
			order = 3,
			name = "探险 III",
			desc_get = "70级解锁",
			use_parm = {"game_Fishing3DHall",},
		},
		[22]=
		{
			id = 22,
			item_id = 5,
			item_key = "head_frame_5",
			type_colour = 2,
			type = 3,
			is_local_icon = 1,
			image = "dt_tx_mx4",
			order = 4,
			name = "探险 IV",
			desc_get = "90级解锁",
			use_parm = {"game_Fishing3DHall",},
		},
		[23]=
		{
			id = 23,
			item_id = 6,
			item_key = "head_frame_6",
			type_colour = 3,
			type = 3,
			is_local_icon = 1,
			image = "dt_tx_mx5",
			order = 5,
			name = "探险 V",
			desc_get = "100级解锁",
			use_parm = {"game_Fishing3DHall",},
		},
	},
}