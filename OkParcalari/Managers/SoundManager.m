//
//  SoundManager.m
//  GreenTheGarden
//
//  Created by Abdullah Karacabey on 14.01.2013.
//
//

#import "SoundManager.h"
#import "SimpleAudioEngine.h"

@implementation SoundManager

static SoundManager *sharedSoundManager = nil;

+ (SoundManager *) sharedSoundManager {
    if(!sharedSoundManager){
        sharedSoundManager = [[SoundManager alloc] init];
    }
    return sharedSoundManager;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}


-(void)playBackgroundMusic{
    [self setIsBackgroundMusicMuted:_isBackgroundMusicMuted];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:_backgroundMusic loop:YES];
}

-(void)resumeBackgroundMusic{
    [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
}

-(void)stopBackgroundMusic{
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
}

-(void)playEffect:(NSString *)itemKey{
    [self setIsEffectsMuted:_isEffectsMuted];
    [[SimpleAudioEngine sharedEngine] playEffect:[self.effects objectForKey:itemKey]];
}
- (void) setIsBackgroundMusicMuted:(BOOL)isBackgroundMusicMuted {
    _isBackgroundMusicMuted = isBackgroundMusicMuted;
    
    if(isBackgroundMusicMuted){
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.0];
    }
    else{
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:1.0];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isBackgroundMusicMuted] forKey:@"isBackgroundMusicMuted"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setIsEffectsMuted:(BOOL)isEffectsMuted {
    _isEffectsMuted = isEffectsMuted;
    
    if(isEffectsMuted){
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.0];
    }
    else{
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:1.0];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isEffectsMuted] forKey:@"isEffectsMuted"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



@end
