//
//  CommentViewScoreCell.m
//  Chant
//
//  Created by Sudjeev Singh on 9/14/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "CommentViewScoreCell.h"
#import "GameData.h"

@implementation CommentViewScoreCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)updateCellWithGameData: (GameData*) data
{
    self.data = data;
    self.home.text = self.data.home;
    self.homeScore.text = [self.data.homeScore stringValue];
    self.away.text = data.away;
    self.awayScore.text = [data.awayScore stringValue];
    self.quarter.text = data.quarter;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
