//
//  ZZRequestDataCache.m
//
//  Copyright (C) 2016年.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//
//

#import "ZZRequestDataCache.h"
#import <CommonCrypto/CommonDigest.h>

@implementation ZZRequestDataCache
{
    NSFileManager *_fileManager;
    NSString *_cacheBasePath;
}

+ (ZZRequestDataCache *)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _fileManager = [NSFileManager defaultManager];
        _cacheBasePath = [self getCacheBasePath];
    }
    return self;
}

- (void)setObject:(id)object forkey:(NSString *)key
{
    if (object)
    {
        NSString *path = [self pathFromFileName:key];
        BOOL result = [NSKeyedArchiver archiveRootObject:object toFile:path];
        if (!result) {
            NSLog(@"缓存数据写入失败");
        }
    }
}

- (id)objectForKey:(NSString *)key
{
    if ([self containsObjectForKey:key])
    {
        NSString *path = [self pathFromFileName:key];
        return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    }
    return nil;
}

- (BOOL)containsObjectForKey:(NSString *)key
{
    NSString *path = [self pathFromFileName:key];
    return [_fileManager fileExistsAtPath:path];
}

- (NSDate *)objectLastDate:(NSString *)key
{
    NSString *path = [self pathFromFileName:key];
    NSError *error = nil;
    NSDictionary *attributes = [_fileManager attributesOfItemAtPath:path error:&error];
    if (error) {
        return nil;
    }
    
    return [attributes fileModificationDate];
}

#pragma mark -
#pragma mark - create base path
- (NSString *)getCacheBasePath
{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *basePath = [cachePath stringByAppendingPathComponent:@"ZZNetwork"];
    [self checkPath:basePath];
    return basePath;
}

- (void)checkPath:(NSString *)path {
    BOOL isDir;
    if (![_fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self createPath:path];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [_fileManager removeItemAtPath:path error:&error];
            if (error) {
                NSLog(@"error in removing file：%@", error.localizedDescription);
            }
            [self createPath:path];
        }
    }
}

- (void)createPath:(NSString *)path
{
    NSError *error = nil;
    [_fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        NSLog(@"error in creating cache folder:%@", error.localizedDescription);
    } else {
        [self addDoNotBackupAttribute:path];
    }
}

#pragma mark -
#pragma mark - tool
- (void)addDoNotBackupAttribute:(NSString *)path
{
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (error) {
        NSLog(@"error in set back up attribute: %@", error.localizedDescription);
    }
}

- (NSString *)md5String:(NSString *)string
{
    if (string.length <= 0) {
        return nil;
    }
    
    const char *value = [string UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

- (NSString *)pathFromFileName:(NSString *)fileName
{
    NSString *md5FileName = [self md5String:fileName];
    NSString *path = [_cacheBasePath stringByAppendingPathComponent:md5FileName];
    return path;
}

@end
