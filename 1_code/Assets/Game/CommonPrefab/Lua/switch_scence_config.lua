
return 
{
	config_scence = 
	{
		game_Fishing3D = 
		{
			[1] = 
			{
				requset = "fsg_3d_signup",
				error_scence = "game_Fishing3DHall",
			}
		},
		game_FishingHall =
		{
			[1] = 
			{
				error_scence = "game_MiniGame",
			}
		},
		game_Zjd = 
		{
			[1] = 
			{
				condi_key = "mini_game_show_center",
				error_scence = "game_MiniGame",
			}
		},
		game_QHBHall = 
		{
			[1] = 
			{
				error_scence = "game_MiniGame",
			}
		},
		game_Eliminate = 
		{
			[1] = 
			{
				requset = "xxl_enter_game",
				error_scence = "game_MiniGame",
			}
		},	
		game_EliminateSH = 
		{
			[1] = 
			{
				requset = "xxl_shuihu_enter_game",
				error_scence = "game_MiniGame",
			}
		},
		game_EliminateCS = 
		{
			[1] = 
			{
				requset = "xxl_caishen_enter_game",
				error_scence = "game_MiniGame",
			}
		},
		game_EliminateXY = 
		{
			[1] = 
			{
				requset = "xxl_xiyou_enter_game",
				error_scence = "game_MiniGame",
			}
		},
		game_EliminateCJ = 
		{
			[1] = 
			{
				requset = "lxxxl_enter_game",
				error_scence = "game_MiniGame",
			}
		},	
		game_DMBJ = 
		{
			[1] = 
			{
				requset = "dmbj_enter_game",
				error_scence = "game_MiniGame",
			}
		},
		game_FishingDR = 
		{
			[1] = 
			{
				condi_key = "mini_game_show_center",
				requset = "fishing_dr_enter_room",
				error_scence = "game_FishingHall",
			}
		},
		game_LHDHall = 
		{
			[1] = 
			{
				condi_key = "freestyle_game_lhd_1001",
				error_scence = "game_MiniGame",
			}
		},
		game_LWZB = 
		{
			[1] = 
			{
				requset = "lwzb_enter_room",
				condi_key = "mini_game_show_center",
				error_scence = "game_MiniGame",
			}
		},
		game_LWZBHall = 
		{
			[1] = 
			{
				condi_key = "mini_game_show_center",
				error_scence = "game_MiniGame",
			}
		},
		game_TTL = 
		{
			[1] = 
			{
				requset = "tantanle_enter_game",
				error_scence = "game_MiniGame",
			}
		},
		game_ZPG = 
		{
			[1] = 	
			{
				requset = "guess_apple_enter_room",
				condi_key = "drt_guess_apple_play",
				error_scence = "game_MiniGame",
			}
		},
		game_Gobang = 
		{
			[1] = 
			{
				requset = "fg_signup",
				parm={id=25},
				error_scence = "game_MiniGame",
			}
		},
		game_Fishing = 
		{
			[1] = 
			{
				requset = "fsg_signup",
				error_scence = "game_FishingHall",
			}
		},
		game_EliminateSG = 
		{
			[1] = 
			{
				requset = "xxl_sanguo_enter_game",
				error_scence = "game_MiniGame",
			}
		},
	},

}