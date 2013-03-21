//
//  MapSelectionLayer.h
//  GreenTheGarden
//
//  Created by Yunus Eren Guzel on 1/11/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "cocos2d.h"
#import "Util.h"
#import "ArrowGameMap.h"
#import "ArrowGameLayer.h"
#import "Reachability.h"


@interface MapSelectionLayer : CCLayer <GKGameCenterControllerDelegate>
{
    
}

@property (strong, nonatomic) Reachability *reachability;

+(CCScene *) scene;

@end
