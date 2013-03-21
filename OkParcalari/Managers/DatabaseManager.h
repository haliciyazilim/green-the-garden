//
//  DatabaseManager.h
//  GreenTheGarden
//
//  Created by Eren Halici on 11.01.2013.
//
//

#import <Foundation/Foundation.h>

#import "Map.h"

@interface DatabaseManager : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (DatabaseManager *)sharedInstance;

- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;
- (BOOL)isEmpty;
- (void) updateMaps;
- (void)insertMaps:(NSArray *)maps forPackage:(NSString *)packageId;
- (Map*) createAndInsertMap;
- (Map *)getMapWithID:(NSString *)mapId;
- (Map *)getMapWithOrder:(NSNumber *)order forPackage:(NSString *)packageId;
- (NSArray *)getMapsForPackage:(NSString *)packageId;
- (NSArray *)getMapsForDifficulty:(int)difficulty;
- (NSArray *)getAllMaps;

@end
