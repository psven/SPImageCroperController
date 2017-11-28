//
//  ViewController.m
//  SPImageCroperControllerDemo
//
//  Created by Joey on 2017/11/27.
//  Copyright © 2017年 Joey. All rights reserved.
//

#import "ViewController.h"
#import "SPImageCroperController.h"

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, SPImageCroperControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *imageHolderBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openButtonClickedHandler:(id)sender {
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
    
    UIAlertAction *photoLibraryAction = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"Open a file" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertCon addAction:cameraAction];
    [alertCon addAction:photoLibraryAction];
    [alertCon addAction:cancelAction];
    [self presentViewController:alertCon animated:YES completion:nil];
}


#pragma make - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //-------
    // block
    //-------
    __weak typeof(self) weakSelf = self;
    SPImageCroperController *vc = [[SPImageCroperController alloc] initWithOriginalImage:image completion:^(SPImageCroperController *viewController, UIImage *cropedImage) {
    [weakSelf.imageHolderBtn setTitle:@"" forState:UIControlStateNormal];
    [weakSelf.imageHolderBtn setBackgroundImage:cropedImage forState:UIControlStateNormal];
        NSLog(@"invoke completionBlock");
    } cancelBlock:^(SPImageCroperController *viewController) {
        NSLog(@"invoke cancelBlock");
    }];
    [self presentViewController:vc animated:YES completion:nil];
    
    
    //----------
    // delegate
    //----------
    SPImageCroperController *vc = [[SPImageCroperController alloc] init];
    vc.originalImage = image;
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}


#pragma mark - SPImageCroperControllerDelegate

- (void)imageCroperController:(SPImageCroperController *)viewController
        didFinishCropingImage:(UIImage *)image {
    [self.imageHolderBtn setTitle:@"" forState:UIControlStateNormal];
    [self.imageHolderBtn setBackgroundImage:image forState:UIControlStateNormal];
    NSLog(@"invoke -imageCroperController:didFinishCropingImage:");
}

- (void)imageCroperControllerDidCancel:(SPImageCroperController *)viewController {
    NSLog(@"invoke -imageCroperControllerDidCancel:");
}


@end
