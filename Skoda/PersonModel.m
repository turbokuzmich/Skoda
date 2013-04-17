//
//  Person.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 29.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "api.h"
#import "PersonModel.h"

@implementation PersonModel

- (PersonModel *)initWithUserInfo:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _ID = [[dict objectForKey:@"id"] intValue];
        _isMe = [[dict objectForKey:@"owner"] boolValue];
        _thumbnailUrl = [dict objectForKey:@"img_thumb"];
        _photoUrl = [dict objectForKey:@"img"];
        _name = [dict objectForKey:@"name"];
        _uploadedAt = [[dict objectForKey:@"uploaded"] intValue];
        _voted = [[dict objectForKey:@"voted"] boolValue];
        _place = [[dict objectForKey:@"place"] intValue];
        _total = [[dict objectForKey:@"total_photos"] intValue];
        _views = [[dict objectForKey:@"views"] intValue];
        _votes = [[dict objectForKey:@"votes"] intValue];
    }
    return self;
}

- (UIImage *)thumbnail
{
    if (_thumbnail == nil && self.thumbnailUrl) {
        _thumbnail = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ApiDomain, self.thumbnailUrl]]]];
    }
    
    return _thumbnail;
}

- (UIImage *)photo
{
    if (_photo == nil && self.photoUrl) {
        _photo = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ApiDomain, self.photoUrl]]]];
    }
    
    return _photo;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Person #%d, special %d, empty - %d", self.ID, self.isSpecial, self.isEmpty];
}

@end
