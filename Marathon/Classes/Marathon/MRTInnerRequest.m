//
//  MRTInnerRequest.m
//  AFNetworking
//
//  Created by chenyusen on 2018/10/19.
//

#import "MRTInnerRequest.h"

@implementation MRTInnerRequest
- (instancetype)initWithRequest:(id<MRTRequest>)request {
    self = [super init];
    if (self) {
        if ([request respondsToSelector:@selector(timeoutInterval)]) {
            _timeoutInterval = request.timeoutInterval;
        } else {
            _timeoutInterval = NSNotFound;
        }
        
        if ([request respondsToSelector:@selector(path)]) {
            _path = request.path;
        }
        
        if ([request respondsToSelector:@selector(methed)]) {
            _methed = request.methed;
        } else {
            _methed = @"GET";
        }
        
        if ([request respondsToSelector:@selector(parameters)]) {
            _parameters = [request.parameters mutableCopy];
        }
        
        if ([request respondsToSelector:@selector(headers)]) {
            _headers = [request.headers mutableCopy];
        }
        
        if ([request respondsToSelector:@selector(ignorePluginHandle)]) {
            _ignorePluginHandle = request.ignorePluginHandle;
        } else {
            _ignorePluginHandle = NO;
        }
        
        if ([request respondsToSelector:@selector(ignoreCommonParamters)]) {
            _ignoreCommonParamters = request.ignoreCommonParamters;
        } else {
            _ignoreCommonParamters = NO;
        }
        
        if ([request respondsToSelector:@selector(ignoreCommonHeaders)]) {
            _ignoreCommonHeaders = request.ignoreCommonHeaders;
        } else {
            _ignoreCommonHeaders = NO;
        }
        
        if ([request respondsToSelector:@selector(needCache)]) {
            _needCache = request.needCache;
        } else {
            _needCache = NO;
        }
        
#ifdef DEBUG
        if ([request respondsToSelector:@selector(preferredSampleData)] &&
            request.preferredSampleData) {
            _preferredSampleData = YES;
        } else {
            _preferredSampleData = NO;
        }
        
        if ([request respondsToSelector:@selector(sampleData)]) {
            _sampleData = request.sampleData;
        } else {
            _sampleData = nil;
        }
#endif
        if ([request respondsToSelector:@selector(ignoreCacheCaluKey)]) {
            _ignoreCacheCaluKey = request.ignoreCacheCaluKey;
        }
        
        if ([request respondsToSelector:@selector(cacheCaluKeyValue)]) {
            _cacheCaluKeyValue = request.cacheCaluKeyValue;
        }
        
        if ([request respondsToSelector:@selector(uniqueCacheKey)]) {
            _uniqueCacheKey = request.uniqueCacheKey;
        }
    }
    return self;
}
@end
