//
//  FNReadParser.m
//  FortuneNovel
//
//  Created by VictorZhang on 2020/10/15.
//
// 源码来自：https://github.com/yuenov/reader-api
//         https://github.com/yuenov/reader-ios
// 这是一个开源的小说平台

#import "FNReadParser.h"
#import "FNReadConfig.h"
#import <CoreText/CoreText.h>

@implementation FNReadParser


+ (NSArray<NSNumber *> *)pagingContent:(NSString *)content bounds:(CGRect)bounds attributedContent:(NSAttributedString **)attributedContent {
    NSMutableArray *pageArray = [NSMutableArray array];
    CTFramesetterRef frameSetter;
    CGPathRef path;
      
    NSMutableAttributedString *contentAttr = [[NSMutableAttributedString alloc] initWithString:content];
    NSDictionary *contentAttribute = [FNReadParser parserFontArrribute:[FNReadConfig shared]];
    [contentAttr setAttributes:contentAttribute range:NSMakeRange(0, contentAttr.length)];
     
    frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) contentAttr);
    path = CGPathCreateWithRect(bounds, NULL);
    
    int currentOffset = 0;
    int currentInnerOffset = 0;
    BOOL hasMorePages = YES;
    // 防止死循环，如果在同一个位置获取CTFrame超过2次，则跳出循环
    int preventDeadLoopSign = currentOffset;
    int samePlaceRepeatCount = 0;
    
    while (hasMorePages) {
        if (preventDeadLoopSign == currentOffset) {
            ++samePlaceRepeatCount;
        } else {
            samePlaceRepeatCount = 0;
        }
        
        if (samePlaceRepeatCount > 1) {
            // 退出循环前检查一下最后一页是否已经加上
            if (pageArray.count == 0) {
                [pageArray addObject:@(currentOffset)];
            } else {
                
                NSUInteger lastOffset = [[pageArray lastObject] integerValue];
                
                if (lastOffset != currentOffset) {
                    [pageArray addObject:@(currentOffset)];
                }
            }
            break;
        }
        
        [pageArray addObject:@(currentOffset)];
        
        CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(currentInnerOffset, 0), path, NULL);
        CFRange range = CTFrameGetVisibleStringRange(frame);
        if ((range.location + range.length) != contentAttr.length) {
            
            currentOffset += range.length;
            currentInnerOffset += range.length;
            
        } else {
            // 已经分完，提示跳出循环
            hasMorePages = NO;
        }
        if (frame) CFRelease(frame);
    }
    
    CGPathRelease(path);
    CFRelease(frameSetter);
    
    *attributedContent = contentAttr;
    return pageArray.copy;
}

+ (NSDictionary *)parserFontArrribute:(FNReadConfig *)config {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSForegroundColorAttributeName] = config.fontColor;
    dict[NSFontAttributeName] = [UIFont systemFontOfSize:config.fontSize];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = config.lineSpacing;
    paragraphStyle.lineBreakMode = config.lineBreakMode;
    //paragraphStyle.alignment = config.alignment;
    //paragraphStyle.firstLineHeadIndent = config.firstLineHeadIndent
    //paragraphStyle.paragraphSpacing = config.lineSpacing+2;
    dict[NSParagraphStyleAttributeName] = paragraphStyle;
    return [dict copy];
}

+ (NSAttributedString *)getLabelAttributedStringWithContent:(NSString *)content {
    NSMutableAttributedString *contentAttr = [[NSMutableAttributedString alloc] initWithString:content];
    NSDictionary *contentAttribute = [FNReadParser parserFontArrribute:[FNReadConfig shared]];
    [contentAttr setAttributes:contentAttribute range:NSMakeRange(0, contentAttr.length)];
    return contentAttr;
}

@end
