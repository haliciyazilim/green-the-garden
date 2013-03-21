//
//  SoundManager.h
//  GreenTheGarden
//
//  Created by Abdullah Karacabey on 14.01.2013.
//
//

#import <Foundation/Foundation.h>

@interface SoundManager : NSObject

@property NSString *backgroundMusic;
@property NSDictionary *effects;

@property (nonatomic) BOOL isBackgroundMusicMuted;
@property (nonatomic) BOOL isEffectsMuted;

+ (SoundManager *) sharedSoundManager;

-(void) playEffect :(NSString *) item;
-(void) playBackgroundMusic;
-(void) resumeBackgroundMusic;
-(void) stopBackgroundMusic;

@end
