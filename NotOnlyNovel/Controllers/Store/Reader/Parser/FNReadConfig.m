//
//  FNReadConfig.m
//  FortuneNovel
//
//  Created by VictorZhang on 2020/10/15.
//

#import "FNReadConfig.h"
#import "UIColor+Cat.h"

@implementation FNReadConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            _fontSize = 28;
            _lineSpacing = 12;
        } else {
            _fontSize = 18;
            _lineSpacing = 8;
        }
        _fontColor = [UIColor colorFromHex:0x646465];
        _brightness = 0.5;
        _lineBreakMode = NSLineBreakByWordWrapping; // NSLineBreakByCharWrapping;
        _alignment = NSTextAlignmentJustified;
    }
    return self;
}

+ (instancetype)shared {
    static FNReadConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[FNReadConfig alloc] init];
    });
    return config;
}

@end
