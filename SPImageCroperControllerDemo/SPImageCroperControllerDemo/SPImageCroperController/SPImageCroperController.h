//
//  SPImageCroperController.h
//  RealTimeImageTIleRenderDemo
//
//  Created by Joey on 2017/11/24.
//  Copyright © 2017年 Joey. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SPImageCroperController;

typedef void (^completionBlock)(SPImageCroperController *viewController, UIImage *image);
typedef void (^cancelBlock)(SPImageCroperController *viewController);

@protocol SPImageCroperControllerDelegate <NSObject>
@optional
- (void)imageCroperController:(SPImageCroperController *)viewController
        didFinishCropingImage:(UIImage *)image;
- (void)imageCroperControllerDidCancel:(SPImageCroperController *)viewController;
@end


@interface SPImageCroperController : UIViewController
//
@property (nonatomic, strong) UIImage *originalImage;
// path line width, default is 2.0
@property (nonatomic, assign) CGFloat lineWidth;
// path line color, default is [UIColor yellowColor]
@property (nonatomic, strong) UIColor *lineColor;

@property (nonatomic, weak) id<SPImageCroperControllerDelegate> delegate;

// if the next blocks are provided, the delegate callback will not be invoked.
@property (nonatomic, copy) completionBlock completionBlock;

@property (nonatomic, copy) cancelBlock cancelBlock;

- (instancetype)initWithOriginalImage:(UIImage *)originalImage
                           completion:(completionBlock)completionBlock
                          cancelBlock:(cancelBlock)cancelBlock;
+ (SPImageCroperController *)imageCroperControllerWithOriginalImage:(UIImage *)originalImage
                                                         completion:(completionBlock)completionBlock
                                                        cancelBlock:(cancelBlock)cancelBlock;

@end
