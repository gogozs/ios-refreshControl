//
//  SVPullToRefreshArrow.m
//  Pods-SZRefreshControl
//
//  Created by songzhou on 2019/3/1.
//

#import "SVPullToRefreshArrow.h"

static const CGFloat kArrowWidth = 22;
static const CGFloat kArrowHeight = 48;

@implementation SVPullToRefreshArrow

- (UIColor *)arrowColor {
    if (!_arrowColor) {
        _arrowColor = [UIColor grayColor];
    }
    
    return _arrowColor;
}

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, kArrowWidth, kArrowHeight)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // the rects above the arrow
    static const CGFloat rectWidth = 12;
    static const CGFloat rectHeight = 4;
    static const NSUInteger rectPadding = 2;
    static const NSUInteger rectCount = 6;
    // the arrow
    static const NSUInteger arrowWidth = 22;
    static const NSUInteger arrowHeight = 14;
    static const CGFloat arrowOriginY = rectCount*rectHeight + (rectCount-1)*rectPadding;
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    // the rects
    for (int i = 0; i < rectCount; i++) {
        CGContextAddRect(c, CGRectMake((CGRectGetWidth(rect) - rectWidth)/2, i*(rectHeight+rectPadding), rectWidth, rectHeight));
    }
    
    // the arrow
    CGFloat arrowX = (CGRectGetWidth(rect) - arrowWidth)/2;
    CGContextMoveToPoint(c, arrowX, arrowOriginY);
    CGContextAddLineToPoint(c, arrowX + arrowWidth/2, arrowOriginY+arrowHeight);
    CGContextAddLineToPoint(c, arrowX + arrowWidth, arrowOriginY);
    CGContextAddLineToPoint(c, arrowX, arrowOriginY);
    CGContextClosePath(c);
    
    CGContextSaveGState(c);
    CGContextClip(c);
    
    // Gradient Declaration
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat alphaGradientLocations[] = {0, 0.8f};
    
    NSArray* alphaGradientColors = [NSArray arrayWithObjects:
                                    (id)[self.arrowColor colorWithAlphaComponent:0].CGColor,
                                    (id)[self.arrowColor colorWithAlphaComponent:1].CGColor,
                                    nil];
     CGGradientRef alphaGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)alphaGradientColors, alphaGradientLocations);
    
    
    CGContextDrawLinearGradient(c, alphaGradient, CGPointZero, CGPointMake(0, rect.size.height), 0);
    
    CGContextRestoreGState(c);
    
    CGGradientRelease(alphaGradient);
    CGColorSpaceRelease(colorSpace);
}

@end
