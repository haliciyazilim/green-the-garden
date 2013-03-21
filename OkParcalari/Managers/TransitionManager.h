//
//  TransitionManager.h
//  GreenTheGarden
//
//  Created by Alperen Kavun on 28.01.2013.
//
//

#import <Foundation/Foundation.h>

@interface TransitionManager : NSObject

typedef void (^ TransitionBlock)();

+ (TransitionManager*)sharedInstance;

- (void) makeTransitionWithBlock:(TransitionBlock)transitionBlock;

@end
