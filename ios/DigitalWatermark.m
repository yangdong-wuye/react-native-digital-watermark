#import "DigitalWatermark.h"
#import "NativeWatermark.h"
#import "DateUtils.h"

#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#import <React/RCTImageLoader.h>
#else
#import "RCTBridgeModule.h"
#import "RCTImageLoader.h"
#endif

@implementation DigitalWatermark

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE()

// 添加水印
RCT_EXPORT_METHOD(buildWatermark:(NSString *)iUri
                  text:(NSString *)text
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    // 加载照片
    RCTImageLoader *loader = [self.bridge moduleForName:@"ImageLoader" lazilyLoadIfNecessary:YES];
    NSURLRequest *request = [RCTConvert NSURLRequest: iUri];
    
    [loader loadImageWithURLRequest:request callback:^(NSError *error, UIImage *image) {
        if (error) {
            reject(@"build error", @"build error", NULL);
            return;
        }
        CGSize newSize = CGSizeMake(image.size.width, image.size.height);
        UIImage *newImage = resizeImage(image, newSize);
        // 缓存路径
         NSString* cachePath =NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES).firstObject;
        // 输入路径
        NSString* inputPath = [NSString stringWithFormat:@"%@/%@.jpg", cachePath, getNowTimeTimestamp()];
        [UIImagePNGRepresentation(newImage) writeToFile:inputPath atomically:YES];
        
        // 输出路径
        NSString *outputPath = [NSString stringWithFormat:@"%@/%@.jpg", cachePath, getNowTimeTimestamp()];
        
        long result = [NativeWatermark buildWatermark:(inputPath) outputPath:(outputPath) text:(text)];
        
        if (result == 0) {
            NSMutableDictionary *retDict = [NSMutableDictionary dictionaryWithCapacity: 2];
            retDict[@"uri"] = [[NSURL fileURLWithPath:outputPath] absoluteString];
            retDict[@"path"] = outputPath;
            resolve(retDict);
        } else {
            reject(@"build error", @"build error", NULL);
        }
    }];
}

// 提取水印
RCT_EXPORT_METHOD(detectWatermark:(NSString *)iUri
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    
    // 加载照片
    RCTImageLoader *loader = [self.bridge moduleForName:@"ImageLoader" lazilyLoadIfNecessary:YES];
    NSURLRequest *request = [RCTConvert NSURLRequest: iUri];
    [loader loadImageWithURLRequest:request callback:^(NSError *error, UIImage *image) {
        if (error) {
            reject(@"build error", @"build error", NULL);
            return;
        }
        // 缓存路径
        NSString* cachePath =NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES).firstObject;
        
        // 输入路径
        NSString* inputPath = [NSString stringWithFormat:@"%@/%@.jpg", cachePath, getNowTimeTimestamp()];
        [UIImagePNGRepresentation(image) writeToFile:inputPath atomically:YES];
        
        // 输出路径
        NSString *outputPath = [NSString stringWithFormat:@"%@/%@.png", cachePath, getNowTimeTimestamp()];
        
        long result = [NativeWatermark detectWatermark:(inputPath) outputPath:(outputPath)];
        
        if (result == 0) {
            // 删除图片
            [[NSFileManager defaultManager] fileExistsAtPath: inputPath];
            
            NSMutableDictionary *retDict = [NSMutableDictionary dictionaryWithCapacity: 2];
            retDict[@"uri"] = [[NSURL fileURLWithPath:outputPath] absoluteString];
            retDict[@"path"] = outputPath;
            resolve(retDict);
        } else {
            reject(@"build error", @"build error", NULL);
        }
    }];
}

UIImage* resizeImage (UIImage* image, CGSize toSize)
{

    CGSize imageSize = CGSizeMake(image.size.width * image.scale, image.size.height * image.scale);

    float scale = getResizeForProportionalResize(imageSize, toSize, false, false);

    CGSize newSize = CGSizeMake(roundf(imageSize.width * scale), roundf(imageSize.height * scale));


    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
float getResizeForProportionalResize( CGSize theSize, CGSize intoSize, bool onlyScaleDown, bool maximize )
{
    float    sx = theSize.width;
    float    sy = theSize.height;
    float    dx = intoSize.width;
    float    dy = intoSize.height;
    float    scale    = 1;

    if( sx != 0 && sy != 0 )
    {
        dx    = dx / sx;
        dy    = dy / sy;

        // if maximize is true, take LARGER of the scales, else smaller
        if( maximize )        scale    = (dx > dy)    ? dx : dy;
        else                scale    = (dx < dy)    ? dx : dy;

        if( scale > 1 && onlyScaleDown )    // reset scale
            scale    = 1;
    }
    else
    {
        scale     = 0;
    }
    return scale;
}
@end
