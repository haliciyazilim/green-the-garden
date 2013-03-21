//
//  DatabaseManager.m
//  GreenTheGarden
//
//  Created by Eren Halici on 11.01.2013.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "DatabaseManager.h"
#import "GreenTheGardenIAPHelper.h"
#import "GreenTheGardenGCSpecificValues.h"

static DatabaseManager *sharedInstance = nil;

@implementation DatabaseManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;
        }
    }
    
    return nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (DatabaseManager *)sharedInstance
{
    @synchronized (self) {
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] init];
        }
    }
    
    return sharedInstance;
}


- (void)saveContext {
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle the error.
    }
    [self updateMaps];
}
- (void) updateMaps {
    int nonPlayedActiveGameCount = kNonPlayedActiveGameCount;
    int freeMapsCount = kFreeMapsCount;
    int index = 0;
    NSArray* maps = [[DatabaseManager sharedInstance] getMapsForPackage:@"standart"];
    int purchasedMapsCount = [[GreenTheGardenIAPHelper sharedInstance] isPro] ? [maps count] : freeMapsCount;
//    purchasedMapsCount = freeMapsCount;
    for (Map* map in maps) {
        if(purchasedMapsCount > 0){
            map.isPurchased = YES;
            purchasedMapsCount--;
        }
        else{
            map.isPurchased = NO;
        }
        if(map.isFinished == NO){
            if(nonPlayedActiveGameCount > 0){
                map.isNotPlayedActiveGame = YES;
                nonPlayedActiveGameCount--;
                map.isLocked = NO;
            }
            else{
                map.isLocked = YES;
            }
        }
        
        index++;
    }
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle the error.
    }
    
}
- (BOOL)isEmpty {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Map" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil || mutableFetchResults.count == 0) {
        // Handle the error.
        return YES;
    } else {
        return NO;
    }
}

- (Map *)getMapWithID:(NSString *)mapId {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Map"
                                              inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"mapId == %@", mapId];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if(mutableFetchResults == nil)
        return nil;
    if([mutableFetchResults count] == 0)
        return nil;
    return [mutableFetchResults objectAtIndex:0];
}

- (Map *)getMapWithOrder:(NSNumber *)order forPackage:(NSString *)packageId {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Map"
                                              inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"(order == %@) AND (packageId == %@)", order, packageId];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    if (mutableFetchResults == nil || mutableFetchResults.count == 0) {
        return nil;
    } else {
        return [mutableFetchResults objectAtIndex:0];
    }
}

- (NSArray *)getMapsForPackage:(NSString *)packageId {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Map"
                                              inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"packageId == %@", packageId];
    [request setPredicate:predicate];
    
    
    NSError *error = nil;
    NSArray* result =  [self.managedObjectContext executeFetchRequest:request error:&error];
    result = [result sortedArrayUsingComparator:^NSComparisonResult(Map *obj1, Map *obj2) {
        return obj1.order - obj2.order;      
    }];
    return result;
}

- (NSArray *)getAllMaps{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Map"
                                              inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    NSPredicate *predicate = nil;
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"order" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error = nil;
    NSArray* result =  [self.managedObjectContext executeFetchRequest:request error:&error];
    result = [result sortedArrayUsingComparator:^NSComparisonResult(Map *obj1, Map *obj2) {
        return obj1.order - obj2.order;
    }];
    return result;
}


- (NSArray *)getMapsForDifficulty:(int)difficulty {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Map"
                                              inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"difficulty == %i", difficulty];
    [request setPredicate:predicate];
    
    
    NSError *error = nil;
    NSArray* result =  [self.managedObjectContext executeFetchRequest:request error:&error];
    result = [result sortedArrayUsingComparator:^NSComparisonResult(Map *obj1, Map *obj2) {
        return obj1.order - obj2.order;
    }];
    return result;
}

- (Map*) createAndInsertMap
{
    
    Map *map = [NSEntityDescription insertNewObjectForEntityForName:@"Map"
                                              inManagedObjectContext:self.managedObjectContext];
    [map setIsFinished:NO];
    [map setScore:[NSNumber numberWithInt:INT32_MAX]];
    [map setDifficulty:-1];
    [map setStepCount:-1];
    [map setTileCount:0];
    [map setIsPurchased:NO];
    [map setIsLocked:YES];
    [map setIsNotPlayedActiveGame:NO];

    [self saveContext];
    return map;
}

- (void)insertMaps:(NSArray *)maps forPackage:(NSString *)packageId {
    for (NSString *mapId in maps) {
        Map* aMap = [self createAndInsertMap];
        [aMap setPackageId:packageId];
        [aMap setMapId:mapId];
    }
    [self saveContext];
}


/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"GreenTheGarden.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

@end

