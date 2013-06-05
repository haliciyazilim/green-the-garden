//
//  LoadingLayer.m
//  Green The Garden
//
//  Created by Alperen Kavun on 05.06.2013.
//
//

#import "LoadingLayer.h"

@implementation LoadingLayer
{
    UIView* loadingBarHolder;
    UIImageView* progressView;
}

static LoadingLayer* lastInstance = nil;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	LoadingLayer *loadingLayer = [LoadingLayer node];
	
	// add layer as a child to scene
	[scene addChild:loadingLayer];
	
	// return the scene
	return scene;
}

+ (LoadingLayer *) lastInstance {
    if (lastInstance) {
        return lastInstance;
    }
    
    return nil;

}

-(id) init
{
    if(self = [super init]){
        lastInstance = self;
    }
    return self;
}

- (void) onEnter {
    [super onEnter];
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    CCSprite *backSprite = [CCSprite spriteWithFile:@"Default-Landscape.png"];
    backSprite.position = ccp(size.width*0.5,size.height*0.5);
    
    [self addChild:backSprite];
    
    self.isTouchEnabled = YES;
    
    [self initLoadingBar];
    
    // loadingView start
    // database()
    
}
- (void) initLoadingBar {
    loadingBarHolder = [[UIView alloc] initWithFrame:CGRectMake((1024.0-182.0)*0.5, 600.0, 182.0, 10.0)];
    UIImageView* backView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"progressbar_bg.png"]];
    [loadingBarHolder addSubview:backView];
    [loadingBarHolder.layer setCornerRadius:5.0];
    [loadingBarHolder.layer setBorderColor:[[UIColor colorWithRed:12.0/255.0 green:15.0/255.0 blue:18.0/255.0 alpha:1.0] CGColor]];
    [loadingBarHolder.layer setBorderWidth:1.0];
    
    progressView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"progressbar_yesil.jpg"]];
    [progressView setFrame:CGRectMake(1.0-180.0, 1.0, progressView.frame.size.width, progressView.frame.size.height)];
    [loadingBarHolder addSubview:progressView];
    [loadingBarHolder setClipsToBounds:YES];
    
    [[[CCDirector sharedDirector] view] addSubview:loadingBarHolder];
}
- (void) updateLoadingBarWithPercentage:(float)percentage {
    
    if (percentage > 0.0) {
        [progressView setFrame:CGRectMake(1.0-(180.0*(1-percentage)), 1.0, progressView.frame.size.width, progressView.frame.size.height)];
    }
    
    if (percentage == 1.0) {
        [self makeTransition];
    }
}

-(void) makeTransition
{
    [loadingBarHolder removeFromSuperview];
    loadingBarHolder = nil;
    self.isTouchEnabled = NO;
    [self removeFromParentAndCleanup:YES];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MainGameLayer scene] withColor:ccWHITE]];
}
@end
