//
//  InfoTableView.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 11.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "InfoTableView.h"

@interface InfoTableView (Private)

- (void)setup;

@end

@implementation InfoTableView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)display:(float)number
{
    NSNumber *num = [NSNumber numberWithFloat:number];
    NSString *stringNumber = [num stringValue];
    NSString *correctedString;
    
    if ([stringNumber rangeOfString:@"."].location == NSNotFound) {
        correctedString = [NSString stringWithFormat:@"%@.0", stringNumber];
    } else {
        correctedString = stringNumber;
    }
    
    int strLength = [correctedString length];
    
    NSMutableArray *chars = [[NSMutableArray alloc] initWithCapacity:strLength];
    for (int i=0; i < strLength; i++) {
        NSString *ichar  = [NSString stringWithFormat:@"%C", [correctedString characterAtIndex:i]];
        [chars addObject:ichar];
    }
    
    self.d1.image = nil;
    self.d2.image = nil;
    self.d3.image = nil;
    self.d4.image = nil;
    self.d5.image = nil;
    self.d6.image = nil;
    
    for (int i = strLength; i < 7; i++) {
        [chars insertObject:@"" atIndex:0];
    }
    
    NSArray *images = [NSArray arrayWithObjects:self.d1, self.d2, self.d3, self.d4, self.d5, self.p, self.d6, nil];
    
    for (int i = 0; i < [images count]; i++) {
        if ([[chars objectAtIndex:i] isEqualToString:@"."]) {
            [(UIImageView *)[images objectAtIndex:i] setImage:[UIImage imageNamed:@"digit-point"]];
        } else {
            [(UIImageView *)[images objectAtIndex:i] setImage:[UIImage imageNamed:[NSString stringWithFormat:@"digit-%@", [chars objectAtIndex:i]]]];
        }
    }
}

@end

@implementation InfoTableView (Private)

- (void)setup
{
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"info-table"]];
    
    self.d1 = [[UIImageView alloc] initWithFrame:CGRectMake(14.5, 110.5, 9.0, 16.5)];
    self.d2 = [[UIImageView alloc] initWithFrame:CGRectMake(27.5, 110.5, 9.0, 16.5)];
    self.d3 = [[UIImageView alloc] initWithFrame:CGRectMake(40.5, 110.5, 9.0, 16.5)];
    self.d4 = [[UIImageView alloc] initWithFrame:CGRectMake(53.5, 110.5, 9.0, 16.5)];
    self.d5 = [[UIImageView alloc] initWithFrame:CGRectMake(67.0, 110.5, 9.0, 16.5)];
    self.d6 = [[UIImageView alloc] initWithFrame:CGRectMake(85.5, 110.5, 9.0, 16.5)];
    self.p = [[UIImageView alloc] initWithFrame:CGRectMake(80.5, 125.5, 1.5, 1.5)];
    
    [self addSubview:self.d1];
    [self addSubview:self.d2];
    [self addSubview:self.d3];
    [self addSubview:self.d4];
    [self addSubview:self.d5];
    [self addSubview:self.d6];
    [self addSubview:self.p];
    
    [self display:0];
}

@end