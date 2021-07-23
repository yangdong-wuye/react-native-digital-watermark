//
//  DateUtils.m
//  react-native-digital-watermark
//
//  Created by wuye on 2020/7/31.
//

#import <DateUtils.h>

NSString* getNowTimeTimestamp(){

    NSDate *datenow = [NSDate date];

    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([datenow timeIntervalSince1970]*1000)];

    return timeSp;
}
