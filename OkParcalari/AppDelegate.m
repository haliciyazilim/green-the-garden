//
//  AppDelegate.m
//  OkParcalari
//
//  Created by Eren Halici on 06.12.2012.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "MainGameLayer.h"
#import "GameCenterManager.h"
#import "DatabaseManager.h"

//#import <FacebookSDK/FacebookSDK.h>
#import "Facebook.h"
#import "Flurry.h"
#import "FlurryAds.h"

#import "GreenTheGardenIAPHelper.h"
#import "GreenTheGardenSoundManager.h"
#import "CDAudioManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVAudioSession.h>
#import "SimpleAudioEngine.h"
#import "GreenTheGardenGCSpecificValues.h"
#import "AchievementManager.h"

@implementation AppController

@synthesize window=window_, navController=navController_, director=director_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Flurry setDebugLogEnabled:NO];
    [Flurry setShowErrorInLogEnabled:NO];
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [Flurry startSession:@"PW345B45PR4W3D6Z2V8H"];
    [FlurryAds initialize:[CCDirector sharedDirector]];
    
    if ([[DatabaseManager sharedInstance] isEmpty]) {
        [Flurry logEvent:kFlurryEventFirstSession timed:YES];
    }
    
    [GreenTheGardenIAPHelper sharedInstance];
    [GreenTheGardenSoundManager sharedSoundManager];
    
	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];


	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];

	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];

	director_.wantsFullScreenLayout = YES;

	// Display FSP and SPF
	[director_ setDisplayStats:NO];

	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];

	// attach the openglView to the director
	[director_ setView:glView];

	// for rotation and other messages
	[director_ setDelegate:self];

	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
//	[director setProjection:kCCDirectorProjection3D];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

	// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
	[director_ pushScene: [MainGameLayer scene]];
    
    [director_ enableRetinaDisplay:YES];
    
	// Create a Navigation Controller with the Director
	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
	
	// set the Navigation Controller as the root view controller
//	[window_ addSubview:navController_.view];	// Generates flicker.
	[window_ setRootViewController:navController_];
	
	// make main window visible
	[window_ makeKeyAndVisible];
    
    return YES;
}

void uncaughtExceptionHandler(NSException *exception) {
    [Flurry logError:@"Uncaught" message:@"Crash!" exception:exception];
}

// Supported orientations: Landscape. Customize it for your own needs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
    if([[ArrowGame lastInstance] isGameRunning] && ![[ArrowGameLayer lastInstance] isAnyAlertShown]){
        [[[ArrowGameLayer lastInstance] arrowGame] pauseGame];
    }
	if( [navController_ visibleViewController] == director_ )
		[director_ pause];
    [[GreenTheGardenSoundManager sharedSoundManager] stopBackgroundMusic];
    [SimpleAudioEngine end];
    
    [[NSNotificationCenter defaultCenter] removeObserver:[AchievementManager sharedAchievementManager] name:kAuthenticationChangedNotification object:nil];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
    [FBSettings publishInstall:[FBSession defaultAppID]];
    if([ArrowGameLayer lastInstance]){
        if(![[ArrowGameLayer lastInstance] isRestaurantOpened] && ![[ArrowGameLayer lastInstance] isMenuOpened] && ![[ArrowGameLayer lastInstance] isGameEnded] && ![[ArrowGameLayer lastInstance] isAnyAlertShown])
            [[ArrowGameLayer lastInstance] showInGameMenu:NO];
    }
	if( [navController_ visibleViewController] == director_ )
		[director_ resume];
    
    if ([[MPMusicPlayerController iPodMusicPlayer] playbackState] != MPMusicPlaybackStatePlaying) {
        [[GreenTheGardenSoundManager sharedSoundManager] playBackgroundMusic];
    } else {
        ;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:[AchievementManager sharedAchievementManager] selector:@selector(loadAchievements) name:kAuthenticationChangedNotification object:nil];
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [FBSession.activeSession handleOpenURL:url];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ ){
		[director_ stopAnimation];
    }
    
    int week=3600*24*7;
    UILocalNotification* localNotificationWeek= [[UILocalNotification alloc]init];
    if(localNotificationWeek){
        localNotificationWeek.fireDate=[NSDate dateWithTimeIntervalSinceNow:week];
        localNotificationWeek.alertBody=@"Duydum ki, bizim uygulamaya 1 haftadır bakmıyoruşsun. BAK!";
        localNotificationWeek.timeZone=[NSTimeZone defaultTimeZone];
        localNotificationWeek.alertAction=@"Start App";
        localNotificationWeek.hasAction=YES;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotificationWeek];
    }

    UILocalNotification* localNotificationMonth= [[UILocalNotification alloc]init];
    if(localNotificationMonth){
        localNotificationMonth.fireDate=[NSDate dateWithTimeIntervalSinceNow:week*4];
        localNotificationMonth.alertBody=@"Duydum ki, bizim uygulamaya 1 aydır bakmıyoruşsun. BAK!";
        localNotificationMonth.timeZone=[NSTimeZone defaultTimeZone];
        localNotificationMonth.alertAction=@"Start App";
        localNotificationMonth.hasAction=YES;
        [[UIApplication  sharedApplication] scheduleLocalNotification:localNotificationMonth];
    }
    
    UILocalNotification* localNotification3Months= [[UILocalNotification alloc]init];
    if(localNotification3Months){
        localNotification3Months.fireDate=[NSDate dateWithTimeIntervalSinceNow:week*12];
        localNotification3Months.alertBody=@"Duydum ki, bizim uygulamaya 3 aydır bakmıyoruşsun. BAK!";
        localNotification3Months.timeZone=[NSTimeZone defaultTimeZone];
        localNotification3Months.alertAction=@"Start App";
        localNotification3Months.hasAction=YES;
        [[UIApplication  sharedApplication] scheduleLocalNotification:localNotification3Months];
    }





}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ ){
		[director_ startAnimation];
    }
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}
- (void) dealloc
{
    
}

@end