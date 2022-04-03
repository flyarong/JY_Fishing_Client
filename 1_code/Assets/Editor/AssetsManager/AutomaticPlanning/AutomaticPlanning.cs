// using System;
// using System.Collections.Generic;
// using System.IO;
// using System.Linq;
// using System.Runtime.Serialization.Formatters.Binary;
// using UnityEditor;
// using UnityEngine;
// using System.Xml.Serialization;
// using UnityEditor.IMGUI.Controls;
// using System.Text.RegularExpressions;
// using LitJson;

// public class AutomaticPlanning : EditorWindow
// {
//     //0:大版本构建，将未启用的活动资产放入具体游戏中 1:小版本升级，未启用的活动资产放在activity_normal
//     public static int updateType = 0;
//     public static Dictionary<string, string> actRe = new Dictionary<string, string>();
//     public static Dictionary<string, List<string>> codeRe = new Dictionary<string, List<string>>();
//     public static Dictionary<string, ReferenceFinderData.AssetDescription> mAssetDict;
//     public static Dictionary<string, MAssetDescription> mAsset;
//     //需要检查的目录 k:检查目录 v:检查目录
//     public static Dictionary<string, string> checkDir = new Dictionary<string, string>();
//     //需要打包目录 k:检查目录 v:公用资源存放目录
//     public static Dictionary<string, string> checkBaseDir = new Dictionary<string, string>();
//     //需要公用目录 k:检查目录 v:公用资源存放目录
//     public static Dictionary<string, string> checkNormalDir = new Dictionary<string, string>();
//     //游戏目录 k:检查目录 v:公用资源存放目录
//     public static Dictionary<string, string> checkGameDir = new Dictionary<string, string>();

//     //自动处理
//     [MenuItem("Window/资源整理/资源完全整理（慎用）", false, 1001)]
//     static void DynamicAssetPlanning()
//     {
//         updateType = 0;
//         //替换copy文件
//         SetCheckDir();
//         SetBaseAssetDir();
//         SetNormalAssetDir();
//         SetGameAssetDir();
//         ReferenceFinderWindow.RefreshData();
//         SetAsset(ReferenceFinderWindow.data.assetDict);
//         //设置引用关系
//         foreach (var kv in mAsset)
//         {
//             SetDependencies(kv.Key, kv.Key, kv.Key);
//             SetReferences(kv.Key, kv.Key, kv.Key);
//         }
//         //代码引用
//         SetCodeReferences();
//         SetActivityReferences();
//         foreach (var kv in mAsset)
//         {
//             SetMoveList(kv.Key, kv.Key);
//         }

//         SetMoveTarget();
//         MoveCorrect();
//         SetMovePath();
//         MoveAsset();
//     }

//     // [MenuItem("Window/资源整理/替换copy资源", false, 1003)]
//     static void ReplaceCopyAssets()
//     {
//         ReferenceFinderWindow.RefreshData();
//         mAssetDict = new Dictionary<string, ReferenceFinderData.AssetDescription>(ReferenceFinderWindow.data.assetDict);
//         List<string> guids = new List<string>();
//         foreach (var kv in mAssetDict)
//         {
//             if (kv.Value.path.Contains("&copy"))
//             {
//                 foreach (var item in mAssetDict)
//                 {
//                     if (item.Value.dependencies.Contains(kv.Key))
//                     {
//                         //找到直接引用对象
//                         guids.Add(item.Key);
//                     }
//                 }
//             }
//         }
//     }

//     private static void SetCheckDir()
//     {
//         string[] subFolders = AssetDatabase.GetSubFolders("Assets/Game");
//         checkDir.Clear();
//         foreach (var path in subFolders)
//         {
//             // Debug.Log("..."+path);
//             if (path != "Assets/Game/Channel"
//                 && path != "Assets/Game/Common"
//                 && path != "Assets/Game/Framework"
//                 && path != "Assets/Game/Sproto"
//                 && path != "Assets/Game/game_FishingTest")
//             {
//                 checkDir.Add(path, path);
//             }
//         }
//     }

//     private static void SetBaseAssetDir()
//     {
//         checkBaseDir.Clear();
//         //启动场景
//         // checkBaseDir.Add("_Assets", "CommonPrefab");
//         //启动场景
//         checkBaseDir.Add("LoadingPanel", "CommonPrefab");
//         //启动
//         checkBaseDir.Add("Entry", "CommonPrefab");
//         //登录
//         checkBaseDir.Add("game_Login", "CommonPrefab");
//         //加载
//         checkBaseDir.Add("game_Loding", "CommonPrefab");
//         //大厅
//         checkBaseDir.Add("game_Hall", "CommonPrefab");
//         //活动 --特殊处理
//         // checkBaseDir.Add("Activity", "CommonPrefab");
//     }

//     private static void SetNormalAssetDir()
//     {
//         checkNormalDir.Clear();
//         //公用
//         checkNormalDir.Add("CommonPrefab", "CommonPrefab");
//         checkNormalDir.Add("normal_base_common", "normal_base_common");
//         //斗地主公用
//         checkNormalDir.Add("normal_ddz_common", "normal_ddz_common");
//         //捕鱼公用
//         checkNormalDir.Add("normal_fishing_common", "normal_fishing_common");
//         //3D捕鱼公用
//         checkNormalDir.Add("normal_fishing3d_common", "normal_fishing3d_common");
//         //龙虎斗公用
//         checkNormalDir.Add("normal_lhd_common", "normal_lhd_common");
//         //麻将公用
//         checkNormalDir.Add("normal_mj_common", "normal_mj_common");
//         //抢红包公用
//         checkNormalDir.Add("normal_qhb_common", "normal_qhb_common");
//         //消消乐公用
//         checkNormalDir.Add("normal_xxl_common", "normal_xxl_common");
//         //疯狂捕鱼
//         checkNormalDir.Add("normal_fishing_dr_common", "normal_fishing_dr_common");
//     }

//     private static void SetGameAssetDir()
//     {
//         checkGameDir.Clear();
//         //比赛场大厅
//         checkGameDir.Add("game_MatchHall", "normal_base_common");
//         //自由场大厅
//         checkGameDir.Add("game_Free", "normal_base_common");
//         //小游戏大厅
//         checkGameDir.Add("game_MiniGame", "normal_base_common");

//         //斗地主房卡
//         checkGameDir.Add("game_DdzFK", "normal_ddz_common");
//         //斗地主自由
//         checkGameDir.Add("game_DdzFree", "normal_ddz_common");
//         //斗地主比赛
//         checkGameDir.Add("game_DdzMatch", "normal_ddz_common");
//         //斗地主跑得快
//         checkGameDir.Add("game_DdzPDK", "normal_ddz_common");
//         //斗地主跑得快比赛
//         checkGameDir.Add("game_DdzPDKMatch", "normal_ddz_common");
//         //斗地主听用
//         checkGameDir.Add("game_DdzTy", "normal_ddz_common");
//         //斗地主百万赛
//         checkGameDir.Add("game_DdzMillion", "normal_ddz_common");
//         //斗地主城市杯
//         checkGameDir.Add("game_CityMatch", "normal_ddz_common");
//         //斗地主自建房
//         checkGameDir.Add("game_DdzZJF", "normal_ddz_common");

//         //麻将血战
//         checkGameDir.Add("game_Mj3D", "normal_mj_common");
//         //麻将血流
//         checkGameDir.Add("game_MjXl3D", "normal_mj_common");
//         //麻将房卡
//         checkGameDir.Add("game_MjXzFK3D", "normal_mj_common");
//         //麻将比赛
//         checkGameDir.Add("game_MjXzMatchER3D", "normal_mj_common");

//         //消消乐水果
//         checkGameDir.Add("game_Eliminate", "normal_xxl_common");
//         //消消乐财神
//         checkGameDir.Add("game_EliminateCS", "normal_xxl_common");
//         //消消乐水浒
//         checkGameDir.Add("game_EliminateSH", "normal_xxl_common");

//         //捕鱼2D
//         checkGameDir.Add("game_Fishing", "normal_fishing_common");
//         //捕鱼2D大厅
//         checkGameDir.Add("game_FishingHall", "normal_fishing_common");
//         //捕鱼2D比赛
//         checkGameDir.Add("game_FishingMatch", "normal_fishing_common");
//         //捕鱼3D
//         checkGameDir.Add("game_Fishing3D", "normal_fishing3d_common");
//         //捕鱼3D大厅
//         checkGameDir.Add("game_Fishing3DHall", "normal_fishing3d_common");

//         //捕鱼达人
//         checkGameDir.Add("game_FishingDR", "normal_fishing_dr_common");

//         //五子棋
//         checkGameDir.Add("game_Gobang", "normal_base_common");

//         //龙虎斗
//         checkGameDir.Add("game_LHD", "normal_lhd_common");
//         //龙虎斗大厅
//         checkGameDir.Add("game_LHDHall", "normal_lhd_common");

//         //抢红包
//         checkGameDir.Add("game_QHB", "normal_qhb_common");
//         //抢红包大厅
//         checkGameDir.Add("game_QHBHall", "normal_qhb_common");

//         //砸金蛋
//         checkGameDir.Add("game_Zjd", "normal_base_common");

//         //扫码
//         checkGameDir.Add("game_ScannerQRCode", "normal_base_common");

//         //种苹果
//         checkGameDir.Add("game_ZPG", "normal_base_common");
//         //自建房
//         checkGameDir.Add("game_ZJF", "normal_base_common");
//         //弹弹乐
//         checkGameDir.Add("game_TTL", "normal_base_common");
//     }

//     private static void SetAsset(Dictionary<string, ReferenceFinderData.AssetDescription> assetDict)
//     {
//         mAssetDict = new Dictionary<string, ReferenceFinderData.AssetDescription>(assetDict);
//         mAsset = new Dictionary<string, MAssetDescription>();
//         foreach (var kv in assetDict)
//         {
//             foreach (var _kv in checkDir)
//             {
//                 //只关心game中的资源，其他资源另行处理
//                 if (!mAsset.ContainsKey(kv.Key) && kv.Value.path.Contains(_kv.Key))
//                 {
//                     MAssetDescription mad = new MAssetDescription();
//                     mad.name = kv.Value.name;
//                     mad.path = kv.Value.path;
//                     mad.assetDependencyHash = kv.Value.assetDependencyHash;
//                     mad.state = kv.Value.state;
//                     mad.dependencies = kv.Value.dependencies;
//                     mad.references = kv.Value.references;
//                     mad.dependenciesRoot = new List<string>();
//                     mad.referencesRoot = new List<string>();
//                     mad.dependenciesAll = new List<string>();
//                     mad.referencesAll = new List<string>();
//                     mad.referencesAllCode = new List<string>();
//                     mad.referencesAllAct = new List<string>();

//                     string path = kv.Value.path;
//                     string[] pathArr = path.Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries);
//                     string name = pathArr[pathArr.Length - 1];
//                     mad.nameSuffix = name;

//                     string at = AssetDatabase.GetMainAssetTypeAtPath(kv.Value.path).ToString();
//                     string[] atArray = at.Split(new string[] { "." }, StringSplitOptions.RemoveEmptyEntries);
//                     at = atArray[atArray.Length - 1];
//                     if (at == "GameObject" || at == "DefaultAsset")
//                     {
//                         //不能判定准确类型
//                         string[] nameArr = name.Split(new string[] { "." }, StringSplitOptions.RemoveEmptyEntries);
//                         string _name = nameArr[nameArr.Length - 1];
//                         _name = _name.Substring(0).ToLower();
//                         at = _name.Substring(0, 1).ToUpper() + _name.Substring(1);
//                     }
//                     mad.type = at;

//                     mAsset.Add(kv.Key, mad);
//                 }
//             }
//         }
//         Debug.Log("asset count : " + mAsset.Count);
//     }

//     private static void SetMovePath()
//     {
//         foreach (var kv in mAsset)
//         {
//             //排除类型
//             if ((kv.Value.type == "Lua") || (kv.Value.type == "SceneAsset")) continue;
//             //AssetDatabase.IsValidFolder
//             if (!string.IsNullOrEmpty(kv.Value.moveTarget))
//             {
//                 if (kv.Value.moveTarget == "Activity" || kv.Value.moveTarget == "Activity/normal_activity_common")
//                 {
//                     if (kv.Value.referencesRoot != null && kv.Value.referencesRoot.Count == 1)
//                     {
//                         string rePath = mAsset[kv.Value.referencesRoot[0]].path;
//                         string[] rsArray = rePath.Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries);
//                         string path = "";
//                         for (int i = 0; i < 4; i++)
//                         {
//                             path = path + rsArray[i] + "/";
//                         }
//                         mAsset[kv.Key].moveParentFolder = path.Substring(0, path.Length - 1);
//                         mAsset[kv.Key].moveFolder = kv.Value.type;
//                         mAsset[kv.Key].movePath = mAsset[kv.Key].moveParentFolder + "/" + mAsset[kv.Key].moveFolder + "/" + kv.Value.nameSuffix;
//                     }
//                     else if (kv.Value.referencesRoot != null && kv.Value.referencesRoot.Count > 1)
//                     {
//                         string fl = "";
//                         for (int k = 0; k < kv.Value.referencesRoot.Count; k++)
//                         {
//                             string rePath = mAsset[kv.Value.referencesRoot[k]].path;
//                             string[] rsArray = rePath.Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries);
//                             if (string.IsNullOrEmpty(fl))
//                             {
//                                 fl = rsArray[3];
//                             }
//                             else
//                             {
//                                 if (fl != rsArray[3])
//                                 {
//                                     //多个活动公用
//                                     fl = "normal_activity_common";
//                                     break;
//                                 }
//                             }
//                         }
//                         if (fl == "normal_activity_common")
//                         {
//                             // string[] act;
//                             // foreach (var item in kv.Value.referencesRoot)
//                             // {
//                             //     act = item.Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries);
//                             // }
//                             //所有活动关闭不需要
//                             bool only_act = true;
//                             foreach (var item in kv.Value.referencesRoot)
//                             {
//                                 string str = mAsset[item].path;
//                                 if (!str.Contains("Assets/Game/Activity/"))
//                                 {
//                                     only_act = false;
//                                     break;
//                                 }
//                             }
//                             bool all_hide = true;
//                             if (only_act)
//                             {
//                                 foreach (var item in kv.Value.referencesRoot)
//                                 {
//                                     string str = mAsset[item].path;
//                                     string[] act = str.Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries);
//                                     if (actRe.ContainsKey(act[3]) && actRe[act[3]] == "true")
//                                     {
//                                         all_hide = false;
//                                         break;
//                                     }
//                                 }
//                             }else{
//                                 all_hide = false;
//                             }
//                             string moveFolder = kv.Value.type;
//                             if (all_hide)
//                             {
//                                 moveFolder = "_" + moveFolder;
//                             }
//                             mAsset[kv.Key].moveParentFolder = "Assets/Game/Activity/" + fl;
//                             mAsset[kv.Key].moveFolder = moveFolder;
//                             mAsset[kv.Key].movePath = mAsset[kv.Key].moveParentFolder + "/" + mAsset[kv.Key].moveFolder + "/" + kv.Value.nameSuffix;
//                         }
//                         else
//                         {
//                             string rePath = mAsset[kv.Value.referencesRoot[0]].path;
//                             string[] rsArray = rePath.Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries);
//                             string path = "";
//                             for (int i = 0; i < 4; i++)
//                             {
//                                 path = path + rsArray[i] + "/";
//                             }
//                             mAsset[kv.Key].moveParentFolder = path.Substring(0, path.Length - 1);
//                             mAsset[kv.Key].moveFolder = kv.Value.type;
//                             mAsset[kv.Key].movePath = mAsset[kv.Key].moveParentFolder + "/" + mAsset[kv.Key].moveFolder + "/" + kv.Value.nameSuffix;
//                         }
//                     }
//                 }
//                 else
//                 {
//                     mAsset[kv.Key].moveParentFolder = "Assets/Game/" + mAsset[kv.Key].moveTarget;
//                     mAsset[kv.Key].moveFolder = kv.Value.type;
//                     mAsset[kv.Key].movePath = mAsset[kv.Key].moveParentFolder + "/" + mAsset[kv.Key].moveFolder + "/" + kv.Value.nameSuffix;
//                 }
//             }
//             else
//             {
//                 //不需要移动的资源进行整理
//                 string at = kv.Value.type;
//                 string[] pathArr = kv.Value.path.Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries);
//                 if ((kv.Value.referencesAll == null || kv.Value.referencesAll.Count == 0)
//                     && (kv.Value.dependenciesAll == null || kv.Value.dependenciesAll.Count == 0)
//                     && (kv.Value.referencesAllCode == null || kv.Value.referencesAllCode.Count == 0)
//                     && (kv.Value.referencesAllAct == null || kv.Value.referencesAllAct.Count == 0))
//                 {
//                     //没有引用，没有被引用，没有代码引用，没有活动引用
//                     at = "_" + at;
//                 }
//                 else if (kv.Value.type != "Prefab"
//                    && (kv.Value.referencesAllCode == null || kv.Value.referencesAllCode.Count == 0)
//                    && (kv.Value.referencesAllAct == null || kv.Value.referencesAllAct.Count == 0))
//                 {
//                     //非预制体资源 没有被用到，没有代码引用，没有活动引用
//                     if (kv.Value.referencesRoot != null && kv.Value.referencesRoot.Count > 0)
//                     {
//                         //是否被预制体使用
//                         bool is_pre = false;
//                         for (int i = 0; i < kv.Value.referencesRoot.Count; i++)
//                         {
//                             if (mAsset[kv.Value.referencesRoot[i]].type == "Prefab" || mAsset[kv.Value.referencesRoot[i]].type == "SceneAsset")
//                             {
//                                 is_pre = true;
//                                 break;
//                             }
//                         }
//                         if (!is_pre)
//                         {
//                             at = "_" + at;
//                         }
//                     }
//                     else if (kv.Value.referencesAll != null && kv.Value.referencesAll.Count > 0)
//                     {
//                         //是否被预制体使用
//                         bool is_pre = false;
//                         for (int i = 0; i < kv.Value.referencesAll.Count; i++)
//                         {
//                             if (mAsset[kv.Value.referencesAll[i]].type == "Prefab" || mAsset[kv.Value.referencesAll[i]].type == "SceneAsset")
//                             {
//                                 is_pre = true;
//                                 break;
//                             }
//                         }
//                         if (!is_pre)
//                         {
//                             at = "_" + at;
//                         }
//                     }
//                     else
//                     {
//                         at = "_" + at;
//                     }
//                 }

//                 if (kv.Value.path.Contains("Assets/Game/Activity"))
//                 {
//                     //活动
//                     string _path = "";
//                     for (int i = 0; i < 4; i++)
//                     {
//                         _path = _path + pathArr[i] + "/";
//                     }
//                     mAsset[kv.Key].moveParentFolder = _path.Substring(0, _path.Length - 1);
//                     mAsset[kv.Key].moveFolder = at;
//                     mAsset[kv.Key].movePath = mAsset[kv.Key].moveParentFolder + "/" + mAsset[kv.Key].moveFolder + "/" + kv.Value.nameSuffix;
//                 }
//                 else
//                 {
//                     string moveTarget = pathArr[2];
//                     mAsset[kv.Key].moveParentFolder = "Assets/Game/" + moveTarget;
//                     mAsset[kv.Key].moveFolder = at;
//                     mAsset[kv.Key].movePath = mAsset[kv.Key].moveParentFolder + "/" + mAsset[kv.Key].moveFolder + "/" + kv.Value.nameSuffix;
//                 }
//             }
//         }

//         // CollectSpine();
//         CollectMaterialTexture2D();
//         CollectTexture2DTpsheet();
//         CollectFont();
//         CollectFbx();
//         RemoveSpine();

//         if (ReadSureRefreences())
//         {
//             //读取缓存成功
//             foreach (var kv in mAsset)
//             {
//                 foreach (var item in sureAssetList)
//                 {
//                     if (kv.Value.nameSuffix == item && !kv.Value.movePath.Contains("Assets/Game/Activity"))
//                     {
//                         if (kv.Value.moveFolder.Contains("_"))
//                         {
//                             mAsset[kv.Key].moveFolder = mAsset[kv.Key].moveFolder.Replace("_", "");
//                             mAsset[kv.Key].movePath = mAsset[kv.Key].moveParentFolder + "/" + mAsset[kv.Key].moveFolder + "/" + mAsset[kv.Key].nameSuffix;
//                         }
//                     }
//                 }
//             }
//         }

//         foreach (var kv in mAsset)
//         {
//             // if(kv.Value.path.Contains("3dby_font_jz")){
//             //     DebugToConsole(kv,0);
//             // }
//             if (mAsset[kv.Key].path == mAsset[kv.Key].movePath)
//             {
//                 mAsset[kv.Key].moveTarget = "";
//                 mAsset[kv.Key].moveParentFolder = "";
//                 mAsset[kv.Key].moveFolder = "";
//                 mAsset[kv.Key].movePath = "";
//                 mAsset[kv.Key].moveList.Clear();
//             }
//         }
//     }

//     public static string DebugToConsole(KeyValuePair<string, MAssetDescription> kv, int i)
//     {
//         string str = "";
//         if (!string.IsNullOrEmpty(kv.Value.moveTarget))
//             str += "------------------------------------------------------" + i + "\n";
//         else if (!string.IsNullOrEmpty(kv.Value.movePath))
//             str += "======================================================" + i + "\n";
//         str += "name:" + kv.Value.name + "    ";
//         str += "path:" + kv.Value.path + "    ";
//         str += "type:" + kv.Value.type + "\n";
//         str += "moveTarget:" + kv.Value.moveTarget + "\n";
//         str += "moveParentFolder:" + kv.Value.moveParentFolder + "\n";
//         str += "moveFolder:" + kv.Value.moveFolder + "\n";
//         str += "movePath:" + kv.Value.movePath + "\n";
//         foreach (var item in kv.Value.moveList)
//         {
//             str += "moveList:" + item + "\n";
//         }
//         foreach (var item in kv.Value.moveComList)
//         {
//             str += "moveComList:" + item + "\n";
//         }
//         for (int k = 0; k < kv.Value.references.Count; k++)
//         {
//             if (mAsset.ContainsKey(kv.Value.references[k]))
//             str += "references:" + mAsset[kv.Value.references[k]].path + "\n";
//         }
//         for (int k = 0; k < kv.Value.referencesAll.Count; k++)
//         {
//             if (mAsset.ContainsKey(kv.Value.referencesAll[k]))
//             str += "referencesAll:" + mAsset[kv.Value.referencesAll[k]].path + "\n";
//         }
//         for (int k = 0; k < kv.Value.referencesRoot.Count; k++)
//         {
//             if (mAsset.ContainsKey(kv.Value.referencesRoot[k]))
//             str += "referencesRoot:" + mAsset[kv.Value.referencesRoot[k]].path + "\n";
//         }
//         for (int k = 0; k < kv.Value.referencesAllCode.Count; k++)
//         {
//             if (mAsset.ContainsKey(kv.Value.referencesAllCode[k]))
//             str += "referencesAllCode:" + mAsset[kv.Value.referencesAllCode[k]].path + "\n";
//         }
//         for (int k = 0; k < kv.Value.referencesAllAct.Count; k++)
//         {
//             // if (mAsset.ContainsKey(kv.Value.referencesAllAct[k]))
//             str += "referencesAllAct:" + kv.Value.referencesAllAct[k] + "\n";
//         }
//         for (int k = 0; k < kv.Value.dependencies.Count; k++)
//         {
//             if (mAsset.ContainsKey(kv.Value.dependencies[k]))
//             str += "dependencies:" + mAsset[kv.Value.dependencies[k]].path + "\n";
//         }
//         for (int k = 0; k < kv.Value.dependenciesAll.Count; k++)
//         {
//             if (mAsset.ContainsKey(kv.Value.dependenciesAll[k]))
//             str += "dependenciesAll:" + mAsset[kv.Value.dependenciesAll[k]].path + "\n";
//         }
//         for (int k = 0; k < kv.Value.dependenciesRoot.Count; k++)
//         {
//             if (mAsset.ContainsKey(kv.Value.dependenciesRoot[k]))
//             str += "dependenciesRoot:" + mAsset[kv.Value.dependenciesRoot[k]].path + "\n";
//         }
//         Debug.Log(str);
//         return str;
//     }

//     private static void MoveCorrect()
//     {
//         foreach (var kv in mAsset)
//         {
//             if (!string.IsNullOrEmpty(kv.Value.moveTarget))
//             {
//                 //检查是否需要移动
//                 string path = kv.Value.path;
//                 path = path.Replace('\\', '/');
//                 string[] sArray = path.Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries);
//                 string tPath = sArray[2];

//                 if (kv.Value.moveTarget == "Activity/normal_activity_common")
//                 {
//                     tPath = sArray[1] + "/" + sArray[2];
//                 }

//                 //当前目录和目标目录一样检查是否需要移动
//                 if (tPath == kv.Value.moveTarget)
//                 {
//                     int index = 2;
//                     if (kv.Value.moveTarget == "Activity" || kv.Value.moveTarget == "Activity/normal_activity_common")
//                     {
//                         //活动
//                         index = 3;
//                     }
//                     else
//                     {
//                         //目录相同不需要移动
//                         mAsset[kv.Key].moveTarget = "";
//                         mAsset[kv.Key].moveList.Clear();
//                         continue;
//                     }
//                     if (kv.Value.referencesRoot != null && kv.Value.referencesRoot.Count == 1)
//                     {
//                         string rePath = mAsset[kv.Value.referencesRoot[0]].path;
//                         string[] pathArr = rePath.Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries);
//                         if (pathArr.Contains(sArray[index]))
//                         {
//                             //目录相同不需要移动
//                             mAsset[kv.Key].moveTarget = "";
//                             mAsset[kv.Key].moveList.Clear();
//                         }
//                     }
//                     else if (kv.Value.referencesRoot != null && kv.Value.referencesRoot.Count > 1)
//                     {
//                         bool isMove = false;
//                         for (int k = 0; k < kv.Value.referencesRoot.Count; k++)
//                         {
//                             string rePath = mAsset[kv.Value.referencesRoot[k]].path;
//                             string[] pathArr = rePath.Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries);
//                             if (!pathArr.Contains(sArray[index]))
//                             {
//                                 isMove = true;
//                                 break;
//                             }
//                         }
//                         if (!isMove)
//                         {
//                             //目录相同不需要移动
//                             mAsset[kv.Key].moveTarget = "";
//                             mAsset[kv.Key].moveList.Clear();
//                         }
//                     }
//                 }
//             }
//         }
//     }

//     private static void SetMoveTarget()
//     {
//         foreach (var kv in mAsset)
//         {
//             // if(kv.Value.path.Contains("3dby_font_jz")){
//             //     DebugToConsole(kv,0);
//             // }
//             if (kv.Value.moveList != null && kv.Value.moveList.Count > 0)
//             {
//                 //有移动意向
//                 string moveTarget = "";
//                 string curMove = "";
//                 string key = kv.Key;
//                 if (kv.Value.moveList.Count == 1)
//                 {
//                     //只想移动到一个地方
//                     curMove = kv.Value.moveList[0];
//                     moveTarget = curMove;
//                     if (checkBaseDir.ContainsKey(curMove))
//                     {
//                         mAsset[key].moveTarget = moveTarget;
//                     }
//                     else if (checkNormalDir.ContainsKey(curMove))
//                     {
//                         mAsset[key].moveTarget = moveTarget;
//                     }
//                     else if (checkGameDir.ContainsKey(curMove))
//                     {
//                         mAsset[key].moveTarget = moveTarget;
//                     }
//                     else if (curMove == "Activity")
//                     {
//                         mAsset[key].moveTarget = moveTarget;
//                     }
//                 }
//                 else
//                 {
//                     //排除activity后
//                     if (kv.Value.moveList.Count == 2 && kv.Value.moveList.Contains("Activity"))
//                     {
//                         if (kv.Value.moveList[0] != "Activity")
//                         {
//                             curMove = kv.Value.moveList[0];
//                         }
//                         else
//                         {
//                             curMove = kv.Value.moveList[1];
//                         }
//                         moveTarget = curMove;
//                         if (checkBaseDir.ContainsKey(curMove))
//                         {
//                             mAsset[key].moveTarget = moveTarget;
//                         }
//                         else if (checkNormalDir.ContainsKey(curMove))
//                         {
//                             mAsset[key].moveTarget = moveTarget;
//                         }
//                         else if (checkGameDir.ContainsKey(curMove))
//                         {
//                             mAsset[key].moveTarget = moveTarget;
//                         }
//                     }
//                     else
//                     {
//                         List<string> moveComList = new List<string>();
//                         for (int i = 0; i < kv.Value.moveList.Count; i++)
//                         {
//                             curMove = kv.Value.moveList[i];
//                             if (checkBaseDir.ContainsKey(curMove))
//                             {
//                                 if (!moveComList.Contains(checkBaseDir[curMove]))
//                                 {
//                                     moveComList.Add(checkBaseDir[curMove]);
//                                 }
//                             }
//                             if (checkNormalDir.ContainsKey(curMove))
//                             {
//                                 if (!moveComList.Contains(checkNormalDir[curMove]))
//                                 {
//                                     moveComList.Add(checkNormalDir[curMove]);
//                                 }
//                             }
//                             if (checkGameDir.ContainsKey(curMove))
//                             {
//                                 if (!moveComList.Contains(checkGameDir[curMove]))
//                                 {
//                                     moveComList.Add(checkGameDir[curMove]);
//                                 }
//                             }
//                         }
//                         mAsset[kv.Key].moveComList = moveComList;
//                         if (moveComList.Count == 1)
//                         {
//                             moveTarget = moveComList[0];
//                         }
//                         else
//                         {
//                             if (moveComList.Contains("CommonPrefab"))
//                             {
//                                 moveTarget = "CommonPrefab";
//                             }
//                             else
//                             {
//                                 moveTarget = "normal_base_common";
//                             }
//                         }
//                     }

//                     if (moveTarget != "CommonPrefab")
//                     {
//                         if (kv.Value.moveList.Contains("Activity"))
//                         {
//                             if (kv.Value.referencesAllAct != null && kv.Value.referencesAllAct.Count > 0)
//                             {
//                                 //活动激活移动到活动公用里面
//                                 moveTarget = "Activity/normal_activity_common";
//                             }
//                             else
//                             {
//                                 for (int k = 0; k < kv.Value.referencesRoot.Count; k++)
//                                 {
//                                     if (mAsset[kv.Value.referencesRoot[k]].referencesAllAct != null && mAsset[kv.Value.referencesRoot[k]].referencesAllAct.Count > 0)
//                                     {
//                                         //活动激活移动到活动公用里面
//                                         moveTarget = "Activity/normal_activity_common";
//                                         break;
//                                     }
//                                 }
//                                 //活动未激活移动到游戏场景里面
//                                 if (moveTarget != "Activity/normal_activity_common")
//                                 {
//                                     if (updateType == 1)
//                                     {
//                                         //小版本更新，尽量保持不变
//                                         moveTarget = "";
//                                     }
//                                 }
//                             }
//                         }
//                     }
//                     mAsset[key].moveTarget = moveTarget;
//                 }
//             }
//             else
//             {
//                 //不需要移动
//             }
//         }
//     }

//     private static void SetMoveList(string key, string cur_key)
//     {
//         var m_as = mAsset[cur_key];
//         if (m_as.referencesRoot != null && m_as.referencesRoot.Count > 0)
//         {
//             //根引用
//             for (int i = 0; i < m_as.referencesRoot.Count; i++)
//             {
//                 string[] pathArr = mAsset[m_as.referencesRoot[i]].path.Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries);
//                 foreach (var item in checkBaseDir)
//                 {
//                     if (pathArr.Contains(item.Key))
//                     {
//                         if (!mAsset[key].moveList.Contains(item.Key))
//                         {
//                             mAsset[key].moveList.Add(item.Key);
//                         }
//                     }
//                 }

//                 foreach (var item in checkNormalDir)
//                 {
//                     if (pathArr.Contains(item.Key))
//                     {
//                         if (!mAsset[key].moveList.Contains(item.Key))
//                         {
//                             mAsset[key].moveList.Add(item.Key);
//                         }
//                     }
//                 }

//                 foreach (var item in checkGameDir)
//                 {
//                     if (pathArr.Contains(item.Key))
//                     {
//                         if (!mAsset[key].moveList.Contains(item.Key))
//                         {
//                             mAsset[key].moveList.Add(item.Key);
//                         }
//                     }
//                 }
//                 if (pathArr.Contains("Activity"))
//                 {
//                     if (!mAsset[key].moveList.Contains("Activity"))
//                     {
//                         mAsset[key].moveList.Add("Activity");
//                     }
//                 }
//             }
//         }
//         if (m_as.dependenciesRoot != null && m_as.dependenciesRoot.Count > 0)
//         {

//         }
//         if (m_as.referencesAll != null && m_as.referencesAll.Count > 0)
//         {
//             //所有引用
//             for (int i = 0; i < m_as.referencesAll.Count; i++)
//             {
//                 SetMoveList(key, m_as.referencesAll[i]);
//             }
//         }
//         if (m_as.dependenciesAll != null && m_as.dependenciesAll.Count > 0)
//         {

//         }
//     }

//     private static void SetActivityReferences()
//     {
//         // if (true) return;
//         string json_str = File.ReadAllText("Assets/VersionConfig/ActivityConfig.json");
//         JsonData jsonData = JsonMapper.ToObject(json_str);
//         JsonData activities = jsonData["activities"];
//         actRe.Clear();
//         foreach (JsonData item in activities)
//         {
//             JsonData name = item["name"]; //通过字符串索引器可以取得键值对的值
//             JsonData enable = item["enable"];
//             // Debug.Log(name.ToString());
//             string[] pathArr = name.ToString().Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries);
//             // Debug.Log(pathArr[1]);
//             actRe.Add(pathArr[1], enable.ToString().ToLower());
//         }
//         // foreach (var item in actRe)
//         // {
//         //     Debug.Log(item.Key + " " + item.Value);
//         // }

//         //记录活动引用
//         foreach (var kv in mAsset)
//         {
//             foreach (var item in actRe)
//             {
//                 string[] pathArr = kv.Value.path.Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries);
//                 if (pathArr[2] == item.Key && item.Value == "true")
//                 {
//                     mAsset[kv.Key].referencesAllAct.Add(item.Key);
//                 }
//                 if (kv.Value.referencesRoot != null && kv.Value.referencesRoot.Count > 0 ){
//                     foreach (var k in kv.Value.referencesRoot)
//                     {
//                         string[] _pathArr = mAsset[k].path.Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries);
//                         if (_pathArr.Contains(item.Key)  && item.Value == "true")
//                         {
//                             mAsset[kv.Key].referencesAllAct.Add(item.Key);
//                         }
//                     }
//                 }
//             }
//         }
//     }

//     private static void SetCodeReferences()
//     {
//         codeRe.Clear();
//         foreach (var kv in mAsset)
//         {
//             if (!(kv.Value.type == "Lua")) continue;
//             string[] lua_line = File.ReadAllLines(kv.Value.path);
//             for (int i = 0; i < lua_line.Length; i++)
//             {
//                 if (lua_line[i].Contains("GetTexture")
//                     || lua_line[i].Contains("Get3DTexture")
//                     || lua_line[i].Contains("GetPrefab")
//                     || lua_line[i].Contains("GetMaterial")
//                     || lua_line[i].Contains("GetFont")
//                     || lua_line[i].Contains("GetAudio"))
//                 {
//                     // Debug.Log("代码引用 " + lua_line[i]);
//                     if (!codeRe.ContainsKey(kv.Key))
//                     {
//                         codeRe.Add(kv.Key, new List<string>());
//                     }
//                     codeRe[kv.Key].Add(lua_line[i]);
//                 }
//             }
//             if (kv.Value.name == "item_config")
//             {
//                 //背包道具
//                 for (int i = 0; i < lua_line.Length; i++)
//                 {
//                     if (lua_line[i].Contains("image ="))
//                     {
//                         // Debug.Log("代码引用 " + lua_line[i]);
//                         if (!codeRe.ContainsKey(kv.Key))
//                         {
//                             codeRe.Add(kv.Key, new List<string>());
//                         }
//                         codeRe[kv.Key].Add(lua_line[i]);
//                     }
//                 }
//             }
//             if (kv.Value.name == "shoping_config")
//             {
//                 //商店
//                 for (int i = 0; i < lua_line.Length; i++)
//                 {
//                     if (lua_line[i].Contains("icon_image =")
//                         || lua_line[i].Contains("ui_icon =")
//                         || lua_line[i].Contains("ui_icon_bg ="))
//                     {
//                         // Debug.Log("代码引用 " + lua_line[i]);
//                         if (!codeRe.ContainsKey(kv.Key))
//                         {
//                             codeRe.Add(kv.Key, new List<string>());
//                         }
//                         codeRe[kv.Key].Add(lua_line[i]);
//                     }
//                 }
//             }
//             if (kv.Value.name == "fish_config")
//             {
//                 //鱼
//                 for (int i = 0; i < lua_line.Length; i++)
//                 {
//                     if (lua_line[i].Contains("icon =")
//                         || lua_line[i].Contains("name_image ="))
//                     {
//                         // Debug.Log("代码引用 " + lua_line[i]);
//                         if (!codeRe.ContainsKey(kv.Key))
//                         {
//                             codeRe.Add(kv.Key, new List<string>());
//                         }
//                         codeRe[kv.Key].Add(lua_line[i]);
//                     }
//                 }
//             }
//             if (kv.Value.name == "fish3d_config")
//             {
//                 //3d鱼
//                 for (int i = 0; i < lua_line.Length; i++)
//                 {
//                     if (lua_line[i].Contains("icon =")
//                         || lua_line[i].Contains("name_image ="))
//                     {
//                         // Debug.Log("代码引用 " + lua_line[i]);
//                         if (!codeRe.ContainsKey(kv.Key))
//                         {
//                             codeRe.Add(kv.Key, new List<string>());
//                         }
//                         codeRe[kv.Key].Add(lua_line[i]);
//                     }
//                 }
//             }
//             if (kv.Value.name == "fish_map_config")
//             {
//                 //鱼百科
//                 for (int i = 0; i < lua_line.Length; i++)
//                 {
//                     if (lua_line[i].Contains("icon ="))
//                     {
//                         // Debug.Log("代码引用 " + lua_line[i]);
//                         if (!codeRe.ContainsKey(kv.Key))
//                         {
//                             codeRe.Add(kv.Key, new List<string>());
//                         }
//                         codeRe[kv.Key].Add(lua_line[i]);
//                     }
//                 }
//             }
//             if (kv.Value.name == "fish3d_map_config")
//             {
//                 //3d鱼百科
//                 for (int i = 0; i < lua_line.Length; i++)
//                 {
//                     if (lua_line[i].Contains("icon ="))
//                     {
//                         // Debug.Log("代码引用 " + lua_line[i]);
//                         if (!codeRe.ContainsKey(kv.Key))
//                         {
//                             codeRe.Add(kv.Key, new List<string>());
//                         }
//                         codeRe[kv.Key].Add(lua_line[i]);
//                     }
//                 }
//             }
//             if (kv.Value.name == "audio_config")
//             {
//                 //3d鱼百科
//                 for (int i = 0; i < lua_line.Length; i++)
//                 {
//                     if (lua_line[i].Contains("audio_name ="))
//                     {
//                         // Debug.Log("代码引用 " + lua_line[i]);
//                         if (!codeRe.ContainsKey(kv.Key))
//                         {
//                             codeRe.Add(kv.Key, new List<string>());
//                         }
//                         codeRe[kv.Key].Add(lua_line[i]);
//                     }
//                 }
//             }
//         }
//         //记录代码引用
//         foreach (var kv in mAsset)
//         {
//             foreach (var item in codeRe)
//             {
//                 for (int i = 0; i < item.Value.Count; i++)
//                 {
//                     if (item.Value[i].Contains(kv.Value.name))
//                     {
//                         if(!mAsset[kv.Key].referencesAllCode.Contains(item.Key)){
//                             mAsset[kv.Key].referencesAllCode.Add(item.Key);
//                         }
//                     }
//                 }
//             }
//         }
//     }

//     private static void CheckFolder(string path)
//     {
//         string[] rsArray = path.Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries);
//         string _path = "";
//         for (int k = 0; k < rsArray.Length - 1; k++)
//         {
//             _path = _path + rsArray[k] + "/";
//         }
//         _path = _path.Substring(0, _path.Length - 1);

//         if (!AssetDatabase.IsValidFolder(_path))
//         {
//             CheckFolder(_path);
//         }
//         else
//         {
//             if (!AssetDatabase.IsValidFolder(path))
//             {
//                 AssetDatabase.CreateFolder(_path, rsArray[rsArray.Length - 1]);
//             }
//         }
//     }

//     private static void MoveAsset()
//     {
//         int i = 0;
//         foreach (var kv in mAsset)
//         {
//             //没有移动目标和不需要移动的资源，不移动
//             if (string.IsNullOrEmpty(kv.Value.moveTarget) && string.IsNullOrEmpty(kv.Value.movePath)) continue;
//             // if (kv.Value.type != "MonoScript") continue;
//             // if (!kv.Value.path.Contains("Assets/Game/Activity") || !kv.Value.movePath.Contains("Assets/Game/CommonPrefab")) continue;
//             // if (!(kv.Value.moveList != null && kv.Value.moveList.Count == 1 && kv.Value.moveList[0] == "Activity")) continue;
//             // if (!(kv.Value.referencesAllCode != null && kv.Value.referencesAllCode.Count > 0)) continue;
//             // if (!(kv.Value.referencesAllAct != null && kv.Value.referencesAllAct.Count > 0)) continue;

//             // bool b = false;
//             // if (kv.Value.moveList != null && kv.Value.moveList.Count > 2){
//             //      if (kv.Value.moveList.Contains("Activity")){
//             //             b = true;
//             //     }
//             // }
//             // if (!b) continue;
//             // if (!(kv.Value.name == "me_bg_jd2")) continue;
//             // if(!kv.Value.path.Contains("Assets/Game/Activity")) continue;
//             i = i + 1;
//             string str = DebugToConsole(kv, i);
//             CheckFolder(kv.Value.moveParentFolder + "/" + kv.Value.moveFolder);
//             string _str = AssetDatabase.MoveAsset(kv.Value.path, kv.Value.movePath);
//             if (string.IsNullOrEmpty(_str))
//             {
//                 Debug.Log("移动资产结果成功：" + _str);
//             }
//             else
//             {
//                 Debug.Log("<color=red>移动资产结果失败>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>：</color>" + str);
//             }
//         }
//         AssetDatabase.Refresh();
//     }

//     private static void SetDependencies(string k, string key, string val)
//     {
//         if (mAsset[k].dependencies != null && mAsset[k].dependencies.Count > 0)
//         {
//             foreach (var guid in mAsset[k].dependencies)
//             {
//                 if (!mAsset.ContainsKey(guid))
//                 {
//                     continue;
//                 }
//                 if (mAsset[guid].dependencies != null && mAsset[guid].dependencies.Count > 0)
//                 {
//                     var v = mAsset[guid];
//                     SetDependencies(guid, key, guid);

//                     if (key != guid && !mAsset[key].dependenciesAll.Contains(guid))
//                     {
//                         mAsset[key].dependenciesAll.Add(guid);
//                     }
//                 }
//                 else
//                 {
//                     if (key != guid && !mAsset[key].dependenciesRoot.Contains(guid))
//                     {
//                         mAsset[key].dependenciesRoot.Add(guid);
//                     }

//                     if (key != guid && !mAsset[key].dependenciesAll.Contains(guid))
//                     {
//                         mAsset[key].dependenciesAll.Add(guid);
//                     }
//                 }
//             }
//         }
//         else
//         {
//             if (key != val && !mAsset[key].dependenciesRoot.Contains(val))
//             {
//                 mAsset[key].dependenciesRoot.Add(val);
//             }

//             if (key != val && !mAsset[key].dependenciesAll.Contains(val))
//             {
//                 mAsset[key].dependenciesAll.Add(val);
//             }
//         }
//     }

//     private static void SetReferences(string k, string key, string val)
//     {
//         if (mAsset[k].references != null && mAsset[k].references.Count > 0)
//         {
//             foreach (var guid in mAsset[k].references)
//             {
//                 if (!mAsset.ContainsKey(guid))
//                 {
//                     continue;
//                 }
//                 if (mAsset[guid].references != null && mAsset[guid].references.Count > 0)
//                 {
//                     var v = mAsset[guid];
//                     SetReferences(guid, key, guid);

//                     if (key != guid && !mAsset[key].referencesAll.Contains(guid))
//                     {
//                         mAsset[key].referencesAll.Add(guid);
//                     }
//                 }
//                 else
//                 {
//                     if (key != guid && !mAsset[key].referencesRoot.Contains(guid))
//                     {
//                         mAsset[key].referencesRoot.Add(guid);
//                     }

//                     if (key != guid && !mAsset[key].referencesAll.Contains(guid))
//                     {
//                         mAsset[key].referencesAll.Add(guid);
//                     }
//                 }
//             }
//         }
//         else
//         {
//             if (key != val && !mAsset[key].referencesRoot.Contains(val))
//             {
//                 mAsset[key].referencesRoot.Add(val);
//             }

//             if (key != val && !mAsset[key].referencesAll.Contains(val))
//             {
//                 mAsset[key].referencesAll.Add(val);
//             }
//         }
//     }

//     public class MAssetDescription : ReferenceFinderData.AssetDescription
//     {
//         public string name = "";
//         public string path = "";
//         public Hash128 assetDependencyHash;
//         public List<string> dependencies = new List<string>();
//         public List<string> references = new List<string>();
//         public ReferenceFinderData.AssetState state = ReferenceFinderData.AssetState.NORMAL;
//         public List<string> dependenciesRoot = new List<string>();
//         public List<string> referencesRoot = new List<string>();

//         public List<string> dependenciesAll = new List<string>();
//         public List<string> referencesAll = new List<string>();
//         public List<string> referencesAllCode = new List<string>();
//         public List<string> referencesAllAct = new List<string>();

//         public List<string> moveList = new List<string>();
//         public List<string> moveComList = new List<string>();

//         public string moveTarget = "";
//         public string movePath = "";
//         public string moveFolder = "";
//         public string moveParentFolder = "";
//         public string type = "";
//         public string nameSuffix = "";
//     }

//     public static void RemoveSpine()
//     {
//         foreach (var kv in mAsset)
//         {
//             bool is_spine = false;
//             if (!is_spine)
//             {
//                 if (kv.Value.type == "SkeletonDataAsset")
//                 {
//                     is_spine = true;
//                 }
//             }
//             if (!is_spine)
//                 foreach (var item in kv.Value.dependencies)
//                 {
//                     if (mAsset.ContainsKey(item) && mAsset[item].type == "SkeletonDataAsset")
//                     {
//                         is_spine = true;
//                     }
//                 }
//             if (!is_spine)
//                 foreach (var item in kv.Value.dependenciesAll)
//                 {
//                     if (mAsset.ContainsKey(item) && mAsset[item].type == "SkeletonDataAsset")
//                     {
//                         is_spine = true;
//                     }
//                 }
//             if (!is_spine)
//                 foreach (var item in kv.Value.references)
//                 {
//                     if (mAsset.ContainsKey(item) && mAsset[item].type == "SkeletonDataAsset")
//                     {
//                         is_spine = true;
//                     }
//                 }
//             if (!is_spine)
//                 foreach (var item in kv.Value.referencesAll)
//                 {
//                     if (mAsset.ContainsKey(item) && mAsset[item].type == "SkeletonDataAsset")
//                     {
//                         is_spine = true;
//                     }
//                 }
//             if (!is_spine)
//                 foreach (var item in kv.Value.referencesRoot)
//                 {
//                     if (mAsset.ContainsKey(item) && mAsset[item].type == "SkeletonDataAsset")
//                     {
//                         is_spine = true;
//                     }
//                 }
//             if (!is_spine)
//                 foreach (var item in kv.Value.dependenciesRoot)
//                 {
//                     if (mAsset.ContainsKey(item) && mAsset[item].type == "SkeletonDataAsset")
//                     {
//                         is_spine = true;
//                     }
//                 }
//             if (is_spine)
//             {
//                 mAsset[kv.Key].moveList.Clear();
//                 mAsset[kv.Key].moveTarget = "";
//                 mAsset[kv.Key].moveFolder = "";
//                 mAsset[kv.Key].moveParentFolder = "";
//                 mAsset[kv.Key].movePath = "";
//             }
//         }
//     }

//     public static void CollectSpine()
//     {
//         if (true) return;
//         foreach (var kv in mAsset)
//         {
//             if (kv.Value.type == "SkeletonDataAsset")
//             {
//                 mAsset[kv.Key].moveFolder += "/" + mAsset[kv.Key].name;
//                 mAsset[kv.Key].movePath = mAsset[kv.Key].moveParentFolder + "/" + mAsset[kv.Key].moveFolder + "/" + mAsset[kv.Key].nameSuffix;
//                 foreach (var item in kv.Value.dependenciesAll)
//                 {
//                     mAsset[item].moveParentFolder = mAsset[kv.Key].moveParentFolder;
//                     mAsset[item].moveFolder = mAsset[kv.Key].moveFolder;
//                     mAsset[item].movePath = mAsset[item].moveParentFolder + "/" + mAsset[item].moveFolder + "/" + mAsset[item].nameSuffix;
//                 }
//             }
//         }
//     }

//     public static void CollectFbx()
//     {
//         foreach (var kv in mAsset)
//         {
//             if (kv.Value.type == "Fbx")
//             {
//                 mAsset[kv.Key].moveParentFolder += "/" + mAsset[kv.Key].moveFolder;
//                 mAsset[kv.Key].moveFolder = mAsset[kv.Key].name;
//                 mAsset[kv.Key].movePath = mAsset[kv.Key].moveParentFolder + "/" + mAsset[kv.Key].moveFolder + "/" + mAsset[kv.Key].nameSuffix;
//                 foreach (var item in kv.Value.dependenciesAll)
//                 {
//                     mAsset[item].moveParentFolder = mAsset[kv.Key].moveParentFolder;
//                     mAsset[item].moveFolder = mAsset[kv.Key].moveFolder;
//                     mAsset[item].movePath = mAsset[item].moveParentFolder + "/" + mAsset[item].moveFolder + "/" + mAsset[item].nameSuffix;
//                 }
//             }
//         }
//     }

//     public static void CollectMaterialTexture2D()
//     {
//         foreach (var kv in mAsset)
//         {
//             if (kv.Value.type == "Material")
//             {
//                 foreach (var item in kv.Value.dependenciesAll)
//                 {
//                     if (mAsset[item].type == "Texture2D")
//                     {
//                         mAsset[item].moveFolder = mAsset[kv.Key].moveFolder + "Texture2D";
//                         mAsset[item].movePath = mAsset[item].moveParentFolder + "/" + mAsset[item].moveFolder + "/" + mAsset[item].nameSuffix;
//                     }
//                 }
//             }
//         }
//     }
//     public static void CollectTexture2DTpsheet()
//     {
//         foreach (var kv in mAsset)
//         {
//             if (kv.Value.type == "Tpsheet")
//             {
//                 foreach (var item in mAsset)
//                 {
//                     if (item.Value.name == kv.Value.name && item.Value.type != "Tpsheet")
//                     {
//                         mAsset[kv.Key].moveParentFolder = item.Value.moveParentFolder;
//                         mAsset[kv.Key].moveFolder = item.Value.moveFolder;
//                         mAsset[kv.Key].movePath = mAsset[kv.Key].moveParentFolder + "/" + mAsset[kv.Key].moveFolder + "/" + mAsset[kv.Key].nameSuffix;
//                     }
//                 }
//             }
//         }
//     }

//     public static void CollectFont()
//     {
//         foreach (var kv in mAsset)
//         {
//             if (kv.Value.type == "Font")
//             {
//                 mAsset[kv.Key].moveParentFolder += "/" + mAsset[kv.Key].moveFolder;
//                 mAsset[kv.Key].moveFolder = mAsset[kv.Key].name;
//                 mAsset[kv.Key].movePath = mAsset[kv.Key].moveParentFolder + "/" + mAsset[kv.Key].moveFolder + "/" + mAsset[kv.Key].nameSuffix;
//                 foreach (var item in kv.Value.dependenciesAll)
//                 {
//                     mAsset[item].moveParentFolder = mAsset[kv.Key].moveParentFolder;
//                     mAsset[item].moveFolder = mAsset[kv.Key].moveFolder;
//                     mAsset[item].movePath = mAsset[item].moveParentFolder + "/" + mAsset[item].moveFolder + "/" + mAsset[item].nameSuffix;
//                 }
//             }
//         }
//     }

//     private const string CACHE_PATH_JSON = "Assets/ReferenceFinderCacheSure.json";
//     public static List<string> sureAssetList = new List<string>();
//     [MenuItem("Window/资源整理/写入确认资源", false, 1004)]
//     public static void WriteSureRefreences()
//     {
//         SetCheckDir();
//         SetBaseAssetDir();
//         SetNormalAssetDir();
//         SetGameAssetDir();
//         ReferenceFinderWindow.RefreshData();
//         SetAsset(ReferenceFinderWindow.data.assetDict);
//         //设置引用关系
//         foreach (var kv in mAsset)
//         {
//             SetDependencies(kv.Key, kv.Key, kv.Key);
//             SetReferences(kv.Key, kv.Key, kv.Key);
//         }
//         //代码引用
//         SetCodeReferences();
//         SetActivityReferences();
//         foreach (var kv in mAsset)
//         {
//             SetMoveList(kv.Key, kv.Key);
//         }
//         SetMoveTarget();
//         MoveCorrect();
//         SetMovePath();
//         // MoveAsset();
//         foreach (var kv in mAsset)
//         {
//             if (kv.Value.moveFolder.Contains("_AnimationClip")
//             || kv.Value.moveFolder.Contains("_AnimatorController")
//             || kv.Value.moveFolder.Contains("_AudioClip")
//             || kv.Value.moveFolder.Contains("_Fbx")
//             || kv.Value.moveFolder.Contains("_Font")
//             || kv.Value.moveFolder.Contains("_Lua")
//             || kv.Value.moveFolder.Contains("_Material")
//             || kv.Value.moveFolder.Contains("_MaterialTexture2D")
//             || kv.Value.moveFolder.Contains("_Prefab")
//             || kv.Value.moveFolder.Contains("_Shader")
//             || kv.Value.moveFolder.Contains("_Spine")
//             || kv.Value.moveFolder.Contains("_Texture2D"))
//             {
//                 sureAssetList.Add(kv.Value.nameSuffix);
//             }
//         }
//         if (File.Exists(CACHE_PATH_JSON))
//             File.Delete(CACHE_PATH_JSON);
//         string json_str = JsonMapper.ToJson(sureAssetList);
//         FileStream fs = new FileStream(CACHE_PATH_JSON, FileMode.OpenOrCreate);
//         StreamWriter sw = new StreamWriter(fs);
//         if (sw != null)
//         {
//             sw.Write(json_str);
//         }
//         if (sw != null)
//         {
//             sw.Close();
//         }
//         if (fs != null)
//         {
//             fs.Close();
//         }
//     }

//     [Serializable]
//     public struct SerializeStruct
//     {
//         public List<string> serializedGuid;
//         public List<Hash128> serializedDependencyHash;
//         public List<int[]> serializedDenpendencies;
//     }

//     //读取缓存信息
//     // [MenuItem("Window/资源整理/读出确认资源", false, 1005)]
//     public static bool ReadSureRefreences()
//     {
//         if (File.Exists(CACHE_PATH_JSON))
//         {
//             FileStream fs = new FileStream(CACHE_PATH_JSON, FileMode.OpenOrCreate);
//             StreamReader sr = new StreamReader(fs);
//             string json_str = "";
//             if (sr != null)
//             {
//                 json_str = sr.ReadToEnd();
//             }
//             if (sr != null)
//             {
//                 sr.Close();
//             }
//             if (fs != null)
//             {
//                 fs.Close();
//             }
//             // StreamReader json = File.OpenText(CACHE_PATH_JSON);
//             // string json_str = json.ReadToEnd();
//             Debug.Log("json_str" + json_str);
//             sureAssetList.Clear();
//             sureAssetList = JsonMapper.ToObject<List<string>>(json_str);
//             Debug.Log("JsonData " + sureAssetList.Count);
//             return true;
//         }
//         return false;
//     }

//     private const string All_CACHE_PATH_JSON = "Assets/ReferenceFinderCacheAll.json";
//     [MenuItem("Window/资源整理/记录所有资源目录", false, 1005)]
//     public static void WriteAllAssetsDirectory()
//     {
//         if (File.Exists(All_CACHE_PATH_JSON))
//             File.Delete(All_CACHE_PATH_JSON);
//         var allAssets = AssetDatabase.GetAllAssetPaths();
//         List<string> allAssetsList = new List<string>();
//         foreach (var item in allAssets)
//         {
//             if (File.Exists(item))
//             {
//                 // 是文件
//                 allAssetsList.Add(item);
//                 // Debug.Log("文件");
//             }
//             else if (Directory.Exists(item))
//             {
//                 // 是文件夹
//                 // Debug.Log("文件夹");
//             }
//             else
//             {
//                 // 都不是
//                 // Debug.Log("都不是");
//             }
//         }
//         string json_str = JsonMapper.ToJson(allAssetsList.ToArray());
//         Debug.Log(json_str);
//         FileStream fs = new FileStream(All_CACHE_PATH_JSON, FileMode.OpenOrCreate);
//         StreamWriter sw = new StreamWriter(fs);
//         if (sw != null)
//         {
//             sw.Write(json_str);
//         }
//         if (sw != null)
//         {
//             sw.Close();
//         }
//         if (fs != null)
//         {
//             fs.Close();
//         }
//     }

//     //读取缓存信息
//     // [MenuItem("Window/资源整理/读出所有资源目录", false, 1005)]
//     public static string[] ReadAllAssetsDirectory()
//     {
//         if (File.Exists(All_CACHE_PATH_JSON))
//         {
//             FileStream fs = new FileStream(All_CACHE_PATH_JSON, FileMode.OpenOrCreate);
//             StreamReader sr = new StreamReader(fs);
//             string json_str = "";
//             if (sr != null)
//             {
//                 json_str = sr.ReadToEnd();
//             }
//             if (sr != null)
//             {
//                 sr.Close();
//             }
//             if (fs != null)
//             {
//                 fs.Close();
//             }
//             Debug.Log("json_str" + json_str);
//             sureAssetList.Clear();
//             var allAssets = JsonMapper.ToObject<string[]>(json_str);
//             Debug.Log("JsonData " + allAssets.Length);
//             return allAssets;
//         }
//         return null;
//     }

//     public struct act_struct
//     {
//         public string name;
//         public bool enable;
//     }
//     private const string ActivityConfigPath = "Assets/VersionConfig/ActivityConfig.json";
//     private const string ActConfigPath = "Assets/act_config.txt";
//     [MenuItem("Window/生成活动配置", false, 1005)]
//     public static void CreateActivityConfig()
//     {
//         Dictionary<string, Dictionary<string, string>> dic = new Dictionary<string, Dictionary<string, string>>();
//         string[] luatable = File.ReadAllLines("Assets/Game/CommonPrefab/Lua/game_module_config.lua"); ;
//         string id = "";
//         for (int i = 0; i < luatable.Length; i++)
//         {
//             // Debug.Log(luatable[i]);
//             string str = luatable[i];
//             if (str.Contains("			id = "))
//             {
//                 string[] sArray = str.Split(new string[] { "			id = ", "," }, StringSplitOptions.RemoveEmptyEntries);
//                 id = sArray[0];
//                 dic.Add(id, new Dictionary<string, string>());
//                 dic[id].Add("id", id);
//             }
//             if (str.Contains("			key = "))
//             {
//                 string[] sArray = str.Split(new string[] { "			key = \"", "\"," }, StringSplitOptions.RemoveEmptyEntries);
//                 dic[id].Add("key", sArray[0]);
//             }
//             if (str.Contains("			desc = "))
//             {
//                 string[] sArray = str.Split(new string[] { "			desc = \"", "\"," }, StringSplitOptions.RemoveEmptyEntries);
//                 dic[id].Add("desc", sArray[0]);
//             }
//             if (str.Contains("			lua = "))
//             {
//                 string[] sArray = str.Split(new string[] { "			lua = \"", "\"," }, StringSplitOptions.RemoveEmptyEntries);
//                 dic[id].Add("lua", sArray[0]);
//             }
//             if (str.Contains("			is_on_off = "))
//             {
//                 string[] sArray = str.Split(new string[] { "			is_on_off = ", "," }, StringSplitOptions.RemoveEmptyEntries);
//                 dic[id].Add("is_on_off", sArray[0]);
//             }
//             if (str.Contains("			enable = "))
//             {
//                 string[] sArray = str.Split(new string[] { "			enable = ", "," }, StringSplitOptions.RemoveEmptyEntries);
//                 dic[id].Add("enable", sArray[0]);
//             }
//             if (str.Contains("			state = "))
//             {
//                 string[] sArray = str.Split(new string[] { "			state = ", "," }, StringSplitOptions.RemoveEmptyEntries);
//                 dic[id].Add("state", sArray[0]);
//             }
//         }
//         //生成ActivityConfig
//         Dictionary<string, List<act_struct>> _dic = new Dictionary<string, List<act_struct>>();
//         _dic.Add("activities", new List<act_struct>());
//         foreach (var item in dic)
//         {
//             bool is_enable = item.Value["enable"] == "1" ? true : false;
//             act_struct act_st = new act_struct()
//             {
//                 name = "Activity/" + item.Value["key"],
//                 enable = is_enable,
//             };

//             _dic["activities"].Add(act_st);
//         }
//         string json_str = JsonMapper.ToJson(_dic);
//         Debug.Log(json_str);
//         if (!string.IsNullOrEmpty(json_str))
//         {
//             if (File.Exists(ActivityConfigPath))
//                 File.Delete(ActivityConfigPath);
//             FileStream fs = new FileStream(ActivityConfigPath, FileMode.OpenOrCreate);
//             StreamWriter sw = new StreamWriter(fs);
//             if (sw != null)
//             {
//                 sw.Write(json_str);
//             }
//             if (sw != null)
//             {
//                 sw.Close();
//             }
//             if (fs != null)
//             {
//                 fs.Close();
//             }
//         }
//         //生成act_config
//         string txt_str = "";
//         foreach (var item in dic)
//         {
//             txt_str += item.Value["key"] + "|" + item.Value["desc"] + "|" + item.Value["state"] + "\n";
//         }
//         Debug.Log(txt_str);
//         if (!string.IsNullOrEmpty(txt_str))
//         {
//             if (File.Exists(ActConfigPath))
//                 File.Delete(ActConfigPath);
//             FileStream fs = new FileStream(ActConfigPath, FileMode.OpenOrCreate);
//             StreamWriter sw = new StreamWriter(fs);
//             if (sw != null)
//             {
//                 sw.Write(txt_str);
//             }
//             if (sw != null)
//             {
//                 sw.Close();
//             }
//             if (fs != null)
//             {
//                 fs.Close();
//             }
//         }
//     }
// }
