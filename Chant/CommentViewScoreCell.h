//
//  CommentViewScoreCell.h
//  Chant
//
//  Created by Sudjeev Singh on 9/14/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameData.h"

@interface CommentViewScoreCell : UICollectionViewCell
@property (nonatomic, strong) IBOutlet UILabel* home;
@property (nonatomic, strong) IBOutlet UILabel* away;
@property (nonatomic, strong) IBOutlet UILabel* homeScore;
@property (nonatomic, strong) IBOutlet UILabel* awayScore;
@property (nonatomic, strong) IBOutlet UILabel* quarter;
@property (nonatomic, strong) IBOutlet UIView* view;
@property (nonatomic, strong) GameData* data;

- (void)updateCellWithGameData: (GameData*) data;
@end
