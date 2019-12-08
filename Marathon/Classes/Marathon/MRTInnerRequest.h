//
//  MRTInnerRequest.h
//  AFNetworking
//
//  Created by chenyusen on 2018/10/19.
//

#import <Foundation/Foundation.h>
#import "MRTRequest.h"
NS_ASSUME_NONNULL_BEGIN

@protocol MRTInnerRequest <MRTRequest>
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *methed;
@property (nonatomic, strong, nullable) id parameters;
@property (nonatomic, strong, nullable) NSMutableDictionary<NSString *, NSString *> *headers;

@property (nonatomic, assign) BOOL ignorePluginHandle;
@property (nonatomic, assign) BOOL ignoreCommonParamters;
@property (nonatomic, assign) BOOL ignoreCommonHeaders;

@property (nonatomic, assign) BOOL needCache;
#ifdef DEBUG
@property (nonatomic, assign) BOOL preferredSampleData;
@property (nonatomic, assign, nullable) id sampleData;
#endif
@property (nonatomic, copy) NSString *uniqueCacheKey;
@property (nonatomic, strong, nullable) NSArray<NSString *> *ignoreCacheCaluKey;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *cacheCaluKeyValue;

@property (nonatomic, strong, nullable) id response;
@property (nonatomic, strong, nullable) NSError *error;

@end

@interface MRTInnerRequest : NSObject<MRTInnerRequest>
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *methed;
@property (nonatomic, strong, nullable) id parameters;
@property (nonatomic, strong, nullable) NSMutableDictionary<NSString *, NSString *> *headers;

@property (nonatomic, assign) BOOL ignorePluginHandle;
@property (nonatomic, assign) BOOL ignoreCommonParamters;
@property (nonatomic, assign) BOOL ignoreCommonHeaders;

@property (nonatomic, assign) BOOL needCache;
#ifdef DEBUG
@property (nonatomic, assign) BOOL preferredSampleData;
@property (nonatomic, assign, nullable) id sampleData;
#endif
@property (nonatomic, copy) NSString *uniqueCacheKey;
@property (nonatomic, strong, nullable) NSArray<NSString *> *ignoreCacheCaluKey;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *cacheCaluKeyValue;

@property (nonatomic, strong, nullable) id response;
@property (nonatomic, strong, nullable) NSError *error;

- (instancetype)initWithRequest:(id<MRTRequest>)request;

@end
NS_ASSUME_NONNULL_END
