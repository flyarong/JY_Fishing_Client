﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class System_Diagnostics_StopwatchWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(System.Diagnostics.Stopwatch), typeof(System.Object));
		L.RegFunction("GetTimestamp", GetTimestamp);
		L.RegFunction("StartNew", StartNew);
		L.RegFunction("Reset", Reset);
		L.RegFunction("Start", Start);
		L.RegFunction("Stop", Stop);
		L.RegFunction("New", _CreateSystem_Diagnostics_Stopwatch);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("Frequency", get_Frequency, null);
		L.RegVar("IsHighResolution", get_IsHighResolution, null);
		L.RegVar("Elapsed", get_Elapsed, null);
		L.RegVar("ElapsedMilliseconds", get_ElapsedMilliseconds, null);
		L.RegVar("ElapsedTicks", get_ElapsedTicks, null);
		L.RegVar("IsRunning", get_IsRunning, null);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateSystem_Diagnostics_Stopwatch(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				System.Diagnostics.Stopwatch obj = new System.Diagnostics.Stopwatch();
				ToLua.PushObject(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: System.Diagnostics.Stopwatch.New");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetTimestamp(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 0);
			long o = System.Diagnostics.Stopwatch.GetTimestamp();
			LuaDLL.tolua_pushint64(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int StartNew(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 0);
			System.Diagnostics.Stopwatch o = System.Diagnostics.Stopwatch.StartNew();
			ToLua.PushObject(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Reset(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			System.Diagnostics.Stopwatch obj = (System.Diagnostics.Stopwatch)ToLua.CheckObject<System.Diagnostics.Stopwatch>(L, 1);
			obj.Reset();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Start(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			System.Diagnostics.Stopwatch obj = (System.Diagnostics.Stopwatch)ToLua.CheckObject<System.Diagnostics.Stopwatch>(L, 1);
			obj.Start();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Stop(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			System.Diagnostics.Stopwatch obj = (System.Diagnostics.Stopwatch)ToLua.CheckObject<System.Diagnostics.Stopwatch>(L, 1);
			obj.Stop();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Frequency(IntPtr L)
	{
		try
		{
			LuaDLL.tolua_pushint64(L, System.Diagnostics.Stopwatch.Frequency);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_IsHighResolution(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushboolean(L, System.Diagnostics.Stopwatch.IsHighResolution);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Elapsed(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			System.Diagnostics.Stopwatch obj = (System.Diagnostics.Stopwatch)o;
			System.TimeSpan ret = obj.Elapsed;
			ToLua.PushValue(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Elapsed on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_ElapsedMilliseconds(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			System.Diagnostics.Stopwatch obj = (System.Diagnostics.Stopwatch)o;
			long ret = obj.ElapsedMilliseconds;
			LuaDLL.tolua_pushint64(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index ElapsedMilliseconds on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_ElapsedTicks(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			System.Diagnostics.Stopwatch obj = (System.Diagnostics.Stopwatch)o;
			long ret = obj.ElapsedTicks;
			LuaDLL.tolua_pushint64(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index ElapsedTicks on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_IsRunning(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			System.Diagnostics.Stopwatch obj = (System.Diagnostics.Stopwatch)o;
			bool ret = obj.IsRunning;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index IsRunning on a nil value");
		}
	}
}

