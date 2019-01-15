//
//  Marathon.h
//  AFNetworking
//
//  Created by chenyusen on 2018/9/5.
//

#import <Foundation/Foundation.h>
#import "MRTPluginManager.h"
#import "MRTCacheManager.h"
#import "MRTRequest.h"
#import "MRTCancelable.h"
#import "MRTConfigurator.h"

NS_ASSUME_NONNULL_BEGIN


/**
 映射自AFNetworking的几个网络状态值

 - MRTNetworkReachabilityStatusUnknown: 未知网络状态
 - MRTNetworkReachabilityStatusNotReachable: 网路无法到达
 - MRTNetworkReachabilityStatusReachableViaWWAN: 运营商流量上网
 - MRTNetworkReachabilityStatusReachableViaWiFi: WiFi上网
 */
typedef NS_ENUM(NSInteger, MRTNetworkReachabilityStatus) {
    MRTNetworkReachabilityStatusUnknown          = -1,
    MRTNetworkReachabilityStatusNotReachable     = 0,
    MRTNetworkReachabilityStatusReachableViaWWAN = 1,
    MRTNetworkReachabilityStatusReachableViaWiFi = 2,
};


/**
 网络连接状态改变回调

 @param status 当前状态
 */
typedef void (^MRTNetworkReachabilityStatusBlock)(MRTNetworkReachabilityStatus status);


/**
 Marathon主类, 线程不安全
 */
@interface Marathon : NSObject

/**
 插件中心
 */
@property (nonatomic, strong) MRTPluginManager *pluginManager;


/**
 网络是否可用
 */
@property (readonly, nonatomic, assign, class, getter=isNetworkReachable) BOOL networkReachable;


/**
 当前网络状态
 */
@property (readonly, nonatomic, assign, class) MRTNetworkReachabilityStatus networkReachabilityStatus;


/**
 设置网络状态变化时的监听回调

 @param statusChangeBlock 监听回调
 */
+ (void)setReachabilityStatusChangeBlock:(MRTNetworkReachabilityStatusBlock)statusChangeBlock;


/**
 初始化配置
 
 @param configuration 配置block
 */
- (void)config:(void(^)(MRTConfigurator *configurator))configuration;


/**
 异步请求方法, 请在shared实例下使用

 @param request 请求对象
 @param success 成功回调
 @param failure 失败回调
 @return 返回一个MRTCancelable协议的对象,用于取消请求
 */
- (id<MRTCancelable>)asyncRequest:(id<MRTRequest>)request
                          success:(nullable MRTRequestSuccessBlock)success
                          failure:(nullable MRTRequestFailureBlock)failure;


/**
 异步组请求, 请在shared实例下使用

 @param requestGroup 请求组
 @param completion 请求完成回调
 @return 返回一个MRTCancelable协议的对象,用于取消请求
 */
- (id<MRTCancelable>)asyncRequestGroup:(id<MRTRequestGroup>)requestGroup
                            completion:(nullable MRTGroupRequestCompletionBlock)completion;



/**
 文件上传, 请在uploader实例下使用

 @param path 请求路径
 @param name 服务器取值时的keyname
 @param fileName 存入服务器后的文件名
 @param mimeType mimeType类型
 @param fileData 文件数据
 @param parameters 参数
 @param progress 上传进度
 @param success 成功回调
 @param failure 失败回调
 @return 返回一个MRTCancelable协议的对象,用于取消请求
 */
- (id<MRTCancelable>)uploadWithPath:(NSString *)path
                               name:(NSString *)name
                           fileName:(NSString *)fileName
                           mimeType:(NSString *)mimeType
                           fileData:(NSData *)fileData
                         parameters:(NSDictionary *)parameters
                           progress:(nullable void (^)(NSProgress *))progress
                            success:(nullable MRTRequestSuccessBlock)success
                            failure:(nullable MRTRequestFailureBlock)failure;

/**
 获取缓存的数据
 
 @param request 请求接口
 @return 缓存数据
 */
- (id)fetchCacheWithRequest:(id<MRTRequest>)request;

@end

NS_ASSUME_NONNULL_END
