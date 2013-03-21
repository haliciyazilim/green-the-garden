//
//  InGameMenuLayer.m
//  OkParcalari
//
//  Created by Alperen Kavun on 03.01.2013.
//
//

#import "InGameMenuLayer.h"
#import "ArrowGameLayer.h"
#import "Util.h"

#define RESTART_APPROVE_ALERTVIEW_TAG 4
#define MAIN_MENU_APPROVE_ALERTVIEW_TAG 5

@implementation InGameMenuLayer
{
    UIButton *menuItem1;
    UIButton *menuItem2;
    UIButton *menuItem3;
//    UIButton *menuItem4;
    BOOL isRestaurantForAlert;
}

- (id) initWithRestaurant:(BOOL)isRestaurant {
    if (self = [super init]) {
        CGSize size = [[CCDirector sharedDirector] winSize];
        CGFloat top = size.height*0.5;
        CGFloat left = 412.0;
        isRestaurantForAlert = isRestaurant;
        
        CCSprite *background = [CCSprite spriteWithFile:@"ingame_menu_frame_Nopaque.png"];
        background.position = ccp(size.width * 0.5, size.height * 0.5);
        
        CCSprite *win = [CCSprite spriteWithFile:@"YOU_WIN.png"];
        win.position = ccp(size.width * 0.5, size.height * 0.5);
        
        CCSprite *menuFrame = [CCSprite spriteWithFile:@"ingame_menu_btnbg.png"];
        menuFrame.position = ccp(size.width * 0.5+4.0, size.height * 0.5-4.0);
        
        
        menuItem1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuItem1 setFrame:CGRectMake(left, top-103.0, 206, 66.0)];
        [menuItem1 setBackgroundImage:[UIImage imageNamed:LocalizedImageName(@"ingamebtn_resume", @"png")] forState:UIControlStateNormal];
        [menuItem1 setBackgroundImage:[UIImage imageNamed:LocalizedImageName(@"ingamebtn_resume_hover", @"png")] forState:UIControlStateHighlighted];
        
        if(!isRestaurant){
            [menuItem1 addTarget:self
                         action:@selector(resumeGame)
               forControlEvents:UIControlEventTouchUpInside];
        }
        else{
            [menuItem1 setEnabled:NO];
        }
        
        menuItem2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuItem2 setFrame:CGRectMake(left, top-33.0, 206, 66.0)];
        [menuItem2 setBackgroundImage:[UIImage imageNamed:LocalizedImageName(@"ingamebtn_restart", @"png")] forState:UIControlStateNormal];
        [menuItem2 setBackgroundImage:[UIImage imageNamed:LocalizedImageName(@"ingamebtn_restart_hover", @"png")] forState:UIControlStateHighlighted];
        
        [menuItem2 addTarget:self
                      action:@selector(restartGameApprove)
            forControlEvents:UIControlEventTouchUpInside];
        
        menuItem3 = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuItem3 setFrame:CGRectMake(left, top+37.0, 206.0, 66.0)];
        [menuItem3 setBackgroundImage:[UIImage imageNamed:LocalizedImageName(@"ingamebtn_mainmenu", @"png")] forState:UIControlStateNormal];
        [menuItem3 setBackgroundImage:[UIImage imageNamed:LocalizedImageName(@"ingamebtn_mainmenu_hover", @"png")] forState:UIControlStateHighlighted];
        
        [menuItem3 addTarget:self
                      action:@selector(returnToMainMenuApprove)
            forControlEvents:UIControlEventTouchUpInside];
        
        [self addChild:background];
//        [self addChild:win];
        [self addChild:menuFrame];
        if(isRestaurant){
            CCSprite *congrat = [CCSprite spriteWithFile:LocalizedImageName(@"congratulation", @"png")];
            congrat.position = ccp(size.width*0.5,size.height*0.8);
            [self addChild:congrat];
        }
        
        [[[CCDirector sharedDirector] view] addSubview:menuItem1];
        [[[CCDirector sharedDirector] view] addSubview:menuItem2];
        [[[CCDirector sharedDirector] view] addSubview:menuItem3];
//        [[[CCDirector sharedDirector] view] addSubview:menuItem4];
        
        self.isTouchEnabled = YES;
    }
    return self;
}
- (void) onEnter {
    [super onEnter];
}

- (void) removeAllButtons {
    [menuItem1 removeFromSuperview];
    [menuItem2 removeFromSuperview];
    [menuItem3 removeFromSuperview];
//    [menuItem4 removeFromSuperview];
    menuItem1 = nil;
    menuItem2 = nil;
    menuItem3 = nil;
//    menuItem4 = nil;
}
- (void) resumeGame {
    [self removeAllButtons];
    [(ArrowGameLayer *)self.callerLayer inGameMenuWillClose];
    [self removeFromParentAndCleanup:YES];
}
- (void) restartGameApprove {
    if(!isRestaurantForAlert){
        UIAlertView *restartApprove = [[UIAlertView alloc] initWithTitle:@""
                                                                   message:NSLocalizedString(@"RESTART_APPROVE", nil)
                                                                  delegate:self
                                                         cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                                         otherButtonTitles:NSLocalizedString(@"OK", nil),nil];
        [restartApprove setTag:RESTART_APPROVE_ALERTVIEW_TAG];
        [restartApprove show];
    }
}
- (void) returnToMainMenuApprove {
    if(!isRestaurantForAlert){
        UIAlertView *mainMenuApprove = [[UIAlertView alloc] initWithTitle:@""
                                                                 message:NSLocalizedString(@"MAIN_MENU_APPROVE", nil)
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                                       otherButtonTitles:NSLocalizedString(@"OK", nil),nil];
        [mainMenuApprove setTag:MAIN_MENU_APPROVE_ALERTVIEW_TAG];
        [mainMenuApprove show];
    }
}
- (void) restartGame {
    [self removeAllButtons];
    [(ArrowGameLayer *)self.callerLayer restartGame];
    [self removeFromParentAndCleanup:YES];
}
- (void) returnToMainMenu {
    [self removeAllButtons];
    [(ArrowGameLayer *)self.callerLayer returnToMainMenu];
    [self removeFromParentAndCleanup:YES];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == RESTART_APPROVE_ALERTVIEW_TAG){
        if (buttonIndex != [alertView cancelButtonIndex]){
            [self restartGame];
        }
    }
    else if(alertView.tag == MAIN_MENU_APPROVE_ALERTVIEW_TAG){
        if (buttonIndex != [alertView cancelButtonIndex]) {
            [self returnToMainMenu];
        }
    }
}

@end
