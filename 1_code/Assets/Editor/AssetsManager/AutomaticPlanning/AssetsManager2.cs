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

// public class AssetsManager2 : EditorWindow
// {
//     public class AssetDescriptionInfo : ReferenceFinderData.AssetDescription
//     {
//         public string guid = "";
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

//         public string type = "";
//         public string nameSuffix = "";
//         public string suffix = "";
//         public string minLocation = "";
//         public string maxLocation = "";
//         public Location location = new Location();
//         public string location1 = "";
//         public string location2 = "";
//         public string location3 = "";
//         public string asset_library = "";
//         public string com_library = "";
//         public List<Location> moveLocationList = new List<Location>();
//         public List<Location> moveLocationAssetList = new List<Location>();
//         public List<Location> moveLocationCodeList = new List<Location>();
//         public List<Location> moveTargetList = new List<Location>();
//         public List<Location> moveTargetCodeList = new List<Location>();
//         public List<string> movePathList = new List<string>();
//     }

//     [Serializable]
//     public class AssetsManagerStruct
//     {
//         public Dictionary<string, List<string>> asset_library;
//         public List<string> com_library;
//         public List<string> normal_common;
//         public Dictionary<string, List<string>> game_scene;
//         public Dictionary<string, List<string>> depend;
//         public List<string> asstes_check;
//         public List<string> game_ignore;
//         public List<string> lua_ignore;
//         public Dictionary<string, List<string>> fix_asset;
//         public string vesion;
//         public Dictionary<string, bool> activity_config;
//         public Dictionary<string, bool> activity_folder;
//     }

//     public struct Location
//     {
//         public string location1;
//         public string location2;
//         public string location3;
//     }

//     private static string ReadAllText(string path)
//     {
//         FileStream fs = new FileStream(path, FileMode.OpenOrCreate);
//         StreamReader sr = new StreamReader(fs);
//         string str = "";
//         if (sr != null) str = sr.ReadToEnd();
//         if (sr != null) sr.Close();
//         if (fs != null) fs.Close();
//         return str;
//     }

//     private static bool WriteAllText(string path, string str)
//     {
//         if (string.IsNullOrEmpty(str) && string.IsNullOrEmpty(path)) return false;
//         if (File.Exists(path)) File.Delete(path);
//         FileStream fs = new FileStream(path, FileMode.OpenOrCreate);
//         StreamWriter sw = new StreamWriter(fs);
//         if (sw != null) sw.Write(str);
//         if (sw != null) sw.Close();
//         if (fs != null) fs.Close();
//         return true;
//     }

//     public static string DebugToConsole(AssetDescriptionInfo adi, string i)
//     {
//         string str = i + "> ";
//         str += "name:" + adi.name + "    ";
//         str += "path:" + adi.path + "    ";
//         str += "type:" + adi.type + "\n";
//         str += "location1:" + adi.location1 + "  ";
//         str += "location2:" + adi.location2 + "  ";
//         str += "location3:" + adi.location3 + "\n";
//         str += "asset_library: " + adi.asset_library + "  ";
//         str += "com_library: " + adi.com_library + "\n";
//         for (int k = 0; k < adi.references.Count; k++)
//         {
//             if (asset_guid.ContainsKey(adi.references[k]))
//                 str += "references:" + asset_guid[adi.references[k]].path + "\n";
//         }
//         for (int k = 0; k < adi.referencesAll.Count; k++)
//         {
//             if (asset_guid.ContainsKey(adi.referencesAll[k]))
//                 str += "referencesAll:" + asset_guid[adi.referencesAll[k]].path + "\n";
//         }
//         for (int k = 0; k < adi.referencesRoot.Count; k++)
//         {
//             if (asset_guid.ContainsKey(adi.referencesRoot[k]))
//                 str += "referencesRoot:" + asset_guid[adi.referencesRoot[k]].path + "\n";
//         }
//         for (int k = 0; k < adi.referencesAllCode.Count; k++)
//         {
//             if (asset_guid.ContainsKey(adi.referencesAllCode[k]))
//                 str += "referencesAllCode:" + asset_guid[adi.referencesAllCode[k]].path + "\n";
//         }
//         for (int k = 0; k < adi.dependencies.Count; k++)
//         {
//             if (asset_guid.ContainsKey(adi.dependencies[k]))
//                 str += "dependencies:" + asset_guid[adi.dependencies[k]].path + "\n";
//         }
//         for (int k = 0; k < adi.dependenciesAll.Count; k++)
//         {
//             if (asset_guid.ContainsKey(adi.dependenciesAll[k]))
//                 str += "dependenciesAll:" + asset_guid[adi.dependenciesAll[k]].path + "\n";
//         }
//         for (int k = 0; k < adi.dependenciesRoot.Count; k++)
//         {
//             if (asset_guid.ContainsKey(adi.dependenciesRoot[k]))
//                 str += "dependenciesRoot:" + asset_guid[adi.dependenciesRoot[k]].path + "\n";
//         }
//         for (int k = 0; k < adi.moveLocationList.Count; k++)
//         {
//             var item = adi.moveLocationList[k];
//             str += "moveLocationList: localtion1: " + item.location1 + "| localtion2: " + item.location2 + "| localtion3: " + item.location3 + "\n";
//         }
//         for (int k = 0; k < adi.moveLocationAssetList.Count; k++)
//         {
//             var item = adi.moveLocationAssetList[k];
//             str += "moveLocationAssetList: localtion1: " + item.location1 + "| localtion2: " + item.location2 + "| localtion3: " + item.location3 + "\n";
//         }
//         for (int k = 0; k < adi.moveLocationCodeList.Count; k++)
//         {
//             var item = adi.moveLocationCodeList[k];
//             str += "moveLocationCodeList: localtion1: " + item.location1 + "| localtion2: " + item.location2 + "| localtion3: " + item.location3 + "\n";
//         }
//         for (int k = 0; k < adi.moveTargetList.Count; k++)
//         {
//             var item = adi.moveTargetList[k];
//             str += "moveTargetList: localtion1: " + item.location1 + "| localtion2: " + item.location2 + "| localtion3: " + item.location3 + "\n";
//         }
//         for (int k = 0; k < adi.moveTargetCodeList.Count; k++)
//         {
//             var item = adi.moveTargetCodeList[k];
//             str += "moveTargetCodeList: localtion1: " + item.location1 + "| localtion2: " + item.location2 + "| localtion3: " + item.location3 + "\n";
//         }
//         for (int k = 0; k < adi.movePathList.Count; k++)
//         {
//             str += "movePathList: " + adi.movePathList[k] + "\n";
//         }
//         Debug.Log(str);
//         return str;
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

//     private static void SortLocation(List<Location> list){
//         list.Sort(delegate (Location x, Location y)
//         {
//             if (string.IsNullOrEmpty(x.location1) && string.IsNullOrEmpty(x.location1)) return 0;
//             else if (string.IsNullOrEmpty(x.location1)) return -1;
//             else if (string.IsNullOrEmpty(y.location1)) return 1;
//             else if(x.location1 == y.location1){
//                 if (string.IsNullOrEmpty(x.location2) && string.IsNullOrEmpty(x.location2)) return 0;
//                 else if (string.IsNullOrEmpty(x.location2)) return -1;
//                 else if (string.IsNullOrEmpty(y.location2)) return 1;
//                 else if(x.location2 == y.location2){
//                     if (string.IsNullOrEmpty(x.location3) && string.IsNullOrEmpty(x.location3)) return 0;
//                     else if (string.IsNullOrEmpty(x.location3)) return -1;
//                     else if (string.IsNullOrEmpty(y.location3)) return 1;
//                     else return x.location3.CompareTo(y.location3);
//                 }
//                 else return x.location2.CompareTo(y.location2);
//             }
//             else return x.location1.CompareTo(y.location1);
//         });
//         list.Reverse();//这里倒序，以game中为基础，activity中进行copy
//     }

//     public static void RemoveSpine()
//     {
//         int counter = 0;
//         int total = asset_guid.Count;
//         foreach (var item in asset_guid)
//         {
//             EditorUtility.DisplayProgressBar("Remove Spine", item.Value.path, ++counter / (float)total);
//             bool is_spine = false;
//             if (!is_spine)
//             {
//                 if (item.Value.type == "SkeletonDataAsset")
//                 {
//                     is_spine = true;
//                 }
//             }
//             if (!is_spine)
//                 foreach (var guid in item.Value.dependencies)
//                 {
//                     if (asset_guid.ContainsKey(guid) && asset_guid[guid].type == "SkeletonDataAsset")
//                     {
//                         is_spine = true;
//                     }
//                 }
//             if (!is_spine)
//                 foreach (var guid in item.Value.dependenciesAll)
//                 {
//                     if (asset_guid.ContainsKey(guid) && asset_guid[guid].type == "SkeletonDataAsset")
//                     {
//                         is_spine = true;
//                     }
//                 }
//             if (!is_spine)
//                 foreach (var guid in item.Value.references)
//                 {
//                     if (asset_guid.ContainsKey(guid) && asset_guid[guid].type == "SkeletonDataAsset")
//                     {
//                         is_spine = true;
//                     }
//                 }
//             if (!is_spine)
//                 foreach (var guid in item.Value.referencesAll)
//                 {
//                     if (asset_guid.ContainsKey(guid) && asset_guid[guid].type == "SkeletonDataAsset")
//                     {
//                         is_spine = true;
//                     }
//                 }
//             if (!is_spine)
//                 foreach (var guid in item.Value.referencesRoot)
//                 {
//                     if (asset_guid.ContainsKey(guid) && asset_guid[guid].type == "SkeletonDataAsset")
//                     {
//                         is_spine = true;
//                     }
//                 }
//             if (!is_spine)
//                 foreach (var guid in item.Value.dependenciesRoot)
//                 {
//                     if (asset_guid.ContainsKey(guid) && asset_guid[guid].type == "SkeletonDataAsset")
//                     {
//                         is_spine = true;
//                     }
//                 }
//             if (is_spine)
//             {
//                 asset_guid[item.Key].movePathList.Clear();
//             }
//         }
//         EditorUtility.ClearProgressBar();
//     }

//     public static void CollectFbx()
//     {
//         int counter = 0;
//         int total = asset_guid.Count;
//         foreach (var item in asset_guid)
//         {
//             EditorUtility.DisplayProgressBar("Collect Fbx", item.Value.path, ++counter / (float)total);
//             if (item.Value.type == "Fbx")
//             {
//                 foreach (var guid in item.Value.dependenciesAll)
//                 {
//                     if (!string.IsNullOrEmpty(asset_guid[guid].asset_library) || !string.IsNullOrEmpty(asset_guid[guid].com_library)) continue;
//                     if ((item.Value.type == "MonoScript") || (item.Value.type == "Lua") || (item.Value.type == "SceneAsset")) continue;
//                     List<string> _mpl = new List<string>();
//                     foreach (var path in item.Value.movePathList)
//                     {
//                         string str = path.Replace(item.Value.nameSuffix,asset_guid[guid].nameSuffix);
//                         str = str.Replace(item.Value.type,asset_guid[guid].type);
//                         _mpl.Add(str);
//                     }
//                     asset_guid[guid].movePathList = _mpl;
//                 }
//             }
//         }
//         EditorUtility.ClearProgressBar();
//     }

//     public static void CollectMaterial()
//     {
//         int counter = 0;
//         int total = asset_guid.Count;
//         foreach (var item in asset_guid)
//         {
//             EditorUtility.DisplayProgressBar("Collect Material", item.Value.path, ++counter / (float)total);
//             if (item.Value.type == "Material")
//             {
//                 foreach (var guid in item.Value.dependenciesAll)
//                 {
//                     if (!string.IsNullOrEmpty(asset_guid[guid].asset_library) || !string.IsNullOrEmpty(asset_guid[guid].com_library)) continue;
//                     if ((item.Value.type == "MonoScript") || (item.Value.type == "Lua") || (item.Value.type == "SceneAsset")) continue;
//                     List<string> _mpl = new List<string>();
//                     foreach (var path in asset_guid[item.Value.guid].movePathList)
//                     {
//                         string str = path.Replace(item.Value.nameSuffix,asset_guid[guid].nameSuffix);
//                         str = str.Replace(item.Value.type,asset_guid[guid].type);
//                         _mpl.Add(str);
//                     }
//                     asset_guid[guid].movePathList = _mpl;
//                 }
//             }
//         }
//         EditorUtility.ClearProgressBar();
//     }

//     public static void CollectTexture2DTpsheet()
//     {
//         int counter = 0;
//         int total = asset_guid.Count;
//         foreach (var item in asset_guid)
//         {
//             EditorUtility.DisplayProgressBar("Collect Texture2D Tpsheet", item.Value.path, ++counter / (float)total);
//             if (item.Value.type == "Tpsheet")
//             {
//                 foreach (var kv in asset_guid)
//                 {
//                     if (kv.Value.name == item.Value.name && kv.Value.type != "Tpsheet")
//                     {
//                         if (!string.IsNullOrEmpty(kv.Value.asset_library) || !string.IsNullOrEmpty(kv.Value.com_library)) continue;
//                         if ((kv.Value.type == "MonoScript") || (kv.Value.type == "Lua") || (kv.Value.type == "SceneAsset")) continue;
//                         List<string> _mpl = new List<string>();
//                         foreach (var path in kv.Value.movePathList)
//                         {
//                             string str = path.Replace(kv.Value.nameSuffix,item.Value.nameSuffix);
//                             // str = str.Replace(kv.Value.type,item.Value.type);
//                             _mpl.Add(str);
//                         }
//                         asset_guid[item.Key].movePathList = _mpl;
//                     }
//                 }
//             }
//         }
//         EditorUtility.ClearProgressBar();
//     }

//     public static void CollectFont()
//     {
//         int counter = 0;
//         int total = asset_guid.Count;
//         foreach (var item in asset_guid)
//         {
//             EditorUtility.DisplayProgressBar("Collect Font", item.Value.path, ++counter / (float)total);
//             if (item.Value.type == "Font")
//             {
//                 foreach (var guid in item.Value.dependenciesAll)
//                 {
//                     if (!string.IsNullOrEmpty(asset_guid[guid].asset_library) || !string.IsNullOrEmpty(asset_guid[guid].com_library))
//                     {
//                         continue;
//                     }
//                     List<string> _mpl = new List<string>();
//                     foreach (var path in asset_guid[item.Value.guid].movePathList)
//                     {
//                         string str = path.Replace(item.Value.nameSuffix,asset_guid[guid].nameSuffix);
//                         str = str.Replace(item.Value.type,asset_guid[guid].type);
//                         _mpl.Add(str);
//                     }
//                     asset_guid[guid].movePathList = _mpl;
//                 }
//             }
//         }
//         EditorUtility.ClearProgressBar();
//     }

//     public static void ParseAssetsManagerConfig()
//     {
//         string path_str = "Assets/Editor/AssetsManager/AssetsManagerConfig.json";
//         string json_str = ReadAllText(path_str);
//         if (json_str.Length <= 0) return;

//         JsonData jsonData = JsonMapper.ToObject(json_str);
//         asset_manager_struct = new AssetsManagerStruct();
//         foreach (KeyValuePair<String, JsonData> keyValue in jsonData)
//         {
//             // Debug.Log(keyValue.Key + ">>>>>>>>>>>>>>>>>>>>>>>>>");
//             Dictionary<string, List<string>> dic = new Dictionary<string, List<string>>();
//             List<string> list = new List<string>();
//             string str = "";
//             int _type = 0;
//             if (keyValue.Value.ToString() == "JsonData array")
//             {
//                 if (keyValue.Value[0].ToString() == "JsonData object")
//                 {
//                     _type = 1;
//                     // Dictionary<string, List<string>>();
//                     for (int i = 0; i < keyValue.Value.Count; i++)
//                     {
//                         foreach (KeyValuePair<String, JsonData> keyValue1 in keyValue.Value[i])
//                         {
//                             if (!dic.ContainsKey(keyValue1.Key))
//                             {
//                                 dic.Add(keyValue1.Key, new List<string>());
//                             }
//                             for (int j = 0; j < keyValue1.Value.Count; j++)
//                             {
//                                 dic[keyValue1.Key].Add(keyValue1.Value[j].ToString());
//                             }
//                         }
//                     }
//                 }
//                 else
//                 {
//                     _type = 2;
//                     // List<string>();
//                     foreach (var keyValue1 in keyValue.Value)
//                     {
//                         list.Add(keyValue1.ToString());
//                     }
//                 }
//             }
//             else
//             {
//                 _type = 3;
//                 //string
//                 str = keyValue.Value.ToString();
//             }

//             // if (_type == 1){
//             //     foreach (var item in dic)
//             //     {
//             //         Debug.Log("key : " + item.Key);
//             //         foreach (var item1 in item.Value)
//             //         {
//             //             Debug.Log("key : " + item.Key + "value :" + item1);
//             //         }
//             //     }
//             // }
//             // else if (_type == 2){
//             //     foreach (var item1 in list)
//             //     {
//             //         Debug.Log("value :" + item1);
//             //     }
//             // }
//             // else if(_type == 3){
//             //     Debug.Log("value :" + str);   
//             // }

//             if (keyValue.Key == "asset_library")
//             {
//                 asset_manager_struct.asset_library = dic;
//             }
//             else if (keyValue.Key == "com_library")
//             {
//                 asset_manager_struct.com_library = list;
//             }
//             else if (keyValue.Key == "normal_common")
//             {
//                 asset_manager_struct.normal_common = list;
//             }
//             else if (keyValue.Key == "game_scene"){
//                 asset_manager_struct.game_scene = dic;
//             }
//             else if (keyValue.Key == "depend")
//             {
//                 asset_manager_struct.depend = dic;
//             }
//             else if (keyValue.Key == "asstes_check")
//             {
//                 asset_manager_struct.asstes_check = list;
//             }
//             else if (keyValue.Key == "game_ignore")
//             {
//                 asset_manager_struct.game_ignore = list;
//             }
//             else if (keyValue.Key == "lua_ignore")
//             {
//                 asset_manager_struct.lua_ignore = list;
//             }
//             else if (keyValue.Key == "fix_asset")
//             {
//                 asset_manager_struct.fix_asset = dic;
//             }
//             else if (keyValue.Key == "vesion")
//             {
//                 asset_manager_struct.vesion = str;
//             }
//         }
//     }

//     private static void SetActivityConfigStruct()
//     {
//         CreateActivityConfig();
//         Dictionary<string, bool> activity_config = new Dictionary<string, bool>();
//         Dictionary<string, bool> activity_folder = new Dictionary<string, bool>();
//         string path = ActivityConfigPath;//以主版本活动为准
//         string json_str = File.ReadAllText(path);
//         JsonData jsonData = JsonMapper.ToObject(json_str);
//         JsonData activities = jsonData["activities"];
//         foreach (JsonData item in activities)
//         {
//             JsonData name = item["name"]; //通过字符串索引器可以取得键值对的值
//             JsonData enable = item["enable"];
//             string[] pathArr = name.ToString().Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries);
//             if (!activity_config.ContainsKey(pathArr[1]))
//             {
//                 activity_config.Add(pathArr[1], enable.ToString().ToLower() == "true");
//             }
//         }

//         string[] subFolders = AssetDatabase.GetSubFolders("Assets/Game/Activity");
//         foreach (var _path in subFolders)
//         {
//             string[] strArr = _path.Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries);
//             string str = strArr[3];
//             if (activity_config.ContainsKey(str))
//             {
//                 activity_folder.Add(str, activity_config[str]);
//             }
//             else
//             {
//                 activity_folder.Add(str, false);
//             }
//         }

//         asset_manager_struct.activity_config = activity_config;
//         asset_manager_struct.activity_folder = activity_folder;
//     }

//     public static Dictionary<string, AssetDescriptionInfo> asset_guid;//所有资源信息
//     //初始化资源描述信息
//     private static void InitAssetDescriptionInfo()
//     {
//         //刷新游戏中资源引用关系
//         ReferenceFinderWindow.RefreshData();
//         Dictionary<string, ReferenceFinderData.AssetDescription> assetDict = ReferenceFinderWindow.data.assetDict;
//         int counter = 0;
//         int total = assetDict.Count;
//         asset_guid = new Dictionary<string, AssetDescriptionInfo>();
//         foreach (var item in assetDict)
//         {
//             EditorUtility.DisplayProgressBar("Init Asset Description", item.Value.path, ++counter / (float)total);

//             string[] pathArr = item.Value.path.Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries);
//             if (asset_guid.ContainsKey(item.Key)) continue; //已经添加过的不需要再添加
//             if (!asset_manager_struct.asstes_check.Contains(pathArr[1])) continue; //Assets目录下不需要检查的直接忽略
//             if (pathArr[1] == "Game" && asset_manager_struct.game_ignore.Contains(pathArr[2])) continue; //game目录下需要忽略的直接忽略

//             AssetDescriptionInfo adi = new AssetDescriptionInfo();
//             adi.guid = item.Key;
//             adi.name = item.Value.name;
//             adi.path = item.Value.path;
//             adi.assetDependencyHash = item.Value.assetDependencyHash;
//             adi.state = item.Value.state;
//             adi.dependencies = item.Value.dependencies;
//             adi.references = item.Value.references;
//             adi.dependenciesRoot = new List<string>();
//             adi.referencesRoot = new List<string>();
//             adi.dependenciesAll = new List<string>();
//             adi.referencesAll = new List<string>();
//             adi.referencesAllCode = new List<string>();

//             adi.nameSuffix = pathArr[pathArr.Length - 1];
//             string[] nameArr = adi.nameSuffix.Split(new string[] { "." }, StringSplitOptions.RemoveEmptyEntries);
//             adi.suffix = nameArr[nameArr.Length - 1].Substring(0).ToLower();

//             // Debug.Log(item.Value.path);
//             string at = AssetDatabase.GetMainAssetTypeAtPath(item.Value.path).ToString();
//             string[] atArray = at.Split(new string[] { "." }, StringSplitOptions.RemoveEmptyEntries);
//             at = atArray[atArray.Length - 1];
//             if (at == "GameObject" || at == "DefaultAsset")
//             {
//                 //不能判定准确类型
//                 at = adi.suffix.Substring(0, 1).ToUpper() + adi.suffix.Substring(1);
//             }
//             adi.type = at;

//             //忽略特定类型的文件
//             if (adi.type == "MonoScript") continue;

//             adi.location1 = pathArr[1];
//             if (pathArr[1] == "Game")
//             {
//                 adi.location2 = pathArr[2];
//                 if (pathArr[2] == "Activity")
//                 {
//                     adi.location3 = pathArr[3];
//                 }
//             }
//             adi.location.location1 = adi.location1;
//             adi.location.location2 = adi.location2;
//             adi.location.location3 = adi.location3;
//             asset_guid.Add(item.Key, adi);
//         }
//         EditorUtility.ClearProgressBar();
//     }

//     //添加资源引用关系
//     private static void AddAssetReferences()
//     {
//         int counter = 0;
//         int total = asset_guid.Count;
//         foreach (var item in asset_guid)
//         {
//             EditorUtility.DisplayProgressBar("Add Asset References", item.Value.path, ++counter / (float)total);
//             SetDependencies(item.Key, item.Key, item.Key);
//             SetReferences(item.Key, item.Key, item.Key);
//         }
//         EditorUtility.ClearProgressBar();
//     }

//     private static void SetDependencies(string k, string key, string val)
//     {
//         if (asset_guid[k].dependencies != null && asset_guid[k].dependencies.Count > 0)
//         {
//             foreach (var guid in asset_guid[k].dependencies)
//             {
//                 if (!asset_guid.ContainsKey(guid))
//                 {
//                     continue;
//                 }
//                 if (asset_guid[guid].dependencies != null && asset_guid[guid].dependencies.Count > 0)
//                 {
//                     var v = asset_guid[guid];
//                     SetDependencies(guid, key, guid);

//                     if (key != guid && !asset_guid[key].dependenciesAll.Contains(guid))
//                     {
//                         asset_guid[key].dependenciesAll.Add(guid);
//                     }
//                 }
//                 else
//                 {
//                     if (key != guid && !asset_guid[key].dependenciesRoot.Contains(guid))
//                     {
//                         asset_guid[key].dependenciesRoot.Add(guid);
//                     }

//                     if (key != guid && !asset_guid[key].dependenciesAll.Contains(guid))
//                     {
//                         asset_guid[key].dependenciesAll.Add(guid);
//                     }
//                 }
//             }
//         }
//         else
//         {
//             if (key != val && !asset_guid[key].dependenciesRoot.Contains(val))
//             {
//                 asset_guid[key].dependenciesRoot.Add(val);
//             }

//             if (key != val && !asset_guid[key].dependenciesAll.Contains(val))
//             {
//                 asset_guid[key].dependenciesAll.Add(val);
//             }
//         }
//     }

//     private static void SetReferences(string k, string key, string val)
//     {
//         if (asset_guid[k].references != null && asset_guid[k].references.Count > 0)
//         {
//             foreach (var guid in asset_guid[k].references)
//             {
//                 if (!asset_guid.ContainsKey(guid))
//                 {
//                     continue;
//                 }
//                 if (asset_guid[guid].references != null && asset_guid[guid].references.Count > 0)
//                 {
//                     var v = asset_guid[guid];
//                     SetReferences(guid, key, guid);

//                     if (key != guid && !asset_guid[key].referencesAll.Contains(guid))
//                     {
//                         asset_guid[key].referencesAll.Add(guid);
//                     }
//                 }
//                 else
//                 {
//                     if (key != guid && !asset_guid[key].referencesRoot.Contains(guid))
//                     {
//                         asset_guid[key].referencesRoot.Add(guid);
//                     }

//                     if (key != guid && !asset_guid[key].referencesAll.Contains(guid))
//                     {
//                         asset_guid[key].referencesAll.Add(guid);
//                     }
//                 }
//             }
//         }
//         else
//         {
//             if (key != val && !asset_guid[key].referencesRoot.Contains(val))
//             {
//                 asset_guid[key].referencesRoot.Add(val);
//             }

//             if (key != val && !asset_guid[key].referencesAll.Contains(val))
//             {
//                 asset_guid[key].referencesAll.Add(val);
//             }
//         }
//     }

//     //添加代码引用
//     public static Dictionary<string, List<string>> asset_name2lua_guid;//一个资源被哪些代码所引用，相同名字的不同类型的资源都会添加引用
//     private static void AddLuaCodeReferences()
//     {
//         SetLuaCodeReferences();
//         int counter = 0;
//         int total = asset_guid.Count;
//         foreach (var item in asset_guid)
//         {
//             EditorUtility.DisplayProgressBar("Add Lua Code References", item.Value.path, ++counter / (float)total);
//             //只考虑对图片的引用
//             // if (item.Value.type != "Texture2D") continue;
//             //MonoScript，lua文件和场景文件不需要移动
//             // if ((item.Value.type == "MonoScript") || (item.Value.type == "Lua") || (item.Value.type == "SceneAsset")) continue;
//             if (asset_name2lua_guid.ContainsKey(item.Value.name))
//             {
//                 asset_guid[item.Key].referencesAllCode = asset_name2lua_guid[item.Value.name];
//             }
//         }
//         EditorUtility.ClearProgressBar();
//     }

//     private static void SetLuaCodeReferences()
//     {
//         int counter = 0;
//         int total = asset_guid.Count;
//         Dictionary<string, string> lua_code = new Dictionary<string, string>();
//         foreach (var item in asset_guid)
//         {
//             EditorUtility.DisplayProgressBar("Read Lua Code", item.Value.path, ++counter / (float)total);
//             if (!(item.Value.type == "Lua")) continue;
//             // if (!item.Value.name.Contains("_config")) continue;//只检查配置文件
//             string lua_str = File.ReadAllText(item.Value.path);
//             lua_code.Add(item.Key, lua_str);
//         }

//         counter = 0;
//         total = lua_code.Count;
//         asset_name2lua_guid = new Dictionary<string, List<string>>();
//         foreach (var lua_kv in lua_code)
//         {
//             EditorUtility.DisplayProgressBar("Set Lua Code References", asset_guid[lua_kv.Key].path, ++counter / (float)total);
//             // if (lua_kv.Key != "item_config") continue;
//             //匹配多个结果
//             string text = lua_kv.Value;
//             string pattern = "(?<=\").*?(?=\")";
//             if (Regex.IsMatch(text, pattern))
//             {
//                 MatchCollection mc = Regex.Matches(text, pattern);
//                 foreach (Match m in mc)
//                 {
//                     var name = m.Value;
//                     var guid = lua_kv.Key;
//                     //res就是匹配得到的结果//
//                     // index += 1;
//                     // Debug.Log(index + "  " + name);
//                     // str += name + "\n";
//                     if (!asset_name2lua_guid.ContainsKey(name))
//                     {
//                         asset_name2lua_guid.Add(name, new List<string>());
//                     }
//                     if (!asset_name2lua_guid[name].Contains(guid))
//                     {
//                         asset_name2lua_guid[name].Add(guid);
//                     }
//                 }
//             }
//             //匹配一个结果
//             // string text1 = lua_kv.Value;
//             // string pattern1 = "(?<=\")("+ "匹配字符" + ")(?=\")";
//             // if(Regex.IsMatch(text1,pattern1))
//             // {
//             //     var m = Regex.Match(text1,pattern1);
//             //     var res = m.Value;
//             //     //res就是匹配得到的结果//
//             //     index += 1;
//             //     Debug.Log(index + "  " + res);
//             //     str += res + "\n";
//             // }
//         }
//         EditorUtility.ClearProgressBar();
//     }

//     //添加资源库
//     private static void AddAssetLibrary()
//     {
//         int counter = 0;
//         int total = asset_guid.Count;
//         foreach (var item in asset_guid)
//         {
//             EditorUtility.DisplayProgressBar("Add Asset Library", item.Value.path, ++counter / (float)total);
//             if (asset_manager_struct.asset_library.ContainsKey(item.Value.type) && asset_manager_struct.asset_library[item.Value.type].Contains(item.Value.name))
//             {
//                 asset_guid[item.Key].asset_library = item.Value.name;
//             }
//         }
//         EditorUtility.ClearProgressBar();
//     }

//     //添加公用库
//     private static void AddComLibrary()
//     {
//         int counter = 0;
//         int total = asset_guid.Count;
//         foreach (var item in asset_guid)
//         {
//             EditorUtility.DisplayProgressBar("Add Com Library", item.Value.path, ++counter / (float)total);
//             if (asset_name2lua_guid.ContainsKey(item.Value.name))
//             {
//                 foreach (var guid in asset_name2lua_guid[item.Value.name])
//                 {
//                     if (asset_manager_struct.com_library.Contains(asset_guid[guid].name))
//                     {
//                         asset_guid[item.Key].com_library = asset_guid[guid].name;
//                         break;
//                     }
//                 }
//             }
//         }
//         EditorUtility.ClearProgressBar();
//     }

//     //添加MoveLocalList
//     private static void AddMoveLocationList()
//     {
//         int counter = 0;
//         int total = asset_guid.Count;
//         foreach (var item in asset_guid)
//         {
//             EditorUtility.DisplayProgressBar("Add Asset Move Location List", item.Value.path, ++counter / (float)total);
//             AddAssetMoveLocationList(item.Key, item.Key);
//         }
//         EditorUtility.ClearProgressBar();
//         AddCodeMoveLocationList();
//     }

//     private static void AddAssetMoveLocationList(string key, string cur_key)
//     {
//         var m_as = asset_guid[cur_key];
//         if (m_as.referencesRoot != null && m_as.referencesRoot.Count > 0)
//         {
//             //根引用
//             for (int i = 0; i < m_as.referencesRoot.Count; i++)
//             {
//                 Location location = new Location();
//                 string root_key = m_as.referencesRoot[i];
//                 location.location1 = asset_guid[root_key].location1;
//                 location.location2 = asset_guid[root_key].location2;
//                 location.location3 = asset_guid[root_key].location3;
//                 if (!asset_guid[key].moveLocationList.Contains(location))
//                 {
//                     asset_guid[key].moveLocationList.Add(location);
//                 }
//                 if (!asset_guid[key].moveLocationAssetList.Contains(location))
//                 {
//                     asset_guid[key].moveLocationAssetList.Add(location);
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
//                 AddAssetMoveLocationList(key, m_as.referencesAll[i]);
//             }
//         }
//         if (m_as.dependenciesAll != null && m_as.dependenciesAll.Count > 0)
//         {

//         }
//     }

//     private static void AddCodeMoveLocationList()
//     {
//         int counter = 0;
//         int total = asset_guid.Count;
//         foreach (var item in asset_guid)
//         {
//             EditorUtility.DisplayProgressBar("Add Code Move Location List", item.Value.path, ++counter / (float)total);
//             if (item.Value.referencesAllCode == null || item.Value.referencesAllCode.Count == 0) continue;
//             foreach (var guid in item.Value.referencesAllCode)
//             {
//                 if (asset_manager_struct.lua_ignore.Contains(asset_guid[guid].name)) continue;
//                 Location location = new Location();
//                 location.location1 = asset_guid[guid].location1;
//                 location.location2 = asset_guid[guid].location2;
//                 location.location3 = asset_guid[guid].location3;
//                 if (!asset_guid[item.Key].moveLocationList.Contains(location))
//                 {
//                     asset_guid[item.Key].moveLocationList.Add(location);
//                 }
//                 if (!asset_guid[item.Key].moveLocationCodeList.Contains(location))
//                 {
//                     asset_guid[item.Key].moveLocationCodeList.Add(location);
//                 }
//             }
//         }
//         EditorUtility.ClearProgressBar();
//     }

//     private static void CheckMoveLocation(){
//         int counter = 0;
//         int total = asset_guid.Count;
//         foreach (var item in asset_guid)
//         {
//             EditorUtility.DisplayProgressBar("Check Move Location", item.Value.path, ++counter / (float)total);
//             if (item.Value.referencesRoot.Count == 0) continue;
//             //referencesRoot 的movelocationlist已经变化，若有引用关系，则应当同步
//             List<Location> moveLocationAddList = new List<Location>();
//             List<Location> moveLocationCodeAddList = new List<Location>();
//             List<Location> moveLocationDelList = new List<Location>();
//             foreach (var guid in item.Value.referencesRoot)
//             {
//                 var r = asset_guid[guid];
//                 Location l = r.location;
//                 if (item.Value.moveLocationList.Contains(l) && !item.Value.moveLocationCodeList.Contains(l)){
//                     if (r.moveLocationList.Count > 0){
//                         // item.Value.moveLocationList.Remove(l);
//                         if (!moveLocationDelList.Contains(l))
//                             moveLocationDelList.Add(l);
//                     }
//                     foreach (var location in r.moveLocationList)
//                     {
//                         // if (!item.Value.moveLocationList.Contains(location))
//                         //     item.Value.moveLocationList.Add(location);
//                         if (!moveLocationAddList.Contains(location))
//                             moveLocationAddList.Add(location);
//                         if (!moveLocationCodeAddList.Contains(location))
//                             moveLocationCodeAddList.Add(location);
//                     }
//                 }
//             }

//             foreach (var location in moveLocationDelList)
//             {
//                 if (item.Value.moveLocationList.Contains(location))
//                     item.Value.moveLocationList.Remove(location);
//             }

//             foreach (var location in moveLocationAddList)
//             {
//                 if (!item.Value.moveLocationList.Contains(location))
//                     item.Value.moveLocationList.Add(location);
//             }

//             foreach (var location in moveLocationCodeAddList)
//             {
//                 if (!item.Value.moveLocationCodeList.Contains(location))
//                     item.Value.moveLocationCodeList.Add(location);
//             }


//             //处理完后，先排序
//             SortLocation(item.Value.moveLocationList);
//             int index = item.Value.moveLocationList.IndexOf(item.Value.location);
//             if (index > 0){
//                 item.Value.moveLocationList.RemoveAt(index);
//                 item.Value.moveLocationList.Insert(0,item.Value.location);
//             }

//             //处理完后，先排序
//             SortLocation(item.Value.moveLocationCodeList);
//             index = item.Value.moveLocationCodeList.IndexOf(item.Value.location);
//             if (index > 0){
//                 item.Value.moveLocationCodeList.RemoveAt(index);
//                 item.Value.moveLocationCodeList.Insert(0,item.Value.location);
//             }
//         }
//         EditorUtility.ClearProgressBar();
//     }

//     //添加MoveTargetList
//     private static void AddMoveTargetList()
//     {
//         int counter = 0;
//         int total = asset_guid.Count;
//         //library 收集
//         foreach (var item in asset_guid)
//         {
//             EditorUtility.DisplayProgressBar("Add Move Target List", item.Value.path, ++counter / (float)total);

//             List<Location> moveTargetList = new List<Location>();
//             //MonoScript，lua文件和场景文件不需要移动
//             if ((item.Value.type == "Lua") || (item.Value.type == "SceneAsset"))
//             {
//                 Location location = new Location();
//                 location.location1 = item.Value.location1;
//                 location.location2 = item.Value.location2;
//                 location.location3 = item.Value.location3;
//                 AddMoveTarget(moveTargetList, location);
//                 item.Value.moveTargetList = moveTargetList;
//                 continue;
//             }

//             //audio文件特殊处理不移动
//             if (item.Value.type == "AudioClip")
//             {
//                 Location location = new Location();
//                 location.location1 = item.Value.location1;
//                 location.location2 = item.Value.location2;
//                 location.location3 = item.Value.location3;
//                 AddMoveTarget(moveTargetList, location);
//                 item.Value.moveTargetList = moveTargetList;
//                 continue;
//             }
//             //asset_library中的文件
//             if (!string.IsNullOrEmpty(item.Value.asset_library))
//             {
//                 Location location = new Location();
//                 location.location1 = "Game";
//                 location.location2 = "CommonPrefab";
//                 AddMoveTarget(moveTargetList, location);
//                 item.Value.moveTargetList = moveTargetList;
//                 continue;
//             }
//             //com_library中的文件
//             if (!string.IsNullOrEmpty(item.Value.com_library))
//             {
//                 string com_library = item.Value.com_library;
//                 Location location = new Location();
//                 if (com_library == "item_config")
//                 {
//                     //道具
//                     location.location1 = "Game";
//                     location.location2 = "Activity";
//                     location.location3 = "sys_item_manager";
//                     item.Value.moveTargetList = moveTargetList;
//                 }
//                 else if (com_library == "audio_conifg")
//                 {
//                     //音频
//                     item.Value.moveTargetList = moveTargetList;
//                 }
//                 else if (com_library == "swjl_icon_asset_config")
//                 {
//                     //实物icon
//                     location.location1 = "Game";
//                     location.location2 = "Activity";
//                     location.location3 = "swjl_icon";
//                     item.Value.moveTargetList = moveTargetList;
//                 }
//                 else if (com_library == "share_link_config")
//                 {
//                     //分享图
//                     location.location1 = "Game";
//                     location.location2 = "Activity";
//                     location.location3 = "sys_fx";
//                     item.Value.moveTargetList = moveTargetList;
//                 }
//                 AddMoveTarget(moveTargetList, location);
//                 continue;
//             }

//             //普通文件，计算出准确目标位置
//             //多个文件夹往公用文件夹提取

//             //不需要移动
//             if (item.Value.moveLocationList.Count == 0)
//             {
//                 item.Value.moveTargetList = moveTargetList;
//                 continue;
//             }
//             //只要移动到一个地方
//             if (item.Value.moveLocationList.Count == 1)
//             {
//                 Location location = new Location();
//                 location.location1 = item.Value.moveLocationList[0].location1;
//                 location.location2 = item.Value.moveLocationList[0].location2;
//                 location.location3 = item.Value.moveLocationList[0].location3;
//                 AddMoveTarget(moveTargetList, location);
//                 item.Value.moveTargetList = moveTargetList;
//                 continue;
//             }
//             bool is_CommonPrefab = false;
//             Location common_ml = new Location();
//             foreach (var _location in item.Value.moveLocationList)
//             {
//                 if (_location.location1 == "Game" && _location.location2 == "CommonPrefab")
//                 {
//                     is_CommonPrefab = true;
//                     common_ml = _location;
//                     break;
//                 }
//             }
//             //要移动到 CommonPrefab
//             if (is_CommonPrefab)
//             {
//                 Location location = new Location();
//                 location.location1 = "Game";
//                 location.location2 = "CommonPrefab";
//                 AddMoveTarget(moveTargetList, location);
//                 item.Value.moveTargetList = moveTargetList;
//                 continue;
//             }
//             bool is_game_scene = false;
//             foreach (var _location in item.Value.moveLocationList)
//             {
//                 if (_location.location1 == "Game" && asset_manager_struct.game_scene.ContainsKey(_location.location2))
//                 {
//                     is_game_scene = true;
//                     break;
//                 }
//             }
//             //没有要移动到游戏中的情况
//             if (!is_game_scene)
//             {
//                 foreach (var _location in item.Value.moveLocationList)
//                 {
//                     Location location = new Location();
//                     location.location1 = _location.location1;
//                     location.location2 = _location.location2;
//                     location.location3 = _location.location3;
//                     AddMoveTarget(moveTargetList, location);
//                 }
//                 item.Value.moveTargetList = moveTargetList;
//                 continue;
//             }

//             //要移动到游戏中的情况
//             Dictionary<string, int> gs_dic = new Dictionary<string, int>();
//             foreach (var _location in item.Value.moveLocationList)
//             {
//                 if (_location.location1 == "Game" && asset_manager_struct.game_scene.ContainsKey(_location.location2))
//                 {
//                     if (!gs_dic.ContainsKey(_location.location2)) gs_dic.Add(_location.location2, 0);
//                     gs_dic[_location.location2] += 1;
//                 }
//                 else if (_location.location1 == "Game" && asset_manager_struct.normal_common.Contains(_location.location2))
//                 {
//                     if (!gs_dic.ContainsKey(_location.location2)) gs_dic.Add(_location.location2, 0);
//                     gs_dic[_location.location2] += 1;
//                 }
//             }
//             //只要移动到一个游戏中的情况
//             if (gs_dic.Count == 1)
//             {
//                 foreach (var _location in item.Value.moveLocationList)
//                 {
//                     Location location = new Location();
//                     location.location1 = _location.location1;
//                     location.location2 = _location.location2;
//                     location.location3 = _location.location3;
//                     AddMoveTarget(moveTargetList, location);
//                 }
//                 item.Value.moveTargetList = moveTargetList;
//                 continue;
//             }

//             Dictionary<string, int> nc_dic = new Dictionary<string, int>();
//             List<string> gs_list = new List<string>();
//             foreach (var _location in item.Value.moveLocationList)
//             {
//                 if (_location.location1 == "Game" && asset_manager_struct.game_scene.ContainsKey(_location.location2) && asset_manager_struct.game_scene[_location.location2].Count > 0)
//                 {
//                     //尝试移动到normal中
//                     if (gs_list.Contains(_location.location2)) continue;
//                     gs_list.Add(_location.location2);
//                     string nc = asset_manager_struct.game_scene[_location.location2][0];
//                     if (!nc_dic.ContainsKey(nc)) nc_dic.Add(nc, 0);
//                     nc_dic[nc] += 1;
//                 }
//             }

//             bool is_normal_common = false;
//             foreach (var nc_c in nc_dic)
//             {
//                 if (nc_c.Value > 0)
//                 {
//                     is_normal_common = true;
//                     break;
//                 }
//             }
//             //不需要移动到normal_common中
//             if (!is_normal_common)
//             {
//                 foreach (var _location in item.Value.moveLocationList)
//                 {
//                     Location location = new Location();
//                     location.location1 = _location.location1;
//                     location.location2 = _location.location2;
//                     location.location3 = _location.location3;
//                     AddMoveTarget(moveTargetList, location);
//                 }
//                 item.Value.moveTargetList = moveTargetList;
//                 continue;
//             }
//             //要移动到normal_common中
//             foreach (var _location in item.Value.moveLocationList)
//             {
//                 if (_location.location1 != "Game" || !asset_manager_struct.game_scene.ContainsKey(_location.location2) || asset_manager_struct.game_scene[_location.location2].Count == 0)
//                 {
//                     //先添加非游戏location
//                     Location location = new Location();
//                     location.location1 = _location.location1;
//                     location.location2 = _location.location2;
//                     location.location3 = _location.location3;
//                     AddMoveTarget(moveTargetList, location);
//                 }
//                 else
//                 {
//                     string game = _location.location2;
//                     string normal = asset_manager_struct.game_scene[game][0];
//                     if (nc_dic.ContainsKey(normal) && nc_dic[normal] > 1)
//                     {
//                         //移动到对应的normal_common中
//                         Location location = new Location();
//                         location.location1 = _location.location1;
//                         location.location2 = normal;
//                         location.location3 = _location.location3;
//                         AddMoveTarget(moveTargetList, location);
//                     }
//                     else
//                     {
//                         Location location = new Location();
//                         location.location1 = _location.location1;
//                         location.location2 = _location.location2;
//                         location.location3 = _location.location3;
//                         AddMoveTarget(moveTargetList, location);
//                     }
//                 }
//             }
//             item.Value.moveTargetList = moveTargetList;
//         }
//         EditorUtility.ClearProgressBar();
//     }

//     private static void AddMoveTarget(List<Location> moveTargetList, Location location)
//     {
//         //原本是 normal_common 要添加 game
//         if (asset_manager_struct.game_scene.ContainsKey(location.location2))
//         {
//             foreach (var item in moveTargetList)
//             {
//                 if (asset_manager_struct.game_scene[location.location2].Contains(item.location2)) return;
//             }
//         }

//         //原本是 game 要添加 normal_common
//         for (int i = 0; i < moveTargetList.Count; i++)
//         {
//             var item = moveTargetList[i];
//             if (asset_manager_struct.game_scene.ContainsKey(item.location2) && asset_manager_struct.game_scene[item.location2].Contains(location.location2))
//             {
//                 moveTargetList[i] = location;
//                 return;
//             }
//         }

//         if (!moveTargetList.Contains(location)) moveTargetList.Add(location);
//     }

//     private static void CheckMoveTargetDepend(){
//         int counter = 0;
//         int total = asset_guid.Count;
//         //library 收集
//         foreach (var item in asset_guid)
//         {
//             EditorUtility.DisplayProgressBar("Check Move Target Depend", item.Value.path, ++counter / (float)total);
//             if (item.Value.moveTargetList == null || item.Value.moveTargetList.Count == 0) continue;
//             if (item.Value.moveTargetList.Count == 1){
//                 var tl = item.Value.moveTargetList[0];
//                 if (tl.location1 == item.Value.location1 && tl.location2 == item.Value.location2 && tl.location3 == item.Value.location3) 
//                     continue;
//             }
//             Location ol = item.Value.location;

//             List<int> del_list = new List<int>();
//             List<Location> add_list = new List<Location>();
//             for (int i = 0; i < item.Value.moveTargetList.Count; i++)
//             {
//                 var tl = item.Value.moveTargetList[i];
//                 string tg = tl.location2;
//                 if (tl.location2 == "Activity") tg = tl.location3;
//                 if (!asset_manager_struct.depend.ContainsKey(tg)) continue;
//                 List<string> tg_dep_list = asset_manager_struct.depend[tg];
//                 foreach (var tg_dep in tg_dep_list)
//                 {
//                     if (asset_manager_struct.activity_config.ContainsKey(tg_dep)){
//                         //是活动
//                         if (ol.location3 == tg_dep){
//                             //自己在依赖的地方，是依赖关系，不用移动
//                             if (!del_list.Contains(i)) del_list.Add(i);
//                             if (!add_list.Contains(ol)) add_list.Add(ol);
//                             break;
//                         }
//                         else{
//                             //之前movelocation已经被替换了，所以这里要检查根引用
//                             if (item.Value.referencesRoot.Count > 0){
//                                 foreach (var rr_guid in item.Value.referencesRoot)
//                                 {
//                                     var rr = asset_guid[rr_guid];
//                                     if (rr.location3 == tg_dep){
//                                         //自己在依赖的地方，是依赖关系，不用移动
//                                         if (!del_list.Contains(i)) del_list.Add(i);
//                                         if (!add_list.Contains(ol)) add_list.Add(ol);
//                                         break;
//                                     }
//                                 }
//                             }


//                             //自己不在依赖的地方，但是要移动到依赖和目标位置，这个时候只需要移动到依赖位置即可
//                             for (int j = 0; j < item.Value.moveTargetList.Count; j++)
//                             {
//                                 var _tl = item.Value.moveTargetList[j];
//                                 string _tg = _tl.location2;
//                                 if (_tl.location2 == "Activity") _tg = _tl.location3;
//                                 if (_tg == tg_dep){
//                                     if (!del_list.Contains(i)) del_list.Add(i);
//                                     break;
//                                 }
//                             }
//                         }
//                     }
//                     else{
//                         //是游戏
//                         if (ol.location2 == tg_dep){
//                             if (!del_list.Contains(i)) del_list.Add(i);
//                             if (!add_list.Contains(ol)) add_list.Add(ol);
//                             break;
//                         }
//                         else{
//                             //之前movelocation已经被替换了，所以这里要检查根引用
//                             if (item.Value.referencesRoot.Count > 0){
//                                 foreach (var rr_guid in item.Value.referencesRoot)
//                                 {
//                                     var rr = asset_guid[rr_guid];
//                                     if (rr.location2 == tg_dep){
//                                         //自己在依赖的地方，是依赖关系，不用移动
//                                         if (!del_list.Contains(i)) del_list.Add(i);
//                                         if (!add_list.Contains(rr.location)) add_list.Add(rr.location);
//                                         break;
//                                     }
//                                 }
//                             }

//                             //自己不在依赖的地方，但是要移动到依赖和目标位置，这个时候只需要移动到依赖位置即可
//                             for (int j = 0; j < item.Value.moveTargetList.Count; j++)
//                             {
//                                 var _tl = item.Value.moveTargetList[j];
//                                 string _tg = _tl.location2;
//                                 if (_tl.location2 == "Activity") _tg = _tl.location3;
//                                 if (_tg == tg_dep){
//                                     if (!del_list.Contains(i)) del_list.Add(i);
//                                     break;
//                                 }
//                             }

//                             if (asset_manager_struct.game_scene.ContainsKey(tg_dep)){
//                                 bool b = false;
//                                 foreach (var normal in asset_manager_struct.game_scene[tg_dep])
//                                 {
//                                     if (ol.location2 == normal){
//                                         if (!del_list.Contains(i)) del_list.Add(i);
//                                         if (!add_list.Contains(ol)) add_list.Add(ol);
//                                         b = true;
//                                         break;      
//                                     }

//                                     //之前movelocation已经被替换了，所以这里要检查根引用
//                                     if (item.Value.referencesRoot.Count > 0){
//                                         foreach (var rr_guid in item.Value.referencesRoot)
//                                         {
//                                             var rr = asset_guid[rr_guid];
//                                             if (rr.location2 == normal){
//                                                 //自己在依赖的地方，是依赖关系，不用移动
//                                                 if (!del_list.Contains(i)) del_list.Add(i);
//                                                 if (!add_list.Contains(rr.location)) add_list.Add(rr.location);
//                                                 b = true;
//                                                 break;
//                                             }
//                                         }
//                                     }

//                                     //自己不在依赖的地方，但是要移动到依赖和目标位置，这个时候只需要移动到依赖位置即可
//                                     for (int j = 0; j < item.Value.moveTargetList.Count; j++)
//                                     {
//                                         var _tl = item.Value.moveTargetList[j];
//                                         string _tg = _tl.location2;
//                                         if (_tl.location2 == "Activity") _tg = _tl.location3;
//                                         if (_tg == normal){
//                                             if (!del_list.Contains(i)) del_list.Add(i);
//                                             b = true;
//                                             break;
//                                         }
//                                     }
//                                 }
//                                 if (b) break;
//                             }
//                         }
//                     }
//                 }
//             }
        
//             for (int i = item.Value.moveTargetList.Count - 1; i >= 0 ; i--)
//             {
//                 if (del_list.Contains(i)) item.Value.moveTargetList.Remove(item.Value.moveTargetList[i]);
//             }

//             foreach (var l in add_list)
//             {
//                 if (!item.Value.moveTargetList.Contains(l)) item.Value.moveTargetList.Add(l);
//             }

//             //处理完后，先排序
//             SortLocation(item.Value.moveTargetList);
//             int index = item.Value.moveTargetList.IndexOf(item.Value.location);
//             if (index > 0){
//                 item.Value.moveTargetList.RemoveAt(index);
//                 item.Value.moveTargetList.Insert(0,item.Value.location);
//             }
//         }
//         EditorUtility.ClearProgressBar();
//     }

//     private static void CheckMoveTargetList()
//     {
//         int counter = 0;
//         int total = asset_guid.Count;
//         //library 收集
//         foreach (var item in asset_guid)
//         {
//             EditorUtility.DisplayProgressBar("Add Move Target List", item.Value.path, ++counter / (float)total);

//             List<Location> moveTargetList = new List<Location>();
//             //MonoScript，lua文件和场景文件不需要移动
//             if ((item.Value.type == "Lua") || (item.Value.type == "SceneAsset"))
//             {
//                 Location location = new Location();
//                 location.location1 = item.Value.location1;
//                 location.location2 = item.Value.location2;
//                 location.location3 = item.Value.location3;
//                 AddMoveTarget(moveTargetList, location);
//                 item.Value.moveTargetList = moveTargetList;
//                 continue;
//             }

//             //audio文件特殊处理不移动
//             if (item.Value.type == "AudioClip")
//             {
//                 Location location = new Location();
//                 location.location1 = item.Value.location1;
//                 location.location2 = item.Value.location2;
//                 location.location3 = item.Value.location3;
//                 AddMoveTarget(moveTargetList, location);
//                 item.Value.moveTargetList = moveTargetList;
//                 continue;
//             }
//             //asset_library中的文件
//             if (!string.IsNullOrEmpty(item.Value.asset_library))
//             {
//                 Location location = new Location();
//                 location.location1 = "Game";
//                 location.location2 = "CommonPrefab";
//                 AddMoveTarget(moveTargetList, location);
//                 item.Value.moveTargetList = moveTargetList;
//                 continue;
//             }
//             //com_library中的文件
//             if (!string.IsNullOrEmpty(item.Value.com_library))
//             {
//                 string com_library = item.Value.com_library;
//                 Location location = new Location();
//                 if (com_library == "item_config")
//                 {
//                     //道具
//                     location.location1 = "Game";
//                     location.location2 = "Activity";
//                     location.location3 = "sys_item_manager";
//                     item.Value.moveTargetList = moveTargetList;
//                 }
//                 else if (com_library == "audio_conifg")
//                 {
//                     //音频
//                     item.Value.moveTargetList = moveTargetList;
//                 }
//                 else if (com_library == "swjl_icon_asset_config")
//                 {
//                     //实物icon
//                     location.location1 = "Game";
//                     location.location2 = "Activity";
//                     location.location3 = "swjl_icon";
//                     item.Value.moveTargetList = moveTargetList;
//                 }
//                 else if (com_library == "share_link_config")
//                 {
//                     //分享图
//                     location.location1 = "Game";
//                     location.location2 = "Activity";
//                     location.location3 = "sys_fx";
//                     item.Value.moveTargetList = moveTargetList;
//                 }
//                 AddMoveTarget(moveTargetList, location);
//                 continue;
//             }

//             //普通文件，计算出准确目标位置
//             //多个文件夹往公用文件夹提取

//             //不需要移动
//             if (item.Value.moveTargetList.Count == 0)
//             {
//                 item.Value.moveTargetList = moveTargetList;
//                 continue;
//             }
//             //只要移动到一个地方
//             if (item.Value.moveTargetList.Count == 1)
//             {
//                 Location location = new Location();
//                 location.location1 = item.Value.moveTargetList[0].location1;
//                 location.location2 = item.Value.moveTargetList[0].location2;
//                 location.location3 = item.Value.moveTargetList[0].location3;
//                 AddMoveTarget(moveTargetList, location);
//                 item.Value.moveTargetList = moveTargetList;
//                 continue;
//             }
//             bool is_CommonPrefab = false;
//             Location common_ml = new Location();
//             foreach (var _location in item.Value.moveTargetList)
//             {
//                 if (_location.location1 == "Game" && _location.location2 == "CommonPrefab")
//                 {
//                     is_CommonPrefab = true;
//                     common_ml = _location;
//                     break;
//                 }
//             }
//             //要移动到 CommonPrefab
//             if (is_CommonPrefab)
//             {
//                 Location location = new Location();
//                 location.location1 = "Game";
//                 location.location2 = "CommonPrefab";
//                 AddMoveTarget(moveTargetList, location);
//                 item.Value.moveTargetList = moveTargetList;
//                 continue;
//             }
//             bool is_game_scene = false;
//             foreach (var _location in item.Value.moveTargetList)
//             {
//                 if (_location.location1 == "Game" && asset_manager_struct.game_scene.ContainsKey(_location.location2))
//                 {
//                     is_game_scene = true;
//                     break;
//                 }
//             }
//             //没有要移动到游戏中的情况
//             if (!is_game_scene)
//             {
//                 foreach (var _location in item.Value.moveTargetList)
//                 {
//                     Location location = new Location();
//                     location.location1 = _location.location1;
//                     location.location2 = _location.location2;
//                     location.location3 = _location.location3;
//                     AddMoveTarget(moveTargetList, location);
//                 }
//                 item.Value.moveTargetList = moveTargetList;
//                 continue;
//             }

//             //要移动到游戏中的情况
//             Dictionary<string, int> gs_dic = new Dictionary<string, int>();
//             foreach (var _location in item.Value.moveTargetList)
//             {
//                 if (_location.location1 == "Game" && asset_manager_struct.game_scene.ContainsKey(_location.location2))
//                 {
//                     if (!gs_dic.ContainsKey(_location.location2)) gs_dic.Add(_location.location2, 0);
//                     gs_dic[_location.location2] += 1;
//                 }
//                 else if (_location.location1 == "Game" && asset_manager_struct.normal_common.Contains(_location.location2))
//                 {
//                     if (!gs_dic.ContainsKey(_location.location2)) gs_dic.Add(_location.location2, 0);
//                     gs_dic[_location.location2] += 1;
//                 }
//             }
//             //只要移动到一个游戏中的情况
//             if (gs_dic.Count == 1)
//             {
//                 foreach (var _location in item.Value.moveTargetList)
//                 {
//                     Location location = new Location();
//                     location.location1 = _location.location1;
//                     location.location2 = _location.location2;
//                     location.location3 = _location.location3;
//                     AddMoveTarget(moveTargetList, location);
//                 }
//                 item.Value.moveTargetList = moveTargetList;
//                 continue;
//             }

//             Dictionary<string, int> nc_dic = new Dictionary<string, int>();
//             List<string> gs_list = new List<string>();
//             foreach (var _location in item.Value.moveTargetList)
//             {
//                 if (_location.location1 == "Game" && asset_manager_struct.game_scene.ContainsKey(_location.location2) && asset_manager_struct.game_scene[_location.location2].Count > 0)
//                 {
//                     //尝试移动到normal中
//                     if (gs_list.Contains(_location.location2)) continue;
//                     gs_list.Add(_location.location2);
//                     string nc = asset_manager_struct.game_scene[_location.location2][0];
//                     if (!nc_dic.ContainsKey(nc)) nc_dic.Add(nc, 0);
//                     nc_dic[nc] += 1;
//                 }
//             }

//             bool is_normal_common = false;
//             foreach (var nc_c in nc_dic)
//             {
//                 if (nc_c.Value > 0)
//                 {
//                     is_normal_common = true;
//                     break;
//                 }
//             }
//             //不需要移动到normal_common中
//             if (!is_normal_common)
//             {
//                 foreach (var _location in item.Value.moveTargetList)
//                 {
//                     Location location = new Location();
//                     location.location1 = _location.location1;
//                     location.location2 = _location.location2;
//                     location.location3 = _location.location3;
//                     AddMoveTarget(moveTargetList, location);
//                 }
//                 item.Value.moveTargetList = moveTargetList;
//                 continue;
//             }
//             //要移动到normal_common中
//             foreach (var _location in item.Value.moveTargetList)
//             {
//                 if (_location.location1 != "Game" || !asset_manager_struct.game_scene.ContainsKey(_location.location2) || asset_manager_struct.game_scene[_location.location2].Count == 0)
//                 {
//                     //先添加非游戏location
//                     Location location = new Location();
//                     location.location1 = _location.location1;
//                     location.location2 = _location.location2;
//                     location.location3 = _location.location3;
//                     AddMoveTarget(moveTargetList, location);
//                 }
//                 else
//                 {
//                     string game = _location.location2;
//                     string normal = asset_manager_struct.game_scene[game][0];
//                     if (nc_dic.ContainsKey(normal) && nc_dic[normal] > 1)
//                     {
//                         //移动到对应的normal_common中
//                         Location location = new Location();
//                         location.location1 = _location.location1;
//                         location.location2 = normal;
//                         location.location3 = _location.location3;
//                         AddMoveTarget(moveTargetList, location);
//                     }
//                     else
//                     {
//                         Location location = new Location();
//                         location.location1 = _location.location1;
//                         location.location2 = _location.location2;
//                         location.location3 = _location.location3;
//                         AddMoveTarget(moveTargetList, location);
//                     }
//                 }
//             }
//             item.Value.moveTargetList = moveTargetList;
//         }
//         EditorUtility.ClearProgressBar();
//     }

//     private static void AddMoveTargetCodeList(){
//         int counter = 0;
//         int total = asset_guid.Count;
//         foreach (var item in asset_guid)
//         {
//             EditorUtility.DisplayProgressBar("Add Move Target Code List", item.Value.path, ++counter / (float)total);

//             if (item.Value.moveLocationCodeList.Count == 0) continue;
//             List<Location> rac_list = new List<Location>();
//             foreach (var location in item.Value.moveLocationCodeList)
//             {
//                 if (!rac_list.Contains(location)) rac_list.Add(location);
//             }   
//             item.Value.moveTargetCodeList = rac_list;

//             //处理完后，先排序
//             SortLocation(item.Value.moveTargetCodeList);
//             int index = item.Value.moveTargetCodeList.IndexOf(item.Value.location);
//             if (index > 0){
//                 item.Value.moveTargetCodeList.RemoveAt(index);
//                 item.Value.moveTargetCodeList.Insert(0,item.Value.location);
//             }
//         }
//         EditorUtility.ClearProgressBar();
//     }

//     private static void CheckMoveTargetCodeDepend(){
//         int counter = 0;
//         int total = asset_guid.Count;
//         //library 收集
//         foreach (var item in asset_guid)
//         {
//             EditorUtility.DisplayProgressBar("Check Move Target Code Depend", item.Value.path, ++counter / (float)total);
//             if (item.Value.moveTargetCodeList == null || item.Value.moveTargetCodeList.Count == 0) continue;
//             if (item.Value.moveTargetCodeList.Count == 1){
//                 var tl = item.Value.moveTargetCodeList[0];
//                 if (tl.location1 == item.Value.location1 && tl.location2 == item.Value.location2 && tl.location3 == item.Value.location3) 
//                     continue;
//             }
//             Location ol = item.Value.location;

//             List<int> del_list = new List<int>();
//             List<Location> add_list = new List<Location>();
//             for (int i = 0; i < item.Value.moveTargetCodeList.Count; i++)
//             {
//                 var tl = item.Value.moveTargetCodeList[i];
//                 string tg = tl.location2;
//                 if (tl.location2 == "Activity") tg = tl.location3;
//                 if (!asset_manager_struct.depend.ContainsKey(tg)) continue;
//                 List<string> tg_dep_list = asset_manager_struct.depend[tg];
//                 foreach (var tg_dep in tg_dep_list)
//                 {
//                     if (asset_manager_struct.activity_config.ContainsKey(tg_dep)){
//                         //是活动
//                         if (ol.location3 == tg_dep){
//                             //自己在依赖的地方，是依赖关系，不用移动
//                             if (!del_list.Contains(i)) del_list.Add(i);
//                             if (!add_list.Contains(ol)) add_list.Add(ol);
//                             break;
//                         }
//                         else{
//                             //自己不在依赖的地方，但是要移动到依赖和目标位置，这个时候只需要移动到依赖位置即可
//                             for (int j = 0; j < item.Value.moveTargetCodeList.Count; j++)
//                             {
//                                 var _tl = item.Value.moveTargetCodeList[j];
//                                 string _tg = _tl.location2;
//                                 if (_tl.location2 == "Activity") _tg = _tl.location3;
//                                 if (_tg == tg_dep){
//                                     if (!del_list.Contains(i)) del_list.Add(i);
//                                     break;
//                                 }
//                             }
//                         }
//                     }
//                     else{
//                         //是游戏
//                         if (ol.location2 == tg_dep){
//                             if (!del_list.Contains(i)) del_list.Add(i);
//                             if (!add_list.Contains(ol)) add_list.Add(ol);
//                             break;
//                         }
//                         else{
//                             //自己不在依赖的地方，但是要移动到依赖和目标位置，这个时候只需要移动到依赖位置即可
//                             for (int j = 0; j < item.Value.moveTargetCodeList.Count; j++)
//                             {
//                                 var _tl = item.Value.moveTargetCodeList[j];
//                                 string _tg = _tl.location2;
//                                 if (_tl.location2 == "Activity") _tg = _tl.location3;
//                                 if (_tg == tg_dep){
//                                     if (!del_list.Contains(i)) del_list.Add(i);
//                                     break;
//                                 }
//                             }

//                             if (asset_manager_struct.game_scene.ContainsKey(tg_dep)){
//                                 bool b = false;
//                                 foreach (var normal in asset_manager_struct.game_scene[tg_dep])
//                                 {
//                                     if (ol.location2 == normal){
//                                         if (!del_list.Contains(i)) del_list.Add(i);
//                                         if (!add_list.Contains(ol)) add_list.Add(ol);
//                                         b = true;
//                                         break;      
//                                     }
//                                     //自己不在依赖的地方，但是要移动到依赖和目标位置，这个时候只需要移动到依赖位置即可
//                                     for (int j = 0; j < item.Value.moveTargetCodeList.Count; j++)
//                                     {
//                                         var _tl = item.Value.moveTargetCodeList[j];
//                                         string _tg = _tl.location2;
//                                         if (_tl.location2 == "Activity") _tg = _tl.location3;
//                                         if (_tg == normal){
//                                             if (!del_list.Contains(i)) del_list.Add(i);
//                                             b = true;
//                                             break;
//                                         }
//                                     }
//                                 }
//                                 if (b) break;
//                             }
//                         }
//                     }
//                 }
//             }
        
//             for (int i = item.Value.moveTargetCodeList.Count - 1; i >= 0 ; i--)
//             {
//                 if (del_list.Contains(i)) item.Value.moveTargetCodeList.Remove(item.Value.moveTargetCodeList[i]);
//             }

//             foreach (var l in add_list)
//             {
//                 if (!item.Value.moveTargetCodeList.Contains(l)) item.Value.moveTargetCodeList.Add(l);
//             }

//             for (int i = item.Value.moveTargetCodeList.Count - 1; i >= 0 ; i--)
//             {
//                 if (!item.Value.moveTargetList.Contains(item.Value.moveTargetCodeList[i]))
//                     item.Value.moveTargetCodeList.RemoveAt(i);
//             }

//             //处理完后，先排序
//             SortLocation(item.Value.moveTargetCodeList);
//             int index = item.Value.moveTargetCodeList.IndexOf(item.Value.location);
//             if (index > 0){
//                 item.Value.moveTargetCodeList.RemoveAt(index);
//                 item.Value.moveTargetCodeList.Insert(0,item.Value.location);
//             }
//         }
//         EditorUtility.ClearProgressBar();
//     }

//     private static void CheckMoveTargetCodeList()
//     {
//         int counter = 0;
//         int total = asset_guid.Count;
//         //library 收集
//         foreach (var item in asset_guid)
//         {
//             EditorUtility.DisplayProgressBar("Check Move Target Code List", item.Value.path, ++counter / (float)total);

//             List<Location> moveTargetCodeList = new List<Location>();
//             //MonoScript，lua文件和场景文件不需要移动
//             if ((item.Value.type == "Lua") || (item.Value.type == "SceneAsset"))
//             {
//                 Location location = new Location();
//                 location.location1 = item.Value.location1;
//                 location.location2 = item.Value.location2;
//                 location.location3 = item.Value.location3;
//                 AddMoveTarget(moveTargetCodeList, location);
//                 item.Value.moveTargetCodeList = moveTargetCodeList;
//                 continue;
//             }

//             //audio文件特殊处理不移动
//             if (item.Value.type == "AudioClip")
//             {
//                 Location location = new Location();
//                 location.location1 = item.Value.location1;
//                 location.location2 = item.Value.location2;
//                 location.location3 = item.Value.location3;
//                 AddMoveTarget(moveTargetCodeList, location);
//                 item.Value.moveTargetCodeList = moveTargetCodeList;
//                 continue;
//             }
//             //asset_library中的文件
//             if (!string.IsNullOrEmpty(item.Value.asset_library))
//             {
//                 Location location = new Location();
//                 location.location1 = "Game";
//                 location.location2 = "CommonPrefab";
//                 AddMoveTarget(moveTargetCodeList, location);
//                 item.Value.moveTargetCodeList = moveTargetCodeList;
//                 continue;
//             }
//             //com_library中的文件
//             if (!string.IsNullOrEmpty(item.Value.com_library))
//             {
//                 string com_library = item.Value.com_library;
//                 Location location = new Location();
//                 if (com_library == "item_config")
//                 {
//                     //道具
//                     location.location1 = "Game";
//                     location.location2 = "Activity";
//                     location.location3 = "sys_item_manager";
//                     item.Value.moveTargetCodeList = moveTargetCodeList;
//                 }
//                 else if (com_library == "audio_conifg")
//                 {
//                     //音频
//                     item.Value.moveTargetCodeList = moveTargetCodeList;
//                 }
//                 else if (com_library == "swjl_icon_asset_config")
//                 {
//                     //实物icon
//                     location.location1 = "Game";
//                     location.location2 = "Activity";
//                     location.location3 = "swjl_icon";
//                     item.Value.moveTargetCodeList = moveTargetCodeList;
//                 }
//                 else if (com_library == "share_link_config")
//                 {
//                     //分享图
//                     location.location1 = "Game";
//                     location.location2 = "Activity";
//                     location.location3 = "sys_fx";
//                     item.Value.moveTargetCodeList = moveTargetCodeList;
//                 }
//                 AddMoveTarget(moveTargetCodeList, location);
//                 continue;
//             }

//             //普通文件，计算出准确目标位置
//             //多个文件夹往公用文件夹提取

//             //不需要移动
//             if (item.Value.moveTargetCodeList.Count == 0)
//             {
//                 item.Value.moveTargetCodeList = moveTargetCodeList;
//                 continue;
//             }
//             //只要移动到一个地方
//             if (item.Value.moveTargetCodeList.Count == 1)
//             {
//                 Location location = new Location();
//                 location.location1 = item.Value.moveTargetCodeList[0].location1;
//                 location.location2 = item.Value.moveTargetCodeList[0].location2;
//                 location.location3 = item.Value.moveTargetCodeList[0].location3;
//                 AddMoveTarget(moveTargetCodeList, location);
//                 item.Value.moveTargetCodeList = moveTargetCodeList;
//                 continue;
//             }
//             bool is_CommonPrefab = false;
//             Location common_ml = new Location();
//             foreach (var _location in item.Value.moveTargetCodeList)
//             {
//                 if (_location.location1 == "Game" && _location.location2 == "CommonPrefab")
//                 {
//                     is_CommonPrefab = true;
//                     common_ml = _location;
//                     break;
//                 }
//             }
//             //要移动到 CommonPrefab
//             if (is_CommonPrefab)
//             {
//                 Location location = new Location();
//                 location.location1 = "Game";
//                 location.location2 = "CommonPrefab";
//                 AddMoveTarget(moveTargetCodeList, location);
//                 item.Value.moveTargetCodeList = moveTargetCodeList;
//                 continue;
//             }
//             bool is_game_scene = false;
//             foreach (var _location in item.Value.moveTargetCodeList)
//             {
//                 if (_location.location1 == "Game" && asset_manager_struct.game_scene.ContainsKey(_location.location2))
//                 {
//                     is_game_scene = true;
//                     break;
//                 }
//             }
//             //没有要移动到游戏中的情况
//             if (!is_game_scene)
//             {
//                 foreach (var _location in item.Value.moveTargetCodeList)
//                 {
//                     Location location = new Location();
//                     location.location1 = _location.location1;
//                     location.location2 = _location.location2;
//                     location.location3 = _location.location3;
//                     AddMoveTarget(moveTargetCodeList, location);
//                 }
//                 item.Value.moveTargetCodeList = moveTargetCodeList;
//                 continue;
//             }

//             //要移动到游戏中的情况
//             Dictionary<string, int> gs_dic = new Dictionary<string, int>();
//             foreach (var _location in item.Value.moveTargetCodeList)
//             {
//                 if (_location.location1 == "Game" && asset_manager_struct.game_scene.ContainsKey(_location.location2))
//                 {
//                     if (!gs_dic.ContainsKey(_location.location2)) gs_dic.Add(_location.location2, 0);
//                     gs_dic[_location.location2] += 1;
//                 }
//                 else if (_location.location1 == "Game" && asset_manager_struct.normal_common.Contains(_location.location2))
//                 {
//                     if (!gs_dic.ContainsKey(_location.location2)) gs_dic.Add(_location.location2, 0);
//                     gs_dic[_location.location2] += 1;
//                 }
//             }
//             //只要移动到一个游戏中的情况
//             if (gs_dic.Count == 1)
//             {
//                 foreach (var _location in item.Value.moveTargetCodeList)
//                 {
//                     Location location = new Location();
//                     location.location1 = _location.location1;
//                     location.location2 = _location.location2;
//                     location.location3 = _location.location3;
//                     AddMoveTarget(moveTargetCodeList, location);
//                 }
//                 item.Value.moveTargetCodeList = moveTargetCodeList;
//                 continue;
//             }

//             Dictionary<string, int> nc_dic = new Dictionary<string, int>();
//             List<string> gs_list = new List<string>();
//             foreach (var _location in item.Value.moveTargetCodeList)
//             {
//                 if (_location.location1 == "Game" && asset_manager_struct.game_scene.ContainsKey(_location.location2) && asset_manager_struct.game_scene[_location.location2].Count > 0)
//                 {
//                     //尝试移动到normal中
//                     if (gs_list.Contains(_location.location2)) continue;
//                     gs_list.Add(_location.location2);
//                     string nc = asset_manager_struct.game_scene[_location.location2][0];
//                     if (!nc_dic.ContainsKey(nc)) nc_dic.Add(nc, 0);
//                     nc_dic[nc] += 1;
//                 }
//             }

//             bool is_normal_common = false;
//             foreach (var nc_c in nc_dic)
//             {
//                 if (nc_c.Value > 0)
//                 {
//                     is_normal_common = true;
//                     break;
//                 }
//             }
//             //不需要移动到normal_common中
//             if (!is_normal_common)
//             {
//                 foreach (var _location in item.Value.moveTargetCodeList)
//                 {
//                     Location location = new Location();
//                     location.location1 = _location.location1;
//                     location.location2 = _location.location2;
//                     location.location3 = _location.location3;
//                     AddMoveTarget(moveTargetCodeList, location);
//                 }
//                 item.Value.moveTargetCodeList = moveTargetCodeList;
//                 continue;
//             }
//             //要移动到normal_common中
//             foreach (var _location in item.Value.moveTargetCodeList)
//             {
//                 if (_location.location1 != "Game" || !asset_manager_struct.game_scene.ContainsKey(_location.location2) || asset_manager_struct.game_scene[_location.location2].Count == 0)
//                 {
//                     //先添加非游戏location
//                     Location location = new Location();
//                     location.location1 = _location.location1;
//                     location.location2 = _location.location2;
//                     location.location3 = _location.location3;
//                     AddMoveTarget(moveTargetCodeList, location);
//                 }
//                 else
//                 {
//                     string game = _location.location2;
//                     string normal = asset_manager_struct.game_scene[game][0];
//                     if (nc_dic.ContainsKey(normal) && nc_dic[normal] > 1)
//                     {
//                         //移动到对应的normal_common中
//                         Location location = new Location();
//                         location.location1 = _location.location1;
//                         location.location2 = normal;
//                         location.location3 = _location.location3;
//                         AddMoveTarget(moveTargetCodeList, location);
//                     }
//                     else
//                     {
//                         Location location = new Location();
//                         location.location1 = _location.location1;
//                         location.location2 = _location.location2;
//                         location.location3 = _location.location3;
//                         AddMoveTarget(moveTargetCodeList, location);
//                     }
//                 }
//             }
//             item.Value.moveTargetCodeList = moveTargetCodeList;

//             //处理完后，先排序
//             SortLocation(item.Value.moveTargetCodeList);
//             int index = item.Value.moveTargetCodeList.IndexOf(item.Value.location);
//             if (index > 0){
//                 item.Value.moveTargetCodeList.RemoveAt(index);
//                 item.Value.moveTargetCodeList.Insert(0,item.Value.location);
//             }
//         }
//         EditorUtility.ClearProgressBar();
//     }

//     //添加MovePathList
//     private static void AddMovePathList()
//     {
//         //检查资源的所有引用，确定移动位置

//         //asset_library基础资源库，其中的资源要收集，不移动
//         //com_library公用库资源，其中的资源收集 audio不移动，没用的要清理
//         //normal_common游戏公用库，多个游戏之间使用
//         //被多次引用的资源认为是公用资源 reference_count ???
//         //在游戏中的资源独立（以上公用资源不需要独立，在导出时进行copy在导出）
//         //活动用到了游戏中的资源需要独立
//         //按照prefab来分资源文件夹（打图集）
//         int counter = 0;
//         int total = asset_guid.Count;
//         foreach (var item in asset_guid)
//         {
//             EditorUtility.DisplayProgressBar("Add Move Path List", item.Value.path, ++counter / (float)total);
//             if (item.Value.moveTargetList.Count == 0)
//             {
//                 string movePath = "Assets";
//                 //没有被引用到的资源，需要移动到 _Type 的文件夹中
//                 if (!string.IsNullOrEmpty(item.Value.location1)) movePath += "/" + item.Value.location1;
//                 if (!string.IsNullOrEmpty(item.Value.location2)) movePath += "/" + item.Value.location2;
//                 if (!string.IsNullOrEmpty(item.Value.location3)) movePath += "/" + item.Value.location3;
//                 //放到_Type目录中
//                 movePath += "/_" + item.Value.type + "/" + item.Value.nameSuffix;

//                 AddMovePath(item.Value, movePath);
//                 continue;
//             }

//             if (item.Value.moveTargetCodeList.Count > 0){
//                 var location = item.Value.moveTargetCodeList[0];
//                 string movePath = "Assets";
//                 if (!string.IsNullOrEmpty(location.location1)) movePath += "/" + location.location1;
//                 if (!string.IsNullOrEmpty(location.location2)) movePath += "/" + location.location2;
//                 if (!string.IsNullOrEmpty(location.location3)) movePath += "/" + location.location3;
//                 movePath += "/" + item.Value.type + "/" + item.Value.nameSuffix;
//                 AddMovePath(item.Value, movePath);
//             }
//             for (int i = 0; i < item.Value.moveTargetList.Count; i++)
//             {
//                 var location = item.Value.moveTargetList[i];
//                 string movePath = "Assets";
//                 if (!string.IsNullOrEmpty(location.location1)) movePath += "/" + location.location1;
//                 if (!string.IsNullOrEmpty(location.location2)) movePath += "/" + location.location2;
//                 if (!string.IsNullOrEmpty(location.location3)) movePath += "/" + location.location3;
//                 string floder = "";
//                 //先按场景分
//                 // if (item.Value.referencesRoot.Count == 1)
//                 // {
//                 //     //只有一个预制体之类的资源引用，以该预制体为文件夹存放资源
//                 //     //没有或有多个预制体之类的资源引用，直接放在 Type 目录中
//                 //     floder = asset_guid[item.Value.referencesRoot[0]].name + "/";
//                 // }
//                 movePath += "/" + item.Value.type + "/" + floder + item.Value.nameSuffix;
//                 AddMovePath(item.Value, movePath);
//             }

//             // //先排序
//             // item.Value.movePathList.Sort(delegate (string x, string y)
//             // {
//             //     if (string.IsNullOrEmpty(x) && string.IsNullOrEmpty(y)) return 0;
//             //     else if (string.IsNullOrEmpty(x)) return -1;
//             //     else if (string.IsNullOrEmpty(y)) return 1;
//             //     else return x.CompareTo(y);
//             // });
//         }
//         EditorUtility.ClearProgressBar();
//     }

//     public static void AddMovePath(AssetDescriptionInfo item, string movePath)
//     {
//         foreach (var _mp in item.movePathList)
//         {
//             string str = _mp.Substring(0, _mp.IndexOf(item.type + "/"));
//             if (movePath.StartsWith(str))
//             {
//                 return;
//             }
//         }
//         if (!item.movePathList.Contains(movePath)) item.movePathList.Add(movePath);
//     }

//     //移动游戏资源
//     public static Dictionary<string,List<string>> asset_move;//拷贝的资源
//     public static void MoveGameAsset()
//     {
//         bool on_off = true;//移动开关
//         int count = 0;//移动资源计数
//         int counter = 0;
//         int total = asset_guid.Count;
//         asset_move = new Dictionary<string, List<string>>();
//         foreach (var item in asset_guid)
//         {
//             EditorUtility.DisplayProgressBar("Move Game Asset", item.Value.path, ++counter / (float)total);
//             //排除不需要处理的文件
//             if ((item.Value.type == "MonoScript") || (item.Value.type == "Lua") || (item.Value.type == "SceneAsset")) continue;
//             //不需要移动的不处理 //需要移动到两个位置的要进行 copy 这里先不处理
//             if (item.Value.movePathList.Count == 0) continue;

//             string mp = item.Value.movePathList[0];
//             //要移动的地方和自己的位置相同的不需要处理
//             if (asset_guid[item.Key].path == mp) continue;
//             //Unity中没有区分大小写目录，这里需要处理
//             if (asset_guid[item.Key].path.ToLower() == mp.ToLower()) continue;
//             string newPath = item.Value.movePathList[0];
//             string[] s = newPath.Split('/');
//             Location move_location = new Location();
//             move_location.location1 = s[1];
//             move_location.location2 = s[2];
//             move_location.location3 = "";
//             if (s[2] == "Activity") move_location.location3 = s[3];

//             string _mp = "Assets";
//             if (!string.IsNullOrEmpty(move_location.location1)) _mp += "/" + move_location.location1;
//             if (!string.IsNullOrEmpty(move_location.location2)) _mp += "/" + move_location.location2;
//             if (!string.IsNullOrEmpty(move_location.location3)) _mp += "/" + move_location.location3;
//             if (!asset_move.ContainsKey(_mp)) asset_move.Add(_mp,new List<string>());
//                 asset_move[_mp].Add(newPath);
//             DebugToConsole(item.Value, string.Format("<color=blue>{0}</color>", count++));
//             if (!on_off) continue;//移动开关，只打印不做移动操作
//             MoveAsset(item.Value, mp);
//         }
//         EditorUtility.ClearProgressBar();
//         //保存copy的数据
//         if (asset_move.Count > 0){
//             string json_str = JsonMapper.ToJson(asset_move);
//             Debug.Log("asset_move " + json_str);
//             System.DateTime startTime = TimeZone.CurrentTimeZone.ToLocalTime(new System.DateTime(1970, 1, 1)); // 当地时区
//             var timeStamp = (long)(DateTime.Now - startTime).TotalMilliseconds; // 相差毫秒数
//             string path = "Assets/asset_move_" + timeStamp + ".json";
//             path = "Assets/asset_move.json";
//             WriteAllText(path, json_str);
//         }
//         Debug.Log(count + " 资源移动完成!!!");
//         // AssetDatabase.Refresh();
//         // AssetDatabase.SaveAssets();
//     }

//     public static string MoveAsset(AssetDescriptionInfo adi, string newPath, int recursion_count = 10)
//     {
//         bool on_off = false;//开关
//         if(!on_off) return "";
//         //要移动的地方和自己的位置相同的不需要处理
//         if (adi.path == newPath) return "";
//         //Unity中没有区分大小写目录，这里需要处理
//         if (adi.path.ToLower() == newPath.ToLower()) return "";
//         recursion_count--;
//         string folder = newPath.Substring(0, newPath.IndexOf("/" + adi.nameSuffix));
//         CheckFolder(folder);
//         string result = AssetDatabase.MoveAsset(adi.path, newPath);
//         if (string.IsNullOrEmpty(result))
//         {
//             // Debug.Log("<color=green>移动资产结果成功：</color>" + newPath);
//             adi.path = newPath;//更新位置
//         }
//         else
//         {
//             //移动失败从新移动
//             if (recursion_count > 0)
//                 MoveAsset(adi, newPath, recursion_count);
//             else
//                 Debug.LogError("<color=red>移动资产结果失败：</color>" + result);

//         }

//         return result;
//     }

//     //拷贝游戏资源
//     public static Dictionary<string, Dictionary<string, string>> path_old2new_guid;//需要替换为新 guid 的文件
//     public static Dictionary<string,List<string>> asset_copy_by_code;//代码中用到的被copy的资源
//     public static Dictionary<string,List<string>> asset_copy;//拷贝的资源
//     public static void CopyGameAsset()
//     {
//         path_old2new_guid = new Dictionary<string, Dictionary<string, string>>();
//         asset_copy_by_code = new Dictionary<string, List<string>>();
//         asset_copy = new Dictionary<string, List<string>>();
//         bool on_off = true;//开关
//         int count = 0;//计数
//         int counter = 0;
//         int total = asset_guid.Count;
//         foreach (var item in asset_guid)
//         {
//             EditorUtility.DisplayProgressBar("Copy Game Asset", item.Value.path, ++counter / (float)total);
//             //排除不需要处理的文件
//             if ((item.Value.type == "MonoScript") || (item.Value.type == "Lua") || (item.Value.type == "SceneAsset")) continue;
//             // if (asset_manager_struct.fix_asset.ContainsKey(item.Value.type))
//             //不需要copy的不处理
//             if (item.Value.movePathList.Count < 2) continue;
//             for (int i = 1; i < item.Value.movePathList.Count; i++)
//             {
//                 string newPath = item.Value.movePathList[i];
//                 string[] s = newPath.Split('/');
//                 Location cop_loction = new Location();
//                 cop_loction.location1 = s[1];
//                 cop_loction.location2 = s[2];
//                 cop_loction.location3 = "";
//                 if (s[2] == "Activity") cop_loction.location3 = s[3];

//                 string _mp = "Assets";
//                 if (!string.IsNullOrEmpty(cop_loction.location1)) _mp += "/" + cop_loction.location1;
//                 if (!string.IsNullOrEmpty(cop_loction.location2)) _mp += "/" + cop_loction.location2;
//                 if (!string.IsNullOrEmpty(cop_loction.location3)) _mp += "/" + cop_loction.location3;

//                 if (item.Value.moveTargetCodeList.Contains(cop_loction)){
//                     // if (item.Value.type != "Texture2D" && !item.Value.moveLocationAssetList.Contains(cop_loction)){
//                     //     //不是图片，资源对其没有引用 这种情况不需要copy，copy会导致大量的资源重复
//                     //     continue;
//                     // }
//                     if (!asset_copy_by_code.ContainsKey(_mp)) asset_copy_by_code.Add(_mp,new List<string>());
//                         asset_copy_by_code[_mp].Add(newPath);
//                     DebugToConsole(item.Value, string.Format("<color=red>！！！代码中引用Copy的资源 {0} </color>", newPath));
//                 }

//                 if (!asset_copy.ContainsKey(_mp)) asset_copy.Add(_mp,new List<string>());
//                     asset_copy[_mp].Add(newPath);
//                 DebugToConsole(item.Value, string.Format("<color=yellow>{0} -> newPath:{1} -- </color>", count++,newPath));
//                 if (!on_off) continue;//只打印不做操作
//                 CopyAsset(item.Value, item.Value.path, newPath);
//             }
//         }
//         EditorUtility.ClearProgressBar();

//         AssetDatabase.SaveAssets();

//         //将游戏中对旧资源的引用重新指向对新copy的资源的引用
//         foreach (var item in path_old2new_guid)
//         {
//             string path = item.Key;
//             path = path.Replace("Assets/", "");
//             path = path.Replace("/", "\\");
//             string newFoldrPath = Application.dataPath + "/" + path;
//             UtilGuids.RegenerateGuids(newFoldrPath, null, item.Value);
//         }

//         //保存多代码引用数据
//         if (asset_copy_by_code.Count > 0){
//             string json_str = JsonMapper.ToJson(asset_copy_by_code);
//             Debug.Log("asset_copy_by_code " + json_str);
//             System.DateTime startTime = TimeZone.CurrentTimeZone.ToLocalTime(new System.DateTime(1970, 1, 1)); // 当地时区
//             var timeStamp = (long)(DateTime.Now - startTime).TotalMilliseconds; // 相差毫秒数
//             string path = "Assets/asset_copy_by_code_" + timeStamp + ".json";
//             path = "Assets/asset_copy_by_code.json";
//             WriteAllText(path, json_str);
//         }

//         //保存copy的数据
//         if (asset_copy.Count > 0){
//             string json_str = JsonMapper.ToJson(asset_copy);
//             Debug.Log("asset_copy " + json_str);
//             System.DateTime startTime = TimeZone.CurrentTimeZone.ToLocalTime(new System.DateTime(1970, 1, 1)); // 当地时区
//             var timeStamp = (long)(DateTime.Now - startTime).TotalMilliseconds; // 相差毫秒数
//             string path = "Assets/asset_copy_" + timeStamp + ".json";
//             path = "Assets/asset_copy.json";
//             WriteAllText(path, json_str);
//         }

//         Debug.Log(count + " 资源拷贝完成!!!");
//         AssetDatabase.Refresh();
//         AssetDatabase.SaveAssets();
//     }

//     public static bool CopyAsset(AssetDescriptionInfo adi, string path, string newPath, int recursion_count = 10)
//     {
//         bool on_off = false;//开关
//         if(!on_off) return true;
//         recursion_count--;
//         string folder = newPath.Substring(0, newPath.IndexOf("/" + adi.nameSuffix));
//         CheckFolder(folder);
//         bool b = AssetDatabase.CopyAsset(path, newPath);
//         if (b)
//         {
//             // Debug.Log("<color=green>拷贝资产结果成功：</color>" + newPath);
//             string[] s = newPath.Split('/');
//             string newGuid = AssetDatabase.AssetPathToGUID(newPath);
//             string newName = adi.name + "_" + s[2];
//             if (s[2] == "Activity") newName += "_" + s[3];
//             newName = newName.ToLower();
//             string result = AssetDatabase.RenameAsset(newPath, newName);
//             if (!string.IsNullOrEmpty(result))
//                 Debug.LogError("<color=red>重命名失败!!!</color>" + result);
//             string oldGuid = adi.guid;

//             string movePath = s[0] + "/" + s[1] + "/" + s[2];
//             if (s[2] == "Activity") movePath = movePath + "/" + s[3];
//             if (path_old2new_guid == null) path_old2new_guid = new Dictionary<string, Dictionary<string, string>>();
//             if (!path_old2new_guid.ContainsKey(movePath)) path_old2new_guid.Add(movePath, new Dictionary<string, string>());
//             if (!path_old2new_guid[movePath].ContainsKey(oldGuid)) path_old2new_guid[movePath].Add(oldGuid, newGuid);

//             //normal_common处理
//             string normal_common = s[2];
//             if (asset_manager_struct.normal_common.Contains(normal_common))
//             {
//                 foreach (var location in adi.moveLocationList)
//                 {
//                     if (location.location1 == "Game" && asset_manager_struct.game_scene.ContainsKey(location.location2) && asset_manager_struct.game_scene[location.location2].Count > 0 && asset_manager_struct.game_scene[location.location2][0] == normal_common)
//                     {
//                         string originPath = "Assets";
//                         if (!string.IsNullOrEmpty(location.location1)) originPath += "/" + location.location1;
//                         if (!string.IsNullOrEmpty(location.location2)) originPath += "/" + location.location2;
//                         if (!string.IsNullOrEmpty(location.location3)) originPath += "/" + location.location3;
//                         if (path_old2new_guid == null) path_old2new_guid = new Dictionary<string, Dictionary<string, string>>();
//                         if (!path_old2new_guid.ContainsKey(originPath)) path_old2new_guid.Add(originPath, new Dictionary<string, string>());
//                         if (!path_old2new_guid[originPath].ContainsKey(oldGuid)) path_old2new_guid[originPath].Add(oldGuid, newGuid);
//                     }
//                 }
//             }
//         }
//         else
//         {
//             if (recursion_count > 0)
//                 CopyAsset(adi, path, newPath, recursion_count);
//             else
//                 Debug.LogError("<color=red>拷贝资产结果失败：</color>" + newPath);
//         }
//         return b;
//     }

//     public static AssetsManagerStruct asset_manager_struct;//资源管理的配置文件转换的结构体

//     [MenuItem("Assets/Util/资源整理", false, 0)]
//     [MenuItem("Util/资源整理", false, 0)]
//     public static void MoveAndCopyGameAsset()
//     {
//         ClearEmptyFolder.IsLock = true;
//         ParseAssetsManagerConfig();
//         SetActivityConfigStruct();

//         InitAssetDescriptionInfo();
//         AddAssetReferences();
//         AddLuaCodeReferences();
//         AddAssetLibrary();
//         AddComLibrary();
//         AddMoveLocationList();
//         CheckMoveLocation();
//         AddMoveTargetList();
//         CheckMoveTargetDepend();
//         CheckMoveTargetList();
//         AddMoveTargetCodeList();
//         CheckMoveTargetCodeDepend();
//         CheckMoveTargetCodeList();
//         AddMovePathList();

//         // CollectMaterial();
//         CollectTexture2DTpsheet();
//         // CollectFont();
//         // CollectFbx();
//         RemoveSpine();//不移动spine相关文件，导入的时候需要确认会导致引用丢失

//         foreach (var item in asset_guid)
//         {
//             // if (item.Value.name.Contains("wave3d")) DebugToConsole(item.Value,"XXXXXXXXXXXX");
//         }

//         MoveGameAsset();
//         CopyGameAsset();

//         AssetDatabase.Refresh();
//         AssetDatabase.SaveAssets();
//         ClearEmptyFolder.IsLock = false;
//         // Packager.BuildAssetMap();//删除空余目录
//     }

//     [MenuItem("Assets/Util/生成资源引用配置",false,1000)]
//     [MenuItem("Util/生成资源引用配置", false, 1000)]
//     private static void UpdateSwjlIconConfig()
//     {
//         string oldFolderPath = AssetDatabase.GetAssetPath(Selection.objects[0]);
//         string[] s = oldFolderPath.Split('/');
//         string folderName = s[s.Length - 1];
//         if (folderName.Contains("."))
//         {
//             Debug.LogError("该索引不是文件夹名字");
//             return;
//         }
//         string folderPath = Path.GetFullPath(".") + Path.DirectorySeparatorChar + oldFolderPath;
//         folderPath = folderPath.Replace("\\","/");
//         Debug.Log("folderPath" + folderPath);
//         List<string> asset_name = new List<string>();
//         GetDirectory(folderPath,asset_name);
//         string json_str = JsonMapper.ToJson(asset_name);
//         Debug.Log("asset_config json " + json_str);
//         string lua_str = json_str.Replace("[", "{");
//         lua_str = lua_str.Replace("]", "}");
//         Debug.Log("asset_config lua " + lua_str);
//         lua_str = "return " + lua_str;

//         s = folderPath.Split('/');
//         string name = s[s.Length -1] + "_asset_config.lua";
//         string path = folderPath.Substring(folderPath.IndexOf("Assets"));
//         path = path +"/Lua/" + name;
//         Debug.Log("path " + path);
//         WriteAllText(path, lua_str);
//         AssetDatabase.SaveAssets();
//         AssetDatabase.Refresh();
//     }

//     public static void GetDirectory(string sourceDirectory, List<string> asset_name)
//     {
//         //判断源目录和目标目录是否存在，如果不存在，则创建一个目录
//         if (!Directory.Exists(sourceDirectory))
//         {
//             Debug.Log("没有目录？？？");
//             return;
//         }
//         GetFile(sourceDirectory, asset_name);
//         string[] directionName = Directory.GetDirectories(sourceDirectory);
//         foreach (string directionPath in directionName)
//         {
//             GetDirectory(directionPath, asset_name);
//         }
//     }
//     public static void GetFile(string sourceDirectory, List<string> asset_name)
//     {
//         //获取所有文件名称
//         string[] fileName = Directory.GetFiles(sourceDirectory);
//         foreach (string filePath in fileName)
//         {
//             Debug.Log("filePath " + filePath);
//             if (!filePath.Contains("."))
//             {
//                 Debug.Log("该索引不是文件名字");
//                 continue;
//             }
//             if (filePath.Contains(".meta"))
//             {
//                 Debug.Log("该索引是meat文件");
//                 continue;
//             }
//             string fp = filePath;
//             fp = fp.Replace("\\","/");
//             string[] s = fp.Split('/');
//             string folderName = s[s.Length - 1];
//             s = folderName.Split('.');
//             folderName = s[0];
//             if (!asset_name.Contains(folderName)) asset_name.Add(folderName);
//         }
//     }

//     //活动配置相关
//     public struct act_struct
//     {
//         public string name;
//         public bool enable;
//     }
//     public static string ActivityConfigPath = "Assets/VersionConfig/ActivityConfig.json";
//     public static string ActConfigPath = "Assets/act_config.txt";
//     public static string GameModuleConfig = "Assets/Game/CommonPrefab/Lua/game_module_config.lua";
//     [MenuItem("Assets/Util/生成活动配置",false,10)]
//     [MenuItem("Util/生成活动配置", false, 10)]
//     public static void CreateActivityConfig()
//     {
//         string ActivityConfigPath = "Assets/VersionConfig/ActivityConfig.json";
//         string ActConfigPath = "Assets/act_config.txt";
//         string GameModuleConfig = "Assets/Game/CommonPrefab/Lua/game_module_config.lua";
//         Debug.Log(AppDefine.CurQuDao);
//         if (AppDefine.CurQuDao != "main")
//         {
//             ActivityConfigPath = "Assets/VersionConfig/ActivityConfig_" + AppDefine.CurQuDao + ".json";
//             ActConfigPath = "Assets/act_config_" + AppDefine.CurQuDao + ".txt";
//             string gmc = "Assets/Channel/" + AppDefine.CurQuDao + "/Assets/Lua/game_module_config.lua";
//             if (File.Exists(gmc))
//                 GameModuleConfig = gmc;
//         }
//         Debug.Log(GameModuleConfig);
//         Dictionary<string, Dictionary<string, string>> dic = new Dictionary<string, Dictionary<string, string>>();
//         string[] luatable = File.ReadAllLines(GameModuleConfig); ;
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
//         Debug.Log("ActivityConfig " + json_str);
//         WriteAllText(ActivityConfigPath, json_str);
//         //生成act_config
//         string txt_str = "";
//         foreach (var item in dic)
//         {
//             txt_str += item.Value["key"] + "|" + item.Value["desc"] + "|" + item.Value["state"] + "\n";
//         }
//         Debug.Log("act_config " + txt_str);
//         WriteAllText(ActConfigPath, txt_str);
//         Debug.Log("生成活动配置完成");
//     }
// }
