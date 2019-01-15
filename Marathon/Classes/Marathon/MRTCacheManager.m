//
//  MRTCacheManager.m
//  AFNetworking
//
//  Created by chenyusen on 2018/9/6.
//

#import "MRTCacheManager.h"
#import <CommonCrypto/CommonCrypto.h>

static id MRTJSONObjectByRemovingKeysWithNullValues(id JSONObject, NSJSONReadingOptions readingOptions) {
    if ([JSONObject isKindOfClass:[NSArray class]]) {
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[(NSArray *)JSONObject count]];
        for (id value in (NSArray *)JSONObject) {
            [mutableArray addObject:MRTJSONObjectByRemovingKeysWithNullValues(value, readingOptions)];
        }
        
        return (readingOptions & NSJSONReadingMutableContainers) ? mutableArray : [NSArray arrayWithArray:mutableArray];
    } else if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:JSONObject];
        for (id <NSCopying> key in [(NSDictionary *)JSONObject allKeys]) {
            id value = (NSDictionary *)JSONObject[key];
            if (!value || [value isEqual:[NSNull null]]) {
                [mutableDictionary removeObjectForKey:key];
            } else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
                mutableDictionary[key] = MRTJSONObjectByRemovingKeysWithNullValues(value, readingOptions);
            }
        }
        
        return (readingOptions & NSJSONReadingMutableContainers) ? mutableDictionary : [NSDictionary dictionaryWithDictionary:mutableDictionary];
    }
    
    return JSONObject;
}


static NSString *const kCacheDocumentName = @"cached_json_file";

@implementation MRTCacheManager {
    dispatch_queue_t _ioQueue;
}

+ (instancetype)shared {
    static id mgr;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[MRTCacheManager alloc] init];
    });
    return mgr;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _ioQueue = dispatch_queue_create("com.marathon.cache.io", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}
#pragma mark - Public

- (NSString *)cachePath {
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:kCacheDocumentName];
}

- (NSUInteger)getCacheSize {
    __block NSUInteger size = 0;
    dispatch_sync(_ioQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:[self cachePath]];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [[self cachePath] stringByAppendingPathComponent:fileName];
            NSDictionary<NSString *, id> *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            size += [attrs fileSize];
        }
    });
    return size;
}



- (void)clearAllCacheWithCompletion:(void (^)(BOOL success))completion {
    dispatch_async(_ioQueue, ^{
        // tmp文件夹
        NSArray* cacheDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self cachePath]
                                                                                      error:NULL];
        NSError *error;
        for (NSString *file in cacheDirectory) {
            NSString *itemPath = [[self cachePath] stringByAppendingPathComponent:file];;
            [[NSFileManager defaultManager] removeItemAtPath:itemPath
                                                       error:&error];
            if (error) break; // 有error就直接退出
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(!error);
            });
        }
    });
}

- (id)cacheWithRequest:(id<MRTRequest>)request {
    NSLog(@"######取缓存 path=%@", request.path);
    return [self cacheWithKey:[self cacheKeyWithRequest:request]];
}

- (void)setCache:(id)cache withReqeust:(id<MRTRequest>)request completion:(void (^)(BOOL))completion {
    NSLog(@"######存缓存 path=%@", request.path);
    cache = MRTJSONObjectByRemovingKeysWithNullValues(cache, NSJSONReadingMutableContainers);
    
    [self setCache:cache withKey:[self cacheKeyWithRequest:request] completion:completion];
}



#pragma mark - Private

- (NSString *)cacheKeyWithRequest:(id<MRTRequest>)request {
    if ([request respondsToSelector:@selector(uniqueCacheKey)] && request.uniqueCacheKey.length > 0) {
        return request.uniqueCacheKey;
    }
    
    NSMutableDictionary *dict = request.parameters.mutableCopy;
    if ([request respondsToSelector:@selector(ignoreCacheCaluKey)]) {
        for (NSString *key in request.ignoreCacheCaluKey) {
            dict[key] = nil;
        }
    }
    
    if ([request respondsToSelector:@selector(cacheCaluKeyValue)]) {
        NSDictionary *caluDict = [request cacheCaluKeyValue];
        [dict addEntriesFromDictionary:caluDict];
    }
    
    
    NSString *url = [request.path stringByAppendingString:[[self class] dataToJSONString:dict] ?: @""];
    NSString *key = [[self class] md5WithString:url];
    NSLog(@"######url=%@", url);
    NSLog(@"######key=%@", key);
    return key;
}

- (id)cacheWithKey:(NSString *)key {
    if (key.length > 0) {
        NSString* dirName = self.cachePath;
        NSString *filePath = [dirName stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.cache", key]];
        BOOL isDir = YES;
        if (![[NSFileManager defaultManager] fileExistsAtPath:dirName
                                                  isDirectory:&(isDir)]) {
            NSError *error;
            [[NSFileManager defaultManager] createDirectoryAtPath:dirName
                                      withIntermediateDirectories:NO
                                                       attributes:nil
                                                            error:&error];
        }
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            id cachedJSON = [NSDictionary dictionaryWithContentsOfFile:filePath];
            
            if (!cachedJSON) {
                cachedJSON = [NSArray arrayWithContentsOfFile:filePath];
            }
            return cachedJSON;
        }
        return nil;
    } else {
        return nil;
    }
}

- (void)setCache:(id)cache withKey:(NSString *)key completion:(void (^)(BOOL success))completion {
    dispatch_async(_ioQueue, ^{
        NSString *dirName =  [self cachePath];
        NSString *filePath = [dirName stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.cache", key]];
        BOOL success = NO;
        if ([cache isKindOfClass:[NSDictionary class]] && filePath.length > 0) {
            NSDictionary *dict = cache;
            success = [dict writeToFile:filePath
                             atomically:YES];
        } else if ([cache isKindOfClass:[NSArray class]] && filePath.length > 0) {
            NSArray *array = cache;
            success = [array writeToFile:filePath
                              atomically:YES];
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(success);
            });
        }
    });
}

#pragma mark - Tool

+ (NSString *)dataToJSONString:(id)data {
    NSMutableString *jsonString = [NSMutableString string];
    if ([data isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictData = data;
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
        NSArray *descriptors = [NSArray arrayWithObject:descriptor];
        NSArray *sortedKeys = [dictData.allKeys sortedArrayUsingDescriptors:descriptors];
        for (NSString *key in sortedKeys) {
            id value = dictData[key];
            if ([value isKindOfClass:[NSString class]]) {
                [jsonString appendString:[NSString stringWithFormat:@"%@=%@,", key, value]];
            } else if ([value isKindOfClass:[NSNumber class]]) {
                [jsonString appendString:[NSString stringWithFormat:@"%@=%@,", key, [value stringValue]]];
            }
        }
    }
    return jsonString;
    
//    if ([data isKindOfClass:[NSArray class]] || [data isKindOfClass:[NSDictionary class]]) {
//        NSString *jsonString = nil;
//        NSError *error;
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
//                                                           options:NSJSONWritingPrettyPrinted
//                                                             error:&error];
//        if (! jsonData) {
//            NSLog(@"Got an error: %@", error);
//        } else {
//            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        }
//        return jsonString;
//    }
//    return nil;
    
}

+ (NSString *)md5WithString:(NSString *)string {
    const char *cStr = [string UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    NSString *key = [NSString stringWithFormat:
                     @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                     result[0], result[1], result[2], result[3],
                     result[4], result[5], result[6], result[7],
                     result[8], result[9], result[10], result[11],
                     result[12], result[13], result[14], result[15]
                     ];
    return key;
}
@end
