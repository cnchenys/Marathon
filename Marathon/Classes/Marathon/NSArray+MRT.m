//
//  NSArray+MRT.m
//  AFNetworking
//
//  Created by chenyusen on 2018/10/18.
//

#import "NSArray+MRT.h"

@implementation NSArray (MRT)

- (void)cancelRequest {
    if ([self.lastObject isKindOfClass:[NSURLSessionDataTask class]]) {
        [self makeObjectsPerformSelector:@selector(cancel)];
    }
}
@end
