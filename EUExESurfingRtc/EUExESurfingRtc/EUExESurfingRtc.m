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

#define APP_USER_AGENT      @"RTC_AppCan"

@implementation EUExESurfingRtc

@synthesize mgr;

//每次open一个新窗口触发插件接口时，会进入一次此函数
- (id)initWithBrwView:(EBrowserView *)eInBrwView
{
    self = [super initWithBrwView:eInBrwView];
    if (self) {
        self.mgr=[MySingletonRTC sharedInstance];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRecvEvent:) name:@"NOTIFY_EVENT" object:nil];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(ShowViewNotification:)
//                                                     name:@"ShowViewNotification"
//                                                   object:nil];
        
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AcceptNotification:) name:@"ACCEPTED_EVENT" object:nil];
    }
    return self;
}

//-(void)AcceptNotification:(NSNotification *)notification
//{
//    if (self.mgr.callTypes==AUDIO_VIDEO || self.mgr.callTypes==AUDIO_VIDEO_RECV || self.mgr.callTypes==AUDIO_VIDEO_SEND)
//    {
////        [self showRemoteView];
////        [self showLocalView];
//        [self.mgr.dapiview setHidden:NO];
//        [self.mgr.localVideoView setHidden:NO];
//        [self.mgr.remoteVideoView setHidden:NO];
//    }
//}

-(void)cbLogStatus:(NSString*)senser{
    //[self jsSuccessWithName:@"uexESurfingRtc.cbLogStatus" opId:0 dataType:0 strData:senser];
    
    NSString* jsString = [NSString stringWithFormat:@"uexESurfingRtc.cbLogStatus(\"0\",\"0\",\'%@\');",senser];
    dispatch_async(self.mgr.callBackDispatchQueue, ^(void){
        [EUtility evaluatingJavaScriptInRootWnd:jsString];
    });
}

-(void)onGlobalStatus:(NSString*)senser{
    
    NSString* jsString = [NSString stringWithFormat:@"uexESurfingRtc.onGlobalStatus(\"0\",\"0\",\'%@\');",senser];
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
        NSLog(@"inArgument---->>>%@",inArgument);
        
        self.mgr.appkey =[inArgument objectAtIndex:0];
        self.mgr.appid = [inArgument objectAtIndex:1];
        
        if ([self.mgr.appkey intValue]>0||[self.mgr.appid intValue]>0)
        {
            [self jsSuccessWithName:@"uexESurfingRtc.cbSetAppKeyAndAppId" opId:0 dataType:0 strData:@"OK"];

        }else{
            [self jsSuccessWithName:@"uexESurfingRtc.cbSetAppKeyAndAppId" opId:0 dataType:0 strData:@"ERROR:PARM_ERROR"];
        }
    }
}

//登录接口
-(void)login:(NSMutableArray*)inArgument
{    
    if ([inArgument isKindOfClass:[NSMutableArray class]] && [inArgument count] == 2)
    {
        NSLog(@"login-----appid----->>>%d...appkey____--->>>>%d",[self.mgr.appid intValue],[self.mgr.appkey intValue]);
        
        if ([self.mgr.appkey intValue] !=0||[self.mgr.appid intValue]!=0)
        {
            NSString* number = [inArgument objectAtIndex:1];
            NSLog(@"username:---->>>>>%@",number);
            NSString * infoStr = [inArgument objectAtIndex:0];
            
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
            self.mgr.str = number;
            
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
                
                [self.mgr.mSDKObj setVideoAttr:[NSNumber numberWithInt:1]];
                
            }else if (self.mgr.Resolutions ==1) {
                
                [self.mgr.mSDKObj setVideoAttr:[NSNumber numberWithInt:3]];
                
            } else if (self.mgr.Resolutions ==2) {
                
                [self.mgr.mSDKObj setVideoAttr:[NSNumber numberWithInt:5]];
                
            }else{
                
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
        NSString* remoteTerminalType = @"Any";// [paramDict objectForKey:@"remoteterminaltype"];
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
        if(!remoteuserID || !message || [message isEqualToString:@""])
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
            return;
        
        NSString* callinfo = [inArgument objectAtIndex:2];
        if(!callinfo)
            callinfo = @"";
        
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
            NSLog(@"发送信息=======>>>%@",dic);
            int ret = [self.mgr.mCallObj doMakeCall:dic];
            if (EC_OK > ret)
            {
                if (self.mgr.mCallObj)
                {
                    [self.mgr.mCallObj doHangupCall];
                    [self.mgr.mCallObj release];
                    self.mgr.mCallObj = nil;
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
        
        [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"ConnectionListener:onConnected" waitUntilDone:NO];
        if (self.mgr.mCallObj.CallMedia == MEDIA_TYPE_AUDIO)
        {
            
            [self.mgr.mCallObj doAcceptCall:[NSNumber numberWithInt:self.mgr.accepptType]];
            [self.mgr setLog:@"音频已接听"];
            //[mCallObj doSwitchAudioDevice:SDK_AUDIO_OUTPUT_SPEAKER];
        }
        else
        {
            [self showRemoteView];
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
    
    [self performSelectorOnMainThread:@selector(cbCallStatus:) withObject:@"OK:NORMAL" waitUntilDone:NO];
    if (self.mgr.mCallObj)
    {
        [self.mgr.mCallObj doHangupCall];
        [self.mgr.mCallObj release];
        self.mgr.mCallObj = nil;
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
    
    [self callBackMethodSuccess:[NSString stringWithFormat:@"%@",@"/private /var/ mobile/Media /DCIM"]];
    
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
    NSInteger netFrameWidth = [[NSUserDefaults standardUserDefaults]integerForKey:@"VIDEO_CAPTURE_NET_FRAME_WIDTH"];
    NSInteger netFrameHeight = [[NSUserDefaults standardUserDefaults]integerForKey:@"VIDEO_CAPTURE_NET_FRAME_HEIGHT"];
    double rate = (double)netFrameHeight/(double)self.mgr.height;//以长边为基准设置全屏，保持分辨率宽高比
    NSInteger width = netFrameWidth/rate;
    self.mgr.dapiview.frame = CGRectMake(self.mgr.x, self.mgr.y, width, self.mgr.height);
    
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
    NSInteger netFrameWidth = [[NSUserDefaults standardUserDefaults]integerForKey:@"VIDEO_CAPTURE_NET_FRAME_WIDTH"];
    NSInteger netFrameHeight = [[NSUserDefaults standardUserDefaults]integerForKey:@"VIDEO_CAPTURE_NET_FRAME_HEIGHT"];
    double rate1 = (double)netFrameHeight/(double)self.mgr.height1;//以长边为基准设置全屏，保持分辨率宽高比
    NSInteger width1 = netFrameWidth/rate1;
    self.mgr.dapiview.frame = CGRectMake(self.mgr.x1, self.mgr.y1, width1, self.mgr.height1);
    
    //本地画面
    self.mgr.localVideoView.frame = self.mgr.dapiview.bounds;
    self.mgr.localVideoView.backgroundColor = [UIColor clearColor];
    self.mgr.localVideoView.center = CGPointMake(self.mgr.dapiview.bounds.size.width/2, self.mgr.dapiview.bounds.size.height/2);
    //对端画面
    double rate = (double)netFrameHeight/(double)self.mgr.height;//以长边为基准设置全屏，保持分辨率宽高比
    NSInteger width = netFrameWidth/rate;
    self.mgr.remoteVideoView.frame = CGRectMake(self.mgr.x, self.mgr.y, width, self.mgr.height);
    [EUtility brwView:meBrwView bringSubviewToFront:self.mgr.remoteVideoView];
    
    [self.mgr.mCallObj doChangeView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6*NSEC_PER_SEC)),dispatch_get_main_queue(),^
                   {
                       [self.mgr.mCallObj doSetCallVideoWindow:self.mgr.remoteVideoView localVideoWindow:self.mgr.localVideoView];
                   });
}

-(void)switchView:(NSDictionary *)paramDict
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
    self.mgr.remoteVideoView = [[IOSDisplay alloc]initWithFrame:CGRectMake(self.mgr.x1,self.mgr.y1, self.mgr.width1, self.mgr.height1)];
    self.mgr.remoteVideoView.backgroundColor = [UIColor whiteColor];
    [EUtility brwView:meBrwView  addSubview:self.mgr.remoteVideoView];

}

@end
