
#import <Foundation/Foundation.h>

@interface NSDate (TimeAgo)
- (NSString *) timeAgoSimple;
- (NSString *) timeAgo;
- (NSString *) timeAgoWithLimit:(NSTimeInterval)limit;
- (NSString *) timeAgoWithLimit:(NSTimeInterval)limit dateFormat:(NSDateFormatterStyle)dFormatter andTimeFormat:(NSDateFormatterStyle)tFormatter;
- (NSString *) timeAgoWithLimit:(NSTimeInterval)limit dateFormatter:(NSDateFormatter *)formatter;


// this method only returns "{value} {unit} ago" strings and no "yesterday"/"last month" strings
- (NSString *)dateTimeAgo;

// 在私信聊天消息里使用
// 比如：今天 10:12 AM，昨天12:12 PM
- (NSString *)dateTimeAgoInPrivateMessage;

// 粗略的日期显示
// 比如: minute ago, hours ago, days ago, weeks ago
- (NSString *)dateTimeAgoRoughly;

// this method gives when possible the date compared to the current calendar date: "this morning"/"yesterday"/"last week"/..
// when more precision is needed (= less than 6 hours ago) it returns the same output as dateTimeAgo
- (NSString *)dateTimeUntilNow;

// 返回例如：2021-03-31
- (NSString *)getYearMonthDayString;

@end



@interface NSString (TimeStamp)

- (NSString *)timeAgo;

@end

