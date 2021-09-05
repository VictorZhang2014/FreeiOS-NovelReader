//
//  FNReadParser.h
//  FortuneNovel
//
//  Created by VictorZhang on 2020/10/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FNReadConfig;
@interface FNReadParser : NSObject

+ (NSArray<NSNumber *> *)pagingContent:(NSString *)content bounds:(CGRect)bounds attributedContent:(NSAttributedString *_Nullable*_Nullable)attributedContent;

+ (NSDictionary *)parserFontArrribute:(FNReadConfig *)config;

+ (NSAttributedString *)getLabelAttributedStringWithContent:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
