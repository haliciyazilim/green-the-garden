
//  TutorialManager.m
//  GreenTheGarden
//
//  Created by Yunus Eren Guzel on 1/25/13.
//
//

#import "TutorialManager.h"
#import "AchievementManager.h"
#import "GreenTheGardenGCSpecificValues.h"
#import "ArrowGameLayer.h"
typedef void (^ IteratorBlock)();
@interface UISetTouchBeganView : UIView
-(void)setTouchesBegan:(IteratorBlock)block;
-(BOOL)isInsideTouchesBegan;
@end

@interface TutorialDescription : NSObject
@property NSString* text;
@property Location tile;
+(TutorialDescription*)descriptionWithText:(NSString*)text andTile:(Location)tile;
@end

@interface TutorialStep : NSObject
@property Location startTile;
@property Location targetTile;
@property NSArray* descriptions;
@property int currentDescription;

@end
@implementation TutorialStep
@end

@implementation TutorialManager
{
    NSString* mapId;
    NSMutableArray* tutorialSteps;
    BOOL isTutorialActive;
    int currentStepIndex;
    BOOL canInteract;
    UIImageView* currentTutorialArrow;
    Location lastMovedArrowEndLocation;
    UIImageView* balloonImageView;
    UIImageView* baseHighlight;
    UIImageView* tileHighlight;
    UIView* lastDialog;
}

static TutorialManager* currentInstance = nil;
+(TutorialManager *)sharedInstance
{
    if(currentInstance == nil){
        currentInstance = [[TutorialManager alloc] init];
    }
    
    return currentInstance;
}

-(id)init
{
    if(self = [super init]){
        canInteract = NO;
        isTutorialActive = NO;
        mapId = @"10000";
        lastMovedArrowEndLocation = LocationMake(-1, -1);
        tutorialSteps = [[NSMutableArray alloc] init];
        
        NSMutableArray* descriptions;
        
        TutorialStep* firstStep = [[TutorialStep alloc] init];
        firstStep.startTile = LocationMake(0, 0);
        firstStep.targetTile = LocationMake(0, 9);
        firstStep.currentDescription = 0;
        descriptions  = [[NSMutableArray alloc] init];
        [descriptions addObject:[TutorialDescription descriptionWithText:NSLocalizedString(@"TUTORIAL_1_0", nil) andTile:LocationMake(0, 0)]];
        [descriptions addObject:[TutorialDescription descriptionWithText:NSLocalizedString(@"TUTORIAL_1_1", nil) andTile:LocationMake(0, 0)]];
        [descriptions addObject:[TutorialDescription descriptionWithText:NSLocalizedString(@"TUTORIAL_1_2", nil) andTile:LocationMake(0, 0)]];
        [descriptions addObject:[TutorialDescription descriptionWithText:NSLocalizedString(@"TUTORIAL_1_3", nil) andTile:LocationMake(0, 0)]];
        firstStep.descriptions = descriptions;
        [tutorialSteps addObject:firstStep];
//
        TutorialStep* secondStep = [[TutorialStep alloc] init];
        secondStep.startTile = LocationMake(2,4);
        secondStep.targetTile = LocationMake(2, 1);
        secondStep.currentDescription = 0;
        descriptions  = [[NSMutableArray alloc] init];
        [descriptions addObject:[TutorialDescription descriptionWithText:NSLocalizedString(@"TUTORIAL_2_0", nil) andTile:LocationMake(2, 1)]];
        [descriptions addObject:[TutorialDescription descriptionWithText:NSLocalizedString(@"TUTORIAL_2_1", nil) andTile:LocationMake(2, 1)]];
        [descriptions addObject:[TutorialDescription descriptionWithText:NSLocalizedString(@"TUTORIAL_2_2", nil) andTile:LocationMake(2, 4)]];
        secondStep.descriptions = descriptions;
        [tutorialSteps addObject:secondStep];
        
        TutorialStep* thirdStep = [[TutorialStep alloc] init];
        thirdStep.startTile = LocationMake(8,8);
        thirdStep.targetTile = LocationMake(1, 8);
        descriptions  = [[NSMutableArray alloc] init];
        [descriptions addObject:[TutorialDescription descriptionWithText:NSLocalizedString(@"TUTORIAL_3_0", nil) andTile:LocationMake(1, 8)]];
        thirdStep.descriptions = descriptions;
        [tutorialSteps addObject:thirdStep];
        
//        TutorialStep* forthStep = [[TutorialStep alloc] init];
//        forthStep.startTile = LocationMake(1, 0);
//        forthStep.targetTile = LocationMake(9, 0);
//        descriptions  = [[NSMutableArray alloc] init];
//        [descriptions addObject:[TutorialDescription descriptionWithText:@"Go on and water 9 tiles by dragging upwards from this pump." andTile:LocationMake(0, 0)]];
//        forthStep.descriptions = descriptions;
//        [tutorialSteps addObject:forthStep];
        
        
        TutorialStep* fifthStep = [[TutorialStep alloc] init];
        fifthStep.startTile = LocationMake(7, 7);
        fifthStep.targetTile = LocationMake(7, 3);
        descriptions  = [[NSMutableArray alloc] init];
        [descriptions addObject:[TutorialDescription descriptionWithText:NSLocalizedString(@"TUTORIAL_5_0", nil) andTile:LocationMake(7, 7)]];
        [descriptions addObject:[TutorialDescription descriptionWithText:NSLocalizedString(@"TUTORIAL_5_1", nil) andTile:LocationMake(7, 7)]];
        [descriptions addObject:[TutorialDescription descriptionWithText:NSLocalizedString(@"TUTORIAL_5_2", nil) andTile:LocationMake(7, 7)]];
        [descriptions addObject:[TutorialDescription descriptionWithText:NSLocalizedString(@"TUTORIAL_5_3", nil) andTile:LocationMake(7, 7)]];
        [descriptions addObject:[TutorialDescription descriptionWithText:NSLocalizedString(@"TUTORIAL_5_4", nil) andTile:LocationMake(7, 7)]];
        fifthStep.descriptions = descriptions;
        [tutorialSteps addObject:fifthStep];
    }
    return self;
}

-(BOOL)isTutorialEnabled
{
    return YES;
}

-(void)setTutorialEnabled
{
    
}

-(void)setTutorialDisabled
{
    
}

-(void)startTutorial
{
    isTutorialActive = YES;
    currentStepIndex =-1;
    NSString* tutorialStartMessage = NSLocalizedString(@"TUTORIAL_WELCOME", nil);
    [self showDialogMessage:tutorialStartMessage andCallback:^{
        [self nextStep];
    }];
}

-(void)finishTutorial
{
    isTutorialActive = NO;
    
    [balloonImageView removeFromSuperview];
    balloonImageView = nil;
    
    [currentTutorialArrow removeFromSuperview];
    currentTutorialArrow = nil;
    
    currentStepIndex = -1;
    [tutorialSteps removeAllObjects];
    
    [baseHighlight removeFromSuperview];
    baseHighlight = nil;
    
    [tileHighlight removeFromSuperview];
    tileHighlight = nil;
    
    currentInstance = nil;

    
}

-(void) nextStep
{
//    NSLog(@"next step");
    currentStepIndex++;
    if(currentStepIndex >= [tutorialSteps count]){
        [self showDialogMessage:NSLocalizedString(@"TUTORIAL_COMPLETED", nil) andCallback:^{
            [self finishTutorial];
            [[AchievementManager sharedAchievementManager] submitAchievement:kAchievementBabySteps percentComplete:100.0];
        }];
        return;
    }
    TutorialStep* step = [tutorialSteps objectAtIndex:currentStepIndex];
    
    baseHighlight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tut_highlight.png"]];
    CGPoint basePoint = [self pointFromLocation:step.startTile];
    baseHighlight.frame = CGRectMake(basePoint.x, basePoint.y, baseHighlight.image.size.width, baseHighlight.image.size.height);
    [[[CCDirector sharedDirector] view] addSubview:baseHighlight];
    
    
    [self nextDescription];
    
}


-(CGPoint) pointFromLocation:(Location)location
{
    return [[GameMap sharedInstance] pointFromGridLocation:LocationMake(location.x,[[GameMap sharedInstance] rows] - location.y - 1)];
}

-(void)shortenCurrentArrowForArrow:(Arrow*)arrow
{
    int arrowSize = [arrow getSize];
    if(arrow.endLocation.x == lastMovedArrowEndLocation.x && arrow.endLocation.y == lastMovedArrowEndLocation.y)
        return;
    else
        lastMovedArrowEndLocation = arrow.endLocation;
    
    TutorialStep* currentStep = (TutorialStep*)[tutorialSteps objectAtIndex:currentStepIndex];
    Location from = currentStep.startTile;
    Location to = currentStep.targetTile;
    if(arrowSize > differenceBetweenTwoLocations(from, to))
        arrowSize = differenceBetweenTwoLocations(from, to);
    
    
    
    Location startingLocation;
    if(arrowSize > 0)
        startingLocation = [arrow locationAtOrder:arrowSize];
    else
        startingLocation = arrow.base.location;
    switch (arrow.direction) {
        case DOWN:
            startingLocation.y -= 1;
            break;
        case RIGHT:
            startingLocation.x += 1;
            break;
            
        default:
            break;
    }
    CGPoint startingPoint = [self pointFromLocation:startingLocation];
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        switch(arrow.direction){
            case UP:
                [currentTutorialArrow setFrame:CGRectMake(currentTutorialArrow.frame.origin.x, currentTutorialArrow.frame.origin.y, currentTutorialArrow.frame.size.width,abs(currentTutorialArrow.frame.origin.y - startingPoint.y))];
                break;
            case DOWN:
                [currentTutorialArrow setFrame:CGRectMake(startingPoint.x, startingPoint.y, currentTutorialArrow.frame.size.width,abs(currentTutorialArrow.frame.origin.y + currentTutorialArrow.frame.size.height - startingPoint.y))];
                break;
            case LEFT:
                [currentTutorialArrow setFrame:CGRectMake(currentTutorialArrow.frame.origin.x, currentTutorialArrow.frame.origin.y, abs(currentTutorialArrow.frame.origin.x - startingPoint.x),currentTutorialArrow.frame.size.height)];
                break;
            case RIGHT:
                [currentTutorialArrow setFrame:CGRectMake(startingPoint.x, startingPoint.y, abs(currentTutorialArrow.frame.origin.x + currentTutorialArrow.frame.size.width - startingPoint.x),currentTutorialArrow.frame.size.height)];
                break;
            case NONE:
                break;
        }
    } completion:^(BOOL finished) {
        
    }];
}

-(void)showHelperSignsFrom:(Location)from to:(Location)to onCompletion:(IteratorBlock)block
{
    Direction direction = DirectionFromTwoLocations(from, to);
    CGPoint toPoint = [self pointFromLocation:to];
    Arrow* arrow = [(ArrowBase*)[[GameMap sharedInstance] entityAtLocation:from] arrowAtDirection:DirectionFromTwoLocations(from, to)];
    CGPoint startingPoint = [self pointFromLocation:[arrow locationAtOrder:1]];
    int difference = differenceBetweenTwoLocations(from, to);
    UIImageView* tutorialArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tut_arrow.png"]];
    tutorialArrow = [self rotatedImageView:tutorialArrow forDirection:direction];
    [tutorialArrow setFrame:CGRectMake(startingPoint.x, startingPoint.y, [GameMap sharedInstance].tileSize.width * 1, tutorialArrow.image.size.height)];
    [[[CCDirector sharedDirector] view] addSubview:tutorialArrow];
    [tutorialArrow setClipsToBounds:YES];
    [tutorialArrow setContentMode:UIViewContentModeRight];
    tutorialArrow.alpha = 0.0;
    
    [UIView animateWithDuration:0.5 animations:^{
        tutorialArrow.alpha = 1.0;
    }];
    float duration = 0.2 * difference;
    [UIView animateWithDuration:duration delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        switch (direction) {
            case UP:
                [tutorialArrow setFrame:CGRectMake(toPoint.x, toPoint.y, [GameMap sharedInstance].tileSize.width * 1, [GameMap sharedInstance].tileSize.width * difference)];
                break;
            case DOWN:
                [tutorialArrow setFrame:CGRectMake(startingPoint.x, startingPoint.y, [GameMap sharedInstance].tileSize.width * 1, [GameMap sharedInstance].tileSize.width * difference)];
                break;
            case LEFT:
                [tutorialArrow setFrame:CGRectMake(toPoint.x, toPoint.y, [GameMap sharedInstance].tileSize.width * difference, [GameMap sharedInstance].tileSize.width * 1)];
                break;
            case RIGHT:
                [tutorialArrow setFrame:CGRectMake(startingPoint.x, startingPoint.y, [GameMap sharedInstance].tileSize.width * difference, [GameMap sharedInstance].tileSize.width * 1)];
                break;
            case NONE:
                break;
        }
    } completion:^(BOOL finished) {
            
    }];
    currentTutorialArrow = tutorialArrow;
}

-(UIImageView*)rotatedImageView:(UIImageView*)imageView forDirection:(Direction)direction
{
    float angle;
    UIViewContentMode contentMode;
    switch (direction) {
        case UP:
            angle = - M_PI * 0.5;
            contentMode = UIViewContentModeRight;
            break;
        case DOWN:
            angle = + M_PI * 0.5;
            contentMode = UIViewContentModeLeft;
            break;
        case LEFT:
            angle = - M_PI * 1;
            contentMode = UIViewContentModeTop;
            break;
        case RIGHT:
            angle = 0;
            contentMode = UIViewContentModeBottom;
            break;
        case NONE:
            return imageView;
    }
    imageView.transform = CGAffineTransformRotate(imageView.transform, angle);
    return imageView;
}
-(void)skipTutorial
{
    
}

-(BOOL)isTutorialActive
{
    return isTutorialActive;
}

-(BOOL)isTutoringMap:(NSString*)mapFileName
{
    return [mapId compare:mapFileName] == 0;
}

-(BOOL)shouldDisableOtherEntities
{
    return YES;
}

-(void)pauseTutorial
{
    [currentTutorialArrow setAlpha:0.0];
    [balloonImageView setAlpha:0.0];
    [baseHighlight setAlpha:0.0];
    [tileHighlight setAlpha:0.0];
    [lastDialog setAlpha:0.0];
}

-(void)resumeTutorial
{
    [baseHighlight setAlpha:1.0];
    [tileHighlight setAlpha:1.0];
    [currentTutorialArrow setAlpha:1.0];
    [balloonImageView setAlpha:1.0];
    [lastDialog setAlpha:1.0];
}

-(BOOL)isCorrectEntitity:(ArrowBase*)entity
{
        
    Location startLocation = ((TutorialStep*)[tutorialSteps objectAtIndex:currentStepIndex]).startTile;
    return entity.location.x == startLocation.x && entity.location.y == startLocation.y;
    
}

-(void)updateForMovedBase:(ArrowBase*)arrowBase
{
    if(![self isCorrectEntitity:arrowBase])
        return;
    TutorialStep* currentStep = (TutorialStep*)[tutorialSteps objectAtIndex:currentStepIndex];
    Location from = currentStep.startTile;
    Location to = currentStep.targetTile;
    Arrow* arrow = [arrowBase arrowAtDirection:DirectionFromTwoLocations(from, to)];
    [self shortenCurrentArrowForArrow:arrow];
}

-(void)checkEntity:(ArrowBase*)entity
{
    if(![self isCorrectEntitity:entity])
        return;
    
    TutorialStep* currentStep = (TutorialStep*)[tutorialSteps objectAtIndex:currentStepIndex];
    Location from = currentStep.startTile;
    Location to = currentStep.targetTile;
    
    Arrow* arrow = [entity arrowAtDirection:DirectionFromTwoLocations(from, to)];
    BOOL result = NO;
    if(arrow.endLocation.x == to.x && arrow.endLocation.y == to.y)
        result = YES;
    if(result == YES){
        
        [baseHighlight removeFromSuperview];
        baseHighlight = nil;
        
        [balloonImageView removeFromSuperview];
        balloonImageView = nil;

        __block UIImageView* previousTutorialArrow = currentTutorialArrow;
        currentTutorialArrow = nil;
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            previousTutorialArrow.alpha = 0;
        } completion:^(BOOL finished) {
            [previousTutorialArrow removeFromSuperview];
            previousTutorialArrow = nil;
        }];
        [self performSelector:@selector(nextStep) withObject:self afterDelay:0.0];
    }
    else{
        [self shortenCurrentArrowForArrow:arrow];
    }
}

-(void)nextDescription
{
    TutorialStep* currentStep = (TutorialStep*)[tutorialSteps objectAtIndex:currentStepIndex];
    TutorialDescription* description = (TutorialDescription*)[currentStep.descriptions objectAtIndex:currentStep.currentDescription];
    
    if(currentStep.currentDescription == [currentStep.descriptions count]-1){
        
        [tileHighlight removeFromSuperview];
        tileHighlight = nil;
        [self showHelperSignsFrom:currentStep.startTile to:currentStep.targetTile onCompletion:^{}];
        
        [self showInstruction:description.text forTile:description.tile];
    }
    else{
        currentStep.currentDescription++;
        [self showInstruction:description.text forTile:description.tile withCompletionBlock:^{
            [self nextDescription];
        }];
        
        [tileHighlight removeFromSuperview];
        tileHighlight = nil;
        if(currentStep.startTile.x != description.tile.x || currentStep.startTile.y != description.tile.y){
            tileHighlight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tut_highlight.png"]];
            CGPoint tilePoint = [self pointFromLocation:description.tile];
            tileHighlight.frame = CGRectMake(tilePoint.x, tilePoint.y, tileHighlight.image.size.width, tileHighlight.image.size.height);
            [[[CCDirector sharedDirector] view] addSubview:tileHighlight];
            [[[CCDirector sharedDirector] view] insertSubview:tileHighlight belowSubview:balloonImageView];
        }
        
    }
    
}

-(void)showDialogMessage:(NSString*)message andCallback:(IteratorBlock)block
{
//    [[ArrowGameLayer lastInstance] setIsAnyAlertShown:YES];
    UIView* dialog = [[UIView alloc] init];
    UIImage* backgroundImage = [UIImage imageNamed:@"inapp_back.png"];
    [dialog setFrame:CGRectMake(512, 384, 0, 0)];
    [dialog setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"inapp_back.png"]]];
    [dialog setUserInteractionEnabled:NO];
    [dialog setClipsToBounds:YES];
    dialog.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        [dialog setFrame:CGRectMake(512-backgroundImage.size.width*0.5, 384 - backgroundImage.size.height*0.5, backgroundImage.size.width, backgroundImage.size.height)];
    }];
    [UIView animateWithDuration:0.5 animations:^{
        dialog.alpha = 1;
    }];
    
    UIFont* font = [UIFont fontWithName:@"Rabbit On The Moon" size:24.0];
    
    UILabel* tapToCloseLabel = [[UILabel alloc] init];
    [tapToCloseLabel setText:[NSString stringWithFormat:@" %@ ",NSLocalizedString(@"TAP_TO_CLOSE", nil)]];
    [tapToCloseLabel setFrame:CGRectMake(0.0, dialog.frame.size.height-80, dialog.frame.size.width, 30.0)];
    [tapToCloseLabel setTextAlignment:NSTextAlignmentCenter];
    [tapToCloseLabel setBackgroundColor:[UIColor clearColor]];
    [tapToCloseLabel setTextColor:[UIColor whiteColor]];
    [tapToCloseLabel setFont:font];
    [dialog addSubview:tapToCloseLabel];
    
    UITextView* messageTextView = [[UITextView alloc] init];
    [messageTextView setFrame:CGRectMake(50.0, 50.0, dialog.frame.size.width-100.0, dialog.frame.size.height - 150)];
    [messageTextView setText:message];
    [messageTextView setFont:font];
    [messageTextView setTextAlignment:NSTextAlignmentCenter];
    [messageTextView setTextColor:[UIColor whiteColor]];
    [messageTextView setBackgroundColor:[UIColor clearColor]];
    [dialog addSubview:messageTextView];
    
    lastDialog = dialog;
    
    UISetTouchBeganView* background = [[UISetTouchBeganView alloc] init];
    
    [background setUserInteractionEnabled:YES];
    [background setFrame:CGRectMake(0, 0, 1024, 768)];
    
    [[ArrowGame lastInstance] pauseTimer];
    
    [[[CCDirector sharedDirector] view] addSubview:background];
    [[[CCDirector sharedDirector] view] addSubview:dialog];
    
    __weak UISetTouchBeganView* weakBackground = background;
    [background setTouchesBegan:^{
        [dialog removeFromSuperview];
        [weakBackground removeFromSuperview];
        lastDialog = nil;
        [[ArrowGame lastInstance] resumeTimer];
//        [[ArrowGameLayer lastInstance] setIsAnyAlertShown:NO];
        block();
    }];
    [background.superview bringSubviewToFront:background];
}

-(void)closeDialog
{
    
}

-(void)showInstruction:(NSString*)message forTile:(Location)location withCompletionBlock:(IteratorBlock)block
{
    UISetTouchBeganView* background = [[UISetTouchBeganView alloc] init];
    background.frame = CGRectMake(0, 0, 1024, 768);
    [[[CCDirector sharedDirector] view] addSubview:background];
    
    __weak UISetTouchBeganView* weakBackground = background;
    [self showInstruction:message forTile:location];
    __block BOOL insideBlock = NO;
    [background setTouchesBegan:^{
        if(insideBlock == YES) return;
        else insideBlock = YES;
        [UIView animateWithDuration:0.2 animations:^{
            CGPoint point = [self pointFromLocation:location];
            [balloonImageView setFrame:CGRectMake(point.x-29, point.y+10, balloonImageView.image.size.width, 0)];
        } completion:^(BOOL finished) {
            [weakBackground removeFromSuperview];
            [balloonImageView removeFromSuperview];
            balloonImageView = nil;
            block();
        }];
    }];
}

-(void)showInstruction:(NSString*)message forTile:(Location)location
{
    CGPoint point = [self pointFromLocation:location];
    UIImage* balloonImage = [UIImage imageNamed:@"tut_dialog.png"];
//    balloonImage = [self imageWithImage:balloonImage convertToSize:CGSizeMake(300.0, 100.0)];
//    balloonImage
    
    balloonImageView = [[UIImageView alloc] initWithImage:balloonImage];
    [balloonImageView setFrame:CGRectMake(point.x-29, point.y+10, balloonImageView.image.size.width, 0)];
    [balloonImageView setClipsToBounds:YES];
    [UIView animateWithDuration:0.1 animations:^{
        [balloonImageView setFrame:CGRectMake(point.x-29, point.y-balloonImageView.image.size.height+10, balloonImageView.image.size.width, balloonImageView.image.size.height)];
    }];
    
//    UILabel* instructionLabel = [[UILabel alloc] init];
//    instructionLabel.frame = CGRectMake(20, 10, 220, 50);
//    [instructionLabel setText:message];
//    [instructionLabel setBackgroundColor:[UIColor clearColor]];
//    [instructionLabel setNumberOfLines:2];
//    [instructionLabel setContentMode:UIViewContentModeTop];
//    [balloonImageView addSubview:instructionLabel];

    UITextView* instructionTextView = [[UITextView alloc] init];
    instructionTextView.frame = CGRectMake(5, 0, balloonImage.size.width-30, 60);
    [instructionTextView setText:message];
    [instructionTextView setTextColor:[UIColor whiteColor]];
    [instructionTextView setBackgroundColor:[UIColor clearColor]];
    [instructionTextView setContentMode:UIViewContentModeTop];
    [instructionTextView setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0]];
    
    [balloonImageView addSubview:instructionTextView];
    
    
    [[[CCDirector sharedDirector] view] addSubview:balloonImageView];
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}
@end

@implementation TutorialDescription

+ (TutorialDescription *)descriptionWithText:(NSString *)text andTile :(Location)tile
{
    TutorialDescription* description = [[TutorialDescription alloc] init];
    description.text = text;
    description.tile = tile;
    return description;
}

@end

@implementation UISetTouchBeganView
{
    IteratorBlock touchBeganBlock;
    BOOL isInsideTouchesBegan;
}


-(void)setTouchesBegan:(IteratorBlock)block
{
    touchBeganBlock = block;
}

-(BOOL)isInsideTouchesBegan
{
    return isInsideTouchesBegan;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    isInsideTouchesBegan = YES;
    if(touchBeganBlock != nil)
        touchBeganBlock();
    isInsideTouchesBegan = NO;
}

@end