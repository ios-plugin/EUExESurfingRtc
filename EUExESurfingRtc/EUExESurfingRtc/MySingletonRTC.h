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

typedef enum EVENTID
{
    MSG_NEED_VIDEO = 4000,
    MSG_SET_AUDIO_DEVICE = 4001,
    MSG_SET_VIDEO_DEVICE = 4002,
    MSG_HIDE_LOCAL_VIDEO = 4003,
    MSG_ROTATE_REMOTE_VIDEO = 4004,
    MSG_SNAP = 4005,
    MSG_MUTE = 4006,
    MSG_SENDDTMF = 4007,
    MSG_DOHOLD = 4008,
    MSG_UPDATE_CALLDURATION = 4009,
    MSG_HANGUP = 4010,
    MSG_ACCEPT = 4011,
    MSG_REJECT = 4012,
}eventid;

@interface MySingletonRTC : NSObject<SdkObjCallBackProtocol,AccObjCallBackProtocol,CallObjCallBackProtocol>

@property (strong, nonatomic) SdkObj* mSDKObj;
@property (strong, nonatomic) AccObj* mAccObj;
@property (strong, nonatomic) CallObj*  mCallObj;
@property(nonatomic,retain)NSString * terminalType;
@property(nonatomic,retain)NSString * remoteTerminalType;
@property(nonatomic,retain)NSString * str;
@property(nonatomic,retain)NSString * callName;
@property(nonatomic,assign)SDK_ACCTYPE   accType;
@property(nonatomic,assign)SDK_ACCTYPE   remoteAccType;
@property(nonatomic,assign)int callTypes;
@property(nonatomic,assign)int accepptType;
@property (strong, nonatomic) DAPIPView * dapiview;
@property (strong, nonatomic) IOSDisplay *remoteVideoView;
@property (strong, nonatomic) UIView *localVideoView;
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
@property (nonatomic,copy)NSString *currentTime;
@property(nonatomic,retain)NSString * appkey;
@property(nonatomic,retain)NSString * appid;
@property(nonatomic,assign)int     mLogIndex;
@property(nonatomic,assign)BOOL firstCheckNetwork;
@property (strong, nonatomic) ReachabilityRTC* hostReach;
@property (strong, nonatomic) CMMotionManager *mMotionManager;//自动旋转
@property(nonatomic,assign)BOOL isGettingToken;//正在获取token时不能重复获取
@property (nonatomic,assign) dispatch_queue_t callBackDispatchQueue;

+ (instancetype)sharedInstance;
- (void)setLog:(NSString*)log;
- (void)doUnRegister;
- (void)onRegister;
- (void)onSDKInit;

@end
