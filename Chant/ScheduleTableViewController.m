//
//  ScheduleTableViewController.m
//  Chant
//
//  Created by Sudjeev Singh on 9/3/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "ScheduleTableViewController.h"
#import "ScheduleCell.h"
#import "UpcomingGameCell.h"
#import <Parse/Parse.h>
#import "GameData.h"
#import "ProfileViewController.h"
#import "LoginViewController.h"
#import "SignUpViewController.h"
#import "CommentViewFeedCell.h"
#import "CommentViewController.h"
#import "NewChatCell.h"
#import "RKClient.h"
#import "RKClient+Users.h"
#import "RKClient+Comments.h"
#import "RKClient+Messages.h"
#import "Flairs.h"
#import "Reachability.h"


@interface ScheduleTableViewController ()
@property (nonatomic, strong) NSMutableArray* schedule;
@property (nonatomic, assign) int liveGames;
@property (nonatomic, assign) int isLoading;
@property (nonatomic, strong) NSNumber* uVotes;
@end

@implementation ScheduleTableViewController

static UIActivityIndicatorView *loadingActivity;


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"ScheduleCell" bundle:nil] forCellReuseIdentifier:@"ScheduleCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LoadingCell" bundle:nil] forCellReuseIdentifier:@"LoadingCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"NewChatCell" bundle:nil] forCellReuseIdentifier:@"NewChatCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EmptyScheduleCell" bundle:nil] forCellReuseIdentifier:@"EmptyScheduleCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"UpcomingGameCell" bundle:nil] forCellReuseIdentifier:@"UpcomingGameCell"];
    

    //reachability
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:kReachabilityChangedNotification object:nil];
    
    self.view.backgroundColor = [UIColor colorWithRed:255.0/255 green:100.0/255.0 blue:0.0/255.0 alpha:1];
    
    //rgb(52, 152, 219)
    if([PFUser currentUser] != nil)
    {
        
        UIBarButtonItem* profile = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Final_userProfile" ] style:UIBarButtonItemStylePlain target:self action:@selector(toProfile)];
        self.navigationItem.rightBarButtonItem = profile;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    }
    else
    {
        UIBarButtonItem* signUp = [[UIBarButtonItem alloc] initWithTitle:@"Sign Up" style:UIBarButtonItemStyleBordered target:self action:@selector(toSignUp)];
        self.navigationItem.rightBarButtonItem = signUp;
        
        UIBarButtonItem* logIn = [[UIBarButtonItem alloc] initWithTitle:@"Log In" style:UIBarButtonItemStyleBordered target:self action:@selector(toLogIn)];
        
        
        UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(0,0,30,30)];
        tempView.backgroundColor=[UIColor clearColor];
        UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(15,0,300,44)];
        tempLabel.backgroundColor=[UIColor redColor];
        tempLabel.shadowColor = [UIColor clearColor];
        tempLabel.shadowOffset = CGSizeMake(0,2);
        tempLabel.textColor = [UIColor redColor]; //here you can change the text color of header.
        tempLabel.text = @"AYYYY";
        [tempView addSubview:tempLabel];
        [logIn.customView addSubview: tempView];
        logIn.target = self;
        logIn.action = @selector(toLogIn);
        
        self.navigationItem.leftBarButtonItem = logIn;

        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];

    }
    self.schedule = [[NSMutableArray alloc] init];
    self.liveGames = 0;
    
    self.navigationItem.title = @"Chant";
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255/255.0 green:100/255.0 blue:0/255.0 alpha:1.0];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc]init];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarPositionAny];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc]init];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:255/255.0 green:100/255.0 blue:0/255.0 alpha:1.0],
      NSForegroundColorAttributeName,
      [UIColor colorWithRed:255/255.0 green:100/255.0 blue:0/255.0 alpha:1.0],
      NSForegroundColorAttributeName,
      [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
      NSForegroundColorAttributeName,
      [UIFont fontWithName:@"Arial-Bold" size:5.0],
      NSFontAttributeName,
      nil]];
    
    self.isLoading = 1;
    PFQuery *getSchedule = [PFQuery queryWithClassName:@"GameData"];
    [getSchedule findObjectsInBackgroundWithTarget:self selector:@selector(gameDataCallback: error:)];
    
    loadingActivity = [[UIActivityIndicatorView alloc]
                                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    loadingActivity.center=self.view.center;
    [loadingActivity startAnimating];
    [self.view addSubview:loadingActivity];
    
}



- (void) reachabilityDidChange:(NSNotification *)notification
{
    Reachability *reachability = (Reachability *)[notification object];

    if([reachability isReachable])
    {
        NSLog(@"Gained internet connection");
    }
    else
    {
        //show an alert that says its unreachable
        UIAlertView* reachabilityAlert = [[UIAlertView alloc]initWithTitle:@"Connection Issue" message:@"Please check your internet connection and retry." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Retry",nil];
        reachabilityAlert.tag = 1;
        [reachabilityAlert show];
    }
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    // Is this my Alert View?
    if (alertView.tag == 1)
    {
        //Yes

        // Then u can check which button was pressed.
        if (buttonIndex == 0) {// 1st Other Button
            NSLog(@"button index at 0 got clicked");
            [alertView setHidden:YES];
            
            loadingActivity = [[UIActivityIndicatorView alloc]
                               initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            
            loadingActivity.center=self.view.center;
            [loadingActivity startAnimating];
            [self.view addSubview:loadingActivity];
            
            PFQuery *getSchedule = [PFQuery queryWithClassName:@"GameData"];
            [getSchedule findObjectsInBackgroundWithTarget:self selector:@selector(gameDataCallback: error:)];

        }
        else if (buttonIndex == 1)
        {//Retry button
            NSLog(@"button index at 1 got clicked");
            [alertView setHidden:YES];

            loadingActivity = [[UIActivityIndicatorView alloc]
                               initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            
            loadingActivity.center=self.view.center;
            [loadingActivity startAnimating];
            [self.view addSubview:loadingActivity];
            
            PFQuery *getSchedule = [PFQuery queryWithClassName:@"GameData"];
            [getSchedule findObjectsInBackgroundWithTarget:self selector:@selector(gameDataCallback: error:)];
        }
        
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)toSignUp
{
    [self.navigationController pushViewController:[[SignUpViewController alloc] init] animated:YES];
}

-(void)toLogIn
{
    [self.navigationController pushViewController:[[LoginViewController alloc] init] animated:YES];
}

- (void) toProfile
{
    ProfileViewController* profile = [[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:profile];
    
    [navController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:255/255.0 green:100/255.0 blue:0/255.0 alpha:1.0],
      NSForegroundColorAttributeName,
      [UIColor colorWithRed:255/255.0 green:100/255.0 blue:0/255.0 alpha:1.0],
      NSForegroundColorAttributeName,
      [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
      NSForegroundColorAttributeName,
      [UIFont fontWithName:@"Arial-Bold" size:0.0],
      NSFontAttributeName,
      nil]];
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)gameDataCallback:(NSArray*) response error: (NSError*) error
{
    NSLog(@"gamedatacallback");
    if(!error)
    {
     //add all the games that are currently going on
     for(PFObject* object in response)
     {
             GameData* nextGame = [[GameData alloc] init];
             nextGame.started = [object objectForKey:@"started"];
             nextGame.home = [object objectForKey:@"home"];
             nextGame.away = [object objectForKey:@"away"];
             nextGame.homeFull = [object objectForKey:@"homeFull"];
             nextGame.awayFull = [object objectForKey:@"awayFull"];
             nextGame.gameId = object.objectId;
             nextGame.status = [object objectForKey:@"status"];
             nextGame.redditFullName = [object objectForKey:@"redditFullName"];
             nextGame.boxScoreURL = [object objectForKey:@"boxScore"];
             [self.schedule addObject:nextGame];
             self.liveGames++;
         
     }
        
    }
    
    else
    {
     NSLog(@"Game data callback problem %@", error);
    }
    
    self.isLoading = 0;
    [self.tableView reloadData];
    [loadingActivity stopAnimating];
    return;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {return 0;}
    else
    {return [self.schedule count];}
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

//need to find an effective way to call tableview reload data on a loop cycle
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%li", (long)indexPath.section);

    //need to check isLoading
    if([self.schedule count] == 0)
    {
        if(self.isLoading == 1)
        {
            //return a loading cell
            UITableViewCell* cell = [[UITableViewCell alloc] init];
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else
        {
            //return a cell saying no games are being played this day
            UITableViewCell* cell = [[UITableViewCell alloc] init];
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"EmptyScheduleCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    
    
    
        //pass on the gameData object in the schedule array
    ScheduleCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"ScheduleCell"];
    [cell updateCellWithGameData:[self.schedule objectAtIndex:indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0; //play around with this value
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == 0)
    {return 40;}
    else{return 0;}
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(0,200,300,40)];
    tempView.backgroundColor=[UIColor clearColor];
    
    UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(15,0,300,40)];
    
    [tempView addSubview:tempLabel];
    
    return tempView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(0,200,300,40)];
    tempView.backgroundColor=[UIColor clearColor];
    
    UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(15,0,300,40)];
    tempLabel.backgroundColor=[UIColor clearColor];
    tempLabel.shadowColor = [UIColor clearColor];
    tempLabel.shadowOffset = CGSizeMake(0,2);
    tempLabel.textColor = [UIColor whiteColor]; //here you can change the text color of header.
    tempLabel.textAlignment = NSTextAlignmentCenter;
    if(section == 0)
    {
        tempLabel.text=@"NBA GameThreads:";
    }
    else
    {
        tempLabel.text=@"";
    }
    
    [tempView addSubview:tempLabel];
    
    return tempView;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    CommentViewController *detailViewController = [[CommentViewController alloc] initWithNibName:@"CommentViewController" bundle:nil];
    
    [detailViewController updateControllerWithGameData:[self.schedule objectAtIndex:indexPath.row]];
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}

//Methods to make sure the view cant turn sideways
- (NSUInteger) supportedInterfaceOrientations {
    // Return a bitmask of supported orientations. If you need more,
    // use bitwise or (see the commented return).
    return UIInterfaceOrientationMaskPortrait;
    // return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    // Return the orientation you'd prefer - this is what it launches to. The
    // user can still rotate. You don't have to implement this method, in which
    // case it launches in the current orientation
    return UIInterfaceOrientationPortrait;
}

@end
