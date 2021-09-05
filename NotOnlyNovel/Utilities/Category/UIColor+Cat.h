//
//  UIColor+Cat.h
//  FortuneNovel
//
//  Created by Johnny Cheung on 2020/10/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Cat)

+ (UIColor *)colorFromHex:(unsigned long)hex;
+ (UIColor *)colorFromHex:(unsigned long)hex alpha:(float)alpha;

// 十六进制字符串 @"#F3F3F3"
+ (UIColor *)colorWithHexString: (NSString *)color;

@end

NS_ASSUME_NONNULL_END
