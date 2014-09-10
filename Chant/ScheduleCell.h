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
@property (nonatomic, strong) GameData* data;
-(void)updateCellWithGameData: (GameData*) data;
@end
