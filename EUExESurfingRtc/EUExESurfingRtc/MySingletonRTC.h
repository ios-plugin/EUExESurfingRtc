//
//  MySingletonRTC.h
//  DEMO
//
//  Created by cc on 15/11/4.
//  Copyright © 2015年 hexc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "sdkobj.h"
#import "sdkkey.h"
#import "sdkerrorcode.h"
#import "tyrtchttpengine.h"
#import "MKNetworkOperationRTC.h"
#import "DAPIPView.h"
#import "EUtility.h"

@interface MySingletonRTC : NSObject<SdkObjCallBackProtocol,AccObjCallBackProtocol,CallObjCallBackProtocol>

@property (nonatomic,retain) SdkObj* mSDKObj;
@property (nonatomic,retain) AccObj* mAccObj;
@property (nonatomic,retain) CallObj*  mCallObj;
@property(nonatomic,retain)NSString * terminalType;
@property(nonatomic,retain)NSString * remoteTerminalType;
@property(nonatomic,retain)NSString * str;
@property(nonatomic,retain)NSString * callName;
@property(nonatomic,assign)SDK_ACCTYPE   accType;
@property(nonatomic,assign)SDK_ACCTYPE   remoteAccType;
@property(nonatomic,assign)int callTypes;
@property(nonatomic,assign)int accepptType;
@property (nonatomic,retain) DAPIPView * dapiview;
@property (nonatomic,retain) IOSDisplay *remoteVideoView;
@property (nonatomic,retain) UIView *localVideoView;
@property(nonatomic,assign)int x;
@property(nonatomic,assign)int y;
@property(nonatomic,assign)int width;
@property(nonatomic,assign)int height;
@property(nonatomic,assign)int x1;
@property(nonatomic,assign)int y1;
@property(nonatomic,assign)int width1;
@property(nonatomic,assign)int height1;
@property(nonatomic,assign)int Resolutions;
@property(nonatomic,retain)NSString * mToken;
@property(nonatomic,retain)NSString * mAccountID;
@property(nonatomic,retain)NSString * appkey;
@property(nonatomic,retain)NSString * appid;
@property(nonatomic,assign)BOOL firstCheckNetwork;
@property (nonatomic,retain) ReachabilityRTC* hostReach;
@property (nonatomic,retain) CMMotionManager *mMotionManager;//自动旋转
@property(nonatomic,assign)BOOL isGettingToken;//正在获取token时不能重复获取
@property (nonatomic,retain) dispatch_queue_t callBackDispatchQueue;
@property(nonatomic,assign)BOOL isViewSwitch;
@property(nonatomic,retain)NSString *notification;

+ (instancetype)sharedInstance;
- (void)setLog:(NSString*)log;
- (void)doUnRegister;
- (void)onRegister;
- (void)onSDKInit;

@end
