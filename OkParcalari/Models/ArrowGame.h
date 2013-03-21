//
//  ArrowGame.h
//  OkParcalari
//
//  Created by Eren Halici on 06.12.2012.
//
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"

#import "ArrowBase.h"

#import "ArrowGameMap.h"

#import "GameCenterManager.h"

#import "GameHistory.h"

#import "TutorialManager.h"

@class GameMap;
@class Stopwatch;

@interface ArrowGame : CCNode <UIAlertViewDelegate>

@property NSMutableArray *arrowBases;

@property Stopwatch *gameTimer;
@property BOOL isGamePaused;
@property BOOL isGameRunning;

- (id)initWithFile:(NSString*)fileName;

- (BOOL) isGameFinished;

- (void) touchBegan:(Location) location;

- (void) touchMoved:(Location) location;

- (void) touchEnded:(Location) location;

- (void) pauseGame;

- (void) resumeGame;

- (void) cleanMap;

- (void) pauseTimer;

- (void) resumeTimer;


+(ArrowGame*)lastInstance;
+(void)cleanLastInstance;


@end
