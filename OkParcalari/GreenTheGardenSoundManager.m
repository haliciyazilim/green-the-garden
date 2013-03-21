//
//  GreenTheGardenSoundManager.m
//  GreenTheGarden
//
//  Created by Alperen Kavun on 15.01.2013.
//
//

#import "GreenTheGardenSoundManager.h"
#import "SimpleAudioEngine.h"

@implementation GreenTheGardenSoundManager

static GreenTheGardenSoundManager *sharedSoundManager = nil;

+ (GreenTheGardenSoundManager *) sharedSoundManager {
    if(!sharedSoundManager){
        sharedSoundManager = [[GreenTheGardenSoundManager alloc] init];
    }
    return sharedSoundManager;
}

- (id) init {
    if(self = [super init]) {
        self.backgroundMusic = @"GreenTheGardenMenu.mp3";
        
        self.effects = @{@"move" : @"move.mp3", @"star" : @"star.mp3", @"success" : @"success.mp3"};
        
        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:self.backgroundMusic];
        for (NSString *effect in self.effects) {
            [[SimpleAudioEngine sharedEngine] preloadEffect:effect];
        }
        
        NSNumber *isMusicMuted = [[NSUserDefaults standardUserDefaults] objectForKey:@"isBackgroundMusicMuted"];
        if(!isMusicMuted){
            self.isBackgroundMusicMuted = NO;
        }
        else{
            self.isBackgroundMusicMuted = [isMusicMuted boolValue];
        }
        NSNumber *isEffMuted = [[NSUserDefaults standardUserDefaults] objectForKey:@"isEffectsMuted"];
        if(!isEffMuted){
            self.isEffectsMuted = NO;
        }
        else{
            self.isEffectsMuted = [isEffMuted boolValue];
        }

    }
    return self;
}

@end
