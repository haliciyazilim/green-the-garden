//
//  MapSelectionScrollView.m
//  Green The Garden
//
//  Created by Yunus Eren Guzel on 5/31/13.
//
//

#import "MapSelectionScrollView.h"
#import "ArrowGameMap.h"
#import "MapSelectionLayer.h"

@implementation MapSelectionScrollView
{
    int rowCount;
    CGFloat contentPadding;
    CGSize buttonSize;
    CGSize unitSize;
    CGFloat topMargin;
    UIImage* passiveStar;
    UIImage* activeStar;
    MapPackage* currentMapPackage;
    NSArray* maps;
}
- (id)initWithMapPackage:(MapPackage *)mapPackage
{
    if(self = [super init]){
        buttonSize = CGSizeMake(111.0, 128.0);
        unitSize = CGSizeMake(120.0, 135.0);
        topMargin = 26.0;
        contentPadding = 400.0;
        rowCount = 3;
        passiveStar = [UIImage imageNamed:@"level_star_passive.png"];
        activeStar  = [UIImage imageNamed:@"level_star_active.png"];
        currentMapPackage = mapPackage;
        [self loadMapIcons];
    }
    return self;
}



- (void) loadMapIcons
{
    
    maps = [ArrowGameMap loadMapsFromFile:currentMapPackage.name];
    
    [self setContentSize:CGSizeMake(unitSize.width*ceil((float)maps.count/(float)rowCount)+unitSize.width*0.5+contentPadding*2.0, unitSize.height*rowCount)];
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.contentSize.height)];
    int index = 0;
    for (Map* map in maps) {
        [self buttonForMap:map atIndex:index];
        index++;
    }
}

- (UIButton*) buttonForMap:(Map*)map atIndex:(int)index
{
    
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(
                                                                  (index/rowCount)*unitSize.width + (unitSize.width*0.5*(index%rowCount))+contentPadding+(index>=12?unitSize.width*0.5:0),
                                                                  (index%rowCount)*unitSize.height,
                                                                  buttonSize.width,
                                                                  buttonSize.height)];
    button.tag = [map.mapId intValue];
    [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"map_%@_bg.png",stringOfDifficulty(map.difficulty)]] forState:UIControlStateNormal];
    
    BOOL isPassive = map.isLocked || (!map.isPurchased && [currentMapPackage.name isEqualToString:STANDART_PACKAGE]) ;
    
    [self addSubview:button];
    if(map.order < 10){
        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"level_num_%d.png",map.order]]];
        view.frame = CGRectMake((float)(buttonSize.width - view.image.size.width) * 0.5+5.0, topMargin, view.image.size.width, view.image.size.height);
        [button addSubview:view];
    }
    else{
        UIImageView* firstDigit  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"level_num_%d.png",map.order/10]]];
        UIImageView* secondDigit = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"level_num_%d.png",map.order%10]]];
        CGFloat width = firstDigit.image.size.width + secondDigit.image.size.width;
        firstDigit.frame  = CGRectMake((buttonSize.width - width) * 0.5 + 5.0, topMargin, firstDigit.image.size.width,firstDigit.image.size.height);
        secondDigit.frame = CGRectMake((buttonSize.width - width) * 0.5 + 5.0 + firstDigit.image.size.width, topMargin, secondDigit.image.size.width,secondDigit.image.size.height);
        [button addSubview:firstDigit];
        [button addSubview:secondDigit];
    }
    
    if(isPassive){
        UIImageView* passiveLayer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"map_%@_mask.png",stringOfDifficulty(map.difficulty)]]];
        [passiveLayer setAlpha:0.80];
        
        [button addSubview:passiveLayer];
        
        if(!map.isPurchased && [currentMapPackage.name isEqualToString:STANDART_PACKAGE]){
            [passiveLayer setAlpha:1.0];
            [button addTarget:self action:@selector(addStore) forControlEvents:UIControlEventTouchUpInside];
            UIImageView* lock = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"level_locked.png"]];
            lock.frame = CGRectMake(buttonSize.width*0.5 - lock.image.size.width*0.5 + 5.0, buttonSize.height * 0.5 , lock.image.size.width, lock.image.size.height);
            [button addSubview:lock];
        }
        
    }else {
        
        [button addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        
        if(map.isFinished){
            for(int i=0;i<3;i++){
                UIImageView* view;
                if(i < [map getStarCount])
                    view = [[UIImageView alloc] initWithImage:activeStar];
                else
                    view = [[UIImageView alloc] initWithImage:passiveStar];
                view.frame = CGRectMake((buttonSize.width - passiveStar.size.width * 3) * 0.5 + 5.0 + passiveStar.size.width * i, buttonSize.height - passiveStar.size.height - 20.0, passiveStar.size.width, passiveStar.size.height);
                [button addSubview:view];
            }
        }
    }
    
    
    return button;
}


-(void) refreshScrollView
{
    for (UIView* view in self.subviews) {
        if([view isKindOfClass:[UIButton class]]){
            [view removeFromSuperview];
        }
    }
    [self loadMapIcons];
}

- (void) openGameFor:(UIButton*)button
{
    Map* selectedMap;
    for(Map* map in maps){
        if([map.mapId intValue] == button.tag){
            selectedMap = map;
        }
    }
    
    if(selectedMap == nil){
        return;
    }
    if([selectedMap isPurchased] == NO){
        [self openStore];
    }
    else{
        [[MapSelectionLayer lastInstance] openGameForMap:selectedMap];
    }
}

- (void) openStore
{
    [[MapSelectionLayer lastInstance] openStoreForPackage:currentMapPackage];
}

@end
