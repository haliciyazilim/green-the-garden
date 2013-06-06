//
//  LoadingLayer.m
//  Green The Garden
//
//  Created by Alperen Kavun on 05.06.2013.
//
//

#import "LoadingLayer.h"
#import "Util.h"

@implementation LoadingLayer
{
    UIView* loadingBarHolder;
    UIImageView* progressView;
    UILabel* loadingLabel;
    NSArray* randomStrings;
    UILabel* loadingString;
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
    
    [[[NSThread alloc] initWithTarget:[ArrowGameMap class] selector:@selector(configureDatabase) object:nil] start];
}

- (void) initLoadingBar {
    loadingBarHolder = [[UIView alloc] initWithFrame:CGRectMake((1024.0-182.0)*0.5, 614.0, 182.0, 10.0)];
    UIImageView* backView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"progressbar_bg.png"]];
    [loadingBarHolder addSubview:backView];
    [loadingBarHolder.layer setCornerRadius:5.0];
    [loadingBarHolder.layer setBorderColor:[[UIColor colorWithRed:12.0/255.0 green:15.0/255.0 blue:18.0/255.0 alpha:1.0] CGColor]];
    [loadingBarHolder.layer setBorderWidth:1.0];
    
    progressView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"progressbar_yesil.jpg"]];
    [progressView setFrame:CGRectMake(1.0-180.0, 1.0, progressView.frame.size.width, progressView.frame.size.height)];
    [loadingBarHolder addSubview:progressView];
    [loadingBarHolder setClipsToBounds:YES];
    
    loadingString = [[UILabel alloc] initWithFrame:CGRectMake((1024.0-182.0)*0.5, 580.0, 182.0, 30.0)];
    [loadingString setBackgroundColor:[UIColor clearColor]];
    [loadingString setFont:[UIFont fontWithName:@"Rabbit On The Moon" size:14.0]];
    [loadingString setTextColor:[UIColor colorWithRed:5.0/255.0 green:62.0/255.0 blue:6.0/255.0 alpha:1.0]];
    [loadingString.layer setShadowOffset:CGSizeMake(0.0, 1.0)];
    [loadingString.layer setShadowColor:[[UIColor colorWithWhite:1.0 alpha:0.4] CGColor]];
    [loadingString setTextAlignment:NSTextAlignmentCenter];
    [loadingString setText:@""];
    
    [[[CCDirector sharedDirector] view] addSubview:loadingBarHolder];
    [[[CCDirector sharedDirector] view] addSubview:loadingString];
    
    randomStrings = [[Util sharedInstance] getRandomStringsWithCapacity:5];
    
}
- (void) updateLoadingBarWithPercentage:(NSNumber*)perc {

    CGFloat percentage = [perc floatValue];
    
    if (percentage > 0.0) {
        [progressView setFrame:CGRectMake(1.0-(180.0*(1-percentage)), 1.0, progressView.frame.size.width, progressView.frame.size.height)];
        if (percentage < 0.2) {
            [loadingString setText:[randomStrings objectAtIndex:0]];
        } else if (percentage < 0.4) {
            [loadingString setText:[randomStrings objectAtIndex:1]];
        } else if (percentage < 0.6) {
            [loadingString setText:[randomStrings objectAtIndex:2]];
        } else if (percentage < 0.8) {
            [loadingString setText:[randomStrings objectAtIndex:3]];
        } else {
            [loadingString setText:[randomStrings objectAtIndex:4]];
        }
    }
    
    if (percentage == 1.0) {
        [self performSelector:@selector(makeTransition) withObject:nil afterDelay:0.5];
    }
}

-(void) makeTransition
{
    [loadingBarHolder removeFromSuperview];
    [loadingString removeFromSuperview];
    loadingBarHolder = nil;
    loadingString = nil;
    self.isTouchEnabled = NO;
    [self removeFromParentAndCleanup:YES];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MainGameLayer scene] withColor:ccWHITE]];
}
@end
