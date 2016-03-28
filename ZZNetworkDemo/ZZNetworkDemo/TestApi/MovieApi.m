//
//  MovieApi.m
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

#import "MovieApi.h"
#import "NSMutableDictionary+ZZExtends.h"

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

@end
