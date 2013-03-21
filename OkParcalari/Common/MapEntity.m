//
//  MapEntity.m
//  OkParcalari
//
//  Created by Eren Halici on 07.12.2012.
//
//

#import "MapEntity.h"
#import "GameMap.h"

Location LocationMake(int x, int y) {
    Location loc;
    loc.x = x;
    loc.y = y;
    return loc;
}

NSString* LocationToString(Location location){
    return [NSString stringWithFormat:@"%dx%d",location.x,location.y];
    
}

int differenceBetweenTwoLocations(Location from,Location to)
{
    int xDiff = from.x - to.x;
    int yDiff = from.y - to.y;
    
    switch (DirectionFromTwoLocations(from, to)) {
        case RIGHT:
        case LEFT:
            return abs(xDiff);
        case UP:
        case DOWN:
            return abs(yDiff);
        default:
            return 0;
    }
}

Location LocationMakeFromDictionary(NSDictionary* dict){
    int x = [(NSNumber*)[dict objectForKey:@"x"] intValue];
    int y = [(NSNumber*)[dict objectForKey:@"y"] intValue];
    return LocationMake(x, y);
}

Direction DirectionFromTwoLocations(Location start, Location end){
    if(start.x == end.x && start.y > end.y)
        return DOWN;
    if(start.x == end.x && start.y < end.y)
        return UP;
    if(start.x < end.x && start.y == end.y)
        return RIGHT;
    if(start.x > end.x && start.y == end.y)
        return LEFT;
    return NONE;
}

NSString* StringFromDirection(Direction direction){
    switch (direction) {
        case UP:
            return @"UP";
        case DOWN:
            return @"DOWN";
        case LEFT:
            return @"LEFT";
        case RIGHT:
            return @"RIGHT";
        default:
            return @"NONE";
    }
    return nil;
}

@implementation MapEntity

- (id)init
{
    return [self initWithLocation:LocationMake(0, 0)];
}

- (id)initWithLocation:(Location)location {
    self = [super init];
    if (self) {
        _location = location;
        self.entities = [[NSMutableSet alloc] init];
        self.position = [self pointFromLocation:location];
        self.parentEntity = nil;
    }
    return self;
}

- (GameMap*)map {
    return [GameMap sharedInstance];
}

- (void) addChild:(CCNode *)entity {
    [super addChild:entity];
    
    if ([entity isKindOfClass:[MapEntity class]]) {
        MapEntity* mapEntity = (MapEntity*)entity;
        [self.entities addObject:mapEntity];
        mapEntity.parentEntity = self;
    }
}

- (void)setParent:(CCNode *)parent {
    [super setParent:parent];
    self.position = [self pointFromLocation:self.location];
}


- (void) setMap:(GameMap *)map
{
    
}

- (void)setLocation:(Location)location {
    _location = location;
    
    self.position = [self pointFromLocation:location];
}

- (BOOL)hitTestWithLocation:(Location) location
{
    if(self.location.x == location.x && self.location.y == location.y){
        return YES;
    }
    else{
        return NO;
    }
}

- (MapEntity*) entityAtLocation:(Location)location
{
    return [[[self entitiesAtLocation:location] allObjects] objectAtIndex:0];
        
}

- (NSSet*) entitiesAtLocation:(Location)location
{
    
    NSMutableSet* set = [[NSMutableSet alloc] init];
    
    if ([self hitTestWithLocation:location] == YES) {
        [set addObject:self];
    }
    [self.entities enumerateObjectsUsingBlock:^(MapEntity *entity, BOOL *stop) {
        [set addObjectsFromArray:[[entity entitiesAtLocation:location] allObjects]];
    }];
    return set;
}

- (CGPoint) pointFromLocation:(Location)location
{
    if([self.parent isKindOfClass:[MapEntity class]]) {
        Location parentLocation = ((MapEntity*)self.parent).location;
        
        float x = (location.x - parentLocation.x) * self.map.tileSize.width;
        float y = (location.y - parentLocation.y) * self.map.tileSize.height;
        
        return CGPointMake(x,y);
    } else {        
        float x = (location.x + 0.5) * self.map.tileSize.width;
        float y = (location.y + 0.5) * self.map.tileSize.height;
        
        return CGPointMake(x,y);
    }
}
- (NSSet*) allEntries
{
    __block NSSet* set = [[NSSet alloc] initWithObjects:self, nil];
    [self.entities enumerateObjectsUsingBlock:^(MapEntity* entity, BOOL *stop) {
        set = [set setByAddingObjectsFromSet:[entity allEntries]];
    }];
    return set;
}

- (void) markWateredLocationsIn:(NSMutableDictionary*) bitMap
{
    [NSException raise:@"Invoked abstract method" format:@"Invoked abstract method"];
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
