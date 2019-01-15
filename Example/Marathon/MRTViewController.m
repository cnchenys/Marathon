//
//  MRTViewController.m
//  Marathon
//
//  Created by TechSen on 09/05/2018.
//  Copyright (c) 2018 TechSen. All rights reserved.
//

#import "MRTViewController.h"
#import <Marathon/Marathon.h>

@interface TestCommonInfoPlugin : NSObject<MRTResponseHandlePlugin, MRTCommonInfoPlugin>

@end

@implementation TestCommonInfoPlugin

- (NSDictionary<NSString *,NSString *> *)headers {
    return @{@"a" : @"a"};
}

- (NSDictionary<NSString *, NSString *> *)parameters {
    return @{@"b" : @"b"};
}

//- (id)handleResponseObject:(id)responseObject {
//    return responseObject[@"code"];
//}
//
//- (nonnull id)handleResponseError:(nonnull NSError *)error {
//    return error;
//}


@end


@interface NewsRequest : NSObject<MRTRequest>

@end

@implementation NewsRequest


- (BOOL)preferredSampleData {
    return NO;
}

- (id)sampleData {
    return @{@"data" : @"嗯哈啊哈哈"};
}


- (BOOL)needCache {
    return YES;
}

- (NSDictionary *)parameters {
    return @{@"deleted" : @0,
             @"enalbe" : @1};
}

- (NSString *)path {
    return @"school/news";
}

- (NSDictionary<NSString *,NSString *> *)cacheCaluKeyValue {
    return @{@"location" : @"123"};
}

//- (BOOL)ignoreCommonParams {
//    return NO;
//}
//
//- (BOOL)ignoreCommonHeaders {
//    return NO;
//}

//- (BOOL)needCache {
//    return YES;
//}

@end



@interface MRTViewController ()
@property (nonatomic, strong) Marathon *testClient;

@end

@implementation MRTViewController
    

- (IBAction)btnAction:(id)sender {
    NewsRequest *request = [[NewsRequest alloc] init];
    
//    id cache = [Marathon.shared fetchCacheWithRequest:request];
    
    [self.testClient asyncRequest:request
                          success:^(id  _Nullable data) {
                             NSLog(@"%@", data);
                         }
                         failure:^(NSError * _Nullable error) {
                             NSLog(@"%@", error);
                         }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupMRT];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    btn.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:btn];
    
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
- (Marathon *)testClient {
    if (!_testClient) {
        _testClient = [[Marathon alloc] init];
    }
    return _testClient;
}


- (void)setupMRT {
    [self.testClient config:^(MRTConfigurator * _Nonnull configurator) {
        configurator.baseURL = [NSURL URLWithString:@"https://api.smartstudy.com"];
        configurator.plugins = @[[TestCommonInfoPlugin new]];
    }];
}
@end



