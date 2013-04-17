//
//  PersonManager.h
//  Skoda
//
//  Created by Дмитрий Куртеев on 01.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#define kPersonManagerMeChanged @"PersonManagerMeChanged"

typedef enum {
    PersonManagerErrorCodeFull = 0,
    PersonManagerErrorCodeUnknownError,
    PersonManagerErrorCodeServerError
} PersonManagerErrorCode;

static int const offsetSize = 100;
static int const maxOffsetCount = 5;

typedef void (^PersonManagerLoadBlock)(NSError **error);

#import "PersonModel.h"
#import <Foundation/Foundation.h>

@interface PersonManager : NSObject

@property (nonatomic, readonly) BOOL isLoading;
@property (nonatomic, readonly) int index;
@property (nonatomic, strong) PersonManagerLoadBlock loadBlock;

+ (PersonManager *)sharedInstance;

- (void)load:(PersonManagerLoadBlock)complete;
- (NSInteger)count;
- (NSInteger)generalCount; // количество людишем без special и empty
- (NSInteger)pagesCount;
- (void)reset;
- (void)purgeModelImages;
- (PersonModel *)personAtIndex:(NSInteger)pIndex;

@end
