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
    self.homeLabel.text = data.homeFull;
    self.awayLabel.text = data.awayFull;

    
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
    
    NSArray* keys = [[NSArray alloc] initWithObjects: @"Philadelphia 76ers",@"Milwaukee Bucks",@"Chicago Bulls", @"Cleveland Cavaliers", @"Boston Celtics", @"Los Angeles Clippers", @"Memphis Grizzlies",@"Atlanta Hawks", @"Miami Heat", @"Charlotte Hornets", @"Utah Jazz", @"Sacramento Kings", @"New York Knicks", @"Los Angeles Lakers", @"Orlando Magic", @"Dallas Mavericks", @"Brooklyn Nets", @"Denver Nuggets", @"Indiana Pacers", @"New Orleans Pelicans", @"Detroit Pistons", @"Toronto Raptors", @"Houston Rockets", @"San Antonio Spurs", @"Phoenix Suns", @"Oklahoma City Thunder", @"Minnesota Timberwolves", @"Portland Trailblazers", @"Golden State Warriors", @"Washington Wizards", nil];
    
    NSArray* images = @[[UIImage imageNamed:@"76ers"], [UIImage imageNamed:@"Bucks"],[UIImage imageNamed:@"Bulls"],[UIImage imageNamed:@"Cavaliers"],[UIImage imageNamed:@"Celtics"],[UIImage imageNamed:@"Clippers"],[UIImage imageNamed:@"Grizzlies"],[UIImage imageNamed:@"Hawks"],[UIImage imageNamed:@"Heat"],[UIImage imageNamed:@"Hornets"],[UIImage imageNamed:@"Jazz"],[UIImage imageNamed:@"Kings"],[UIImage imageNamed:@"Knicks"],[UIImage imageNamed:@"Lakers"],[UIImage imageNamed:@"Magic"],[UIImage imageNamed:@"Mavericks"],[UIImage imageNamed:@"Nets"],[UIImage imageNamed:@"Nuggets"],[UIImage imageNamed:@"Pacers"],[UIImage imageNamed:@"Pelicans"],[UIImage imageNamed:@"Pistons"],[UIImage imageNamed:@"Raptors"],[UIImage imageNamed:@"Rockets"],[UIImage imageNamed:@"Spurs"],[UIImage imageNamed:@"Suns"],[UIImage imageNamed:@"Thunder"],[UIImage imageNamed:@"Timberwolves"],[UIImage imageNamed:@"TrailBlazers"],[UIImage imageNamed:@"Warriors"],[UIImage imageNamed:@"Wizards"]];
    
    self.dictionary = [NSDictionary dictionaryWithObjects:images forKeys:keys];
    
    self.homeLogo.image = [self.dictionary objectForKey:data.homeFull];
    self.awayLogo.image  =[self.dictionary objectForKey:data.awayFull];
    

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
