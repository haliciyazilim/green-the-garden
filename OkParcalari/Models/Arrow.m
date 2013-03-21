//
//  Arrow.m
//  OkParcalari
//
//  Created by Eren Halici on 10.12.2012.
//
//

#import "Arrow.h"
#import "WaterSpray.h"
#import "GreenTheGardenSoundManager.h"
#import "AchievementManager.h"
#import "GreenTheGardenGCSpecificValues.h"

#define DELAY_ACTION_TAG 141
#define ACTION_TAG 142
#define BACKSPRITE1_TAG 5600
#define BACKSPRITE2_TAG 5700
#define BACKSPRITE3_TAG 5800

@implementation Arrow
{
    int lastSize;
    BOOL isActionWaiting;
    int actionCount;
    BOOL isDeformed;
    int moveCount;
}

- (id) init
{
    return [self initWithLocation:LocationMake(0, 0)];
}

- (id) initWithLocation:(Location)location andDirection:(Direction)direction forBase:(ArrowBase*)base
{
    self = [super initWithLocation:location];
    if (self) {
        self.isSelected = NO;
        isDeformed = NO;
        moveCount = 0;
        self.endLocation = location;
        self.base = base;
        self.direction = direction;
        self.position = CGPointMake(0, 0);
        lastSize = 0;
        isActionWaiting = NO;
        [self createSprites];
        actionCount = 0;
    }
    return self;
}

- (void) setEndLocation:(Location)endLocation {
    if(self.endLocation.x == endLocation.x && self.endLocation.y == endLocation.y){
        return;
    }
    Direction direction = DirectionFromTwoLocations(self.location, endLocation);
    if(direction != NONE && direction != self.direction)
        return;
    Location savedEndLocation = self.endLocation;
    _endLocation = endLocation;
    
    BOOL applyChanges = YES;
    
    ArrowBase *base = self.base;
    
    if ([base.upArrow getSize] + [base.downArrow getSize] + [base.leftArrow getSize] + [base.rightArrow getSize] > base.size) {
        applyChanges = NO;
    }
    
    for(int i=1;i<=[self getSize];i++){
        NSArray* entities = [[self.map entitiesAtLocation:[self locationAtOrder:i]] allObjects];
        if([entities count] > 1)
            applyChanges = NO;
    }
    
    if(applyChanges == NO){
        _endLocation = savedEndLocation;
        return;
    }
    
    [base showSize];
    
    [self createSprites];
}


- (int) getSize
{
    int xDiff = self.endLocation.x - self.location.x;
    int yDiff = self.endLocation.y - self.location.y;
    
    switch ([self direction]) {
        case RIGHT:
            return xDiff;
        case UP:
            return yDiff;
        case LEFT:
            return -xDiff;
        case DOWN:
            return -yDiff;
        default:
            return 0;
    }
}

-(NSArray*) childrenByTag:(NSInteger)tag
{
    NSMutableArray* childrenForTag = [[NSMutableArray alloc] init];
    for(int i=0; i< [[self children] count];i++){
        if([[[self children] objectAtIndex:i] tag] == tag){
            [childrenForTag addObject:[[self children] objectAtIndex:i]];
        }
    }
    
    return (NSArray*)childrenForTag;
}

-(void) removeChildrenByTag:(NSInteger)tag cleanup:(BOOL)cleanup
{
    NSArray* willRemove = [self childrenByTag:tag];
    for(int i=0;i<[willRemove count];i++){
        [self removeChild:[willRemove objectAtIndex:i] cleanup:cleanup];
    }
}

- (void) createSprites {
    [self removeChildrenByTag:40 cleanup:YES];
    int size = [self getSize];

    if(size <= 0)
        return;
    
    Location location;
    CCSprite *sprite;
    
    switch ([self direction]) {
        case RIGHT:
            sprite = [CCSprite spriteWithFile:@"arrow_left_start.png"];
            break;
        case LEFT:
            sprite = [CCSprite spriteWithFile:@"arrow_right_start.png"];
            break;
        case UP:
            sprite = [CCSprite spriteWithFile:@"arrow_down_start.png"];
            break;
        case DOWN:
            sprite = [CCSprite spriteWithFile:@"arrow_up_start.png"];
            break;
            
        default:
            break;
    }
    sprite.tag = 40;
    sprite.position = [self pointFromLocation:[self location]];
    [self addChild:sprite];
    
    
    switch ([self direction]) {
        case RIGHT:
            location = LocationMake(self.location.x + size, self.location.y);
            sprite = [CCSprite spriteWithFile:@"arrow_right_start.png"];
            break;
        case LEFT:
            location = LocationMake(self.location.x - size, self.location.y);
            sprite = [CCSprite spriteWithFile:@"arrow_left_start.png"];
            break;
        case DOWN:
            location = LocationMake(self.location.x, self.location.y - size);
            sprite = [CCSprite spriteWithFile:@"arrow_down_start.png"];
            break;
        case UP:
            location = LocationMake(self.location.x, self.location.y + size);
            sprite = [CCSprite spriteWithFile:@"arrow_up_start.png"];
            break;
        case NONE:
        default:
            break;
    }
    sprite.tag = 40;
    sprite.position = [self pointFromLocation:location];
    [self addChild:sprite z:0] ;
    
    if([self direction] != NONE){
        //NSLog(@"%d",[self direction]);
        [[GreenTheGardenSoundManager sharedSoundManager] playEffect:@"move"];
        //NSLog(@"MOve Efekti çalması gerek.");
    }
    
    
    sprite = [CCSprite spriteWithFile:@"arrow_base_fiskiye.png"];
    sprite.tag = 40;
    sprite.position = [self pointFromLocation:location];
    [self addChild:sprite];
    [self reorderChild:sprite z:100];
    
    for (int i = 1; i < size; i++) {
        switch ([self direction]) {
            case RIGHT:
                sprite = [CCSprite spriteWithFile:@"arrow_horizontal.png"];
                location = LocationMake(self.location.x + i, self.location.y);
                break;
            case LEFT:
                sprite = [CCSprite spriteWithFile:@"arrow_horizontal.png"];
                location = LocationMake(self.location.x - i, self.location.y);
                break;
            case DOWN:
                sprite = [CCSprite spriteWithFile:@"arrow_vertical.png"];
                location = LocationMake(self.location.x, self.location.y - i);
                break;
            case UP:
                sprite = [CCSprite spriteWithFile:@"arrow_vertical.png"];
                location = LocationMake(self.location.x, self.location.y + i);
                break;
            case NONE:
            default:
                break;
        }
        
        sprite.tag = 40;
        sprite.position = [self pointFromLocation:location];
        [self addChild:sprite z:0];
        
        sprite = [CCSprite spriteWithFile:@"arrow_base_fiskiye.png"];
        sprite.tag = 40;
        sprite.position = [self pointFromLocation:location];
        [self addChild:sprite];
        [self reorderChild:sprite z:100];
        
        
    }
}

- (void) removeSquirts
{
    int max = lastSize > [self getSize] ? lastSize : [self getSize];
    int min = lastSize < [self getSize] ? lastSize : [self getSize];
    
    
    for(int i=0;i<max;i++){
        if(i >= min && lastSize > [self getSize]){
            [self removeChildrenByTag:100+i+1 cleanup:YES];
        }
    }
}

- (BOOL) isDeformed
{
    return isDeformed;
};

- (void) animateBackgrounds{
    
    if(lastSize > [self getSize]){
        isDeformed = YES;
    }
    
    int max = lastSize > [self getSize] ? lastSize : [self getSize];
    int min = lastSize < [self getSize] ? lastSize : [self getSize];
    
    if(max != min){
        moveCount++;
        if(moveCount <=10){
            [[AchievementManager sharedAchievementManager] submitAchievement:kAchievementBipolar percentComplete:100.0];
        }
    }
    
    for(int i=0;i<max;i++){
        if(i < min){
            [self backgroundAtOrder:i+1 withDuration:0.0f withDelay:0.0f];
        }
        else {
            float delayConstant = lastSize < [self getSize] ? (i-min) : (max-i);
            [self backgroundAtOrder:i+1 withDuration:0.5f withDelay:delayConstant*0.2f];
            
        }
    }
    
    lastSize = [self getSize];
    
}

-(void) backgroundAtOrder:(int)order withDuration:(float)duration withDelay:(float)delay
{
    
    NSString *fileName1 = [NSString stringWithFormat:@"%dx%da.png",[self locationAtOrder:order].x,[self locationAtOrder:order].y];
    NSString *fileName2 = [NSString stringWithFormat:@"%dx%db.png",[self locationAtOrder:order].x,[self locationAtOrder:order].y];
    NSString *fileName3 = [NSString stringWithFormat:@"%dx%dc.png",[self locationAtOrder:order].x,[self locationAtOrder:order].y];
    
    CCSprite *backSprite1 = (CCSprite*)[self getChildByTag:BACKSPRITE1_TAG+order] ;
    CCSprite *backSprite2 = (CCSprite*)[self getChildByTag:BACKSPRITE2_TAG+order] ;
    CCSprite *backSprite3 = (CCSprite*)[self getChildByTag:BACKSPRITE3_TAG+order] ;
    
    if(backSprite1 == nil){
        backSprite1 = [CCSprite spriteWithFile:fileName1];
        backSprite1.tag = BACKSPRITE1_TAG+order;
        backSprite1.position = [self pointFromLocation:[self locationAtOrder:order]];
        [self addChild:backSprite1];
        backSprite1.opacity = 0;
        [self reorderChild:backSprite1 z:-3];
    }
    
    if(backSprite2 == nil){
        backSprite2 = [CCSprite spriteWithFile:fileName2];
        backSprite2.tag = BACKSPRITE2_TAG+order;
        backSprite2.position = [self pointFromLocation:[self locationAtOrder:order]];
        [self addChild:backSprite2];
        backSprite2.opacity = 0;
        [self reorderChild:backSprite2 z:-3];
    }
    
    if(backSprite3 == nil){
        backSprite3 = [CCSprite spriteWithFile:fileName3];
        backSprite3.tag = BACKSPRITE3_TAG+order;
        backSprite3.position = [self pointFromLocation:[self locationAtOrder:order]];
        backSprite3.opacity = 0;
        [self addChild:backSprite3];
        [self reorderChild:backSprite3 z:-3];
    }
    
//    delay += 1.0f;
    if(duration > 0 ){
        [self stopBackspriteAtOrder:order];
        if(order > lastSize){
            
            WaterSpray *mySpray = [[WaterSpray alloc] initWithPoint: [self pointFromLocation:[self locationAtOrder:order]]];
            mySpray.tag = 100+order;
            [mySpray callScheduleSprayingWithDelay:delay];
            [self addChild:mySpray z:10];
            
            [[GreenTheGardenSoundManager sharedSoundManager] playEffect:@"fiskiye"];
            //NSLog(@"fiksiye efekti çalması gerek.");
            
            delay += 1.0;
            [backSprite1 runAction:  [self fadeInSequenceWithDelay:duration*0.0f+delay withDuration:duration]];
            [backSprite2 runAction: [self fadeInSequenceWithDelay:duration*1.0f+delay withDuration:duration]];
            [backSprite3 runAction: [self fadeInSequenceWithDelay:duration*2.0f+delay withDuration:duration]];
        }
        else {
            [self removeChildrenByTag:100+order cleanup:YES];
            float durationConstant1 = (float)backSprite2.opacity/255 + (float)backSprite3.opacity/255;
            float durationConstant2 = (float)backSprite3.opacity/255;
            [backSprite1 runAction:[self fadeOutSequenceWithDelay:duration*durationConstant1+delay withDuration:duration]];
            [backSprite2 runAction:[self fadeOutSequenceWithDelay:duration*durationConstant2+delay withDuration:duration]];
            [backSprite3 runAction:[self fadeOutSequenceWithDelay:duration*0.0f+delay withDuration:duration]];
        }
    }
}


- (void) stopBackspriteAtOrder:(int)order {
    [[self getChildByTag:BACKSPRITE1_TAG+order] stopAllActions];
    [[self getChildByTag:BACKSPRITE2_TAG+order] stopAllActions];
    [[self getChildByTag:BACKSPRITE3_TAG+order] stopAllActions];
}

- (CCSequence*) fadeOutSequenceWithDelay:(float)delay withDuration:(float) duration
{
    CCDelayTime* delayAction = [CCDelayTime actionWithDuration:delay];
    CCFadeTo* action = [CCFadeTo actionWithDuration:duration opacity:0];
    delayAction.tag = DELAY_ACTION_TAG;
    action.tag = ACTION_TAG;
    
    return [CCSequence actions:
            delayAction,
            action,
            nil];
}

- (CCSequence*) fadeInSequenceWithDelay:(float)delay withDuration:(float) duration
{
    CCDelayTime* delayAction = [CCDelayTime actionWithDuration:delay];
    CCFadeTo*  action = [CCFadeTo actionWithDuration:duration opacity:255];
    delayAction.tag = DELAY_ACTION_TAG;
    action.tag = ACTION_TAG;
    return [CCSequence actions:
            delayAction,
            action,
            nil];
}

- (BOOL) hitTestWithLocation:(Location) location
{
    
    switch([self direction]){
        case RIGHT:
            return (self.location.y == location.y && self.location.x < location.x && self.endLocation.x >= location.x);
        case LEFT:
            return (self.location.y == location.y && self.location.x > location.x && self.endLocation.x <= location.x);
        case UP:
            return (self.location.x == location.x && self.location.y < location.y && self.endLocation.y >= location.y);
        case DOWN:
            return (self.location.x == location.x && self.location.y > location.y && self.endLocation.y <= location.y);
        case NONE:
        default:
            break;
    }
    return NO;
}

- (Location) locationAtOrder:(int)order
{
    if(order > 0) {
        int x=-1;int y=-1;
        switch ([self direction]) {
            case DOWN:
                x = self.location.x;
                y = self.location.y - order;
                break;
                
            case UP:
                x = self.location.x;
                y = self.location.y + order;
                break;
            
            case LEFT:
                x = self.location.x - order;
                y = self.location.y;
                break;
                
            case RIGHT:
                x = self.location.x + order;
                y = self.location.y;
                break;
                
            default:
                break;
        }
        return LocationMake(x, y);
    }
    return LocationMake(-1, -1);
}

- (void) markWateredLocationsIn:(NSMutableDictionary *)bitMap
{
    for(int i=1; i<=[self getSize];i++)
       [bitMap setValue:@"1" forKey:LocationToString([self locationAtOrder:i])];
}

@end
