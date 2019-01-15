//
//  MRTConfigurator.m
//  AFNetworking
//
//  Created by chenyusen on 2018/12/18.
//

#import "MRTConfigurator.h"


@implementation MRTRequestSerializer
@end

@implementation MRTResponseSerializer
@end

@implementation MRTConfigurator


- (instancetype)init {
    self = [super init];
    if (self) {
        _requestSerializer = [[MRTRequestSerializer alloc] init];
        _responseSerializer = [[MRTResponseSerializer alloc] init];
    }
    return self;
}
@end
