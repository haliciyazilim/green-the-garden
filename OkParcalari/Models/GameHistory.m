//
//  GameHistory.m
//  OkParcalari
//
//  Created by Yunus Eren Guzel on 1/2/13.
//
//

#import "GameHistory.h"

#define SCORES_FILE_NAME "green_the_garden_game_history"
#define SCORES_FILE_EXTENSION "json"

@implementation Score

+(Score*)score:(int)s map:(NSString*)mapName
{
    Score* score = [[Score alloc] init];
    score.score = s;
    score.mapName = mapName;
    return score;
}

-(NSDictionary*)dictionary{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:self.score] forKey:@"score"];
    [dict setObject:self.mapName forKey:@"map"];
    return dict;
}

@end

@implementation GameHistory
+(NSMutableArray*)_scores
{
    static NSMutableArray* scores;
    if(scores == nil){
        scores = [[NSMutableArray alloc] init];
        [GameHistory readScoresFromFile];
    }
    return scores;
}

+(void)saveScore:(int)score forMap:(NSString*)map
{
    if([GameHistory scoreForMap:map] == nil)
    {
        Score* s = [Score score:score map:map];
        [[GameHistory _scores] addObject:s];
    }
    else if([[GameHistory scoreForMap:map] score] > score)
    {
        
        [[GameHistory scoreForMap:map] setScore:score];
    }
    [GameHistory writeScoresToFile];
}

+(NSArray*)scores
{
    return [GameHistory _scores];
}

+(Score*)scoreForMap:(NSString*)mapName
{
    for (Score* score in [GameHistory scores]) {
        if([[score mapName] compare:mapName] == 0)
            return score;
    }
    return nil;
}

+(void) writeScoresToFile
{
    NSMutableDictionary* json = [[NSMutableDictionary alloc] init];
    [json setObject:[NSNumber numberWithInt:1] forKey:@"version"];
    NSMutableArray* scores = [[NSMutableArray alloc] init];
    for (Score* s in [GameHistory scores]) {
        [scores addObject:[s dictionary]];
    }
    [json setObject:scores forKey:@"scores"];
    
//    NSString* jsonString = 	[writer stringWithObject:(NSDictionary*)json];
    NSString* jsonString = 	[json JSONRepresentation];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex: 0];
    NSString *docFile = [[docDir stringByAppendingPathComponent: [NSString stringWithUTF8String:SCORES_FILE_NAME]] stringByAppendingPathExtension:[NSString stringWithUTF8String:SCORES_FILE_EXTENSION]];
    [jsonString writeToFile:docFile atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

+(void) readScoresFromFile
{
    NSLog(@"start read scores from file");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex: 0];
    NSString *docFile = [[docDir stringByAppendingPathComponent: [NSString stringWithUTF8String:SCORES_FILE_NAME]] stringByAppendingPathExtension:[NSString stringWithUTF8String:SCORES_FILE_EXTENSION]];
    NSString* content = [NSString stringWithContentsOfFile:docFile
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    NSLog(@"%@",content);
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary* file = [parser objectWithString:content];
    
    [[GameHistory _scores] removeAllObjects];
    if( [(NSNumber*)[file valueForKey:@"version"] intValue] == 1){
        for(NSDictionary* s in [file objectForKey:@"scores"]){
            [GameHistory saveScore:[[s objectForKey:@"score"] intValue] forMap:[s objectForKey:@"map"] ];
        }
    }
    
}


@end
