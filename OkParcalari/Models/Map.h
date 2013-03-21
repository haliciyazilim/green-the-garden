//
//  Map.h
//  GreenTheGarden
//
//  Created by Yunus Eren Guzel on 1/10/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum MAP_DIFFICULTY {
    EASY = 1,
    NORMAL = 2,
    HARD = 3,
    INSANE = 4
} MAP_DIFFICULTY;
MAP_DIFFICULTY difficultyFromString(NSString* string);
NSString* stringOfDifficulty(MAP_DIFFICULTY difficulty);


@interface MapPackage : NSObject 

@property NSString* name;
@property int packageId;
@property NSArray* maps;

@end

@interface Map : NSManagedObject

@property NSString *mapId;
@property NSString *packageId;
@property NSNumber *score;
@property BOOL isFinished;
@property MAP_DIFFICULTY difficulty;
@property int stepCount;
@property int tileCount;
@property int order;
@property BOOL isPurchased;
@property BOOL isLocked;
@property int solveCount;

@property MapPackage* package;
@property BOOL isNotPlayedActiveGame;

-(int)getStarCount;
+ (int) starCountForScore:(int)score andDifficulty:(MAP_DIFFICULTY)difficulty;

@end
