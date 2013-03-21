//
//  Squirt.m
//  OkParcalari
//
//  Created by Alperen Kavun on 31.12.2012.
//
//

#import "Squirt.h"
#import "CCBAnimationManager.h"

@implementation Squirt

- (void) runAnimationWithSequenceNamed:(NSString *)sequenceName{
    CCBAnimationManager* animationManager = self.userObject;
    [animationManager runAnimationsForSequenceNamed:sequenceName];
}

@end
