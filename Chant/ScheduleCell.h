//
//  ScheduleCell.h
//  Chant
//
//  Created by Sudjeev Singh on 9/5/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameData.h"

@interface ScheduleCell : UITableViewCell

-(void)updateCellWithGameData: (GameData*) data;

@property (nonatomic, strong) IBOutlet UILabel* homeLabel;
@property (nonatomic, strong) IBOutlet UILabel* awayLabel;
@property (nonatomic, strong) IBOutlet UILabel* quarterLabel;
@property (nonatomic, strong) IBOutlet UILabel* homeScoreLabel;
@property (nonatomic, strong) IBOutlet UILabel* awayScoreLabel;

@end
