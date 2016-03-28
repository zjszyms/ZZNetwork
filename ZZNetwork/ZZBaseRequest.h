//
//  ZZBaseRequest.h
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

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@class ZZBaseRequest;

// HTTP请求方式
typedef NS_ENUM(NSInteger, ZZRequestMethod)
{
    ZZReuqestGet    = 0,
    ZZReuqestPost   = 1,
    ZZReuqestPut    = 2,
    ZZReuqestDelete = 3,
};

// 请求参数序列方式
typedef NS_ENUM(NSInteger, ZZRequestSerializerType)
{
    // 向服务端提交表单
    ZZRequestSerializerTypeHTTP = 0,
    // 向服务端提交Json
    ZZRequestSerializerTypeJSON = 1,
};

// 返回参数序列方式
typedef NS_ENUM(NSInteger, ZZResponseSerializerType)
{
    // 从服务器返回原始数据
    ZZResponseSerializerTypeHTTP = 0,
    // 从服务端返回Json数据
    ZZResponseSerializerTypeJSON = 1,
    // 从服务端返回XML数据
    ZZResponseSerializerTypeXML  = 2
};

// 请求Block定义
typedef void (^SuccessCompletionBlock)(ZZBaseRequest *request, id responseObject);
typedef void (^FailureCompletionBlock)(ZZBaseRequest *request, NSString *error);

// 协议
@protocol ZZRequestDelegate <NSObject>

@optional
- (void)requestDidFinished:(ZZBaseRequest *)request error:(NSString *)error;

@end

@interface ZZBaseRequest : NSObject

@property (nonatomic, assign) int requestTag;

// SessionTask
@property (nonatomic, strong) NSURLSessionDataTask *requestSessionTask;

@property (nonatomic, weak) id<ZZRequestDelegate> delegate;

#pragma mark -
#pragma mark - 请求响应数据

// 服务端返回的数据
@property (nonatomic, strong) id responseObject;

// error
@property (nonatomic, strong) NSError *error;

// 服务端返回成功数据Block
@property (nonatomic, copy, readonly) SuccessCompletionBlock successCompletionBlock;

// 服务端返回失败数据Block
@property (nonatomic, copy, readonly) FailureCompletionBlock failureCompletionBlock;

#pragma mark -
#pragma mark - main

- (void)start;
- (void)stop;
- (NSURLSessionTaskState)requestSessionTaskState;

- (void)startRequestWithCompletionBlockWithSuccess:(SuccessCompletionBlock)success
                                            failue:(FailureCompletionBlock)failure;

// 重写改方法会忽略配置里的baseUrl
- (NSString *)baseUrl;

// 请求的Url路径
- (NSString *)requestUrl;

// 请求参数
- (id)requestParameters;

// 请求方式
- (ZZRequestMethod)requestMethod;

// 返回数据序列化方式
- (ZZResponseSerializerType)responseSerializerType;

// 请求参数序列化方式
- (ZZRequestSerializerType)requestSerializerType;

// 请求超时时间（默认20秒）
- (NSTimeInterval)requestTimeoutInterval;

// 在HTTP报头添加参数
- (NSDictionary *)requestHeaderFieldValueDictionary;

// 请求成功后调用，//子类重写
- (void)requestCompleteSuccess;

// 清空BlOCK
- (void)clearCompletionBlock;

@end

// TODO
@interface ZZBaseRequest (CustomSSL)

// 是否使用自定义安全证书 默认 NO（不使用）
- (BOOL)useCustomSecurityCertificate;

@end
