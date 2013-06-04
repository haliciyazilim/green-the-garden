//
//  GTGScrollView.h
//  Green The Garden
//
//  Created by Yunus Eren Guzel on 5/31/13.
//
//

#import <UIKit/UIKit.h>
typedef void (^VoidBlock)(void);
typedef void (^TimerBlock)(NSTimer*);

@interface GTGScrollView : UIScrollView

- (void) refreshScrollView;

- (void) showWithCallback:(VoidBlock)block reverse:(BOOL)reverse;

- (void) hideWithCallback:(VoidBlock)block reverse:(BOOL)reverse;

@end
