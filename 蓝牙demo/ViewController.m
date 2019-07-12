//
//  ViewController.m
//  蓝牙demo
//
//  Created by liu zixuan on 2019/7/12.
//  Copyright © 2019 liu zixuan. All rights reserved.
//
#define ServiceUUID @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define WriteUUID @"6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
#define ReadUUID @"6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
#define WeakSelf(type) __weak typeof(type)weakSelf = type;
#define ScreenWidth             [UIScreen mainScreen].bounds.size.width
#define ScreenHeight            [UIScreen mainScreen].bounds.size.height

#import "EasyBlueToothManager.h"
#import "ViewController.h"
#import "ZXProgressHUD.h"

@interface ViewController ()
@property (nonatomic,strong)EasyBlueToothManager  *centerManager ;
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,strong)UIButton *BtnLeft;
@property (nonatomic,strong)UIButton *BtnRight;
@property (nonatomic,strong)EasyPeripheral *currentPeri;
@property (nonatomic,strong)UILabel *statusLb;
@property (nonatomic,strong)UILabel *deviceName;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //BOE_ECG19062816
    //必须持有centerManager才可以使用
    [self centerManager];
    //通过蓝牙名字链接 这里换成你自己蓝牙设备的名字
    [self scanAndConnectDevice:@"BOE_ECG19062816"];
    
    UILabel *titleLb = [[UILabel alloc]initWithFrame:CGRectMake(0, 100, ScreenWidth, 50)];
    titleLb.text = @"蓝牙演示程序";
    titleLb.textAlignment = 1;
    titleLb.numberOfLines = 1;
    titleLb.textColor = [UIColor blackColor];
    titleLb.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:titleLb];
    
    _BtnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    _BtnLeft.frame = CGRectMake(50, 200, 100, 50);
    [_BtnLeft setTitle:@"断开连接" forState:UIControlStateNormal];
    [_BtnLeft setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_BtnLeft setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    //切圆角
    _BtnLeft.layer.masksToBounds = YES;
    _BtnLeft.layer.cornerRadius = 5;
    //描边
    _BtnLeft.layer.borderWidth = 2;
    [_BtnLeft setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    _BtnLeft.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 7);
    _BtnLeft.titleEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 0);
    [_BtnLeft addTarget:self action:@selector(btnclick) forControlEvents:UIControlEventTouchUpInside];
    _BtnLeft.tag = 101;
    [self.view addSubview:_BtnLeft];
    
    _BtnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    _BtnRight.frame = CGRectMake(200, 200, 100, 50);
    [_BtnRight setTitle:@"重启连接" forState:UIControlStateNormal];
    [_BtnRight setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [_BtnRight setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    //切圆角
    _BtnRight.layer.masksToBounds = YES;
    _BtnRight.layer.cornerRadius = 5;
    //描边
    _BtnRight.layer.borderWidth = 2;
    [_BtnRight setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    _BtnRight.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 7);
    _BtnRight.titleEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 0);
    [_BtnRight addTarget:self action:@selector(restartLink) forControlEvents:UIControlEventTouchUpInside];
    _BtnRight.tag = 101;
    [self.view addSubview:_BtnRight];
    
    _statusLb = [[UILabel alloc]initWithFrame:CGRectMake(0, 270, ScreenWidth, 50)];
    _statusLb.text = @"----";
    _statusLb.textAlignment = 1;
    _statusLb.numberOfLines = 1;
    _statusLb.textColor = [UIColor blackColor];
    _statusLb.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:_statusLb];
    
    _deviceName = [[UILabel alloc]initWithFrame:CGRectMake(50, 350, 300, 50)];
    _deviceName.text = @"设备名称：";
    _deviceName.textAlignment = 0;
    _deviceName.numberOfLines = 1;
    _deviceName.textColor = [UIColor blackColor];
    _deviceName.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:_deviceName];
    
}
-(void)btnclick{
    
    [self.centerManager disconnectWithPeripheral:self.currentPeri];
    _statusLb.text = @"断开连接";
    _deviceName.text = @"设备名称：";
}
-(void)restartLink{
    
    [self scanAndConnectDevice:@"BOE_ECG19062816"];
}

- (EasyBlueToothManager *)centerManager
{
    if (nil == _centerManager) {
        _centerManager = [EasyBlueToothManager shareInstance];
        
        dispatch_queue_t queue = dispatch_queue_create("com.easyBluetooth.queue", 0);
        NSDictionary *managerDict = @{CBCentralManagerOptionShowPowerAlertKey:@NO};
        NSDictionary *scanDict = @{CBCentralManagerScanOptionAllowDuplicatesKey: @YES };
        NSDictionary *connectDict = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
        
        EasyManagerOptions *options = [[EasyManagerOptions alloc]initWithManagerQueue:queue managerDictionary:managerDict scanOptions:scanDict scanServiceArray:nil connectOptions:connectDict];
        options.scanTimeOut = 30;
        options.connectTimeOut = 30;
        options.autoConnectAfterDisconnect = YES ;
        [EasyBlueToothManager shareInstance].managerOptions = options ;
        
    }
    
    return _centerManager ;
}
-(void)scanAndConnectDevice:(NSString *)name
{
    NSLog(@"-----------开始扫描并连接");
    WeakSelf(self);
    [self.centerManager scanAndConnectDeviceWithName:name callback:^(EasyPeripheral *peripheral, NSError *error) {
        
        if (error) {
            NSLog(@"------------收到扫描并连接的error:%@",error);
            //[BOEProgressHUD showTextStatus:@"自动重连超时，请手动尝试"];
        }else
        {
            NSLog(@"------------收到扫描并连接的回调");
            NSLog(@"------------回调状态%ld",(long)peripheral.state);
            if (peripheral.state==CBPeripheralStateConnected) {
                self.currentPeri = peripheral;
                
                queueMainStart
                [ZXProgressHUD showSuccessWithStatus:@"已连接"];
                self.deviceName.text = [NSString stringWithFormat:@"设备名称：%@",peripheral.name];
                _statusLb.text = @"已连接";
                queueEnd
            }
        }
        
    }];
    
}
@end
