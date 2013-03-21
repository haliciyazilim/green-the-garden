//
//  GameHistory.h
//  OkParcalari
//
//  Created by Yunus Eren Guzel on 1/2/13.
//
//

#import <Foundation/Foundation.h>
#import "SBJson.h"


@interface Score : NSObject

@property int score;

@property NSString* mapName;

+(Score*)score:(int)score map:(NSString*)mapName;

@end


@interface GameHistory : NSObject

+(void)saveScore:(int)score forMap:(NSString*)map;

+(NSArray*)scores;

+(Score*)scoreForMap:(NSString*)mapName;

+(void) readScoresFromFile;

@end
