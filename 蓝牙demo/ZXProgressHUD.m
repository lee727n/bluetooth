//
//  BOEProgressHUD.m
//  HFHospital-OC
//
//  Created by Jiankun Zhang on 2018/1/10.
//  Copyright © 2018年 BOE-Health. All rights reserved.
//

#import "ZXProgressHUD.h"

@implementation ZXProgressHUD

+ (void)initialize
{
    [ZXProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];// 整个后面的背景选择
    [ZXProgressHUD setBackgroundColor:[UIColor blackColor]];// 弹出框颜色
    [ZXProgressHUD setForegroundColor:[UIColor whiteColor]];// 弹出框内容颜色
    [ZXProgressHUD setFont:[UIFont systemFontOfSize:16.0]];//字体
    [ZXProgressHUD setMinimumDismissTimeInterval:2.0];
    [ZXProgressHUD setMaximumDismissTimeInterval:3.0];
    [ZXProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    
}

+ (void)showTextStatus:(NSString *)status {
    [SVProgressHUD showImage:[UIImage imageNamed:@"wrt424erte2342rx"] status:status];
}

@end
