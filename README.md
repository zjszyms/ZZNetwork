# ZZNetwork
ZZNetwork 主要是对AFNetworking进行了封装，便于网络请求。

## 编译环境
xcode 7+
AFNetworking 3+

## 运行项目
下载后直接运行，本项目中得AFNetworking不是最新版本，生产环境请请更换置最新版本。

## 开源协议
ZZNetwork is under the MIT license. See the LICENSE file for more details.

#使用方法
1.网络请求根地址设置
ZZRequestConfig 文件设置，例如：https://api.douban.com/
```
- (NSString *)baseUrl
{
	return @"https://api.douban.com/";
}
```
2. ZZNetwork默认值（具体可以参考ZZBaseRequest类）
ZZNetwork默认请求方式为Post请求。
ZZNetwork默认返回参数类型为Json格式

##网络请求API创建
ZZRequest.h
```
@interface MovieApi : ZZRequest
- (instancetype)initWithSearchName:(NSString *)theName;
@end
```
MovieApi.m
```
@implementation MovieApi
{
	NSString *_theName;
}
- (instancetype)initWithSearchName:(NSString *)theName
{
	self = [super init];
	if (self) {
		_theName = theName;
	}
	return self;
}
// 请求的地址
- (NSString *)requestUrl
{
	return @"/v2/movie/search";
}
// 请求的参数
- (id)requestParameters
{
	NSDictionary *params = [NSDictionary dictionaryWithObject:_theName forKey:@"q"];
	return params;
}
```
##网络API请求的调用
```
MovieApi *api = [[MovieApi alloc] initWithSearchName:@"刘德华"];
[api startRequestWithCompletionBlockWithSuccess:^(ZZBaseRequest *request, id responseObject) {
    NSLog(@"MovieApi请求成功 = %@",responseObject);	
} failue:^(ZZBaseRequest *request, NSError *error) {
    NSLog(@"MovieApi请求失败 = %@", [error description]);
}];
```
如果API请求需要缓存返回的数据，只需重写以下方法即可：
```
// 缓存有效时间（60秒）
- (NSInteger)cacheTimeInSeconds
{
    return 60;
}
// 是否缓存返回数据
- (BOOL)shouldCacheResponse
{
    return YES;
}
```
可以参考Demo中得MusicApi；

#注意：
如果设置了缓存，则在缓存有效期内再次发起请求，ZZNetwork会直接返回本地数据（不进行网络请求）；
如果想强行刷新本地数据，需在请求之前设置：
```
// 可选 该参数为强行忽略本地缓存，直接请求
api.shouldIgnoreCache = YES;
```
设置为YES后，会忽略本地缓存数据，直接发起网络请求，并且刷新本地缓存数据；