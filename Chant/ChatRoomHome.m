//
//  ChatRoomHome.m
//  Chant
//
//  Created by Sudjeev Singh on 10/12/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "ChatRoomHome.h"
#import "StartChatController.h"
#import "ChatRoom.h"
#import "LiveChatCell.h"
#import <Parse/Parse.h>

@interface ChatRoomHome ()
@property (nonatomic, strong) NSMutableArray* liveThreads;
@property (nonatomic, assign) int isLoading;
@end

@implementation ChatRoomHome


//need to make a call to parse to get all the live chat rooms, same logic as the schedule controller
//should i make a data model obj for chat rooms? make an array of chat room objects with info from parse
//then pass the object accross to the next view controller and use the object id made by parse to filter
//through the comments table. Long run i should ideally be using more than just one table for all the comments



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Chat Rooms";
    [self.tableView registerNib:[UINib nibWithNibName:@"StartChatCell" bundle:nil] forCellReuseIdentifier:@"StartChatCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LiveChatCell" bundle:nil] forCellReuseIdentifier:@"LiveChatCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LoadingCell" bundle:nil] forCellReuseIdentifier:@"LoadingCell"];

    self.liveThreads = [[NSMutableArray alloc] init];
    self.isLoading = 0;
    
    
    
    //set loading marker before the query
    self.isLoading = 1;
    
    //Need to query parse to get the chat threads
    PFQuery *getSchedule = [PFQuery queryWithClassName:@"chatRoom"];
    [getSchedule findObjectsInBackgroundWithTarget:self selector:@selector(queryCallBack: error:)];
    
    
    
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void) queryCallBack:(NSArray*) response error: (NSError*) error
{
    if(!error)
    {
        for(PFObject* object in response)
        {
            // make an object for each thread there is in the table
            ChatRoom *nextRoom = [[ChatRoom alloc] init];
            nextRoom.title = [object objectForKey:@"title"];
            nextRoom.creator = [object objectForKey:@"creator"];
            nextRoom.objectId = object.objectId;
            [self.liveThreads addObject:nextRoom];
        }
    }
    
    else
    {
        NSLog(@"error on parse callback!!!!!");
    }
    
    self.isLoading = 0;
    [self.tableView reloadData];
    return;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section == 0)
    {
        return 1;
    }
    
    if(self.isLoading == 1)
    {
        return 1;
    }
    
    return [self.liveThreads count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    if(indexPath.section == 0)
    {
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StartChatCell" forIndexPath:indexPath];
     return cell;
    }
    else
    {
        if([self.liveThreads count] == 0)
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
                cell = [self.tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
                return cell;
            }
        }
        else
        {
            LiveChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LiveChatCell" forIndexPath:indexPath];
            [cell updateWithChatRoomData:[self.liveThreads objectAtIndex:indexPath.row]];
            return cell;
        }
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 1)
    {
        return @"Live Chat Rooms";
    }
    
    return @"";
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



// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    if(indexPath.section == 0)
    {
     StartChatController *detailViewController = [[StartChatController alloc] initWithNibName:@"StartChatController" bundle:nil];
        UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
        [self presentViewController:navController animated:YES completion:nil];
    }
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
}


@end
