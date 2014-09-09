//
//  ScheduleCell.m
//  Chant
//
//  Created by Sudjeev Singh on 9/5/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "ScheduleCell.h"

@implementation ScheduleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
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
