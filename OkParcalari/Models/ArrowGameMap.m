//
//  ArrowGameMap.m
//  OkParcalari
//
//  Created by Yunus Eren Guzel on 12/19/12.
//
//

#import "ArrowGameMap.h"

@implementation ArrowGameMap

+ (NSArray*) loadMapsFromFile:(NSString*)fileName
{
    NSNumber *versionNumber = [[NSUserDefaults standardUserDefaults] valueForKey:@"version_number"];
    
    if([[DatabaseManager sharedInstance] isEmpty] || versionNumber == nil || [versionNumber intValue] == 100){
    
        NSString* content = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"packageinfo"]
                                                      encoding:NSUTF8StringEncoding
                                                         error:NULL];
               SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary* file = [parser objectWithString:content];
        
        for(NSString* mapName in [file objectForKey:@"maps"]){
            if([[DatabaseManager sharedInstance] getMapWithID:mapName] == nil){
                NSString* content = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:mapName ofType:@"gamemap"]
                                                              encoding:NSUTF8StringEncoding
                                                                 error:NULL];
                SBJsonParser *parser = [[SBJsonParser alloc] init];
                NSDictionary* jsonMap = [parser objectWithString:content];
                Map* map = [ArrowGameMap insertMapToDatabaseFromJsonObject:jsonMap];
                map.packageId = fileName;
                map.mapId = mapName;
                [[DatabaseManager sharedInstance] saveContext];
            }
        }
        
        NSArray* mapNames = [file objectForKey:@"maps"];
        for(Map* map in [[DatabaseManager sharedInstance] getAllMaps]){
            BOOL willBeDeleted = YES;
            for(NSString* newMapName in mapNames){
                if([map.mapId compare:newMapName] == 0){
                    willBeDeleted = NO;
                    break;
                }
            }
            if(willBeDeleted == YES){
                [[[DatabaseManager sharedInstance] managedObjectContext] deleteObject:map];
                [[DatabaseManager sharedInstance] saveContext];
            }
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:110] forKey:@"version_number"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[DatabaseManager sharedInstance] updateMaps];
    }
    return [[DatabaseManager sharedInstance] getMapsForPackage:fileName];
}

+ (Map *) insertMapToDatabaseFromJsonObject:(NSDictionary*)jsonMap
{
    Map* map = [[DatabaseManager sharedInstance] createAndInsertMap];
    map.difficulty  = difficultyFromString([jsonMap valueForKey:@"difficulty"]);
    map.stepCount   = [[jsonMap valueForKey:@"stepCount"] intValue];
    map.tileCount   = [[jsonMap valueForKey:@"tileCount"] intValue];
    map.order       = [[jsonMap valueForKey:@"order"] intValue];
    [[DatabaseManager sharedInstance] saveContext];
    return map;
}

+ (GameMap*) loadFromFile:(NSString*)fileName{
    
    GameMap* gameMap = [self sharedInstance];
    
    NSString* content = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"gamemap"]
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
	
    NSDictionary* map = [parser objectWithString:content];
    
    if( [(NSNumber*)[map valueForKey:@"version"] intValue] == 1){
        NSDictionary* size = [map valueForKey:@"mapsize"];
        gameMap.rows = [(NSNumber*)[size valueForKey:@"rows"] intValue];
        gameMap.cols = [(NSNumber*)[size valueForKey:@"cols"] intValue];
        for(NSDictionary* entitiy in [map objectForKey:@"entities"]){
            if([(NSString*)[entitiy valueForKey:@"class"] compare:@"ArrowBase"] == 0){
                ArrowBase * base = [ArrowBase arrowBaseFromDictionary:entitiy];
                [gameMap addChild:base];
            }
        }
    }
    
    return gameMap;
    
}

@end