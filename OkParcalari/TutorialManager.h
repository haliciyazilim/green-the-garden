//
//  TutorialManager.h
//  GreenTheGarden
//
//  Created by Yunus Eren Guzel on 1/25/13.
//
//

#import <Foundation/Foundation.h>
#import "MapEntity.h"
#import "Map.h"
#import "GameMap.h"
#import "ArrowBase.h"
#import "ArrowGame.h"

@interface TutorialManager : NSObject

+(TutorialManager*)sharedInstance;

-(BOOL)isTutorialEnabled;

-(void)setTutorialEnabled;

-(void)setTutorialDisabled;

-(BOOL)isTutoringMap:(NSString*)mapFileName;

-(void)startTutorial;

-(void)finishTutorial;

-(void)skipTutorial;

-(BOOL)isTutorialActive;

-(BOOL)shouldDisableOtherEntities;

-(BOOL)isCorrectEntitity:(ArrowBase*)entity;

-(void)checkEntity:(ArrowBase*)entity;

-(void)pauseTutorial;

-(void)resumeTutorial;

-(void)updateForMovedBase:(ArrowBase*)arrowBase;

@end
