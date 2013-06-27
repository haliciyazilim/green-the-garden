//
//  Util.h
//  OkParcalari
//
//  Created by Yunus Eren Guzel on 12/24/12.
//
//

#import <Foundation/Foundation.h>

NSString* LocalizedImageName(NSString* name, NSString* extension);

@interface Util : NSObject

+ (Util*) sharedInstance;

- (NSArray *) getRandomStringsWithCapacity:(int)capacity andIsLoading:(BOOL)isLoading;

@end
