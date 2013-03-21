//
//  Arrow.h
//  OkParcalari
//
//  Created by Eren Halici on 10.12.2012.
//
//

#import "MapEntity.h"

#import "ArrowBase.h"

#import "GameMap.h"

@class ArrowBase;

@interface Arrow : MapEntity

@property (nonatomic) Location endLocation;

@property BOOL isSelected;

@property Direction direction;

@property ArrowBase* base;

- (id)initWithLocation:(Location)location andDirection:(Direction)direction forBase:(ArrowBase*)base;

- (void)animateBackgrounds;

- (int) getSize;

- (Location) locationAtOrder:(int)order;

- (void) removeSquirts;

- (BOOL) isDeformed;

@end
