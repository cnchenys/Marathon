//
//  MRTRequest.h
//  Pods
//
//  Created by chenyusen on 2018/9/11.
//

#ifndef MRTRequest_h
#define MRTRequest_h
#import <Foundation/Foundation.h>
#import "MRTCancelable.h"

NS_ASSUME_NONNULL_BEGIN
/**
 请求成功回调
 
 @param data 请求成功数据
 */
typedef void(^MRTRequestSuccessBlock)(id _Nullable data);

/**
 请求失败回调
 
 @param error 失败实例
 */
typedef void(^MRTRequestFailureBlock)(NSError * _Nullable error);

/**
 组请求完成回调

 @param completion 完成回调
 */
typedef void(^MRTGroupRequestCompletionBlock)(NSDictionary * _Nullable completion);




@protocol MRTCacheable <NSObject>

@optional
/**
 是否需要缓存

 @return 是否需要缓存
 */
- (BOOL)needCache;


/**
 设置此值后,缓存的存取Key将直接使用该值而不计算, 请勿出现重复值

 @return 缓存存储值
 */
- (NSString *)uniqueCacheKey;

/**
 过滤指定key参与缓存key的计算
 例如一些定位信息,经纬度经度较高,稍微的偏差,就会造成缓存不命中,可根据业务需求,过滤相关key值

 @return 需要过滤的key集合
 */
- (NSArray<NSString *> *)ignoreCacheCaluKey;


/**
 额外参与缓存key值计算的键值对
 一些情况下, 用户信息或则例如手动降低经纬度后的重新传值等操作可以通过此方法传入

 @return 需要参与缓存计算的键值对
 */
- (NSDictionary <NSString *, id> *)cacheCaluKeyValue;
@end


@protocol MRTRequest<MRTCacheable>
@optional
/**
 控制当前请求的超时时长, 如果不设置, 则默认走全局配置

 @return 超时时长
 */
- (NSTimeInterval)timeoutInterval;


/**
 当前请求的路径, 如果为全路径, 则将忽略全局设置的baseUrl

 @return 请求路径
 */
- (NSString *)path;


/**
 当前请求的方法 @"GET"、@"POST"、@"PUT"、@"DELETE", 默认为@"GET"

 @return 请求方式
 */
- (NSString *)methed;

/**
 当前请求参数
 
 @return 参数
 */
- (NSDictionary *)parameters;


/**
 给当前请求请求头添加参数

 @return 请求头
 */
- (NSDictionary<NSString *, NSString *> *)headers;

/**
 是否忽略插件处理, 默认不忽略, 如果忽略, 则ignoreCommonParamters和ignoreCommonHeaders都会生效
 
 @return 是否忽略
 */
- (BOOL)ignorePluginHandle;

/**
 是否忽略公共参数, 默认不忽略
 
 @return 是否忽略
 */
- (BOOL)ignoreCommonParamters;

/**
 是否忽略公共请求头, 默认不忽略
 
 @return 是否忽略
 */
- (BOOL)ignoreCommonHeaders;

#ifdef DEBUG
/** 优先使用测试数据 */
- (BOOL)preferredSampleData;

/**
 测试数据, 用于接口调试时使用

 @return 测试数据
 */
- (id)sampleData;
#endif

/**
 异步发起请求
 
 @param success 成功请求回调
 @param failure 失败请求回调
 @return 返回可以取消请求的实例
 */
- (id<MRTCancelable>)asyncRequestSuccess:(nullable MRTRequestSuccessBlock)success
                                 failure:(nullable MRTRequestFailureBlock)failure;
@end

@protocol MRTRequestGroup <NSObject>

/**
 参与并发请求的请求数组

 @return 请求数组
 */
- (NSArray<id<MRTRequest>> *)requests;

@optional


/**
 请求数组完成回调, 如果实现该方法, 则Marathon将使用此方法处理回调

 @param completion 完成回调
 @return 返回可以取消请求的实例
 */
- (id<MRTCancelable>)asyncGroupRequestWithCompletion:(nullable MRTGroupRequestCompletionBlock)completion;
@end

NS_ASSUME_NONNULL_END

#endif /* MRTRequest_h */
