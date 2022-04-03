package com.qq.e.union.demo;

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import com.qq.e.ads.nativ.NativeExpressADView;

public class UnionAdViewManager {

    private static volatile UnionAdViewManager sInstance;

    private final Handler handler = new Handler(Looper.getMainLooper());

    private UnionAdViewManager() {

    }

    public static UnionAdViewManager getInstance() {
        if (sInstance == null) {
            synchronized (UnionAdViewManager.class) {
                if (sInstance == null) {
                    sInstance = new UnionAdViewManager();
                }
            }
        }
        return sInstance;
    }

    public void showAdView(final Activity context, final View adView, boolean isWrapContent) {
        if (context == null || adView == null) {
            return;
        }
        handler.post(new Runnable() {
            @Override
            public void run() {
                FrameLayout.LayoutParams lp;
                if (isWrapContent) {
                    lp = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                } else {
                    lp = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
                }
                lp.gravity = Gravity.CENTER | Gravity.BOTTOM;
                addAdView(context, adView, lp);
            }
        });
    }

    private void addAdView(Activity context, View adView, ViewGroup.LayoutParams layoutParams) {
        if (context == null || adView == null || layoutParams == null) {
            return;
        }
        ViewGroup group = getRootLayout(context);
        if (group == null) {
            return;
        }
        group.addView(adView, layoutParams);
    }

    private void removeAdView(Activity context, View adView) {
        if (context == null || adView == null) {
            return;
        }
        handler.post(new Runnable() {

            @Override
            public void run() {
                ViewGroup group = getRootLayout(context);
                if (group == null) {
                    return;
                }
                group.removeView(adView);
            }
        });
    }

    public ViewGroup newFrameLayout(Activity context) {
        FrameLayout layout = new FrameLayout(context);
        return layout;
    }

    private ViewGroup getRootLayout(Activity context) {
        if (context == null) {
            return null;
        }
        return context.findViewById(android.R.id.content);
    }
}
