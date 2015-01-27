//
//  GameData.h
//  Chant
//
//  Created by Sudjeev Singh on 9/9/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameData : NSObject
@property (strong, nonatomic) NSString* home;
@property (strong, nonatomic) NSString* away;
@property (strong, nonatomic) NSString* quarter;
@property (strong, nonatomic) NSDate* date;
@property (assign, nonatomic) NSTimeInterval* timeRemaining;
@property (strong, nonatomic) NSNumber* homeScore;
@property (strong, nonatomic) NSNumber* awayScore;
@property (strong, nonatomic) NSString* gameId;
@property (strong, nonatomic) NSString* started;
@property (strong, nonatomic) NSString* status;
@end
