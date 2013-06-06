//
//  DiMAboutUs.m
//  Dim
//
//  Created by Abdullah Karacabey on 4/10/13.
//  Copyright (c) 2013 Halici Yazilim. All rights reserved.
//

#import "AboutUs.h"

@implementation AboutUs{
    
    NSMutableArray * dictCredits;   // Dictionary of cast ['Programmer', ['Abdullah','Alperen','Yunus']]
    
    UIScrollView * scrollView;      // contains cast, it is subview of mask
    float categoryPadding;          // Bottom Padding between 2 categories
    float categoryHeaderPadding;    // Bottom padding header of cetagory
    float personsPadding;           // Bottom padding person of category
    float fontSizeL;                // Font size header of category
    float fontSizeM;                // Font size person of catefory
    NSString * fontHeader;          // Font header of category
    NSString * fontPerson;          // Font header of person
    
    NSDate * startTime;
    float difference;
    int didScrolled;
    float contentSize;
    float animationTime;
    UIColor * textColor;
    UIColor * headerColor;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        
        dictCredits=[[NSMutableArray alloc] init];
        
        textColor=[UIColor whiteColor];
        headerColor=[UIColor colorWithRed:0.702 green:1.0 blue:0.502 alpha:1.0];

        fontHeader = @"Rabbit On The Moon";
        fontPerson = @"Rabbit On The Moon";
        
        
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone){
            categoryPadding=50;
            categoryHeaderPadding=40;
            personsPadding=25;
            fontSizeL=15;
            fontSizeM=13;
            
        }else if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
            categoryPadding=50;
            categoryHeaderPadding=40;
            personsPadding=25;
            fontSizeL=28;
            fontSizeM=24;

        }
        
        animationTime=22.0f;
      
        self.clipsToBounds=YES;
        
        scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        
        NSLog(@"ScrollView %f, %f, %f, %f", scrollView.frame.origin.x,scrollView.frame.origin.y,scrollView.frame.size.width,scrollView.frame.size.height);
        [scrollView setShowsHorizontalScrollIndicator:NO];
        [scrollView setShowsVerticalScrollIndicator:NO];
        [scrollView setBackgroundColor:[UIColor clearColor]];
        
        NSArray * programmers=[[NSArray alloc] initWithObjects:@"Eren HALICI",@"Yunus Eren GÜZEL", @"Abdullah KARACABEY",@"Alperen KAVUN", nil];
        NSArray * art=[[NSArray alloc] initWithObjects:@"Egemen Dursun", nil];
        NSArray * music=[[NSArray alloc] initWithObjects:@"Onur IŞIKLI",@"Eren HALICI", @" ",@" ", nil];
        
        NSArray * companyInformation=[[NSArray alloc] initWithObjects:@"ODTÜ-Halıcı Yazılımevi",@"İnönü Bulvarı 06531",@"ODTÜ-Teknokent/ANKARA",@"iletisim@halici.com.tr", nil];
        NSArray * copyRight=[[NSArray alloc] initWithObjects:@"Copyright © 2013",@"www.brainquire.com", nil];
        
        [self addCategoryWithName:@"HALICI BİLGİ İŞLEM A.Ş." andPersons:companyInformation];
        [self addCategoryWithName:@"PROGRAMLAMA" andPersons:programmers];
        [self addCategoryWithName:@"TASARIM" andPersons:art];
        [self addCategoryWithName:@"MUSİK" andPersons:music];
        [self addCategoryWithName:@" " andPersons:copyRight];
        
//        [self setBackgroundColor:[UIColor redColor]];
        [self prepareView];

    }
    
    return self;
}
-(void) addCategoryWithName: (NSString *) name  andPersons: (NSArray *) arrayPerson{
    NSArray * array=[[NSArray alloc] initWithObjects:name, arrayPerson, nil];
    
    [dictCredits addObject:array];
}
-(void) prepareView{
//    NSLog(@"prepareView");
    
    float place=[self frame].size.height;
    for(NSArray * array in dictCredits){
        
        
        
        UILabel * lblHeader=[[UILabel alloc] initWithFrame:CGRectMake(0.0, place, self.frame.size.width, fontSizeL+fontSizeL*0.25)];
        [lblHeader setText:[array objectAtIndex:0]];
        [lblHeader setTextAlignment:NSTextAlignmentCenter];
        [lblHeader setFont:[UIFont fontWithName:fontHeader size:fontSizeL]];
        [lblHeader setBackgroundColor:[UIColor clearColor]];
        [lblHeader setTextColor:headerColor];
        [scrollView addSubview:lblHeader];
        place+=categoryHeaderPadding;
        
        NSArray * personArray=[array objectAtIndex:1];
        
        for(int i=0; i<personArray.count;i++){
            
            
            UILabel * lblPerson=[[UILabel alloc] initWithFrame:CGRectMake(0.0, place, self.frame.size.width, fontSizeM+fontSizeM*0.25)];
            [lblPerson setText:personArray[i]];
            
            [lblPerson setTextAlignment:NSTextAlignmentCenter];
            [lblPerson setFont:[UIFont fontWithName:fontPerson size:fontSizeM]];
            [lblPerson  setTextColor:textColor];
            [lblPerson setBackgroundColor:[UIColor clearColor]];
            [scrollView addSubview:lblPerson];
            
            
            place+=personsPadding;
        }
        place+=categoryPadding;
        
        
    }
    place+=[self frame].size.height*0.4-categoryPadding;
//    NSLog(@"prepareView place: %f",place);
    
    contentSize=place;
    
    [scrollView setContentSize:CGSizeMake(self.frame.size.width, contentSize)];
    
    [self addSubview:scrollView];
    
    [self startAnimation];
    
}


-(void) startAnimation{
    NSLog(@"Animation Started, contentsSize: %f",contentSize);
    startTime=[NSDate date];
    [scrollView setUserInteractionEnabled:YES];
    [UIScrollView beginAnimations:nil context:NULL];
    [UIScrollView setAnimationDuration:animationTime];
    [UIScrollView setAnimationCurve:UIViewAnimationCurveLinear];
    [scrollView setDelegate:self];
    [scrollView setContentOffset:CGPointMake(0, contentSize-[self frame].size.height)];
    [UIScrollView commitAnimations];
    didScrolled=0;
    
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    didScrolled++;
    if(didScrolled==2)
        [self scrollViewTap];
}

-(void) scrollViewTap
{
    [scrollView.layer removeAllAnimations];
    difference = [[NSDate date] timeIntervalSinceDate:startTime];
    float actualOffset=(contentSize-[self frame].size.height)/animationTime*difference;

    [scrollView setContentOffset:CGPointMake(0, actualOffset)];
}


@end
