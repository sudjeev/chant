//
//  CommentViewController.h
//  Chant
//
//  Created by Sudjeev Singh on 9/15/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentViewScoreCell.h"
#import "GameData.h"

@interface CommentViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) IBOutlet UICollectionView* collectionView;
- (BOOL)updateControllerWithGameData: (GameData* ) data;
@end
