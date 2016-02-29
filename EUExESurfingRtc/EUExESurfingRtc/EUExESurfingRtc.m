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
#define APP_VERSION         @"V2.6.2_B20160205"


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
    }
    return self;
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
    //[dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
//    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
//    [dateFormat setLocale:usLocale];
//    [usLocale release];
    NSString* datestr = [dateFormat stringFromDate:[NSDate date]];
    [dateFormat release];
    
    NSString* strs = [NSString stringWithFormat:@"%@: %@",datestr,senser];
    //[self jsSuccessWithName:@"uexESurfingRtc.onGlobalStatus" opId:0 dataType:0 strData:strs];
    
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

-(void)setAppKeyAndAppId:(NSMutableArray *)inArgument{
    
    if ([inArgument isKindOfClass:[NSMutableArray class]] && [inArgument count] == 2){
        NSLog(@"chen----》》》》%@",inArgument);
        
        self.mgr.appkey =[inArgument objectAtIndex:0];
        
        NSLog(@"appkey------>>>.%@",self.mgr.appkey);
        self.mgr.appid = [inArgument objectAtIndex:1];
        
        if ([self.mgr.appkey intValue]>0||[self.mgr.appid intValue]>0)
        {
            [self jsSuccessWithName:@"uexESurfingRtc.cbSetAppKeyAndAppId" opId:0 dataType:0 strData:@"OK"];

        }else{
            [self jsSuccessWithName:@"uexESurfingRtc.cbSetAppKeyAndAppId" opId:0 dataType:0 strData:@"ERROR:PARM_ERROR"];
        }
    }
}

//登陆接口
-(void)login:(NSMutableArray*)inArgument{
    
    if ([inArgument isKindOfClass:[NSMutableArray class]] && [inArgument count] == 2)
    {
        NSLog(@"login-----appid----->>>%d...appkey____--->>>>%d",[self.mgr.appid intValue],[self.mgr.appkey intValue]);
        
        if ([self.mgr.appkey intValue] !=0||[self.mgr.appid intValue]!=0)
        {
            int  number = [[inArgument objectAtIndex:1] intValue];
            NSLog(@"username:---->>>>>%d",number);
            NSString * infoStr = [inArgument objectAtIndex:0];
            
            NSDictionary * dic = [infoStr JSONValue];
            NSLog(@"chen_____>......>>.%@",dic);
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
            self.mgr.str = [NSString stringWithFormat:@"%d",number];
            
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
    [self.mgr.localVideoView removeFromSuperview];
    [self.mgr.remoteVideoView removeFromSuperview];
    [self.mgr.dapiview removeFromSuperview];
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
        
        int str =  [[inArgument objectAtIndex:1] intValue];
        self.mgr.callName = [NSString stringWithFormat:@"%d",str];
        if(!self.mgr.callName || [self.mgr.callName isEqualToString:@""])
            return;
        
        int str2 =  [[inArgument objectAtIndex:2] intValue];
        NSString* callinfo = [NSString stringWithFormat:@"%d",str2];
        if(!callinfo || [callinfo isEqualToString:@""])
            callinfo = @"callinfo";
        
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
        }
//        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
//                                [NSNumber numberWithInt:MSG_NEED_VIDEO],@"msgid",
//                                [NSNumber numberWithInt:0],@"arg",
//                                [NSNumber numberWithBool:YES],@"iscallout",
//                                nil];
//        NSLog(@"发送监听：：》》》》%@",params);
//        [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
        
//        if (MSG_NEED_VIDEO == msgid)//发起呼叫
//        {
        
            if (self.mgr.mCallObj ==nil)
            {
                self.mgr.mCallObj = [[CallObj alloc]init];
                [self.mgr.mCallObj setDelegate:self.mgr];
                [self.mgr.mCallObj bindAcc:self.mgr.mAccObj];
                
                // SDK_CALLTYPE callType = (remoteV != 0)? VIDEO_CALL:AUDIO_CALL;
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
//            return;
//        }
        
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
        
//        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
//                                [NSNumber numberWithInt:MSG_ACCEPT],@"msgid",
//                                [NSNumber numberWithInt:0],@"arg",
//                                nil];
//        
//        NSLog(@"+++++>>>>接听:%@",params);
//        [self.mgr setLog:@"音频接听中......."];
//        [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
        //接听
//        if (MSG_ACCEPT == msgid)//接听
//        {
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
//            return;
//        }
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
    
//    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
//                            [NSNumber numberWithInt:MSG_HANGUP],@"msgid",
//                            [NSNumber numberWithInt:0],@"arg",
//                            nil];
//    [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
//    if (MSG_HANGUP == msgid)//挂断
//    {
        [self performSelectorOnMainThread:@selector(cbCallStatus:) withObject:@"OK:NORMAL" waitUntilDone:NO];
        if (self.mgr.mCallObj)
        {
            [self.mgr.mCallObj doHangupCall];
            [self.mgr.mCallObj release];
            self.mgr.mCallObj = nil;
        }
        
        [self.mgr setLog:@"呼叫已结束"];
        [self.mgr.localVideoView removeFromSuperview];
        [self.mgr.remoteVideoView removeFromSuperview];
        [self.mgr.dapiview removeFromSuperview];
        [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"call hangup" waitUntilDone:NO];
        
//        return;
//    }
}

//扬声器

-(void)loudSpeaker:(NSMutableArray*)inArgument
{
    NSString* flag = [inArgument objectAtIndex:0];
    int arg = 0;
    
    if ([flag isEqualToString:@"true"])
        arg = 1;
   else
       arg = 0;
        
//    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
//                            [NSNumber numberWithInt:MSG_SET_AUDIO_DEVICE],@"msgid",
//                            [NSNumber numberWithInt:arg],@"arg",
//                            nil];
//    [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
//    if (MSG_SET_AUDIO_DEVICE == msgid)//切换音频输出设备(扬声器)
//    {
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
//        return;
//    }
}

//静音mute接口
-(void)mute:(NSMutableArray*)inArgument
{
    NSString* flag = [inArgument objectAtIndex:0];
    int arg = 0;
    
    if ([flag isEqualToString:@"true"])
        arg = 1;
    else
        arg = 0;
    
//    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
//                            [NSNumber numberWithInt:MSG_MUTE],@"msgid",
//                            [NSNumber numberWithInt:arg],@"arg",
//                            nil];
//    [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
    
//    if (MSG_MUTE == msgid)//静音
//    {
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
//        return;
//    }
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
            
            if (self.mgr.Resolutions ==1) {
                
                [self.mgr.mSDKObj setVideoAttr:[NSNumber numberWithInt:3]];
                
            } else if (self.mgr.Resolutions ==2) {
                
                [self.mgr.mSDKObj setVideoAttr:[NSNumber numberWithInt:5]];
                
            }else//if (self.mgr.Resolutions ==0)
            {
                
                [self.mgr.mSDKObj setVideoAttr:[NSNumber numberWithInt:1]];
                
            }
            
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
    
    //获取应用程序沙盒的Documents目录
//    NSBundle* mainBundle = [NSBundle mainBundle];
//    NSDictionary* infoDictionary =  [mainBundle infoDictionary];
//    NSString * bundleName = [infoDictionary objectForKey:@"CFBundleName"];
//    //创建目录下的文件路径；
//    NSString *path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:bundleName ]stringByAppendingPathComponent:@"photo"];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    //进行创建；
//    [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
//    
//    self.mgr.currentTime = [self getCurrentTime];
//    NSLog(@"当前时间:%@",self.mgr.currentTime);
//    
//    NSString *resultPath = [NSString stringWithFormat:@"%@/%@.png",path,self.mgr.currentTime];
//    NSLog(@"当前时间的路径 :%@",resultPath);
    
    [self.mgr.mCallObj doSnapImage];
    
    [self callBackMethodSuccess:[NSString stringWithFormat:@"%@",@"/private /var/ mobile/Media /DCIM"]];
    
    return;
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
        if (nil == self.mgr.mAccObj)
        {
            CWLogDebug(@"请先登录");
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
        [self performSelectorOnMainThread:@selector(cbLogStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
}

//获取当前的时间；
//- (NSString *)getCurrentTime{
//    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//    [formatter setDateFormat:@"yyMMddhhmmss"];
//    NSString *dateTime =[formatter stringFromDate:[NSDate date]];
//    self.mgr.currentTime = dateTime;
//    [formatter release];
//    return self.mgr.currentTime;
//}

-(void)switchCamera:(NSMutableArray*)inArgument
{
    if(!self.mgr.mSDKObj)
    {
        CWLogDebug(@"请先初始化");
        return;
    }
    if (nil == self.mgr.mAccObj)
    {
        CWLogDebug(@"请先登录");
        return;
    }
    NSString* flag = [inArgument objectAtIndex:0];
    int camera;
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

-(void)rotateCamera:(NSMutableArray*)inArgument
{
    if(!self.mgr.mSDKObj)
    {
        CWLogDebug(@"请先初始化");
        return;
    }
    if (nil == self.mgr.mAccObj)
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

//小窗口为本地
-(void)createVideoView
{
    //只修改尺寸，不重新创建
    NSInteger netFrameWidth = [[NSUserDefaults standardUserDefaults]integerForKey:@"VIDEO_CAPTURE_NET_FRAME_WIDTH"];
    NSInteger netFrameHeight = [[NSUserDefaults standardUserDefaults]integerForKey:@"VIDEO_CAPTURE_NET_FRAME_HEIGHT"];
    double rate = (double)netFrameWidth/(double)self.mgr.width;
    NSInteger height = netFrameHeight/rate;
    self.mgr.dapiview.frame = CGRectMake(self.mgr.x, self.mgr.y, self.mgr.width, height);
    
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
    double rate = (double)netFrameWidth/(double)self.mgr.width1;
    NSInteger height = netFrameHeight/rate;
    self.mgr.dapiview.frame = CGRectMake(self.mgr.x1, self.mgr.y1, self.mgr.width1, height);
    
    //本地画面
    self.mgr.localVideoView.frame = self.mgr.dapiview.bounds;
    self.mgr.localVideoView.backgroundColor = [UIColor clearColor];
    self.mgr.localVideoView.center = CGPointMake(self.mgr.dapiview.bounds.size.width/2, self.mgr.dapiview.bounds.size.height/2);
    //对端画面
    self.mgr.remoteVideoView.frame = CGRectMake(self.mgr.x, self.mgr.y, self.mgr.width, self.mgr.height);
    [EUtility brwView:meBrwView bringSubviewToFront:self.mgr.remoteVideoView];
    
    [self.mgr.mCallObj doChangeView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6*NSEC_PER_SEC)),dispatch_get_main_queue(),^
                   {
                       [self.mgr.mCallObj doSetCallVideoWindow:self.mgr.remoteVideoView localVideoWindow:self.mgr.localVideoView];
                   });
}

-(void)switchView:(NSDictionary *)paramDict
{
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

//监听
//-(void)onRecvEvent:(NSNotification *)notification
//{
//    if (nil == notification)
//    {
//        return;
//    }
//    if (nil == [notification userInfo])
//    {
//        return;
//    }
//    NSDictionary * data=[notification userInfo];
//    NSLog(@"监听者：》》》》》%@",data);
//    int msgid = [[data objectForKey:@"msgid"]intValue];
//    NSLog(@"%d",msgid);
//    int arg = [[data objectForKey:@"arg"]intValue];
//    
//}

//- (void) ShowViewNotification:(NSNotification *) notification
//{
//    [self showLocalView];
//    [self showRemoteView];
//}

@end
