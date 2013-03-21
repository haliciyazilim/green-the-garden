//
//  InGameMenuLayer.h
//  OkParcalari
//
//  Created by Alperen Kavun on 03.01.2013.
//
//

#import "CCLayer.h"

@interface InGameMenuLayer : CCLayer <UIAlertViewDelegate>

@property CCLayer *callerLayer;

- (void) resumeGame;

- (id) initWithRestaurant:(BOOL)isRestaurant;

@end
