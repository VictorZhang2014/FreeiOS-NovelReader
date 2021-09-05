//
//  NSData+AES128.m
//  NotOnlyNovel
//
//  Created by 徐可 on 2021/1/4.
//

#import "NSData+AES128.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation NSData (AES128)

//解密
- (NSString *)AES128DecryptWithKey:(NSString *)key iv:(NSString *)iv

{

    return [self AES128Operation:kCCDecrypt key:key iv:iv];

}

- (NSString *)AES128Operation:(CCOperation)operation key:(NSString *)key iv:(NSString *)iv

{

    char keyPtr[kCCKeySizeAES128 + 1];

    memset(keyPtr, 0, sizeof(keyPtr));

    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];

    

    char ivPtr[kCCBlockSizeAES128 + 1];

    memset(ivPtr, 0, sizeof(ivPtr));

    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];

    

    NSUInteger dataLength = [self length];

    size_t bufferSize = dataLength + kCCBlockSizeAES128;

    void *buffer = malloc(bufferSize);

    

    size_t numBytesCrypted = 0;

    CCCryptorStatus cryptStatus = CCCrypt(operation,

                                          kCCAlgorithmAES128,

                                          kCCOptionPKCS7Padding,

                                          keyPtr,

                                          kCCBlockSizeAES128,

                                          ivPtr,

                                          [self bytes],

                                          dataLength,

                                          buffer,

                                          bufferSize,

                                          &numBytesCrypted);

    if (cryptStatus == kCCSuccess) {

        NSData *ret = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
        NSString *string = [[NSString alloc] initWithData:ret encoding:NSUTF8StringEncoding];
        return string;

    }

    free(buffer);

    return nil;

}


@end
