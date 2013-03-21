//
//  ArrowBase.m
//  OkParcalari
//
//  Created by Eren Halici on 07.12.2012.
//
//

#import "ArrowBase.h"

#import "GameMap.h"
#define ARROW_BASE_SIZE_NUMBER_TAG_1 2101
#define ARROW_BASE_SIZE_NUMBER_TAG_2 2102
@interface ArrowBase()

@end


@implementation ArrowBase

+ (ArrowBase*) arrowBaseFromDictionary:(NSDictionary*)dict
{
    Location location = LocationMakeFromDictionary([dict objectForKey:@"location"]);
    int size = [(NSNumber*)[dict objectForKey:@"size"] intValue];
    ArrowBase* arrowBase = [[ArrowBase alloc] initWithLocation:location andSize:size];
    return arrowBase;
}

+ (id) ArrowBaseWithLocation:(Location)location andSize:(int)size {
    return [[ArrowBase alloc] initWithLocation:location andSize:size];
}

- (id) initWithLocation:(Location)location andSize:(int)size {
    self = [super initWithLocation:location];
    
    if (self) {
        self.size = size;
        
        self.upArrow    = [[Arrow alloc] initWithLocation:self.location andDirection:UP forBase:self];
        self.downArrow  = [[Arrow alloc] initWithLocation:self.location andDirection:DOWN forBase:self];
        self.rightArrow = [[Arrow alloc] initWithLocation:self.location andDirection:RIGHT forBase:self];
        self.leftArrow  = [[Arrow alloc] initWithLocation:self.location andDirection:LEFT forBase:self];
        
        [self createSprite];
    }
    
    return self;
}


- (void) createSprite {
    
    NSString* fileName;
    if( self.location.x == self.map.cols - 1 && self.location.y == self.map.rows-1)
        fileName = @"arrow_base_3.png";
    else if( self.location.x == self.map.cols - 1 && self.location.y == 0)
        fileName = @"arrow_base_9.png";
    else if( self.location.x == self.map.cols-1)
        fileName = @"arrow_base_6.png";
    else if( self.location.x == 0 && self.location.y == self.map.rows-1)
        fileName = @"arrow_base_1.png";
    else if( self.location.x == 0 && self.location.y == 0)
        fileName = @"arrow_base_7.png";
    else if( self.location.x == 0)
        fileName = @"arrow_base_4.png";
    else if( self.location.y == self.map.rows-1)
        fileName = @"arrow_base_2.png";
    else if( self.location.y == 0)
        fileName = @"arrow_base_8.png";
    else
        fileName = @"arrow_base_5.png";
    

    
    CCSprite *sprite = [CCSprite spriteWithFile:fileName];
    sprite.position = CGPointMake(0, 0);

    CCSprite *back = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%dx%dc.png",self.location.x,self.location.y]];
    
    back.position = CGPointMake(0, 0);
    
    [self addChild:back];
    [self addChild:self.upArrow];
    [self addChild:self.downArrow];
    [self addChild:self.leftArrow];
    [self addChild:self.rightArrow];
    [self addChild:sprite];
    
    
    [self showSize];

}

- (void) showSize
{
    int size = self.size - ([self.leftArrow getSize] + [self.rightArrow getSize] + [self.upArrow getSize] + [self.downArrow getSize]);
    [self removeChildByTag:ARROW_BASE_SIZE_NUMBER_TAG_1 cleanup:YES];
    [self removeChildByTag:ARROW_BASE_SIZE_NUMBER_TAG_2 cleanup:YES];
    if(size < 10){
        NSString* numberFileName = [NSString stringWithFormat:@"arrow_num_%d.png",size];
        
        CCSprite *arrowNumber = [CCSprite spriteWithFile:numberFileName];
        arrowNumber.tag = ARROW_BASE_SIZE_NUMBER_TAG_1;
        arrowNumber.position = CGPointMake(0, 0);
        [self addChild:arrowNumber];
    }
    else if(size >= 10){
        NSString *numberFileName1 = [NSString stringWithFormat:@"arrow_num_%d.png",size/10];
        NSString *numberFileName2 = [NSString stringWithFormat:@"arrow_num_%d.png",size%10];
        CCSprite *arrowNumber1 = [CCSprite spriteWithFile:numberFileName1];
        CCSprite *arrowNumber2 = [CCSprite spriteWithFile:numberFileName2];
        arrowNumber1.tag = ARROW_BASE_SIZE_NUMBER_TAG_1;
        arrowNumber2.tag = ARROW_BASE_SIZE_NUMBER_TAG_2;
        arrowNumber1.position = CGPointMake(-6,0);
        arrowNumber2.position = CGPointMake(6,0);
        [self addChild:arrowNumber1];
        [self addChild:arrowNumber2];
    }
}

- (BOOL) isCorrect {
    return NO;
}

- (BOOL) isDeformed
{
    return [self.rightArrow isDeformed] || [self.upArrow isDeformed] || [self.downArrow isDeformed] || [self.leftArrow isDeformed];
 }
- (Arrow *) arrowAtDirection:(Direction) direction
{
    switch (direction) {
        case UP:
            return self.upArrow;
        case DOWN:
            return self.downArrow;
        case LEFT:
            return self.leftArrow;
        case RIGHT:
            return self.rightArrow;
        case NONE:
        default:
            return nil;
    }
}

- (Arrow *) extendArrowWithEndLocation:(Location) endLocation
{
    Arrow* arrow = [self arrowAtDirection:DirectionFromTwoLocations(self.location, endLocation)];
    if(arrow != nil)
        arrow.endLocation = endLocation;
    return arrow;
}

- (Arrow *) compressArrowAtDirection:(Direction) direction
{
    Arrow* arrow = [self arrowAtDirection:direction];
    arrow.endLocation = self.location;
    return arrow;
}

- (void) markWateredLocationsIn:(NSMutableDictionary *)bitMap
{
    [bitMap setValue:@"1" forKey:LocationToString(self.location)];
}

- (void) refreshShownSize
{
    
}

@end
