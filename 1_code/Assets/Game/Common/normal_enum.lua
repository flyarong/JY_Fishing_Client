--
-- Author: lyx
-- Date: 2018/4/14
-- Time: 10:31
-- 说明：公用的 枚举变量
--

-- 条件的处理方式
NOR_CONDITION_TYPE = {
    CONSUME = 1, -- 消费：必须大于等于，并扣除
    EQUAL = 2, -- 等于
    GREATER = 3, -- 大于等于
    LESS = 4, -- 小于等于
    NOT_EQUAL = 5 -- 不等于
}

-- 玩家财富类型
PLAYER_ASSET_TYPES =
{
	DIAMOND 			= "diamond", 		-- 钻石
	JING_BI 			= "jing_bi",	-- 金币
	CASH 				= "cash", 			-- 现金
	SHOP_GOLD_SUM		= "shop_gold_sum",	-- 总数：各面额加起来

	ROOM_CARD 			= "room_card",	-- 房卡

	JIPAIQI 			= "jipaiqi",	-- 记牌器有效期 -- 只作为消息发送

	PROP_JICHA_CASH		= "prop_jicha_cash", 	-- 生财之道的级差现金

	PROP_1              = "prop_1",         -- 竞标赛门票

	PROP_2              = "prop_2",         -- 千元赛门票

}

-- 玩家财富类型集合 以及 所有 prop_ 开头的东西
PLAYER_ASSET_TYPES_SET =
{
	["diamond"] 		= "diamond", 		-- 钻石
	["jing_bi"] 		= "jing_bi",		-- 金币
	["cash"] 			= "cash", 			-- 现金
	["shop_gold_sum"] 	= "shop_gold_sum", 	-- 

	["jipaiqi"] 		= "jipaiqi", 		-- 记牌器有效期

	["room_card"] 		= "room_card",		-- 房卡
}

--财富改变类型
--[[
  
--]]
ASSET_CHANGE_TYPE = {
    BUY = "buy", --玩家充值购买
    BUY_GIFT = "buy_gift", --玩家充值购买 附赠 的东西
    SHOPING = "shoping", --玩家在线上商城通过买东西
    MERCHANT_BUY = "merchant_buy", --玩家在通过买东西
    WITHDRAW = "withdraw", --玩家现金提现
    PAY_EXCHANGE_JING_BI = "pay_exchange_jing_bi", -- 充值界面中，用钻石购买金币
    PAY_EXCHANGE_JIPAIQI = "pay_exchange_jipaiqi", -- 充值界面中，用钻石购买记牌器
    PAY_EXCHANGE_ROOMCARD = "pay_exchange_roomcard", -- 充值界面中，用钻石购买房卡
    -- 兑物券
    DWQ_CHANGE_1 = "dwq_change_1", --兑物券合成扣除
    DWQ_CHANGE_2 = "dwq_change_2", --兑物券合成增加
    DWQ_CHANGE_3 = "dwq_change_3", --兑物券普通使用扣除
    DWQ_CHANGE_4 = "dwq_change_4", --兑物券被激活码的方式使用
    --
    GWJ_CHANGE_1 = "gwj_change_1", --自己使用兑物券增加
    FREESTYLE_SIGNUP = "freestyle_signup", --自由场报名
    FREESTYLE_CANCEL_SIGNUP = "freestyle_cancel_signup", --自由场报名
    FREESTYLE_AWARD = "freestyle_award", --自由场获奖
    FREESTYLE_LOSE = "freestyle_lose", --自由场输了
    --laizi
    LZ_FREESTYLE_SIGNUP = "lz_freestyle_signup", --自由场报名
    LZ_FREESTYLE_CANCEL_SIGNUP = "lz_freestyle_cancel_signup", --自由场报名
    LZ_FREESTYLE_AWARD = "lz_freestyle_award", --自由场获奖
    LZ_FREESTYLE_LOSE = "lz_freestyle_lose", --自由场输了
    --laizi
    TY_FREESTYLE_SIGNUP = "ty_freestyle_signup", --自由场报名
    TY_FREESTYLE_CANCEL_SIGNUP = "ty_freestyle_cancel_signup", --自由场报名
    TY_FREESTYLE_AWARD = "ty_freestyle_award", --自由场获奖
    TY_FREESTYLE_LOSE = "ty_freestyle_lose", --自由场输了
    MILLION_SIGNUP = "million_signup", --百万大奖赛报名
    MILLION_CANCEL_SIGNUP = "million_cancel_signup", --百万大奖赛取消报名
    MILLION_COMFORT_AWARD = "million_comfort_award", --百万大奖赛安慰奖
    MILLION_AWARD = "million_award", --百万大奖赛获奖
    MILLION_FUHUO = "million_fuhuo", --百万大奖赛复活
    -- 麻将自由场
    MAJIANG_FREESTYLE_SIGNUP = "majiang_freestyle_signup", --自由场报名
    MAJIANG_FREESTYLE_CANCEL_SIGNUP = "majiang_freestyle_cancel_signup", --自由场报名
    MAJIANG_FREESTYLE_AWARD = "majiang_freestyle_award", --自由场获奖
    MAJIANG_FREESTYLE_LOSE = "majiang_freestyle_lose", --自由场输了
    MAJIANG_FREESTYLE_REFUND = "majiang_freestyle_refund", --退税（杠的钱）
    -- 麻将自由场
    MJXL_MAJIANG_FREESTYLE_SIGNUP = "mjxl_majiang_freestyle_signup", --自由场报名
    MJXL_MAJIANG_FREESTYLE_CANCEL_SIGNUP = "mjxl_majiang_freestyle_cancel_signup", --自由场报名
    MJXL_MAJIANG_FREESTYLE_AWARD = "mjxl_majiang_freestyle_award", --自由场获奖
    MJXL_MAJIANG_FREESTYLE_LOSE = "mjxl_majiang_freestyle_lose", --自由场输了
    MJXL_MAJIANG_FREESTYLE_REFUND = "mjxl_majiang_freestyle_refund", --退税（杠的钱）
    MATCH_SIGNUP = "match_signup", --比赛场报名
    MATCH_CANCEL_SIGNUP = "match_cancel_signup", --比赛场取消报名
    MATCH_AWARD = "match_award", --自由场获奖
    MANUAL_SEND = "manual_send", --手工发送
    ADMIN_DECREASE_ASSET = "admin_decrease_asset", --管理员进行扣除资产
    EVERYDAY_SHARED_FRIEND = "everyday_shared_friend", --每日分享朋友奖励
    EVERYDAY_SHARED_TIMELINE = "everyday_shared_timeline", --每日分享朋友圈奖励
    EVERYDAY_FLAUNT = "everyday_flaunt", --每日炫耀奖励
    EVERYDAY_SHARED_MATCH = "everyday_shared_match", --每日分享朋友圈奖励比赛场
    XSYD_FINISH_AWARD = "xsyd_finish_award", --新手引导完成奖励
    FRIENDGAME_RENT = "friendgame_rent", --房卡开放费用
    BUY_2_GIFT_BAG = "buy_2_gift_bag", --房卡开放费用
    TASK_AWARD = "task_award",   --任务奖励
    GLORY_AWARD = "glory_award",   --荣耀奖励
    REDEEM_CODE_AWARD = "redeem_code_award", --兑换码奖励
    BUY_GIFT_BAG_7 = "buy_gift_bag_7",
    BUY_GIFT_BAG_8 = "buy_gift_bag_8",
    BUY_GIFT_BAG_10 = "buy_gift_bag_10",
    BROKE_SUBSIDY = "broke_subsidy",
    FREE_BROKE_SUBSIDY = "free_broke_subsidy",
    BROKE_SHARE_POP = "broke_share_pop",
    BUY_GIFT_BAG_11 = "buy_gift_bag_11",
    BUY_GIFT_BAG_12 = "buy_gift_bag_12",
    BUY_GIFT_BAG_13 = "buy_gift_bag_13",
    BUY_GIFT_BAG_20 = "buy_gift_bag_20",
    BUY_GIFT_BAG_21 = "buy_gift_bag_21",
    BUY_GIFT_BAG_28 = "buy_gift_bag_28",
    BUY_GIFT_BAG_29 = "buy_gift_bag_29",
    BUY_GIFT_BAG_30 = "buy_gift_bag_30",
    BUY_GIFT_BAG_31 = "buy_gift_bag_31",
    BUY_GIFT_BAG_32 = "buy_gift_bag_32",
    BUY_GIFT_BAG_33 = "buy_gift_bag_33",
    BUY_GIFT_BAG_35 = "buy_gift_bag_35",
    BUY_GIFT_BAG_36 = "buy_gift_bag_36",
    BUY_GIFT_BAG_37 = "buy_gift_bag_37",
    BUY_GIFT_BAG_38 = "buy_gift_bag_38",
    BUY_GIFT_BAG_39 = "buy_gift_bag_39",
    BUY_GIFT_BAG_40 = "buy_gift_bag_40",
    GOLD_PIG2_TASK_AWARD = "gold_pig2_task_award",
    PAY_EXCHANGE_EXPRESSION_57 = "pay_exchange_expression_57",
    EVERYDAY_WYS_SHARED = "everyday_wys_shared",
    FREESTYLE_SETTLE_EXCHANGE_HONGBAO = "freestyle_settle_exchange_hongbao",
    ACTIVITY_EXCHANGE_DUANWUJIE_FISHGAME_ZONGZI = "activity_exchange_duanwujie_fishgame_zongzi",
    BUYU_DAILY_TASK_AWARD = "buyu_daily_task_award",
    OPEN_LUCK_BOX = "open_luck_box",
    IOS_PLYJ = "ios_plyj",
    BUYU_RANK_AWARD = "buyu_rank_award",
    OLD_PLAYER_LOTTERY_RANK_AWARD="old_player_lottery_rank_award",
    PAY_STRIDE_1000 = "pay_stride_1000",
    BIND_PHONE_AWARD = "bind_phone_award",
    JING_YU_KUAI_PAO_EMAIL_AWARD = "jing_yu_kuai_pao_email_award",
    ACTIVITY_EXCHANGE_RECYCLE ="activity_exchange_recycle",    
    WATERMElON_RANK_AWARD="watermelon_rank_award",
    VIP_CHARGE_AWARD="vip_charge_award",
    JING_YU_KUAI_PAO_AUTO_AWARD= "jing_yu_kuai_pao_auto_award",
    ZHOUNIANQING_YUYUE_AWARD="zhounianqing_yuyue_award",
    ZNQ_LOOK_BACK="znq_look_back",
    ZNQ_JNB_EXCHANGE_DHQ = "znq_jnb_exchange_dhq",
    ZHOUNIANQING_YINGJING_RANK_EMAIL_AWARD = "zhounianqing_yingjing_rank_email_award",
    ZNQ_JNB_RECYCLE = "znq_jnb_recycle",
    ZHOUNIANQING_YINGJING_RANK_WANGZHE_EMAIL = "zhounianqing_yingjing_rank_wangzhe_email",
    XIAOXIAOLE_ONCE_GAME_RANK_AWARD="xiaoxiaole_once_game_rank_award",
    WITHDRAW_TO_SHOP_GOLD="withdraw_to_shop_gold",
    NEW_USER_QYS_AWARD = "new_user_qys_award",
    QYS_EVERY_TIME_REMIND = "qys_every_time_remind",
    SIGN_IN_AWARD="sign_in_award",
    SIGN_IN_ACC_AWARD = "sign_in_acc_award",
    EMAIL_NOTIFICATION_GIFT = "email_notification_gift",
    NATIONAL_DAY_LOTTERY_RANK_EMAIL_AWARD = "national_day_lottery_rank_email_award",
    SCZD_ACHIEVEMENT_SYS_AWARD = "sczd_achievement_sys_award",
    OCTOBER_19_LOTTERY_2_RANK_EMAIL_AWARD = "october_19_lottery_2_rank_email_award",
    BOX_EXCHANGE = "box_exchange",
    BUYU_MATCH_AWARD = "buyu_match_award",
    BROKE_BEG = "broke_beg",
    FREESTYLE_ACTIVITY_AWARD_EMAIL = "freestyle_activity_award_email",
    STXT_EVERYDAY_TASK_AWARD = "stxt_everyday_task_awards",
    STXT_GIVE_PROPS = "stxt_give_props",
    YUYUE_GNS = "yuyue_gns",
    WATCH_AD_AWARD = "watch_ad_award",
    AUTHENTICATION_AWARD = "authentication_award",
    FISH_3D_CAIBEI_AWARD = "fish_3d_caibei_award",
    PAY_EXCHANGE_ROOM_CARD = "pay_exchange_room_card",
    ALL_RETURN_LB_3_EXTRA_AWARD = "all_return_lb_3_extra_award",
    PAY_EXCHANGE_PROP_FISH_SUMMON_FISH = "pay_exchange_prop_fish_summon_fish",
    NPCA_BOX_AWARD = "npca_box_award",
    XIAOXIAOLE_SHUIHU_ONCE_GAME_RANK_AWARD = "xiaoxiaole_shuihu_once_game_rank_award",
    ADD_FISH_3D_GUN = "add_fish_3d_gun",
    --存钱罐
    DEPOSIT_WITHDRAW_MONEY = "deposit_withdraw_money",
    --排名赛每日24:00结算奖励
    BULLET_RANK_EVERYDAY_EMAIL_AWARD = "bullet_rank_everyday_email_award",
    BULLET_VIP_RANK_EVERYDAY_EMAIL_AWARD = "bullet_vip_rank_everyday_email_award",
    BULLET_RANK_AWARD_SETTLE = "bullet_rank_award_settle",
    OPEN_TEST = "open_test",
    BUYU_3D_YINGJIN_RANK_EMAIL_AWARD = "buyu_3d_yingjin_rank_email_award",
    ALL_RETURN_LB_OVERTIME_AWARD = "all_return_lb_overtime_award",
    FISHBOWL_OPEN = "fishbowl_open",
    FISHBOWL_SALE = "fishbowl_sale",
    FISHING_3D_GAME_FREE_LOTTERY = "fishing_3d_game_free_lottery",
    FISHING_3D_GAME_AD_FISH = "fishing_3d_game_ad_fish",
    NEW_YUEKA_AWARD = "new_yueka_award",
    XIAOLONGXIA_BOSS_025_RANK_EMAIL_AWARD = "xiaolongxia_boss_025_rank_email_award",
    XIAOLONGXIAQUAN_025_RANK_EMAIL_AWARD = "xiaolongxiaquan_025_rank_email_award",
    TRUE_LOVE_026_RANK_EMAIL_AWARD = "true_love_026_rank_email_award",
    LEIJIYINGJIN_RANK_EMAIL_AWARD = "leijiyingjin_rank_email_award",
    LEIJIXIAOHAO_RANK_EMAIL_AWARD = "leijixiaohao_rank_email_award",

    OCEAN_EXPLORE_WEEK_RANK_EMAIL_AWARD = "ocean_explore_week_rank_email_award",
    JJSL_AWARD = "jjsl_award",--金鸡送礼(冲金鸡)
    FISHBOWL_COMPOSE = "fishbowl_compose", -- 水族馆合成
    XXLZB_004_RANK_EMAIL_AWARD = "xxlzb_004_rank_email_award",
    CHANGE_ASSETS_BY_WEBVIEW = "change_assets_by_webview",
}

--需要给tips的资产类型
TIPS_ASSET_CHANGE_TYPE = {
    buy = "BUY", --玩家充值购买
    buy_gift = "BUY_GIFT", --玩家充值购买 附赠 的东西
    shoping = "SHOPING", --玩家在线上商城通过买东西
    merchant_buy = "MERCHANT_BUY", --玩家在通过买东西
    withdraw = "WITHDRAW", --玩家现金提现
    pay_exchange_jing_bi = "PAY_EXCHANGE_JING_BI", -- 充值界面中，用钻石购买金币
    pay_exchange_jipaiqi = "PAY_EXCHANGE_JIPAIQI", -- 充值界面中，用钻石购买记牌器
    pay_exchange_roomcard = "PAY_EXCHANGE_ROOMCARD", -- 充值界面中，用钻石购买房卡
    -- 兑物券
    dwq_change_1 = "DWQ_CHANGE_1", --兑物券合成扣除
    dwq_change_2 = "DWQ_CHANGE_2", --兑物券合成增加
    dwq_change_3 = "DWQ_CHANGE_3", --兑物券普通使用扣除
    dwq_change_4 = "DWQ_CHANGE_4", --兑物券被激活码的方式使用
    --
    gwj_change_1 = "GWJ_CHANGE_1", --自己使用兑物券增加
    manual_send = "MANUAL_SEND", --手工发送
    everyday_shared_friend = "EVERYDAY_SHARED_FRIEND", --每日分享朋友奖励
    everyday_shared_timeline = "EVERYDAY_SHARED_TIMELINE", --每日分享朋友圈奖励
    everyday_flaunt = "EVERYDAY_FLAUNT", --每日炫耀奖励
    everyday_shared_match = "EVERYDAY_SHARED_MATCH", --每日分享朋友圈奖励比赛场
    xsyd_finish_award = "XSYD_FINISH_AWARD", --新手引导完成奖励
    task_award = "TASK_AWARD",   --任务奖励
    glory_award = "GLORY_AWARD",   --荣耀奖励
    redeem_code_award = "REDEEM_CODE_AWARD", --兑换码奖励
    buy_gift_bag_7 = "BUY_GIFT_BAG_7",
    buy_gift_bag_8 = "BUY_GIFT_BAG_8",
    buy_gift_bag_10 = "BUY_GIFT_BAG_10",
    buy_gift_bag_11 = "BUY_GIFT_BAG_11",
    buy_gift_bag_12 = "BUY_GIFT_BAG_12",
    buy_gift_bag_13 = "BUY_GIFT_BAG_13",
    buy_gift_bag_20 = "BUY_GIFT_BAG_20",
    buy_gift_bag_21 = "BUY_GIFT_BAG_21",
    buy_gift_bag_28 = "BUY_GIFT_BAG_28",
    buy_gift_bag_29 = "BUY_GIFT_BAG_29",
    buy_gift_bag_30 = "BUY_GIFT_BAG_30",
    buy_gift_bag_31 = "BUY_GIFT_BAG_31",
    buy_gift_bag_32 = "BUY_GIFT_BAG_32",
    buy_gift_bag_33 = "BUY_GIFT_BAG_33",
    buy_gift_bag_35 = "BUY_GIFT_BAG_35",
    buy_gift_bag_36 = "BUY_GIFT_BAG_36",
    buy_gift_bag_37 = "BUY_GIFT_BAG_37",
    buy_gift_bag_38 = "BUY_GIFT_BAG_38",
    buy_gift_bag_39 = "BUY_GIFT_BAG_39",
    buy_gift_bag_40 = "BUY_GIFT_BAG_40",
    broke_subsidy = "BROKE_SUBSIDY",
    free_broke_subsidy = "FREE_BROKE_SUBSIDY",
    broke_share_pop = "BROKE_SHARE_POP",
    gold_pig2_task_award = "GOLD_PIG2_TASK_AWARD",
    pay_exchange_expression_57 = "PAY_EXCHANGE_EXPRESSION_57",
    everyday_wys_shared = "EVERYDAY_WYS_SHARED",
    freestyle_settle_exchange_hongbao = "FREESTYLE_SETTLE_EXCHANGE_HONGBAO",
    activity_exchange_duanwujie_fishgame_zongzi = "ACTIVITY_EXCHANGE_DUANWUJIE_FISHGAME_ZONGZI",
    buyu_daily_task_award = "BUYU_DAILY_TASK_AWARD",
    open_luck_box = "OPEN_LUCK_BOX",
    ios_plyj = "IOS_PLYJ",
    buyu_rank_award = "BUYU_RANK_AWARD",
    old_player_lottery_rank_award="OLD_PLAYER_LOTTERY_RANK_AWARD",
    pay_stride_1000 = "PAY_STRIDE_1000",
    bind_phone_award = "BIND_PHONE_AWARD",
    jing_yu_kuai_pao_email_award = "JING_YU_KUAI_PAO_EMAIL_AWARD",
    activity_exchange_recycle="ACTIVITY_EXCHANGE_RECYCLE",
    watermelon_rank_award="WATERMElON_RANK_AWARD",
    vip_charge_award="VIP_CHARGE_AWARD",
    jing_yu_kuai_pao_auto_award ="JING_YU_KUAI_PAO_AUTO_AWARD",
    zhounianqing_yuyue_award="ZHOUNIANQING_YUYUE_AWARD",
    znq_look_back="ZNQ_LOOK_BACK",
    znq_jnb_exchange_dhq = "ZNQ_JNB_EXCHANGE_DHQ",
    zhounianqing_yingjing_rank_email_award = "ZHOUNIANQING_YINGJING_RANK_EMAIL_AWARD",
    znq_jnb_recycle = "ZNQ_JNB_RECYCLE",
    zhounianqing_yingjing_rank_wangzhe_email = "ZHOUNIANQING_YINGJING_RANK_WANGZHE_EMAIL",
    xiaoxiaole_once_game_rank_award="XIAOXIAOLE_ONCE_GAME_RANK_AWARD",
    withdraw_to_shop_gold="WITHDRAW_TO_SHOP_GOLD",
    new_user_qys_award = "NEW_USER_QYS_AWARD",
    qys_every_time_remind = "QYS_EVERY_TIME_REMIND",
    sign_in_award="SIGN_IN_AWARD",
    sign_in_acc_award="SIGN_IN_ACC_AWARD",
    email_notification_gift = "EMAIL_NOTIFICATION_GIFT",
    national_day_lottery_rank_email_award = "NATIONAL_DAY_LOTTERY_RANK_EMAIL_AWARD",
    sczd_achievement_sys_award = "SCZD_ACHIEVEMENT_SYS_AWARD",
    october_19_lottery_2_rank_email_award = "OCTOBER_19_LOTTERY_2_RANK_EMAIL_AWARD",
    box_exchange = "BOX_EXCHANGE",
    buyu_match_award = "BUYU_MATCH_AWARD",
    broke_beg = "BROKE_BEG",
    freestyle_activity_award_email = "FREESTYLE_ACTIVITY_AWARD_EMAIL",
    stxt_everyday_task_awards = "STXT_EVERYDAY_TASK_AWARDS",
    stxt_give_props = "STXT_GIVE_PROPS",
    yuyue_gns = "YUYUE_GNS",
    watch_ad_award = "WATCH_AD_AWARD",
    authentication_award = "AUTHENTICATION_AWARD",
    fish_3d_caibei_award = "FISH_3D_CAIBEI_AWARD",
    pay_exchange_room_card = "PAY_EXCHANGE_ROOM_CARD",
    all_return_lb_3_extra_award = "ALL_RETURN_LB_3_EXTRA_AWARD",
    pay_exchange_prop_fish_summon_fish = "PAY_EXCHANGE_PROP_FISH_SUMMON_FISH",
    npca_box_award = "NPCA_BOX_AWARD",
    xiaoxiaole_shuihu_once_game_rank_award = "XIAOXIAOLE_SHUIHU_ONCE_GAME_RANK_AWARD",
    add_fish_3d_gun = "ADD_FISH_3D_GUN",
    --存钱罐
    deposit_withdraw_money = "DEPOSIT_WITHDRAW_MONEY",
    --排名赛每日24:00结算奖励
    bullet_rank_everyday_email_award = "BULLET_RANK_EVERYDAY_EMAIL_AWARD",
    bullet_vip_rank_everyday_email_award = "BULLET_VIP_RANK_EVERYDAY_EMAIL_AWARD",
    bullet_rank_award_settle = "BULLET_RANK_AWARD_SETTLE",
    open_test = "OPEN_TEST",
    buyu_3d_yingjin_rank_email_award = "BUYU_3D_YINGJIN_RANK_EMAIL_AWARD",
    all_return_lb_overtime_award = "ALL_RETURN_LB_OVERTIME_AWARD",
    fishbowl_open = "FISHBOWL_OPEN",
    fishbowl_sale = "FISHBOWL_SALE",
    fishing_3d_game_free_lottery = "FISHING_3D_GAME_FREE_LOTTERY",
    fishing_3d_game_ad_fish = "FISHING_3D_GAME_AD_FISH",
    new_yueka_award = "NEW_YUEKA_AWARD",
    xiaolongxia_boss_025_rank_email_award = "XIAOLONGXIA_BOSS_025_RANK_EMAIL_AWARD",
    xiaolongxiaquan_025_rank_email_award = "XIAOLONGXIAQUAN_025_RANK_EMAIL_AWARD",
    true_love_026_rank_email_award = "TRUE_LOVE_026_RANK_EMAIL_AWARD",
    leijiyingjin_rank_email_award = "LEIJIYINGJIN_RANK_EMAIL_AWARD",
    leijixiaohao_rank_email_award = "LEIJIXIAOHAO_RANK_EMAIL_AWARD",

    ocean_explore_week_rank_email_award = "OCEAN_EXPLORE_WEEK_RANK_EMAIL_AWARD",
    jjsl_award = "JJSL_AWARD",
    fishbowl_sale_obj = "FISHBOWL_SALE_OBJ",
    fishbowl_sale_prop = "FISHBOWL_SALE_PROP",
    gun_overflow_award_barrel_1 = "GUN_OVERFLOW_AWARD_BARREL_1",
    gun_overflow_award_barrel_2 = "GUN_OVERFLOW_AWARD_BARREL_2",
    gun_overflow_award_barrel_3 = "GUN_OVERFLOW_AWARD_BARREL_3",
    gun_overflow_award_barrel_4 = "GUN_OVERFLOW_AWARD_BARREL_4",
    gun_overflow_award_barrel_5 = "GUN_OVERFLOW_AWARD_BARREL_5",
    gun_overflow_award_barrel_6 = "GUN_OVERFLOW_AWARD_BARREL_6",
    gun_overflow_award_barrel_7 = "GUN_OVERFLOW_AWARD_BARREL_7",
    s12_12_lhsjb_rank_email_award = "S12_12_LHSJB_RANK_EMAIL_AWARD",
    dz_jzsjb_rank_email_award = "DZ_JZSJB_RANK_EMAIL_AWARD",
    sd_lhsjb_rank_email_award = "SD_LHSJB_RANK_EMAIL_AWARD",
    yd_jyb_rank_email_award = "YD_JYD_RANK_EMAIL_AWARD",
    hlqd_xxphb_rank_email_award = "HLQD_XXPHB_RANK_EMAIL_AWARD",
    hhqjnh_046_lhsjb_rank_email_award = "HHQJNH_046_LHSJB_RANK_EMAIL_AWARD",
    khqd_001_lzphb_rank_email_award = "KHQD_001_LZPHB_RANK_EMAIL_AWARD",
    drswn_002_ygbd_rank_email_award = "DRWSN_002_YGBD_RANK_EMAIL_AWARD",
    cjs_003_bzphb_rank_email_award = "CJS_003_BZPHB_RANK_EMAIL_AWARD",
    sleep_act_task_auto_get_award_email_award = "SLEEP_ACT_TASK_AUTO_GET_AWARD_EMAIL_AWARD",
    xiaoxiaole_2_9_rate_rank_email_award = "XIAOXIAOLE_2_9_RATE_RANK_EMAIL_AWARD",
    gdn_004_jzbd_rank_email_award = "GDN_004_JZBD_RANK_EMAIL_AWRAD",
    ycs_005_jybb_rank_email_award = "YCS_005_JYBB_RANK_EMAIL_AWARD",
    nyx_006_yxbd_rank_email_award = "NYX_006_YXBD_RANK_EMAIL_AWARD",
    xxlzb_005_rank_email_award = "XXLZB_005_RANK_EMAIL_AWARD",
    kh315_008_lhphb_rank_email_award = "KH315_008_LHPHB_RANK_EMAIL_AWARD",
    xxlzb_005_rank_ext_email_award = "XXLZB_005_RANK_EXT_EMAIL_AWARD",
    kh315_008_lhphb_rank_ext_email_award = "KH315_008_LHPHB_RANK_EXT_EMAIL_AWARD",

    xxlzb_006_rank_email_award = "XXLZB_006_RANK_EMAIL_AWARD",
    cnhk_009_thphb_rank_email_award = "CNHK_009_THPHB_RANK_EMAIL_AWARD",
    xxlzb_006_rank_ext_email_award = "XXLZB_006_RANK_EXT_EMAIL_AWARD",
    cnhk_009_thphb_rank_ext_email_award = "CNHK_009_THPHB_RANK_EXT_EMAIL_AWARD",

    xxlzb_007_rank_email_award = "XXLZB_007_RANK_EMAIL_AWARD",
    xxlzb_007_rank_ext_email_award = "XXLZB_007_RANK_EXT_EMAIL_AWARD",
    ymkh_010_wxphb_rank_email_award = "YMKH_010_WXPHB_RANK_EMAIL_AWARD",
    ymkh_010_wxphb_rank_ext_email_award = "YMKH_010_WXPHB_RANK_EXT_EMAIL_AWARD",

    xxlzb_008_rank_email_award = "XXLZB_008_RANK_EMAIL_AWARD",
    xxlzb_008_rank_ext_email_award = "XXLZB_008_RANK_EXT_EMAIL_AWARD",
    qmyl_011_hdphb_rank_email_award = "QMYL_011_HDPHB_RANK_EMAIL_AWARD",
    qmyl_011_hdphb_rank_ext_email_award = "QMYL_011_HDPHB_RANK_EXT_EMAIL_AWARD",

    xxlzb_009_rank_email_award = "XXLZB_009_RANK_EMAIL_AWARD",
    xxlzb_009_rank_ext_email_award = "XXLZB_009_RANK_EXT_EMAIL_AWARD",
    ltqf_012_fqdr_rank_email_award = "ITQF_012_FQDR_RANK_EMAIL_AWARD",
    ltqf_012_fqdr_rank_ext_email_award = "ITQF_012_FQDR_RANK_EXT_EMAIL_AWARD",

    cjj_xxlzb_rank_email_award = "CJJ_XXLZB_RANK_EMAIL_AWARD",
    cjj_xxlzb_rank_ext_email_award = "CJJ_XXLZB_RANK_EXT_EMAIL_AWARD",
    hlsyt_013_bsyl_rank_email_award = "HLSYT_013_BSYL_RANK_EMAIL_AWARD",
    hlsyt_013_bsyl_rankk_ext_email_award = "HLSYT_013_BSYL_RANK_EXT_EMAIL_AWARD",

    wylft_014_ldxfb_rank_email_award = "WYLFT_014_LDXFB_RANK_EMAIL_AWARD",
    wylft_014_ldxfb_rank_ext_email_award = "WYLFT_014_LDXFB__RANK_EXT_EMAIL_AWARD",

    hljnh_015_yxdr_rank_email_award = "HLJNH_015_YXDR_RANK_EMAIL_AWARD",
    hljnh_015_yxdr_rank_ext_email_award = "HLJNH_015_YXDR_RANK_EXT_EMAIL_AWARD",

    hlwyt_016_fqdr_rank_email_award = "HLWYT_016_FQDR_RANK_EMAIL_AWARD",
    hlwyt_016_fqdr_rank_ext_email_award = "HLWYT_016_FQDR_RANK_EXT_EMAIL_AWARD",

    ymshf_017_hldr_rank_email_award = "YMSHF_017_HLDR_RANK_EMAIL_AWARD",
    ymshf_017_hldr_rank_ext_email_award = "YMSHF_017_HLDR_RANK_EXT_EMAIL_AWARD",
    
    hlly_018_hlbd_rank_email_award = "HLLY_018_HLBD_RANK_EMAIL_AWARD",
    hlly_018_hlbd_rank_ext_email_award = "HLLY_018_HLBD_RANK_EXT_EMAIL_AWARD",
    
    zqdw_019_fqdr_rank_email_award = "ZQDW_019_FQDR_RANK_EMAIL_AWARD",
    zqdw_019_fqdr_rank_ext_email_award = "ZQDW_019_FQDR_RANK_EXT_EMAIL_AWARD",
    
    fqjkh_020_yxbd_rank_email_award = "FQJKH_020_YXBD_RANK_EMAIL_AWARD",
    fqjkh_020_yxbd_rank_ext_email_award = "FQJKH_020_YXBD_RANK_EXT_EMAIL_AWARD",

    qlyx_021_xgphb_rank_email_award = "QLYX_021_XGPHB_RANK_EMAIL_AWARD",
    qlyx_021_xgphb_rank_ext_email_award = "QLYX_021_XGPHB_RANK_EXT_EMAIL_AWARD",

    yqhp_022_nqdr_rank_email_award = "YQHP_022_NQDR_RANK_EMAIL_AWARD",
    yqhp_022_nqdr_rank_ext_email_award = "YQHP_022_NQDR_RANK_EXT_EMAIL_AWARD",
    
    xrkh_023_ygbd_rank_email_award = "XRKH_023_YGBD_RANK_EMAIL_AWARD",
    xrkh_023_ygbd_rank_ext_email_award = "XRKH_023_YGBD_RANK_EXT_EMAIL_AWARD",

    lxjkh_024_jfphb_rank_email_award = "LXJKH_024_JFPHB_RANK_EMAIL_AWARD",
    lxjkh_024_jfphb_rank_ext_email_award = "LXJKH_024_JFPHB_RANK_EXT_EMAIL_AWARD",

    supreme_ranking_rank_email_award = "SUPREME_RANKING_RANK_EMAIL_AWARD",

    xiaoxiaole_tower_week_rank_email_award = "XIAOXIAOLE_TOWER_WEEK_RANK_EMAIL_AWARD",
    box_exchange_active_award_110_local = "BOX_EXCHANGE_ACTIVE_AWARD_110_LOCAL",
    
    --水族馆宝藏章鱼
    fishbowl_shop_buy = "FISHBOWL_SHOP_BUY",
    fishbowl_compose = "FISHBOWL_COMPOSE", -- 水族馆合成
    xxlzb_004_rank_email_award = "XXLZB_004_RANK_EMAIL_AWARD",
    nsj_007_mgbd_rank_email_award = "NSJ_007_MGBD_RANK_EMAIL_AWARD",
    xxl_card_chip_merge_award = "XXL_CARD_CHIP_MERGE_AWARD",
}

--不需要给tips的资产类型
NO_TIPS_ASSET_CHANGE_TYPE = {
    task_newplayer_xrcdj1 = "TASK_NEWPLAYER_XRCDJ1",
    task_newplayer_xrcdj2 = "TASK_NEWPLAYER_XRCDJ2",
    task_newplayer_xrcdj3 = "TASK_NEWPLAYER_XRCDJ3",
    task_p_029_hlqjd_hammer = "TASK_P_029_HLQJD_HAMMER",  --欢乐敲金蛋
    little_game_yingjin_task = "LITTLE_GAME_YINGJIN_TASK", -- 小游戏累计赢金抽红包
    buyu_fire_award_hongbao_task = "BUYU_FIRE_AWARD_HONGBAO_TASK", -- 3D捕鱼抽红包
    buyu_2d_leiji_dapao_new_task = "BUYU_2D_LEIJI_DAPAO_NEW_TASK", -- 街机捕鱼抽红包
    box_exchange_active_award_37 = "BOX_EXCHANGE_ACTIVE_AWARD_37", -- 新人抽大奖
    box_exchange_active_award_38 = "BOX_EXCHANGE_ACTIVE_AWARD_38",
    box_exchange_active_award_39 = "BOX_EXCHANGE_ACTIVE_AWARD_39",
    box_exchange_active_award_40 = "BOX_EXCHANGE_ACTIVE_AWARD_40", -- 免费福利券
    box_exchange_active_award_41 = "BOX_EXCHANGE_ACTIVE_AWARD_41", -- 免费话费
    box_exchange_active_award_42 = "BOX_EXCHANGE_ACTIVE_AWARD_42", -- 幸运转盘
    box_exchange_active_award_69 = "BOX_EXCHANGE_ACTIVE_AWARD_69", -- 庆典礼包
    box_exchange_active_award_87 = "BOX_EXCHANGE_ACTIVE_AWARD_87", -- 桃花礼包
    box_exchange_active_award_88 = "BOX_EXCHANGE_ACTIVE_AWARD_88", -- 话费礼包
    box_exchange_active_award_99 = "BOX_EXCHANGE_ACTIVE_AWARD_99", -- 消暑礼包
    box_exchange_active_award_104 = "BOX_EXCHANGE_ACTIVE_AWARD_104", -- 重阳礼包(稀有宝箱)
    box_exchange_active_award_105 = "BOX_EXCHANGE_ACTIVE_AWARD_105", -- 重阳礼包(传说宝箱)
    box_exchange_active_award_106 = "BOX_EXCHANGE_ACTIVE_AWARD_106", -- 重阳礼包(史诗宝箱)
    box_exchange_active_award_107 = "BOX_EXCHANGE_ACTIVE_AWARD_107", -- 祈福赠礼
    box_exchange_active_award_108 = "BOX_EXCHANGE_ACTIVE_AWARD_108", -- 祈福赠礼
    box_exchange_active_award_109 = "BOX_EXCHANGE_ACTIVE_AWARD_109", -- 祈福赠礼

    task_ocean_explore_week_children_task = "TASK_OCEAN_EXPLORE_WEEK_CHILDREN_TASK",--深海探险
    buy_gift_bag_10436 = "BUY_GIFT_BAG_10436",--超值周卡
    treasure_bowl_restore = "TREASURE_BOWL_RESTORE",--聚宝盆
    task_p_hammer = "TASK_P_HAMMER",--疯狂敲金蛋
    box_exchange_active_award_74 = "BOX_EXCHANGE_ACTIVE_AWARD_74",--新年送茅台
    box_exchange_active_award_75 = "BOX_EXCHANGE_ACTIVE_AWARD_75",--新年送茅台
    box_exchange_active_award_76 = "BOX_EXCHANGE_ACTIVE_AWARD_76",--新年送茅台
    box_exchange_active_award_77 = "BOX_EXCHANGE_ACTIVE_AWARD_77",-- 财神送礼
    box_exchange_active_award_78 = "BOX_EXCHANGE_ACTIVE_AWARD_78",-- 财神送礼
    box_exchange_active_award_89="BOX_EXCHANGE_ACTIVE_AWARD_89",---转盘抽奖
    box_exchange_active_award_96="BOX_EXCHANGE_ACTIVE_AWARD_96",---祈福抽奖
    box_exchange_active_award_97="BOX_EXCHANGE_ACTIVE_AWARD_97",---祈福抽奖
    box_exchange_active_award_98="BOX_EXCHANGE_ACTIVE_AWARD_98",---祈福抽奖
    box_exchange_active_award_93="BOX_EXCHANGE_ACTIVE_AWARD_93",---欢乐礼包
    box_exchange_active_award_94="BOX_EXCHANGE_ACTIVE_AWARD_94",--超级夺宝
    box_exchange_active_award_95="BOX_EXCHANGE_ACTIVE_AWARD_95",--超级夺宝

    box_exchange_active_award_100 = "BOX_EXCHANGE_ACTIVE_AWARD_100",
    
    box_exchange_active_award_101= "BOX_EXCHANGE_ACTIVE_AWARD_101",
    box_exchange_active_award_102= "BOX_EXCHANGE_ACTIVE_AWARD_102",
    box_exchange_active_award_103 = "BOX_EXCHANGE_ACTIVE_AWARD_103",
    
    task_award_1000069 = "TASK_AWARD_1000069", -- 星星获得
    fishbowl_lottery = "FISHBOWL_LOTTERY",
    task_award_1000129 = "TASK_AWARD_1000129", -- 礼盒掉落
    task_award_no_show = "TASK_AWARD_NO_SHOW",
    activity_exchange_43 = "ACTIVITY_EXCHANGE_43",
    activity_exchange_44 = "ACTIVITY_EXCHANGE_44",
    task_p_xrxsfl_hlby = "TASK_P_XRXSFL_HLBY",
    task_p_xrxsfl_cjj = "TASK_P_XRXSFL_CJJ",
    buy_gift_bag_10496="BUY_GIFT_BAG_10496",  --金币周卡解锁
    task_xiaoxiaole_tower = "TASK_XIAOXIAOLE_TOWER",
    change_assets_by_webview = "CHANGE_ASSETS_BY_WEBVIEW",
    box_exchange_active_award_110 = "BOX_EXCHANGE_ACTIVE_AWARD_110",

    task_aquaman_passport_base="TASK_AQUAMAN_PASSPORT_BASE"
}

-- 支付： 支持的渠道类型
PAY_CHANNEL_TYPE = {
    alipay = true,
    weixin = true
}

--商品类型
GOODS_TYPE = {
    goods = "goods",
    jing_bi = "jing_bi",
    item = "item",
    gift_bag = "gift_bag",
    shop_gold_sum = "shop_gold_sum",
    paotai = "paotai",
}


--优惠券 单位：分
CZYHQ = {
    [5000] = 500,
    [9800] = 1000,
    [19800] = 2000,
    [49800] = 5000,
    [99800] = 10000,
    [249800] = 20000,
}

--优惠券额度对应的道具
CZYHQ_ITEM = {
    [500] = "obj_5_coupon",
    [1000] = "obj_10_coupon",
    [2000] = "obj_20_coupon",
    [5000] = "obj_50_coupon",
    [10000] = "obj_100_coupon",
    [20000] = "obj_200_coupon",
}

--道具类型
ITEM_TYPE = {
    expression = "expression",
    jipaiqi = "jipaiqi",
    room_card = "room_card",
    qys_ticket = "prop_2",
}

-- 活动提示状态值
ACTIVITY_HINT_STATUS_ENUM = {
    AT_Nor = "常态",
    AT_Red = "红点",
    AT_Get = "领奖",
}

--玩家类型
PLAYER_TYPE = {
    PT_New = "新玩家",
    PT_Old = "老玩家",
}

-- 服务器名字(类型)
SERVER_TYPE = {
    ZS = "zs", -- 正式
    CS = "cs", -- 测试
}

-- 低保领取的金币条件
GAME_Di_Bao_JB = 20000