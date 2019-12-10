//
//  AFHTTPSessionManager+MRT.h
//  AFNetworking
//
//  Created by chenyusen on 2018/9/6.
//

#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

@interface AFHTTPSessionManager (MRT)


- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                   encryptedData:(id)encryptedData
                                 timeoutInterval:(NSTimeInterval)timeoutInterval
                                         headers:(NSDictionary <NSString *, NSString *>*)headers
                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;


- (NSURLSessionDataTask *)POST:(NSString *)URLString
               timeoutInterval:(NSTimeInterval)timeoutInterval
                       headers:(NSDictionary <NSString *, NSString *>*)headers
                    parameters:(id)parameters
                 encryptedData:(id)encryptedData
     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                      progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
