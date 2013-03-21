//
//  ArrowGameMap.h
//  OkParcalari
//
//  Created by Yunus Eren Guzel on 12/19/12.
//
//

#import "GameMap.h"
#import "SBJson.h"
#import "ArrowBase.h"
#import "DatabaseManager.h"

@interface ArrowGameMap : GameMap
+ (NSArray*) loadMapsFromFile:(NSString*)fileName;

+ (GameMap*) loadFromFile:(NSString*)fileName;
@end
