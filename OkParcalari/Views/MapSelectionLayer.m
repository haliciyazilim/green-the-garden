//
//  MainGameLayer.m
//  OkParcalari
//
//  Created by Alperen Kavun on 24.12.2012.
//
//

#define GAME_LAYER_TAG 582

#import "Flurry.h"

#import "MapSelectionLayer.h"
#import "GreenTheGardenSoundManager.h"
#import "GreenTheGardenIAPHelper.h"
#import "AchievementManager.h"
#import "GreenTheGardenGCSpecificValues.h"
#import "TransitionManager.h"
#import "InfoScreenView.h"
#import "GTGScrollView.h"
#import "MapSelectionScrollView.h"
#import "PackageSelectionScrollView.h"

static MapSelectionLayer* lastInstance;

@implementation MapSelectionLayer
{
    GTGScrollView* scrollView;
    UIView *barView;
    UIImageView *leafView;
    UIImageView *maskView;
    UIImageView *logoView;
    NSString* packageFileName;
    UIButton *unlockButton;
    MapPackage* currentMapPackage;
    UIViewController * tempVC;
    BOOL shouldCancel;
}

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MapSelectionLayer *gameLayer = [MapSelectionLayer node];
	
	// add layer as a child to scene
	[scene addChild:gameLayer];
	
	// return the scene
	return scene;
}
+ (MapSelectionLayer *)lastInstance
{
    return lastInstance;
}
-(id) init
{
    if(self = [super init]){
        lastInstance = self;
        packageFileName = @"standart";
        //        CGSize size = [[CCDirector sharedDirector] winSize];
        
        maskView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_selection_masklayer.png"]];
        

        if(currentMapPackage == nil){
            scrollView = [[PackageSelectionScrollView alloc] init];
            [scrollView setFrame:CGRectMake(0.0, 300.0, 1024.0, 400.0)];
        }
        else{
            [self showPackage:currentMapPackage];
        }
        
        leafView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_selection_leaflayer.png"]];
        
        logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GreenTheGarden_Logo.png"]];
        [logoView setFrame:CGRectMake(521, 69, logoView.image.size.width, logoView.image.size.height)];
        
        barView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 708.0, 1024.0, 60)];
        
        UIButton* infoButton = [[UIButton alloc] initWithFrame:CGRectMake(35.0, 17.0, 26.0, 28.0)];
        [infoButton setBackgroundImage:[UIImage imageNamed:@"map_barbtn_info.png"] forState:UIControlStateNormal];
        [infoButton setBackgroundImage:[UIImage imageNamed:@"map_barbtn_info_hover.png"] forState:UIControlStateHighlighted];
        [infoButton addTarget:self action:@selector(infoScreen) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* fxButton = [[UIButton alloc] initWithFrame:CGRectMake(70.0, 17.0, 26.0, 28.0)];
        if([[GreenTheGardenSoundManager sharedSoundManager] isEffectsMuted]){
            [fxButton setBackgroundImage:[UIImage imageNamed:@"map_barbtn_fx_off.png"] forState:UIControlStateNormal];
            [fxButton setBackgroundImage:[UIImage imageNamed:@"map_barbtn_fx_off.png"] forState:UIControlStateHighlighted];
        }
        else{
            [fxButton setBackgroundImage:[UIImage imageNamed:@"map_barbtn_fx_on.png"] forState:UIControlStateNormal];
            [fxButton setBackgroundImage:[UIImage imageNamed:@"map_barbtn_fx_on.png"] forState:UIControlStateHighlighted];
        }
        [fxButton addTarget:self action:@selector(fxClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* musicButton = [[UIButton alloc] initWithFrame:CGRectMake(106.0, 17.0, 26.0, 28.0)];
        if([[GreenTheGardenSoundManager sharedSoundManager] isBackgroundMusicMuted]){
            [musicButton setBackgroundImage:[UIImage imageNamed:@"map_barbtn_music_off.png"] forState:UIControlStateNormal];
            [musicButton setBackgroundImage:[UIImage imageNamed:@"map_barbtn_music_off.png"] forState:UIControlStateHighlighted];
        }
        else{
            [musicButton setBackgroundImage:[UIImage imageNamed:@"map_barbtn_music_on.png"] forState:UIControlStateNormal];
            [musicButton setBackgroundImage:[UIImage imageNamed:@"map_barbtn_music_on.png"] forState:UIControlStateHighlighted];
        }
        [musicButton addTarget:self action:@selector(musicClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *gameCenterButton = [[UIButton alloc] initWithFrame:CGRectMake(142.0, 17.0, 26.0, 28.0)];
        [gameCenterButton setBackgroundImage:[UIImage imageNamed:@"map_barbtn_gc.png"] forState:UIControlStateNormal];
        [gameCenterButton setBackgroundImage:[UIImage imageNamed:@"map_barbtn_gc_hover.png"] forState:UIControlStateHighlighted];
        [gameCenterButton addTarget:self action:@selector(showGameCenter) forControlEvents:UIControlEventTouchUpInside];

        
        [barView addSubview:infoButton];
        [barView addSubview:fxButton];
        [barView addSubview:musicButton];
        [barView addSubview:gameCenterButton];
        
        if(![[GreenTheGardenIAPHelper sharedInstance] isPro]){
            unlockButton = [[UIButton alloc] initWithFrame:CGRectMake(783.0, 17.0, 150.0, 28.0)];
            [unlockButton setBackgroundImage:[UIImage imageNamed:LocalizedImageName(@"map_barbtn_unlock", @"png")] forState:UIControlStateNormal];
            [unlockButton setBackgroundImage:[UIImage imageNamed:LocalizedImageName(@"map_barbtn_unlock_hover", @"png")] forState:UIControlStateHighlighted];
            [unlockButton addTarget:self action:@selector(addStore) forControlEvents:UIControlEventTouchUpInside];
            [barView addSubview:unlockButton];
        }

        
        [[[CCDirector sharedDirector] view] addSubview:maskView];
        [[[CCDirector sharedDirector] view] addSubview:logoView];
        [[[CCDirector sharedDirector] view] addSubview:scrollView];
        [[[CCDirector sharedDirector] view] addSubview:leafView];
        [[[CCDirector sharedDirector] view] addSubview:barView];
        
    }
    return self;
}

-(void)showPackage:(MapPackage *)package
{
    [scrollView removeFromSuperview];
    scrollView = [[MapSelectionScrollView alloc] initWithMapPackage:package];
    [[[CCDirector sharedDirector] view] addSubview:scrollView];
    [scrollView setFrame:CGRectMake(0.0, 300.0, 1024.0, 400.0)];
    [[[CCDirector sharedDirector] view] addSubview:leafView];
    [[[CCDirector sharedDirector] view] addSubview:barView];
}


- (void)onEnter{
    [scrollView refreshScrollView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    shouldCancel = NO;
    double delayInSeconds = 120.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (!shouldCancel) {
            [[AchievementManager sharedAchievementManager]submitAchievement:kAchievementNothingToDoHere percentComplete:100];
        }
    });
}

- (void)onExit {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IAPHelperProductPurchasedNotification object:nil];
    shouldCancel=YES;
}

-(void)onDown:(UIButton*)button
{
    [button setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"level_bg_selected.png"]]];
}

-(void)openGameForMap:(Map*)map
{

    self.isTouchEnabled = NO;
    [[TransitionManager sharedInstance] makeTransitionWithBlock:^{
        [MapSelectionLayer setLastScroll:scrollView.contentOffset.x];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[ArrowGameLayer sceneWithFile:map.mapId] withColor:ccWHITE]];
        [scrollView removeFromSuperview];
        [maskView removeFromSuperview];
        [leafView removeFromSuperview];
        [barView removeFromSuperview];
        [logoView removeFromSuperview];
        [self removeFromParentAndCleanup:YES];

    }];
}

- (void) openStoreForPackage:(MapPackage*)package
{
    #pragma mark Alperen GAVUN
}

- (void) setPackage:(NSString*)package
{
    packageFileName = package;
}

- (void)productPurchased:(NSNotification *)notification {
    [unlockButton removeFromSuperview];
    [[DatabaseManager sharedInstance] updateMaps];
    [scrollView refreshScrollView];
}
-(void)addStore {
    if(!self.reachability){
        self.reachability = [Reachability reachabilityForInternetConnection];
    }
    NetworkStatus netStatus = [self.reachability currentReachabilityStatus];
    if(netStatus == NotReachable){
        UIAlertView *noConnection = [[UIAlertView alloc] initWithTitle:@""
                                                                      message:NSLocalizedString(@"CONNECTION_ERROR", nil)
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                            otherButtonTitles:nil,nil];
        [noConnection show];
    }
    else{
        [[GreenTheGardenIAPHelper sharedInstance] setCallerLayer:self];
        [[GreenTheGardenIAPHelper sharedInstance] createStore];
    }
    
}
- (void)fxClicked:(UIButton *)button {
    if([[GreenTheGardenSoundManager sharedSoundManager] isEffectsMuted]){
        [button setBackgroundImage:[UIImage imageNamed:@"map_barbtn_fx_on.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"map_barbtn_fx_on.png"] forState:UIControlStateHighlighted];
        [[GreenTheGardenSoundManager sharedSoundManager] setIsEffectsMuted:NO];
    }
    else{
        [button setBackgroundImage:[UIImage imageNamed:@"map_barbtn_fx_off.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"map_barbtn_fx_off.png"] forState:UIControlStateHighlighted];
        [[GreenTheGardenSoundManager sharedSoundManager] setIsEffectsMuted:YES];
    }
}
- (void)musicClicked:(UIButton *)button {
    if([[GreenTheGardenSoundManager sharedSoundManager] isBackgroundMusicMuted]){
        [button setBackgroundImage:[UIImage imageNamed:@"map_barbtn_music_on.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"map_barbtn_music_on.png"] forState:UIControlStateHighlighted];
        [[GreenTheGardenSoundManager sharedSoundManager] setIsBackgroundMusicMuted:NO];
    }
    else{
        [button setBackgroundImage:[UIImage imageNamed:@"map_barbtn_music_off.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"map_barbtn_music_off.png"] forState:UIControlStateHighlighted];
        [[GreenTheGardenSoundManager sharedSoundManager] setIsBackgroundMusicMuted:YES];
    }
}

- (void) showGameCenter
{    if(!self.reachability){
        self.reachability = [Reachability reachabilityForInternetConnection];
    }
    NetworkStatus netStatus = [self.reachability currentReachabilityStatus];
    if(netStatus == NotReachable){
        UIAlertView *noConnection = [[UIAlertView alloc] initWithTitle:@""
                                                               message:NSLocalizedString(@"CONNECTION_ERROR", nil)
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                     otherButtonTitles:nil,nil];
        [noConnection show];
    }
    else{
        tempVC = [[UIViewController alloc] init];
        GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
        if (gameCenterController != nil){
            [Flurry logEvent:kFlurryEventGameCenterView timed:YES];
            gameCenterController.gameCenterDelegate = self;
            [[[CCDirector sharedDirector] view] addSubview:tempVC.view];
            [tempVC presentModalViewController:gameCenterController animated:YES];
        }
    }
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [tempVC dismissModalViewControllerAnimated:YES];
    [tempVC.view removeFromSuperview];
    [Flurry endTimedEvent:kFlurryEventGameCenterView withParameters:nil];
}

-(void) infoScreen{
    [Flurry logEvent:kFlurryEventInfoScreenView timed:YES];
    [[[InfoScreenView alloc] init] setHidden:NO];
}





- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void) makeTransition
{
//    NSLog(@"entered makeTransition");
}

//static MAP_DIFFICULTY difficulty = EASY;
//+(MAP_DIFFICULTY) getDifficulty
//{
//    return difficulty;
//}
//+(void) setDifficulty:(MAP_DIFFICULTY)_difficulty
//{
//    difficulty = _difficulty;
//}

static int __lastScroll = 0;

+(int)getLastScroll
{
    return __lastScroll;
}

+(void)setLastScroll:(int)scroll{
    __lastScroll = scroll;
}

@end
