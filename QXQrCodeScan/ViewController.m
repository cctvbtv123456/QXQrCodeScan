//
//  ViewController.m
//  QXQrCodeScan
//
//  Created by mac on 2019/7/9.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import "ViewController.h"
#import "QXQrCodeScanVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)scanClick:(UIButton *)sender {
    QXQrCodeScanVC *vc = [[QXQrCodeScanVC alloc] init];
    [vc hiddenFlashBtn:NO];
    [vc hiddenAlbumBtn:NO];
//    __weak typeof(self) weakSelf = self;
    [vc setCompBlick:^(QXQrCodeScanVC * _Nonnull qrCodeScanVC, NSError * _Nonnull error, NSString * _Nonnull content) {
        if (!error) {
            NSLog(@"content = %@",content);
            [qrCodeScanVC dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    
    [self.navigationController pushViewController:vc animated:YES];
//    [self presentViewController:vc animated:YES completion:nil];
}

@end
