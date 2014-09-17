//
//  UpcomingGameCell.m
//  Chant
//
//  Created by Sudjeev Singh on 9/11/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "UpcomingGameCell.h"

@interface UpcomingGameCell ()
@property (nonatomic, strong) GameData* data;
@end

@implementation UpcomingGameCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void) updateCellWithGameData: (GameData*) data
{
    self.data = data;
    self.gameLabel.text = [NSString stringWithFormat:@"%@ vs %@", self.data.home, self.data.away];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
