//
//  GameMap.m
//  OkParcalari
//
//  Created by Eren Halici on 07.12.2012.
//
//

#import "GameMap.h"

#include <stdio.h>


@interface GameMap ()

@property NSDictionary *randomMap;

@end


@implementation GameMap

static GameMap *sharedInstance = nil;

- (id)init
{
    self = [super init];
    if (self) {
        self.entities = [NSMutableSet setWithCapacity:50];
        self.tileSize = CGSizeMake(70, 70);
        self.position = CGPointMake(34, 34);
        
        self.rows = 10;
        self.cols = 10;
        
    }
    return self;
}



- (int)getRandomNumberForLocation:(Location)location {
    return [[self.randomMap objectForKey:[NSString stringWithFormat:@"%d, %d", location.x, location.y]] intValue];
}

+ (GameMap *)loadFromFile:(NSString *)fileName
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

+ (GameMap *)sharedInstance {
    @synchronized (self) {
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] init];
        }
    }
    return sharedInstance;
}

- (void) addChild:(CCNode *)entity {
    [super addChild:entity];
    
    if ([entity isKindOfClass:[MapEntity class]]) {
        [self.entities addObject:entity];
    }
}


-(Location) convertAbsolutePointToGridPoint:(CGPoint) absolutePoint
{
    int x = (absolutePoint.x - self.position.x) / self.tileSize.width;
    int y = (absolutePoint.y - self.position.y) / self.tileSize.height;
    
    return LocationMake(x,y);
    
}



-(CGPoint) pointFromGridLocation:(Location) location
{
    return CGPointMake(location.x*self.tileSize.width+self.position.x, location.y*self.tileSize.height+self.position.y);
}



- (MapEntity*) entityAtLocation:(Location)location
{
    NSArray* allObjects = [[self entitiesAtLocation:location] allObjects];
    if([allObjects count] == 0)
        return nil;
    return [allObjects objectAtIndex:0];
    
}

- (NSSet*) entitiesAtLocation:(Location)location
{
    NSMutableSet* set = [[NSMutableSet alloc] init];
    
    [self.entities enumerateObjectsUsingBlock:^(MapEntity *entity, BOOL *stop) {
        [set addObjectsFromArray:[[entity entitiesAtLocation:location] allObjects]];
    }];
    
    return set;
}

- (BOOL) isLocationInsideMap:(Location) location
{
    return (location.x >= 0 && location.y >= 0 && location.x < self.cols && location.y < self.rows);
}



- (NSSet*) allEntries
{
    __block NSSet* set = [[NSSet alloc] init];
    [self.entities enumerateObjectsUsingBlock:^(MapEntity* entity, BOOL *stop) {
        set = [set setByAddingObjectsFromSet:[entity allEntries]];
    }];
    return set;
}

- (void)removeAllChildrenWithCleanup:(BOOL)cleanup
{
    [self.entities enumerateObjectsUsingBlock:^(MapEntity* entity, BOOL *stop) {
        [entity removeAllChildrenWithCleanup:cleanup];
    }];
    
    [self.entities removeAllObjects];
    
    [super removeAllChildrenWithCleanup:cleanup];
    
}

@end
