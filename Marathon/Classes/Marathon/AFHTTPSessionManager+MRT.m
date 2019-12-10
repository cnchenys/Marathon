//
//  AFHTTPSessionManager+MRT.m
//  AFNetworking
//
//  Created by chenyusen on 2018/9/6.
//

#import "AFHTTPSessionManager+MRT.h"

@implementation AFHTTPSessionManager (MRT)
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                   encryptedData:(id)encryptedData
                                 timeoutInterval:(NSTimeInterval)timeoutInterval
                                         headers:(NSDictionary <NSString *, NSString *>*)headers
                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:encryptedData ? nil : parameters error:&serializationError];
    
    if (encryptedData) {
        if ([encryptedData isKindOfClass:[NSData class]]) {
            [request setHTTPBody:encryptedData];
        } else if ([encryptedData isKindOfClass:[NSString class]]) {
            [request setHTTPBody:[((NSString *)encryptedData) dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    request.timeoutInterval = timeoutInterval;
    
    [headers enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
        [request setValue:value forHTTPHeaderField:field];
    }];
    
    if (serializationError) {
        if (failure) {
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
        }
        
        return nil;
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self dataTaskWithRequest:request
                          uploadProgress:uploadProgress
                        downloadProgress:downloadProgress
                       completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
                           if (error) {
                               if (failure) {
                                   failure(dataTask, error);
                               }
                           } else {
                               if (success) {
                                   success(dataTask, responseObject);
                               }
                           }
                       }];
    
    return dataTask;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
               timeoutInterval:(NSTimeInterval)timeoutInterval
                       headers:(NSDictionary <NSString *, NSString *>*)headers
                    parameters:(id)parameters
                 encryptedData:(id)encryptedData
     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                      progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:encryptedData ? nil : parameters constructingBodyWithBlock:block error:&serializationError];
    
    request.timeoutInterval = timeoutInterval;
    
    [headers enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
        [request setValue:value forHTTPHeaderField:field];
    }];
    
    if (serializationError) {
        if (failure) {
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
        }
        
        return nil;
    }
    
    __block NSURLSessionDataTask *task = [self uploadTaskWithStreamedRequest:request progress:uploadProgress completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        if (error) {
            if (failure) {
                failure(task, error);
            }
        } else {
            if (success) {
                success(task, responseObject);
            }
        }
    }];
    
    [task resume];
    
    return task;
}
@end
