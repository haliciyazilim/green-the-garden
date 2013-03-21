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


@implementation MapSelectionLayer
{
    UIScrollView* scrollView;
    UIView *barView;
    UIImageView *leafView;
    UIImageView *maskView;
    UIImageView *logoView;
    CGSize unitSize;
    CGSize buttonSize;
    NSString* packageFileName;
    CGFloat topMargin;
    CGFloat contentPadding;
    UIImage* passiveStar;
    UIImage* activeStar;
    UIButton *unlockButton;
//    NSArray *_products;
    int rowCount;
    
    UIViewController * tempVC;
    UIView * backgroundUIView;
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

-(id) init
{
    if(self = [super init]){
        packageFileName = @"standart";
        //        CGSize size = [[CCDirector sharedDirector] winSize];
        buttonSize = CGSizeMake(111.0, 128.0);
        unitSize = CGSizeMake(120.0, 135.0);
        topMargin = 26.0;
        contentPadding = 400.0;
        rowCount = 3;
        passiveStar = [UIImage imageNamed:@"level_star_passive.png"];
        activeStar  = [UIImage imageNamed:@"level_star_active.png"];
        
        maskView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_selection_masklayer.png"]];
        
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 300.0, 1024.0, 400.0)];
        [scrollView setBackgroundColor:[UIColor colorWithWhite:255.0 alpha:0.5]];
        [scrollView setBackgroundColor:[UIColor clearColor]];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        
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


- (UIButton*) buttonForMap:(Map*)map atIndex:(int)index
{
    
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(
                                                                  (index/rowCount)*unitSize.width + (unitSize.width*0.5*(index%rowCount))+contentPadding+(index>=12?unitSize.width*0.5:0),
                                                           (index%rowCount)*unitSize.height,
                                                           buttonSize.width,
                                                           buttonSize.height)];
    button.tag = [map.mapId intValue];
    [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"map_%@_bg.png",stringOfDifficulty(map.difficulty)]] forState:UIControlStateNormal];
    
    BOOL isPassive = map.isLocked || !map.isPurchased;
    
    [scrollView addSubview:button];
    if(map.order < 10){
        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"level_num_%d.png",map.order]]];
        view.frame = CGRectMake((float)(buttonSize.width - view.image.size.width) * 0.5+5.0, topMargin, view.image.size.width, view.image.size.height);
        [button addSubview:view];
    }
    else{
        UIImageView* firstDigit  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"level_num_%d.png",map.order/10]]];
        UIImageView* secondDigit = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"level_num_%d.png",map.order%10]]];
        CGFloat width = firstDigit.image.size.width + secondDigit.image.size.width;
        firstDigit.frame  = CGRectMake((buttonSize.width - width) * 0.5 + 5.0, topMargin, firstDigit.image.size.width,firstDigit.image.size.height);
        secondDigit.frame = CGRectMake((buttonSize.width - width) * 0.5 + 5.0 + firstDigit.image.size.width, topMargin, secondDigit.image.size.width,secondDigit.image.size.height);
        [button addSubview:firstDigit];
        [button addSubview:secondDigit];
    }
    
    if(isPassive){
        UIImageView* passiveLayer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"map_%@_mask.png",stringOfDifficulty(map.difficulty)]]];
        [passiveLayer setAlpha:0.80];
        
        [button addSubview:passiveLayer];
        
        if(!map.isPurchased){
            [passiveLayer setAlpha:1.0];
            [button addTarget:self action:@selector(addStore) forControlEvents:UIControlEventTouchUpInside];
            UIImageView* lock = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"level_locked.png"]];
//            lock.image = [lock.image resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch];
            lock.frame = CGRectMake(buttonSize.width*0.5 - lock.image.size.width*0.5 + 5.0, buttonSize.height * 0.5 , lock.image.size.width, lock.image.size.height);
            [button addSubview:lock];
        }
        else if(map.isLocked){
//            UIImageView* lock = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"level_locked.png"]];
//            lock.frame = CGRectMake(buttonSize.width*0.5 - lock.image.size.width*0.5 + 5.0, buttonSize.height * 0.5 , lock.image.size.width , lock.image.size.height);
//            [button addSubview:lock];
            
        }
        
    }else {
        
        [button addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        
        if(map.isFinished){
//            int score = [map.score intValue];
//            NSLog(@"score: %d",score);
            for(int i=0;i<3;i++){
                UIImageView* view;
                if(i < [map getStarCount])
                    view = [[UIImageView alloc] initWithImage:activeStar];
                else
                    view = [[UIImageView alloc] initWithImage:passiveStar];
                view.frame = CGRectMake((buttonSize.width - passiveStar.size.width * 3) * 0.5 + 5.0 + passiveStar.size.width * i, buttonSize.height - passiveStar.size.height - 20.0, passiveStar.size.width, passiveStar.size.height);
                [button addSubview:view];
            }
        }
    }
    

    return button;
}

-(void) refreshScrollView
{
    for (UIView* view in scrollView.subviews) {
        if([view isKindOfClass:[UIButton class]]){
            [view removeFromSuperview];
        }
    }
    
    [self loadMapIcons];

    
}

- (void) loadMapIcons
{
    NSArray* maps = [ArrowGameMap loadMapsFromFile:@"standart"];
    
    
    [scrollView setContentSize:CGSizeMake(unitSize.width*ceil((float)maps.count/(float)rowCount)+unitSize.width*0.5+contentPadding*2.0, unitSize.height*rowCount)];
    [scrollView setFrame:CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.contentSize.height)];
    int index = 0;
    for (Map* map in maps) {
        [self buttonForMap:map atIndex:index];
        index++;
    }
//    [scrollView scrollRectToVisible:CGSizeMake([MapSelectionLayer getLastScroll], 0) animated:NO];
    [scrollView setContentOffset:CGPointMake([MapSelectionLayer getLastScroll], 0.0)];
    

}

- (void)onEnter{
    [self refreshScrollView];
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

-(void)onClick:(UIButton*)button
{
//    NSLog(@"button tag: %d",button.tag);
    self.isTouchEnabled = NO;
    [[TransitionManager sharedInstance] makeTransitionWithBlock:^{
        [MapSelectionLayer setLastScroll:scrollView.contentOffset.x];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[ArrowGameLayer sceneWithFile:[NSString stringWithFormat:@"%d",button.tag]] withColor:ccWHITE]];
        [scrollView removeFromSuperview];
        [maskView removeFromSuperview];
        [leafView removeFromSuperview];
        [barView removeFromSuperview];
        [logoView removeFromSuperview];
        [self removeFromParentAndCleanup:YES];

    }];
}

- (void) setPackage:(NSString*)package
{
    packageFileName = package;
}

- (void)productPurchased:(NSNotification *)notification {
    [unlockButton removeFromSuperview];
    [[DatabaseManager sharedInstance] updateMaps];
    [self refreshScrollView];
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
//        NSLog(@"show GameCenter");
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
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    UIImageView *backgroundImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inapp_menu_frame.png"]];
    backgroundUIView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, winSize.height)];
    
    
    UIImageView * background=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inapp_back.png" ]];
    CGFloat bgWidth=background.frame.size.width;
    CGFloat bgHeight=background.frame.size.height;
    
    UIButton * btnClose=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnClose setFrame:CGRectMake(bgWidth-55.0,10.0, 45.0, 45.0)];
    [btnClose setBackgroundImage:[UIImage imageNamed:@"inapp_btn_close.png"] forState:UIControlStateNormal];
    [btnClose setBackgroundImage:[UIImage imageNamed:@"inapp_btn_close_hover.png"] forState:UIControlStateHighlighted];
    [btnClose addTarget:self action:@selector(closeInfoScreen) forControlEvents:UIControlEventTouchUpInside];
    
       
    UIView * mask=[[UIView alloc]initWithFrame:CGRectMake(20, 40, bgWidth-40, bgHeight-80)];
    [mask setBackgroundColor:[UIColor clearColor]];
    mask.clipsToBounds=YES;

    
    UIView * credits=[[UIView alloc]initWithFrame:CGRectMake(0, mask.frame.size.width-80, mask.frame.size.width, winSize.height)];
    [credits setBackgroundColor:[UIColor clearColor]];
    
    float fontSizeL = 28.0;
    float fontSizeM = 24.0;
    NSString *font = @"Rabbit On The Moon";
    UIColor *color = [UIColor whiteColor];
    UIColor *color2 = [UIColor colorWithRed:0.702 green:1.0 blue:0.502 alpha:1.0];
    // Company Name
    UILabel * cName=[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0, credits.frame.size.width, 40.0)];
    [cName setFont:[UIFont fontWithName:font size:fontSizeL]];
    [cName setTextColor:[UIColor whiteColor]];
    [cName setShadowColor:[UIColor blackColor]];
    [cName setShadowOffset:CGSizeMake(1, 1)];
    [cName setTextAlignment:NSTextAlignmentCenter];
    [cName setBackgroundColor:[UIColor clearColor]];
    [cName setText:@"HALICI BİLGİ İŞLEM A.Ş."];
    
    // Adress
    UILabel * cAdress=[[UILabel alloc] initWithFrame:CGRectMake(0.0, 40, credits.frame.size.width, 120)];
    [cAdress setFont:[UIFont fontWithName:font size:fontSizeM]];
    [cAdress setTextColor:color2];
    [cAdress setTextAlignment:NSTextAlignmentCenter];
    [cAdress setBackgroundColor:[UIColor clearColor]];
    [cAdress setNumberOfLines:3];
    [cAdress setText:@"ODTÜ-Halıcı Yazılımevi \nİnönü Bulvarı 06531 \nODTÜ-Teknokent/ANKARA"];
    
    // Mail
    UILabel * cMail=[[UILabel alloc] initWithFrame:CGRectMake(0.0, 160, credits.frame.size.width, 40.0)];
    [cMail setFont:[UIFont fontWithName:font size:fontSizeM]];
    [cMail setTextColor:color2];
    [cMail setTextAlignment:NSTextAlignmentCenter];
    [cMail setBackgroundColor:[UIColor clearColor]];
    [cMail setText:@"iletisim@halici.com.tr"];
    
    
    // Programming
    UILabel * cProgramming=[[UILabel alloc] initWithFrame:CGRectMake(0.0, 240, credits.frame.size.width, 40.0)];
    [cProgramming setFont:[UIFont fontWithName:font size:fontSizeL]];
    [cProgramming setTextColor:color];
    [cProgramming setShadowColor:[UIColor blackColor]];
    [cProgramming setShadowOffset:CGSizeMake(1, 1)];
    [cProgramming setTextAlignment:NSTextAlignmentCenter];
    [cProgramming setBackgroundColor:[UIColor clearColor]];
    [cProgramming setText:NSLocalizedString(@"PROGRAMMING",nil)];
    
    
    // Names
    NSArray * names=[[NSArray alloc] initWithObjects:@"Eren HALICI",@"Yunus Eren GÜZEL", @"Abdullah KARACABEY",@"Alperen KAVUN", nil];
    for(int i=0; i<names.count;i++){
        UILabel * cName=[[UILabel alloc] initWithFrame:CGRectMake(0.0, 300+i*40, credits.frame.size.width, 40.0)];
        [cName setFont:[UIFont fontWithName:font size:fontSizeM]];
        [cName setTextColor:color2];
        [cName setTextAlignment:NSTextAlignmentCenter];
        [cName setBackgroundColor:[UIColor clearColor]];
        [cName setNumberOfLines:2];
        [cName setText:names[i]];
        [credits addSubview:cName];
    }
    

    // Art
    UILabel * cArt=[[UILabel alloc] initWithFrame:CGRectMake(0.0, 500, credits.frame.size.width, 40.0)];
    [cArt setFont:[UIFont fontWithName:font size:fontSizeL]];
    [cArt setTextColor:color];
    [cArt setShadowColor:[UIColor blackColor]];
    [cArt setShadowOffset:CGSizeMake(1, 1)];
    [cArt setTextAlignment:NSTextAlignmentCenter];
    [cArt setBackgroundColor:[UIColor clearColor]];
    [cArt setText:NSLocalizedString(@"ART", nil)];
    
    UILabel * cArtName=[[UILabel alloc] initWithFrame:CGRectMake(0.0, 540, credits.frame.size.width, 40.0)];
    [cArtName setFont:[UIFont fontWithName:@"Rabbit On The Moon" size:fontSizeM]];
    [cArtName setTextColor:color2];
    [cArtName setTextAlignment:NSTextAlignmentCenter];
    [cArtName setBackgroundColor:[UIColor clearColor]];
    [cArtName setNumberOfLines:2];
    [cArtName setText:@"Ebuzer Egemen DURSUN"];
    
    
    // Music
    UILabel * cMusic=[[UILabel alloc] initWithFrame:CGRectMake(0.0, 620, credits.frame.size.width, 40.0)];
    [cMusic setFont:[UIFont fontWithName:font size:fontSizeL]];
    [cMusic setTextColor:color];
    [cMusic setShadowColor:[UIColor blackColor]];
    [cMusic setShadowOffset:CGSizeMake(1, 1)];
    [cMusic setTextAlignment:NSTextAlignmentCenter];
    [cMusic setBackgroundColor:[UIColor clearColor]];
    [cMusic setText:NSLocalizedString(@"MUSIC", nil)];
    
    NSArray * namesMusic=[[NSArray alloc] initWithObjects:@"Onur IŞIKLI",@"Eren HALICI", nil];
    for(int i=0; i<namesMusic.count;i++){
        UILabel * cName=[[UILabel alloc] initWithFrame:CGRectMake(0.0, 660+i*40, credits.frame.size.width, 40.0)];
        [cName setFont:[UIFont fontWithName:font size:fontSizeM]];
        [cName setTextColor:color2];
        [cName setTextAlignment:NSTextAlignmentCenter];
        [cName setBackgroundColor:[UIColor clearColor]];
        [cName setNumberOfLines:2];
        [cName setText:namesMusic[i]];
        [credits addSubview:cName];
    }
    

    // Copyright
    UILabel * cCRight=[[UILabel alloc] initWithFrame:CGRectMake(0.0, 860, credits.frame.size.width, 40.0)];
    [cCRight setFont:[UIFont fontWithName:font size:fontSizeL]];
    [cCRight setTextColor:color];
    [cCRight setShadowColor:[UIColor blackColor]];
    [cCRight setShadowOffset:CGSizeMake(1, 1)];
    [cCRight setTextAlignment:NSTextAlignmentCenter];
    [cCRight setBackgroundColor:[UIColor clearColor]];
    [cCRight setText:@"Copyright © 2013"];

    

    [credits addSubview:cName];
    [credits addSubview:cAdress];
    [credits addSubview:cMail];
    [credits addSubview:cProgramming];
    [credits addSubview:cArt];
    [credits addSubview:cArtName];
    [credits addSubview:cMusic];
    [credits addSubview:cCRight];
    [mask addSubview:credits];
    
    UIView * infoScreen=[[UIView alloc] initWithFrame:CGRectMake((winSize.width-bgWidth)/2, (winSize.height-bgHeight)/2, bgWidth, bgHeight)];
//    infoScreen.clipsToBounds=YES;
    [infoScreen setBackgroundColor:[UIColor clearColor]];
    
    [infoScreen addSubview:background];
    [infoScreen addSubview:mask];
    [infoScreen addSubview:btnClose];
    
    [backgroundUIView addSubview:backgroundImgView];
    [backgroundUIView addSubview:infoScreen];
    [[[CCDirector sharedDirector] view]addSubview:backgroundUIView];
    
//    cName.transform=CGAffineTransformMakeTranslation(0, 0);
//    CGRect frame=cName.frame;
//    frame.origin.y=550.0;
//    cName.frame=frame;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:30.0f];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector(closeInfoScreen)];
    
    CGAffineTransform transform=CGAffineTransformMakeTranslation(0, -1050);
    credits.transform=transform;
    [UIView commitAnimations];
}



-(void)closeInfoScreen{
    [backgroundUIView removeFromSuperview];
    
    [Flurry endTimedEvent:kFlurryEventInfoScreenView withParameters:nil];
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
