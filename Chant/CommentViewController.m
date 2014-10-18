//
//  CommentViewController.m
//  Chant
//
//  Created by Sudjeev Singh on 9/15/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "CommentViewController.h"
#import "CommentTableViewCell.h"
#import "CommentViewFeedCell.h"
#import "GameData.h"

@interface CommentViewController ()
@property(nonatomic, strong) GameData* data;
@end

@implementation CommentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //need to register the collectionview cell
    [self.collectionView registerNib:[UINib nibWithNibName:@"CommentViewScoreCell" bundle:nil] forCellWithReuseIdentifier:@"CommentViewScoreCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"CommentViewFeedCell" bundle:nil] forCellWithReuseIdentifier:@"CommentViewFeedCell"];
    self.navigationController.navigationBar.translucent = NO;
}

- (BOOL)updateControllerWithGameData: (GameData* ) data
{
    if(data == nil)
    {
        return NO;
    }
    
    self.data = data;
    self.navigationItem.title = [NSString stringWithFormat:@"%@ at %@", self.data.away, self.data.home];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

        CommentViewFeedCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CommentViewFeedCell" forIndexPath:indexPath];
        [cell setupWithGameData:self.data];
        return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{

    return CGSizeMake(310, 450);
}

@end
