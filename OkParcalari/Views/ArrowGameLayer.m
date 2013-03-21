//
//  ArrowGameLayer.m
//  OkParcalari
//
//  Created by Eren Halici on 06.12.2012.
//
//

#define MENU_TAG 994

//#import <FacebookSDK/FacebookSDK.h>
#import "Facebook.h"
#import <Twitter/Twitter.h>
#import "Flurry.h"

#import "ArrowGameLayer.h"
#import "InGameMenuLayer.h"
#import "GameMap.h"
#import "MapEntity.h"
#import "CCBReader.h"
#import "Squirt.h"
#import "CCBAnimationManager.h"
#import "MapSelectionLayer.h"
#import "GreenTheGardenSoundManager.h"
#import "Stopwatch.h"

#import "AchievementManager.h"
#import "GreenTheGardenGCSpecificValues.h"
#import "TransitionManager.h"

@interface ArrowGameLayer ()

- (void) showFaceBookDialogWithAccessToken:(NSString *)accessToken
                         andExpirationDate:(NSDate *)expirationDate;

@end


@implementation ArrowGameLayer
{
    NSString *_fileName;
    UIView *inGameButtonsView;
    UIView *gameWinView;
    
    int _elapsedSeconds;
    int _starCount;
    int _mapOrder;
    MAP_DIFFICULTY _difficulty;
    
    BOOL canShowRateUsAlert;
}

+(CCScene *) sceneWithFile:(NSString *)fileName
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	ArrowGameLayer *layer = [ArrowGameLayer node];
	[layer initializeGameWithFile:fileName];
//    NSLog(@"%@",fileName);
	// add layer as a child to scene
//    InGameMenuLayer *menuLayer = [InGameMenuLayer node];
	[scene addChild: layer];
//    [scene addChild:menuLayer];
    
    
	
	// return the scene
	return scene;
}

static ArrowGameLayer* __lastInstance;

+(ArrowGameLayer*)lastInstance
{
    return __lastInstance;
}

+(void)cleanLastInstance
{
    __lastInstance = nil;
}

-(void)onExit{
    [inGameButtonsView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachedToRestaurantNotification object:nil];
}
-(void)onEnter{
    [super onEnter];
    inGameButtonsView = [[UIView alloc] initWithFrame:CGRectMake(900.0, 20.0, 105.0, 35.0)];
//    [inGameButtonsView setBackgroundColor:[UIColor redColor]];
    
    UIButton* fxButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 2.0, 30.0, 30.0)];
    if([[GreenTheGardenSoundManager sharedSoundManager] isEffectsMuted]){
        [fxButton setBackgroundImage:[UIImage imageNamed:@"game_btnfx_off.png"] forState:UIControlStateNormal];
        [fxButton setBackgroundImage:[UIImage imageNamed:@"game_btnfx_off.png"] forState:UIControlStateHighlighted];
    }
    else{
        [fxButton setBackgroundImage:[UIImage imageNamed:@"game_btnfx_on.png"] forState:UIControlStateNormal];
        [fxButton setBackgroundImage:[UIImage imageNamed:@"game_btnfx_on.png"] forState:UIControlStateHighlighted];
    }
    [fxButton addTarget:self action:@selector(fxClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* musicButton = [[UIButton alloc] initWithFrame:CGRectMake(38.0, 2.0, 30.0, 30.0)];
    if([[GreenTheGardenSoundManager sharedSoundManager] isBackgroundMusicMuted]){
        [musicButton setBackgroundImage:[UIImage imageNamed:@"game_btnsound_off.png"] forState:UIControlStateNormal];
        [musicButton setBackgroundImage:[UIImage imageNamed:@"game_btnsound_off.png"] forState:UIControlStateHighlighted];
    }
    else{
        [musicButton setBackgroundImage:[UIImage imageNamed:@"game_btnsound_on.png"] forState:UIControlStateNormal];
        [musicButton setBackgroundImage:[UIImage imageNamed:@"game_btnsound_on.png"] forState:UIControlStateHighlighted];
    }
    [musicButton addTarget:self action:@selector(musicClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* menuButton = [[UIButton alloc] initWithFrame:CGRectMake(75.0, 2.0, 30.0, 30.0)];
    [menuButton setBackgroundImage:[UIImage imageNamed:@"game_btnmenu.png"] forState:UIControlStateNormal];
    [menuButton setBackgroundImage:[UIImage imageNamed:@"game_btnmenu_selected.png"] forState:UIControlStateHighlighted];
    [menuButton addTarget:self action:@selector(goToMenu) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachedToRestaurant:) name:kReachedToRestaurantNotification object:nil];
    
    [inGameButtonsView addSubview:fxButton];
    [inGameButtonsView addSubview:musicButton];
    [inGameButtonsView addSubview:menuButton];
    
    [[[CCDirector sharedDirector] view] addSubview:inGameButtonsView];
    
//    if(gameWinView != nil){
//        [gameWinView removeFromSuperview];
//        gameWinView = nil;
//    }
    self.arrowGame = [[ArrowGame alloc] initWithFile:_fileName];
    [self addChild:self.arrowGame];
}
-(void)goToMenu{
    if(!_isRestaurantOpened){
        [self showInGameMenu:NO];
    }
}

// on "init" you need to initialize your instance
-(id) init
{
    // always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCSprite *background = [CCSprite spriteWithFile:@"mainbg.jpg"];
        background.position = ccp(size.width * 0.5, size.height * 0.5);
        
        CCSprite *frameView = [CCSprite spriteWithFile:@"main_frame.png"];
        frameView.position = ccp(size.width * 0.5, size.height * 0.5);

        CCSprite *topView = [CCSprite spriteWithFile:@"gameboard.png"];
        topView.position = ccp(384,384);
        
        CCSprite *logoView = [CCSprite spriteWithFile:@"game_logo.png"];
        logoView.position = ccp(782,549);
        
        [self addChild:background];
        [self addChild:topView z:998];
        [self addChild:frameView z:999];
        [self addChild:logoView z:1000];
        
        _isRestaurantOpened = NO;
        _isMenuOpened = NO;
        _isGameEnded = NO;
        
		self.isTouchEnabled = YES;
        
        
        NSString *userDef = [[NSUserDefaults standardUserDefaults] objectForKey:@"canShowRateUsAlert"];
        
        if (userDef == nil) {
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"canShowRateUsAlert"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            canShowRateUsAlert = YES;
        } else if ([userDef  isEqualToString:@"YES"]) {
            canShowRateUsAlert = YES;
        } else if ([userDef isEqualToString:@"NO"]) {
            canShowRateUsAlert = NO;
        }
	}
    __lastInstance = self;
	return self;
}

- (void)fxClicked:(UIButton *)button {
    if([[GreenTheGardenSoundManager sharedSoundManager] isEffectsMuted]){
        [button setBackgroundImage:[UIImage imageNamed:@"game_btnfx_on.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"game_btnfx_on.png"] forState:UIControlStateHighlighted];
        [[GreenTheGardenSoundManager sharedSoundManager] setIsEffectsMuted:NO];
    }
    else{
        [button setBackgroundImage:[UIImage imageNamed:@"game_btnfx_off.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"game_btnfx_off.png"] forState:UIControlStateHighlighted];
        [[GreenTheGardenSoundManager sharedSoundManager] setIsEffectsMuted:YES];
    }
}
- (void)musicClicked:(UIButton *)button {
    if([[GreenTheGardenSoundManager sharedSoundManager] isBackgroundMusicMuted]){
        [button setBackgroundImage:[UIImage imageNamed:@"game_btnsound_on.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"game_btnsound_on.png"] forState:UIControlStateHighlighted];
        [[GreenTheGardenSoundManager sharedSoundManager] setIsBackgroundMusicMuted:NO];
    }
    else{
        [button setBackgroundImage:[UIImage imageNamed:@"game_btnsound_off.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"game_btnsound_off.png"] forState:UIControlStateHighlighted];
        [[GreenTheGardenSoundManager sharedSoundManager] setIsBackgroundMusicMuted:YES];
    }
}

- (void) initializeGameWithFile:(NSString*)fileName
{
    _fileName = fileName;
    __lastInstance = self;
    
    _difficulty = [[DatabaseManager sharedInstance] getMapWithID:_fileName].difficulty;
    _mapOrder = [[DatabaseManager sharedInstance] getMapWithID:_fileName].order;
    
    [Flurry logEvent:kFlurryEventMapStarted
      withParameters:@{
            @"Map Order" : [NSNumber numberWithInt:_mapOrder],
            @"Difficulty" : [NSNumber numberWithInt:_difficulty]
     }];
}

- (void) restartGame {
    self.isTouchEnabled = NO;
    
    [[TransitionManager sharedInstance] makeTransitionWithBlock:^{
        NSString *newFile = [NSString stringWithString:_fileName];
        if(gameWinView != nil){
            [gameWinView removeFromSuperview];
            gameWinView = nil;
        }
        [self.arrowGame cleanMap];
        [self.arrowGame removeFromParentAndCleanup:YES];
        _isRestaurantOpened = NO;
        _isMenuOpened = NO;
        _isGameEnded = NO;
        [ArrowGame cleanLastInstance];
        [ArrowGameLayer cleanLastInstance];
        [self removeFromParentAndCleanup:YES];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[ArrowGameLayer sceneWithFile:newFile] withColor:ccWHITE]];
    }];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.arrowGame touchBegan:[self locationFromTouches:touches]];
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.arrowGame touchMoved:[self locationFromTouches:touches]];
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.arrowGame touchEnded:[self locationFromTouches:touches]];
}

-(CGPoint)pointFromTouches:(NSSet*) touches
{
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:[touch view]];
    point = [[CCDirector sharedDirector] convertToGL:point];
    return point;
}

-(Location)locationFromTouches:(NSSet*) touches
{
    CGPoint point = [self pointFromTouches:touches];
    Location location = [[GameMap sharedInstance] convertAbsolutePointToGridPoint:point];
    return location;
}
- (void) reachedToRestaurant:(NSNotification *)notif {
    [[AchievementManager sharedAchievementManager] submitAchievement:kAchievementTheRestaurant percentComplete:100.0];
    _isRestaurantOpened = YES;
    [self showInGameMenu:YES];
    
}
- (void) showInGameMenu:(BOOL)isRestaurant {
    InGameMenuLayer *child = (InGameMenuLayer*)[self getChildByTag:MENU_TAG];
    if(child){
        [child resumeGame];
    }
    else{
        if([self.arrowGame isGameRunning]){
            [self.arrowGame pauseGame];
        }
        InGameMenuLayer *menuLayer = [[InGameMenuLayer alloc] initWithRestaurant:isRestaurant];
        menuLayer.callerLayer = self;
        menuLayer.tag = MENU_TAG;
        [self addChild:menuLayer];
        [self reorderChild:menuLayer z:1111];
        self.isTouchEnabled = NO;
        if(!isRestaurant){
            _isMenuOpened = YES;
        }
    }
}
- (void) inGameMenuWillClose {
    [self.arrowGame resumeGame];
    _isMenuOpened = NO;
    self.isTouchEnabled = YES;
}
- (void) returnToMainMenu {
    self.isTouchEnabled = NO;
    [[TransitionManager sharedInstance] makeTransitionWithBlock:^{
        if(gameWinView != nil){
            [gameWinView removeFromSuperview];
            gameWinView = nil;
        }
        _isRestaurantOpened = NO;
        [self.arrowGame cleanMap];
        [self.arrowGame removeFromParentAndCleanup:YES];
        [self removeFromParentAndCleanup:YES];
        [ArrowGameLayer cleanLastInstance];
        [ArrowGame cleanLastInstance];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[MapSelectionLayer scene] withColor:ccWHITE]];
    }];
}
- (void) nextGame {
    Map *oldMap = [[DatabaseManager sharedInstance] getMapWithID:_fileName];
    int oldMapOrder = oldMap.order;
    NSString *oldMapPackage = oldMap.packageId;
    Map *newMap = [[DatabaseManager sharedInstance] getMapWithOrder:[NSNumber numberWithInt:oldMapOrder+1] forPackage:oldMapPackage];
    if (!newMap.isPurchased) {
        UIAlertView *noPurchased = [[UIAlertView alloc] initWithTitle:@""
                                                                   message:NSLocalizedString(@"NO_PURCHASED", nil)
                                                                  delegate:self
                                                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                         otherButtonTitles:nil,nil];
        [noPurchased show];
    }
    else{
        self.isTouchEnabled = NO;
        [[TransitionManager sharedInstance] makeTransitionWithBlock:^{
            if(gameWinView != nil){
//                NSLog(@"removed gameWinView");
//                NSLog(@"%@",gameWinView);
                [gameWinView removeFromSuperview];
                gameWinView = nil;
            }
            [self.arrowGame cleanMap];
            [self.arrowGame removeFromParentAndCleanup:YES];
            _isRestaurantOpened = NO;
            _isMenuOpened = NO;
            _isGameEnded = NO;
            [ArrowGame cleanLastInstance];
            [ArrowGameLayer cleanLastInstance];
            [self removeFromParentAndCleanup:YES];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[ArrowGameLayer sceneWithFile:newMap.mapId] withColor:ccWHITE]];
        }];
    }
}
-(void) gameEnded:(int)starCount andElapsedSeconds:(int)elapsedSeconds
{
    _starCount = starCount;
    _elapsedSeconds = elapsedSeconds;
    
    [Flurry logEvent:kFlurryEventMapSolved
      withParameters:@{
            @"Map Order" : [NSNumber numberWithInt:_mapOrder],
            @"Difficulty" : [NSNumber numberWithInt:_difficulty],
            @"Star Count" : [NSNumber numberWithInt:_starCount],
            @"Elapsed Seconds" : [NSNumber numberWithInt:_elapsedSeconds]
     }];
    
    [[GreenTheGardenSoundManager sharedSoundManager] playEffect:@"success"];
    _isGameEnded = YES;
    self.isTouchEnabled = NO;
    
    Map* map = [[DatabaseManager sharedInstance] getMapWithID:_fileName];
    NSString *levelNumStr = [NSString stringWithFormat:@"%d",map.order];
    
    int mapOrder = map.order;
    NSString *oldMapPackage = map.packageId;
    Map *newMap = [[DatabaseManager sharedInstance] getMapWithOrder:[NSNumber numberWithInt:mapOrder+1] forPackage:oldMapPackage];
    
    int minutes = elapsedSeconds / 60;
    int seconds = elapsedSeconds % 60;
    
    NSString *fileName1, *fileName2, *fileName3, *fileName4;
    
    if (minutes < 10) {
        fileName1 = @"youwin_num_0.png";
        fileName2 = [NSString stringWithFormat:@"youwin_num_%d.png",minutes];
    }
    else {
        fileName1 = [NSString stringWithFormat:@"youwin_num_%d.png",minutes/10];
        fileName2 = [NSString stringWithFormat:@"youwin_num_%d.png",minutes%10];
    }
    
    if (seconds < 10) {
        fileName3 = @"youwin_num_0.png";
        fileName4 = [NSString stringWithFormat:@"youwin_num_%d.png",seconds];
    }
    else {
        fileName3 = [NSString stringWithFormat:@"youwin_num_%d.png",seconds/10];
        fileName4 = [NSString stringWithFormat:@"youwin_num_%d.png",seconds%10];
    }
    
    gameWinView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1024.0, 768.0)];
    
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inapp_menu_frame.png"]];
    
    UIView *holderFrame = [[UIView alloc] initWithFrame:CGRectMake(350.0, 145.0, 327.0, 440.0)];
    
    UIImageView *star1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"youwin_star_passive.png"]];
    star1.frame = CGRectMake(40.0, 26.0, 80.0, 77.0);
    UIImageView *star2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"youwin_star_passive.png"]];
    star2.frame = CGRectMake(126.0, 0.0, 80.0, 77.0);
    UIImageView *star3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"youwin_star_passive.png"]];
    star3.frame = CGRectMake(212.0, 26.0, 80.0, 77.0);
    
    UIImageView *levelNumHolder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"youwin_mapnum.png"]];
    levelNumHolder.frame = CGRectMake(122.0, 80.0, 80.0, 75.0);
    
    UILabel *levelNum = [[UILabel alloc] initWithFrame:CGRectMake(140.0, 100.0, 45.0, 30.0)];
    [levelNum setBackgroundColor:[UIColor clearColor]];
    [levelNum setFont:[UIFont fontWithName:@"Helvetica-Bold" size:30]];
    [levelNum setTextAlignment:NSTextAlignmentCenter];
    [levelNum setTextColor:[UIColor colorWithRed:0.309 green:0.176 blue:0.0 alpha:1.0]];
    [levelNum setShadowColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.4]];
    [levelNum setShadowOffset:CGSizeMake(0, 1)];
    [levelNum setText:levelNumStr];
    
    UIImageView *rope1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"youwin_ayrac.png"]];
    rope1.frame = CGRectMake(0.0, 111.0, 327.0, 13.0);
    
    UIView *timerHolder = [[UIView alloc] initWithFrame:CGRectMake(39.0, 160.0, 252.0, 75.0)];
    UIImageView *num1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName1]];
    num1.frame = CGRectMake(0.0, 0.0, 57.0, 75.0);
    num1.transform = CGAffineTransformMakeScale(4.0, 4.0);
    num1.alpha = 0.0;
    
    UIImageView *num2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName2]];
    num2.frame = CGRectMake(57.0, 0.0, 57.0, 75.0);
    num2.transform = CGAffineTransformMakeScale(4.0, 4.0);
    num2.alpha = 0.0;
    
    UIImageView *dot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"youwin_num_nokta.png"]];
    dot.frame = CGRectMake(114.0, 0.0, 25.0, 75.0);
    
    UIImageView *num3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName3]];
    num3.frame = CGRectMake(138.0, 0.0, 57.0, 75.0);
    num3.transform = CGAffineTransformMakeScale(4.0, 4.0);
    num3.alpha = 0.0;
    
    UIImageView *num4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName4]];
    num4.frame = CGRectMake(195.0, 0.0, 57.0, 75.0);
    num4.transform = CGAffineTransformMakeScale(4.0, 4.0);
    num4.alpha = 0.0;
    
    UIImageView *rope2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"youwin_ayrac.png"]];
    rope2.frame = CGRectMake(0.0, 250.0, 327.0, 13.0);
    
    UIButton *mainMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    [mainMenu setFrame:CGRectMake(19.0, 263.0, 139.0, 55.0)];
    [mainMenu setBackgroundImage:[UIImage imageNamed:LocalizedImageName(@"youwin_mainmenu", @"png")] forState:UIControlStateNormal];
    [mainMenu setBackgroundImage:[UIImage imageNamed:LocalizedImageName(@"youwin_mainmenu_hover", @"png")] forState:UIControlStateHighlighted];
    [mainMenu addTarget:self action:@selector(returnToMainMenu) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *buttonsDot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"youwin_nokta.png"]];
    buttonsDot.frame = CGRectMake(153.0, 263.0, 20.0, 55.0);
    
    UIButton *nextGame = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextGame setFrame:CGRectMake(173.0, 263.0, 139.0, 55.0)];
    [nextGame setBackgroundImage:[UIImage imageNamed:LocalizedImageName(@"youwin_next", @"png")] forState:UIControlStateNormal];
    [nextGame setBackgroundImage:[UIImage imageNamed:LocalizedImageName(@"youwin_next_hover", @"png")] forState:UIControlStateHighlighted];
    if(newMap != nil){
        [nextGame addTarget:self action:@selector(nextGame) forControlEvents:UIControlEventTouchUpInside];
    }
    else{
        [nextGame setEnabled:NO];
    }
    
    UIButton *restartGame = [UIButton buttonWithType:UIButtonTypeCustom];
    [restartGame setFrame:CGRectMake(94.0, 308.0, 139.0, 55.0)];
    [restartGame setBackgroundImage:[UIImage imageNamed:LocalizedImageName(@"youwin_restart", @"png")] forState:UIControlStateNormal];
    [restartGame setBackgroundImage:[UIImage imageNamed:LocalizedImageName(@"youwin_restart_hover", @"png")] forState:UIControlStateHighlighted];
    [restartGame addTarget:self action:@selector(restartGame) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *rope3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"youwin_ayrac.png"]];
    rope3.frame = CGRectMake(0.0, 363.0, 327.0, 13.0);
    
    UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [faceButton setFrame:CGRectMake(100.0, 390.0, 50.0, 50.0)];
    [faceButton setBackgroundImage:[UIImage imageNamed:@"youwin_social_face.png"] forState:UIControlStateNormal];
    [faceButton setBackgroundImage:[UIImage imageNamed:@"youwin_social_face_hover.png"] forState:UIControlStateHighlighted];
    [faceButton addTarget:self action:@selector(shareOnFacebook) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *tweetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tweetButton setFrame:CGRectMake(179.0, 390.0, 50.0, 50.0)];
    [tweetButton setBackgroundImage:[UIImage imageNamed:@"youwin_social_tweet.png"] forState:UIControlStateNormal];
    [tweetButton setBackgroundImage:[UIImage imageNamed:@"youwin_social_tweet_hover.png"] forState:UIControlStateHighlighted];
    [tweetButton addTarget:self action:@selector(shareOnTwitter) forControlEvents:UIControlEventTouchUpInside];
    
    NSMutableArray *activeStars = [[NSMutableArray alloc] initWithCapacity:starCount];
    
    for ( int i = 0; i < starCount; i++) {
        CGFloat yOffset;
        if( i % 2 == 0) {
            yOffset = 0.0;
        }
        else{
            yOffset = -26.0;
        }
        UIImageView *activeStar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"youwin_star_active.png"]];
        activeStar.frame = CGRectMake(40.0+i*86, 26.0+yOffset, 80.0, 77.0);
        activeStar.transform = CGAffineTransformScale(activeStar.transform,0.01, 0.01);
        activeStar.alpha = 0.0;
        [activeStars addObject:activeStar];
    }
    
    [gameWinView addSubview:background];
    [holderFrame addSubview:star1];
    [holderFrame addSubview:star2];
    [holderFrame addSubview:star3];
    for ( int i = 0; i < starCount; i++){
        [holderFrame addSubview:[activeStars objectAtIndex:i]];
    }
    [holderFrame addSubview:rope1];
    [holderFrame addSubview:levelNumHolder];
    [holderFrame addSubview:levelNum];
    [timerHolder addSubview:num1];
    [timerHolder addSubview:num2];
    [timerHolder addSubview:dot];
    [timerHolder addSubview:num3];
    [timerHolder addSubview:num4];
    [holderFrame addSubview:timerHolder];
    [holderFrame addSubview:rope2];
    [holderFrame addSubview:mainMenu];
    [holderFrame addSubview:buttonsDot];
    [holderFrame addSubview:nextGame];
    [holderFrame addSubview:restartGame];
    [holderFrame addSubview:rope3];
    [holderFrame addSubview:faceButton];
    [holderFrame addSubview:tweetButton];
    [gameWinView addSubview:holderFrame];
    
    [[[CCDirector sharedDirector] view] addSubview:gameWinView];

    // opacities
    for ( int i = 0; i < starCount; i++){
        [[GreenTheGardenSoundManager sharedSoundManager] performSelector:@selector(playEffect:)
                                                              withObject:@"star"
                                                              afterDelay:1.7+i*0.5];
    }

    
    if (starCount == 0) {
        [self showRateUsAlert];
    }
    
    for ( int i = 0; i < starCount; i++){
        [UIView animateWithDuration:0.3 delay:1.2+i*0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [[activeStars objectAtIndex:i] setAlpha:1.0];
        } completion:^(BOOL finished) {

        }];
    }
    for ( int i = 0; i < starCount; i++){
        [UIView animateWithDuration:0.5 delay:1.2+i*0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGAffineTransform myTransform = CGAffineTransformConcat(CGAffineTransformMakeRotation(1.0), CGAffineTransformMakeScale(1.5, 1.5));
            ((UIView *)[activeStars objectAtIndex:i]).transform = myTransform;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            CGAffineTransform myTransform = CGAffineTransformConcat(CGAffineTransformMakeRotation(0.0), CGAffineTransformMakeScale(1.0, 1.0));
            ((UIView *)[activeStars objectAtIndex:i]).transform = myTransform;
            } completion:^(BOOL finished) {
                if (i == starCount-1) {
                    [self showRateUsAlert];
                }
            }];
        }];
    }
    [UIView animateWithDuration:0.8 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        num1.alpha = 1.0;
        num2.alpha = 1.0;
        num3.alpha = 1.0;
        num4.alpha = 1.0;
        num1.transform = CGAffineTransformMakeScale(1.0, 1.0);
        num2.transform = CGAffineTransformMakeScale(1.0, 1.0);
        num3.transform = CGAffineTransformMakeScale(1.0, 1.0);
        num4.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        ;
    }];

}
- (void) showRateUsAlert {
    
    NSArray *allMaps=[[DatabaseManager sharedInstance] getAllMaps];
    int finishedMaps=0;
    
    for (Map * map in allMaps){
        if(map.isFinished)
            finishedMaps++;
    }
    int lastAlert = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastRateUsAlertCount"];
    NSLog(@"last alert is at:%d, and finishedMaps is:%d",lastAlert,finishedMaps);
    if (finishedMaps >= lastAlert+10) {
        if (canShowRateUsAlert) {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:NSLocalizedString(@"RATE_US_TITLE", nil)
                                      message:NSLocalizedString(@"RATE_US_MESSAGE", nil)
                                      delegate:self
                                      cancelButtonTitle:nil
                                      otherButtonTitles:NSLocalizedString(@"RATE_US_RATE", nil),
                                                        NSLocalizedString(@"RATE_US_LATER", nil),
                                                        NSLocalizedString(@"RATE_US_DONT_SHOW_AGAIN", nil),nil];
            
            [alertView show];
            [[NSUserDefaults standardUserDefaults] setInteger:finishedMaps forKey:@"lastRateUsAlertCount"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView firstOtherButtonIndex]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"canShowRateUsAlert"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        canShowRateUsAlert = NO;
        
        NSString *str = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa";
        str = [NSString stringWithFormat:@"%@/wa/viewContentsUserReviews?", str];
        str = [NSString stringWithFormat:@"%@type=Purple+Software&id=", str];
        
        // Here is the app id from itunesconnect
        str = [NSString stringWithFormat:@"%@592099228", str];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    } else if (buttonIndex == [alertView firstOtherButtonIndex]+1) {
        canShowRateUsAlert = YES;
    } else if (buttonIndex == [alertView firstOtherButtonIndex]+2) {
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"canShowRateUsAlert"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        canShowRateUsAlert = NO;
    }
}
- (void) shareOnFacebook {
    [Flurry logEvent:kFlurryEventFacebookPostPressed
      withParameters:@{
            @"Map Order" : [NSNumber numberWithInt:_mapOrder],
            @"Difficulty" : [NSNumber numberWithInt:_difficulty],
            @"Star Count" : [NSNumber numberWithInt:_starCount],
            @"Elapsed Seconds" : [NSNumber numberWithInt:_elapsedSeconds]
     }];
    
    if ([[FBSession activeSession] state] == FBSessionStateOpen) {
        [self showFaceBookDialogWithAccessToken:[[FBSession activeSession] accessToken]
                              andExpirationDate:[[FBSession activeSession] expirationDate]];
    } else {
        [FBSession openActiveSessionWithPublishPermissions:@[@"publish_actions"]
                                           defaultAudience:FBSessionDefaultAudienceEveryone
                                              allowLoginUI:YES
                                         completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                             if (status != FBSessionStateOpen) {
                                                 // Show alert
                                                 UIAlertView *alertView = [[UIAlertView alloc]
                                                                           initWithTitle:NSLocalizedString(@"FACEBOOK_SESSION_NOT_OPEN_TITLE", nil)
                                                                           message:NSLocalizedString(@"FACEBOOK_SESSION_NOT_OPEN", nil)
                                                                           delegate:nil
                                                                           cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                                           otherButtonTitles:nil];
                                             
                                             [alertView show];
                                         } else {
                                             [self showFaceBookDialogWithAccessToken:[session accessToken]
                                                                   andExpirationDate:[session expirationDate]];
                                         }
                                     }];
    }
}

- (void) showFaceBookDialogWithAccessToken:(NSString *)accessToken
                         andExpirationDate:(NSDate *)expirationDate {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"name" : @"Green the Garden",
                                   @"caption" : NSLocalizedString(@"FACEBOOK_SHARE_CAPTION", nil),
                                   @"description" : [self prepareShareMessageForTwitter:NO],
                                   @"picture" : @"http://a1268.phobos.apple.com/us/r30/Purple2/v4/1d/6f/b1/1d6fb17c-b001-a53c-9250-967bc5922479/mzl.plgguvnt.170x170-75.png",
                                   @"link" : @"https://itunes.apple.com/us/app/green-the-garden/id592099228"}];
    
    
    // Invoke the dialog
    _facebook = [[Facebook alloc] initWithAppId:[FBSession defaultAppID] andDelegate:nil];
    _facebook.accessToken = accessToken;
    _facebook.expirationDate = expirationDate;
    [_facebook dialog:@"feed" andParams:params andDelegate:self];
}

- (void) dialogCompleteWithUrl:(NSURL*) url
{
    if ([url.absoluteString rangeOfString:@"post_id="].location != NSNotFound) {
        // user pressed "Send"
        [Flurry logEvent:kFlurryEventFacebookPostSent
          withParameters:@{
                @"Map Order" : [NSNumber numberWithInt:_mapOrder],
                @"Difficulty" : [NSNumber numberWithInt:_difficulty],
                @"Star Count" : [NSNumber numberWithInt:_starCount],
                @"Elapsed Seconds" : [NSNumber numberWithInt:_elapsedSeconds]
         }];
    } else {
        // user pressed "Cancel" button (although not the circle with X)
    }
}

- (NSString *)prepareShareMessageForTwitter:(BOOL)twitter {
    // Set the initial tweet text. See the framework for additional properties that can be set.
    MAP_DIFFICULTY difficulty = _difficulty;
    
    NSString *difficultyString;
    
    if (difficulty == EASY) {
        difficultyString = NSLocalizedString(@"TWEET_MAP_EASY", nil);
    } else if (difficulty == NORMAL) {
        difficultyString = NSLocalizedString(@"TWEET_MAP_NORMAL", nil);
    } else if (difficulty == HARD) {
        difficultyString = NSLocalizedString(@"TWEET_MAP_HARD", nil);
    } else if (difficulty == INSANE) {
        difficultyString = NSLocalizedString(@"TWEET_MAP_INSANSE", nil);
    }
    
    NSString *tweetString;
    
    if (_starCount == 0) {
        if (twitter) {
            tweetString = [NSString stringWithFormat:NSLocalizedString(@"TWEET_MESSAGE_NO_STAR", nil), difficultyString, _elapsedSeconds];
        } else {
            tweetString = [NSString stringWithFormat:NSLocalizedString(@"FACEBOOK_MESSAGE_NO_STAR", nil), difficultyString, _elapsedSeconds];
        }
    } else {
        NSString *localizedString = [NSString stringWithFormat:@"TWEET_%d_STAR", _starCount];
        NSString *starString = NSLocalizedString(localizedString , nil);
        NSString *formatString;
        if (twitter) {
            formatString = NSLocalizedString(@"TWEET_MESSAGE_WITH_STARS", nil);
        } else {
            formatString = NSLocalizedString(@"FACEBOOK_MESSAGE_WITH_STARS", nil);
        }
        
        tweetString = [NSString stringWithFormat:formatString, difficultyString, _elapsedSeconds, starString];
    }

    return [[[tweetString substringToIndex:1] uppercaseString] stringByAppendingString:[tweetString substringFromIndex:1]];
}

- (void) shareOnTwitter {
    [Flurry logEvent:kFlurryEventTweetPressed
      withParameters:@{
            @"Map Order" : [NSNumber numberWithInt:_mapOrder],
            @"Difficulty" : [NSNumber numberWithInt:_difficulty],
            @"Star Count" : [NSNumber numberWithInt:_starCount],
            @"Elapsed Seconds" : [NSNumber numberWithInt:_elapsedSeconds]
     }];
    
    TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
    
    
    [tweetViewController setInitialText:[self prepareShareMessageForTwitter:YES]];
    
    [tweetViewController addURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/green-the-garden/id592099228"]];
    
    // Create the completion handler block.
    [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
        UIAlertView *alertView;
        switch (result) {
            case TWTweetComposeViewControllerResultCancelled:
                // The cancel button was tapped.
                break;
            case TWTweetComposeViewControllerResultDone:
                // The tweet was sent.
                alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TWEET_SENT", nil)
                                                       message:nil
                                                      delegate:nil
                                             cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                             otherButtonTitles:nil];
                
                [alertView show];
                [Flurry logEvent:kFlurryEventTweetSent
                  withParameters:@{
                        @"Map Order" : [NSNumber numberWithInt:_mapOrder],
                        @"Difficulty" : [NSNumber numberWithInt:_difficulty],
                        @"Star Count" : [NSNumber numberWithInt:_starCount],
                        @"Elapsed Seconds" : [NSNumber numberWithInt:_elapsedSeconds]
                 }];
                break;
            default:
                break;
        }
        
        // Dismiss the tweet composition view controller.
        [[CCDirector sharedDirector] dismissModalViewControllerAnimated:YES];
    }];
    
    // Present the tweet composition view controller modally.
    [[CCDirector sharedDirector] presentModalViewController:tweetViewController animated:YES];
    
}
@end
