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
#import "ReplyViewController.h"
#import "BoxScoreController.h"
#import "Reachability.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

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
    
    //connect with Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"CommentScreen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"CommentViewScoreCell" bundle:nil] forCellWithReuseIdentifier:@"CommentViewScoreCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"CommentViewFeedCell" bundle:nil] forCellWithReuseIdentifier:@"CommentViewFeedCell"];
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Box" style:UIBarButtonItemStylePlain target:self action:@selector(openBoxScore:)];
    
    //register for the notifcation that specifies a reply
    NSString *notificationName = @"ReplyNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(useNotification:) name:notificationName object:nil];

    self.collectionView.backgroundColor = [UIColor colorWithRed:255.0/255 green:100.0/255.0 blue:0.0/255.0 alpha:1];
    
    //reachability
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:kReachabilityChangedNotification object:nil];

}


- (void) reachabilityDidChange:(NSNotification *)notification
{
    Reachability *reachability = (Reachability *)[notification object];
    
    if([reachability isReachable])
    {
        //NSLog(@"Gained internet connection");
    }
    else
    {
        //show an alert that says its unreachable
        UIAlertView* reachabilityAlert = [[UIAlertView alloc]initWithTitle:@"Connection Issue" message:@"Please check your internet connection and retry." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        reachabilityAlert.tag = 1;
        [reachabilityAlert show];
    }
}

- (void) openBoxScore: (id) sender
{
    if(self.data.boxScoreURL == nil)
    {
        return;
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:@"boxScore"          // Event label
                                                           value:nil] build]];
    
    
    BoxScoreController* boxScoreController = [[BoxScoreController alloc] init];
    [boxScoreController updateWithGameData:self.data];
    [self.navigationController pushViewController:boxScoreController animated:YES];
    
    return;
   // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.data.boxScoreURL]];
    
}

- (void) useNotification: (NSNotification*) notification
{
    NSString *key = @"CommentValue";
    if([[notification name] isEqualToString:@"ReplyNotification"])
    {
        //need to access the comment data object that gets sent as userInfo
        //use this game data object to push a new view controller that will
        //display
        NSDictionary* information = [notification userInfo];
        CommentData* replyToComment = [information objectForKey:key];
        ReplyViewController* replyController = [[ReplyViewController alloc] init];
        [replyController updateViewWithCommentData:replyToComment];
        [self.navigationController pushViewController:replyController animated:YES];
        
    }
}

- (BOOL)updateControllerWithGameData: (GameData* ) data
{
    if(data == nil)
    {
        return NO;
    }
    
    self.data = data;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255.0/255 green:100.0/255.0 blue:0.0/255.0 alpha:1];
    self.navigationItem.title = [NSString stringWithFormat:@"%@ at %@", self.data.away, self.data.home];
    return YES;
}


- (void) onRefresh
{
    //call a refresh method on the feed cell?
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillDisappear:(BOOL)animated
{
    //code to call the notification that will be used to invalidate the timer object
    //NSLog(@"in view will dissapear");
    NSString *notificationName = @"BackNotification";
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:nil];
}

-(void) viewDidAppear:(BOOL)animated
{
    //NSLog(@"in view will dissapear");
    NSString *notificationName = @"ValidateTimer";
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:nil];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

        CommentViewFeedCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CommentViewFeedCell" forIndexPath:indexPath];
        [cell setupWithGameData:self.data];
       // NSLog(@"CommentViewController loaded!!!!!!!!!!!!");
        return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{

    return CGSizeMake(310, 500);
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
