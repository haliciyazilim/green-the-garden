//
//  AchievementManager.m
//  GreenTheGarden
//
//  Created by Alperen Kavun on 22.01.2013.
//
//

#import "Flurry.h"
#import "AchievementManager.h"
#import "GameCenterManager.h"
#import "DatabaseManager.h"
#import "GreenTheGardenGCSpecificValues.h"


@implementation AchievementManager

static AchievementManager * sharedAchievementManager=nil;

+(AchievementManager *) sharedAchievementManager{
    if(!sharedAchievementManager){
        sharedAchievementManager=[[AchievementManager alloc]init];
    }
    return sharedAchievementManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self getAchievements];
        
    }
    return self;
}

-(void) getAchievements{
    NSMutableDictionary *achievementDescriptions = [[NSMutableDictionary alloc] init];

    [GKAchievementDescription loadAchievementDescriptionsWithCompletionHandler:^(NSArray *descriptions, NSError *error) {
        if (error != nil) {
            ;
        }
        for (GKAchievementDescription *achievementDescription in descriptions) {
            [achievementDescriptions setObject:achievementDescription forKey:achievementDescription.identifier];
        }
    }];
    _achievementDescriptions=achievementDescriptions;
}

- (void) loadAchievements
{
    NSMutableDictionary *achievementsDictionary = [[NSMutableDictionary alloc] init];
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error)
     {
         if (error == nil)
         {
             for (GKAchievement* achievement in achievements){
                 if(achievement.percentComplete==100.0){
                     [achievementsDictionary setObject: achievement forKey: achievement.identifier];
                 }
             }
         }
         else{
             ;
         }
         _achievementsDictionary=achievementsDictionary;
     }];
}

- (void) submitAchievement: (NSString*) identifier percentComplete: (float) percent;
{
    
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier: identifier];
    
    BOOL isExist=NO;
    GKAchievement * loadedAchievement=[[GKAchievement alloc] initWithIdentifier:[_achievementsDictionary objectForKey:achievement.identifier]];
    
    if(loadedAchievement.identifier!=nil){
        NSLog(@" Var: %@", loadedAchievement.identifier);
        isExist=YES;
    }
    
    if (achievement && isExist==NO)
    {
        NSLog(@" Yok: %@", identifier);

        achievement.percentComplete = percent;
        achievement.showsCompletionBanner = YES; 
        [achievement reportAchievementWithCompletionHandler:^(NSError *error)
         {
             if (achievement.percentComplete==100.0) {
                 GKAchievementDescription *achievementDescription=[[GKAchievementDescription alloc] init];
                 achievementDescription=[_achievementDescriptions objectForKey:achievement.identifier];
                 [_achievementsDictionary setObject: achievement forKey: achievement.identifier];
                 
                 NSLog(@"Achievement OK: %@",identifier);
             }
             dispatch_async(dispatch_get_main_queue(), ^(void)
                            {
                                if (error == nil) {
                                    
                                    
                                    NSLog(@"dict: %@",_achievementsDictionary.description);
                                    
                                    [[AchievementManager sharedAchievementManager] loadAchievements];
                                } else {
                                    ;
                                }
                            });
             if (error != nil)
             {
                 ;
             }
         }];
    }
}

- (void) resetAchievements
{
    _achievementsDictionary = [[NSMutableDictionary alloc] init];
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error){
         if (error != nil){
             ;
         }
    }];
}

// Specific Methods

-(void)checkAchievementFastMindQuickHands: (Map*) playedMap{
    if(playedMap.score.intValue<60)
    [self submitAchievement:kAchievementFastMindQuickHands percentComplete:100];
}


-(void) checkAchievementMapsStars:(Map*) playedMap{
    // Check maps for difficulty
    NSArray * maps=[[DatabaseManager sharedInstance] getMapsForDifficulty:playedMap.difficulty];
    int mapsCount=maps.count;
    int solvedMapsCount=0;
    int star3Count=0;
    
    int solvedFreeMapsCount=0;
    int freeMapsStar3Count=0;
    
    for(Map * map in maps){
        if (map.isFinished) {
            solvedMapsCount++;
            if(map.order<=kFreeMapsCount)
                solvedFreeMapsCount++;
        }
        if (map.getStarCount==3) {
            star3Count++;
            if(map.order<=kFreeMapsCount)
                freeMapsStar3Count++;
        }
    }

        NSString * achievementCompletionist=[[NSString alloc] init];
        NSString * achievementPerfectionist=[[NSString alloc] init];
        switch (playedMap.difficulty) {
            case 1:
                achievementCompletionist=kAchievementEasyMapsCompletionist;
                achievementPerfectionist =kAchievementEasyMapsPerfectionist;
                break;
            case 2:
                achievementCompletionist=kAchievementNormalMapsCompletionist;
                achievementPerfectionist=kAchievementNormalMapsPerfectionist;
                break;
            case 3:
                achievementCompletionist=kAchievementHardMapsCompletionist;
                achievementPerfectionist=kAchievementHardMapsPerfectionist;
                break;
            case 4:
                achievementCompletionist=kAchievementInsaneMapsCompletionist;
                achievementPerfectionist=kAchievementInsaneMapsPerfectionist;
                break;
            default:
                break;
        }
    double solvedMapPercentComplete=solvedMapsCount*100/mapsCount;
    double star3PercentComplete=star3Count*100/mapsCount;
    
    double solvedFreeMapPercentComplete=solvedFreeMapsCount*100/kFreeMapsCount;
    double freeStar3PercentComplete=freeMapsStar3Count*100/kFreeMapsCount;
    
//    Maps with difficulty
    [self submitAchievement:achievementCompletionist percentComplete:solvedMapPercentComplete];
    [self submitAchievement:achievementPerfectionist percentComplete:star3PercentComplete];
    
//    Free Maps
    [self submitAchievement:kAchievementFreeMapCompletionist percentComplete:solvedFreeMapPercentComplete];
    [self submitAchievement:kAchievementFreeMapsPerfectionist percentComplete:freeStar3PercentComplete];
    
    if ([self achievementsDictionary] != nil) {
        if ([[self achievementsDictionary] objectForKey:kAchievementFreeMapCompletionist] == nil) {
            if (solvedFreeMapPercentComplete == 100.0) {
                [Flurry logEvent:kFlurryEventAllFreeMapsPlayed];
            }
        }
    }
    
//    pathtuStardom
    if(playedMap.getStarCount==3)
        [self submitAchievement:kAchievementPathToStardom percentComplete:100.0];
}

@end
