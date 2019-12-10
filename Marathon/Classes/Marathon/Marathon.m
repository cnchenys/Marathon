//
//  Marathon.m
//  AFNetworking
//
//  Created by chenyusen on 2018/9/5.
//

#import "Marathon.h"
#import <AFNetworking/AFNetworking.h>
#import "AFHTTPSessionManager+MRT.h"
#import "NSURLSessionDataTask+MRT.h"
#import "NSArray+MRT.h"


@interface Marathon()
@property (nonatomic, strong) AFHTTPSessionManager *sessionMgr;
@property (nonatomic, strong, readonly) MRTConfigurator *configurator;
@end


@implementation Marathon {
    MRTConfigurator *_configurator;
}

+ (AFHTTPResponseSerializer <AFURLResponseSerialization> *)responseSerializerWithType:(MRTResponseSerializeType)type {
    AFHTTPResponseSerializer *serializer;
    switch (type) {
        case MRTResponseSerializeTypeJSON:
            serializer = [AFJSONResponseSerializer serializer];
            break;
        case MRTResponseSerializeTypeHTTP:
            serializer = [AFHTTPResponseSerializer serializer];
            break;
        case MRTResponseSerializeTypeXML:
            serializer = [AFXMLParserResponseSerializer serializer];
            break;
        default:
            break;
    }
    return serializer;
}


+ (AFHTTPRequestSerializer <AFURLRequestSerialization> *)requestSerializerWithType:(MRTRequestSerializeType)type {
    
    AFHTTPRequestSerializer *serializer;
    switch (type) {
        case MRTRequestSerializeTypeHTTP:
            serializer = [AFHTTPRequestSerializer serializer];
            break;
        case MRTRequestSerializeTypeJSON:
            serializer = [AFJSONRequestSerializer serializer];
            break;
        case MRTRequestSerializeTypePropertyList:
            serializer = [AFPropertyListRequestSerializer serializer];
            break;
        default:
            break;
    }
    return serializer;
}


+ (void)setReachabilityStatusChangeBlock:(MRTNetworkReachabilityStatusBlock)statusChangeBlock {
    [AFNetworkReachabilityManager.sharedManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (statusChangeBlock) {
            statusChangeBlock([self transformStatus:status]);
        }
    }];
    [AFNetworkReachabilityManager.sharedManager startMonitoring]; // 再次确保开启监控
}


+ (BOOL)isNetworkReachable {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}


+ (MRTNetworkReachabilityStatus)networkReachabilityStatus {
    return [self transformStatus:[[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus]];
}


+ (MRTNetworkReachabilityStatus)transformStatus:(AFNetworkReachabilityStatus)status {
    return (NSInteger)status;
}


- (MRTConfigurator *)configurator {
    if (!_configurator) {
        _configurator = [[MRTConfigurator alloc] init];
    }
    return _configurator;
}


- (void)config:(void (^)(MRTConfigurator * _Nonnull))configuration {
    !configuration ?: configuration(self.configurator);
    assert(self.configurator.baseURL.absoluteString.length > 0);
    [self initData];
}


- (instancetype)init {
    self = [super init];
    if (self) {
        [AFNetworkReachabilityManager.sharedManager startMonitoring];
    }
    return self;
}


- (void)initData {
    _pluginManager = [[MRTPluginManager alloc] init];
    for (id<MRTPlugin> plugin in self.configurator.plugins) {
        [_pluginManager registerPlugin:plugin];
    }
    _sessionMgr = [[AFHTTPSessionManager alloc] initWithBaseURL:self.configurator.baseURL];
    _sessionMgr.requestSerializer = [self.class requestSerializerWithType: self.configurator.requestSerializer.serializeType];
    _sessionMgr.requestSerializer.timeoutInterval = self.configurator.requestSerializer.timeoutInterval;
    
    _sessionMgr.responseSerializer = [self.class responseSerializerWithType:self.configurator.responseSerializer.serializeType];
    _sessionMgr.responseSerializer.acceptableContentTypes = self.configurator.responseSerializer.acceptableContentTypes;
    
}

#pragma mark - Public Methods
- (id<MRTCancelable>)asyncRequest:(id<MRTRequest>)request
                          success:(MRTRequestSuccessBlock)success
                          failure:(MRTRequestFailureBlock)failure {
    
#ifdef DEBUG
    if ([request respondsToSelector:@selector(preferredSampleData)] && request.preferredSampleData) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (success) {
                success(request.sampleData);
            }
        });
        return nil;
    }
    
#endif
    
    // 经插件中心处理
    id<MRTInnerRequest> handledRequest = [_pluginManager handleBeforeRequest:request];
    
    NSString *url = handledRequest.path;
    if (![url hasPrefix:@"http"]) { // url为非全路径, 则拼上baseUrl
        url = [[self.configurator.baseURL URLByAppendingPathComponent:url] absoluteString];
    }
    
    NSTimeInterval timeoutInterval = [request respondsToSelector:@selector(timeoutInterval)] ? request.timeoutInterval : self.configurator.requestSerializer.timeoutInterval;
    
    
    __weak __typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [_sessionMgr dataTaskWithHTTPMethod:handledRequest.methed
                                                           URLString:url
                                                          parameters:handledRequest.parameters
                                                     timeoutInterval:timeoutInterval
                                                             headers:handledRequest.headers
                                                      uploadProgress:nil
                                                    downloadProgress:nil
                                                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                                                 
                                                                 __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                                 if (!strongSelf) return;
                                                                                  
                                                                 [strongSelf handleSuccessWithRequest:handledRequest
                                                                                       responseObject:responseObject
                                                                                              success:success
                                                                                              failure:failure];
                                                             }
                                                             failure:^(NSURLSessionDataTask *task, NSError * _Nonnull error) {
                                                                 
                                                                 __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                                 if (!strongSelf) return;
                                                                 
                                                                 [strongSelf handleFailureWithRequest:handledRequest error:error success:success failure:failure];
                                                             }];
    [task resume];
    return task;
    
}


- (id<MRTCancelable>)asyncRequestGroup:(id<MRTRequestGroup>)requestGroup
                            completion:(nullable MRTGroupRequestCompletionBlock)completion {
    
    
    dispatch_group_t group = dispatch_group_create();
    NSMutableArray<id<MRTCancelable>> *cancelables = [NSMutableArray arrayWithCapacity:requestGroup.requests.count];
    NSMutableDictionary *groupDictM = [NSMutableDictionary dictionaryWithCapacity:requestGroup.requests.count];
    
    for (id<MRTRequest> request in requestGroup.requests) {
        dispatch_group_enter(group);
        NSInteger index = [requestGroup.requests indexOfObject:request];
        NSString *indexStr = [NSString stringWithFormat:@"%ld", (long)index];
        
        id<MRTCancelable> task;
        if ([request respondsToSelector:@selector(asyncRequestSuccess:failure:)]) {
            task = [request asyncRequestSuccess:^(id  _Nullable data) {
                groupDictM[indexStr] = data;
                dispatch_group_leave(group);
            } failure:^(NSError * _Nullable error) {
                groupDictM[indexStr] = error;
                dispatch_group_leave(group);
            }];
        } else {
            task = [self asyncRequest:request
                              success:^(id  _Nullable data) {
                                  groupDictM[indexStr] = data;
                                  dispatch_group_leave(group);
                              }
                              failure:^(NSError * _Nullable error) {
                                  groupDictM[indexStr] = error;
                                  dispatch_group_leave(group);
                              }];
        }
        [cancelables addObject:task];
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completion) {
            completion([groupDictM copy]);
        }
    });
    return cancelables;
}


- (id<MRTCancelable>)uploadWithPath:(NSString *)path
                               name:(NSString *)name
                           fileName:(NSString *)fileName
                           mimeType:(NSString *)mimeType
                           fileData:(NSData *)fileData
                         parameters:(NSDictionary *)parameters
                           progress:(nullable void (^)(NSProgress *))progress
                            success:(MRTRequestSuccessBlock)success
                            failure:(MRTRequestFailureBlock)failure {

    
    NSString *aPath = [path copy];
    if (![aPath hasPrefix:@"http"]) { // url为非全路径, 则拼上baseUrl
        aPath = [[self.configurator.baseURL URLByAppendingPathComponent:aPath] absoluteString];
    }
    
    
    MRTInnerRequest *request = [[MRTInnerRequest alloc] init];
    request.path = path;
    request.parameters = [parameters mutableCopy];
    // 经插件中心处理
    id<MRTInnerRequest> handledRequest = [_pluginManager handleBeforeRequest:request];
    
    
    __weak __typeof(self) weakSelf = self;
    [_sessionMgr POST:aPath
      timeoutInterval:handledRequest.timeoutInterval
              headers:handledRequest.headers
           parameters:parameters
    constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
      [formData appendPartWithFileData:fileData name:name fileName:fileName mimeType:mimeType];
  }
             progress:progress
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  __strong __typeof(weakSelf) strongSelf = weakSelf;
                  if (!strongSelf) return;
                  
                  [strongSelf handleSuccessWithRequest:handledRequest
                                        responseObject:responseObject
                                               success:success
                                               failure:failure];
              }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  __strong __typeof(weakSelf) strongSelf = weakSelf;
                  if (!strongSelf) return;
                  
                  [strongSelf handleFailureWithRequest:handledRequest error:error success:success failure:failure];
              }];
    
    
    return nil;
}


#pragma mark - Private
- (void)handleSuccessWithRequest:(id<MRTInnerRequest>)request
                  responseObject:(id)responseObject
                         success:(MRTRequestSuccessBlock)success
                         failure:(MRTRequestFailureBlock)failure {
                             
    request.response = responseObject;
    
    id<MRTInnerRequest> aHandledRequest = [self.pluginManager handleAfterResponse:request];
    if (!aHandledRequest.error) {
        if (aHandledRequest.response && aHandledRequest.needCache) {
            [self handleRequestIgnoreCacheCaluKey:request];
            [MRTCacheManager.shared setCache:aHandledRequest.response
                                 withReqeust:request
                                  completion:nil];
        }
        if (success) {
            success(aHandledRequest.response);
        }
    } else {
        if (failure && aHandledRequest.error) {
            failure(aHandledRequest.error);
        }
    }
}


- (void)handleFailureWithRequest:(id<MRTInnerRequest>)request
                           error:(NSError *)error
                         success:(MRTRequestSuccessBlock)success
                         failure:(MRTRequestFailureBlock)failure {
    request.error = error;
    id<MRTInnerRequest> aHandledRequest = [self.pluginManager handleAfterResponse:request];
    if (failure && aHandledRequest.error) {
        failure(aHandledRequest.error);
    } else if (success && aHandledRequest.response) {
        success(aHandledRequest.response);
    }
}

- (void)handleRequestIgnoreCacheCaluKey:(id<MRTInnerRequest>)request {
    if (self.configurator.ignoreCacheCaluKey.count > 0) {
        NSMutableArray *ignoreCacheCaluKey = [NSMutableArray array];
        [ignoreCacheCaluKey addObjectsFromArray:self.configurator.ignoreCacheCaluKey];
        
        if (request.ignoreCacheCaluKey.count > 0) {
            [ignoreCacheCaluKey addObjectsFromArray:request.ignoreCacheCaluKey];
        }
        
        request.ignoreCacheCaluKey = ignoreCacheCaluKey;
    }
}

- (id)fetchCacheWithRequest:(id<MRTRequest>)request {
    // 经过插件中心处理
    id<MRTInnerRequest> handledRequest = [_pluginManager handleBeforeRequest:request];
    
    [self handleRequestIgnoreCacheCaluKey:handledRequest];
    
    // 经过缓存中心处理
    if (handledRequest.needCache) {
        return [MRTCacheManager.shared cacheWithRequest:handledRequest];
    } else {
        return nil;
    }
}
@end
