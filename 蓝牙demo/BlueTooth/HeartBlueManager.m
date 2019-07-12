//
//  HeartBlueManager.m
//  HeartRate
//
//  Created by 王灵博 on 2019/6/4.
//  Copyright © 2019 王灵博. All rights reserved.
//

#import "HeartBlueManager.h"
#import "EasyBlueToothManager.h"
#import "HeartBlueManager.h"
#define ServiceUUID @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define WriteUUID @"6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
#define ReadUUID @"6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
#define WeakSelf(type) __weak typeof(type)weakSelf = type;

@interface HeartBlueManager ()
@property (nonatomic,strong)EasyBlueToothManager  *centerManager ;
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,strong)EasyCharacteristic *characteristic ;
@end
@implementation HeartBlueManager
+(instancetype)defaultManager{
    static HeartBlueManager *manager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager=[[HeartBlueManager alloc] init];
        manager.dataArray=[NSMutableArray array];
        manager.currentPeri=nil;
        [manager centerManager];
        manager.multipleRate=1;
        manager.bremultipleRate=1;
       
    });
    return manager;
}
-(void)changeInfoLable:(EasyPeripheral *)peripheral
{
    NSString *name=@"";
    if (self.currentPeri&&self.currentPeri.name) {
        name=self.currentPeri.name;
    }
    if ([peripheral.name isEqualToString:name]) {
        NSArray *serviceArray = [peripheral.advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey];
        NSString *connectStr=@"未连接";
        if (peripheral.state == CBPeripheralStateConnected) {
            connectStr = @"已连接";
            
        }else{
            connectStr=@"未连接";
            queueMainStart
            //[BOEProgressHUD showSuccessWithStatus:@"已断开"];
            queueEnd
        }
        queueMainStart
        [[HeartBlueManager defaultManager].target performSelector:@selector(currentDeviceStatus)];
        queueEnd
    }
}
-(void)scanDeviceWithTime:(NSTimeInterval)time
{
    [self.dataArray removeAllObjects];
    WeakSelf(self);
    [self.centerManager scanAllDeviceAsyncWithRule:^BOOL(EasyPeripheral *peripheral) {
        NSLog(@"蓝牙名字：%@",peripheral.name);
        if ([peripheral.name hasPrefix:@"BOE"]) {
            return YES;
        }else
        {
            return NO;
        }
    
    }callback:^(EasyPeripheral *peripheral, searchFlagType searchFlagType, NSError *error) {
        if (peripheral) {
            if (searchFlagType==searchFlagTypeChanged) {
                if (weakSelf.dataArray.count>0) {
                    if ([weakSelf.dataArray containsObject:peripheral]) {
                        NSInteger perpheralIndex = [weakSelf.dataArray indexOfObject:peripheral];
                        [weakSelf.dataArray replaceObjectAtIndex:perpheralIndex withObject:peripheral];
                        if ([weakSelf.delegate respondsToSelector:@selector(foundDeviceList:)]&&self.delegate) {
                            [weakSelf.delegate foundDeviceList:weakSelf.dataArray];
                        }
                        
                        NSLog(@"%@状态已经改变",peripheral.name);
                        [weakSelf changeInfoLable:peripheral];
                    } else {
                        [weakSelf.dataArray addObject:peripheral];
                        if ([weakSelf.delegate respondsToSelector:@selector(foundDeviceList:)]&&self.delegate) {
                            [weakSelf.delegate foundDeviceList:weakSelf.dataArray];
                        }
                        
                        NSLog(@"%@是新设备",peripheral.name);
                        
                        [weakSelf changeInfoLable:peripheral];
                    }
                    
                }else
                {
                    [weakSelf.dataArray addObject:peripheral];
                    if ([weakSelf.delegate respondsToSelector:@selector(foundDeviceList:)]&&self.delegate) {
                        [weakSelf.delegate foundDeviceList:weakSelf.dataArray];
                    }
                    
                    NSLog(@"%@是新设备",peripheral.name);
                    
                    [weakSelf changeInfoLable:peripheral];
                }
               
                
            }
            else if(searchFlagType&searchFlagTypeAdded){
                [weakSelf.dataArray addObject:peripheral];
                if ([weakSelf.delegate respondsToSelector:@selector(foundDeviceList:)]&&self.delegate) {
                    [weakSelf.delegate foundDeviceList:weakSelf.dataArray];
                }
                
                NSLog(@"%@是新设备",peripheral.name);
                
                [weakSelf changeInfoLable:peripheral];
            }
            else if (searchFlagType&searchFlagTypeDisconnect || searchFlagType&searchFlagTypeDelete){
                [weakSelf.dataArray removeObject:peripheral];
                
                if ([weakSelf.delegate respondsToSelector:@selector(foundDeviceList:)]&&self.delegate) {
                    [weakSelf.delegate foundDeviceList:weakSelf.dataArray];
                }
               
                NSLog(@"%@已经断开",peripheral.name);
                [weakSelf changeInfoLable:peripheral];
            }
        }
    }];
   
//        self.centerManager.stateChangeCallback = ^(EasyCenterManager *manager, CBManagerState state) {
//            [weakSelf managerStateChanged:state];
//        };
    
}
-(void)stopScan
{
    [self.centerManager stopScanDevice];
}
-(void)disConnectDevice
{
    [self.centerManager disconnectWithPeripheral:self.currentPeri];
    queueMainStart
    [[HeartBlueManager defaultManager].target performSelector:@selector(currentDeviceStatus)];
    queueEnd
}
-(void)connectDevice
{
    NSLog(@"连接设备");
    
    if (self.currentPeri.state==CBPeripheralStateConnected) {
        return;
    }
    queueMainStart
    [BOEProgressHUD showWithStatus:@"正在连接设备..."];
    queueEnd
    [self.centerManager connectDeviceWithPeripheral:self.currentPeri callback:^(EasyPeripheral *peripheral, NSError *error) {
//        if (error) {
//
//        }else
//        {
            if (self.currentPeri.state==CBPeripheralStateConnected) {
                queueMainStart
                [BOEProgressHUD dismiss];
                [[HeartBlueManager defaultManager].target performSelector:@selector(currentDeviceStatus)];
                queueEnd
           // }
        }
        
    }];
}
-(void)writeAndReadWithString:(NSString *)str
{
    [self read];
    NSData *data = [EasyUtils convertHexStrToData:str];
    [self.centerManager writeDataWithPeripheral:self.currentPeri serviceUUID:ServiceUUID writeUUID:WriteUUID data:data callback:^(NSData *data, NSError *error) {
        
    }];

   
}
-(void)writeWithStr:(NSString *)str
{
    NSData *data = [EasyUtils convertHexStrToData:str];
    [self.centerManager writeDataWithPeripheral:self.currentPeri serviceUUID:ServiceUUID writeUUID:WriteUUID data:data callback:^(NSData *data, NSError *error) {
        
    }];
}
-(void)read
{
    [self.centerManager notifyDataWithPeripheral:self.currentPeri serviceUUID:ServiceUUID notifyUUID:ReadUUID notifyValue:YES withCallback:^(NSData *data, NSError *error) {
        NSLog(@"VVVVVVV====%@",data);
        [[HeartBlueManager defaultManager].target performSelector:@selector(connectAcceptData:) withObject:data];
    }];
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
                queueMainStart
                [HeartBlueManager defaultManager].currentPeri=peripheral;
                [BOEProgressHUD showSuccessWithStatus:@"已连接"];
                [[NSObject currentController].navigationController popToRootViewControllerAnimated:YES];
                [[HeartBlueManager defaultManager].target performSelector:@selector(currentDeviceStatus)];
                queueEnd
            }
        }
        
    }];
    
}

@end
