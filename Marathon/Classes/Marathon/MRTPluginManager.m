//
//  MRTPluginManager.m
//  AFNetworking
//
//  Created by chenyusen on 2018/9/6.
//

#import "MRTPluginManager.h"
#import "MRTInnerRequest.h"


@implementation MRTPluginManager {
    NSMutableArray<id<MRTRequestPlugin>> *_requestPlugins;
    NSMutableArray<id<MRTResponsePlugin>> *_responsePlugins;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _requestPlugins = [NSMutableArray array];
        _responsePlugins = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Public Methods

- (void)registerPlugin:(id<MRTPlugin>)plugin {
    if (![plugin conformsToProtocol:@protocol(MRTPlugin)]) {
        return;
    }
    if ([plugin conformsToProtocol:@protocol(MRTRequestPlugin)]) {
        [_requestPlugins addObject:(id<MRTRequestPlugin>)plugin];
    }
    if ([plugin conformsToProtocol:@protocol(MRTResponsePlugin)]) {
        [_responsePlugins addObject:(id<MRTResponsePlugin>)plugin];
    }
  
    [_requestPlugins sortedArrayUsingComparator:^NSComparisonResult(id<MRTPlugin> obj1, id<MRTPlugin> obj2) {
        SEL sel = @selector(priority);
        NSInteger priority1 = [obj1 respondsToSelector:sel] ? [obj1 priority] : 1000;
        NSInteger priority2 = [obj2 respondsToSelector:sel] ? [obj2 priority] : 1000;
        return priority1 > priority2 ? NSOrderedDescending : NSOrderedAscending;
    }];
    
    [_responsePlugins sortedArrayUsingComparator:^NSComparisonResult(id<MRTPlugin> obj1, id<MRTPlugin> obj2) {
        if ([obj1 conformsToProtocol:@protocol(MRTSecurityPlugin)]) {
            return NSOrderedDescending;
        }
        SEL sel = @selector(priority);
        NSInteger priority1 = [obj1 respondsToSelector:sel] ? [obj1 priority] : 1000;
        NSInteger priority2 = [obj2 respondsToSelector:sel] ? [obj2 priority] : 1000;
        return priority1 > priority2 ? NSOrderedDescending : NSOrderedAscending;
    }];
    
}

- (void)unregisterPlugin:(id<MRTPlugin>)plugin {
    if ([plugin conformsToProtocol:@protocol(MRTRequestPlugin)]) {
        [_requestPlugins removeObject:(id<MRTRequestPlugin>)plugin];
    }
    if ([plugin conformsToProtocol:@protocol(MRTResponsePlugin)]) {
        [_responsePlugins removeObject:(id<MRTResponsePlugin>)plugin];
    }
}

- (id<MRTInnerRequest>)handleBeforeRequest:(id<MRTRequest>)request {
    MRTInnerRequest *tmpRequest = [[MRTInnerRequest alloc] initWithRequest:request];
    if (tmpRequest.ignorePluginHandle) {
        return tmpRequest;
    }
    for (id<MRTRequestPlugin> plugin in _requestPlugins) {

        // 处理公共参数插件
        if ([plugin conformsToProtocol:@protocol(MRTCommonInfoPlugin)]) {
            if ([plugin respondsToSelector:@selector(headers)]) {

                if (!tmpRequest.headers) {
                    tmpRequest.headers = [NSMutableDictionary dictionary];
                }
                
                if (!tmpRequest.ignoreCommonHeaders) {
                    [tmpRequest.headers addEntriesFromDictionary:[((id<MRTCommonInfoPlugin>)plugin) headers] ?: @{}];
                }
            }

            if ([plugin respondsToSelector:@selector(parameters)]) {
                if (!tmpRequest.parameters) {
                    tmpRequest.parameters = [NSMutableDictionary dictionary];
                }
                
                if (!tmpRequest.ignoreCommonParamters) {
                    [tmpRequest.parameters addEntriesFromDictionary:[((id<MRTCommonInfoPlugin>)plugin) parameters] ?: @{}];
                }
            }
        }
        
        // 处理加密插件
        if ([plugin conformsToProtocol:@protocol(MRTSecurityPlugin)] && [plugin respondsToSelector:@selector(signatureWithRequest:)]) { // 加密插件处理
            if (!tmpRequest.parameters) {
                tmpRequest.parameters = [NSMutableDictionary dictionary];
            }
            [tmpRequest.parameters addEntriesFromDictionary:[((id<MRTSecurityPlugin>)plugin) signatureWithRequest:tmpRequest] ?: @{}];
        }
        
        if ([plugin conformsToProtocol:@protocol(MRTSecurityPlugin)] && [plugin respondsToSelector:@selector(encryptWithRequest:)]) { // 加密插件处理
            id encryptedObj = [((id<MRTSecurityPlugin>)plugin) encryptWithRequest:request];
            tmpRequest.encryptedData = encryptedObj;
        }
    }
    
    return tmpRequest;
}

- (id<MRTInnerRequest>)handleAfterResponse:(id<MRTInnerRequest>)request {
    if (request.ignorePluginHandle) {
        return request;
    }
    for (id<MRTResponsePlugin> plugin in _responsePlugins) {
        if ([plugin conformsToProtocol:@protocol(MRTSecurityPlugin)] && [plugin respondsToSelector:@selector(decryptWithResponse:)]) {
            request.response = [((id<MRTSecurityPlugin>)plugin) decryptWithResponse:request.response];
        } else {
            if (request.response && [plugin conformsToProtocol:@protocol(MRTResponseHandlePlugin)]) {
                id result;
                if ([plugin respondsToSelector:@selector(handleResponseObject:)]) {
                    result = [((id<MRTResponseHandlePlugin>)plugin) handleResponseObject:request.response];
                } else if (request.error && [plugin respondsToSelector:@selector(handleResponseError:)]) {
                    result = [((id<MRTResponseHandlePlugin>)plugin) handleResponseError:request.response];
                }
                if ([result isKindOfClass:[NSError class]]) {
                    request.error = result;
                    request.response = nil;
                } else {
                    request.response = result;
                    request.error = nil;
                }
            }
        }
    }
    return request;
}

@end
