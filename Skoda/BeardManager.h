//
//  BeardManager.h
//  Skoda
//
//  Created by Дмитрий Куртеев on 26.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#define kBeardManagerBeardsLoaded @"BeardManagerBeardsLoaded"

static NSString * const BeardVersionKey = @"beard_version";
static NSString * const BeardLargeName = @"beard_large.png";
static NSString * const BeardSmallName = @"beard_small.png";

#import <Foundation/Foundation.h>

typedef enum {
    BeardManagerSpriteTypeLarge = 0,
    BeardManagerSpriteTypeSmall
} BeardManagerSpriteType;

typedef void (^CheckBlock)(BOOL uptodate, NSError *error);

@interface BeardManager : NSObject

@property (nonatomic, strong) NSString *beardLargeUrl;
@property (nonatomic, strong) NSString *beardSmallUrl;
@property (nonatomic, strong) UIImage *largeSprite;
@property (nonatomic, strong) UIImage *smallSprite;
@property (nonatomic) CGSize largeSpriteFrameSize;
@property (nonatomic) CGSize smallSpriteFrameSize;
@property (nonatomic) NSString *version;

+ (BeardManager *)instance;

- (void)load;
- (UIImage *)frameForIndex:(unsigned int)index andType:(BeardManagerSpriteType)type;
- (int)framesCount;
- (void)checkVersion:(CheckBlock)checkBlock;
- (void)reset;

@end
