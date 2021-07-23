package com.wuye;

import android.net.Uri;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.wuye.watermark.FileUtils;
import com.wuye.watermark.Watermark;

import java.io.File;
import java.util.UUID;

public class DigitalWatermarkModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;


    DigitalWatermarkModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "DigitalWatermark";
    }

    @ReactMethod
    public void buildWatermark(final String uri, final String text, final Promise promise) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    Uri file = Uri.parse(uri);
                    String src = file.getPath();

                    // 文件输出路径
                    String dst = FileUtils.getDiskCachePath(reactContext) + "/"+ UUID.randomUUID().toString() + ".jpg";

                    // 添加水印图
                    long result = Watermark.buildWatermark(src, dst, text);

                    if (result == 0) {
                        WritableMap map = Arguments.createMap();
                        map.putString("uri", Uri.fromFile(new File(dst)).toString());
                        map.putString("path", dst);
                        promise.resolve(map);
                    } else {
                        promise.reject(new Exception("build error"));
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                    promise.reject(ex);
                }
            }
        }).start();
    }

    @ReactMethod
    public void detectWatermark(final String uri, final Promise promise) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    Uri file = Uri.parse(uri);
                    String src = file.getPath();

                    // 文件输出路径
                    String dst = FileUtils.getDiskCachePath(reactContext) + "/"+ UUID.randomUUID().toString() + ".jpg";

                    // 提取水印
                    long result = Watermark.extractingWatermark(src, dst);

                    if (result == 0) {
                        WritableMap map = Arguments.createMap();
                        map.putString("uri", Uri.fromFile(new File(dst)).toString());
                        map.putString("path", dst);
                        promise.resolve(map);
                    } else {
                        promise.reject(new Exception("detect error"));
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                    promise.reject(ex);
                }
            }
        }).start();
    }
}
