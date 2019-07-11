//
//  QXImagePicker.h
//  QXQrCodeScan
//
//  Created by mac on 2019/7/9.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QXImagePicker;

typedef void(^PickerCompletion)(QXImagePicker *picker, NSError *error, UIImage *image);

@interface QXImagePicker : NSObject

+ (instancetype)sharedInstance;

/* 设置当前选择器的VC */
- (void)startCurrentWithVC:(UIViewController *)vc;

/* 选择器的回调 */
- (void)setPickerCompletion:(PickerCompletion)compBlick;

@end

NS_ASSUME_NONNULL_END
