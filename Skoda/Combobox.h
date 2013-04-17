//
//  Combobox.h
//  Skoda
//
//  Created by Дмитрий Куртеев on 28.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "SBTableAlert.h"
#import <UIKit/UIKit.h>

@interface Combobox : UIButton <SBTableAlertDelegate, SBTableAlertDataSource>

@property (nonatomic, strong) NSArray *values;
@property (nonatomic, strong) NSString *caption;

- (NSString *)value;
- (void)setValue:(NSString *)value;

@end
