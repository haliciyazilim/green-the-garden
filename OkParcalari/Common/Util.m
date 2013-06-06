//
//  Util.m
//  OkParcalari
//
//  Created by Yunus Eren Guzel on 12/24/12.
//
//

#import "Util.h"

NSString* LocalizedImageName(NSString* name, NSString* extension){
    NSString* suffix = NSLocalizedString(@"IMAGE_FILENAME_SUFFIX", nil);
    if([suffix compare:@""] == 0)
        return [NSString stringWithFormat:@"%@.%@",name,extension];
    else
        return [NSString stringWithFormat:@"%@-%@.%@",name,suffix,extension];
}

static Util* sharedInstance = nil;

@implementation Util
{
    NSMutableDictionary* loadingStrings;
}

+ (Util*) sharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[Util alloc] init];
        
        [sharedInstance generateLoadingStrings];
    }
    
    return sharedInstance;
}
- (void) generateLoadingStrings {
    NSArray* englishStrings = @[@"Planting seeds...",
                                @"Warming the globe...",
                                @"Transporting soil...",
                                @"Cross-breeding tulips...",
                                @"Tiling pipes...",
                                @"Browning the garden...",
                                @"Pressurizing the pumps...",
                                @"Importing bees...",
                                @"Tiling tiles..."];
    
    NSArray* turkishStrings = @[@"Planting seeds...",
                                @"Warming the globe...",
                                @"Transporting soil...",
                                @"Cross-breeding tulips...",
                                @"Tiling pipes...",
                                @"Browning the garden...",
                                @"Pressurizing the pumps...",
                                @"Importing bees...",
                                @"Tiling tiles..."];
    
    loadingStrings = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    [loadingStrings setObject:englishStrings forKey:@"en"];
    [loadingStrings setObject:turkishStrings forKey:@"tr"];
    
}

- (NSArray *) getRandomStringsWithCapacity:(int)capacity {
    
    NSString* suffix = NSLocalizedString(@"IMAGE_FILENAME_SUFFIX", nil);
    
    NSArray* allStrings = [loadingStrings objectForKey:suffix];
    
    NSMutableArray* indexes = [self get:capacity randomIndexesWithCapacity:[allStrings count]];
    
    NSMutableArray* returnedStrings = [[NSMutableArray alloc] initWithCapacity:capacity];
    
    for (int i = 0; i < capacity; i++) {
        [returnedStrings addObject:[allStrings objectAtIndex:[[indexes objectAtIndex:i] intValue]]];
    }
    
    return returnedStrings;
}

- (NSMutableArray *) get:(int)number randomIndexesWithCapacity:(int)capacity
{
    int canAdd = 1;
    NSMutableArray* indexes = [[NSMutableArray alloc] initWithCapacity:number];
    int j = 0;
    while (j < number) {
        canAdd = 1;
        int random = arc4random() % capacity;
        for (NSNumber* number in indexes) {
            if ([number intValue] == random) {
                canAdd = 0;
            }
        }
        if (canAdd) {
            [indexes addObject:[NSNumber numberWithInt:random]];
            j++;
        }
    }
    
    return indexes;

}
@end
