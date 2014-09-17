//
//  ScheduleCell.m
//  Chant
//
//  Created by Sudjeev Singh on 9/5/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "ScheduleCell.h"

@interface ScheduleCell ()
@property (nonatomic, strong) GameData* data;
@end

@implementation ScheduleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UILabel *a = [[UILabel alloc] init];
        self.homeLabel= a;
        self.awayLabel = a;
        self.homeScoreLabel = a;
        self.awayScoreLabel = a;
        self.quarterLabel = a;
    }
    return self;
}

- (void) updateCellWithGameData:(GameData *)data
{
    self.data = data;
    self.homeLabel.text = data.home;
    self.awayLabel.text = data.away;
    self.quarterLabel.text = data.quarter;
    self.homeScoreLabel.text = [data.homeScore stringValue];
    self.awayScoreLabel.text = [data.awayScore stringValue];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
