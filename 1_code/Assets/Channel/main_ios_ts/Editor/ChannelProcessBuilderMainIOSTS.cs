﻿using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEditor;
using UnityEditor.Build;
using UnityEditor.Callbacks;
using LuaFramework;

#if UNITY_IOS
using UnityEditor.iOS.Xcode;
#endif

class PreProcessBuilderMainIOSTS : IPreprocessBuild {
	public int callbackOrder { get { return 0; } }
	public void OnPreprocessBuild(BuildTarget buildTarget, string path) {
		string channelName = AppDefine.CurQuDao;
		if (string.Compare (channelName, "main_ios_ts", true) != 0)
			return;

		UnityEngine.Debug.Log ("OnPreprocessBuild for main_ios_ts channel!");

		PlayerSettings.applicationIdentifier = "com.changleyouyl.hlbuyu";

		if (buildTarget == BuildTarget.Android)
			PreprocessAndroid(path);

		if (buildTarget == BuildTarget.iOS)
			PreprocessIOS(path);
	}

	private void PreprocessAndroid(string path) {
		string rootDir = Application.dataPath.Substring (0, Application.dataPath.Length - 6);
		CopyPluginDir(rootDir, "Android");
	}
	private void PreprocessIOS(string path) {
		string rootDir = Application.dataPath.Substring (0, Application.dataPath.Length - 6);
		CopyPluginDir(rootDir, "iOS");
	}

	private void CopyPluginDir(string rootDir, string tagName) {
		string pluginDir = "/Plugins/" + tagName + "/";
		Util.CopyDir(rootDir + "Channel/" + AppDefine.CurQuDao + pluginDir, Application.dataPath + pluginDir);
		AssetDatabase.Refresh ();
	}
}

class PostProcessBuilderMainIOSTS : IPostprocessBuild {
	public int callbackOrder { get { return 0; } }
	public void OnPostprocessBuild(BuildTarget buildTarget, string path) {
		string channelName = AppDefine.CurQuDao;
		if (string.Compare (channelName, "main_ios_ts", true) != 0)
			return;
		
		UnityEngine.Debug.Log ("OnPostprocessBuild for main_ios_ts channel!");

		if (buildTarget == BuildTarget.Android)
			PostprocessAndroid(path);
		
		if (buildTarget == BuildTarget.iOS)
			PostprocessIOS(path);
	}

	private void PostprocessAndroid(string path) {
		string rootDir = Application.dataPath.Substring (0, Application.dataPath.Length - 6);
		Util.ClearPluginDir (rootDir, "Android", AppDefine.CurQuDao);
		AssetDatabase.Refresh ();

		string exportDir = path.Replace('\\', '/') + "/" + Application.productName + "/";
		string copyRoot = rootDir + "Channel/" + AppDefine.CurQuDao + "/Android/Copy/";

		Util.CopyDir (copyRoot, exportDir);

		//delete
		string[] deleteFiles = new string[] {
			"libs/openinstall-unity.jar",
			"libs/OpenInstall_v2.3.2.jar"
		};
		string fileName = string.Empty;
		for (int idx = 0; idx < deleteFiles.Length; ++idx)
		{
			fileName = exportDir + deleteFiles[idx];
			if (File.Exists(fileName))
				File.Delete(fileName);
		}
	}

	private void PostprocessIOS(string path) {
#if UNITY_IOS

		string rootDir = Application.dataPath.Substring (0, Application.dataPath.Length - 6);

		Util.ClearPluginDir (rootDir, "iOS", AppDefine.CurQuDao);
		AssetDatabase.Refresh ();

		string copyRoot = rootDir + "Channel/" + AppDefine.CurQuDao + "/IOS/Copy/";
		Util.CopyDir (copyRoot, path);

		string projPath = PBXProject.GetPBXProjectPath (path);
		PBXProject proj = new PBXProject ();
		string fileText = File.ReadAllText (projPath);
		proj.ReadFromString (fileText);

		string targetName = PBXProject.GetUnityTargetName ();
		string targetGuid = proj.TargetGuidByName (targetName);
		//Debug.Log ("targetName: " + targetName);
		//Debug.Log ("targetGuid: " + targetGuid);

		proj.AddFileToBuild(targetGuid, proj.AddFile(path + "/" + "Classes/ConvertAudioFile.h", "Classes/ConvertAudioFile.h", PBXSourceTree.Source));
		proj.AddFileToBuild(targetGuid, proj.AddFile(path + "/" + "Classes/ConvertAudioFile.mm", "Classes/ConvertAudioFile.mm", PBXSourceTree.Source));

		proj.AddFileToBuild(targetGuid, proj.AddFile(path + "/" + "Classes/ios_permission.h", "Classes/ios_permission.h", PBXSourceTree.Source));
		proj.AddFileToBuild(targetGuid, proj.AddFile(path + "/" + "Classes/ios_permission.mm", "Classes/ios_permission.mm", PBXSourceTree.Source));
		proj.AddFileToBuild(targetGuid, proj.AddFile(path + "/" + "Classes/MyCLLocationManager.h", "Classes/MyCLLocationManager.h", PBXSourceTree.Source));
		proj.AddFileToBuild(targetGuid, proj.AddFile(path + "/" + "Classes/MyCLLocationManager.mm", "Classes/MyCLLocationManager.mm", PBXSourceTree.Source));

		proj.AddFileToBuild(targetGuid, proj.AddFile(path + "/" + "Classes/AmrFileCodec.h", "Classes/AmrFileCodec.h", PBXSourceTree.Source));
		proj.AddFileToBuild(targetGuid, proj.AddFile(path + "/" + "Classes/AmrFileCodec.mm", "Classes/AmrFileCodec.mm", PBXSourceTree.Source));
		proj.AddFileToBuild(targetGuid, proj.AddFile(path + "/" + "Classes/AudioUtil.h", "Classes/AudioUtil.h", PBXSourceTree.Source));
		proj.AddFileToBuild(targetGuid, proj.AddFile(path + "/" + "Classes/AudioUtil.mm", "Classes/AudioUtil.mm", PBXSourceTree.Source));

		proj.AddFileToBuild(targetGuid, proj.AddFile(path + "/" + "Classes/IOSAlbumCameraController.h", "Classes/IOSAlbumCameraController.h", PBXSourceTree.Source));
		proj.AddFileToBuild(targetGuid, proj.AddFile(path + "/" + "Classes/IOSAlbumCameraController.mm", "Classes/IOSAlbumCameraController.mm", PBXSourceTree.Source));

		proj.AddFileToBuild(targetGuid, proj.AddFile(path + "/" + "Classes/Amr/opencore-amrnb/interf_dec.h", "Classes/Amr/opencore-amrnb/interf_dec.h", PBXSourceTree.Source));
		proj.AddFileToBuild(targetGuid, proj.AddFile(path + "/" + "Classes/Amr/opencore-amrnb/interf_enc.h", "Classes/Amr/opencore-amrnb/interf_enc.h", PBXSourceTree.Source));
		proj.AddFileToBuild(targetGuid, proj.AddFile(path + "/" + "Classes/Amr/opencore-amrwb/dec_if.h", "Classes/Amr/opencore-amrwb/dec_if.h", PBXSourceTree.Source));
		proj.AddFileToBuild(targetGuid, proj.AddFile(path + "/" + "Classes/Amr/opencore-amrwb/if_rom.h", "Classes/Amr/opencore-amrwb/if_rom.h", PBXSourceTree.Source));

		// common
		proj.SetBuildProperty(targetGuid, "ENABLE_BITCODE", "NO");
		proj.SetBuildProperty(targetGuid, "GCC_ENABLE_OBJC_EXCEPTIONS", "YES");
		proj.SetBuildProperty(targetGuid, "USYM_UPLOAD_AUTH_TOKEN", "FakeToken");
		proj.AddBuildProperty (targetGuid, "OTHER_LDFLAGS", "-ObjC");
		proj.AddBuildProperty (targetGuid, "OTHER_LDFLAGS", "-all_load");

		proj.AddFrameworkToProject (targetGuid, "SystemConfiguration.framework", false);
		proj.AddFrameworkToProject (targetGuid, "CoreGraphics.framework", false);
		proj.AddFrameworkToProject (targetGuid, "CoreTelephony.framework", false);
		proj.AddFrameworkToProject (targetGuid, "CFNetwork.framework", false);
		proj.AddFrameworkToProject (targetGuid, "UserNotifications.framework", false);
		proj.AddFrameworkToProject (targetGuid, "libsqlite3.tbd", false);
		proj.AddFrameworkToProject (targetGuid, "libstdc++.tbd", false);
		proj.AddFrameworkToProject (targetGuid, "libz.tbd", false);
		proj.AddFrameworkToProject (targetGuid, "libopencore-amrnb.a", false);
		proj.AddFrameworkToProject (targetGuid, "libopencore-amrwb.a", false);
		proj.AddFrameworkToProject (targetGuid, "AssetsLibrary.framework", false);
		proj.AddFrameworkToProject (targetGuid, "StoreKit.framework", false);
		proj.AddFrameworkToProject (targetGuid, "AuthenticationServices.framework", false);
		proj.AddFrameworkToProject (targetGuid, "Security.framework", false);

		proj.AddCapability(targetGuid, PBXCapabilityType.InAppPurchase);
		proj.AddCapability(targetGuid, PBXCapabilityType.PushNotifications);
		proj.AddCapability(targetGuid, PBXCapabilityType.SignInWithApple);
		proj.AddCapability(targetGuid, PBXCapabilityType.AssociatedDomains);

		proj.AddFile(targetName + "/" + "jyjjddz.entitlements", "jyjjddz.entitlements");
		proj.AddBuildProperty(targetGuid, "CODE_SIGN_ENTITLEMENTS", targetName + "/" + "jyjjddz.entitlements");

		//proj.SetBuildProperty(targetGuid, "CODE_SIGN_IDENTITY", "");

		File.WriteAllText (projPath, proj.WriteToString ());

		//var entitlements = new ProjectCapabilityManager(projPath, "jyjjddz.entitlements", targetName);
		//entitlements.AddAssociatedDomains(new string[] { "applinks:game-support.jyhd919.cn" });
		//entitlements.WriteToFile();

		Debug.Log("MainIOSTS OK: " + targetName);

#endif
	}
}
