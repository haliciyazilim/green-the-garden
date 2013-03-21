//
//  MainGameLayer.m
//  OkParcalari
//
//  Created by Alperen Kavun on 24.12.2012.
//
//

#import "MainGameLayer.h"
#import "GameCenterManager.h"
#import "GreenTheGardenIAPHelper.h"
#import "Util.h"
#import "CCBReader.h"
#import "CCBAnimationManager.h"
//#import "Util.h"

#import "AchievementManager.h"
#import "GreenTheGardenGCSpecificValues.h"
#import "TransitionManager.h"

@implementation MainGameLayer{
    CCSprite *newGameButton;
    CCLabelTTF *tapToStart;
    NSArray *_products;
}

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainGameLayer *gameLayer = [MainGameLayer node];
	
	// add layer as a child to scene
	[scene addChild:gameLayer];
	
	// return the scene
	return scene;
}

- (void)onEnter{
    [super onEnter];
    CGSize size = [[CCDirector sharedDirector] winSize];
    [[GameCenterManager sharedInstance] authenticateLocalUser];
    
    [AchievementManager sharedAchievementManager];
    
    CCLayerColor *colorLayer = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 255)];
    colorLayer.position = ccp(size.width*0.0,size.height*0.0);
    
    CCLayer *backLayer = (CCLayer *)[CCBReader nodeGraphFromFile:@"mainLayer.ccbi"];
    backLayer.position = ccp(size.width*0.0, size.height*0.0);
    
    [self addChild:colorLayer];
    [self addChild:backLayer];
    [self scheduleOnce:@selector(addLogo:) delay:2.0];
    [self scheduleOnce:@selector(addTapToStart) delay:2.25];
    
}
- (void) addTapToStart {
    CGSize size = [[CCDirector sharedDirector] winSize];
    tapToStart = [CCLabelTTF labelWithString:NSLocalizedString(@"TAP_TO_START", nil) fontName:@"Futura-Medium" fontSize:24.0];
    tapToStart.position = ccp(size.width * 0.5,size.height * 0.15);
    [self addChild:tapToStart z:1999];
    [self schedule:@selector(fadeOutTap) interval:0.5 repeat:0 delay:0.0];
    self.isTouchEnabled = YES;
}
- (void) fadeOutTap {
    [self unschedule:@selector(fadeOutTap)];
    CCFadeTo *fadeTo = [CCFadeTo actionWithDuration:0.5];
    [tapToStart runAction:fadeTo];
    [self schedule:@selector(fadeInTap) interval:0.5 repeat:0 delay:0.0];
}
- (void) fadeInTap {
    [self unschedule:@selector(fadeInTap)];
    CCFadeIn *fadeIn = [CCFadeIn actionWithDuration:0.5];
    [tapToStart runAction:fadeIn];
    [self schedule:@selector(fadeOutTap) interval:0.5 repeat:0 delay:0.0];
}

- (void) addLogo:(ccTime)dt {
    CGSize size = [[CCDirector sharedDirector] winSize];
    CCLayer *logoLayer = (CCLayer *)[CCBReader nodeGraphFromFile:@"LOGOAnimation.ccbi"];
    logoLayer.position = ccp(size.width*0.74, size.height*0.75);
    [self addChild:logoLayer];
}

-(id) init
{
    if(self = [super init]){
    }
    return self;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self makeTransition];
}

- (void) buyButtonTapped {
    SKProduct *product = [_products objectAtIndex:0];
    
//    NSLog(@"Buying %@...", product.productIdentifier);
    [[GreenTheGardenIAPHelper sharedInstance] buyProduct:product];
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(CGPoint)pointFromTouches:(NSSet*) touches
{
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:[touch view]];
    point = [[CCDirector sharedDirector] convertToGL:point];
    return point;
}

-(void) makeTransition
{
    self.isTouchEnabled = NO;
    [[TransitionManager sharedInstance] makeTransitionWithBlock:^{
        [self removeFromParentAndCleanup:YES];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[MapSelectionLayer scene] withColor:ccWHITE]];
    }];
}

@end
