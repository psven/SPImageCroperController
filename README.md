# SPImageCroperController
A simple controller that allows users to crop image using an arbitrary quadrilateral,  and then preview the tiled effect of the croped image in real time, and return the croped image in a square rect.

## Screenshot
![IMAGE](resources/A97FA1130ADDCFCBA482F3BFA255F600.jpg =750x1334)
![IMAGE](resources/E06E825E0A574A76455F429AEF433BE9.jpg =750x1334)


## Features
- Crop images by dragging the four angles of the selection box
- Supports arbitrary quadrilateral
- Adjust the croped image to a square by using [CIPerspectiveCorrection](https://developer.apple.com/library/content/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIPerspectiveCorrection)

## System Requirement
iOS 8.0 or above

## Installation
### Manual Installation
Simply copy the `SPImageCroperController` directory to your Xcode project.

## Example
Using `SPImageCroperController` is very straightforward. Simply create a new instance passing the `UIImage` object you wish to crop, and then present it modally on the screen.

While `SPImageCroperController` prefers to be presented modally, it can also be pushed to a `UINavigationController` stack.

For a complete working example, check out the demo included in this repo.

**Basic Implementation**

You can implement `SPImageCroperController` just with one line code by using block:
```Objective-C
SPImageCroperController *vc = [[SPImageCroperController alloc] initWithOriginalImage:image completion:^(SPImageCroperController *viewController, UIImage *cropedImage) {
    NSLog(@"invoke completionBlock");
} cancelBlock:^(SPImageCroperController *viewController) {
    NSLog(@"invoke cancelBlock");
}];
[self presentViewController:vc animated:YES completion:nil];
// [self.navigationController pushViewController:vc animated:YES];
```
Or using `SPImageCroperControllerDelegate`, which usage is similiar to `UIImagePickerControllerDelegate`:
```Objective-C
SPImageCroperController *vc = [[SPImageCroperController alloc] init];
vc.originalImage = image;
vc.delegate = self;
[self presentViewController:vc animated:YES completion:nil];
```

```
- (void)imageCroperController:(SPImageCroperController *)viewController
        didFinishCropingImage:(UIImage *)image {
    [self.imageHolderBtn setTitle:@"" forState:UIControlStateNormal];
    [self.imageHolderBtn setBackgroundImage:image forState:UIControlStateNormal];
    NSLog(@"invoke -imageCroperController:didFinishCropingImage:");
}

- (void)imageCroperControllerDidCancel:(SPImageCroperController *)viewController {
    NSLog(@"invoke -imageCroperControllerDidCancel:");
}
```

## License
`SPImageCroperController` is licensed under the MIT License, please see the [LICENSE](https://github.com/light3n/SPImageCroperController/blob/master/LICENSE) file. 