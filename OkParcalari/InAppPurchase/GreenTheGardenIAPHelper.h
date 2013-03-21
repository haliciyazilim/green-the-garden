//
//  GreenTheGardenIAPHelper.h
//  GreenTheGarden
//
//  Created by Alperen Kavun on 10.01.2013.
//
//

#import "IAPHelper.h"
#import "MapSelectionLayer.h"

@interface GreenTheGardenIAPHelper : IAPHelper

@property MapSelectionLayer *callerLayer;

+ (GreenTheGardenIAPHelper *) sharedInstance;

- (BOOL) isPro;
- (void) createStore;
@end
