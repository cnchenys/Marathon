//
//  MRTConfigurator.h
//  AFNetworking
//
//  Created by chenyusen on 2018/12/18.
//

#import <Foundation/Foundation.h>
#import "MRTPluginManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface MRTRequestSerializer : NSObject
/**
 默认请求超时时间, 默认为10s
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

@property (nonatomic, assign) BOOL useJson;

@end


@interface MRTResponseSerializer : NSObject
@property (nonatomic, copy, nullable) NSSet <NSString *> *acceptableContentTypes;
@end

@interface MRTConfigurator : NSObject
/**
 默认baseURL
 */
@property (nonatomic, strong, nullable) NSURL *baseURL;


/**
 请求序列化器
 */
@property (nonatomic, strong) MRTRequestSerializer *requestSerializer;


/**
 响应序列化器
 */
@property (nonatomic, strong) MRTResponseSerializer *responseSerializer;


/**
 请求响应处理插件
 */
@property (nonatomic, strong, nullable) NSArray<id<MRTPlugin>> *plugins;


/**
 公共默认忽略的用于缓存计算参数, 例如恶心的时间戳啊, 网络状态啊,地理经纬度啊
 */
@property (nonatomic, strong) NSArray *ignoreCacheCaluKey;

@end

NS_ASSUME_NONNULL_END
