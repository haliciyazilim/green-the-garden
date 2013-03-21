//
//  GreenTheGardenIAPHelper.m
//  GreenTheGarden
//
//  Created by Alperen Kavun on 10.01.2013.
//


#import "Flurry.h"
#import "DatabaseManager.h"
#import "Map.h"

#import "GreenTheGardenIAPHelper.h"
#import "MapSelectionLayer.h"
#import "GreenTheGardenIAPSpecificValues.h"
#import "AchievementManager.h"
#import "GreenTheGardenGCSpecificValues.h"

@implementation GreenTheGardenIAPHelper
{
    UIView *storeView;
    UILabel *descriptionLabel;
    UILabel *headerLabel;
    UILabel *priceLabel;
    UIButton *buyButton;
    UIButton *restoreButton;
    BOOL isClosed;
    BOOL isAlertShown;
}
+ (GreenTheGardenIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static GreenTheGardenIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSDictionary *products = @{iProUpgradeKey : iProUpgradeSecret};
        sharedInstance = [[self alloc] initWithProductsDictionary:products];
        [[NSNotificationCenter defaultCenter] addObserver:sharedInstance selector:@selector(productPurchaseCompleted:) name:IAPHelperProductPurchasedNotification object:nil];
    });
    return sharedInstance;
}
- (void)productPurchaseCompleted:(NSNotification *)notif {
    [self closeStore];
    if(!isAlertShown){
        UIAlertView *productPurchased = [[UIAlertView alloc] initWithTitle:@""
                                                                   message:NSLocalizedString(@"PRODUCT_PURCHASED", nil)
                                                                  delegate:self
                                                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                         otherButtonTitles:nil,nil];
        [productPurchased show];
        isAlertShown = YES;
        
        int count = 0;
        for (Map *map in [[DatabaseManager sharedInstance] getAllMaps]) {
            
            if ([map isFinished]) {
                count++;
            }
        }
        
        [[AchievementManager sharedAchievementManager] submitAchievement:kAchievementBeAPro percentComplete:100.00];
        
        [Flurry logEvent:kFlurryEventUnlockFullGame
          withParameters:@{@"Solved Map Count" : [NSNumber numberWithInt:count]}];
    }
}
- (void) createStore {
    isAlertShown = NO;
    isClosed = NO;
    storeView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1024.0, 768.0)];
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activity setColor:[UIColor blackColor]];
    [activity setHidesWhenStopped:YES];
    [activity startAnimating];
    activity.frame = CGRectMake(241.0, 115.0, 60.0, 60.0);
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inapp_menu_frame.png"]];
    UIImageView *backView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inapp_back.png"]];
    [backView setFrame:CGRectMake(322.0, 231.0, 425.0, 350.0)];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setFrame:CGRectMake(690.0, 240.0, 45.0, 45.0)];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"inapp_btn_close.png"] forState:UIControlStateNormal];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"inapp_btn_close_hover.png"] forState:UIControlStateHighlighted];
    [closeButton addTarget:self action:@selector(closeStore) forControlEvents:UIControlEventTouchUpInside];
    
    buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [buyButton setFrame:CGRectMake(550.0, 470.0, 148.0, 69.0)];
    [buyButton setBackgroundImage:[UIImage imageNamed:LocalizedImageName(@"inapp_btn_buynow", @"png")] forState:UIControlStateNormal];
    [buyButton setBackgroundImage:[UIImage imageNamed:LocalizedImageName(@"inapp_btn_buynow_hover", @"png")] forState:UIControlStateHighlighted];
    
    restoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [restoreButton setFrame:CGRectMake(370.0, 470.0, 148.0, 69.0)];
    [restoreButton setBackgroundImage:[UIImage imageNamed:LocalizedImageName(@"inapp_btn_purchase", @"png")] forState:UIControlStateNormal];
    [restoreButton setBackgroundImage:[UIImage imageNamed:LocalizedImageName(@"inapp_btn_purchase_hover", @"png")] forState:UIControlStateHighlighted];

    UIImageView *unlockImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inapp_image.png"]];
    [unlockImage setFrame:CGRectMake(380.0, 285.0, 118.0, 137.0)];

    headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(510.0, 280.0, 180.0, 40.0)];
    [headerLabel setFont:[UIFont fontWithName:@"Rabbit On The Moon" size:28.0]];
    [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel setShadowColor:[UIColor blackColor]];
    [headerLabel setShadowOffset:CGSizeMake(1.0, 1.0)];
    [headerLabel setBackgroundColor:[UIColor clearColor]];
    [headerLabel setTextAlignment:NSTextAlignmentLeft];
    [headerLabel setText:@""];
    
    descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(510.0, 320.0, 180.0, 130.0)];
    [descriptionLabel setFont:[UIFont fontWithName:@"Rabbit On The Moon" size:18.0]];
    [descriptionLabel setTextColor:[UIColor colorWithRed:0.702 green:1.0 blue:0.502 alpha:1.0]];
    [descriptionLabel setBackgroundColor:[UIColor clearColor]];
    [descriptionLabel setTextAlignment:NSTextAlignmentLeft];
    [descriptionLabel setNumberOfLines:6];
    [descriptionLabel setText:@""];
    
    priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(400.0, 430.0, 120.0, 40.0)];
    [priceLabel setFont:[UIFont fontWithName:@"Rabbit On The Moon" size:24.0]];
    [priceLabel setBackgroundColor:[UIColor clearColor]];
    [priceLabel setTextColor:[UIColor whiteColor]];
    [priceLabel setShadowColor:[UIColor blackColor]];
    [priceLabel setShadowOffset:CGSizeMake(1.0, 1.0)];
    [priceLabel setTextAlignment:NSTextAlignmentLeft];
    [priceLabel setText:@""];

    [backView addSubview:activity];
    [storeView addSubview:backgroundView];
    [storeView addSubview:backView];
    [storeView addSubview:closeButton];
    [storeView addSubview:buyButton];
    [storeView addSubview:restoreButton];
    [storeView addSubview:unlockImage];
    [storeView addSubview:headerLabel];
    [storeView addSubview:descriptionLabel];
    [storeView addSubview:priceLabel];
    
    [[[CCDirector sharedDirector] view] addSubview:storeView];
    
    [self requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if(!isClosed){
            if([products count] != 0){
                self.products = products;
                NSString *description = [[self.products objectAtIndex:0] localizedDescription];
                NSString *header = [[self.products objectAtIndex:0] localizedTitle];
               
                NSNumberFormatter *priceFormatter = [[NSNumberFormatter alloc] init];
                [priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
                [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                SKProduct *myProduct = [self.products objectAtIndex:0];
                
                [priceFormatter setLocale:myProduct.priceLocale];
                
                NSString *priceStr = [priceFormatter stringFromNumber:[[self.products objectAtIndex:0] price]];
                
                [activity stopAnimating];
                [activity removeFromSuperview];
                
                [headerLabel setText:header];
                [descriptionLabel setText:description];
                [priceLabel setText:priceStr];
                
                [buyButton addTarget:self action:@selector(buyPro) forControlEvents:UIControlEventTouchUpInside];
                
                [restoreButton addTarget:self action:@selector(restorePurchases) forControlEvents:UIControlEventTouchUpInside];
            }
            else{
                UIAlertView *couldNotGetProducts = [[UIAlertView alloc] initWithTitle:@""
                                                                              message:NSLocalizedString(@"SERVER_ERROR", nil)
                                                                             delegate:self
                                                                    cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                                    otherButtonTitles:nil,nil];
                [couldNotGetProducts show];
            }
        }
    }];
}
- (void)buyPro {
    if([[GreenTheGardenIAPHelper sharedInstance] canMakePurchases]){
        [[GreenTheGardenIAPHelper sharedInstance] buyProduct:[self.products objectAtIndex:0]];
    }
    else{
        UIAlertView *couldNotMakePurchasesAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"IN_APP_PURCHASES", nil)
                                                                             message:NSLocalizedString(@"COULD_NOT_MAKE_PURCHASES", nil)
                                                                            delegate:self
                                                                   cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                                   otherButtonTitles:nil,nil];
        [couldNotMakePurchasesAlert show];
    }
}

- (void)restorePurchases {
    [[GreenTheGardenIAPHelper sharedInstance] restoreCompletedTransactions];
}

- (void)closeStore {
    [super removeActivity];
    isClosed = YES;
    [storeView removeFromSuperview];
    storeView = nil;
}

- (BOOL) isPro {
    return [self productPurchased:iProUpgradeKey];
}

@end