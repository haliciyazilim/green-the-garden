//
//  GTGScrollView.m
//  Green The Garden
//
//  Created by Yunus Eren Guzel on 5/31/13.
//
//

#import "GTGScrollView.h"

@implementation GTGScrollView

- (id)init
{
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(0.0, 300.0, 1024.0, 400.0)];
        [self setShowsHorizontalScrollIndicator:NO];
        [self setShowsVerticalScrollIndicator:NO];

    }
    return self;
}
- (void)refreshScrollView
{
    
}

-(void)showWithCallback:(VoidBlock)block reverse:(BOOL)reverse
{
    [self setHidden:YES];
    if(reverse){
        [self setContentOffset:CGPointMake(self.contentSize.width+self.frame.size.width, 0.0)];
    }else{
        [self setContentOffset:CGPointMake(-self.frame.size.width, 0.0)];
    }
    [self setHidden:NO];
    [UIView animateWithDuration:0.5 animations:^{
        [self setContentOffset:CGPointMake(0.0, 0.0)];
    } completion:^(BOOL finished) {
        if(block != nil)
            block();
    }];
}


-(void)hideWithCallback:(VoidBlock)block reverse:(BOOL)reverse
{
    [UIView animateWithDuration:0.5 animations:^{
        if(reverse){
            [self setContentOffset:CGPointMake(self.contentSize.width + self.frame.size.width, 0.0)];
        }else{
            [self setContentOffset:CGPointMake(-self.frame.size.width, 0.0)];
        }
    } completion:^(BOOL finished) {
        if(block != nil)
            block();
    }];
}

//- (void) setContentOffset:(CGPoint)contentOffset interval:(CGFloat)interval callback:(VoidBlock)callback
//{
//    NSDate* initialDate = [NSDate date];
//    NSDate* endDate = [initialDate dateByAddingTimeInterval:interval];
//
//    TimerBlock block = ^(NSTimer* timer){
//        NSLog(@"here");
//        NSDate* currentDate = [NSDate date];
//        if([endDate timeIntervalSince1970] > [currentDate timeIntervalSince1970]){
//            CGFloat ratio = ([currentDate timeIntervalSinceDate:initialDate] / interval);
//            CGFloat x = contentOffset.x * ratio;
//            CGFloat y = contentOffset.y * ratio;
//            [self setContentOffset:CGPointMake([self contentOffset].x + x, [self contentOffset].y + y)];
//        } else {
//            [self setContentOffset:contentOffset];
//            callback();
//            [timer invalidate];
//        }
//    };
//    [[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(timerBlock:) userInfo:block repeats:YES] fire];
//    
//
//}
//
//- (void) timerBlock:(NSTimer*)timer{
//    TimerBlock block = timer.userInfo;
//    block(timer);
//}

@end
