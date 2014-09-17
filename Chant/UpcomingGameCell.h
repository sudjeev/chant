//
//  UpcomingGameCell.h
//  Chant
//
//  Created by Sudjeev Singh on 9/11/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameData.h"

@interface UpcomingGameCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel* gameLabel;
- (void) updateCellWithGameData: (GameData*) data;
@end
