//
//  MySingletonRTC.m
//  DEMO
//
//  Created by cc on 15/11/4.
//  Copyright © 2015年 hexc. All rights reserved.
//

#import "MySingletonRTC.h"

#define APP_USER_AGENT      @"RTC_AppCan"

@implementation MySingletonRTC

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static MySingletonRTC *sharedObject = nil;
    dispatch_once(&pred, ^{
        sharedObject = [[self alloc] init];
    });
    
    return sharedObject;
}

-(instancetype)init{
    self=[super init];
    if(self){
        self.accType = ACCTYPE_APP;
        self.terminalType = TERMINAL_TYPE_PHONE;
        [self.terminalType retain];
        self.remoteAccType = ACCTYPE_APP;
        self.remoteTerminalType = TERMINAL_TYPE_ANY;
        [self.remoteTerminalType retain];
        
        self.mMotionManager = [[CMMotionManager alloc]init];
        self.isGettingToken = NO;
        self.firstCheckNetwork = YES;
        self.callBackDispatchQueue=dispatch_queue_create("gcd.uexESurfingRtcCallBackDispatchQueue",NULL);
        [self checkNetWorkReachability];//检测网络切换
        
        NSString* islog = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"enablelog"];
        self.notification = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"notification"];
        if([islog isEqualToString:@"1"])
            initCWDebugLog();
        
        //注册本地推送
        if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]&&[[[UIDevice currentDevice]systemVersion]floatValue]>=8.0)
        {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
            CWLogDebug(@"registerUserNotificationSettings");
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    
    return self;
}

//-(void)onAccepted:(NSString*)senser
//{
//    [[NSNotificationCenter defaultCenter]  postNotificationName:@"ACCEPTED_EVENT" object:nil];
//}

-(void)cbLogStatus:(NSString*)senser{
    //[self jsSuccessWithName:@"uexESurfingRtc.cbLogStatus" opId:0 dataType:0 strData:senser];
    
    NSString* jsString = [NSString stringWithFormat:@"uexESurfingRtc.cbLogStatus(\"0\",\"0\",\'%@\');",senser];
    dispatch_async(self.callBackDispatchQueue, ^(void){
        [EUtility evaluatingJavaScriptInRootWnd:jsString];
    });
}

-(void)onGlobalStatus:(NSString*)senser{
    
    NSString* jsString = [NSString stringWithFormat:@"uexESurfingRtc.onGlobalStatus(\"0\",\"0\",\'%@\');",senser];
    dispatch_async(self.callBackDispatchQueue, ^(void){
        [EUtility evaluatingJavaScriptInRootWnd:jsString];
    });
}

-(void)cbCallStatus:(NSString*)senser{
    //[self jsSuccessWithName:@"uexESurfingRtc.cbCallStatus" opId:0 dataType:0 strData:senser];
    
    NSString* jsString = [NSString stringWithFormat:@"uexESurfingRtc.cbCallStatus(\"0\",\"0\",\'%@\');",senser];
    dispatch_async(self.callBackDispatchQueue, ^(void){
        [EUtility evaluatingJavaScriptInRootWnd:jsString];
    });
}

-(void)cbMessageStatus:(NSString*)senser{
    //[self jsSuccessWithName:@"uexESurfingRtc.cbCallStatus" opId:0 dataType:0 strData:senser];
    
    NSString* jsString = [NSString stringWithFormat:@"uexESurfingRtc.cbMessageStatus(\"0\",\"0\",\'%@\');",senser];
    dispatch_async(self.callBackDispatchQueue, ^(void){
        [EUtility evaluatingJavaScriptInRootWnd:jsString];
    });
}

- (void)onSDKInit
{
    if (self.mSDKObj && [self.mSDKObj isInitOk])
    {
        //若sdk已成功初始化，请不要重复创建，更不要频繁重复向RTC平台发送请求
        [self setLog:@"已初始化成功"];
        [self onRegister];
        return;
    }
    
    signal(SIGPIPE, SIG_IGN);
    self.mSDKObj = [[SdkObj alloc]init];//创建sdkobj指针
    
    [self.mSDKObj setSdkAgent:APP_USER_AGENT terminalType:TERMINAL_TYPE_PHONE UDID:[OpenUDIDRTC value] appID:self.appid appKey:self.appkey];
    [self.mSDKObj setDelegate:self];//必须设置回调代理，否则无法执行回调
    [self.mSDKObj doNavigation:@"default"];//参数传入@"default"即可，采用平台默认地址
}

- (void)onRegister
{
    if(!self.mSDKObj)
    {
        [self setLog:@"请先初始化"];
        CWLogDebug(@"isGettingToken:%d",self.isGettingToken);
        if(!self.isGettingToken)
        {
            self.isGettingToken = YES;
            CWLogDebug(@"初始化rtc");
            [self doUnRegister];
            [self onSDKInit];
        }
        [self performSelectorOnMainThread:@selector(cbLogStatus:) withObject:@"ERROR:UNINIT" waitUntilDone:NO];
        return;
    }
    if (!self.mAccObj)
    {
        [self setLog:@"登录中..."];
        self.mAccObj = [[AccObj alloc]init];
        [self.mAccObj bindSdkObj:self.mSDKObj];
        [self.mAccObj setDelegate:self];
        //此句代码为临时做法，开发者需通过第三方应用平台获取token，无需通过此接口获取
        //获取到返回结果后，请调用doAccRegister接口进行注册，传入参数为服务器返回的结构
        if([self.str isEqualToString:@"0"]){
            
            [self performSelectorOnMainThread:@selector(cbLogStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
            
            return;
        }else if(!self.mToken)
            [self.mAccObj getToken:self.str andType:self.accType andGrant:@"100<200" andAuthType:ACC_AUTH_TO_APPALL];
        else
        {
            self.isGettingToken = NO;
            NSMutableDictionary *newResult = [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
            [newResult setObject:self.mToken forKey:KEY_CAPABILITYTOKEN];
            [newResult setObject:self.mAccountID forKey:KEY_RTCACCOUNTID];//形如"账号类型-账号~appid~终端类型@chinartc.com"
            [newResult setObject:[NSNumber numberWithDouble:2] forKey:KEY_ACC_SRTP];//若与浏览器互通则打开
            [self.mAccObj doAccRegister:newResult];
        }
    }
    else if ([self.mAccObj isRegisted])
    {
        self.isGettingToken = NO;
        [self setLog:@"登录刷新"];
        [self.mAccObj doRegisterRefresh];
    }
    else
    {
        [self setLog:@"重新发起登录动作"];
        [self.mAccObj getToken:self.str andType:self.accType andGrant:@"100<200" andAuthType:ACC_AUTH_TO_APPALL];
    }
}

- (void)doUnRegister
{
    if (self.mAccObj)
    {
        [self.mAccObj doUnRegister];
        [self.mAccObj release];
        self.mAccObj = nil;
        self.mToken = nil;
        self.mAccountID = nil;
        CWLogDebug(@"注销完毕");
    }
    if(self.mSDKObj)
    {
        [self.mSDKObj release];
        self.mSDKObj = nil;
        CWLogDebug(@"release完毕");
    }
}

-(void)setLog:(NSString*)log
{
    //回调信息；
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"mm:ss"];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormat setLocale:usLocale];
    [usLocale release];
    NSString* datestr = [dateFormat stringFromDate:[NSDate date]];
    [dateFormat release];
    
    CWLogDebug(@"SDKTEST:%@:%@",datestr,log);
    NSString* strs = [NSString stringWithFormat:@"%@:%@",datestr,log];
    NSLog(@"++++==>>>%@",strs);
}

-(NSInteger)calcRotation:(double)xy z:(double)z
{
    if ((z >= 45 && z <= 135) || (z >= -135 && z <= -45))//处于正向水平,反向水平位置,此时可作为竖直方向
    {
        return 0;
    }
    if (xy <= 180 && xy > 135)//竖直方向,向右侧倾斜,但未到角度
    {
        return 0;
    }
    if (xy <= 135 && xy >= 90)//竖直方向,向右倾斜,已经到位
    {
        return 90;
    }
    if (xy < 90 && xy >= 45) //斜向下方向,尚未到位
    {
        return 90;
    }
    if (xy < 45 && xy >= 0)//头朝下,已到位
    {
        return 180;
    }
    if (xy < 0 && xy >= -45)//头朝下,未到位
    {
        return 180;
    }
    if (xy < -45 && xy >= -90)//头朝下,已到位
    {
        return 270;
    }
    if (xy < -90 && xy >= -135)//头朝下,未到位
    {
        return 270;
    }
    if (xy < -135 && xy >= -180)//头朝上,偏左,已到位
    {
        return 0;
    }
    return 0;
}

-(void)setMotionStatus:(BOOL)doStart
{
    if (doStart)//对端接收的图像始终保持竖直方向
    {
        [self.mMotionManager startDeviceMotionUpdatesToQueue:[[[NSOperationQueue alloc] init] autorelease]
                                                     withHandler:^(CMDeviceMotion *motion, NSError *error) {
                                                         dispatch_sync(dispatch_get_main_queue(), ^(void) {
                                                             double gravityX = motion.gravity.x;
                                                             double gravityY = motion.gravity.y;
                                                             double gravityZ = motion.gravity.z;
                                                             double xyTheta = atan2(gravityX,gravityY)/M_PI*180.0;
                                                             double zTheta = atan2(gravityZ,sqrtf(gravityX*gravityX+gravityY*gravityY))/M_PI*180.0;
                                                             NSInteger rotation = [self calcRotation:xyTheta z:zTheta];
                                                             [[NSNotificationCenter defaultCenter]postNotificationName:@"MOTIONCHECK_NOTIFY"
                                                                                                                object:nil
                                                                                                              userInfo:
                                                              [NSDictionary dictionaryWithObjectsAndKeys:
                                                               [NSNumber numberWithInteger:rotation],@"rotation",
                                                               nil]];
                                                             
                                                         });
                                                     }];
    }
    else//对端接收的图像会随着本地设备的旋转而旋转
    {
        [self.mMotionManager stopDeviceMotionUpdates];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"MOTIONCHECK_NOTIFY"
                                                           object:nil
                                                         userInfo:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithInteger:0],@"rotation",
          nil]];
        
    }
}

#pragma mark - LocalNotification delegates
#define CALL_INCOMING_FLAG  @"CALL_INCOMING_FLAG"
//标志后台来电中的状态
-(void)setCallIncomingFlag:(BOOL)reg
{
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:reg] forKey:CALL_INCOMING_FLAG];
}

-(BOOL)getCallIncomingFlag
{
    id obj = [[NSUserDefaults standardUserDefaults]objectForKey:CALL_INCOMING_FLAG];
    if (obj)
    {
        return [obj boolValue];
    }
    return NO;
}

-(BOOL)accObjIsRegisted
{
    if (self.mAccObj && [self.mAccObj isRegisted])
        return  YES;
    return NO;
}

-(BOOL)isBackground
{
    return [[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground
    ||[[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive;
}

-(void)checkNetWorkReachability
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityNetWorkStatusChanged:)
                                                 name: kReachabilityChangedNotificationRTC
                                               object: nil];
    
    self.hostReach = [[ReachabilityRTC reachabilityWithHostname:@"www.apple.com"] retain];
    [self.hostReach startNotifier];
}

- (void) reachabilityNetWorkStatusChanged: (NSNotification* )note
{
    ReachabilityRTC* curReach = [note object];
    int networkStatus = [curReach currentReachabilityStatus];
    //    BOOL isLogin = [self accObjIsRegisted];
    //    if (isLogin)
    //    {
    if (networkStatus==NotReachableRTC)
    {
        //网络断开后销毁网络数据
        [self onNetworkChanged:NO];
    }
    else
    {
        if (self.firstCheckNetwork)
        {
            self.firstCheckNetwork=NO;
            return;
        }
        //网络恢复后进行重连
        [self onNetworkChanged:YES];
    }
    //    }
    
    self.firstCheckNetwork=NO;
}

-(void)onNetworkChanged:(BOOL)netstatus
{
    if(netstatus)
    {
        CWLogDebug(@"networkChanged to YES");
        if (!self.mSDKObj || ![self.mSDKObj isInitOk] || !self.mAccObj || ![self.mAccObj isRegisted])
        {
            //            CWLogDebug(@"isGettingToken:%d",self.isGettingToken);
            //            if(!self.isGettingToken)
            //            {
            //                self.isGettingToken = YES;
            //                CWLogDebug(@"重新初始化rtc");
            //                [self doUnRegister];
            //                [self onSDKInit];
            //            }
            return;
        }
        [self.mSDKObj onAppEnterBackground];//网络恢复后进行重连
        [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"StateChanged,result=-1002" waitUntilDone:NO];
    }
    else
    {
        CWLogDebug(@"networkChanged to NO");
        [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"StateChanged,result=-1001" waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"pls check network" waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(cbCallStatus:) withObject:@"OK:NORMAL" waitUntilDone:NO];
        [self.mSDKObj onNetworkChanged];//网络断开后销毁网络数据
        
        if(self.mCallObj)//通话被迫结束，销毁通话界面
        {
            [self.mCallObj doHangupCall];
            [self.mCallObj release];
            self.mCallObj = nil;
        }
        if(self.localVideoView)
        {
            [self.localVideoView removeFromSuperview];
            [self.localVideoView release];
            self.localVideoView = nil;
        }
        if(self.remoteVideoView)
        {
            [self.remoteVideoView removeFromSuperview];
            [self.remoteVideoView release];
            self.remoteVideoView = nil;
        }
        if(self.dapiview)
        {
            [self.dapiview removeFromSuperview];
//            [self.dapiview release];
//            self.dapiview = nil;
        }
    }
}

- (void)keepAlive
{
    [self onAppEnterBackground];
}

-(void)onAppEnterBackground
{
    if (!self.mSDKObj || ![self.mSDKObj isInitOk] || !self.mAccObj || ![self.mAccObj isRegisted])
    {
        //        CWLogDebug(@"isGettingToken:%d",self.isGettingToken);
        //        if(!self.isGettingToken)
        //        {
        //            self.isGettingToken = YES;
        //            CWLogDebug(@"重新初始化rtc");
        //            [self doUnRegister];
        //            [self onSDKInit];
        //        }
        return;
    }
    [self.mSDKObj onAppEnterBackground];//SDK长连接
}

-(void)enterBackgroundNotification:(NSNotification *) notification
{
    //后台重连
    [NSRunLoop currentRunLoop];
    //[self performSelectorOnMainThread:@selector(keepAlive) withObject:nil waitUntilDone:YES];
    [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler: ^{
        [self performSelectorOnMainThread:@selector(keepAlive) withObject:nil waitUntilDone:YES];
    }];
}

-(void)enterForegroundNotification:(NSNotification *) notification
{
    if (!self.mSDKObj || ![self.mSDKObj isInitOk] || !self.mAccObj || ![self.mAccObj isRegisted])
    {
        //        CWLogDebug(@"isGettingToken:%d",self.isGettingToken);
        //        if(!self.isGettingToken)
        //        {
        //            self.isGettingToken = YES;
        //            CWLogDebug(@"重新初始化rtc");
        //            [self doUnRegister];
        //            [self onSDKInit];
        //        }
        return;
    }
//    if ([self getCallIncomingFlag])
//    {
//        [self setCallIncomingFlag:NO];
//        int callType = [[[NSUserDefaults standardUserDefaults]objectForKey:KEY_CALL_TYPE]intValue];
//        
//        //延时等待应用唤醒后，再创建界面
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5*NSEC_PER_SEC)),dispatch_get_main_queue(),^
//                       {
//                           if (callType == AUDIO_VIDEO || callType == AUDIO_VIDEO_SEND || callType == AUDIO_VIDEO_RECV)
//                           {
//                               [self showLocalView];
//                               [self showRemoteView];
//                           }
//                       });
//    }
}

#pragma mark - UIActionSheetDelegate
//导航结果回调
-(void)onNavigationResp:(int)code error:(NSString*)error
{
    [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:[NSString stringWithFormat:@"ClientListener:onInit,result=%d",code] waitUntilDone:NO];
    if (0 == code)
    {
        [self setLog:[NSString stringWithFormat:@"初始化成功"]];
        
        [self.mSDKObj setVideoCodec:[NSNumber numberWithInt:1]];//VP8
        [self.mSDKObj setAudioCodec:[NSNumber numberWithInt:1]];//iLBC
        [self.mSDKObj setVideoAttr:[NSNumber numberWithInt:3]];//CIF
        
        [self onRegister];
    }
    else
    {
        [self setLog:[NSString stringWithFormat:@"初始化失败:%d,%@",code,error]];
        [self.mSDKObj release];
        self.mSDKObj = nil;
        self.isGettingToken = NO;
        
        if(code == -1001)//没有网络
            [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"StateChanged,result=-1001" waitUntilDone:NO];
        else if(code == -1002)//切换网络
            [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"StateChanged,result=-1002" waitUntilDone:NO];
        else if(code == -1003)//网络差
            [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"StateChanged,result=-1003" waitUntilDone:NO];
        else if(code == -1004)//重连失败需要重登录
            [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"StateChanged,result=-1004" waitUntilDone:NO];
    }
}

//注册结果回调
-(int)onRegisterResponse:(NSDictionary*)result  accObj:(AccObj*)accObj
{
    self.mToken = [result objectForKey:KEY_CAPABILITYTOKEN];
    self.mAccountID = [result objectForKey:KEY_RTCACCOUNTID];
    self.isGettingToken = NO;
    if(self.mToken)
    {
        NSMutableDictionary *newResult = [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
        [newResult setObject:self.mToken forKey:KEY_CAPABILITYTOKEN];
        [newResult setObject:self.mAccountID forKey:KEY_RTCACCOUNTID];//形如"账号类型-账号~appid~终端类型@chinartc.com"
        [newResult setObject:[NSNumber numberWithDouble:2] forKey:KEY_ACC_SRTP];//若与浏览器互通则打开
        [self.mAccObj doAccRegister:newResult];
        return EC_OK;
    }
    if (nil == result || nil == accObj)
    {
        [self setLog:@"注册请求失败-未知原因"];
        return EC_PARAM_WRONG;
    }
    id obj = [result objectForKey:KEY_REG_EXPIRES];
    if (nil == obj)
    {
        [self setLog:@"注册请求失败-丢失字段KEY_REG_EXPIRES"];
        return EC_PARAM_WRONG;
    }
    int nExpire = [obj intValue];
    
    obj = [result objectForKey:KEY_REG_RSP_CODE];
    if (nil == obj)
    {
        [self setLog:@"注册请求失败-丢失字段KEY_REG_RSP_CODE"];
        return EC_PARAM_WRONG;
    }
    int nRspCode = [obj intValue];
    
    obj = [result objectForKey:KEY_REG_RSP_REASON];
    if (nil == obj)
    {
        [self setLog:@"注册请求失败-丢失字段KEY_REG_RSP_REASON"];
        return EC_PARAM_WRONG;
    }
    NSString* sReason = obj;
    
    [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:[NSString stringWithFormat:@"获取token:%d reason:%@",nRspCode,sReason] waitUntilDone:NO];
    if (nRspCode == 200)
    {
        [self setLog:[NSString stringWithFormat:@"登录成功,距下次注册%d秒",nExpire]];
        [self performSelectorOnMainThread:@selector(cbLogStatus:) withObject:@"OK:LOGIN" waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"StateChanged,result=200" waitUntilDone:NO];
    }
    else
    {
        [self setLog:[NSString stringWithFormat:@"登录失败:%d:%@",nRspCode,sReason]];
        
        //        if (self.mAccObj)
        //        {
        //            [self.mAccObj doUnRegister];
        //            [self.mAccObj release];
        //            self.mAccObj = nil;
        //            [self setLog:@"注销完毕"];
        //
        //            if(self.mSDKObj)
        //            {
        //                [self.mSDKObj release];
        //                self.mSDKObj = nil;
        //                [self setLog:@"release完毕"];
        //            }
        //            [self.localVideoView removeFromSuperview];
        //            [self.remoteVideoView removeFromSuperview];
        //        }
        
        [self performSelectorOnMainThread:@selector(cbLogStatus:) withObject:[NSString stringWithFormat:@"ERROR:获取token失败 [status:%d]%@",nRspCode,sReason] waitUntilDone:NO];
        if(nRspCode == -1001)//没有网络
            [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"StateChanged,result=-1001" waitUntilDone:NO];
        else if(nRspCode == -1002)//切换网络
            [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"StateChanged,result=-1002" waitUntilDone:NO];
        else if(nRspCode == -1003)//网络差
            [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"StateChanged,result=-1003" waitUntilDone:NO];
        else if(nRspCode == -1004)//重连失败需要重登录
            [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"StateChanged,result=-1004" waitUntilDone:NO];
    }
    
    return EC_OK;
}

//用户在线状态查询结果回调
-(int)onAccStatusQueryResponse:(NSDictionary*)result accObj:(AccObj*)accObj
{
    return EC_OK;
}

//发送IM消息结果回调
-(int)onSendIM:(int)status
{
    CWLogDebug(@"发送消息:%d",status);
    
    if(status == 200)
        [self performSelectorOnMainThread:@selector(cbMessageStatus:) withObject:@"OK:SEND" waitUntilDone:NO];
    else// if(status == 404)
        [self performSelectorOnMainThread:@selector(cbMessageStatus:) withObject:[NSString stringWithFormat:@"ERROR:%d",status] waitUntilDone:NO];
    
    return 0;
}

//接收到IM消息回调
-(int)onReceiveIM:(NSDictionary*)param withAccObj:(AccObj*)accObj
{
    CWLogDebug(@"result is %@onCall:%@",param,accObj);
    
    //NSString* mime = [param objectForKey:KEY_CALL_TYPE];
    NSString* uri = [param objectForKey:KEY_CALLER];
    NSString* content = [param objectForKey:KEY_CALL_INFO];
    CWLogDebug(@"接收消息:%@",content);
    
    if(content)
    {
        const char* cacc = [uri UTF8String];
        int strindex1=0,strindex2=0;
        int l = (int)strlen(cacc);
        for(int i = 0;i<l;i++)
        {
            if(cacc[i]=='-')
            {
                strindex1=i;
                break;
            }
        }
        for(int i = 0;i<l;i++)
        {
            if(cacc[i]=='~')
            {
                strindex2=i;
                break;
            }
        }
        NSString* accNum = [[NSString stringWithUTF8String:cacc] substringWithRange:NSMakeRange(strindex1+1, strindex2-strindex1-1)];
        
        [self performSelectorOnMainThread:@selector(cbMessageStatus:) withObject:@"OK:RECEIVE" waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:[NSString stringWithFormat:@"onReceiveIm:from:%@,msg:%@",accNum,content] waitUntilDone:NO];
    }
    
    return 0;
}

//在这里增加来电后台通知或前台弹呼叫接听页面
-(int)onCallIncoming:(NSDictionary*)param withNewCallObj:(CallObj*)newCallObj accObj:(AccObj*)accObj
{
    if(newCallObj)
    {
        self.mCallObj = newCallObj;
        [self.mCallObj setDelegate:self];
    }
    
    int callType = [[param objectForKey:KEY_CALL_TYPE]intValue];
    NSLog(@"%d",callType);
    NSString* uri = [param objectForKey:KEY_CALLER];
    NSString* ci = [param objectForKey:KEY_CALL_INFO];
    if(!ci)
        ci = @"";
    
    const char* cacc = [uri UTF8String];
    int strindex1=0,strindex2=0;
    int l = (int)strlen(cacc);
    for(int i = 0;i<l;i++)
    {
        if(cacc[i]=='-')
        {
            strindex1=i;
            break;
        }
    }
    for(int i = 0;i<l;i++)
    {
        if(cacc[i]=='~')
        {
            strindex2=i;
            break;
        }
    }
    NSString* accNum = [[NSString stringWithUTF8String:cacc] substringWithRange:NSMakeRange(strindex1+1, strindex2-strindex1-1)];
    
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         ci,KEY_CALL_INFO,
                         [NSNumber numberWithInt:callType],@"t",
                         [NSNumber numberWithInt:2],@"dir",
                         accNum,@"uri",
                         nil];
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    NSRange range3 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\\" withString:@"" options:NSLiteralSearch range:range3];
    //    [jsonString stringByReplacingOccurrencesOfString:@"\\n" withString:@""];
    //    [jsonString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    
    NSString* str = nil;
    if(newCallObj)
    {
        str = [NSString stringWithFormat:@"DeviceListener:onNewCall,call=%@", mutStr];
        [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:str waitUntilDone:NO];
    }
    else
    {
        str = [NSString stringWithFormat:@"DeviceListener:rejectIncomingCall call=%@", mutStr];
        [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:str waitUntilDone:NO];
        return 0;
    }
    
    [self performSelectorOnMainThread:@selector(cbCallStatus:) withObject:@"OK:INCOMING" waitUntilDone:NO];
    if ([self isBackground])
    {
        [self setCallIncomingFlag:YES];
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:callType] forKey:KEY_CALL_TYPE];
        [[NSUserDefaults standardUserDefaults]setObject:uri     forKey:KEY_CALLER];
        
        CWLogDebug(@"self.notification = %@",self.notification);
        if([self.notification isEqualToString:@"callInfo"])
            makeNotification(@"接听",[NSString stringWithFormat:@"来电:%@",ci],UILocalNotificationDefaultSoundName,YES);
        else
            makeNotification(@"接听",[NSString stringWithFormat:@"来电:%@",accNum],UILocalNotificationDefaultSoundName,YES);
        return 0;
    }
//    if (callType == AUDIO_VIDEO || callType == AUDIO_VIDEO_SEND || callType == AUDIO_VIDEO_RECV)
//    {
//        [self showLocalView];
//        [self showRemoteView];
//    }
    
    return 0;
}

//呼叫事件回调
-(int)onCallBack:(SDK_CALLBACK_TYPE)type code:(int)code callObj:(CallObj*)callObj
{
    [self setLog:[NSString stringWithFormat:@"呼叫事件:%d code:%d",type,code]];
    //不同事件类型见SDK_CALLBACK_TYPE
    if(type == SDK_CALLBACK_RING)
    {
        [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"ConnectionListener:onConnecting" waitUntilDone:NO];
    }
    else if (type == SDK_CALLBACK_ACCEPTED)
    {
        [self.dapiview setHidden:NO];
        [self.localVideoView setHidden:NO];
        [self.remoteVideoView setHidden:NO];
        //[self performSelectorOnMainThread:@selector(onAccepted:) withObject:nil waitUntilDone:NO];
        [self.mCallObj doSwitchAudioDevice:SDK_AUDIO_OUTPUT_DEFAULT];
        [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"ConnectionListener:onConnected" waitUntilDone:NO];
        [self setCallIncomingFlag:NO];
    }
    else  if (type == SDK_CALLBACK_CLOSED)
    {
        [self performSelectorOnMainThread:@selector(cbCallStatus:) withObject:@"OK:NORMAL" waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:[NSString stringWithFormat:@"ConnectionListener:onDisconnect,code=200"] waitUntilDone:NO];
        if(self.localVideoView)
        {
            [self.localVideoView removeFromSuperview];
            [self.localVideoView release];
            self.localVideoView = nil;
        }
        if(self.remoteVideoView)
        {
            [self.remoteVideoView removeFromSuperview];
            [self.remoteVideoView release];
            self.remoteVideoView = nil;
        }
        if(self.dapiview)
        {
            [self.dapiview removeFromSuperview];
//            [self.dapiview release];
//            self.dapiview = nil;
        }
        if (self.mCallObj)
        {
            [self.mCallObj release];
            self.mCallObj = nil;
        }
        [self setCallIncomingFlag:NO];
    }
    else  if (type == SDK_CALLBACK_FAILED || type == SDK_CALLBACK_CANCELED)
    {
        [self performSelectorOnMainThread:@selector(cbCallStatus:) withObject:@"OK:NORMAL" waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:[NSString stringWithFormat:@"ConnectionListener:onDisconnect,code=%d",code] waitUntilDone:NO];
        if(self.localVideoView)
        {
            [self.localVideoView removeFromSuperview];
            [self.localVideoView release];
            self.localVideoView = nil;
        }
        if(self.remoteVideoView)
        {
            [self.remoteVideoView removeFromSuperview];
            [self.remoteVideoView release];
            self.remoteVideoView = nil;
        }
        if(self.dapiview)
        {
            [self.dapiview removeFromSuperview];
//            [self.dapiview release];
//            self.dapiview = nil;
        }
        if (self.mCallObj)
        {
            [self.mCallObj release];
            self.mCallObj = nil;
        }
        [self setCallIncomingFlag:NO];
    }
    
    return 0;
}

//呼叫媒体建立事件通知
-(int)onCallMediaCreated:(int)mediaType callObj:(CallObj *)callObj
{
    if (mediaType == MEDIA_TYPE_VIDEO)
    {
        int ret = [callObj doSetCallVideoWindow:self.remoteVideoView localVideoWindow:self.localVideoView];
        NSLog(@">>>%d",ret);
        [self setLog:[NSString stringWithFormat:@"%d",ret]];
        [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"ConnectionListener:onVideo" waitUntilDone:NO];
    }
    [self setMotionStatus:YES];
    [self setCallIncomingFlag:NO];
    return 0;
}

//呼叫网络状态事件通知
-(int)onNetworkStatus:(NSString*)desc callObj:(CallObj*)callObj
{
    return 0;
}

//通知
-(int)onNotifyMessage:(NSDictionary*)result  accObj:(AccObj*)accObj
{
    CWLogDebug(@"%s result is %@onNotify:%@",__FUNCTION__,result,accObj);
    NSString* kickedBy = [result objectForKey:@"kickedBy"];//同一账号不同设备登录被踢出
    NSString* multiLogin = [result objectForKey:@"multiLogin"];//多终端登录
    
    if(kickedBy)//被踢下线
    {
        [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"StateChanged,result=-1500" waitUntilDone:NO];
    }
    else if(multiLogin)//多终端登录
    {
        [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"StateChanged,result=-1501" waitUntilDone:NO];
    }
    
    return EC_OK;
}

//多人
-(int)onGroupResponse:(NSDictionary*)result grpObj:(CallObj*)grpObj
{
    return EC_OK;
}

-(int)onGroupCreate:(NSDictionary*)param withNewCallObj:(CallObj*)newCallObj accObj:(AccObj*)accObj
{
    return EC_OK;
}


@end
