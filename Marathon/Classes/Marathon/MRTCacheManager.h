//
//  MRTCacheManager.h
//  AFNetworking
//
//  Created by chenyusen on 2018/9/6.
//

#import <Foundation/Foundation.h>
#import "MRTRequest.h"

NS_ASSUME_NONNULL_BEGIN
@interface MRTCacheManager : NSObject
/**
 默认单例
 */
@property (nonatomic, strong, readonly, class) MRTCacheManager *shared;


/**
 获取缓存路径

 @return 缓存路径
 */
- (NSString *)cachePath;


/**
 获取缓存大小(单位bit)

 @return 缓存大小
 */
- (NSUInteger)getCacheSize;


/**
 通过一个MRTRequest协议对象获取对应的缓存对象

 @param request MRTRequest协议对象
 @return 缓存对象
 */
- (nullable id)cacheWithRequest:(id<MRTRequest>)request;


/**
 通过一个MRTRequest协议对象设置响应缓存

 @param cache 缓存
 @param request 协议对象
 @param completion 存储结果
 */
- (void)setCache:(id)cache withReqeust:(id<MRTRequest>)request completion:(void (^_Nullable)(BOOL success))completion;



/**
 通过指定键获取缓存数据

 @param key 指定键
 @return 缓存数据
 */
- (nullable id)cacheWithKey:(NSString *)key;

/**
 通过指定Key值设置缓存数据

 @param cache 缓存数据
 @param key 指定键
 @param completion 完成回调
 */
- (void)setCache:(id)cache withKey:(NSString *)key completion:(void (^ _Nullable)(BOOL success))completion;

/**
 清空所有

 @param completion 清空结果回调
 */
- (void)clearAllCacheWithCompletion:(void (^_Nullable)(BOOL success))completion;

@end
NS_ASSUME_NONNULL_END
