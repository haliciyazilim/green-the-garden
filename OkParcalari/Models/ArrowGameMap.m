//
//  ArrowGameMap.m
//  OkParcalari
//
//  Created by Yunus Eren Guzel on 12/19/12.
//
//

#import "ArrowGameMap.h"
#import "GreenTheGardenIAPHelper.h"
#import "GreenTheGardenIAPSpecificValues.h"
#import "LoadingLayer.h"

@implementation ArrowGameMap

+ (NSArray*) loadMapsFromFile:(NSString*)fileName
{
    return [[DatabaseManager sharedInstance] getMapsForPackage:fileName];
}

+ (void) configureDatabase
{
    NSNumber *versionNumber = [[NSUserDefaults standardUserDefaults] valueForKey:@"version_number"];
    CGFloat totalMapCount = 359.0;
    CGFloat proccessedMapCount = 0.0;
    if(YES || [[DatabaseManager sharedInstance] isEmpty] || versionNumber == nil || [versionNumber intValue] == 100 || [versionNumber intValue] == 110){
    
        for (MapPackage* package in [MapPackage allPackages]) {
//            NSLog(@"packName: %@",package.name);
            NSString* content = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:package.name ofType:@"packageinfo"]
                                                          encoding:NSUTF8StringEncoding
                                                             error:NULL];
//            NSLog(@"content: %@",content);
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
                    map.packageId = package.name;
                    map.mapId = mapName;
                    [[DatabaseManager sharedInstance] saveContext];
                }
                proccessedMapCount += 1.0;
                [[LoadingLayer lastInstance] performSelectorOnMainThread:@selector(updateLoadingBarWithPercentage:) withObject:[NSNumber numberWithFloat:proccessedMapCount/totalMapCount] waitUntilDone:NO];
            }
            
            if([package.name isEqualToString:STANDART_PACKAGE]){
                
                NSArray* mapNames = [file objectForKey:@"maps"];
                for(Map* map in [[DatabaseManager sharedInstance] getAllMaps]){
                    BOOL willBeDeleted = YES;
                    for(NSString* newMapName in mapNames){
                        if([map.mapId isEqualToString:newMapName]){
                            willBeDeleted = NO;
                            break;
                        }
                    }
                    if(willBeDeleted == YES){
                        [[[DatabaseManager sharedInstance] managedObjectContext] deleteObject:map];
                        [[DatabaseManager sharedInstance] saveContext];
                    }
                }
            }
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:120] forKey:@"version_number"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[DatabaseManager sharedInstance] updateMapsForPackage:package.name];
        }
        
        [self migrateGameUnlock];
    }
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

#pragma mark Alperen dolduracak
+ (void) migrateGameUnlock
{
    if ([[GreenTheGardenIAPHelper sharedInstance] isProductPurchased:iStandartPackageKey]) {
        // this is an update and need to write pro version to user defaults for removing ads
        
        NSString* deviceName = [[UIDevice currentDevice] name];
        
        NSString *proString = [NSString stringWithFormat:@"%@%@",iProSecret,deviceName];
        
        [[NSUserDefaults standardUserDefaults] setObject:[[GreenTheGardenIAPHelper sharedInstance] sha1:proString] forKey:iProKey];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end