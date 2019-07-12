//
//  NSObject+Tools.m
//  HeartRate
//
//  Created by 王灵博 on 2019/5/30.
//  Copyright © 2019 王灵博. All rights reserved.
//

#import "NSObject+Tools.h"
#import <CoreBluetooth/CoreBluetooth.h>

@implementation NSObject (Tools)




/*
无线局域网
App-Prefs:root=WIFI


蓝牙
App-Prefs:root=Bluetooth


蜂窝移动网络
App-Prefs:root=MOBILE_DATA_SETTINGS_ID


个人热点
App-Prefs:root=INTERNET_TETHERING


运营商
App-Prefs:root=Carrier


通知
App-Prefs:root=NOTIFICATIONS_ID


通用
App-Prefs:root=General


通用-关于本机
App-Prefs:root=General&path=About


通用-键盘
App-Prefs:root=General&path=Keyboard


通用-辅助功能
App-Prefs:root=General&path=ACCESSIBILITY


通用-语言与地区
App-Prefs:root=General&path=INTERNATIONAL


通用-还原
App-Prefs:root=Reset


墙纸
App-Prefs:root=Wallpaper


Siri
App-Prefs:root=SIRI


隐私
App-Prefs:root=Privacy


Safari
App-Prefs:root=SAFARI


音乐
App-Prefs:root=MUSIC


音乐-均衡器
App-Prefs:root=MUSIC&path=com.apple.Music:EQ


照片与相机
App-Prefs:root=Photos


FaceTime
App-Prefs:root=FACETIME
 

 个人热点
 App-Prefs:root=INTERNET_TETHERING
 
 
 运营商
 App-Prefs:root=Carrier
 
 
 隐私->麦克风
 App-Prefs:root=Privacy&path=MICROPHONE
 
 
 隐私->定位
 App-Prefs:root=Privacy&path=LOCATION
 
 
 隐私->相机
 App-Prefs:root=Privacy&path=CAMERA
 
 

*/
-(void)jumpSetingPage:(NSString *)setStr
{
    //亲测：iOS 8.1 ~ iOS 12.2
    // 跳转到设置 - 相机 / 该应用的设置界面
    NSURL *url1 = [NSURL URLWithString:setStr];
    // iOS10也可以使用url2访问，不过使用url1更好一些，可具体根据业务需求自行选择
    NSURL *url2 = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if (@available(iOS 11.0, *)) {
        if ([[UIApplication sharedApplication] canOpenURL:url2]){
            [[UIApplication sharedApplication] openURL:url2 options:@{} completionHandler:nil];
        }
    } else {
        if ([[UIApplication sharedApplication] canOpenURL:url1]){
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:url1 options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:url1];
            }
        }
    }
}


@end
