//
//  MySingletonRTC.m
//  DEMO
//
//  Created by cc on 15/11/4.
//  Copyright © 2015年 hexc. All rights reserved.
//
#import <UserNotifications/UserNotifications.h>
#import "MySingletonRTC.h"

@interface MySingletonRTC()
{
    int lastStatus;
}
@end

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

-(NSString*)getAPNsBody:(NSDictionary*)dic
{
    if(dic)
    {
        NSLog(@"aps key: %@",[dic objectForKey:@"key"]);
        if([dic objectForKey:@"key"])
        {
            const char* cacc = [[dic objectForKey:@"key"] UTF8String];
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
            return accNum;
        }
        
        return nil;
    }
    return nil;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    lastStatus = 0;
    //解析APNs通知
    if(launchOptions)
    {
        NSDictionary* notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        [self.pushInfo release];
        self.pushInfo = [self getAPNsBody:notification];
        [self.pushInfo retain];
    }
    
    // 注册APNS
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [self registerUserNotification];
    
    return YES;
}

/** 注册APNS,注:获取DeviceToken不同项目或版本会有所不同，可以参考如下方式注册APNs。 */
- (void)registerUserNotification
{
    // 判读系统版本是否是“iOS 8.0”以上
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ||
        [UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        
        // 定义用户通知类型(Remote.远程 - Badge.标记 Alert.提示 Sound.声音)
        UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        
        // 定义用户通知设置
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        
        // 注册用户通知 - 根据用户通知设置
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else { // iOS8.0 以前远程推送设置方式
        // 定义远程通知类型(Remote.远程 - Badge.标记 Alert.提示 Sound.声音)
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        
        // 注册远程通知 -根据远程通知类型
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
}

/** 已登记用户通知 ,IOS 8.0以上使用*/
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

/** 注册APNs成功*/
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"\n>>>[DeviceToken Success]:%@\n\n", token);
    self.pushToken = token;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSString *error_str = [NSString stringWithFormat: @"%@", error];
    NSLog(@"Failed to get token, error:%@", error_str);
}

/** APP已经接收到“远程”通知(推送) - (App运行在后台/App运行在前台) */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    application.applicationIconBadgeNumber = 0; // 标签
    NSLog(@"\n>>>[Receive RemoteNotification]:%@\n\n", userInfo);
    //解析APNs通知
    [self.pushInfo release];
    self.pushInfo = [self getAPNsBody:userInfo];
    [self.pushInfo retain];
    if(self.pushInfo)
        [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:[NSString stringWithFormat:@"APNs:%@",self.pushInfo] waitUntilDone:NO];
}

/* iOS7.0 以后支持APP后台刷新数据，会回调 performFetchWithCompletionHandler 接口*/
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    completionHandler(UIBackgroundFetchResultNewData);
}

/** APP已经接收到“远程”通知(推送) - 透传推送消息  （滑动通知进入前台）*/
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    application.applicationIconBadgeNumber = 0; // 标签
    NSLog(@"\n>>>[Receive RemoteNotification - Background Fetch]:%@\n\n", userInfo);
    completionHandler(UIBackgroundFetchResultNewData);
    
    if (application.applicationState == UIApplicationStateActive) {
        NSLog(@"active");
        //程序当前正处于前台
    }
    else
    {
        //解析APNs通知
        [self.pushInfo release];
        self.pushInfo = [self getAPNsBody:userInfo];
        [self.pushInfo retain];
        if(self.pushInfo)
            [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:[NSString stringWithFormat:@"APNs:%@",self.pushInfo] waitUntilDone:NO];
    }
}

-(instancetype)init{
    self=[super init];
    if(self){
        self.isRoot = YES;
        self.userID = @"";
        [self.userID retain];
        self.nickName = @"";
        [self.nickName retain];
        self.appkey = nil;
        self.appid = nil;
        self.x = 0;
        self.y = 0;
        self.width = 0;
        self.height = 0;
        self.x1 = 0;
        self.y1 = 0;
        self.width1 = 0;
        self.height1 = 0;
        self.accType = ACCTYPE_APP;
        self.terminalType = TERMINAL_TYPE_PHONE;
        [self.terminalType retain];
        self.remoteAccType = ACCTYPE_APP;
        self.remoteTerminalType = TERMINAL_TYPE_ANY;
        [self.remoteTerminalType retain];
        self.pushInfo = @"";
        [self.pushInfo retain];
        self.pushToken = nil;
        self.mSDKObj = nil;
        self.mAccObj = nil;
        self.isGroup = 0;
        self.isGroupCreator = NO;
        self.callID = @"";
        [self.callID retain];
        self.grpType = SDK_GROUP_CHAT_AUDIO;
        self.isViewSwitch = NO;
        self.mMotionManager = [[CMMotionManager alloc]init];
        self.isGettingToken = NO;
        self.firstCheckNetwork = YES;
        self.callBackDispatchQueue=dispatch_queue_create("gcd.uexESurfingRtcCallBackDispatchQueue",NULL);
        [self checkNetWorkReachability];//检测网络切换
        
        NSString* islog = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"enablelog"];
        self.isAPNs = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"enableAPNs"] boolValue];
        self.notification = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"notification"];
        self.notification2 = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"notificationGrp"];
        self.pushId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"pushid"];
        self.pushKey = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"pushkey"];
        self.pushMasterSecret = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"pushmastersecret"];
        if(!self.notification)
            self.notification = @"callName";
        if(!self.notification2)
            self.notification2 = @"群组来电:grpName";
        if([islog isEqualToString:@"1"])
            initCWDebugLog();
        
        if ([[[UIDevice currentDevice]systemVersion]floatValue]>=10.0)
        {
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            //iOS 10 使用以下方法注册，才能得到授权
            [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert)
                                  completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                      // Enable or disable features based on authorization.
                                  }];
        }
        else if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]&&[[[UIDevice currentDevice]systemVersion]floatValue]>=8.0)
        {
            //注册本地推送
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    
    return self;
}

-(void)cbLogStatus:(NSString*)senser{
    //[self jsSuccessWithName:@"uexESurfingRtc.cbLogStatus" opId:0 dataType:0 strData:senser];
    
    NSString* jsString = [NSString stringWithFormat:@"uexESurfingRtc.cbLogStatus(\"0\",\"0\",\'%@\');",senser];
    dispatch_async(self.callBackDispatchQueue, ^(void){
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

-(void)cbGroupStatus:(NSString*)senser
{
    NSString* jsString = [NSString stringWithFormat:@"uexESurfingRtc.cbGroupStatus(\"0\",\"0\",\'%@\');",senser];
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
    
    [self.mSDKObj setSdkAgent:@"EUExESurfingRtc" terminalType:self.terminalType UDID:[OpenUDIDRTC value] appID:self.appid appKey:self.appkey];
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
        if([self.userID isEqualToString:@"0"]){
            
            [self performSelectorOnMainThread:@selector(cbLogStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
            
            return;
        }else if(!self.mToken)
            [self.mAccObj getToken:self.userID andType:self.accType andGrant:@"100<200<301<302<303<304<400" andAuthType:ACC_AUTH_TO_APPALL];
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
        [self.mAccObj getToken:self.userID andType:self.accType andGrant:@"100<200<301<302<303<304<400" andAuthType:ACC_AUTH_TO_APPALL];
    }
}

- (void)doUnRegister
{
    if (self.mAccObj)
    {
        if(self.isAPNs&&self.pushId&&self.pushKey&&self.pushMasterSecret)
            [self.mAccObj setAPNsToken:self.userID andPushToken:nil andPushId:self.pushId andPushKey:self.pushKey andPushMaster:self.pushMasterSecret];
        [self.mAccObj doUnRegister];
        [self.mAccObj release];
        self.mAccObj = nil;
        self.mToken = nil;
        [self.mAccountID release];
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

-(void)reCallRequest
{
    if(!self.mSDKObj)
    {
        return;
    }
    
    if(self.pushInfo && ![self.pushInfo isEqualToString:@""] && !self.mCallObj)
    {
        /*NSArray* info = [self.pushInfo componentsSeparatedByString:@" "];
        info = [[info objectAtIndex:1] componentsSeparatedByString:@" "];
        NSArray *num = [NSArray arrayWithObjects:[info objectAtIndex:0],nil];
        NSString* numberString = [num componentsJoinedByString:@""];*/
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.pushInfo,KEY_CALLED,
                             [NSNumber numberWithInt:self.remoteAccType],KEY_CALL_REMOTE_ACC_TYPE,
                             self.remoteTerminalType,KEY_CALL_REMOTE_TERMINAL_TYPE,
                             @"reCallRequest",KEY_CALL_INFO,
                             nil];
        [self.mAccObj doSendIM:dic];
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
    if (xy <= 180 && xy > 135)//头朝上,向右侧倾斜
    {
        return 0;
    }
    if (xy <= 135 && xy >= 90)//头朝右,水平方向,逆时针倾斜
    {
        return 90;
    }
    if (xy < 90 && xy >= 45) //头朝右,水平方向,顺时针倾斜
    {
        return 90;
    }
    if (xy < 45 && xy >= 0)//头朝下,向右侧倾斜
    {
        return 180;
    }
    if (xy < 0 && xy >= -45)//头朝下,向左侧倾斜
    {
        return 180;
    }
    if (xy < -45 && xy >= -90)//头朝左,水平方向,逆时针倾斜
    {
        return 270;
    }
    if (xy < -90 && xy >= -135)//头朝左,水平方向,顺时针倾斜
    {
        return 270;
    }
    if (xy < -135 && xy >= -180)//头朝上,向左侧倾斜
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
    self.isGettingToken = NO;
    if([result objectForKey:KEY_CAPABILITYTOKEN])
    {
        self.mToken = [result objectForKey:KEY_CAPABILITYTOKEN];
        [self.mAccountID release];
        self.mAccountID = [result objectForKey:KEY_RTCACCOUNTID];
        [self.mAccountID retain];
        NSMutableDictionary *newResult = [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
        [newResult setObject:self.mToken forKey:KEY_CAPABILITYTOKEN];
        [newResult setObject:self.mAccountID forKey:KEY_RTCACCOUNTID];//形如"账号类型-账号~appid~终端类型@chinartc.com"
        if(self.nickName)
            [newResult setObject:self.nickName forKey:KEY_ACC_NAME];
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
    
    CWLogDebug(@"pushInfo:%@",self.pushInfo);
    [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:[NSString stringWithFormat:@"获取token:%d reason:%@",nRspCode,sReason] waitUntilDone:NO];
    if (nRspCode == 200)
    {
        if(self.isAPNs&&self.pushToken&&self.pushId&&self.pushKey&&self.pushMasterSecret)
            [self.mAccObj setAPNsToken:self.userID andPushToken:self.pushToken andPushId:self.pushId andPushKey:self.pushKey andPushMaster:self.pushMasterSecret];
        else if(!self.isAPNs&&self.pushToken&&self.pushId&&self.pushKey&&self.pushMasterSecret)
            [self.mAccObj setAPNsToken:self.userID andPushToken:nil andPushId:self.pushId andPushKey:self.pushKey andPushMaster:self.pushMasterSecret];
        
        [self setLog:[NSString stringWithFormat:@"登录成功,距下次注册%d秒",nExpire]];
        [self performSelectorOnMainThread:@selector(cbLogStatus:) withObject:@"OK:LOGIN" waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"StateChanged,result=200" waitUntilDone:NO];
        
        if([[[UIDevice currentDevice]systemVersion]floatValue]>=9.0)
        {
            //self.mAccObj.isBackground = NO;
            //CWLogDebug(@"AccObj.isBackground = NO");
            [self reCallRequest];
        }
    }
    else
    {
        [self setLog:[NSString stringWithFormat:@"登录失败:%d:%@",nRspCode,sReason]];
        
        if(self.isAPNs&&self.pushId&&self.pushKey&&self.pushMasterSecret)
            [self.mAccObj setAPNsToken:self.userID andPushToken:nil andPushId:self.pushId andPushKey:self.pushKey andPushMaster:self.pushMasterSecret];
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

-(int)onSetAPNsResponse:(NSDictionary*)result  accObj:(AccObj*)accObj
{
    CWLogDebug(@"result is %@onCall:%@",result,accObj);
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
    {
        [self performSelectorOnMainThread:@selector(cbMessageStatus:) withObject:@"OK:SEND" waitUntilDone:NO];
        if(self.pushInfo)
        {
            [self.pushInfo release];
            self.pushInfo = @"";
            [self.pushInfo retain];
        }
    }
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
        
        if([content isEqualToString:@"reCallRequest"])
        {
            if(self.mCallObj && self.calldic)
            {
                [self.mCallObj doHangupCall];
                [self.mCallObj setDelegate:self];
                [self.mCallObj bindAcc:self.mAccObj];
                
                int ret = [self.mCallObj doMakeCall:self.calldic];
                [self.calldic release];
                self.calldic = nil;
            }
        }
        else
        {
            [self performSelectorOnMainThread:@selector(cbMessageStatus:) withObject:@"OK:RECEIVE" waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:[NSString stringWithFormat:@"onReceiveIm:from:%@,msg:%@",accNum,content] waitUntilDone:NO];
        }
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
    NSString* nickname = [param objectForKey:KEY_ACC_NAME];//昵称
    if(!nickname)
        nickname = @"";
    
    
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
                         nickname,KEY_ACC_NAME,
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
    if ([self isBackground] && [[[UIDevice currentDevice]systemVersion]floatValue]<10.0)
    {
        [self setCallIncomingFlag:YES];
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:callType] forKey:KEY_CALL_TYPE];
        [[NSUserDefaults standardUserDefaults]setObject:uri     forKey:KEY_CALLER];
        
        CWLogDebug(@"self.notification = %@",self.notification);
        NSMutableString *not = [NSMutableString stringWithString:self.notification];
        NSRange range = {0,self.notification.length};
        if([self.notification isEqualToString:@"callInfo"])
            makeNotification(@"接听",[NSString stringWithFormat:@"来电:%@",ci],UILocalNotificationDefaultSoundName,YES);
        else if([self.notification isEqualToString:@"callName"])
            makeNotification(@"接听",[NSString stringWithFormat:@"来电:%@",accNum],UILocalNotificationDefaultSoundName,YES);
        else if([self.notification isEqualToString:@"hideNotification"])
        {
            CWLogDebug(@"hideNotification");
        }
        else if([not rangeOfString:@"callInfo"].length)
        {
            [not replaceOccurrencesOfString:@"callInfo" withString:ci options:NSLiteralSearch range:range];
            makeNotification(@"接听",not,UILocalNotificationDefaultSoundName,YES);
        }
        else if([not rangeOfString:@"callName"].length)
        {
            [not replaceOccurrencesOfString:@"callName" withString:accNum options:NSLiteralSearch range:range];
            makeNotification(@"接听",not,UILocalNotificationDefaultSoundName,YES);
        }
        else if([not rangeOfString:@"nickName"].length)
        {
            [not replaceOccurrencesOfString:@"nickName" withString:nickname options:NSLiteralSearch range:range];
            makeNotification(@"接听",not,UILocalNotificationDefaultSoundName,YES);
        }
        else
            makeNotification(@"接听",not,UILocalNotificationDefaultSoundName,YES);
        
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
        //[self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"ConnectionListener:onConnected" waitUntilDone:NO];
        [self setCallIncomingFlag:NO];
    }
    else  if (type == SDK_CALLBACK_CLOSED)
    {
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
            [self.mCallObj doReleaseCallResource];
            [self.mCallObj release];
            self.mCallObj = nil;
        }
        [self performSelectorOnMainThread:@selector(cbCallStatus:) withObject:@"OK:NORMAL" waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:[NSString stringWithFormat:@"ConnectionListener:onDisconnect,code=200"] waitUntilDone:NO];
        [self setCallIncomingFlag:NO];
    }
    else  if (type == SDK_CALLBACK_FAILED || type == SDK_CALLBACK_CANCELED)
    {
        [self.pushInfo release];
        self.pushInfo = @"";
        [self.pushInfo retain];
        
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
            [self.mCallObj doReleaseCallResource];
            [self.mCallObj release];
            self.mCallObj = nil;
        }
        [self performSelectorOnMainThread:@selector(cbCallStatus:) withObject:@"OK:NORMAL" waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:[NSString stringWithFormat:@"ConnectionListener:onDisconnect,code=%d",code] waitUntilDone:NO];
        
        [self.calldic release];
        self.calldic = nil;
        [self setCallIncomingFlag:NO];
    }
    
    return 0;
}

//呼叫媒体建立事件通知
-(int)onCallMediaCreated:(int)mediaType callObj:(CallObj *)callObj
{
    [self.mCallObj doSwitchAudioDevice:SDK_AUDIO_OUTPUT_DEFAULT];
    [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"ConnectionListener:onConnected" waitUntilDone:NO];
    
    //#if(SDK_HAS_GROUP>0)
    if(self.isGroup != 0 && self.grpType<20)//多人语音
    {
        [self setCallIncomingFlag:NO];
        return 0;
    }
    //#endif
    
    if (mediaType == MEDIA_TYPE_VIDEO)
    {
        int ret = [callObj doSetCallVideoWindow:self.remoteVideoView localVideoWindow:self.localVideoView];
        [self setLog:[NSString stringWithFormat:@"%d",ret]];
        [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"ConnectionListener:onVideo" waitUntilDone:NO];
    }

    [self setMotionStatus:NO];
    [self setCallIncomingFlag:NO];
    self.isViewSwitch = NO;
    
    return 0;
}

//呼叫网络状态事件通知
-(int)onNetworkStatus:(NSString*)desc callObj:(CallObj*)callObj
{
    return 0;
}

-(int)onRecordStatus:(NSDictionary*)result callObj:(CallObj*)callObj
{
    CWLogDebug(@"%s result is %@onCall:%@",__FUNCTION__,result,callObj);
    return 0;
}

-(int)groupMember
{
    if(!self.mSDKObj)
    {
        CWLogDebug(@"请先初始化");
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNREGISTER" waitUntilDone:NO];
        return EC_PARAM_WRONG;
    }
    if (!self.mAccObj)
    {
        CWLogDebug(@"请先登录");
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNREGISTER" waitUntilDone:NO];
        return EC_PARAM_WRONG;
    }
    
    int ret = EC_START_IDX;
    if (self.mCallObj)
    {
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInt:self.isGroupCreator],KEY_GRP_ISCREATOR,
                             self.callID,KEY_GRP_CALLID,
                             nil];
        
        ret = [self.mCallObj groupCall:SDK_GROUP_GETMEMLIST param:dic];
        if (EC_OK > ret)
        {
            CWLogDebug(@"多人操作失败:%@",[SdkObj ECodeToStr:ret]);
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:PARM_ERROR" waitUntilDone:NO];
            return EC_PARAM_WRONG;
        }
    }
    else// if(!self.mgr.mCallObj)
    {
        CWLogDebug(@"请先呼叫");
        [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"ERROR:UNCALL" waitUntilDone:NO];
        return EC_PARAM_WRONG;
    }
    
    return ret;
}

//通知
-(int)onNotifyMessage:(NSDictionary*)result  accObj:(AccObj*)accObj
{
    CWLogDebug(@"%s result is %@onNotify:%@",__FUNCTION__,result,accObj);
    NSString* changeInfo = [result objectForKey:@"ChangedInfo"];//多人会议成员状态变化
    NSString* connection = [result objectForKey:@"CheckConnection"];//多人会议成员异常掉线
    NSArray* gvcList = [result objectForKey:@"gvcList"];//会议列表
    NSString* kickedBy = [result objectForKey:@"kickedBy"];//同一账号不同设备登录被踢出
    NSString* multiLogin = [result objectForKey:@"multiLogin"];//多终端登录
    
    NSString *accID = @"",*accNum = @"";
    NSString *accIDList = @"",*accNumList = @"";
    if(changeInfo)
    {
        //解析result,result形如：
        //{
        //    ChangedInfo =     {
        //        callID = "YmVpamluZy1KVDAwMjA4MjE3MjE0NDYwMDk4NjQzMQ==";
        //        memberlist =         (
        //                              {
        //                                  appAccountID = "10-1111~70038~Phone";
        //                                  memberStatus = 2;
        //                              }
        //                              );
        //    };
        //}
        //操作麦克后结果形如：
        //{
        //    ChangedInfo =     {
        //        callID = YmVpamluZy1KVDAwMjA5MjQ0NTE0NDYwMTQ0OTM3;
        //        memberlist =         (
        //                              {
        //                                  appAccountID = "10-1111~70038~Phone";
        //                                  downAudioState = 0;
        //                                  downVideoState = 0;
        //                                  upAudioState = 0;
        //                                  upVideoState = 0;
        //                              }
        //                              );
        //    };
        //}
        NSArray *memberlist = [[result objectForKey:@"ChangedInfo"] objectForKey:@"memberlist"];
        //解析账号
        NSString *accID = [memberlist[0] objectForKey:KEY_GRP_ACCID];
        const char* cacc = [accID UTF8String];
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
        accID = [[NSString stringWithUTF8String:cacc] substringWithRange:NSMakeRange(strindex1+1, strindex2-strindex1-1)];
        
        int memberstatus = [[memberlist[0] objectForKey:KEY_GRP_MBSTATUS] intValue];
        int da = [[memberlist[0] objectForKey:@"downAudioState"] intValue];
        int dv = [[memberlist[0] objectForKey:@"downVideoState"] intValue];
        int ua = [[memberlist[0] objectForKey:@"upAudioState"] intValue];
        int uv = [[memberlist[0] objectForKey:@"upVideoState"] intValue];
        
        if([memberlist[0] objectForKey:KEY_GRP_MBSTATUS])
        {
            NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 accID,KEY_GRP_ACCID,
                                 [NSNumber numberWithInt:memberstatus],KEY_GRP_MBSTATUS,
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
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:[NSString stringWithFormat:@"statusChangedInfo=%@",mutStr] waitUntilDone:NO];
            
            if(!self.isGroupCreator && [accID isEqualToString:self.userID] && memberstatus == 2)
            {
                [self groupMember];//被叫加入后查询成员列表
            }
        }
        else
        {
            NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 accID,KEY_GRP_ACCID,
                                 [NSNumber numberWithInt:da],@"downAudioState",
                                 [NSNumber numberWithInt:dv],@"downVideoState",
                                 [NSNumber numberWithInt:ua],@"upAudioState",
                                 [NSNumber numberWithInt:uv],@"upVideoState",
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
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:[NSString stringWithFormat:@"micChangedInfo=%@",mutStr] waitUntilDone:NO];
        }
    }
    if(connection)
    {
        //解析result,result形如：
        //{
        //    CheckConnection= {
        //        ConfID = ”100734”;
        //    }
        //}
    }
    if(gvcList)
    {
        //解析result,result形如：
        //{
        //        code = 200;
        //        gvcList =     (
        //        {
        //            callId = "YmVpamluZy1KVDAwMjA2MjA0NDE0NDU1Nzk0MDg0MQ==";
        //            gvcattendingPolicy = 1;
        //            gvcname = test;
        //        }
        //        )；
        //        reason = "\U8bf7\U6c42\U88ab\U6267\U884c";
        //}
        if([gvcList count]>0)
        {
            int first = 1;
            NSMutableString *list = nil;
            NSMutableArray *numarr = [NSMutableArray array];
            NSString *jsonString = nil;
            for(int i = 0; i < [gvcList count]; i++)
            {
                accID = [gvcList[i] objectForKey:KEY_GRP_CALLID];//id
                accNum = [gvcList[i] objectForKey:KEY_GRP_NAME];//name
                NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     accID,@"callid",
                                     accNum,@"name",
                                     nil];
                [numarr setObject:dic atIndexedSubscript:i];
                
//                NSError *parseError = nil;
//                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
//                NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//                NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
//                NSRange range = {0,jsonString.length};
//                [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
//                NSRange range2 = {0,mutStr.length};
//                [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
//                NSRange range3 = {0,mutStr.length};
//                [mutStr replaceOccurrencesOfString:@"\\" withString:@"" options:NSLiteralSearch range:range3];
//                
//                if(first == 1)
//                {
//                    list = mutStr;
//                    first = 0;
//                }
//                else
//                {
//                    list = [NSMutableString stringWithFormat:@"%@,%@",list,mutStr];
//                }
            }
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:numarr
                                                               options:kNilOptions
                                                                 error:nil];
            jsonString = [[NSString alloc] initWithData:jsonData
                                               encoding:NSUTF8StringEncoding];
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:[NSString stringWithFormat:@"OK:groupList,list=%@",jsonString] waitUntilDone:NO];
        }
        else
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"OK:noGroupList" waitUntilDone:NO];
    }
    if(multiLogin)//多终端登录
    {
        [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"StateChanged,result=-1501" waitUntilDone:NO];
    }
    if(kickedBy)//被踢下线
    {
        [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"StateChanged,result=-1500" waitUntilDone:NO];
        
        if(self.isAPNs&&self.pushId&&self.pushKey&&self.pushMasterSecret)
            [self.mAccObj setAPNsToken:self.userID andPushToken:nil andPushId:self.pushId andPushKey:self.pushKey andPushMaster:self.pushMasterSecret];
        
        if (self.mAccObj)
        {
            [self.mAccObj doUnRegister];
            [self.mAccObj release];
            self.mAccObj = nil;
            self.mToken = nil;
            [self.mAccountID release];
            self.mAccountID = nil;
            if(self.mSDKObj)
            {
                [self.mSDKObj release];
                self.mSDKObj = nil;
            }
        }
    }
    
    return EC_OK;
}

-(int)onGroupCreate:(NSDictionary*)param withNewCallObj:(CallObj*)newCallObj accObj:(AccObj*)accObj
{
    CWLogDebug(@"%s result is %@onCall:%@",__FUNCTION__,param,accObj);
    
    if(newCallObj)
    {
        self.mCallObj = newCallObj;
        [self.mCallObj setDelegate:self];
    }
    
    NSString* uri = [param objectForKey:KEY_GRP_CALLID];
    self.isGroupCreator = [[param objectForKey:KEY_GRP_ISCREATOR]intValue];
    self.grpType = [[param objectForKey:KEY_GRP_TYPE]intValue];
    NSString* grpName = [param objectForKey:KEY_GRP_NAME];
    
    if([param objectForKey:KEY_GRP_CALLID]!=nil&&[param objectForKey:KEY_GRP_CALLID]!=[NSNull null])
    {
        [self.callID release];
        self.callID = uri;
        [self.callID retain];
    }
    
    self.isGroup = 1;//1或2
    if (!self.isGroupCreator)
    {
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.callID,@"callid",
                             grpName,@"name",
                             [NSNumber numberWithInt:self.grpType],@"type",
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
        NSString* str = nil;
        if(newCallObj)
        {
            str = [NSString stringWithFormat:@"onNewGroupCall,call=%@", mutStr];
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:str waitUntilDone:NO];
        }
        else
        {
            str = [NSString stringWithFormat:@"rejectIncomingCall,call=%@", mutStr];
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:str waitUntilDone:NO];
            return 0;
        }
        
        if ([self isBackground] && [[[UIDevice currentDevice]systemVersion]floatValue]<10.0)
        {
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:0] forKey:KEY_CALL_TYPE];
            [[NSUserDefaults standardUserDefaults]setObject:uri     forKey:KEY_CALLER];
            [[NSUserDefaults standardUserDefaults]setObject:grpName     forKey:KEY_GRP_NAME];
            CWLogDebug(@"self.notification2 = %@",self.notification2);
            NSMutableString *not = [NSMutableString stringWithString:self.notification2];
            NSRange range = {0,self.notification2.length};
            if([self.notification2 isEqualToString:@"hideNotification"])
            {
                CWLogDebug(@"hideNotification");
            }
            else if([not rangeOfString:@"grpName"].length)
            {
                [not replaceOccurrencesOfString:@"grpName" withString:grpName options:NSLiteralSearch range:range];
                makeNotification(@"接听",not,UILocalNotificationDefaultSoundName,YES);
            }
            else
                makeNotification(@"接听",not,UILocalNotificationDefaultSoundName,YES);
            
            return EC_OK;
        }
    }
    else
    {
        CWLogDebug(@"自动接听");
        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                                [NSNumber numberWithInt:4014],@"msgid",
                                nil];
        [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
    }
    
    return EC_OK;
}

//多人请求回调
-(int)onGroupResponse:(NSDictionary*)result grpObj:(CallObj*)grpObj
{
    CWLogDebug(@"%s result is %@onCall:%@",__FUNCTION__,result,grpObj);
    
    if([result objectForKey:KEY_GRP_CALLID]!=nil&&[result objectForKey:KEY_GRP_CALLID]!=[NSNull null])
    {
        [self.callID release];
        self.callID = [result objectForKey:KEY_GRP_CALLID];
        [self.callID retain];
        CWLogDebug(@"callID in onGroupResponse is %@",self.callID);
    }
    
    //由哪种请求产生的回调，用action区分，result形如：
    int action = [[result objectForKey:@"action"] intValue];
    int code = [[result objectForKey:@"code"] intValue];
    NSString* reason = [result objectForKey:@"reason"];
    //1、发起会话请求：
    //{
    //    action = 101;
    //    callId = "YmVpamluZy1KVDAwMjA3MTkwNzE0NDYwMTQ3NjkxNg==";
    //    code = 0;
    //    mode = "<null>";
    //    reason = "";
    //    requestId = "2015-10-28 14:46:09:009";
    //}
    if(action == 101)
    {
        if( code == 0)
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:[NSString stringWithFormat:@"OK:groupCreate,callid=%@",self.callID] waitUntilDone:NO];
        else
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:[NSString stringWithFormat:@"ERROR:groupCreate,code=%d",code] waitUntilDone:NO];
    }
    //2、获取成员列表请求：
    //{
    //    action = 102;
    //    callId = "YmVpamluZy1KVDAwMjA3MTkxMDE0NDYwMTQ4NTQ1OA==";
    //    code = 0;
    //    memberInfoList =     (
    //                          {
    //                              appAccountID = "10-1111~70038~Phone";
    //                              downAudioState = 1;
    //                              downVideoState = 0;
    //                              duration = 0;
    //                              memberStatus = 2;
    //                              role = 1;
    //                              startTime = 20151028144735;
    //                              upAudioState = 1;
    //                              upVideoState = 0;
    //                          }
    //                          );
    //    reason = success;
    //    requestId = "2015-10-28 14:47:38:038";
    //}
    else if(action == 102)
    {
        NSArray *num = [result objectForKey:@"memberInfoList"];
        NSMutableArray *numarr = [NSMutableArray arrayWithArray:num];
        NSString *accID = nil,*accNum = nil,*list = @"";
        NSString *jsonString = nil;
        if(num)//查询列表触发
        {
            for(int i = 0; i < [num count]; i++)
            {
                accID = [num[i] objectForKey:KEY_GRP_ACCID];//id
                const char* cacc = [accID UTF8String];
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
                accNum = [[NSString stringWithUTF8String:cacc] substringWithRange:NSMakeRange(strindex1+1, strindex2-strindex1-1)];
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
                [dic setObject:accNum forKey:KEY_GRP_ACCID];
                [dic setObject:[num[i] objectForKey:@"downAudioState"] forKey:@"downAudioState"];
                [dic setObject:[num[i] objectForKey:@"downVideoState"] forKey:@"downVideoState"];
                [dic setObject:[num[i] objectForKey:@"duration"] forKey:@"duration"];
                [dic setObject:[num[i] objectForKey:@"memberStatus"] forKey:@"memberStatus"];
                [dic setObject:[num[i] objectForKey:@"role"] forKey:@"role"];
                [dic setObject:[num[i] objectForKey:@"startTime"] forKey:@"startTime"];
                [dic setObject:[num[i] objectForKey:@"upAudioState"] forKey:@"upAudioState"];
                [dic setObject:[num[i] objectForKey:@"upVideoState"] forKey:@"upVideoState"];
                [numarr setObject:dic atIndexedSubscript:i];
                
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:numarr
                                                                   options:kNilOptions
                                                                     error:nil];
                jsonString = [[NSString alloc] initWithData:jsonData
                                                   encoding:NSUTF8StringEncoding];
                
                /*if(![accNum isEqual:self.userID]&&[[num[i] objectForKey:KEY_GRP_MBSTATUS] intValue] == 2)
                {
                    list = [NSString stringWithFormat:@"%@,%@",list,accNum];
                }*/
            }
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:[NSString stringWithFormat:@"OK:groupMember,list=%@",jsonString] waitUntilDone:NO];
        }
        else
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:[NSString stringWithFormat:@"ERROR:groupMember,code=%d",code] waitUntilDone:NO];
    }
    //3、邀请成员请求：
    //{
    //    action = 103;
    //    callId = "<null>";
    //    code = 0;
    //    mode = 0;
    //    reason = success;
    //    requestId = "2015-10-28 14:49:19:019";
    //}
    else if(action == 103)
    {
        if( code == 0 && [reason isEqualToString:@"success"])
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"OK:groupInvite" waitUntilDone:NO];
        else
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:[NSString stringWithFormat:@"ERROR:groupInvite,code=%d",code] waitUntilDone:NO];
    }
    //7、主动加入会议请求：
    //{
    //    action = 107;
    //    code = 0;
    //    mode = 0;
    //    reason = success;
    //    requestId = "2015-10-28 14:51:14:014";
    //}
    else if(action == 107)
    {
        if( code == 0 && [reason isEqualToString:@"success"])
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"OK:groupJoin" waitUntilDone:NO];
        else
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:[NSString stringWithFormat:@"ERROR:groupJoin,code=%d",code] waitUntilDone:NO];
    }
    //4、踢出成员请求：
    //{
    //    action = 104;
    //    callId = "<null>";
    //    code = 0;
    //    mode = "<null>";
    //    reason = "10-18910903997~70038~Any delete member success !";
    //    requestId = "2015-10-28 14:49:01:001";
    //}
    else if(action == 104)
    {
        if(code == 0 && [reason hasSuffix:@"success !"])
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"OK:groupKick" waitUntilDone:NO];
        else
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:[NSString stringWithFormat:@"ERROR:groupKick,code=%d",code] waitUntilDone:NO];
    }
    //6、关闭会议请求：
    //{
    //    action = 106;
    //    callId = "<null>";
    //    code = 0;
    //    mode = "<null>";
    //    reason = success;
    //    requestId = "2015-10-28 14:52:28:028";
    //}
    else if(action == 106)
    {
        if(code == 0 && [reason isEqualToString:@"success"])
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"OK:groupClose" waitUntilDone:NO];
        else
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:[NSString stringWithFormat:@"ERROR:groupClose,code=%d",code] waitUntilDone:NO];
    }
    //5、操作麦克请求：
    //{
    //    action = 105;
    //    code = 0;
    //    controlResult = "<null>";
    //    reason = success;
    //    requestId = "2015-10-28 14:51:59:059";
    //}
    else if(action == 105)
    {
        if(code == 0 && [reason isEqualToString:@"success"])
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"OK:groupMic" waitUntilDone:NO];
        else
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:[NSString stringWithFormat:@"ERROR:groupMic,code=%d",code] waitUntilDone:NO];
    }
    else if(action == 108)
    {
        if(code == 0 && [reason hasSuffix:@"success!"])
        {
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:@"OK:groupVideo" waitUntilDone:NO];
            
            [self.mCallObj doChangeView];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6*NSEC_PER_SEC)),dispatch_get_main_queue(),^
                           {
                               [self.mCallObj doSetCallVideoWindow:self.remoteVideoView localVideoWindow:self.localVideoView];
                           });
        }
        else
            [self performSelectorOnMainThread:@selector(cbGroupStatus:) withObject:[NSString stringWithFormat:@"ERROR:groupVideo,code=%d",code] waitUntilDone:NO];
    }
    
    return EC_OK;
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

//    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), //center
//                                    NULL, // observer
//                                    onNotifyCallback, // callback
//                                    CFSTR("com.apple.system.config.network_change"), // event name
//                                    NULL, // object
//                                    CFNotificationSuspensionBehaviorDeliverImmediately);
}

static void onNotifyCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    NSString* notifyName = (__bridge NSString *)name;//(NSString*)name;
    // this check should really only be necessary if you reuse this one callback method
    //  for multiple Darwin notification events
    if ([notifyName isEqualToString:@"com.apple.system.config.network_change"]) {
        // use the Captive Network API to get more information at this point
        //  http://stackoverflow.com/a/4714842/119114
        
        //
        NSLog(@"onNotifyCallback %@", notifyName);
        
        @autoreleasepool
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kReachabilityChangedNotificationRTC
                                                                object:nil];
        }
        
    } else {
        NSLog(@"intercepted %@", notifyName);
    }
    
}

- (void) reachabilityNetWorkStatusChanged: (NSNotification* )note
{
    ReachabilityRTC* curReach = [note object];
    //    if(!curReach)
    //    {
    //        NSLog(@"网络变化");
    //        [self.viewController onNetworkChanged:YES];
    //        return;
    //    }
    int networkStatus = [curReach currentReachabilityStatus];
    NSLog(@"reachability Changed:%d.",networkStatus);
    
    if (networkStatus!=NotReachableRTC)
    {
        if (self.firstCheckNetwork)
        {
            self.firstCheckNetwork=NO;
            lastStatus = networkStatus;
            return;
        }
    }
    
    NSLog(@"lastStatus:%d,networkStatus:%d.",lastStatus,networkStatus);
    if((networkStatus == 0) || (networkStatus*lastStatus !=0))
        [self onNetworkChanged:networkStatus];
    
    
    lastStatus = networkStatus;
    self.firstCheckNetwork=NO;
}

-(void)onNetworkChanged:(int)netstatus
{
    if(netstatus == 1 || netstatus == 2)
    {
        CWLogDebug(@"networkChanged to YES");
        [self.mSDKObj onNetworkChanged];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5*NSEC_PER_SEC)),dispatch_get_main_queue(),^{
            if (!self.mSDKObj || ![self.mSDKObj isInitOk] || !self.mAccObj || ![self.mAccObj isRegisted])
            {
//                CWLogDebug(@"isGettingToken:%d",isGettingToken);
//                if(!isGettingToken)
//                {
//                    isGettingToken = YES;
//                    CWLogDebug(@"重新初始化rtc");
//                    [self doUnRegister];
//                    [self onSDKInit];
//                }
                return;
            }
            if(!self.isGettingToken)//如果已经发起了重注册并且还未返回登录结果，那么在回调返回结果之前请不要再次进行重连
            {
                self.isGettingToken = YES;
                [self.mSDKObj onAppEnterBackground];//网络恢复后进行重连
            }
            [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"StateChanged,result=-1002" waitUntilDone:NO];
        });
    }
    else
    {
        CWLogDebug(@"networkChanged to NO");
        [self.mSDKObj onNetworkChanged];//网络断开后销毁网络数据
        
        if(self.mCallObj)//通话被迫结束，销毁通话界面
        {
            [self.mCallObj doReleaseCallResource];
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
        [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"StateChanged,result=-1001" waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(onGlobalStatus:) withObject:@"pls check network" waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(cbCallStatus:) withObject:@"OK:NORMAL" waitUntilDone:NO];
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

-(void)willResignActiveNotification:(NSNotification *) notification
{
    if(!self.mCallObj && [[[UIDevice currentDevice]systemVersion]floatValue]>=9.0)
    {
        if (self.mAccObj)
        {
            self.mAccObj.isBackground = YES;
        }
    }
}

-(void)didBecomeActiveNotification:(NSNotification *) notification
{
    if([[[UIDevice currentDevice]systemVersion]floatValue]>=9.0)
    {
        if (self.mAccObj)
        {
            self.mAccObj.isBackground = NO;
        }
    }
}

-(void)enterBackgroundNotification:(NSNotification *) notification
{
    //后台重连
    [NSRunLoop currentRunLoop];
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]&&[[[UIDevice currentDevice]systemVersion]floatValue]<=9.0)
    {
        //[self performSelectorOnMainThread:@selector(keepAlive) withObject:nil waitUntilDone:YES];
        [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler: ^{
            [self performSelectorOnMainThread:@selector(keepAlive) withObject:nil waitUntilDone:YES];
        }];
    }
}

-(void)enterForegroundNotification:(NSNotification *) notification
{
    if([[[UIDevice currentDevice]systemVersion]floatValue]>=9.0)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0*NSEC_PER_SEC)),dispatch_get_main_queue(),^{
            self.mAccObj.isBackground = NO;
            CWLogDebug(@"AccObj.isBackground = NO");
            [self reCallRequest];
        });
    if (!self.mSDKObj || ![self.mSDKObj isInitOk] || !self.mAccObj || ![self.mAccObj isRegisted])
    {
        CWLogDebug(@"isGettingToken:%d",self.isGettingToken);
        if(!self.isGettingToken&&![self.userID isEqualToString:@""])
        {
            self.isGettingToken = YES;
            CWLogDebug(@"重新初始化rtc");
            [self doUnRegister];
            [self onSDKInit];
        }
        return;
    }
}

@end
