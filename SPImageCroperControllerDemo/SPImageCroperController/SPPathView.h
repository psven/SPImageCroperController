//
//  SPPathView.h
//  RealTimeImageTIleRenderDemo
//
//  Created by Joey on 2017/11/2.
//  Copyright © 2017年 Joey. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SPPathView;

@protocol SPPathViewDelegate <NSObject>
@required
- (void)pathView:(SPPathView *)view didChangingControlPoints:(NSArray *)points;
@end

@interface SPPathView : UIView

// path line width, default is 2.0
@property (nonatomic, assign) CGFloat lineWidth;
// path line color, default is [UIColor yellowColor]
@property (nonatomic, strong) UIColor *lineColor;

@property (nonatomic, weak) id<SPPathViewDelegate> delegate;

@end
