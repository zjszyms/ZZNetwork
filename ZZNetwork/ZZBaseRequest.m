//
//  ZZBaseRequest.m
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

#import "ZZBaseRequest.h"
#import "ZZRequestManager.h"

@interface ZZBaseRequest ()

// 服务端返回成功数据Block
@property (nonatomic, copy, readwrite) SuccessCompletionBlock successCompletionBlock;
// 服务端返回失败数据Block
@property (nonatomic, copy, readwrite) FailureCompletionBlock failureCompletionBlock;

@end

@implementation ZZBaseRequest

#pragma mark -
#pragma mark - main

- (void)start
{
    [[ZZRequestManager sharedInstance] startRequest:self];
}

- (void)stop
{
    [[ZZRequestManager sharedInstance] cancelRequest:self];
}

- (NSURLSessionTaskState)requestSessionTaskState
{
    return self.requestSessionTask.state;
}  

- (void)startRequestWithCompletionBlockWithSuccess:(SuccessCompletionBlock)success
                                            failue:(FailureCompletionBlock)failure
{
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
    
    [self start];
}

// 重写改方法会忽略配置里的baseUrl
- (NSString *)baseUrl
{
    return @"";
}

// 请求的Url路径
- (NSString *)requestUrl
{
    return @"";
}

// 请求参数
- (id)requestParameters
{
    return nil;
}

// 请求方式
- (ZZRequestMethod)requestMethod
{
    return ZZReuqestPost;
}

// 返回数据序列化方式
- (ZZResponseSerializerType)responseSerializerType
{
    return ZZResponseSerializerTypeJSON;
}

// 请求参数序列化方式
- (ZZRequestSerializerType)requestSerializerType
{
    return ZZRequestSerializerTypeHTTP;
}

// 请求超时时间（默认20秒）
- (NSTimeInterval)requestTimeoutInterval
{
    return 20;
}

// 在HTTP报头添加参数
- (NSDictionary *)requestHeaderFieldValueDictionary
{
    return nil;
}

// 请求成功后调用，//子类重写
- (void)requestCompleteSuccess
{

}

// 清空BlOCK
- (void)clearCompletionBlock
{
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}

@end
