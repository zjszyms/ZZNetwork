//
//  ZZRequestManager.m
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

#import "ZZRequestManager.h"
#import "AFNetworking.h"
#import "ZZRequestConfig.h"
#import "AFNetworkActivityIndicatorManager.h"

@interface ZZRequestManager ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) NSMutableDictionary *requestsRecordDictionary;

@end

@implementation ZZRequestManager

+ (ZZRequestManager *)sharedInstance {
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
        self.sessionManager = [AFHTTPSessionManager manager];
        self.requestsRecordDictionary = [[NSMutableDictionary alloc] init];
        self.sessionManager.operationQueue.maxConcurrentOperationCount = 5;
        
        [self startNetworkStateMonitoring];
    }
    return self;
}

- (void)startRequest:(ZZBaseRequest *)request
{
    // 网络异常处理
    if (self.reachabilityStatus == ZZRequestReachabilityStatusNotReachable)
    {
        NSError *error = [NSError errorWithDomain:@"网络错误" code:-1005 userInfo:nil];
        request.error = error;
        request.responseObject = nil;
        [self requestDidFinished:request];
        return;
    }
    
    // 配置请求参数
    [self configRequest:request];
    
    // 发起请求
    [self startAFnetwokRequest:request];
}

#pragma mark - AFNetwork 请求处理方法
- (void)handleReponseResult:(NSURLSessionDataTask *)task response:(id)responseObject error:(NSError *)error
{
    NSString *hashKey = [self taskHashKey:task];
    ZZBaseRequest *request = [self.requestsRecordDictionary objectForKey:hashKey];
    request.responseObject = responseObject;
    request.error = error;
    
    // 对网络数据进行校验
    [self handleRequestDataWithRequest:request];
    
    // 处理网络请求
    [self requestDidFinished:request];
}

#pragma mark - 对数据进行校验，并对数据业务逻辑的失败进行处理
- (void)handleRequestDataWithRequest:(ZZBaseRequest *)request
{
    if (!request.error) {
        if (request.responseSerializerType == ZZResponseSerializerTypeJSON) {
            if (![NSJSONSerialization isValidJSONObject:request.responseObject] || !request.responseObject) {
                request.error = [NSError errorWithDomain:@"数据错误" code:-1005 userInfo:nil];
            }
        }
    }
    else
    {
        request.error = [NSError errorWithDomain:@"网络错误" code:-1005 userInfo:nil];
    }
}

#pragma mark - 处理网络请求
- (void)requestDidFinished:(ZZBaseRequest *)request
{
    if (request.error) {
        if (request.failureCompletionBlock) {
            request.failureCompletionBlock(request,[request.error domain]);
        }
        if ([request.delegate respondsToSelector:@selector(requestDidFinished:error:)]) {
            [request.delegate requestDidFinished:request error:[request.error domain]];
        }
    }
    else
    {
        if (request.successCompletionBlock) {
            request.successCompletionBlock(request,request.responseObject);
        }
        if ([request.delegate respondsToSelector:@selector(requestDidFinished:error:)]) {
            [request.delegate requestDidFinished:request error:[request.error domain]];
        }
    }
    
    // 子类重写，便于缓存数据
    [request requestCompleteSuccess];
    
    // 移除网络请求
    [self removeRequest:request.requestSessionTask];
    // 清空Block
    [request clearCompletionBlock];
}

#pragma mark - 配置请求Url
- (NSString *)configRequestUrl:(ZZBaseRequest *)request
{
    NSString *detailUrl     = [request requestUrl];
    NSString *baseUrl       = [request baseUrl];
    ZZRequestConfig *config = [ZZRequestConfig sharedInstance];
    
    // detailUrl如果是一个完整的Url，则直接使用，忽略baseUrl
    if ([detailUrl hasPrefix:@"http"])
    {
        return detailUrl;
    }
    // 如果Request没有添加baseUrl，则使用ZZNetworkConfig baseUrl
    if(baseUrl.length <= 0)
    {
        baseUrl = [config baseUrl];
    }
    
    return [NSString stringWithFormat:@"%@%@", baseUrl, detailUrl];
}

#pragma mark - 配置请求
- (void)configRequest:(ZZBaseRequest *)request
{
    // 处理请求序列化类型
    ZZRequestSerializerType requestSerializerType = request.requestSerializerType;
    if (requestSerializerType == ZZRequestSerializerTypeHTTP)
    {
        self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    else if (requestSerializerType == ZZRequestSerializerTypeJSON)
    {
        self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    [self.sessionManager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    
    // 处理返回数据序列化类型
    ZZResponseSerializerType responseSerializerType = request.responseSerializerType;
    if (responseSerializerType == ZZResponseSerializerTypeHTTP)
    {
        self.sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    else if (responseSerializerType == ZZResponseSerializerTypeJSON)
    {
        self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    else if (responseSerializerType == ZZResponseSerializerTypeXML)
    {
        self.sessionManager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    }
    
    // 设置acceptable ContentTypes
    self.sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/xml", @"application/xml", @"text/json", @"application/json", nil];
    
    // 设置超时时间
    self.sessionManager.requestSerializer.timeoutInterval = request.requestTimeoutInterval;
    
    // 添加自定义请求头
    [self addCustomRequestHeader:request];
}

#pragma mark - 添加自定义请求头
- (void)addCustomRequestHeader:(ZZBaseRequest *)request
{
    NSDictionary *headerFieldValueDictionary = [request requestHeaderFieldValueDictionary];
    if (headerFieldValueDictionary != nil) {
        for (id httpHeaderField in headerFieldValueDictionary.allKeys)
        {
            id value = headerFieldValueDictionary[httpHeaderField];
            if ([httpHeaderField isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]])
            {
                [self.sessionManager.requestSerializer setValue:(NSString *)value forHTTPHeaderField:(NSString *)httpHeaderField];
            }
            else
            {
                NSLog(@"Error, class of key/value in headerFieldValueDictionary should be NSString.");
            }
        }
    }
}

#pragma mark - 添加请求
- (void)addRequest:(ZZBaseRequest *)request
{
    if (request.requestSessionTask) {
        NSString *key = [self taskHashKey:request.requestSessionTask];
        @synchronized(self) {
            [self.requestsRecordDictionary setValue:request forKey:key];
        }
    }
}
#pragma mark - 移除请求
- (void)removeRequest:(NSURLSessionDataTask *)task
{
    if (!task) {
        return;
    }
    
    NSString *key = [self taskHashKey:task];
    @synchronized(self) {
        [self.requestsRecordDictionary removeObjectForKey:key];
    }
}
#pragma mark - 取消请求
- (void)cancelRequest:(ZZBaseRequest *)request
{
    if (!request) {
        return;
    }
    [request.requestSessionTask cancel];
    [self removeRequest:request.requestSessionTask];
}

#pragma mark - 取消所有请求
- (void)cancelAllRequests
{
    for (NSString *key in self.requestsRecordDictionary) {
        ZZBaseRequest *request = self.requestsRecordDictionary[key];
        [self cancelRequest:request];
    }
}

#pragma mark - 发起网络请求
- (void)startAFnetwokRequest:(ZZBaseRequest *)request
{
    // url处理
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSString *theRequestUrl = [[self configRequestUrl:request] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#pragma clang diagnostic pop
    
    // 处理参数
    id params = request.requestParameters;
    if (request.requestSerializerType == ZZRequestSerializerTypeJSON) {
        if (![NSJSONSerialization isValidJSONObject:params] && params) {
            NSLog(@"error in JSON parameters：%@", params);
            return;
        }
    }
    else if (request.requestSerializerType == ZZRequestSerializerTypeHTTP)
    {
        // 添加内置参数
        id<ZZBuiltinParametersProtocol>builtinParametersManager = [ZZRequestConfig sharedInstance].builtinParametersManager;
        
        BOOL isConform = [builtinParametersManager respondsToSelector:@selector(buildtinParameters)];
        if (isConform)
        {
            NSDictionary *builtinParams = [builtinParametersManager buildtinParameters];
            
            if (params && [params isKindOfClass:[NSDictionary class]])
            {
                if (builtinParams) {
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:params];
                    [dic addEntriesFromDictionary:builtinParams];
                    params = [dic copy];
                }
            }
            else
            {
                params = builtinParams;
            }

        }
    }
    
    // 处理请求
    ZZRequestMethod requestMethod = request.requestMethod;
    NSURLSessionDataTask *task = nil;
    switch (requestMethod) {
        case ZZReuqestGet:
        {

            task = [self.sessionManager GET:theRequestUrl parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                        [self handleReponseResult:task response:responseObject error:nil];
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        [self handleReponseResult:task response:nil error:error];
                    }];
            
        }
            break;
            
        case ZZReuqestPost:
        {
            task = [self.sessionManager POST:theRequestUrl parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                [self handleReponseResult:task response:responseObject error:nil];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handleReponseResult:task response:nil error:error];
            }];
        }
            break;
            
        case ZZReuqestPut:
        {
            task = [self.sessionManager PUT:theRequestUrl parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self handleReponseResult:task response:responseObject error:nil];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handleReponseResult:task response:nil error:error];
            }];
        }
            break;
            
        case ZZReuqestDelete:
        {
            task = [self.sessionManager DELETE:theRequestUrl parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self handleReponseResult:task response:responseObject error:nil];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handleReponseResult:task response:nil error:error];
            }];
        }
            break;
        default:
            break;
    }
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    request.requestSessionTask = task;
    [self addRequest:request];
}

- (NSString *)taskHashKey:(NSURLSessionDataTask *)sessionDataTask
{
    return [NSString stringWithFormat:@"%lu", (unsigned long)[sessionDataTask hash]];
}

#pragma mark - 监测网络状态
- (void)startNetworkStateMonitoring {
    [self.sessionManager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                _reachabilityStatus = ZZRequestReachabilityStatusUnknow;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                _reachabilityStatus = ZZRequestReachabilityStatusNotReachable;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                _reachabilityStatus = ZZRequestReachabilityStatusViaWWAN;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                _reachabilityStatus = ZZRequestReachabilityStatusViaWiFi;
                break;
            default:
                break;
        }
    }];
    [self.sessionManager.reachabilityManager startMonitoring];
}

@end
