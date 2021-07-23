package com.wuye.watermark;

import android.content.Context;

public class FileUtils {
	public static String getDiskCachePath(Context context) {
		return context.getCacheDir().getPath();
	}
}
