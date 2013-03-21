//
//  WaterSpray.h
//  OkParcalari
//
//  Created by Alperen Kavun on 02.01.2013.
//
//

#import "MapEntity.h"
#import "Squirt.h"

@interface WaterSpray : CCNode

@property Squirt *squirt1;
@property Squirt *squirt2;
@property Squirt *squirt3;

- (id) initWithPoint:(CGPoint)point;
- (void) scheduleSpraying;

-(void) callScheduleSprayingWithDelay:(ccTime)delay;
@end
