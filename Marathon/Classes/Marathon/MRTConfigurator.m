//
//  MRTConfigurator.m
//  AFNetworking
//
//  Created by chenyusen on 2018/12/18.
//

#import "MRTConfigurator.h"


@implementation MRTRequestSerializer

- (instancetype)init {
    self = [super init];
    if (self) {
        _serializeType = MRTRequestSerializeTypeJSON;
    }
    return self;
}
@end

@implementation MRTResponseSerializer

- (instancetype)init {
    self = [super init];
    if (self) {
        _serializeType = MRTResponseSerializeTypeJSON;
    }
    return self;
}
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
