//
//  ViewController.m
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

#import "ViewController.h"
#import "MusicApi.h"
#import "MovieApi.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)movieButtonDidonclick:(id)sender {
    
    MovieApi *api = [[MovieApi alloc] initWithSearchName:@"刘德华"];
    [api startRequestWithCompletionBlockWithSuccess:^(ZZBaseRequest *request, id responseObject) {
        NSLog(@"MovieApi请求成功 = %@",responseObject);
    } failue:^(ZZBaseRequest *request, NSString *error) {
        NSLog(@"MovieApi请求失败 = %@", error);
    }];
    
}
- (IBAction)musicButtonDidonclick:(id)sender {
    
    MusicApi *api = [[MusicApi alloc] initWithSearchName:@"邓丽君"];
    
    // 可选 该参数为强行忽略本地缓存，直接请求
    //api.shouldIgnoreCache = YES;
    
    [api startRequestWithCompletionBlockWithSuccess:^(ZZBaseRequest *request, id responseObject) {
        NSLog(@"MusicApi请求成功 = %@",responseObject);
    } failue:^(ZZBaseRequest *request, NSString *error) {
         NSLog(@"MusicApi请求失败 = %@", error);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
