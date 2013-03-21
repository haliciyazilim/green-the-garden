//
//  IAPHelper.h
//  GreenTheGarden
//
//  Created by Alperen Kavun on 10.01.2013.
//
//

#import <StoreKit/StoreKit.h>

#define IAPHelperProductPurchasedNotification @"IAPHelperProductPurchasedNotification"

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPHelper : NSObject

@property NSDictionary *iProducts;
@property NSArray* products;

- (id)initWithProductsDictionary:(NSDictionary *)products;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

- (BOOL)canMakePurchases;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)buyProduct:(SKProduct *)product;
- (void)restoreCompletedTransactions;
- (void)removeActivity;
@end