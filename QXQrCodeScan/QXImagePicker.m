//
//  QXImagePicker.m
//  QXQrCodeScan
//
//  Created by mac on 2019/7/9.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import "QXImagePicker.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface QXImagePicker()<UIActionSheetDelegate, UINavigationBarDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) UIViewController *vc;

@property (nonatomic, copy) PickerCompletion compBlick;

@end

@implementation QXImagePicker

- (void)setPickerCompletion:(PickerCompletion)compBlick{
    _compBlick = compBlick;
}

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static QXImagePicker *imagePicker = nil;
    dispatch_once(&onceToken, ^{
        imagePicker = [[QXImagePicker alloc] init];
    });
    return imagePicker;
}

- (void)startCurrentWithVC:(UIViewController *)vc{
    _vc = vc;
    UIAlertController *alertController = [[UIAlertController alloc] init];
    [alertController addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getTakePhotoFromCamera];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"从相册获取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getTakePhotoFromLibrary];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"从相册获取" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [_vc presentViewController:alertController animated:YES completion:nil];
}

- (void)getTakePhotoFromCamera{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [UIImagePickerController new];
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        imagePicker.title = @"拍照";
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        [_vc presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)getTakePhotoFromLibrary{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePicker = [UIImagePickerController new];
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        imagePicker.title = @"选择照片";
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        [_vc presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark -- UINavigationControllerDelegate,UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info{
    __weak typeof(self) weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        //此处选择为原始图片，若需要裁剪，可用 UIImagePickerControllerEditedImage
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self->_compBlick) {
                self->_compBlick(weakSelf, nil, image);
            }
        });
    }];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_compBlick) {
            NSString *description = @"";
            if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
                description = @"用户已取消选择照片";
            }else{
                description = @"用户已取消拍照";
            }
            NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:1 userInfo:@{@"description":description}];
            self->_compBlick(weakSelf, error, nil);
        }
    });
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
