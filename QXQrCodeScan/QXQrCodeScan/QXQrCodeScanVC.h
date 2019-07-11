//
//  QXOrCodeScanVC.h
//  QXQrCodeScan
//
//  Created by mac on 2019/7/9.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QXQrCodeScanVC;

typedef void(^QrCodeScanCompletion) (QXQrCodeScanVC *vc, NSError *error, NSString *content);

@interface QXQrCodeScanVC : UIViewController

@property (nonatomic, copy) QrCodeScanCompletion compBlick;

-(void)hiddenFlashBtn:(BOOL)type;

-(void)hiddenAlbumBtn:(BOOL)type;

@end

NS_ASSUME_NONNULL_END
