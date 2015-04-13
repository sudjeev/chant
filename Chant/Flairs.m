//
//  Flairs.m
//  Chant
//
//  Created by Sudjeev Singh on 2/27/15.
//  Copyright (c) 2015 SudjeevSingh. All rights reserved.
//

#import "Flairs.h"

@implementation Flairs
//want a single instance I can call up to provide flairs
+ (instancetype)allFlairs
{
    static Flairs *allFlairs = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        allFlairs = [[Flairs alloc] init];
        NSArray* keys = [[NSArray alloc] initWithObjects: @"Philadelphia 76ers",@"Milwaukee Bucks",@"Chicago Bulls", @"Cleveland Cavaliers", @"Boston Celtics", @"Los Angeles Clippers", @"Memphis Grizzlies",@"Atlanta Hawks", @"Miami Heat", @"Charlotte Hornets", @"Utah Jazz", @"Sacramento Kings", @"New York Knicks", @"Los Angeles Lakers", @"Orlando Magic", @"Dallas Mavericks", @"Brooklyn Nets", @"Denver Nuggets", @"Indiana Pacers", @"New Orleans Pelicans", @"Detroit Pistons", @"Toronto Raptors", @"Houston Rockets", @"San Antonio Spurs", @"Phoenix Suns", @"Oklahoma City Thunder", @"Minnesota Timberwolves", @"Portland Trail Blazers", @"Golden State Warriors", @"Washington Wizards", nil];
        
        NSArray* images = @[[UIImage imageNamed:@"76ers"], [UIImage imageNamed:@"Bucks"],[UIImage imageNamed:@"Bulls"],[UIImage imageNamed:@"Cavaliers"],[UIImage imageNamed:@"Celtics"],[UIImage imageNamed:@"Clippers"],[UIImage imageNamed:@"Grizzlies"],[UIImage imageNamed:@"Hawks"],[UIImage imageNamed:@"Heat"],[UIImage imageNamed:@"Hornets"],[UIImage imageNamed:@"Jazz"],[UIImage imageNamed:@"Kings"],[UIImage imageNamed:@"Knicks"],[UIImage imageNamed:@"Lakers"],[UIImage imageNamed:@"Magic"],[UIImage imageNamed:@"Mavericks"],[UIImage imageNamed:@"Nets"],[UIImage imageNamed:@"Nuggets"],[UIImage imageNamed:@"Pacers"],[UIImage imageNamed:@"Pelicans"],[UIImage imageNamed:@"Pistons"],[UIImage imageNamed:@"Raptors"],[UIImage imageNamed:@"Rockets"],[UIImage imageNamed:@"Spurs"],[UIImage imageNamed:@"Suns"],[UIImage imageNamed:@"Thunder"],[UIImage imageNamed:@"Timberwolves"],[UIImage imageNamed:@"TrailBlazers"],[UIImage imageNamed:@"Warriors"],[UIImage imageNamed:@"Wizards"]];

        NSArray* teams = [[NSArray alloc] initWithObjects: @"76ers",@"Bucks",@"Bulls", @"Cavaliers", @"Celtics", @"Clippers", @"Grizzlies",@"Hawks", @"Heat", @"Hornets", @"Jazz", @"Kings", @"Knicks", @"Lakers", @"Magic", @"Mavericks", @"Nets", @"Nuggets", @"Pacers", @"Pelicans", @"Pistons", @"Raptors", @"Rockets", @"Spurs", @"Suns", @"Thunder", @"Timberwolves", @"Trailblazers", @"Warriors", @"Wizards", nil];
        


        allFlairs.dict = [NSDictionary dictionaryWithObjects:images forKeys:keys];
        allFlairs.teams = [NSDictionary dictionaryWithObjects:teams forKeys:keys];
        allFlairs.fullTeam = [NSDictionary dictionaryWithObjects:keys forKeys:teams];
        
    });
    
    return allFlairs;
}

- (id)init
{
    self = [super init];
    return self;
}

@end
