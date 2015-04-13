//
//  ScheduleCell.m
//  Chant
//
//  Created by Sudjeev Singh on 9/5/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "ScheduleCell.h"
#import "Flairs.h"

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
    self.homeLabel.text = [[Flairs allFlairs].teams objectForKey:data.homeFull];
    self.awayLabel.text = [[Flairs allFlairs].teams objectForKey:data.awayFull];

    
    //update the status of the game and set text color accordingly
    self.status.text = data.status;
    
    if ([data.status isEqualToString:@"pregame"]) {
        self.status.textColor = [UIColor blueColor];
    }
    else if ([data.status isEqualToString:@"live"])
    {
        self.status.textColor = [UIColor greenColor];
    }
    else
    {
        self.status.textColor = [UIColor redColor];
    }
    
    self.uView.layer.cornerRadius = 5;
    self.uView.layer.masksToBounds = YES;
    
    
    self.homeLogo.image = [[Flairs allFlairs].dict objectForKey:data.homeFull];
    self.awayLogo.image  =[[Flairs allFlairs].dict objectForKey:data.awayFull];
    

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
