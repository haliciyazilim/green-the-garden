//
//  TransitionManager.m
//  GreenTheGarden
//
//  Created by Alperen Kavun on 28.01.2013.
//
//

#import "TransitionManager.h"
#import "MapSelectionLayer.h"

#import "GreenTheGardenGCSpecificValues.h"
#import "GreenTheGardenIAPHelper.h"
#import "Flurry.h"
#import "FlurryAds.h"

@implementation TransitionManager
{
    TransitionBlock transition;
    UIImageView *transitionImage;
    UIImageView *transitionImage2;
    UIImageView *transitionImage3;
    
    int adCountDown;
}

static TransitionManager* currentInstance = nil;

+ (TransitionManager *)sharedInstance
{
    if(currentInstance == nil){
        currentInstance = [[TransitionManager alloc] init];
    }
    
    return currentInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        adCountDown = arc4random_uniform(kAdRepeatMax - kAdRepeatMin) + kAdRepeatMin - 1;
        
        [FlurryAds fetchAdForSpace:@"GreenTheGardenTransition2"
                             frame:[CCDirector sharedDirector].view.frame
                              size:FULLSCREEN];
    }
    return self;
}

- (void) makeTransitionWithBlock:(TransitionBlock)transitionBlock {
    [Flurry logPageView];
    transition = transitionBlock;
    
    [[[CCDirector sharedDirector] view] setUserInteractionEnabled:NO];
    
    transitionImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 768.0, 1024.0, 768.0)];
    [transitionImage setImage:[UIImage imageNamed:@"transition_leafs.png"]];
    transitionImage.layer.zPosition = 999.0;
    
    transitionImage2 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -768.0, 1024, 768.0)];
    [transitionImage2 setImage:[UIImage imageNamed:@"transition_leafs.png"]];
    [transitionImage2 setTransform:CGAffineTransformMakeRotation(M_PI)];
    transitionImage2.layer.zPosition = 998.0;
    
    transitionImage3 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1024.0, 768.0)];
    [transitionImage3 setImage:[UIImage imageNamed:@"transition_grass.jpg"]];
    transitionImage3.alpha = 0.0;
    transitionImage3.layer.zPosition = 997.0;
    
    [[[CCDirector sharedDirector] view] addSubview:transitionImage];
    [[[CCDirector sharedDirector] view] addSubview:transitionImage2];
    [[[CCDirector sharedDirector] view] addSubview:transitionImage3];
    [UIView animateWithDuration:1.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        transitionImage.frame = CGRectMake(0.0, 0.0, 1024.0, 768.0);
        transitionImage2.frame = CGRectMake(0.0, 0.0, 1024.0, 768.0);
        transitionImage3.alpha = 1.0;
    } completion:^(BOOL finished) {
        if ([[GreenTheGardenIAPHelper sharedInstance] isPro]){
            [self performRealTransition];
        } else {
            if (adCountDown == 0) {
                if ([FlurryAds adReadyForSpace:@"GreenTheGardenTransition2"]) {
                    adCountDown = arc4random_uniform(kAdRepeatMax - kAdRepeatMin) + kAdRepeatMin - 1;
                    [FlurryAds displayAdForSpace:@"GreenTheGardenTransition2"
                                          onView:[CCDirector sharedDirector].view];
                    [FlurryAds setAdDelegate:self];
                    
                } else {
                    adCountDown = 0;
                    [FlurryAds fetchAdForSpace:@"GreenTheGardenTransition2"
                                         frame:[CCDirector sharedDirector].view.frame
                                          size:FULLSCREEN];
                    [self performRealTransition];
                }
                
            } else {
                adCountDown--;
                [self performRealTransition];
            }
        }
        
    }];

}

- (BOOL) spaceShouldDisplay:(NSString*)adSpace interstitial:(BOOL)
interstitial {
    if (interstitial) {
        // Pause app state here
    }
    
    // Continue ad display
    return YES;
}

- (void)spaceDidDismiss:(NSString *)adSpace interstitial:(BOOL)interstitial {
    if (interstitial) {
        // Resume app state here
        
        [FlurryAds fetchAdForSpace:@"GreenTheGardenTransition2"
                             frame:[CCDirector sharedDirector].view.frame
                              size:FULLSCREEN];

        [self performRealTransition];
    }
}


- (void) openTransitionLayers {
    [UIView animateWithDuration:1.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        transitionImage.frame = CGRectMake(0.0, 768.0, 1024.0, 768.0);
        transitionImage2.frame = CGRectMake(0.0, -768.0, 1024.0, 768.0);
        transitionImage3.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transitionImage removeFromSuperview];
        [transitionImage2 removeFromSuperview];
        [transitionImage3 removeFromSuperview];
        transitionImage = nil;
        transitionImage2 = nil;
        transitionImage3 = nil;
        [[[CCDirector sharedDirector] view] setUserInteractionEnabled:YES];
    }];
}

- (void) performRealTransition{
    transition();
    [self openTransitionLayers];
}

- (void)dealloc {
    [FlurryAds setAdDelegate:nil];
}

@end
