//
//  SKProduct+LocalizedPrice.h
//  OkParcalari
//
//  Created by Alperen Kavun on 20.12.2012.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface SKProduct (LocalizedPrice)

@property (nonatomic, readonly) NSString *localizedPrice;

@end
