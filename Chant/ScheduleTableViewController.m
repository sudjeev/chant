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
#import "CommentViewFeedCell.h"
#import "CommentViewController.h"

@interface ScheduleTableViewController ()
@property (nonatomic, strong) NSMutableArray* schedule;
@property (nonatomic, assign) int liveGames;
@property (nonatomic, assign) int isLoading;
@end

@implementation ScheduleTableViewController




- (void)viewDidLoad
{
    [super viewDidLoad];

    
    [self.tableView registerNib:[UINib nibWithNibName:@"ScheduleCell" bundle:nil] forCellReuseIdentifier:@"ScheduleCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LoadingCell" bundle:nil] forCellReuseIdentifier:@"LoadingCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EmptyScheduleCell" bundle:nil] forCellReuseIdentifier:@"EmptyScheduleCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"UpcomingGameCell" bundle:nil] forCellReuseIdentifier:@"UpcomingGameCell"];
    
    
    
    UIBarButtonItem* profile = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Final_userProfile" ] style:UIBarButtonItemStylePlain target:self action:@selector(toProfile)];
    self.navigationItem.rightBarButtonItem = profile;
    
    self.schedule = [[NSMutableArray alloc] init];
    self.liveGames = 0;
    
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                          dateStyle:NSDateFormatterMediumStyle
                                                          timeStyle:nil];
    self.navigationItem.title = dateString;
    
    self.isLoading = 1;
    PFQuery *getSchedule = [PFQuery queryWithClassName:@"GameData"];
    [getSchedule findObjectsInBackgroundWithTarget:self selector:@selector(gameDataCallback: error:)];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) toProfile
{
    ProfileViewController* profile = [[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:profile];
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
         if([[object objectForKey:@"started"] isEqualToString:@"True"])
         {
             GameData* nextGame = [[GameData alloc] init];
             nextGame.started = [object objectForKey:@"started"];
             nextGame.home = [object objectForKey:@"home"];
             nextGame.away = [object objectForKey:@"away"];
             nextGame.homeScore = [object objectForKey:@"homeScore"];
             nextGame.awayScore = [object objectForKey:@"awayScore"];
             nextGame.quarter = [object objectForKey:@"quarter"];
             nextGame.gameId = [object objectForKey:@"gameId"];
             [self.schedule addObject:nextGame];
             self.liveGames++;
         }
     }
     //add all the games that are scheduled
     for(PFObject* object in response)
     {
        if([[object objectForKey:@"started"] isEqualToString:@"False"])
        {
            GameData* nextGame = [[GameData alloc] init];
            nextGame.started = [object objectForKey:@"started"];
            nextGame.home = [object objectForKey:@"home"];
            nextGame.away = [object objectForKey:@"away"];
            nextGame.homeScore = [object objectForKey:@"homeScore"];
            nextGame.awayScore = [object objectForKey:@"awayScore"];
            nextGame.quarter = [object objectForKey:@"quarter"];
            nextGame.gameId = [object objectForKey:@"gameId"];
            [self.schedule addObject:nextGame];
        }
     }
    }
    
    else
    {
     NSLog(@"Game data callback problem %@", error);
    }
    
    self.isLoading = 0;
    [self.tableView reloadData];
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
    NSLog(@"in number of rows for section %i", section);
    if([self.schedule count] == 0)
    {
        //we are returning 1 so that we can show a loading cell instead or a no games cell
        NSLog(@"returning one");
        return 1;
    }
    
    
    // Return the number of rows in the section.
    if(section == 0)
    {
        NSLog(@"returningg %i", self.liveGames);
        return self.liveGames;
    }
    NSLog(@"returning %i ", [self.schedule count] - self.liveGames);
    return ([self.schedule count] - self.liveGames);
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(section == 0)
    {
        return @"Live Games:";
    }
    return @"Scheduled Games";
}

//need to find an effective way to call tableview reload data on a loop cycle
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%i", indexPath.section);

    //need to check isLoading
    if([self.schedule count] == 0)
    {
        if(self.isLoading == 1)
        {
            //return a loading cell
            UITableViewCell* cell = [[UITableViewCell alloc] init];
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
            return cell;
        }
        else
        {
            //return a cell saying no games are being played this day
            UITableViewCell* cell = [[UITableViewCell alloc] init];
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"EmptyScheduleCell"];
            return cell;
        }
    }
    
    
    //cell for a live game
    if(indexPath.section == 0)
    {
        //pass on the gameData object in the schedule array
        ScheduleCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"ScheduleCell"];
        [cell updateCellWithGameData:[self.schedule objectAtIndex:indexPath.row]];
        return cell;
    }
    //cell for a scheduled game
    else
    {
        UpcomingGameCell* cell =  [self.tableView dequeueReusableCellWithIdentifier:@"UpcomingGameCell"];
        [cell updateCellWithGameData:[self.schedule objectAtIndex:indexPath.row + self.liveGames]];
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
     return 100;
    }
    
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40; //play around with this value
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


@end
