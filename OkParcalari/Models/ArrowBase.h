//
//  ArrowBase.h
//  OkParcalari
//
//  Created by Eren Halici on 07.12.2012.
//
//

#import <Foundation/Foundation.h>

#import "MapEntity.h"

#import "Arrow.h"

@class Arrow;

@interface ArrowBase : MapEntity

@property int size;

@property Arrow* upArrow;
@property Arrow* downArrow;
@property Arrow* leftArrow;
@property Arrow* rightArrow;

+ (ArrowBase*) arrowBaseFromDictionary:(NSDictionary*)dict;

+ (id) ArrowBaseWithLocation:(Location)location andSize:(int)size;

- (id) initWithLocation:(Location)location andSize:(int)size;

- (BOOL) isCorrect;

- (Arrow *) extendArrowWithEndLocation:(Location) endLocation;

- (Arrow *) compressArrowAtDirection:(Direction) direction;

- (Arrow *) arrowAtDirection:(Direction) direction;

- (BOOL) isDeformed;

- (void) showSize;

@end
