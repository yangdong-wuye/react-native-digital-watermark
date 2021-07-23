//
//  NativeWatermark.m
//  NativeWatermark
//
//  Created by wuye on 2020/7/31.
//  Copyright © 2020 dabank. All rights reserved.
//

#import "NativeWatermark.h"

@implementation NativeWatermark

+ (long) buildWatermark:(NSString *)inputPath
             outputPath:(NSString *)outputPath
                   text:(NSString *)text {
    long result = nativeCode([inputPath UTF8String], [outputPath UTF8String], [text UTF8String]);
    return result;
}

+ (long) detectWatermark:(NSString *)inputPath
             outputPath:(NSString *)outputPath {
    long result = nativeDecode([inputPath UTF8String], [outputPath UTF8String]);
    return result;
}

@end
