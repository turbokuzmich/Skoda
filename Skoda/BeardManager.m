//
//  BeardManager.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 26.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "api.h"
#import "MBProgressHUD.h"
#import "MKNetworkKit/MKNetworkKit.h"
#import "BeardManager.h"

@interface BeardManager (Private)

- (BOOL)_imagesReady;
- (void)_fetchCurrentVersion;
- (void)_updateCurrentVersion:(NSString *)newVersion;
- (void)_fetchSavedSprites;
- (NSUserDefaults *)_userDefaults;

@end

@implementation BeardManager
{
    NSString *_newVersion;
}

@synthesize largeSprite;
@synthesize smallSprite;
@synthesize largeSpriteFrameSize;
@synthesize smallSpriteFrameSize;
@synthesize version;

+ (BeardManager *)instance
{
    static BeardManager *sharedInstance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[BeardManager alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self _fetchSavedSprites];
        [self _fetchCurrentVersion];
    }
    return self;
}

- (void)load
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData *smallBeardData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ApiDomain, self.beardSmallUrl]]];
        NSData *largeBeardData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ApiDomain, self.beardLargeUrl]]];
        
        // пишем в файлики
        NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectoryPath = [directories objectAtIndex:0];
        NSString *beardSmallPath = [documentDirectoryPath stringByAppendingPathComponent:BeardSmallName];
        NSString *beardLargePath = [documentDirectoryPath stringByAppendingPathComponent:BeardLargeName];
        
        NSFileManager *manager = [NSFileManager defaultManager];
        
        if ([manager fileExistsAtPath:beardSmallPath] && [manager fileExistsAtPath:beardLargePath]) {
            [manager removeItemAtPath:beardSmallPath error:nil];
            [manager removeItemAtPath:beardLargePath error:nil];
        }
        
        [smallBeardData writeToFile:beardSmallPath atomically:YES];
        [largeBeardData writeToFile:beardLargePath atomically:YES];
        
        [self _updateCurrentVersion:_newVersion];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.smallSprite = [UIImage imageWithData:smallBeardData];
            self.largeSprite = [UIImage imageWithData:largeBeardData];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kBeardManagerBeardsLoaded object:self];
        });
    });
}

- (UIImage *)frameForIndex:(unsigned int)index andType:(BeardManagerSpriteType)type
{
    if ([self _imagesReady]) {
        UIImage *originalImage;
        UIImage *croppedImage;
        CGSize frameSize;
        
        if (type == BeardManagerSpriteTypeLarge) {
            originalImage = self.largeSprite;
            frameSize = self.largeSpriteFrameSize;
        } else {
            originalImage = self.smallSprite;
            frameSize = self.smallSpriteFrameSize;
        }
        
        CGRect cropRect;
        cropRect.origin.x = frameSize.width * index;
        cropRect.origin.y = 0;
        cropRect.size.width = frameSize.width;
        cropRect.size.height = frameSize.height;
        
        CGImageRef originalImageRef = CGImageCreateWithImageInRect([originalImage CGImage], cropRect);
        croppedImage = [UIImage imageWithCGImage:originalImageRef];
        CGImageRelease(originalImageRef);
        
        return croppedImage;
    }
    
    return nil;
}

- (int)framesCount
{
    if ([self _imagesReady]) {
        return (int)(self.largeSprite.size.width / self.largeSpriteFrameSize.width);
    }
    
    return 0;
}

- (void)checkVersion:(CheckBlock)checkBlock
{
    NSError __block *error = nil;
    BeardManager __weak *weakSelf = self;
    
    if (_newVersion != nil && ![_newVersion isEqualToString:self.version]) {
        checkBlock(NO, error);
    } else {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.version, @"version",
                                nil];
        
        MKNetworkOperation *checkOperation = [[MKNetworkOperation alloc] initWithURLString:ApiBeardManagerCheckUrl params:params httpMethod:@"GET"];
        
        [checkOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            NSDictionary *response = completedOperation.responseJSON;
            NSString *status = [response objectForKey:@"status"];
            NSDictionary *data = [response objectForKey:@"data"];
            
            if ([status isEqualToString:@"success"]) {
                NSDictionary *spriteDict = [data objectForKey:@"sprite"];
                NSString *v = [(NSNumber *)[spriteDict objectForKey:@"version"] stringValue];
                weakSelf.beardSmallUrl = [spriteDict objectForKey:@"small"];
                weakSelf.beardLargeUrl = [spriteDict objectForKey:@"large"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([v isEqualToString:self.version]) {
                        checkBlock(YES, error);
                    } else {
                        _newVersion = v;
                        checkBlock(NO, error);
                    }
                });
            } else {
                error = [NSError errorWithDomain:@"beardcheck" code:404 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Бороды не доступны", NSLocalizedDescriptionKey, nil]];
                checkBlock(YES, error);
            }
            
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            error = [NSError errorWithDomain:@"beardcheck" code:503 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Возникла ошибка при образении к серверу", NSLocalizedDescriptionKey, nil]];
            checkBlock(YES, error);
        }];
        
        MKNetworkEngine *engine = [[MKNetworkEngine alloc] init];
        [engine enqueueOperation:checkOperation];
    }
}

- (void)reset
{
    [[self _userDefaults] setObject:@"0" forKey:BeardVersionKey];
    [[self _userDefaults] synchronize];
    
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectoryPath = [directories objectAtIndex:0];
    NSString *beardSmallPath = [documentDirectoryPath stringByAppendingPathComponent:BeardSmallName];
    NSString *beardLargePath = [documentDirectoryPath stringByAppendingPathComponent:BeardLargeName];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:beardSmallPath] && [manager fileExistsAtPath:beardLargePath]) {
        [manager removeItemAtPath:beardSmallPath error:nil];
        [manager removeItemAtPath:beardLargePath error:nil];
    }
}

@end

@implementation BeardManager (Private)

- (BOOL)_imagesReady
{
    return (self.largeSprite != nil && self.smallSprite != nil);
}

- (void)_fetchCurrentVersion
{
    NSString *v = [[self _userDefaults] objectForKey:BeardVersionKey];
    
    if (v == nil) {
        self.version = @"0";
    } else {
        self.version = v;
    }
}

- (void)_updateCurrentVersion:(NSString *)newVersion
{
    NSUserDefaults *defaults = [self _userDefaults];
    
    [defaults setObject:newVersion forKey:BeardVersionKey];
    [defaults synchronize];
    
    _newVersion = nil;
}

- (void)_fetchSavedSprites
{
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectoryPath = [directories objectAtIndex:0];
    NSString *beardSmallPath = [documentDirectoryPath stringByAppendingPathComponent:BeardSmallName];
    NSString *beardLargePath = [documentDirectoryPath stringByAppendingPathComponent:BeardLargeName];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:beardSmallPath] && [manager fileExistsAtPath:beardLargePath]) {
        self.smallSprite = [UIImage imageWithData:[NSData dataWithContentsOfFile:beardSmallPath]];
        self.largeSprite = [UIImage imageWithData:[NSData dataWithContentsOfFile:beardLargePath]];
    }
}

- (NSUserDefaults *)_userDefaults
{
    static NSUserDefaults *defs;
    
    if (!defs) {
        defs = [NSUserDefaults standardUserDefaults];
    }
    
    return defs;
}

@end