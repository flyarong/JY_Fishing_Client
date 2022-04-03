
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using ByteDance.Union;

public class RewardADMgr {
	private static RewardADMgr m_instance;
	public static RewardADMgr Instance {
		get {
			if (m_instance == null)
				m_instance = new RewardADMgr ();
			return m_instance;
		}
	}

	public static LuaFunction rewardVideoAdListenerCallback;
	public static LuaFunction onErrorCallback;
	public static LuaFunction onRewardVideoAdLoadCallback;
	public static LuaFunction onRewardVideoCachedCallback;
	public static LuaFunction rewardAdInteractionListenerCallback;
	public static LuaFunction onAdShowCallback;
	public static LuaFunction onAdVideoBarClickCallback;
	public static LuaFunction onAdCloseCallback;
	public static LuaFunction onVideoCompleteCallback;
	public static LuaFunction onVideoErrorCallback;
	public static LuaFunction onRewardVerifyCallback;


	internal class Unit
	{
		public string codeID;
		#if UNITY_IOS
		public ExpressRewardVideoAd rewardVideoAd;
		#else
		public RewardVideoAd rewardVideoAd;
		#endif


		public Unit(string codeID) {
			this.codeID = codeID;
		}

		public void Prepare(string rewardName, int rewardAmount, string userID, string extraData, int width, int height, LuaFunction callback) {
			var adSlot = new AdSlot.Builder ()
				.SetCodeId (codeID)
				.SetSupportDeepLink (true)
				.SetImageAcceptedSize (width, height)
				.SetExpressViewAcceptedSize(width, height)
				.SetRewardName (rewardName)
				.SetRewardAmount (rewardAmount)
				.SetUserID (userID)
				.SetMediaExtra (extraData)
				.SetOrientation (AdOrientation.Horizontal)
				.Build ();
			#if UNITY_IOS
				RewardADMgr.Instance.adNative.LoadExpressRewardAd (adSlot, new RewardVideoAdListener (this));
			#else
				RewardADMgr.Instance.adNative.LoadRewardVideoAd (adSlot, new RewardVideoAdListener (this));
			#endif
		}

		public void Play(LuaFunction callback) {
			if (rewardVideoAd == null) {
				callback.Call (codeID, -1);
				Debug.LogError(string.Format("[AD] play({0}) rewardVideoAd invalid", codeID));
				return;
			}
			rewardVideoAd.ShowRewardVideoAd ();
		}

		public void Dispose() {
			if (rewardVideoAd != null) {
				rewardVideoAd.Dispose ();
				rewardVideoAd = null;
			}
			codeID = string.Empty;
		}
	}

	public static void RewardVideoAdListenerCallback (string codeID,int result) {
		if (rewardVideoAdListenerCallback != null)
			rewardVideoAdListenerCallback.Call (codeID, result);
	}

	public static void OnErrorCallback (string codeID,int code, string message) {
		if (onErrorCallback != null)
			onErrorCallback.Call (codeID, code,message);
	}

	public static void OnRewardVideoAdLoadCallback (string codeID,int result) {
		if (onRewardVideoAdLoadCallback != null)
			onRewardVideoAdLoadCallback.Call (codeID, result);
	}

	public static void OnRewardVideoCachedCallback (string codeID,int result) {
		if (onRewardVideoCachedCallback != null)
			onRewardVideoCachedCallback.Call (codeID, result);
	}

	public static void RewardAdInteractionListenerCallback (string codeID,int result) {
		if (rewardAdInteractionListenerCallback != null)
			rewardAdInteractionListenerCallback.Call (codeID, result);
	}

	public static void OnAdShowCallback (string codeID,int result) {
		if (onAdShowCallback != null)
			onAdShowCallback.Call (codeID, result);
	}

	public static void OnAdVideoBarClickCallback (string codeID,int result) {
		if (onAdVideoBarClickCallback != null)
			onAdVideoBarClickCallback.Call (codeID, result);
	}

	public static void OnAdCloseCallback (string codeID,int result) {
		if (onAdCloseCallback != null)
			onAdCloseCallback.Call (codeID, result);
	}

	public static void OnVideoCompleteCallback (string codeID,int result) {
		if (onVideoCompleteCallback != null)
			onVideoCompleteCallback.Call (codeID, result);
	}

	public static void OnVideoErrorCallback (string codeID,int result) {
		if (onVideoErrorCallback != null)
			onVideoErrorCallback.Call (codeID, result);
	}

	public static void OnRewardVerifyCallback (string codeID,int result,bool rewardVerify, int rewardAmount, string rewardName) {
		if (onRewardVerifyCallback != null)
			onRewardVerifyCallback.Call (codeID, result, rewardVerify, rewardAmount, rewardName);
	}

	private sealed class RewardVideoAdListener : IRewardVideoAdListener {
		private Unit unit;
		public RewardVideoAdListener(Unit unit) {
			this.unit = unit;
			RewardVideoAdListenerCallback(unit.codeID,0);
		}

		public void OnError(int code, string message)
		{
			OnErrorCallback(unit.codeID, code,message);
			Debug.LogError(string.Format("[AD] prepare({0}) error {1},{2}: ", unit.codeID, code, message));
		}

		public void OnRewardVideoAdLoad(RewardVideoAd ad)
		{
			#if !(UNITY_IOS)
			ad.SetRewardAdInteractionListener(
				new RewardAdInteractionListener(unit));
			ad.SetShowDownLoadBar (false);
			unit.rewardVideoAd = ad;
			OnRewardVideoAdLoadCallback(unit.codeID, 0);
			Debug.Log (string.Format ("[AD] prepare({0}) loaded", unit.codeID));
			#endif
		}

		public void OnRewardVideoCached()
		{
			OnRewardVideoCachedCallback(unit.codeID, 0);
			Debug.Log (string.Format ("[AD] prepare({0}) ok", unit.codeID));
		}
		public void OnExpressRewardVideoAdLoad(ExpressRewardVideoAd ad)
		{
			#if UNITY_IOS
			ad.SetRewardAdInteractionListener(
				new RewardAdInteractionListener(unit));
			unit.rewardVideoAd = ad;
			OnRewardVideoAdLoadCallback(unit.codeID, 0);
			Debug.Log (string.Format ("[AD] prepare({0}) loaded", unit.codeID));
			#endif
		}
	}

	private sealed class RewardAdInteractionListener : IRewardAdInteractionListener
	{
		private Unit unit;
		public RewardAdInteractionListener(Unit unit) {
			this.unit = unit;
			RewardAdInteractionListenerCallback(unit.codeID,0);
		}

		public void OnAdShow()
		{
			OnAdShowCallback(unit.codeID,0);
			Debug.Log("[AD] play ad show:" + unit.codeID);
		}

		public void OnAdVideoBarClick()
		{
			OnAdVideoBarClickCallback(unit.codeID,0);
			Debug.Log("[AD] play ad click:" + unit.codeID);
		}

		public void OnAdClose()
		{
			OnAdCloseCallback(unit.codeID,0);
			Debug.Log("[AD] play ad close:" + unit.codeID);
		}

		public void OnVideoComplete()
		{
			OnVideoCompleteCallback(unit.codeID,0);
			Debug.Log("[AD] play ad complete:" + unit.codeID);
		}

		public void OnVideoError()
		{
			OnVideoErrorCallback(unit.codeID,0);
			Debug.LogError("[AD] play ad error:" + unit.codeID);
		}

		public void OnRewardVerify(bool rewardVerify, int rewardAmount, string rewardName)
		{
			OnRewardVerifyCallback(unit.codeID,0,rewardVerify,rewardAmount,rewardName);
			Debug.Log("[AD] codeID:" + unit.codeID + " verify:" + rewardVerify + " name:" + rewardName + " amount:" + rewardAmount);
		}
	}

	public AdNative adNative;
	private List<Unit> adList;

	private Unit Find(string codeID, bool clear) {
		Unit unit;
		for (int idx = 0; idx < adList.Count; ++idx) {
			unit = adList [idx];
			if (unit.codeID == codeID) {
				if (clear)
					adList.RemoveAt (idx);
				return unit;
			}
		}
		return null;
	}

	public void SetupAD() {
		adNative = SDK.CreateAdNative ();
		adList = new List<Unit> ();
	}

	public void PrepareAD(string codeID, string rewardName, int rewardAmount, string userID, string extraData, int width, int height, LuaFunction callback) {
		if (adNative == null) {
			callback.Call (codeID, -1);
			return;
		}

		Unit unit = Find (codeID, true);
		if (unit != null)
			unit.Dispose ();

		unit = new Unit (codeID);
		adList.Add (unit);

		unit.Prepare (rewardName, rewardAmount, userID, extraData, width, height, callback);
	}

	public void PlayAD(string codeID, LuaFunction callback) {
		if (adNative == null) {
			callback.Call (codeID, -1);
			return;
		}

		Unit unit = Find (codeID, false);
		if (unit == null){
			callback.Call (codeID, -1);
			Debug.LogError ("[AD] It's not find ad:" + codeID);
		}
		else
			unit.Play (callback);
	}

	public void ClearAD(string codeID) {
		if (adNative == null)
			return;
		
		Unit unit = Find (codeID, true);
		if (unit != null)
			unit.Dispose ();
	}

	public void ClearAllAD() {
		if (adNative == null)
			return;

		for (int idx = 0; idx < adList.Count; ++idx)
			adList [idx].Dispose ();
		adList.Clear ();
	}

	public void AddRewardVideoAdListener (LuaFunction RewardVideoAdListener,
											LuaFunction OnError,
											LuaFunction OnRewardVideoAdLoad,
											LuaFunction OnRewardVideoCached)
	{
		rewardVideoAdListenerCallback = RewardVideoAdListener;
		onErrorCallback = OnError;
		onRewardVideoAdLoadCallback = OnRewardVideoAdLoad;
		onRewardVideoCachedCallback = OnRewardVideoCached;
	}

	public void RemoveRewardVideoAdListener(){
		rewardVideoAdListenerCallback = null;
		onErrorCallback = null;
		onRewardVideoAdLoadCallback = null;
		onRewardVideoCachedCallback = null;
	}

	public void AddRewardAdInteractionListener(LuaFunction RewardAdInteractionListener,
												LuaFunction OnAdShowCallback,
												LuaFunction OnAdVideoBarClickCallback, 
												LuaFunction OnAdCloseCallback, 
												LuaFunction OnVideoCompleteCallback,
												LuaFunction OnVideoErrorCallback,
												LuaFunction OnRewardVerifyCallback)
	{
		rewardAdInteractionListenerCallback = RewardAdInteractionListener;
		onAdShowCallback = OnAdShowCallback;
		onAdVideoBarClickCallback = OnAdVideoBarClickCallback;
		onAdCloseCallback = OnAdCloseCallback;
		onVideoCompleteCallback = OnVideoCompleteCallback;
		onVideoErrorCallback = OnVideoErrorCallback;
		onRewardVerifyCallback = OnRewardVerifyCallback;
	}
	
	public void RemoveRewardAdInteractionListener(){
		rewardAdInteractionListenerCallback = null;
		onAdShowCallback = null;
		onAdVideoBarClickCallback = null;
		onAdCloseCallback = null;
		onVideoCompleteCallback = null;
		onVideoErrorCallback = null;
		onRewardVerifyCallback = null;
	}
}
