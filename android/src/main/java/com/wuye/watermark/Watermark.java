package com.wuye.watermark;

public class Watermark {
	static {
		System.loadLibrary("Watermark");
	}

	public static native long buildWatermark(String src, String dst, String text);

	public static native long extractingWatermark(String src, String dst);
}
