//
//  HeartBlueManager.h
//  HeartRate
//
//  Created by 王灵博 on 2019/6/4.
//  Copyright © 2019 王灵博. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EasyPeripheral.h"
#import "HeartBlueManager.h"

NS_ASSUME_NONNULL_BEGIN
@protocol HeartRateBlueDelegate <NSObject>
@optional
-(void)foundDeviceList:(NSArray *)list;
@end
@interface HeartBlueManager : NSObject
@property(nonatomic,assign)id<HeartRateBlueDelegate>delegate;
@property(nonatomic,assign)CGFloat multipleRate;
@property(nonatomic,assign)CGFloat bremultipleRate;
@property(nonatomic,assign)BOOL stop;
@property(nonatomic,assign)BOOL brestop;
@property (nonatomic,strong)EasyPeripheral *currentPeri;
@property (nonatomic,strong)NSObject *target;
+(instancetype)defaultManager;
-(void)scanAndConnectDevice:(NSString *)name;
-(void)stopScan;
-(void)scanDeviceWithTime:(NSTimeInterval)time;
-(void)connectDevice;
-(void)disConnectDevice;
-(void)writeWithStr:(NSString *)str;
-(void)read;
-(void)writeAndReadWithString:(NSString *)str;
@end

NS_ASSUME_NONNULL_END
