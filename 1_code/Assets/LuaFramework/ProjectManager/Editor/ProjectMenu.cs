using UnityEditor;
using UnityEngine;

public class ProjectMenu : EditorWindow
{
    const string NEWGAMEMENU = "Assets/新建游戏";
    const string SETCURRENTMENU = "Assets/设置为当前项目";

    /// <summary>
    /// 项目名称
    /// </summary>
    private string gameName = "";
    //绘制窗口时调用
    void OnGUI()
    {
        gameName = GUILayout.TextField(gameName, GUILayout.Height(50));
        if (GUILayout.Button("确定", GUILayout.Height(30)))
        {
            if (gameName != "")
            {
                ProjectEditUtility.CreateGameTemplateForlders(gameName);
                this.Close();
            }
            else
            {
                Debug.Log("<color=red>项目名不能为空！！！</color>");
            }
        }
    }
    [MenuItem(NEWGAMEMENU, true, 60)]
    public static bool CreateGameValidate()
    {
        string[] assetGUIDArray = Selection.assetGUIDs;

        if (assetGUIDArray.Length == 1)
            return AssetDatabase.GUIDToAssetPath(assetGUIDArray[0]) == "Assets";

        return false;
    }
    // 新建游戏
    [MenuItem(NEWGAMEMENU, false, 60)]
    public static void CreateGame()
    {
        //创建窗口
        Rect wr = new Rect(0, 0, 400, 200);
        ProjectMenu window = (ProjectMenu)EditorWindow.GetWindowWithRect(typeof(ProjectMenu), wr, true, "新建游戏名");
        window.Show();
    }

    // 设置为当前项目目录
    [MenuItem(SETCURRENTMENU, false, 61)]
    public static void SetCurrentProject()
    {
        string[] assetGUIDArray = Selection.assetGUIDs;

        if (assetGUIDArray.Length == 1)
            AppDefine.CurrentProjectPath = AssetDatabase.GUIDToAssetPath(assetGUIDArray[0]);
    }

    [MenuItem(SETCURRENTMENU, true, 61)]
    public static bool SelectProjectFounderValidate()
    {
        string[] assetGUIDArray = Selection.assetGUIDs;

        if (assetGUIDArray.Length == 1)
        {
            string path = AssetDatabase.GUIDToAssetPath(Selection.assetGUIDs[0]);
            return path == "Assets/Hall" || (path.Split('/').Length == 3 && path.Contains("Assets/Game"));
        }

        return false;
    }
    
    const string kSimulateAssetBundlesMenu = "Dev/模拟AssetBundles";

    [MenuItem(kSimulateAssetBundlesMenu, false, 1)]
    public static void ToggleSimulateAssetBundle()
    {
        AppDefine.IsLuaBundleMode = !AppDefine.IsLuaBundleMode;
    }

    [MenuItem(kSimulateAssetBundlesMenu, true, 1)]
    public static bool ToggleSimulateAssetBundleValidate()
    {
        Menu.SetChecked(kSimulateAssetBundlesMenu, AppDefine.IsLuaBundleMode);
        return true;
    }

    const string kSimulateDebug = "Dev/Debug开关";

    [MenuItem(kSimulateDebug, false, 1)]
    public static void ToggleSimulateDebug()
    {
        AppDefine.IsDebug = !AppDefine.IsDebug;
    }

    [MenuItem(kSimulateDebug, true, 1)]
    public static bool ToggleSimulateDebugValidate()
    {
        Menu.SetChecked(kSimulateDebug, AppDefine.IsDebug);
        return true;
    }

    const string kSimulateForceOpenYK = "Dev/强制打开游客登录";

    [MenuItem(kSimulateForceOpenYK, false, 1)]
    public static void ToggleSimulateForceOpenYK()
    {
        AppDefine.IsForceOpenYK = !AppDefine.IsForceOpenYK;
    }

    [MenuItem(kSimulateForceOpenYK, true, 1)]
    public static bool ToggleSimulateForceOpenYKValidate()
    {
        Menu.SetChecked(kSimulateForceOpenYK, AppDefine.IsForceOpenYK);
        return true;
    }

    const string kLocal1Menu = "Dev/渠道/Local1";
    [MenuItem(kLocal1Menu, false, 20)]
    public static void ToggleLocal1()
    {
        Debug.Log(Application.dataPath);
        Debug.Log("Local1");
        AppDefine.CurQuDao = "Local1";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kLocal1Menu, true, 20)]
    public static bool ToggleLocal1Validate()
    {
        if ("Local1" == AppDefine.CurQuDao)
            Menu.SetChecked(kLocal1Menu, true);
        else
            Menu.SetChecked(kLocal1Menu, false);
        return true;
    }

    const string kLocal2Menu = "Dev/渠道/Local2";
    [MenuItem(kLocal2Menu, false, 20)]
    public static void ToggleLocal2()
    {
        Debug.Log(Application.dataPath);
        Debug.Log("Local2");
        AppDefine.CurQuDao = "Local2";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kLocal2Menu, true, 20)]
    public static bool ToggleLocal2Validate()
    {
        if ("Local2" == AppDefine.CurQuDao)
            Menu.SetChecked(kLocal2Menu, true);
        else
            Menu.SetChecked(kLocal2Menu, false);
        return true;
    }

    const string kLocal3Menu = "Dev/渠道/Local3";
    [MenuItem(kLocal3Menu, false, 20)]
    public static void ToggleLocal3()
    {
        Debug.Log(Application.dataPath);
        Debug.Log("Local3");
        AppDefine.CurQuDao = "Local3";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kLocal3Menu, true, 20)]
    public static bool ToggleLocal3Validate()
    {
        if ("Local3" == AppDefine.CurQuDao)
            Menu.SetChecked(kLocal3Menu, true);
        else
            Menu.SetChecked(kLocal3Menu, false);
        return true;
    }

    const string kNewFishMenu = "Dev/渠道/NewFish";
    [MenuItem(kNewFishMenu, false, 20)]
    public static void ToggleNewFish()
    {
        Debug.Log(Application.dataPath);
        Debug.Log("NewFish");
        AppDefine.CurQuDao = "NewFish";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kNewFishMenu, true, 20)]
    public static bool ToggleNewFishValidate()
    {
        if ("NewFish" == AppDefine.CurQuDao)
            Menu.SetChecked(kNewFishMenu, true);
        else
            Menu.SetChecked(kNewFishMenu, false);
        return true;
    }

    // 渠道选择菜单
    // 自营渠道:main
    // 华为:huawei
    // ...
    const string kQudao1Menu = "Dev/渠道/自营渠道";
    [MenuItem(kQudao1Menu, false, 20)]
    public static void ToggleQuDao1()
    {
        Debug.Log(Application.dataPath);
        Debug.Log("自营渠道");
        AppDefine.CurQuDao = "main";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kQudao1Menu, true, 20)]
    public static bool ToggleQuDao1Validate()
    {
        if ("main" == AppDefine.CurQuDao)
            Menu.SetChecked(kQudao1Menu, true);
        else
            Menu.SetChecked(kQudao1Menu, false);
        return true;
    }

    const string kQudao2Menu = "Dev/渠道/自营渠道(IOS提审)";
    [MenuItem(kQudao2Menu, false, 21)]
    public static void ToggleQuDao2()
    {
		Debug.Log("IOS提审");
        AppDefine.CurQuDao = "main_ios_ts";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kQudao2Menu, true, 21)]
    public static bool ToggleQuDao2Validate()
    {
        if ("main_ios_ts" == AppDefine.CurQuDao)
            Menu.SetChecked(kQudao2Menu, true);
        else
            Menu.SetChecked(kQudao2Menu, false);
        return true;
    }
	
    const string kLocal4Menu = "Dev/渠道/欢乐天天捕鱼(VIVO)";
    [MenuItem(kLocal4Menu, false, 20)]
    public static void ToggleLocal4()
    {
        Debug.Log(Application.dataPath);
        Debug.Log("欢乐天天捕鱼(VIVO)");
        AppDefine.CurQuDao = "vivo";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kLocal4Menu, true, 20)]
    public static bool ToggleLocal4Validate()
    {
        if ("vivo" == AppDefine.CurQuDao)
            Menu.SetChecked(kLocal4Menu, true);
        else
            Menu.SetChecked(kLocal4Menu, false);
        return true;
    }

    const string kLocal5Menu = "Dev/渠道/欢乐天天捕鱼(VIVO)_提审";
    [MenuItem(kLocal5Menu, false, 20)]
    public static void ToggleLocal5()
    {
        Debug.Log(Application.dataPath);
        Debug.Log("欢乐天天捕鱼(VIVO)_提审");
        AppDefine.CurQuDao = "vivo_ts";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kLocal5Menu, true, 20)]
    public static bool ToggleLocal5Validate()
    {
        if ("vivo_ts" == AppDefine.CurQuDao)
            Menu.SetChecked(kLocal5Menu, true);
        else
            Menu.SetChecked(kLocal5Menu, false);
        return true;
    }

    const string kLocal6Menu = "Dev/渠道/拼多多";
    [MenuItem(kLocal6Menu, false, 20)]
    public static void ToggleLocal6()
    {
        Debug.Log(Application.dataPath);
        Debug.Log("拼多多");
        AppDefine.CurQuDao = "pdd";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kLocal6Menu, true, 20)]
    public static bool ToggleLocal6Validate()
    {
        if ("pdd" == AppDefine.CurQuDao)
            Menu.SetChecked(kLocal6Menu, true);
        else
            Menu.SetChecked(kLocal6Menu, false);
        return true;
    }

    const string kLocal7Menu = "Dev/渠道/小米(提审)";
    [MenuItem(kLocal7Menu, false, 20)]
    public static void ToggleLocal7()
    {
        Debug.Log(Application.dataPath);
        Debug.Log("小米(提审)");
        AppDefine.CurQuDao = "xiaomi_ts";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kLocal7Menu, true, 20)]
    public static bool ToggleLocal7Validate()
    {
        if ("xiaomi_ts" == AppDefine.CurQuDao)
            Menu.SetChecked(kLocal7Menu, true);
        else
            Menu.SetChecked(kLocal7Menu, false);
        return true;
    }

    const string kLocal8Menu = "Dev/渠道/冲金鸡";
    [MenuItem(kLocal8Menu, false, 22)]
    public static void ToggleLocal8()
    {
        Debug.Log(Application.dataPath);
        Debug.Log("冲金鸡");
        AppDefine.CurQuDao = "cjj";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kLocal8Menu, true, 22)]
    public static bool ToggleLocal8Validate()
    {
        if ("cjj" == AppDefine.CurQuDao)
            Menu.SetChecked(kLocal8Menu, true);
        else
            Menu.SetChecked(kLocal8Menu, false);
        return true;
    }

    const string kLocal9Menu = "Dev/渠道/CPL";
    [MenuItem(kLocal9Menu, false, 19)]
    public static void ToggleLocal9()
    {
        Debug.Log(Application.dataPath);
        Debug.Log("捕鱼的CPL");
        AppDefine.CurQuDao = "cpl";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kLocal9Menu, true, 19)]
    public static bool ToggleLocal9Validate()
    {
        if ("cpl" == AppDefine.CurQuDao)
            Menu.SetChecked(kLocal9Menu, true);
        else
            Menu.SetChecked(kLocal9Menu, false);
        return true;
    }

    const string kLocal10Menu = "Dev/渠道/应用宝(提审)";
    [MenuItem(kLocal10Menu, false, 20)]
    public static void ToggleLocal10()
    {
        Debug.Log(Application.dataPath);
        Debug.Log("应用宝(提审)");
        AppDefine.CurQuDao = "yyb_ts";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kLocal10Menu, true, 20)]
    public static bool ToggleLocal10Validate()
    {
        if ("yyb_ts" == AppDefine.CurQuDao)
            Menu.SetChecked(kLocal10Menu, true);
        else
            Menu.SetChecked(kLocal10Menu, false);
        return true;
    }

    const string kLocal11Menu = "Dev/渠道/小米";
    [MenuItem(kLocal11Menu, false, 20)]
    public static void ToggleLocal11()
    {
        Debug.Log(Application.dataPath);
        Debug.Log("小米");
        AppDefine.CurQuDao = "xiaomi";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kLocal11Menu, true, 20)]
    public static bool ToggleLocal11Validate()
    {
        if ("xiaomi" == AppDefine.CurQuDao)
            Menu.SetChecked(kLocal11Menu, true);
        else
            Menu.SetChecked(kLocal11Menu, false);
        return true;
    }

    const string kLocal12Menu = "Dev/渠道/冲金鸡CPL";
    [MenuItem(kLocal12Menu, false, 23)]
    public static void ToggleLocal12()
    {
        Debug.Log(Application.dataPath);
        Debug.Log("冲金鸡CPL");
        AppDefine.CurQuDao = "cjj_cpl";
        AppDefine.CurResPath = "cjj";
    }
    [MenuItem(kLocal12Menu, true, 23)]
    public static bool ToggleLocal12Validate()
    {
        if ("cjj_cpl" == AppDefine.CurQuDao)
            Menu.SetChecked(kLocal12Menu, true);
        else
            Menu.SetChecked(kLocal12Menu, false);
        return true;
    }
}
