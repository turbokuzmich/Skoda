//
//  SparkApi.h
//  Skoda
//
//  Created by Дмитрий Куртеев on 05.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SparkApi : NSObject

@property (strong, nonatomic) NSDictionary *raw;

+ (SparkApi *)instance;

- (void)parseJSON:(NSDictionary *)json;
- (void)parseString:(NSString *)string;

- (BOOL)isSuccess;

- (NSDictionary *)data;
- (NSDictionary *)errors;

- (NSString *)errorDescription;

@end
