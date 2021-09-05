//
//  FNReadConfig.h
//  FortuneNovel
//
//  Created by VictorZhang on 2020/10/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FNReadConfig : NSObject

@property (nonatomic, assign) CGFloat lineSpacing; //行间距
@property (nonatomic, assign) CGFloat fontSize;  //字体大小
//@property (nonatomic,strong) NSString *fontName;    //字体名称
@property (nonatomic, strong) UIColor *fontColor;    //字体颜色
//@property (nonatomic,assign) CGFloat chapterFontSize;   //标题字体大小
//@property (nonatomic,assign) CGFloat chapterLineSpace;  //标题行间距
//@property (nonatomic,assign) CGFloat firstLineHeadIndent;  //首行缩紧
@property (nonatomic, assign) CGFloat brightness;        //屏幕亮度
@property (nonatomic, assign) NSLineBreakMode lineBreakMode; // 断行，折行模式
@property (nonatomic, assign) NSTextAlignment alignment; // 对其方式

+ (instancetype)shared;

@end

NS_ASSUME_NONNULL_END
