using UnityEngine;
using System.Collections;
using DG.Tweening;
using System;
using LuaInterface;
using System.Threading;
using System.Collections.Generic;

namespace LuaFramework
{
    /// <summary>
    /// </summary>
    public class Main : MonoBehaviour
    {
        public struct MainQueueItem
        {
            public string _coid_id;
            public string _msg;
            public LuaFunction _call;

            public MainQueueItem(string coid_id, string msg, LuaFunction call)
            {
                _coid_id = coid_id;
                _msg = msg;
                _call = call;
            }
        }

        public static Mutex mainQueueMutex = new Mutex();
        public static Queue<MainQueueItem> mainMsgQueue = new Queue<MainQueueItem>();

        public static void LuaCallBack(string msg,LuaFunction _call,string _coid_id)
        {
            if (_call != null)
            {
                mainQueueMutex.WaitOne();
                mainMsgQueue.Enqueue(new MainQueueItem(_coid_id, msg, _call));
                mainQueueMutex.ReleaseMutex();
            }
        }
        public static long GetTimeStamp(bool bflag)
        {
            TimeSpan ts = DateTime.UtcNow - new DateTime(1970, 1, 1, 0, 0, 0, 0);
            long ret;
            if (bflag)
                ret = Convert.ToInt64(ts.TotalSeconds);
            else
                ret = Convert.ToInt64(ts.TotalMilliseconds);

            return ret;
        }
        

        void Awake() {
			DontDestroyOnLoad (this);
			Application.targetFrameRate = 60;
            DOTween.Init(true, true);
        }

        void Start()
        {
            AppFacade.Instance.StartUp();   //启动游戏
        }

        //焦点转移
        void OnApplicationFocus(bool isFocus)
        {
// #if UNITY_EDITOR
// #else
            //if (isFocus)
            //{
            //    Debug.LogFormat("OnApplicationFocus :{0}", isFocus);
            //    Util.CallMethod("MainModel", "OnForeGround");
            //}
            //else
            //{
            //    Debug.LogFormat("OnApplicationFocus :{0}", isFocus);
            //    Util.CallMethod("MainModel", "OnBackGround");
            //}
// #endif
        }

        //前后台
        void OnApplicationPause(bool isPause)
        {
            if(isPause)
            {
                Debug.LogErrorFormat("OnApplicationPause :{0}", isPause);
                Util.CallMethod("MainModel", "OnBackGround");
            }
            else
            {
                Debug.LogErrorFormat("OnApplicationPause :{0}", isPause);
                Util.CallMethod("MainModel", "OnForeGround");
            }

			GameManager gameMgr = AppFacade.Instance.GetManager<GameManager> (ManagerName.Game);
			if (gameMgr) {
				if (isPause)
					gameMgr.HandleOnBackGround ();
				else
					gameMgr.HandleOnForeGround ();
			}
        }
        void FixedUpdate()
        {
             DealYLHAd();  
        }

        long lastQueueYLHAdCall = 0;
        void DealYLHAd()
        {
            long _now = GetTimeStamp(false);
            if (_now - lastQueueYLHAdCall < 50) return;

            MainQueueItem mqi = new MainQueueItem();
            bool hasItem = false;
            mainQueueMutex.WaitOne();

            if (mainMsgQueue != null && mainMsgQueue.Count > 0)
            {
                mqi = mainMsgQueue.Dequeue();
                if (mqi._call != null)
                {
                    hasItem = true;
                }
            }
            mainQueueMutex.ReleaseMutex();
            lastQueueYLHAdCall = _now;
            if (hasItem)
            {
                mqi._call.Call(mqi._coid_id, mqi._msg);
            }
        }     
    }
}