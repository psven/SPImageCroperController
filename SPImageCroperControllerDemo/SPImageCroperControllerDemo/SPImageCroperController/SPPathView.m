//
//  SPPathView.m
//  RealTimeImageTIleRenderDemo
//
//  Created by Joey on 2017/11/2.
//  Copyright © 2017年 Joey. All rights reserved.
//

#import "SPPathView.h"

@interface SPPathView () {
    CGPoint _originPoint;
    NSUInteger _index;
}
@property (nonatomic, strong) NSMutableArray *pointsArray;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@end

@implementation SPPathView

#pragma mark - Initialize

- (void)setup {
    
    // setup defalut value
    self.lineWidth = 2.0f;
    self.lineColor = [UIColor yellowColor];
    
    // Pan Gesture
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
    [self addGestureRecognizer:panGes];
    
    UIView *aView = [[UIView alloc] init];
    aView.frame = CGRectMake(50, 50, 150, 150);
    
    // store the points
    NSArray *pointsArray = @[
                             [NSValue valueWithCGPoint:aView.frame.origin], //topLeft
                             [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(aView.frame),
                                                                   CGRectGetMinY(aView.frame))],  //topRight
                             [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(aView.frame),
                                                                   CGRectGetMaxY(aView.frame))], //bottomRight
                             [NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(aView.frame),
                                                                   CGRectGetMaxY(aView.frame))] //bottomLeft
                             ];
    self.pointsArray = [NSMutableArray arrayWithArray:pointsArray];
    aView = nil;
    
    [self buildDisplay];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}


#pragma mark - Pan Gesture Hanlder

- (void)panGestureHandler:(UIPanGestureRecognizer *)panGes {
    CGPoint translationPoint = [panGes translationInView:self];
    switch (panGes.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint beginPoint = [panGes locationInView:self];
            _index = [self detectClosestPointIndexAgainst:beginPoint];
            _originPoint = [[self.pointsArray objectAtIndex:_index] CGPointValue];
        }
            break;
            
        case UIGestureRecognizerStateChanged: {
            CGPoint activePoint = CGPointMake(_originPoint.x + translationPoint.x,
                                              _originPoint.y + translationPoint.y);
            activePoint = [self limitPoint:activePoint toRect:self.frame];
            [self.pointsArray replaceObjectAtIndex:_index
                                        withObject:[NSValue valueWithCGPoint:activePoint]];
            [self buildDisplay];
        }
            break;
            
        case UIGestureRecognizerStateEnded: {
            CGPoint activePoint = CGPointMake(_originPoint.x + translationPoint.x,
                                              _originPoint.y + translationPoint.y);
            activePoint = [self limitPoint:activePoint toRect:self.frame];
            [self.pointsArray replaceObjectAtIndex:_index
                                        withObject:[NSValue valueWithCGPoint:activePoint]];
            [self buildDisplay];
            _originPoint = CGPointZero;
        }
            break;
            
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled: {
            [self.pointsArray replaceObjectAtIndex:_index
                                        withObject:[NSValue valueWithCGPoint:_originPoint]];
            _index = 0;
            [self buildDisplay];
        }
            break;
            
        default:
            break;
    }
    
}


#pragma mark - Custom Methods

- (void)buildDisplay {
    // build path
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint topLeft = [[self.pointsArray objectAtIndex:0] CGPointValue];
    [path moveToPoint:topLeft];
    for (int i = 1; i < self.pointsArray.count; i++) {
        CGPoint point = [[self.pointsArray objectAtIndex:i] CGPointValue];
        [path addLineToPoint:point];
    }
    [path closePath];
    
    // generate shapelayer
    self.shapeLayer = [[CAShapeLayer alloc] init];
    self.shapeLayer.path = path.CGPath;
    self.shapeLayer.lineWidth = self.lineWidth;
    self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
    self.shapeLayer.strokeColor = self.lineColor.CGColor;
    if (self.layer.sublayers.count < 1) {
        [self.layer addSublayer:self.shapeLayer];
        NSLog(@"sublayers.count = %zd", self.layer.sublayers.count);
    } else {
        [self.layer replaceSublayer:self.layer.sublayers[0] with:self.shapeLayer];
    }
    
    [self.delegate pathView:self didChangingControlPoints:[self.pointsArray mutableCopy]];
}

// detect the closest point's index against with another point
// the shortest distance indicates the cloest point
- (NSUInteger)detectClosestPointIndexAgainst:(CGPoint)aPoint {
    NSUInteger index = 0;
    CGFloat minimalDistance = CGFLOAT_MAX;
    for (int i = 0; i < self.pointsArray.count; i++) {
        CGPoint point = [[self.pointsArray objectAtIndex:i] CGPointValue];
        CGFloat distance = [self distanceBetween:aPoint andOtherPoint:point];
        if (distance < minimalDistance) {
            minimalDistance = distance;
            index = i;
        }
    }
    return index;
}

// calculate the distance between two points
- (CGFloat)distanceBetween:(CGPoint)point andOtherPoint:(CGPoint)otherPoint {
    return sqrt(pow((point.x - otherPoint.x), 2) + pow((point.y - otherPoint.y), 2));
}

// limit the point to a rectangle
- (CGPoint)limitPoint:(CGPoint)point toRect:(CGRect)rect {
    CGPoint newPoint = CGPointZero;
    newPoint.x = (point.x < 0) ? 0 : point.x;
    newPoint.x = (point.x > CGRectGetWidth(rect)) ? CGRectGetWidth(rect) : newPoint.x;
    newPoint.y = (point.y < 0) ? 0 : point.y;
    newPoint.y = (point.y > CGRectGetHeight(rect)) ? CGRectGetHeight(rect) : newPoint.y;
    return newPoint;
}


#pragma mark - Setter

- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    [self buildDisplay];
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    [self buildDisplay];
}

@end
