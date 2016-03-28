//
//  ZZRequest.m
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

#import "ZZRequest.h"

#import "ZZRequestConfig.h"

@implementation ZZRequest
{
    id _dataCacheManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.shouldIgnoreCache = NO;
        self.shouldCacheResponse = NO;
        
        _dataCacheManager = [ZZRequestConfig sharedInstance].dataCache;
    }
    return self;
}

- (NSInteger)cacheTimeInSeconds
{
    return -1;
}

- (NSString *)cacheFileName
{
    ZZRequestMethod method = [self requestMethod];
    NSString *baseURL = [self baseUrl];
    NSString *requestURL = [self requestUrl];
    NSString *fileName = [NSString stringWithFormat:@"method_%ld_host_%@_url:%@", (long)method, baseURL, requestURL];
    return fileName;
}

#pragma mark -
#pragma mark - overwrite
- (void)start
{
    // 忽略缓存
    if (self.shouldIgnoreCache)
    {
        [super start];
        return;
    }
    
    // 缓存时间小于0，不缓存
    if ([self cacheTimeInSeconds] <= 0)
    {
        [super start];
        return;
    }
    
    // 缓存不存在的话，加载网络请求
    if (![_dataCacheManager containsObjectForKey:[self cacheFileName]])
    {
        [super start];
        return;
    }
    
    // 缓存失效的情况下，
    if ([self cacheInvalidation])
    {
        [super start];
        return;
    }
    
    //  加载缓存数据
    [self startLoadCacheData];
}


- (void)startLoadCacheData
{
    self.responseObject = [_dataCacheManager objectForKey:[self cacheFileName]];
    
    if (self.error) {
        if (self.failureCompletionBlock) {
            self.failureCompletionBlock(self, [self.error domain]);
        }
        
        if ([self.delegate respondsToSelector:@selector(requestDidFinished:error:)]) {
            [self.delegate requestDidFinished:self error:[self.error domain]];
        }
        
    }
    else
    {
        if (self.successCompletionBlock)
        {
            self.successCompletionBlock(self, self.responseObject);
        }
        
        if ([self.delegate respondsToSelector:@selector(requestDidFinished:error:)]) {
            [self.delegate requestDidFinished:self error:[self.error domain]];
        }
    }
    
    [super clearCompletionBlock];
    
}

// 网络请求成功后，缓存本地数据
- (void)requestCompleteSuccess
{
    if(!self.shouldCacheResponse)
    {
        return;
    }
    
    if ([self cacheTimeInSeconds] > 0)
    {
        [_dataCacheManager setObject:self.responseObject forkey:[self cacheFileName]];
    }
}

// 缓存是否失效
- (BOOL)cacheInvalidation
{
    NSDate *fileLastDate = [_dataCacheManager objectLastDate:[self cacheFileName]];
    NSTimeInterval fileTimeInterval = -[fileLastDate timeIntervalSinceNow];
    NSTimeInterval cacheTimeInterval = [self cacheTimeInSeconds];
    
    BOOL result = cacheTimeInterval < fileTimeInterval ? YES: NO;
    
    return result;
}

@end
