//
//  InfoScreenView.m
//  Green The Garden
//
//  Created by Yunus Eren Guzel on 5/28/13.
//
//

#import "InfoScreenView.h"
#import "Flurry.h"
#import "GreenTheGardenGCSpecificValues.h"

@implementation InfoScreenView
{
    UIView * backgroundUIView;
}
- (id)init
{
    self = [super init];
    if (self) {
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        UIImageView *backgroundImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inapp_menu_frame.png"]];
        backgroundUIView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, winSize.height)];
        
        
        UIImageView * background=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inapp_back.png" ]];
        CGFloat bgWidth=background.frame.size.width;
        CGFloat bgHeight=background.frame.size.height;
        
        UIButton * btnClose=[UIButton buttonWithType:UIButtonTypeCustom];
        [btnClose setFrame:CGRectMake(bgWidth-55.0,10.0, 45.0, 45.0)];
        [btnClose setBackgroundImage:[UIImage imageNamed:@"inapp_btn_close.png"] forState:UIControlStateNormal];
        [btnClose setBackgroundImage:[UIImage imageNamed:@"inapp_btn_close_hover.png"] forState:UIControlStateHighlighted];
        [btnClose addTarget:self action:@selector(closeInfoScreen) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIView * mask=[[UIView alloc]initWithFrame:CGRectMake(20, 40, bgWidth-40, bgHeight-80)];
        [mask setBackgroundColor:[UIColor clearColor]];
        mask.clipsToBounds=YES;
        
        
        UIView * credits=[[UIView alloc]initWithFrame:CGRectMake(0, mask.frame.size.width-80, mask.frame.size.width, winSize.height)];
        [credits setBackgroundColor:[UIColor clearColor]];
        
        float fontSizeL = 28.0;
        float fontSizeM = 24.0;
        NSString *font = @"Rabbit On The Moon";
        UIColor *color = [UIColor whiteColor];
        UIColor *color2 = [UIColor colorWithRed:0.702 green:1.0 blue:0.502 alpha:1.0];
        // Company Name
        UILabel * cName=[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0, credits.frame.size.width, 40.0)];
        [cName setFont:[UIFont fontWithName:font size:fontSizeL]];
        [cName setTextColor:[UIColor whiteColor]];
        [cName setShadowColor:[UIColor blackColor]];
        [cName setShadowOffset:CGSizeMake(1, 1)];
        [cName setTextAlignment:NSTextAlignmentCenter];
        [cName setBackgroundColor:[UIColor clearColor]];
        [cName setText:@"HALICI BİLGİ İŞLEM A.Ş."];
        
        // Adress
        UILabel * cAdress=[[UILabel alloc] initWithFrame:CGRectMake(0.0, 40, credits.frame.size.width, 120)];
        [cAdress setFont:[UIFont fontWithName:font size:fontSizeM]];
        [cAdress setTextColor:color2];
        [cAdress setTextAlignment:NSTextAlignmentCenter];
        [cAdress setBackgroundColor:[UIColor clearColor]];
        [cAdress setNumberOfLines:3];
        [cAdress setText:@"ODTÜ-Halıcı Yazılımevi \nİnönü Bulvarı 06531 \nODTÜ-Teknokent/ANKARA"];
        
        // Mail
        UILabel * cMail=[[UILabel alloc] initWithFrame:CGRectMake(0.0, 160, credits.frame.size.width, 40.0)];
        [cMail setFont:[UIFont fontWithName:font size:fontSizeM]];
        [cMail setTextColor:color2];
        [cMail setTextAlignment:NSTextAlignmentCenter];
        [cMail setBackgroundColor:[UIColor clearColor]];
        [cMail setText:@"iletisim@halici.com.tr"];
        
        
        // Programming
        UILabel * cProgramming=[[UILabel alloc] initWithFrame:CGRectMake(0.0, 240, credits.frame.size.width, 40.0)];
        [cProgramming setFont:[UIFont fontWithName:font size:fontSizeL]];
        [cProgramming setTextColor:color];
        [cProgramming setShadowColor:[UIColor blackColor]];
        [cProgramming setShadowOffset:CGSizeMake(1, 1)];
        [cProgramming setTextAlignment:NSTextAlignmentCenter];
        [cProgramming setBackgroundColor:[UIColor clearColor]];
        [cProgramming setText:NSLocalizedString(@"PROGRAMMING",nil)];
        
        
        // Names
        NSArray * names=[[NSArray alloc] initWithObjects:@"Eren HALICI",@"Yunus Eren GÜZEL", @"Abdullah KARACABEY",@"Alperen KAVUN", nil];
        for(int i=0; i<names.count;i++){
            UILabel * cName=[[UILabel alloc] initWithFrame:CGRectMake(0.0, 300+i*40, credits.frame.size.width, 40.0)];
            [cName setFont:[UIFont fontWithName:font size:fontSizeM]];
            [cName setTextColor:color2];
            [cName setTextAlignment:NSTextAlignmentCenter];
            [cName setBackgroundColor:[UIColor clearColor]];
            [cName setNumberOfLines:2];
            [cName setText:names[i]];
            [credits addSubview:cName];
        }
        
        
        // Art
        UILabel * cArt=[[UILabel alloc] initWithFrame:CGRectMake(0.0, 500, credits.frame.size.width, 40.0)];
        [cArt setFont:[UIFont fontWithName:font size:fontSizeL]];
        [cArt setTextColor:color];
        [cArt setShadowColor:[UIColor blackColor]];
        [cArt setShadowOffset:CGSizeMake(1, 1)];
        [cArt setTextAlignment:NSTextAlignmentCenter];
        [cArt setBackgroundColor:[UIColor clearColor]];
        [cArt setText:NSLocalizedString(@"ART", nil)];
        
        UILabel * cArtName=[[UILabel alloc] initWithFrame:CGRectMake(0.0, 540, credits.frame.size.width, 40.0)];
        [cArtName setFont:[UIFont fontWithName:@"Rabbit On The Moon" size:fontSizeM]];
        [cArtName setTextColor:color2];
        [cArtName setTextAlignment:NSTextAlignmentCenter];
        [cArtName setBackgroundColor:[UIColor clearColor]];
        [cArtName setNumberOfLines:2];
        [cArtName setText:@"Ebuzer Egemen DURSUN"];
        
        
        // Music
        UILabel * cMusic=[[UILabel alloc] initWithFrame:CGRectMake(0.0, 620, credits.frame.size.width, 40.0)];
        [cMusic setFont:[UIFont fontWithName:font size:fontSizeL]];
        [cMusic setTextColor:color];
        [cMusic setShadowColor:[UIColor blackColor]];
        [cMusic setShadowOffset:CGSizeMake(1, 1)];
        [cMusic setTextAlignment:NSTextAlignmentCenter];
        [cMusic setBackgroundColor:[UIColor clearColor]];
        [cMusic setText:NSLocalizedString(@"MUSIC", nil)];
        
        NSArray * namesMusic=[[NSArray alloc] initWithObjects:@"Onur IŞIKLI",@"Eren HALICI", nil];
        for(int i=0; i<namesMusic.count;i++){
            UILabel * cName=[[UILabel alloc] initWithFrame:CGRectMake(0.0, 660+i*40, credits.frame.size.width, 40.0)];
            [cName setFont:[UIFont fontWithName:font size:fontSizeM]];
            [cName setTextColor:color2];
            [cName setTextAlignment:NSTextAlignmentCenter];
            [cName setBackgroundColor:[UIColor clearColor]];
            [cName setNumberOfLines:2];
            [cName setText:namesMusic[i]];
            [credits addSubview:cName];
        }
        
        
        // Copyright
        UILabel * cCRight=[[UILabel alloc] initWithFrame:CGRectMake(0.0, 860, credits.frame.size.width, 40.0)];
        [cCRight setFont:[UIFont fontWithName:font size:fontSizeL]];
        [cCRight setTextColor:color];
        [cCRight setShadowColor:[UIColor blackColor]];
        [cCRight setShadowOffset:CGSizeMake(1, 1)];
        [cCRight setTextAlignment:NSTextAlignmentCenter];
        [cCRight setBackgroundColor:[UIColor clearColor]];
        [cCRight setText:@"Copyright © 2013"];
        
        
        
        [credits addSubview:cName];
        [credits addSubview:cAdress];
        [credits addSubview:cMail];
        [credits addSubview:cProgramming];
        [credits addSubview:cArt];
        [credits addSubview:cArtName];
        [credits addSubview:cMusic];
        [credits addSubview:cCRight];
        [mask addSubview:credits];
        
        UIView * infoScreen=[[UIView alloc] initWithFrame:CGRectMake((winSize.width-bgWidth)/2, (winSize.height-bgHeight)/2, bgWidth, bgHeight)];
        //    infoScreen.clipsToBounds=YES;
        [infoScreen setBackgroundColor:[UIColor clearColor]];
        
        [infoScreen addSubview:background];
        [infoScreen addSubview:mask];
        [infoScreen addSubview:btnClose];
        
        [backgroundUIView addSubview:backgroundImgView];
        [backgroundUIView addSubview:infoScreen];
        [[[CCDirector sharedDirector] view]addSubview:backgroundUIView];
        
        //    cName.transform=CGAffineTransformMakeTranslation(0, 0);
        //    CGRect frame=cName.frame;
        //    frame.origin.y=550.0;
        //    cName.frame=frame;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:30.0f];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDelegate:self];
        //    [UIView setAnimationDidStopSelector:@selector(closeInfoScreen)];
        
        CGAffineTransform transform=CGAffineTransformMakeTranslation(0, -1050);
        credits.transform=transform;
        [UIView commitAnimations];
    }
    return self;
}
-(void)closeInfoScreen{
    [backgroundUIView removeFromSuperview];
    
    [Flurry endTimedEvent:kFlurryEventInfoScreenView withParameters:nil];
}


@end
