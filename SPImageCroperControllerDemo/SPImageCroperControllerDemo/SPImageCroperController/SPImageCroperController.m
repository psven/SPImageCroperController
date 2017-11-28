//
//  SPImageCroperController.m
//  RealTimeImageTIleRenderDemo
//
//  Created by Joey on 2017/11/24.
//  Copyright © 2017年 Joey. All rights reserved.
//

#import "SPImageCroperController.h"
#import "SPPathView.h"

static CGFloat titleLabelHeight = 40.0f;
static CGFloat toolBarViewHeight = 40.0f;

@interface SPImageCroperController () <SPPathViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    CIContext *context;
}

// preview
@property (nonatomic, strong) UIView *previewContainerView;
@property (nonatomic, strong) UIImageView *tiledPreviewImageView;
// work
@property (nonatomic, strong) UIView *workContainerView;
@property (nonatomic, strong) UIImageView *originalImageView;
@property (nonatomic, strong) UIImageView *displayImageView;
@property (nonatomic, strong) SPPathView *pathView;
// tool bar
@property (nonatomic, strong) UIView *toolbarView;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *confirmBtn;
//@property (nonatomic, strong) UIButton *scaleBtn;


@property (nonatomic, strong) UIImage *cropedImage;

@end

@implementation SPImageCroperController

- (void)setOriginalImage:(UIImage *)originalImage {
    _originalImage = originalImage;
    [self buildOriginalImageViewWithImage:originalImage];
}

- (instancetype)initWithOriginalImage:(UIImage *)originalImage
                           completion:(completionBlock)completionBlock
                          cancelBlock:(cancelBlock)cancelBlock {
    self = [super init];
    if (self) {
        _originalImage = originalImage;
        _completionBlock = completionBlock;
        _cancelBlock = cancelBlock;
    }
    return self;
}

+ (SPImageCroperController *)imageCroperControllerWithOriginalImage:(UIImage *)originalImage
                                                         completion:(completionBlock)completionBlock
                                                        cancelBlock:(cancelBlock)cancelBlock {
    return [[SPImageCroperController alloc] initWithOriginalImage:originalImage
                                                       completion:completionBlock
                                                      cancelBlock:cancelBlock];;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildUI];
}

- (void)buildUI {
    self.view.backgroundColor = [UIColor whiteColor];
    // preview
    self.previewContainerView = [[UIView alloc] init];
    [self.view addSubview:self.previewContainerView];
    
    UILabel *previewTitleLabel = [[UILabel alloc] init];
    previewTitleLabel.frame = CGRectMake(0, 0, 100, titleLabelHeight);
    previewTitleLabel.font = [UIFont systemFontOfSize:14];
    previewTitleLabel.text = @"Effect Preview";
    [self.previewContainerView addSubview:previewTitleLabel];
    
    self.tiledPreviewImageView = [[UIImageView alloc] init];
    [self.previewContainerView addSubview:self.tiledPreviewImageView];
    
    // work
    self.workContainerView = [[UIView alloc] init];
    [self.view addSubview:self.workContainerView];
    
    UILabel *workTitleLabel = [[UILabel alloc] init];
    workTitleLabel.frame = CGRectMake(0, 0, 100, titleLabelHeight);
    workTitleLabel.font = [UIFont systemFontOfSize:14];
    workTitleLabel.text = @"Area Detect";
    [self.workContainerView addSubview:workTitleLabel];
    
    self.originalImageView = [[UIImageView alloc] init];
    self.originalImageView.image = self.originalImage;
    [self.workContainerView addSubview:self.originalImageView];
    
    self.displayImageView = [[UIImageView alloc] init];
    self.displayImageView.image = self.originalImage;
    [self.workContainerView addSubview:self.displayImageView];
    
    self.pathView = [[SPPathView alloc] init];
    self.pathView.delegate = self;
    if (self.lineWidth > 0) {
        self.pathView.lineWidth = self.lineWidth;
    }
    if (self.lineColor) {
        self.pathView.lineColor = self.lineColor;
    }
    [self.workContainerView addSubview:self.pathView];
    
    // tool bar
    self.toolbarView = [[UIView alloc] init];
    [self.view addSubview:self.toolbarView];
    
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(buttonClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView addSubview:self.cancelBtn];
    
    self.confirmBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.confirmBtn setTitle:@"Confirm" forState:UIControlStateNormal];
    [self.confirmBtn addTarget:self action:@selector(buttonClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView addSubview:self.confirmBtn];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat containerViewY = 0;
    CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    containerViewY += statusBarHeight;
    if (self.navigationController) {
        containerViewY += CGRectGetHeight(self.navigationController.navigationBar.frame);
    }
    
    CGFloat screenWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    CGFloat screenHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]);
    
    if (screenWidth < screenHeight) {
        // device is now in portrait mode
        self.previewContainerView.frame = CGRectMake(0, containerViewY, screenWidth, (screenHeight - containerViewY  - toolBarViewHeight)/2);
        self.workContainerView.frame = CGRectMake(0, CGRectGetMaxY(self.previewContainerView.frame), screenWidth, (screenHeight - containerViewY  - toolBarViewHeight)/2);
    } else {
        // device is now in landscape mode
        self.previewContainerView.frame = CGRectMake(10, containerViewY, (screenWidth-30)/2, screenHeight -containerViewY - toolBarViewHeight);
        self.workContainerView.frame = CGRectMake(CGRectGetMaxX(self.previewContainerView.frame)+10, containerViewY, (screenWidth-30)/2, screenHeight - containerViewY - toolBarViewHeight);
    }
    
    self.tiledPreviewImageView.frame = CGRectMake(0, titleLabelHeight, CGRectGetWidth(self.previewContainerView.frame), CGRectGetHeight(self.previewContainerView.frame)-titleLabelHeight);
    
    self.originalImageView.frame = CGRectMake(0, titleLabelHeight, CGRectGetWidth(self.workContainerView.frame), CGRectGetHeight(self.workContainerView.frame)-titleLabelHeight);
    
    self.displayImageView.frame = self.originalImageView.frame;
    self.pathView.frame = self.originalImageView.frame;
    
    self.toolbarView.frame = CGRectMake(0, CGRectGetMaxY(self.workContainerView.frame), screenWidth, toolBarViewHeight);
    self.cancelBtn.frame = CGRectMake(0, 0, 80, CGRectGetHeight(self.toolbarView.frame));
    self.confirmBtn.frame = CGRectMake(CGRectGetWidth(self.toolbarView.frame)-80, 0, 80, CGRectGetHeight(self.toolbarView.frame));
    
    [self buildOriginalImageViewWithImage:self.originalImage];
}

- (void)buttonClickedHandler:(UIButton *)button {
    if (button == self.cancelBtn) {
        
        [self dismiss];
        if (self.cancelBlock) {
            self.cancelBlock(self);
        } else {
            if ([self.delegate respondsToSelector:@selector(imageCroperControllerDidCancel:)]) {
                [self.delegate imageCroperControllerDidCancel:self];
            }
        }
        
    } else if (button == self.confirmBtn) {
        
        [self dismiss];
        if (self.completionBlock) {
            self.completionBlock(self, self.cropedImage);
        } else {
            if ([self.delegate respondsToSelector:@selector(imageCroperController:didFinishCropingImage:)]) {
                [self.delegate imageCroperController:self didFinishCropingImage:self.cropedImage];
            }
        }
    }
}

#pragma mark - Custom Methods

// if this controller is presented by a controller, then dismiss, else pop
- (void)dismiss {
    if (self.presentingViewController) {
        NSLog(@"SPImageCroperController has a presenting Controller.");
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// convert point to Cartesian coordinate system
// Core Image uses the Cartesian coordinate system. Y axis is up. (zero, zero) is at the bottom left.
// @see https://stackoverflow.com/questions/28869337/ciperspectivecorrection-filter-returns-image-flipped-and-inverted
- (CGPoint)cartesianForPoint:(CGPoint)point rect:(CGRect)extent {
    return CGPointMake(point.x, extent.size.height - point.y);
}

// draw the image to specified size
// so the SPPathView's control points can matching the image's area correctly
- (void)buildOriginalImageViewWithImage:(UIImage *)image {
    UIGraphicsBeginImageContext(self.originalImageView.frame.size);
    [image drawInRect:CGRectMake(0, 0, CGRectGetWidth(self.originalImageView.frame), CGRectGetHeight(self.originalImageView.frame))];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.originalImageView.image = finalImage;
    self.displayImageView.image = finalImage;
}


#pragma mark - SPPathViewDelegate

- (void)pathView:(SPPathView *)view didChangingControlPoints:(NSArray *)points {
    
    CIImage *inputImage = [CIImage imageWithCGImage:self.originalImageView.image.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIPerspectiveCorrection"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    
    CIVector *topLeft = [CIVector vectorWithCGPoint:[self cartesianForPoint:[points[0] CGPointValue]
                                                                       rect:self.originalImageView.frame]];
    CIVector *topRight = [CIVector vectorWithCGPoint:[self cartesianForPoint:[points[1] CGPointValue]
                                                                        rect:self.originalImageView.frame]];
    CIVector *bottomRight = [CIVector vectorWithCGPoint:[self cartesianForPoint:[points[2] CGPointValue]
                                                                           rect:self.originalImageView.frame]];
    CIVector *bottomLeft = [CIVector vectorWithCGPoint:[self cartesianForPoint:[points[3] CGPointValue]
                                                                          rect:self.originalImageView.frame]];
    
    [filter setValue:topLeft forKey:@"inputTopLeft"];
    [filter setValue:topRight forKey:@"inputTopRight"];
    [filter setValue:bottomRight forKey:@"inputBottomRight"];
    [filter setValue:bottomLeft forKey:@"inputBottomLeft"];
    
    if (!context) {
        context = [CIContext context];
    }
    CIImage *outputImage = [filter outputImage];
    // adjust rect
    CGRect rectWithoutLine = CGRectInset(outputImage.extent, 1, 1);
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:rectWithoutLine];
    UIImage *finalImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    self.tiledPreviewImageView.backgroundColor = [UIColor colorWithPatternImage:finalImage];
    self.cropedImage = finalImage;
}


@end
