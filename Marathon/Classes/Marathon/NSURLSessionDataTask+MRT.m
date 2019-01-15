//
//  NSURLSessionDataTask+MRT.m
//  AFNetworking
//
//  Created by chenyusen on 2018/10/18.
//

#import "NSURLSessionDataTask+MRT.h"

@implementation NSURLSessionDataTask (MRT)

- (void)cancelRequest {
    [self cancel];
}

@end
