//
//  MRTPluginManager.h
//  AFNetworking
//
//  Created by chenyusen on 2018/9/6.
//

#import <Foundation/Foundation.h>
#import "MRTRequest.h"
#import "MRTInnerRequest.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MRTPlugin<NSObject>
@optional
/**
 插件执行优先级, 值越大优先级越高, 不实现默认为1000

 @return 优先级值
 */
- (NSInteger)priority;
@end


/**
 在请求发起前对请求进行处理的插件
 */
@protocol MRTRequestPlugin <MRTPlugin>
@end
@protocol MRTResponsePlugin <MRTPlugin>
@end

/**
 公共参数插件
 */
@protocol MRTCommonInfoPlugin<MRTRequestPlugin>

@optional
- (nullable NSDictionary<NSString *, NSString *> *)headers;

- (nullable NSDictionary<NSString *, NSString *> *)parameters;
@end

/**
 在请求结果返回时对结果进行处理的插件
 */
@protocol MRTResponseHandlePlugin <MRTResponsePlugin>

@optional
/**
 用于处理返回结果, 比如取subObject
 
 @param responseObject 返回结果, 若返回结果为一个NSError对象, 则会被作为错误响应
 @return 处理后的返回结果
 */
- (id)handleResponseObject:(id)responseObject;


/**
 用于处理错误请求
 
 @param error 原错误
 @return 处理后的结果,如果返回非NSError, 则该请求会被处理为响应成功
 */
- (id)handleResponseError:(NSError *)error;
@end


/**
 加密插件
 */
@protocol MRTSecurityPlugin<MRTRequestPlugin, MRTResponsePlugin>
@optional

/// 用来最终加密请求参数
/// @param request 请求对象
- (id)encryptWithRequest:(id<MRTRequest>)request;


/// 用来第一时间解密响应数据
/// @param responseObject 请求对象
- (id)decryptWithResponse:(id)responseObject;


/// 用来计算某个签名参数
/// @param request 请求对象
- (NSDictionary *)signatureWithRequest:(id<MRTRequest>)request;

@end


@interface MRTPluginManager : NSObject

/**
 注册插件

 @param plugin 插件
 */
- (void)registerPlugin:(id<MRTPlugin>)plugin;

/**
 注销插件

 @param plugin 插件
 */
- (void)unregisterPlugin:(id<MRTPlugin>)plugin;

/**
 处理请求发起前

 @param request 请求对象
 @return 返回处理过后的请求对象
 */
- (id<MRTInnerRequest>)handleBeforeRequest:(id<MRTRequest>)request;


/**
 处理响应返回后

 @param request 请求对象
 @return 返回处理后的请求对象
 */
- (id<MRTInnerRequest>)handleAfterResponse:(id<MRTInnerRequest>)request;
@end

NS_ASSUME_NONNULL_END
