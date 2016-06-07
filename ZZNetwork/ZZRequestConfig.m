//
//  ZZRequestConfig.m
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

#import "ZZRequestConfig.h"
#import "ZZRequestDataCache.h"
//#import "ZZRequestGeneralParameters.h"

@interface ZZRequestConfig ()

@property (nonatomic, copy, readwrite) NSString *baseUrl;

@end

@implementation ZZRequestConfig

+ (ZZRequestConfig *)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSString *)baseUrl
{
    return @"https://api.douban.com/";
}

- (id<ZZDataCacheProtocol>)dataCache
{
    return [ZZRequestDataCache sharedInstance];
}

#warning 所有Api增加参数，可以实现返回实现这个ZZBuiltinParametersProtocol的类
//- (id<ZZBuiltinParametersProtocol>)builtinParametersManager
//{
//    return [ZZRequestGeneralParameters sharedInstance];
//}

@end
