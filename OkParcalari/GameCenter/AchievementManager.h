//
//  AchievementManager.h
//  GreenTheGarden
//
//  Created by Alperen Kavun on 22.01.2013.
//
//

#import <Foundation/Foundation.h>
#import "Map.h"

@interface AchievementManager : NSObject


@property NSMutableDictionary * achievementDescriptions;
@property(nonatomic, retain) NSMutableDictionary *achievementsDictionary;

+(AchievementManager *) sharedAchievementManager;

-(void) getAchievements;
- (void) loadAchievements;
-(void) submitAchievement: (NSString*) identifier percentComplete: (float) percent;
-(void)checkAchievementFastMindQuickHands: (Map*) playedMap;
-(void) checkAchievementMapsStars:(Map*) playedMap;
@end
