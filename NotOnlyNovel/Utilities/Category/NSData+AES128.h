//
//  NSData+AES128.h
//  NotOnlyNovel
//
//  Created by 徐可 on 2021/1/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (AES128)

- (NSString *)AES128DecryptWithKey:(NSString *)key iv:(NSString *)iv;

@end

NS_ASSUME_NONNULL_END
