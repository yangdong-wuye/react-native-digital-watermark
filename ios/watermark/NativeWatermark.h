//
//  NativeWatermark.h
//  NativeWatermark
//
//  Created by wuye on 2020/7/31.
//  Copyright © 2020 dabank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Watermark.mm"

@interface NativeWatermark : NSObject

// 图片添加水印
+ (long) buildWatermark:(NSString *)inputPath
             outputPath: (NSString *) outputPath
                   text:(NSString *)text;

// 图片提取水印
+ (long) detectWatermark:(NSString *)inputPath
              outputPath: (NSString *) outputPath;
@end
