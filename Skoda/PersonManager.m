//
//  PersonManager.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 01.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#define PersonsPerPage 24

#import "api.h"
#import "AuthManager.h"
#import "SparkApi.h"
#import "MKNetworkKit/MKNetworkKit.h"
#import "PersonManager.h"

static NSString * const ErrorDomain = @"PersonManagerError";

@interface PersonManager (Private)

- (NSString *)_timestamp;
- (void)_startLoad;
- (void)_loadEnded:(NSError **)error;
- (void)_checkMe;
- (void)_correctData;

@end

@implementation PersonManager
{
    NSMutableArray *_data;
}

+ (PersonManager *)sharedInstance
{
    static PersonManager *instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[PersonManager alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self reset];
        
        // если мы залогинились, нужно проверить, какая фотка моя
        // если мы разлогинились, тоже нужно все вернуть на место
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_checkMe) name:kAuthManagerBeardIdChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_checkMe) name:kAuthManagerLogoutSuccess object:nil];
    }
    return self;
}

- (void)load:(PersonManagerLoadBlock)complete
{
    if (!_isLoading) {
        [self reset];
        
        _isLoading = YES;
        self.loadBlock = complete;
        
        [self _startLoad];
    }
}

- (NSInteger)count
{
    return _data.count;
}

- (NSInteger)generalCount
{
    int count = 0;
    PersonModel *person;
    
    for (int i = 0; i < _data.count; i++) {
        person = [_data objectAtIndex:i];
        
        if (!person.isEmpty && !person.isSpecial) count++;
    }
    
    return count;
}

- (NSInteger)pagesCount
{
    return _data.count / PersonsPerPage;
}

- (PersonModel *)personAtIndex:(NSInteger)pIndex
{
    if ([_data count] > pIndex) {
        return (PersonModel *)[_data objectAtIndex:pIndex];
    }
    
    return nil;
}

- (void)reset
{
    _data = nil;
    _data = [[NSMutableArray alloc] init];
    _isLoading = NO;
    _index = -1;
}

- (void)purgeModelImages
{
    PersonModel *person;
    
    for (int i = 0; i < _data.count; i++) {
        person = [self personAtIndex:i];
        person.thumbnail = nil;
        person.photo = nil;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@implementation PersonManager (Private)

- (NSString *)_timestamp
{
    NSInteger time = 0;
    
    if ([_data count] > 0) {
        time = [(PersonModel *)[_data objectAtIndex:0] uploadedAt];
    }
    
    return [NSString stringWithFormat:@"%d", time];
}

- (void)_correctData
{
    PersonModel *specialPerson = [[PersonModel alloc] init];
    specialPerson.isSpecial = YES;
    specialPerson.isEmpty = NO;
    
    PersonModel *emptyPerson = [[PersonModel alloc] init];
    emptyPerson.isSpecial = NO;
    emptyPerson.isEmpty = YES;
    
    // если даже первых нет, то добавляем
    if (_data.count < 7) {
        int topEmptyCount = 7 - _data.count;
        
        for (int i = 0; i < topEmptyCount; i++) {
            [_data addObject:emptyPerson];
        }
    }
    
    [_data insertObject:specialPerson atIndex:7];
    
    int startIndex = 10;
    for (int i = 0; i < 8; i++) {
        [_data insertObject:specialPerson atIndex:(startIndex + i)];
    }
    
    int pagesCount = ceil((float)_data.count / PersonsPerPage);
    if (pagesCount < 2) {
        pagesCount = 2;
    }
    int personsNeeded = pagesCount * PersonsPerPage;
    
    if (_data.count < personsNeeded) {
        int bottomEmptyCount = personsNeeded - _data.count;
        
        for (int i = 0; i < bottomEmptyCount; i++) {
            [_data addObject:emptyPerson];
        }
    }
}

- (void)_startLoad
{
    _index++;
    
    NSError __block *error = nil;
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:_index * offsetSize], @"offset", [NSNumber numberWithInt:offsetSize], @"limit", [self _timestamp], @"time", nil];
    MKNetworkOperation *loadOperation = [[MKNetworkOperation alloc] initWithURLString:ApiPhotosListUrls params:params httpMethod:@"GET"];
    
    [loadOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        SparkApi *api = [SparkApi instance];
        [api parseJSON:completedOperation.responseJSON];
        
        if (api.isSuccess) {
            NSArray *data = [api.raw objectForKey:@"data"];
            
            if ([data count] > 0) {
                [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSDictionary *dict = (NSDictionary *)obj;
                    
                    NSString *name = [dict objectForKey:@"name"];
                    if ([name isEqual:[NSNull null]]) {
                        name = @"Инкогнито";
                    }
                    NSString *thumbnailUrl = [dict objectForKey:@"img_thumb"];
                    if ([thumbnailUrl isEqual:[NSNull null]]) {
                        thumbnailUrl = @"";
                    }
                    NSString *photoUrl = [dict objectForKey:@"img"];
                    if ([photoUrl isEqual:[NSNull null]]) {
                        photoUrl = @"";
                    }
                    
                    PersonModel *newPerson = [[PersonModel alloc] init];
                    
                    newPerson.isSpecial     = NO;
                    newPerson.isEmpty       = NO;
                    newPerson.ID            = [(NSNumber *)[dict objectForKey:@"id"] intValue];
                    newPerson.isMe          = [[dict objectForKey:@"owner"] boolValue];
                    newPerson.thumbnailUrl  = thumbnailUrl;
                    newPerson.photoUrl      = photoUrl;
                    newPerson.name          = name;
                    newPerson.uploadedAt    = [(NSNumber *)[dict objectForKey:@"uploaded"] intValue];
                    newPerson.place         = [(NSNumber *)[dict objectForKey:@"place"] intValue];
                    newPerson.views         = [(NSNumber *)[dict objectForKey:@"views"] intValue];
                    newPerson.votes         = [(NSNumber *)[dict objectForKey:@"votes"] intValue];
                    newPerson.voted         = [[dict objectForKey:@"voted"] boolValue];
                    newPerson.total         = [(NSNumber *)[dict objectForKey:@"total_photos"] intValue];
                    
                    [_data addObject:newPerson];
                }];
            } else {
                error = [NSError errorWithDomain:ErrorDomain code:PersonManagerErrorCodeFull userInfo:nil];
            }
        } else {
            error = [NSError errorWithDomain:ErrorDomain code:PersonManagerErrorCodeUnknownError userInfo:nil];
        }
        
        [self _loadEnded:&error];
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        error = [NSError errorWithDomain:ErrorDomain code:PersonManagerErrorCodeServerError userInfo:nil];
        [self _loadEnded:&error];
    }];
    
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] init];
    [engine enqueueOperation:loadOperation];
}

- (void)_loadEnded:(NSError *__autoreleasing *)error
{
    if (*error == nil) {
        if (_index == maxOffsetCount - 1) {
            _isLoading = NO;
            
            [self _correctData];
            self.loadBlock(nil);
        } else {
            [self _startLoad];
        }
    } else {
        _isLoading = NO;
        
        if ([*error code] == PersonManagerErrorCodeFull) {
            [self _correctData];
            self.loadBlock(nil);
        } else {
            self.loadBlock(error);
        }
    }
}

- (void)_checkMe
{
    AuthManager *auth = [AuthManager instance];
    PersonModel *model;
    NSInteger beardId;
    
    if ([auth isSession] && [auth isBeard]) {
        beardId = [[auth beardId] intValue];
        
        for (int i = 0; i < [self count]; i++) {
            model = [_data objectAtIndex:i];
            
            if (model.ID == beardId) {
                model.isMe = YES;
            }
        }
    } else {
        for (int i = 0; i < [self count]; i++) {
            [[_data objectAtIndex:i] setIsMe:NO];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPersonManagerMeChanged object:nil];
}

@end