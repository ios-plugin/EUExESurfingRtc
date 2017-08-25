//
//  EUExESurfingRtc.m
//  AppCanPlugin
//
//  Created by cc on 15/5/13.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "EUExESurfingRtc.h"
#import "JSON.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <AVFoundation/AVCaptureSession.h>
#import "DAPIPView.h"

@implementation EUExESurfingRtc

@synthesize mgr;

//每次open一个新窗口并触发插件接口时，会进入一次此函数
- (id)initWithBrwView:(EBrowserView *)eInBrwView
{
    self = [super initWithBrwView:eInBrwView];
    if (self) {
        self.mgr=[MySingletonRTC sharedInstance];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRecvEvent:) name:@"NOTIFY_EVENT" object:nil];
        
        if(self.mgr.pushInfo && ![self.mgr.pushInfo isEqualToString:@""] && self.mgr.isRoot)
        {
            self.mgr.isRoot = NO;
            [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:[NSString stringWithFormat:@"APNs:%@",self.mgr.pushInfo] waitUntilDone:NO];
        }
    }
    return self;
}

+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[MySingletonRTC sharedInstance] application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions];
    
    return YES;
}

+ (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [[MySingletonRTC sharedInstance] application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings];
}

+ (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[MySingletonRTC sharedInstance] application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken];
}

+ (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[MySingletonRTC sharedInstance] application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error];
}

+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[MySingletonRTC sharedInstance] application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo];
}

+ (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [[MySingletonRTC sharedInstance] application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler];
}

+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    [[MySingletonRTC sharedInstance] application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler];
}

-(void)cbLogStatus:(NSString*)senser{
    //[self jsSuccessWithName:@"uexESurfingRtc.cbLogStatus" opId:0 dataType:0 strData:senser];
    
    NSString* jsString = [NSString stringWithFormat:@"uexESurfingRtc.cbLogStatus(\"0\",\"0\",\'%@\');",senser];
    dispatch_async(self.mgr.callBackDispatchQueue, ^(void){
        [EUtility evaluatingJavaScriptInRootWnd:jsString];
    });
}

-(void)onGlobalStatus:(NSString*)senser{
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm:ss"];
    NSString* datestr = [dateFormat stringFromDate:[NSDate date]];
    [dateFormat release];
    NSString* strs = [NSString stringWithFormat:@"%@: %@",datestr,senser];
    NSString* jsString = [NSString stringWithFormat:@"uexESurfingRtc.onGlobalStatus(\"0\",\"0\",\'%@\');",strs];
    dispatch_async(self.mgr.callBackDispatchQueue, ^(void){
        [EUtility evaluatingJavaScriptInRootWnd:jsString];
    });
}

-(void)cbCallStatus:(NSString*)senser{
    //[self jsSuccessWithName:@"uexESurfingRtc.cbCallStatus" opId:0 dataType:0 strData:senser];
    
    NSString* jsString = [NSString stringWithFormat:@"uexESurfingRtc.cbCallStatus(\"0\",\"0\",\'%@\');",senser];
    dispatch_async(self.mgr.callBackDispatchQueue, ^(void){
        [EUtility evaluatingJavaScriptInRootWnd:jsString];
    });
}

-(void)cbMessageStatus:(NSString*)senser{
    //[self jsSuccessWithName:@"uexESurfingRtc.cbCallStatus" opId:0 dataType:0 strData:senser];
    
    NSString* jsString = [NSString stringWithFormat:@"uexESurfingRtc.cbMessageStatus(\"0\",\"0\",\'%@\');",senser];
    dispatch_async(self.mgr.callBackDispatchQueue, ^(void){
        [EUtility evaluatingJavaScriptInRootWnd:jsString];
    });
}

-(void)cbGroupStatus:(NSString*)senser
{
    NSString* jsString = [NSString stringWithFormat:@"uexESurfingRtc.cbGroupStatus(\"0\",\"0\",\'%@\');",senser];
    dispatch_async(self.mgr.callBackDispatchQueue, ^(void){
        [EUtility evaluatingJavaScriptInRootWnd:jsString];
    });
}

-(void)callBackMethodSuccess:(NSString *)jsString{
    if (self.meBrwView) {
        jsString = [NSString stringWithFormat:@"uexESurfingRtc.cbRemotePicPath(\"0\",\"0\",\'%@\');",jsString];
        
        NSLog(@"保存到图片完成的(完成后调用)js========:%@",jsString);
        
        //[self.meBrwView stringByEvaluatingJavaScriptFromString:jsString];
        
        dispatch_async(self.mgr.callBackDispatchQueue, ^(void){
            [EUtility evaluatingJavaScriptInRootWnd:jsString];
        });
    }
}

-(void)setAppKeyAndAppId:(NSMutableArray *)inArgument{
    
    if ([inArgument isKindOfClass:[NSMutableArray class]] && [inArgument count] == 2){
        
        self.mgr.appkey =[inArgument objectAtIndex:0];
        self.mgr.appid = [inArgument objectAtIndex:1];
        
        if(!self.mgr.appkey || !self.mgr.appid || [self.mgr.appkey isEqualToString:@""] || [self.mgr.appkey isEqualToString:@""])
        {
            [self performSelectorOnMainThread:@selector(cbLogStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
            return;
        }
        
//        if ([self.mgr.appkey intValue]>0||[self.mgr.appid intValue]>0)
//        {
//            [self jsSuccessWithName:@"uexESurfingRtc.cbSetAppKeyAndAppId" opId:0 dataType:0 strData:@"OK"];
//
//        }else{
//            [self jsSuccessWithName:@"uexESurfingRtc.cbSetAppKeyAndAppId" opId:0 dataType:0 strData:@"ERROR:PARM_ERROR"];
//        }
    }
}

//登录接口
-(void)login:(NSMutableArray*)inArgument
{    
    if ([inArgument isKindOfClass:[NSMutableArray class]]/* && [inArgument count] == 2*/)
    {
        NSLog(@"login-----appid----->>>%@...appkey____--->>>>%@",self.mgr.appid,self.mgr.appkey);
        
        if ([self.mgr.appkey intValue] !=0||[self.mgr.appid intValue]!=0)
        {
            NSString* number = [inArgument objectAtIndex:1];
            NSLog(@"username:---->>>>>%@",number);
            if(!number || [number isEqualToString:@""])
            {
                [self performSelectorOnMainThread:@selector(cbLogStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
                return;
            }
            
            NSString * infoStr = [inArgument objectAtIndex:0];
            if(!infoStr || [infoStr isEqualToString:@""])
            {
                [self performSelectorOnMainThread:@selector(cbLogStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
                return;
            }
            NSDictionary * dic = [infoStr JSONValue];
            NSLog(@"view:---->>>>>%@",dic);
            NSDictionary * dict = [dic objectForKey:@"localView"];
            NSDictionary * dictt = [dic objectForKey:@"remoteView"];
            
            self.mgr.x = [[dict objectForKey:@"x"] intValue];
            self.mgr.y = [[dict objectForKey:@"y"] intValue];
            self.mgr.width = [[dict objectForKey:@"w"]intValue];
            self.mgr.height = [[dict objectForKey:@"h"]intValue];
            self.mgr.x1 = [[dictt objectForKey:@"x"]intValue];
            self.mgr.y1 = [[dictt objectForKey:@"y"]intValue];
            self.mgr.width1 = [[dictt objectForKey:@"w"]intValue];
            self.mgr.height1 = [[dictt objectForKey:@"h"]intValue];
            self.mgr.userID = number;
            
            if([inArgument count]>2)
                self.mgr.nickName = [inArgument objectAtIndex:2];
            
            [self.mgr onSDKInit];
            
        }else{
            [self performSelectorOnMainThread:@selector(cbLogStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
        }
    }
    else{
        [self performSelectorOnMainThread:@selector(cbLogStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
    }
}

//注销logout接口；
-(void)logout: (NSMutableArray *)inArgument
{
    [self.mgr doUnRegister];
    [self performSelectorOnMainThread:@selector(cbLogStatus:) withObject:@"OK:LOGOUT" waitUntilDone:NO];
    if(self.mgr.localVideoView)
    {
        [self.mgr.localVideoView removeFromSuperview];
        [self.mgr.localVideoView release];
        self.mgr.localVideoView = nil;
    }
    if(self.mgr.remoteVideoView)
    {
        [self.mgr.remoteVideoView removeFromSuperview];
        [self.mgr.remoteVideoView release];
        self.mgr.remoteVideoView = nil;
    }
    if(self.mgr.dapiview)
    {
        [self.mgr.dapiview removeFromSuperview];
//        [self.mgr.dapiview release];
//        self.mgr.dapiview = nil;
    }
}

//set分辨率接口
-(void)setVideoAttr:(NSMutableArray*)inArgument
{
    if ([inArgument isKindOfClass:[NSMutableArray class]] && [inArgument count] == 1){
        
        if (!self.mgr.mSDKObj)
        {
            [self.mgr setLog:@"请先初始化"];
        }
        else{
            
            self.mgr.Resolutions = [[inArgument objectAtIndex:0] intValue];
            
            if (self.mgr.Resolutions ==0){
                
                [self.mgr.mSDKObj setVideoAttr:[NSNumber numberWithInt:3]];
                
            }else if (self.mgr.Resolutions ==1) {
                
                [self.mgr.mSDKObj setVideoAttr:[NSNumber numberWithInt:1]];
                
            } else if (self.mgr.Resolutions ==2) {
                
                [self.mgr.mSDKObj setVideoAttr:[NSNumber numberWithInt:4]];
                
            }
            else if (self.mgr.Resolutions ==3){
                
                [self.mgr.mSDKObj setVideoAttr:[NSNumber numberWithInt:6]];
            
            }
            else if (self.mgr.Resolutions ==4){
                
                [self.mgr.mSDKObj setVideoAttr:[NSNumber numberWithInt:7]];
                
            }
            else{
                
                [self.mgr.mSDKObj setVideoAttr:[NSNumber numberWithInt:3]];
                
            }
        }
    }
}

//发送IM消息
- (void)sendMessage:(NSMutableArray *)inArgument
{
    if ([inArgument isKindOfClass:[NSMutableArray class]] && [inArgument count] == 2)
    {
        NSString* remoteuserID=  [inArgument objectAtIndex:0];
        SDK_ACCTYPE remoteAccType = ACCTYPE_APP;//(SDK_ACCTYPE)[paramDict integerValueForKey:@"remoteacctype"  defaultValue:10];
        NSString* remoteTerminalType = TERMINAL_TYPE_ANY;// [paramDict objectForKey:@"remoteterminaltype"];
        NSString* message = [inArgument objectAtIndex:1];
        if(!self.mgr.mSDKObj)
        {
            CWLogDebug(@"请先初始化");
            return;
        }
        if (!self.mgr.mAccObj)
        {
            CWLogDebug(@"请先登录");
            return;
        }
        if(!remoteuserID || [remoteuserID isEqualToString:@""] || !message || [message isEqualToString:@""])
        {
            [self performSelectorOnMainThread:@selector(cbMessageStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
            return;
        }
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             remoteuserID,KEY_CALLED,
                             [NSNumber numberWithInt:remoteAccType],KEY_CALL_REMOTE_ACC_TYPE,
                             remoteTerminalType,KEY_CALL_REMOTE_TERMINAL_TYPE,
                             message,KEY_CALL_INFO,
                             nil];
        [self.mgr.mAccObj doSendIM:dic];
    }
    else
        [self performSelectorOnMainThread:@selector(cbMessageStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
}

//call；
-(void)call:(NSMutableArray *)inArgument
{
    if ([inArgument isKindOfClass:[NSMutableArray class]]/* && [inArgument count] == 3*/){
        
        int jscallType = [[inArgument objectAtIndex:0] intValue];
        if(jscallType == 1)
            self.mgr.callTypes = AUDIO;
        else if(jscallType == 2)
            self.mgr.callTypes = AUDIO_VIDEO;
        else if(jscallType == 3)
            self.mgr.callTypes = AUDIO_VIDEO_RECV;
        else if(jscallType == 4)
            self.mgr.callTypes = AUDIO_VIDEO_SEND;
        else
        {
            [self performSelectorOnMainThread:@selector(cbCallStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
            return;
        }
        
        self.mgr.callName =  [inArgument objectAtIndex:1];
        if(!self.mgr.callName || [self.mgr.callName isEqualToString:@""])
        {
            [self performSelectorOnMainThread:@selector(cbCallStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
            return;
        }
        
        NSString* callinfo = @"";
        if([inArgument count] == 3)
        {
            callinfo = [inArgument objectAtIndex:2];
            if(!callinfo)
                callinfo = @"";
        }
        
        if(!self.mgr.mSDKObj)
        {
            [self.mgr setLog:@"请先初始化"];
            [self performSelectorOnMainThread:@selector(cbCallStatus:) withObject:@"ERROR:UNREGISTER" waitUntilDone:NO];
            
            return;
        }
        
        if (self.mgr.callTypes == AUDIO_VIDEO || self.mgr.callTypes == AUDIO_VIDEO_SEND || self.mgr.callTypes == AUDIO_VIDEO_RECV)
        {
            [self showRemoteView];
            [self showLocalView];
            [self.mgr.dapiview setHidden:YES];
            [self.mgr.localVideoView setHidden:YES];
            [self.mgr.remoteVideoView setHidden:YES];
        }
        
        if (self.mgr.mCallObj ==nil)
        {
            self.mgr.mCallObj = [[CallObj alloc]init];
            [self.mgr.mCallObj setDelegate:self.mgr];
            [self.mgr.mCallObj bindAcc:self.mgr.mAccObj];
            
            if (self.mgr.callTypes == AUDIO || self.mgr.callTypes == AUDIO_SEND || self.mgr.callTypes == AUDIO_RECV)
            {
                self.mgr.mCallObj.CallMedia = MEDIA_TYPE_AUDIO;
            }
            else
                self.mgr.mCallObj.CallMedia = MEDIA_TYPE_VIDEO;
            
            NSString* remoteUri = self.mgr.callName;
            NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 remoteUri,KEY_CALLED,
                                 [NSNumber numberWithInt:self.mgr.callTypes],KEY_CALL_TYPE,
                                 [NSNumber numberWithInt:ACCTYPE_APP],KEY_CALL_REMOTE_ACC_TYPE,
                                 self.mgr.remoteTerminalType,KEY_CALL_REMOTE_TERMINAL_TYPE,
                                 callinfo,KEY_CALL_INFO,
                                 nil];
            int ret = [self.mgr.mCallObj doMakeCall:dic];
            self.mgr.calldic = [NSMutableDictionary dictionaryWithDictionary:dic];
            [self.mgr.calldic retain];
            if (EC_OK > ret)
            {
                if (self.mgr.mCallObj)
                {
                    [self.mgr.mCallObj doReleaseCallResource];
                    [self.mgr.mCallObj release];
                    self.mgr.mCallObj = nil;
                }
                if(self.mgr.localVideoView)
                {
                    [self.mgr.localVideoView removeFromSuperview];
                    [self.mgr.localVideoView release];
                    self.mgr.localVideoView = nil;
                }
                if(self.mgr.remoteVideoView)
                {
                    [self.mgr.remoteVideoView removeFromSuperview];
                    [self.mgr.remoteVideoView release];
                    self.mgr.remoteVideoView = nil;
                }
                if(self.mgr.dapiview)
                {
                    [self.mgr.dapiview removeFromSuperview];
                    [self.mgr.dapiview release];
                    self.mgr.dapiview = nil;
                }
                
                [self.mgr setLog:[NSString stringWithFormat:@"创建呼叫失败:%@",[SdkObj ECodeToStr:ret]]];
                [self performSelectorOnMainThread:@selector(cbCallStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
                return;
            }
            [self performSelectorOnMainThread:@selector(cbCallStatus:) withObject:@"OK:CALLING" waitUntilDone:NO];
            //切换音频播放设备；doSwitchAudioDevice:
            [self.mgr.mCallObj doSwitchAudioDevice:SDK_AUDIO_OUTPUT_DEFAULT];
        }
    }
}

//接听acceptCall接口；
-(void)acceptCall:(NSMutableArray*)inArgument
{
    if ([inArgument isKindOfClass:[NSMutableArray class]] && [inArgument count] == 1){
        
        [self.mgr.pushInfo release];
        self.mgr.pushInfo = @"";
        [self.mgr.pushInfo retain];
        NSLog(@"%@",inArgument);
        int jscallType = [[inArgument objectAtIndex:0] intValue];
        if(jscallType == 1)
            self.mgr.accepptType = AUDIO;
        else if(jscallType == 2)
            self.mgr.accepptType = AUDIO_VIDEO;
        else if(jscallType == 3)
            self.mgr.accepptType = AUDIO_VIDEO_RECV;
        else if(jscallType == 4)
            self.mgr.accepptType = AUDIO_VIDEO_SEND;
        else
        {
            [self performSelectorOnMainThread:@selector(cbCallStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
            return;
        }
        
        if(!self.mgr.mSDKObj)
        {
            [self.mgr setLog:@"请先初始化"];
            [self performSelectorOnMainThread:@selector(cbCallStatus:) withObject:@"ERROR:UNREGISTER" waitUntilDone:NO];
            return;
        }
        
        //[self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"ConnectionListener:onConnected" waitUntilDone:NO];
        [self.mgr.mCallObj doSwitchAudioDevice:SDK_AUDIO_OUTPUT_DEFAULT];
        if (self.mgr.accepptType == AUDIO)
        {
            
            [self.mgr.mCallObj doAcceptCall:[NSNumber numberWithInt:self.mgr.accepptType]];
            [self.mgr setLog:@"音频已接听"];
        }
        else
        {
            [self showRemoteView];
            
            if(self.mgr.isGroup == 0)
                [self showLocalView];
            [self.mgr setLog:@"视频已接听"];
            [self.mgr.mCallObj doAcceptCall:[NSNumber numberWithInt:self.mgr.accepptType]];
        }
        [self performSelectorOnMainThread:@selector(cbCallStatus:) withObject:@"OK:CALLING" waitUntilDone:NO];
    }
}

//挂断hangUp接口；
-(void)hangUp:(NSMutableArray*)inArgument
{
    if(!self.mgr.mSDKObj)
    {
        [self.mgr setLog:@"请先初始化"];
        
        return;
    }
    
    [self.mgr.pushInfo release];
    self.mgr.pushInfo = @"";
    [self.mgr.pushInfo retain];
    [self performSelectorOnMainThread:@selector(cbCallStatus:) withObject:@"OK:NORMAL" waitUntilDone:NO];
    if (self.mgr.mCallObj)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5*NSEC_PER_SEC)),dispatch_get_main_queue(),^{
            [self.mgr.mCallObj doHangupCall];
            [self.mgr.mCallObj release];
            self.mgr.mCallObj = nil;
        });
    }
    
    [self.mgr setLog:@"呼叫已结束"];
    if(self.mgr.localVideoView)
    {
        [self.mgr.localVideoView removeFromSuperview];
        [self.mgr.localVideoView release];
        self.mgr.localVideoView = nil;
    }
    if(self.mgr.remoteVideoView)
    {
        [self.mgr.remoteVideoView removeFromSuperview];
        [self.mgr.remoteVideoView release];
        self.mgr.remoteVideoView = nil;
    }
    if(self.mgr.dapiview)
    {
        [self.mgr.dapiview removeFromSuperview];
//        [self.mgr.dapiview release];
//        self.mgr.dapiview = nil;
    }
    [self.mgr.calldic release];
    self.mgr.calldic = nil;
    [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"call hangup" waitUntilDone:NO];
}

//扬声器

-(void)loudSpeaker:(NSMutableArray*)inArgument
{
    if([inArgument isKindOfClass:[NSMutableArray class]] && [inArgument count] == 1)
    {
        NSString* flag = [inArgument objectAtIndex:0];
        int arg = 0;
        
        if ([flag isEqualToString:@"true"])
            arg = 1;
       else
           arg = 0;
        
        if (!self.mgr.mCallObj)
        {
            [self.mgr setLog:@"切换放音设备前请先呼叫"];
            return;
        }
        //SDK_AUDIO_OUTPUT_DEVICE ad = [mCallObj getAudioOutputDeviceType];
        if (arg == 1/*SDK_AUDIO_OUTPUT_DEFAULT == ad || SDK_AUDIO_OUTPUT_HEADSET == ad*/)
        {
            [self.mgr.mCallObj doSwitchAudioDevice:SDK_AUDIO_OUTPUT_SPEAKER];
            [self.mgr setLog:@"放音设备切换到外放"];
        }
        else
        {
            [self.mgr.mCallObj doSwitchAudioDevice:SDK_AUDIO_OUTPUT_DEFAULT];
            [self.mgr setLog: @"放音设备切换到听筒/耳机"];
        }
    }
}

//静音mute接口
-(void)mute:(NSMutableArray*)inArgument
{
    if([inArgument isKindOfClass:[NSMutableArray class]] && [inArgument count] == 1)
    {
        NSString* flag = [inArgument objectAtIndex:0];
        int arg = 0;
        
        if ([flag isEqualToString:@"true"])
            arg = 1;
        else
            arg = 0;
        
        if (!self.mgr.mCallObj)
        {
            [self.mgr setLog:@"静音前请先呼叫"];
            return;
        }
        if (arg == 1/*[mCallObj MuteStatus] == NO*/)
        {
            [self.mgr.mCallObj doMuteMic:MUTE_DOMUTE];
            [self.mgr setLog:@"静音"];
        }
        else
        {
            [self.mgr.mCallObj doMuteMic:MUTE_DOUNMUTE];
            [self.mgr setLog:@"解除静音"];
        }
    }
}

//截图
-(void)takeRemotePicture:(NSMutableArray*)inArgument{
    
    if (!self.mgr.mCallObj || self.mgr.mCallObj.CallMedia!= MEDIA_TYPE_VIDEO)
    {
        [self.mgr setLog:@"请先呼叫"];
        return;
    }
    
    [self.mgr.mCallObj doSnapImage];
    
    [self callBackMethodSuccess:[NSString stringWithFormat:@"%@",@"/private/var/mobile/Media/DCIM"]];
    
    return;
}

-(void)switchCamera:(NSMutableArray*)inArgument
{
    if ([inArgument isKindOfClass:[NSMutableArray class]] && [inArgument count] == 1)
    {
        if(!self.mgr.mSDKObj)
        {
            CWLogDebug(@"请先初始化");
            return;
        }
        if (!self.mgr.mAccObj)
        {
            CWLogDebug(@"请先登录");
            return;
        }
        NSString* flag = [inArgument objectAtIndex:0];
        int camera = 1;
        if ([flag isEqualToString:@"front"])
            camera = 1;
        else
            camera = 0;
        
        if (self.mgr.mCallObj && self.mgr.mCallObj.CallMedia == MEDIA_TYPE_VIDEO)
            [self.mgr.mCallObj doSwitchCamera:camera];//1为前置，0为后置
        else if(!self.mgr.mCallObj)
        {
            CWLogDebug(@"请先呼叫");
            return;
        }
    }
}

-(void)rotateCamera:(NSMutableArray*)inArgument
{
    if ([inArgument isKindOfClass:[NSMutableArray class]] && [inArgument count] == 1)
    {
        if(!self.mgr.mSDKObj)
        {
            CWLogDebug(@"请先初始化");
            return;
        }
        if (!self.mgr.mAccObj)
        {
            CWLogDebug(@"请先登录");
            return;
        }
        SDK_VIDEO_ROTATE mRotate = [[inArgument objectAtIndex:0] intValue];
        if (mRotate > SDK_VIDEO_ROTATE_270)
            mRotate = SDK_VIDEO_ROTATE_0;
        else if(mRotate == SDK_VIDEO_ROTATE_90)
            mRotate = SDK_VIDEO_ROTATE_270;
        else if(mRotate == SDK_VIDEO_ROTATE_270)
            mRotate = SDK_VIDEO_ROTATE_90;
        
        if (self.mgr.mCallObj && self.mgr.mCallObj.CallMedia == MEDIA_TYPE_VIDEO)
        {
            [self.mgr.mCallObj doRotateRemoteVideo:mRotate];
        }
        else if(!self.mgr.mCallObj)
        {
            CWLogDebug(@"请先呼叫");
            return;
        }
    }
}

//小窗口为本地
-(void)createVideoView
{
    //只修改尺寸，不重新创建
//    NSInteger netFrameWidth = [[NSUserDefaults standardUserDefaults]integerForKey:@"VIDEO_CAPTURE_NET_FRAME_WIDTH"];
//    NSInteger netFrameHeight = [[NSUserDefaults standardUserDefaults]integerForKey:@"VIDEO_CAPTURE_NET_FRAME_HEIGHT"];
//    double rate = (double)netFrameHeight/(double)self.mgr.height;//以长边为基准设置全屏，保持分辨率宽高比
//    NSInteger width = netFrameWidth/rate;
    self.mgr.dapiview.frame = CGRectMake(self.mgr.x, self.mgr.y, self.mgr.width, self.mgr.height);
    
    //对端画面
    self.mgr.remoteVideoView.frame = CGRectMake(self.mgr.x1, self.mgr.y1, self.mgr.width1, self.mgr.height1);
    //本地画面
    self.mgr.localVideoView.frame = self.mgr.dapiview.bounds;
    self.mgr.localVideoView.backgroundColor = [UIColor blackColor];
    self.mgr.localVideoView.center = CGPointMake(self.mgr.dapiview.bounds.size.width/2, self.mgr.dapiview.bounds.size.height/2);
    [EUtility brwView:meBrwView bringSubviewToFront:self.mgr.dapiview];
    
    [self.mgr.mCallObj doChangeView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6*NSEC_PER_SEC)),dispatch_get_main_queue(),^
                   {
                       [self.mgr.mCallObj doSetCallVideoWindow:self.mgr.remoteVideoView localVideoWindow:self.mgr.localVideoView];
                   });
}

//小窗口为远端
-(void)createVideoViewSwitch
{
    //只修改尺寸，不重新创建
//    NSInteger netFrameWidth = [[NSUserDefaults standardUserDefaults]integerForKey:@"VIDEO_CAPTURE_NET_FRAME_WIDTH"];
//    NSInteger netFrameHeight = [[NSUserDefaults standardUserDefaults]integerForKey:@"VIDEO_CAPTURE_NET_FRAME_HEIGHT"];
//    double rate1 = (double)netFrameHeight/(double)self.mgr.height1;//以长边为基准设置全屏，保持分辨率宽高比
//    NSInteger width1 = netFrameWidth/rate1;
    self.mgr.dapiview.frame = CGRectMake(self.mgr.x1, self.mgr.y1, self.mgr.width1, self.mgr.height1);
    
    //本地画面
    self.mgr.localVideoView.frame = self.mgr.dapiview.bounds;
    self.mgr.localVideoView.backgroundColor = [UIColor clearColor];
    self.mgr.localVideoView.center = CGPointMake(self.mgr.dapiview.bounds.size.width/2, self.mgr.dapiview.bounds.size.height/2);
    //对端画面
//    double rate = (double)netFrameHeight/(double)self.mgr.height;//以长边为基准设置全屏，保持分辨率宽高比
//    NSInteger width = netFrameWidth/rate;
    self.mgr.remoteVideoView.frame = CGRectMake(self.mgr.x, self.mgr.y, self.mgr.width, self.mgr.height);
    [EUtility brwView:meBrwView bringSubviewToFront:self.mgr.remoteVideoView];
    
    [self.mgr.mCallObj doChangeView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6*NSEC_PER_SEC)),dispatch_get_main_queue(),^
                   {
                       [self.mgr.mCallObj doSetCallVideoWindow:self.mgr.remoteVideoView localVideoWindow:self.mgr.localVideoView];
                   });
}

-(void)switchView:(NSMutableArray*)inArgument
{
    if(!self.mgr.mSDKObj)
    {
        CWLogDebug(@"请先初始化");
        return;
    }
    if (!self.mgr.mAccObj)
    {
        CWLogDebug(@"请先登录");
        return;
    }
    if (self.mgr.mCallObj && self.mgr.mCallObj.CallMedia == MEDIA_TYPE_VIDEO)
    {
        if(self.mgr.isViewSwitch)
        {
            self.mgr.isViewSwitch = NO;
            [self createVideoView];//小窗口为本地
        }
        else
        {
            self.mgr.isViewSwitch = YES;
            [self createVideoViewSwitch];//小窗口为远端
        }
    }
    else if(!self.mgr.mCallObj)
    {
        CWLogDebug(@"请先呼叫");
        return;
    }
}

-(void)hideLocalView:(NSMutableArray*)inArgument
{
    if ([inArgument isKindOfClass:[NSMutableArray class]] && [inArgument count] == 1)
    {
        if(!self.mgr.mSDKObj)
        {
            CWLogDebug(@"请先初始化");
            return;
        }
        if (!self.mgr.mAccObj)
        {
            CWLogDebug(@"请先登录");
            return;
        }
        NSString* flag = [inArgument objectAtIndex:0];
        int hide = 1;
        if ([flag isEqualToString:@"show"])
            hide = 0;
        else
            hide = 1;
        
        if (self.mgr.mCallObj && self.mgr.mCallObj.CallMedia == MEDIA_TYPE_VIDEO)
        {
            [self.mgr.mCallObj doHideLocalVideo:(SDK_HIDE_LOCAL_VIDEO)hide];
            [self.mgr.dapiview setHidden:hide];
        }
        else if(!self.mgr.mCallObj)
        {
            CWLogDebug(@"请先呼叫");
            return;
        }
    }
}

- (void)showLocalView
{
    DAPIPView* dvItem = [[DAPIPView alloc] init:CGRectMake(self.mgr.x, self.mgr.y, self.mgr.width, self.mgr.height)];
    self.mgr.dapiview = dvItem;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.mgr.dapiview.borderInsets = UIEdgeInsetsMake(1.0f,       // top
                                                          1.0f,       // left
                                                          1.0f,      // bottom
                                                          1.0f);      // right
    }
    else
    {
        self.mgr.dapiview.borderInsets = UIEdgeInsetsMake(1.0f,       // top
                                                          1.0f,       // left
                                                          1.0f,       // bottom
                                                          1.0f);      // right
    }
    
    //本地窗口;
    self.mgr.localVideoView = [[UIView alloc]initWithFrame:self.mgr.dapiview.bounds];
    self.mgr.localVideoView.backgroundColor = [UIColor whiteColor];
    self.mgr.localVideoView.center = CGPointMake(self.mgr.dapiview.bounds.size.width/2, self.mgr.dapiview.bounds.size.height/2);
    [self.mgr.dapiview addSubview:self.mgr.localVideoView];
    [EUtility brwView: meBrwView  addSubview:self.mgr.dapiview];
    
    [dvItem release];
}

- (void)showRemoteView
{
    //远端窗口
    self.mgr.remoteVideoView = initIOSDisplay(CGRectMake(self.mgr.x1,self.mgr.y1, self.mgr.width1, self.mgr.height1));//[[IOSDisplay alloc]initWithFrame:CGRectMake(self.mgr.x1,self.mgr.y1, self.mgr.width1, self.mgr.height1)];
    self.mgr.remoteVideoView.backgroundColor = [UIColor whiteColor];
    [EUtility brwView:meBrwView  addSubview:self.mgr.remoteVideoView];

}

#if (SDK_HAS_GROUP>0)
-(void)groupCreate:(NSMutableArray*)inArgument
{
    if (self.mgr.mCallObj)
    {
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNCALL" waitUntilDone:NO];
        return;
    }
    
    if(!self.mgr.mSDKObj)
    {
        CWLogDebug(@"请先初始化");
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNREGISTER" waitUntilDone:NO];
        return;
    }
    if (!self.mgr.mAccObj)
    {
        CWLogDebug(@"请先登录");
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNREGISTER" waitUntilDone:NO];
        return;
    }
    
    NSString* remoteUri2 = nil;
    if([[inArgument[0] JSONValue] objectForKey:@"members"] && ![[[inArgument[0] JSONValue] objectForKey:@"members"] isEqualToString:@""])
        remoteUri2 = [NSString stringWithFormat:@"%@,%@",self.mgr.userID,[[inArgument[0] JSONValue] objectForKey:@"members"]];//账号之间用逗号隔开
    else
    {
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
        return;
    }
    SDK_GROUP_TYPE grpType = (SDK_GROUP_TYPE)[[[inArgument[0] JSONValue] objectForKey:@"groupType"]  intValue];
    NSString* groupname = [[inArgument[0] JSONValue] objectForKey:@"groupName"];
    NSString* password = [[inArgument[0] JSONValue] objectForKey:@"passWord"];
    if(!groupname || [groupname isEqualToString:@""] || !password || [password isEqualToString:@""])
    {
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
        return;
    }
    int max = [[[inArgument[0] JSONValue] objectForKey:@"max"]  intValue];
    if(max == 0)
        max = 16;
    int screenSplit = [[[inArgument[0] JSONValue] objectForKey:@"screenSplit"]  intValue];
    int lv = [[[inArgument[0] JSONValue] objectForKey:@"lv" ]  intValue];
    
    if (grpType == SDK_GROUP_CHAT_VIDEO || grpType == SDK_GROUP_SPEAK_VIDEO || grpType == SDK_GROUP_TWOVOICE_VIDEO)
    {
        [self showRemoteView];
    }
    else if (grpType == SDK_GROUP_MICROLIVE_VIDEO)
    {
        [self showLocalView];
    }
    
    self.mgr.isGroup = 1;
    int ret = EC_START_IDX;
    if (!self.mgr.mCallObj)
    {
        self.mgr.mCallObj = [[CallObj alloc]init];
        [self.mgr.mCallObj setDelegate:self.mgr];
        [self.mgr.mCallObj bindAcc:self.mgr.mAccObj];
        
        NSArray* remoteAccArr = [remoteUri2 componentsSeparatedByString:@","];
        NSUInteger countMem=[remoteAccArr count];
        NSMutableArray* remoteTypeArr = [NSMutableArray arrayWithObjects:
                                         [NSNumber numberWithInt:self.mgr.accType],
                                         nil];
        for(int i = 1; i<countMem; i++)
        {
            [remoteTypeArr addObject:[NSNumber numberWithInt:self.mgr.remoteAccType]];
        }
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             remoteTypeArr,KEY_CALL_REMOTE_ACC_TYPE,
                             [NSNumber numberWithInt:grpType],KEY_GRP_TYPE,
                             groupname,KEY_GRP_NAME,
                             remoteUri2,KEY_GRP_INVITEELIST,
                             password,KEY_GRP_PASSWORD,
                             [NSNumber numberWithInt:1],KEY_GRP_CODEC,//codec格式必须与setVideoCodec设置格式一致
                             [NSNumber numberWithInt:max],KEY_GRP_MAXMEMBER,
                             [NSNumber numberWithInt:screenSplit],KEY_GRP_SCREENSPLIT,
                             [NSNumber numberWithInt:lv],KEY_GRP_LV,
                             nil];
        ret = [self.mgr.mCallObj groupCall:SDK_GROUP_CREATE param:dic];
        
        if (EC_OK > ret)
        {
            if (self.mgr.mCallObj)
            {
                [self.mgr.mCallObj doReleaseCallResource];
                [self.mgr.mCallObj release];
                self.mgr.mCallObj = nil;
            }
            if(self.mgr.localVideoView)
            {
                [self.mgr.localVideoView removeFromSuperview];
                [self.mgr.localVideoView release];
                self.mgr.localVideoView = nil;
            }
            if(self.mgr.remoteVideoView)
            {
                [self.mgr.remoteVideoView removeFromSuperview];
                [self.mgr.remoteVideoView release];
                self.mgr.remoteVideoView = nil;
            }
            if(self.mgr.dapiview)
            {
                [self.mgr.dapiview removeFromSuperview];
                [self.mgr.dapiview release];
                self.mgr.dapiview = nil;
            }
            
            CWLogDebug(@"创建会议失败:%@",[SdkObj ECodeToStr:ret]);
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
            return;
        }
        //[self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"OK:CALLING" waitUntilDone:NO];
        [self.mgr.mCallObj doSwitchAudioDevice:SDK_AUDIO_OUTPUT_DEFAULT];
    }
    
    return;
}

-(void)groupMember:(NSMutableArray*)inArgument
{
    if(!self.mgr.mSDKObj)
    {
        CWLogDebug(@"请先初始化");
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNREGISTER" waitUntilDone:NO];
        return;
    }
    if (!self.mgr.mAccObj)
    {
        CWLogDebug(@"请先登录");
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNREGISTER" waitUntilDone:NO];
        return;
    }
    
    int ret = EC_START_IDX;
    if (self.mgr.mCallObj)
    {
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInt:self.mgr.isGroupCreator],KEY_GRP_ISCREATOR,
                             self.mgr.callID,KEY_GRP_CALLID,
                             nil];
        
        ret = [self.mgr.mCallObj groupCall:SDK_GROUP_GETMEMLIST param:dic];
        if (EC_OK > ret)
        {
            CWLogDebug(@"多人操作失败:%@",[SdkObj ECodeToStr:ret]);
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
            return;
        }
    }
    else// if(!self.mgr.mCallObj)
    {
        CWLogDebug(@"请先呼叫");
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNCALL" waitUntilDone:NO];
        return;
    }
    
    return;
}

-(void)groupInvite:(NSMutableArray*)inArgument
{
    if(!self.mgr.mSDKObj)
    {
        CWLogDebug(@"请先初始化");
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNREGISTER" waitUntilDone:NO];
        return;
    }
    if (!self.mgr.mAccObj)
    {
        CWLogDebug(@"请先登录");
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNREGISTER" waitUntilDone:NO];
        return;
    }
    
    NSString* memberList = [inArgument objectAtIndex:0];//账号之间用逗号隔开
    if(!memberList || [memberList isEqualToString:@""])
    {
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
        return;
    }
    
    int ret = EC_START_IDX;
    if (self.mgr.mCallObj)
    {
        NSArray* remoteAccArr = [memberList componentsSeparatedByString:@","];
        NSUInteger countMem=[remoteAccArr count];
        NSMutableArray* remoteTypeArr = [NSMutableArray arrayWithObjects:
                                         nil];
        for(int i = 0; i<countMem; i++)
        {
            [remoteTypeArr addObject:[NSNumber numberWithInt:self.mgr.accType]];
        }
        
        int mode=SDK_GROUP_AUDIO_SENDRECV;//语音群聊
        if(self.mgr.grpType == 21 || self.mgr.grpType == 22 || self.mgr.grpType == 29)//视频对讲或两方或直播
            mode = SDK_GROUP_AUDIO_RECVONLY_VIDEO_RECVONLY;
        else if(self.mgr.grpType == 1 || self.mgr.grpType == 2 || self.mgr.grpType == 9)//语音对讲或两方或直播
            mode = SDK_GROUP_AUDIO_RECVONLY;
        else if(self.mgr.grpType == 20 )//视频群聊
            mode = -1;
        
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             remoteTypeArr,KEY_CALL_REMOTE_ACC_TYPE,
                             self.mgr.callID,KEY_GRP_CALLID,
                             [NSNumber numberWithInt:self.mgr.isGroupCreator],KEY_GRP_ISCREATOR,
                             memberList,KEY_GRP_INVITEDMBLIST,
                             [NSNumber numberWithInt:mode],KEY_GRP_MODE,
                             nil];
        
        ret = [self.mgr.mCallObj groupCall:SDK_GROUP_INVITEMEMLIST param:dic];
        if (EC_OK > ret)
        {
            CWLogDebug(@"多人操作失败:%@",[SdkObj ECodeToStr:ret]);
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
            return;
        }
    }
    else// if(!self.mgr.mCallObj)
    {
        CWLogDebug(@"请先呼叫");
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNCALL" waitUntilDone:NO];
        return;
    }
    
    return;
}

- (void)groupList:(NSMutableArray*)inArgument
{
    if(!self.mgr.mSDKObj)
    {
        CWLogDebug(@"请先初始化");
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNREGISTER" waitUntilDone:NO];
        return;
    }
    if (!self.mgr.mAccObj)
    {
        CWLogDebug(@"请先登录");
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNREGISTER" waitUntilDone:NO];
        return;
    }
    int ret = [self.mgr.mAccObj getGroupList];
    
    return;
}

-(void)groupJoin:(NSMutableArray*)inArgument
{
    if (self.mgr.mCallObj)
    {
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNCALL" waitUntilDone:NO];
        return;
    }
    
    if(!self.mgr.mSDKObj)
    {
        CWLogDebug(@"请先初始化");
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNREGISTER" waitUntilDone:NO];
        return;
    }
    if (!self.mgr.mAccObj)
    {
        CWLogDebug(@"请先登录");
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNREGISTER" waitUntilDone:NO];
        return;
    }
    
    NSString* joinID = [inArgument objectAtIndex:0];//此处填入callID
    NSString* password = [inArgument objectAtIndex:1];
    if(!joinID || [joinID isEqualToString:@""] || !password || [password isEqualToString:@""])
    {
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
        return;
    }
    
    self.mgr.isGroup = 2;
    int ret = EC_START_IDX;
    if (!self.mgr.mCallObj)
    {
        self.mgr.mCallObj = [[CallObj alloc]init];
        [self.mgr.mCallObj setDelegate:self.mgr];
        [self.mgr.mCallObj bindAcc:self.mgr.mAccObj];
        
        int mode=SDK_GROUP_AUDIO_SENDRECV;//语音群聊
        if(self.mgr.grpType == 21 || self.mgr.grpType == 22 || self.mgr.grpType == 29)//视频对讲或两方或直播
            mode = SDK_GROUP_AUDIO_RECVONLY_VIDEO_RECVONLY;
        else if(self.mgr.grpType == 1 || self.mgr.grpType == 2 || self.mgr.grpType == 9)//语音对讲或两方或直播
            mode = SDK_GROUP_AUDIO_RECVONLY;
        else if(self.mgr.grpType == 20 )//视频群聊
            mode = -1;
        
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInt:1],KEY_GRP_JOINONLY,
                             joinID,KEY_GRP_CALLID,
                             [NSNumber numberWithInt:mode],KEY_GRP_MODE,
                             password,KEY_GRP_PASSWORD,
                             nil];
        
        ret = [self.mgr.mCallObj groupCall:SDK_GROUP_JOIN param:dic];
        if (EC_OK > ret)
        {
            if (self.mgr.mCallObj)
            {
                [self.mgr.mCallObj doReleaseCallResource];
                [self.mgr.mCallObj release];
                self.mgr.mCallObj = nil;
            }
            if(self.mgr.localVideoView)
            {
                [self.mgr.localVideoView removeFromSuperview];
                [self.mgr.localVideoView release];
                self.mgr.localVideoView = nil;
            }
            if(self.mgr.remoteVideoView)
            {
                [self.mgr.remoteVideoView removeFromSuperview];
                [self.mgr.remoteVideoView release];
                self.mgr.remoteVideoView = nil;
            }
            if(self.mgr.dapiview)
            {
                [self.mgr.dapiview removeFromSuperview];
                [self.mgr.dapiview release];
                self.mgr.dapiview = nil;
            }
            
            CWLogDebug(@"加入会议失败:%@",[SdkObj ECodeToStr:ret]);
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
            return;
        }
        [self.mgr.mCallObj doSwitchAudioDevice:SDK_AUDIO_OUTPUT_DEFAULT];
    }
    
    return;
}

-(void)groupKick:(NSMutableArray*)inArgument
{
    if(!self.mgr.mSDKObj)
    {
        CWLogDebug(@"请先初始化");
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNREGISTER" waitUntilDone:NO];
        return;
    }
    if (!self.mgr.mAccObj)
    {
        CWLogDebug(@"请先登录");
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNREGISTER" waitUntilDone:NO];
        return;
    }
    
    NSString* memberList = [inArgument objectAtIndex:0];//账号之间用逗号隔开
    if(!memberList || [memberList isEqualToString:@""])
    {
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
        return;
    }
    
    int ret = EC_START_IDX;
    if (self.mgr.mCallObj)
    {
        NSArray* remoteAccArr = [memberList componentsSeparatedByString:@","];
        NSUInteger countMem=[remoteAccArr count];
        NSMutableArray* remoteTypeArr = [NSMutableArray arrayWithObjects:
                                         nil];
        for(int i = 0; i<countMem; i++)
        {
            [remoteTypeArr addObject:[NSNumber numberWithInt:self.mgr.accType]];
        }
        
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             remoteTypeArr,KEY_CALL_REMOTE_ACC_TYPE,
                             [NSNumber numberWithInt:self.mgr.isGroupCreator],KEY_GRP_ISCREATOR,
                             self.mgr.callID,KEY_GRP_CALLID,
                             memberList,KEY_GRP_KICKEDMBLIST,
                             nil];
        
        ret = [self.mgr.mCallObj groupCall:SDK_GROUP_KICKMEMLIST param:dic];
        if (EC_OK > ret)
        {
            CWLogDebug(@"多人操作失败:%@",[SdkObj ECodeToStr:ret]);
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
            return;
        }
    }
    else// if(!self.mgr.mCallObj)
    {
        CWLogDebug(@"请先呼叫");
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNCALL" waitUntilDone:NO];
        return;
    }
    
    return;
}

-(void)groupClose:(NSMutableArray*)inArgument
{
    if(!self.mgr.mSDKObj)
    {
        CWLogDebug(@"请先初始化");
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNREGISTER" waitUntilDone:NO];
        return;
    }
    if (!self.mgr.mAccObj)
    {
        CWLogDebug(@"请先登录");
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNREGISTER" waitUntilDone:NO];
        return;
    }
    
    int ret = EC_START_IDX;
    if (self.mgr.mCallObj)
    {
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.mgr.callID,KEY_GRP_CALLID,
                             nil];
        
        ret = [self.mgr.mCallObj groupCall:SDK_GROUP_CLOSE param:dic];
        if (EC_OK > ret)
        {
            CWLogDebug(@"多人操作失败:%@",[SdkObj ECodeToStr:ret]);
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
            return;
        }
    }
    else// if(!self.mgr.mCallObj)
    {
        CWLogDebug(@"请先呼叫");
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNCALL" waitUntilDone:NO];
        return;
    }
    
    return;
}

-(void)groupMic:(NSMutableArray*)inArgument
{
    if(!self.mgr.mSDKObj)
    {
        CWLogDebug(@"请先初始化");
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNREGISTER" waitUntilDone:NO];
        return;
    }
    if (!self.mgr.mAccObj)
    {
        CWLogDebug(@"请先登录");
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNREGISTER" waitUntilDone:NO];
        return;
    }
    
    NSString* member = [inArgument objectAtIndex:0];//账号之间用逗号隔开
    if(!member || [member isEqualToString:@""])
    {
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
        return;
    }
    SDK_GROUP_MICMANAGEMENT mode1 = (SDK_GROUP_MICMANAGEMENT)[[inArgument objectAtIndex:1] intValue];
    SDK_GROUP_MICMANAGEMENT mode2 = (SDK_GROUP_MICMANAGEMENT)[[inArgument objectAtIndex:2] intValue];
    
    int ret = EC_START_IDX;
    if (self.mgr.mCallObj)
    {
        NSArray* remoteAccArr = [member componentsSeparatedByString:@","];
        NSUInteger countMem=[remoteAccArr count];
        NSMutableArray* mbOperationList =  [NSMutableArray arrayWithObjects:
                                            nil];
        NSMutableArray* remoteTypeArr = [NSMutableArray arrayWithObjects:
                                         nil];
        for(int i = 0; i<countMem; i++)
        {
            NSDictionary* operationdic = [NSDictionary dictionaryWithObjectsAndKeys:
                                          remoteAccArr[i],KEY_GRP_MEMBER,
                                          [NSNumber numberWithInt:mode1],KEY_GRP_UPOPERATIONTYPE,
                                          [NSNumber numberWithInt:mode2],KEY_GRP_DWOPERATIONTYPE,
                                          nil];
            [mbOperationList addObject:operationdic];
            [remoteTypeArr addObject:[NSNumber numberWithInt:self.mgr.remoteAccType]];
        }
        
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             remoteTypeArr,KEY_CALL_REMOTE_ACC_TYPE,
                             [NSNumber numberWithInt:self.mgr.isGroupCreator],KEY_GRP_ISCREATOR,
                             self.mgr.callID,KEY_GRP_CALLID,
                             mbOperationList,KEY_GRP_MBOPERATIONLIST,
                             nil];
        
        ret = [self.mgr.mCallObj groupCall:SDK_GROUP_MIC param:dic];
        if (EC_OK > ret)
        {
            CWLogDebug(@"多人操作失败:%@",[SdkObj ECodeToStr:ret]);
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
            return;
        }
    }
    else// if(!self.mgr.mCallObj)
    {
        CWLogDebug(@"请先呼叫");
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNCALL" waitUntilDone:NO];
        return;
    }
    
    return;
}

-(void)groupVideo:(NSMutableArray*)inArgument
{
    if(!self.mgr.mSDKObj)
    {
        CWLogDebug(@"请先初始化");
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNREGISTER" waitUntilDone:NO];
        return;
    }
    if (!self.mgr.mAccObj)
    {
        CWLogDebug(@"请先登录");
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNREGISTER" waitUntilDone:NO];
        return;
    }
    
    int screenSplit = [[[inArgument[0] JSONValue] objectForKey:@"screenSplit"] intValue];
    int lv = [[[inArgument[0] JSONValue] objectForKey:@"lv"] intValue];
    int mode = [[[inArgument[0] JSONValue] objectForKey:@"mode"] intValue];
    NSString* memberToSet = [[inArgument[0] JSONValue] objectForKey:@"memberToSet"];
    NSString* memberToShow = [[inArgument[0] JSONValue] objectForKey:@"memberToShow"];
    
    int ret = EC_START_IDX;
    if (self.mgr.mCallObj)
    {
        NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    self.mgr.callID,KEY_GRP_CALLID,
                                    [NSNumber numberWithInt:lv],KEY_GRP_LV,//70063only
                                    [NSNumber numberWithInt:screenSplit],KEY_GRP_SCREENSPLIT,//70063only
                                    nil];
        
        if(mode > 0 && mode <3)
        {
            if(mode == 1)//替代
            {
                [dic setObject:[NSNumber numberWithInt:4] forKey:KEY_GRP_MBSETSTYLE];
                if(![memberToSet isEqualToString:@""])
                    [dic setObject:[NSString stringWithFormat:@"10-%@",memberToSet] forKey:KEY_GRP_MBTOSET];
                if(![memberToShow isEqualToString:@""])
                    [dic setObject:[NSString stringWithFormat:@"10-%@",memberToShow] forKey:KEY_GRP_MBTOSHOW];
            }
            else if(mode == 2)//最大
            {
                [dic setObject:[NSNumber numberWithInt:100] forKey:KEY_GRP_MBSETSTYLE];
                if(![memberToSet isEqualToString:@""])
                    [dic setObject:[NSString stringWithFormat:@"10-%@",memberToSet] forKey:KEY_GRP_MBTOSET];
            }
        }
        
        ret = [self.mgr.mCallObj groupCall:SDK_GROUP_VIDEO param:dic];
        if (EC_OK > ret)
        {
            CWLogDebug(@"多人操作失败:%@",[SdkObj ECodeToStr:ret]);
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
            return;
        }
    }
    else// if(!self.mgr.mCallObj)
    {
        CWLogDebug(@"请先呼叫");
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNCALL" waitUntilDone:NO];
        return;
    }
    
    return;
}

-(void)onRecvEvent:(NSNotification *)notification
{
    if (nil == notification)
    {
        return;
    }
    if (nil == [notification userInfo])
    {
        return;
    }
    NSDictionary *data=[notification userInfo];
    int msgid = [[data objectForKey:@"msgid"]intValue];
    
    if (4014 == msgid)//多人创建者自动接听
    {
        [self.mgr.mCallObj performSelector:@selector(doAcceptCall:) withObject:[NSNumber numberWithInt:AUDIO_VIDEO] afterDelay:0.1];
        return;
    }
}
#endif

@end
