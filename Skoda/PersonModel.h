//
//  Person.h
//  Skoda
//
//  Created by Дмитрий Куртеев on 29.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersonModel : NSObject

@property (nonatomic) BOOL isSpecial;
@property (nonatomic) BOOL isEmpty;

@property (nonatomic) NSInteger ID;
@property (nonatomic) BOOL isMe;

@property (strong, nonatomic) NSString *thumbnailUrl;
@property (strong, nonatomic) UIImage *thumbnail;

@property (strong, nonatomic) NSString *photoUrl;
@property (strong, nonatomic) UIImage *photo;

@property (strong, nonatomic) NSString *name;

@property (nonatomic) NSInteger uploadedAt;

@property (nonatomic) BOOL voted;

@property (nonatomic) NSInteger place;
@property (nonatomic) NSInteger total;
@property (nonatomic) NSInteger views;
@property (nonatomic) NSInteger votes;

- (PersonModel *)initWithUserInfo:(NSDictionary *)dict;

@end
