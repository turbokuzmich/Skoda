//
//  ListNewViewCellBackgroundView.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 11.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "ListNewViewCellBackgroundView.h"

CGPoint static plusOffset = {39.0, 20.0};
static NSMutableDictionary *drawCache = nil;

@interface ListNewViewCellBackgroundView ()
@property (nonatomic, strong) UIImage *backgroundImage;
@end

@implementation ListNewViewCellBackgroundView
@synthesize vertices=_vertices, color=_color, stroke=_stroke;

+ (void)initialize {
    [super initialize];
    drawCache = [[NSMutableDictionary alloc] initWithCapacity:24];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundImage = [UIImage imageNamed:@"beard-pattern"];
        self.clipsToBounds = NO;
        self.isStrokeView = NO;
    }
    return self;
}

- (void)setColor:(UIColor *)newColor {
    if (![_color isEqual:newColor]) {
        _color = newColor;
        [self setNeedsDisplay];
    }
}

- (void)setStroke:(UIColor *)newStroke {
    if (![_stroke isEqual:newStroke]) {
        _stroke = newStroke;
        [self setNeedsDisplay];
    }
}

- (void)setVertices:(NSArray *)vertices {
    _vertices = vertices;
    CGPoint p1 = CGPointMake([[self.vertices objectAtIndex:0] floatValue], [[self.vertices objectAtIndex:1] floatValue]);
    CGPoint p2 = CGPointMake([[self.vertices objectAtIndex:2] floatValue], [[self.vertices objectAtIndex:3] floatValue]);
    CGPoint p3 = CGPointMake([[self.vertices objectAtIndex:4] floatValue], [[self.vertices objectAtIndex:5] floatValue]);
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: p1];
    [bezierPath addLineToPoint: p2];
    [bezierPath addLineToPoint: p3];
    [bezierPath addLineToPoint: p1];
    [bezierPath closePath];
    self.polygon = bezierPath;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (self.polygon) {
        if (self.isStrokeView) {
            [self.polygon applyTransform:CGAffineTransformMakeTranslation(1.5, 1.5)];
        }
        
        [self.color setFill];
        [self.polygon fill];
        
        if (self.isPlus) {
            UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0.5 + plusOffset.x, 0.5 + plusOffset.y, 19, 19)];
            [[UIColor whiteColor] setStroke];
            ovalPath.lineWidth = 1;
            [ovalPath stroke];
            
            UIBezierPath* bezierPath = [UIBezierPath bezierPath];
            [bezierPath moveToPoint: CGPointMake(10 + plusOffset.x, 6.5 + plusOffset.y)];
            [bezierPath addLineToPoint: CGPointMake(10 + plusOffset.x, 13.5 + plusOffset.y)];
            [bezierPath addLineToPoint: CGPointMake(10 + plusOffset.x, 6.5 + plusOffset.y)];
            [bezierPath closePath];
            [[UIColor grayColor] setFill];
            [bezierPath fill];
            [[UIColor whiteColor] setStroke];
            bezierPath.lineWidth = 1;
            [bezierPath stroke];
            
            UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
            [bezier2Path moveToPoint: CGPointMake(13.5 + plusOffset.x, 10 + plusOffset.y)];
            [bezier2Path addLineToPoint: CGPointMake(6.5 + plusOffset.x, 10 + plusOffset.y)];
            [bezier2Path addLineToPoint: CGPointMake(13.5 + plusOffset.x, 10 + plusOffset.y)];
            [bezier2Path closePath];
            [[UIColor grayColor] setFill];
            [bezier2Path fill];
            [[UIColor whiteColor] setStroke];
            bezier2Path.lineWidth = 1;
            [bezier2Path stroke];
        }
        
        if (self.stroke) {
            if (self.isStrokeView) {
                [self.stroke setStroke];
                [self.polygon setLineWidth:3];
                [self.polygon stroke];
            } else {
                if (!self.strokeView) {
                    self.strokeView = [[ListNewViewCellBackgroundView alloc] init];
                    [self.strokeView setBackgroundColor:[UIColor clearColor]];
                    [self.strokeView setIsStrokeView:YES];
                    [self addSubview:self.strokeView];
                }
                
                CGRect selfFrame = self.bounds;
                selfFrame.origin.x -= 1.5;
                selfFrame.origin.y -= 1.5;
                selfFrame.size.width += 3;
                selfFrame.size.height += 3;
                
                [self.strokeView setFrame:selfFrame];
                [self.strokeView setVertices:self.vertices];
                [self.strokeView setColor:[UIColor clearColor]];
                [self.strokeView setStroke:self.stroke];
                [self.strokeView setHidden:NO];
                [self.strokeView setNeedsDisplay];
            }
        } else {
            [self.strokeView setHidden:YES];
        }
    }
}

@end
