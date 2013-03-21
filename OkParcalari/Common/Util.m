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


@implementation Util



@end
