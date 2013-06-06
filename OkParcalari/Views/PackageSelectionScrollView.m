//
//  PackageSelectionScrollView.m
//  Green The Garden
//
//  Created by Yunus Eren Guzel on 5/31/13.
//
//

#import "PackageSelectionScrollView.h"
#import "Map.h"
#import "MapSelectionLayer.h"

@implementation PackageSelectionScrollView
{
    int rowCount;
    CGFloat contentPadding;
    CGSize buttonSize;
    CGSize unitSize;
    CGFloat topMargin;

}
- (id)init
{
    self = [super init];
    if (self) {
        buttonSize = CGSizeMake(355.0, 195.0);
        unitSize = CGSizeMake(385.0, 205.0);
        topMargin = 5.0;
        contentPadding = 400.0;
        rowCount = 2;
        [self loadButtons];
    }
    return self;
}

- (UIButton*) buttonForMapPack:(MapPackage*)package atIndex:(int)index
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = package.packageId;

    button.frame = CGRectMake(
                            ceil(index/rowCount)*unitSize.width + ceil(unitSize.width*0.5*(index%rowCount))+contentPadding+(index>=12?unitSize.width*0.5:0),
                            (index%rowCount)*unitSize.height+topMargin,
                            buttonSize.width,
                            buttonSize.height);
    
    if([package isPurchased] || [[package name] isEqualToString:STANDART_PACKAGE]){
        [button addTarget:self action:@selector(openMapsFor:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [button addTarget:self action:@selector(openStoreFor:) forControlEvents:UIControlEventTouchUpInside];
        UIImageView* lock = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"package_lock-%@.png",NSLocalizedString(@"IMAGE_FILENAME_SUFFIX", nil)]]];
        [lock setFrame:CGRectMake(0.0,0.0,button.frame.size.width,button.frame.size.height)];
        [[button imageView] addSubview:lock];
    }
    [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@-%@.png",package.name,NSLocalizedString(@"IMAGE_FILENAME_SUFFIX", nil)]] forState:UIControlStateNormal];
    return button;

}

- (void) loadButtons
{
    int index=0;
    
    NSArray* packages = [MapPackage allPackages];
    
    for(MapPackage* package in packages){
        UIButton* button = [self buttonForMapPack:package atIndex:index];
        [self addSubview:button];
        index++;
    }
    
    [self setContentSize:CGSizeMake(unitSize.width*ceil((float)packages.count/(float)rowCount)+unitSize.width*0.5+contentPadding*1.5, unitSize.height*rowCount)];
    
}



- (void)refreshScrollView
{
    for (UIView* view in self.subviews) {
        if([view isKindOfClass:[UIButton class]]){
            [view removeFromSuperview];
        }
    }
    
    [self loadButtons];
}

- (void) openStoreFor:(UIButton*)button
{
    for(MapPackage* package in [MapPackage allPackages]){
        if(package.packageId == button.tag){
            [[MapSelectionLayer lastInstance] openStoreForPackage:package];
        }
    }
}

- (void) openMapsFor:(UIButton*)button
{
    for(MapPackage* package in [MapPackage allPackages]){
        if(package.packageId == button.tag){
            [[MapSelectionLayer lastInstance] showPackage:package];
        }
    }
}


@end
