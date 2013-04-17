//
//  Combobox.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 28.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "Combobox.h"

#pragma mark - Combobox (Private);

@interface Combobox (Private)

- (void)setup;
- (SBTableAlert *)alertView;
- (UILabel *)valueLabel;
- (int)valueInList:(NSString *)value;

@end

#pragma mark - Combobox

@implementation Combobox
{
    SBTableAlert *_alertView;
    UILabel *_valueLabel;
}

@synthesize values;
@synthesize caption;

- (NSString *)value
{
    if (_valueLabel != nil) {
        return _valueLabel.text;
    }
    
    return @"";
}

- (void)setValue:(NSString *)value
{
    if ([self valueInList:value] != NSNotFound) {
        self.valueLabel.text = value;
    }
}

#pragma mark - SBTableAlertDelegate

- (void)tableAlert:(SBTableAlert *)tableAlert didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.valueLabel.text = [self.values objectAtIndex:indexPath.row];
}

#pragma mark - SBTableAlertDataSource

- (UITableViewCell *)tableAlert:(SBTableAlert *)tableAlert cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableAlert.tableView dequeueReusableCellWithIdentifier:@"ComboAlertCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ComboAlertCell"];
        
        CGRect cellBounds = cell.contentView.bounds;
        cellBounds.origin.x += 5;
        
        UILabel *cellLabel = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
        [cellLabel setFrame:cellBounds];
        
        [cell.contentView addSubview:cellLabel];
    }
    
    [(UILabel *)[cell.contentView.subviews objectAtIndex:0] setText:[self.values objectAtIndex:indexPath.row]];
    
    return cell;
}

- (NSInteger)tableAlert:(SBTableAlert *)tableAlert numberOfRowsInSection:(NSInteger)section
{
    return self.values.count;
}

#pragma mark - UIButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* borderColor = [UIColor colorWithRed: 0.685 green: 0.696 blue: 0.71 alpha: 1];
    UIColor* bodyGradientColor = [UIColor colorWithRed: 0.797 green: 0.797 blue: 0.797 alpha: 1];
    UIColor* dividerColor = [UIColor colorWithRed: 0.86 green: 0.86 blue: 0.86 alpha: 1];
    
    //// Gradient Declarations
    NSArray* bodyGradientColors = [NSArray arrayWithObjects:
                                   (id)bodyGradientColor.CGColor,
                                   (id)[UIColor whiteColor].CGColor, nil];
    CGFloat bodyGradientLocations[] = {0, 1};
    CGGradientRef bodyGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)bodyGradientColors, bodyGradientLocations);
    
    //// Rounded Rectangle Drawing
    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0.5, 0.5, rect.size.width - 1, rect.size.height - 1) cornerRadius: 6];
    CGContextSaveGState(context);
    [roundedRectanglePath addClip];
    CGContextDrawLinearGradient(context, bodyGradient, CGPointMake(0, 29.5), CGPointMake(0, 0.5), 0);
    CGContextRestoreGState(context);
    [borderColor setStroke];
    roundedRectanglePath.lineWidth = 1;
    [roundedRectanglePath stroke];
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(rect.size.width - 29, 1)];
    [bezierPath addLineToPoint: CGPointMake(rect.size.width - 29, rect.size.height - 1)];
    [bezierPath closePath];
    [[UIColor whiteColor] setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(rect.size.width - 30, 1)];
    [bezier2Path addLineToPoint: CGPointMake(rect.size.width - 30, rect.size.height - 1)];
    [bezier2Path closePath];
    [dividerColor setStroke];
    bezier2Path.lineWidth = 1;
    [bezier2Path stroke];
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(rect.size.width - 21.5, 13.5)];
    [bezier3Path addLineToPoint: CGPointMake(rect.size.width - 15.5, 19.5)];
    [bezier3Path addLineToPoint: CGPointMake(rect.size.width - 9.5, 13.5)];
    [bezier3Path addLineToPoint: CGPointMake(rect.size.width - 12.5, 13.5)];
    [bezier3Path addLineToPoint: CGPointMake(rect.size.width - 15.5, 16.5)];
    [bezier3Path addLineToPoint: CGPointMake(rect.size.width - 18.5, 13.5)];
    [bezier3Path addLineToPoint: CGPointMake(rect.size.width - 21.5, 13.5)];
    [bezier3Path closePath];
    [borderColor setFill];
    [bezier3Path fill];
    
    
    //// Cleanup
    CGGradientRelease(bodyGradient);
    CGColorSpaceRelease(colorSpace);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.alertView show];
}

- (void)dealloc
{
    _alertView = nil;
    _valueLabel = nil;
}

@end

#pragma mark - Combobox (Private);

@implementation Combobox (Private)

- (void)setup
{
    CGRect selfFrame = self.frame;
    selfFrame.size.height = 30;
    [self setFrame:selfFrame];
    
    self.backgroundColor = [UIColor clearColor];
}

- (SBTableAlert *)alertView
{
    if (_alertView == nil) {
        _alertView = [SBTableAlert alertWithTitle:self.caption cancelButtonTitle:@"Отмена" messageFormat:nil];
        _alertView.type = SBTableAlertTypeSingleSelect;
        _alertView.style = SBTableAlertStyleApple;
        _alertView.delegate = self;
        _alertView.dataSource = self;
    }
    
    return _alertView;
}

- (UILabel *)valueLabel
{
    if (_valueLabel == nil) {
        CGRect selfBounds = self.bounds;
        selfBounds.size.width -= 38;
        selfBounds.origin.x += 8;
        
        _valueLabel = [[UILabel alloc] init];
        _valueLabel.frame = selfBounds;
        _valueLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:_valueLabel];
    }
    
    return _valueLabel;
}

- (int)valueInList:(NSString *)value
{
    int result = NSNotFound;
    
    for (int i = 0; i < self.values.count; i++) {
        if ([[self.values objectAtIndex:i] isEqualToString:value]) {
            result = i;
            break;
        }
    }
    
    return result;
}

@end