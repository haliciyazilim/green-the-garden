//
//  GameCenterManager.h
//  OkParcalari
//
//  Created by Alperen Kavun on 27.12.2012.
//
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface GameCenterManager : NSObject

@property (nonatomic) BOOL isGameCenterAvailable;
@property (nonatomic) BOOL isUserAuthenticated;
@property NSArray * leaderboardCategories;
@property NSArray * leaderboardTitles;

+ (GameCenterManager *) sharedInstance;
- (void) authenticateLocalUser;
- (void) submitScore:(int)score category:(NSString*)category;

-(void) getScores;
@end
