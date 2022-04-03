using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using LuaInterface;

public class ComAnimatorEvent : MonoBehaviour
{
    LuaFunction _Call;
    public LuaFunction onCall
    {
        get
        {
            return _Call;
        }
        set
        {
            _Call = value;
        }
    }
    LuaFunction _CallDestroy;
    public LuaFunction onDestroy
    {
        get
        {
            return _CallDestroy;
        }
        set
        {
            _CallDestroy = value;
        }
    }
 
    int i_s = 0;
    public void CallIntStr(string _str)
    {
        i_s++;
        if (this.onCall != null)
        {
            this.onCall.Call(i_s, _str);
        }
    }

    protected void OnDestroy()
    {
        if (this.onDestroy != null)
        {
            this.onDestroy.Call();
        }
    }
}
