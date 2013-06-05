//
//  LoadingLayer.h
//  Green The Garden
//
//  Created by Alperen Kavun on 05.06.2013.
//
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "MainGameLayer.h"

@interface LoadingLayer : CCLayer

+ (CCScene *) scene;
+ (LoadingLayer *) lastInstance;

- (void) updateLoadingBarWithPercentage:(NSNumber*)percentage;
@end
