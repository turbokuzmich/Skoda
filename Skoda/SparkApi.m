//
//  SparkApi.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 05.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "SparkApi.h"

@implementation SparkApi

+ (SparkApi *)instance
{
    static SparkApi *sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SparkApi alloc] init];
    });
    
    return sharedInstance;
}

- (void)parseJSON:(NSDictionary *)json
{
    self.raw = json;
}

- (void)parseString:(NSString *)string
{
    self.raw = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:NULL];
}

- (BOOL)isSuccess
{
    if (self.raw != nil) {
        NSString *status = [self.raw objectForKey:@"status"];
        
        return [status isEqualToString:@"success"];
    }
    
    return NO;
}

- (NSDictionary *)data
{
    if (self.raw) {
        return [self.raw objectForKey:@"data"];
    }
    
    return nil;
}

- (NSDictionary *)errors
{
    if (self.raw) {
        return [self.raw objectForKey:@"error"];
    }
    
    return nil;
}

- (NSString *)errorDescription
{
    NSMutableArray *errors = [NSMutableArray array];
    NSDictionary *errorDict = self.errors;
    
    [errorDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [errors addObject:obj];
    }];
    
    return [errors componentsJoinedByString:@". "];
}

@end
