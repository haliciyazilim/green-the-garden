//
//  ArrowGameLayer.h
//  OkParcalari
//
//  Created by Eren Halici on 06.12.2012.
//
//

#import "Facebook.h"
#import "cocos2d.h"
#import "ArrowGame.h"
#import "ArrowBase.h"
#import "Util.h"

//@class Stopwatch;

@interface ArrowGameLayer : CCLayer <FBDialogDelegate, UIAlertViewDelegate>

+(CCScene *) sceneWithFile:(NSString*)fileName;
- (void) initializeGameWithFile:(NSString*)fileName;

@property ArrowGame *arrowGame;
@property BOOL isRestaurantOpened;
@property BOOL isMenuOpened;
@property BOOL isGameEnded;
@property BOOL isAnyAlertShown;
//@property Stopwatch *gameTimer;

@property (strong, nonatomic) Facebook *facebook;

- (void) restartGame;
- (void) inGameMenuWillClose;
- (void) returnToMainMenu;
- (void) gameEnded:(int)starCount andElapsedSeconds:(int)elapsedSeconds;
- (void) showInGameMenu:(BOOL)isRestaurant;

+(ArrowGameLayer*)lastInstance;
+(void)cleanLastInstance;

@end
