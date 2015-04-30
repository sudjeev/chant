//
//  CommentViewFeedCell.m
//  Chant
//
//  Created by Sudjeev Singh on 9/15/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "CommentViewFeedCell.h"
#import "GameData.h"
#import "RKClient.h"
#import "RKClient+Users.h"
#import "RKClient+Comments.h"
#import "RKClient+Messages.h"
#import "SSKeychain.h"
#import "SSKeychainQuery.h"
#import "GAIDictionaryBuilder.h"


@implementation CommentViewFeedCell

static int offset;
static int isLoading;
static UIRefreshControl* refresher;
static int newComments;//a count of the new comments waiting to be loaded
static int atTop;//the flag I use to reset the most recent comment object


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //need to pass the game object here as well
        [self.feed registerNib:[UINib nibWithNibName:@"CommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"CommentTableViewCell"];
    }
    return self;
}

- (void)setupWithGameData:(GameData*) data
{
    self.view.layer.cornerRadius = 5;
    self.view.layer.masksToBounds = YES;
    self.post.tintColor = [UIColor colorWithRed:255.0/255 green:100.0/255.0 blue:0.0/255.0 alpha:1];
    self.segmentedControl.tintColor = [UIColor colorWithRed:255.0/255 green:100.0/255.0 blue:0.0/255.0 alpha:1];
    self.loadNew.hidden = YES;
    
    self.feed.allowsSelection = NO;
    
    newComments = 0;
    offset = 0;
    self.data = data;
    self.feed.dataSource = self;
    self.feed.delegate = self;
    self.tableData = [[NSMutableArray alloc] init];
    //initialize mostrecent comment
    self.mostRecentComment = [PFObject objectWithClassName:self.data.gameId];
    self.loadNew.titleLabel.textColor = [UIColor colorWithRed:255.0/255 green:100.0/255.0 blue:0.0/255.0 alpha:1];
    
    //implementing the pull to refresh of the table view
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    //refreshControl.backgroundColor = [UIColor colorWithRed:255.0 green:100.0 blue:0.0 alpha:1.0];
    refreshControl.tintColor = [UIColor colorWithRed:243.0/255 green:156.0/255.0 blue:18.0/255.0 alpha:1];
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    refresher = refreshControl;
    [self.feed addSubview:refreshControl];
    
    //Query to get all the comments for this chatroom, by querying the gameId database
    PFQuery *getComments = [PFQuery queryWithClassName:data.gameId];
    getComments.limit = 50;
    isLoading = 1;
    //set atTop to 1 as we are at top of tableView
    atTop = 1;
    //I should check segmented control before deciding how to sort initially
    [getComments orderByDescending:@"createdAt"];
    [refresher beginRefreshing];
    [getComments findObjectsInBackgroundWithTarget:self selector:@selector(commentCallback: error:)];
    //show the loading sign


    
    //check if the user is signed into reddit, if not then check with parse to see if he has an account connected with reddit and
    //if he does then log him in
    //is user aint signed into reddit but is signed into chant
    if(![[RKClient sharedClient] isSignedIn] && [PFUser currentUser] != nil)
    {
        PFQuery* query = [PFUser query];
        [query whereKey:@"username" equalTo:[PFUser currentUser].username];
        [query findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError* error)
         {
             if(!error)
             {
                 for(PFObject* object in objects)
                 {
                     //string to check if user connected to reddit
                     NSString* flag = object[@"reddit"];
                 
                     //check if connected to reddit
                     if([flag isEqualToString:@"true"])
                     {
                             //sign the user in with his username and the password stored on parse
                            if([SSKeychain passwordForService:[PFUser currentUser].username account:@"com.chant.keychain"] != nil)
                            {
                             NSString* redditPassword = [SSKeychain passwordForService:[PFUser currentUser].username account:@"com.chant.keychain"];

                             [[RKClient sharedClient] signInWithUsername:[PFUser currentUser].username  password:redditPassword completion:^(NSError *error) {
                                 if (!error)
                                 {
                                     //NSLog(@"User successfully connected to reddit in comment view");
                                 }
                                 else
                                 {
                                     //NSLog(@"Error logging user into reddit from the comments screen");
                                 }
                             }];
                            }
                     }
                 }
             }
         }];
    }

    //setup the nstimer that will be calling the poller
    //NSLog(@"Making the timer object in setupWithGameData");
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(poll:) userInfo:nil repeats:YES];
    
    //setup the notification that gets called when the back button is hit so we can invalidate the timer
    //register for the notifcation that specifies a reply
    NSString *notificationName = @"BackNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(useNotification:) name:notificationName object:nil];
    
    
    NSString *notificationName2 = @"ValidateTimer";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(useNotification:) name:notificationName2 object:nil];
    
    [self.feed registerNib:[UINib nibWithNibName:@"CommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"CommentTableViewCell"];
    [self.feed registerNib:[UINib nibWithNibName:@"LoadingCell" bundle:nil] forCellReuseIdentifier:@"LoadingCell"];

}

//method that handles pull to refresh
- (void) handleRefresh: (id) sender
{
    //just call the segmented control method
    [self valueChanged:self.segmentedControl];
    self.loadNew.hidden = YES;
    [refresher endRefreshing];
    //need to end the refreshing once its done as well
}

- (void) useNotification: (NSNotification*) notification
{
    //when the back button is hit it posts a notfication that calls this method
    if ([notification.name isEqualToString:@"BackNotification"])
    {
        [self.myTimer invalidate];
        self.myTimer = nil;
       // NSLog(@"invalidated this timer object");
    }

}

- (IBAction)onLoadNew:(id)sender
{
    //log the reply action in google
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:@"loadNewComments"          // Event label
                                                           value:nil] build]];
    
    [refresher beginRefreshing];
    [refresher sendActionsForControlEvents:UIControlEventValueChanged];
    self.loadNew.hidden = YES;

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.feed scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
    
}

- (void) poll:(NSTimer *)timer
{
    //make this change depending on the segmented control value, should only show up for new
    
    PFQuery *countComments = [PFQuery queryWithClassName:self.data.gameId];
    //crashing when commentCallback takes more than 15 seconds to respond because most recent comment does not get set and we do nil comparison
    
    if(self.mostRecentComment.createdAt != nil)
    {
     [countComments whereKey:@"createdAt" greaterThan:self.mostRecentComment.createdAt];
    }
    
    if([PFUser currentUser].username != nil)
    {
        [countComments whereKey:@"User" notEqualTo:[PFUser currentUser].username];//count all the new comments not made by me
    }
    
    [countComments countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if(!error)
        {
            //NSLog(@"The count I got was %i", count);
            //increment newComments by count
            newComments += count;
            if(newComments > 0)
            {
             //we should only see this if the user is on new
             if (self.segmentedControl.selectedSegmentIndex == 0)
             {
                 self.loadNew.hidden = NO;
                 [self.loadNew setTitle:[NSString stringWithFormat:@"%i comments", newComments] forState:UIControlStateNormal];
                 //self.loadNew.titleLabel.text = [NSString stringWithFormat:@"%i comments", newComments];
             }
            }
        }
        else
        {
            //NSLog(@"error trying to count comments %@", error);
        }
    }];
    
   // NSLog(@"The Poller method has been called");
}


- (void) commentCallback: (NSArray*) array error: (NSError*) error
{

    [refresher endRefreshing];
    
    if(!error)
    {
        //no error was reported
        if([array count] == 0)
        {
           // NSLog(@"The query didnt return shit !!!!!!!!!!!!!!!!");
        }
        
        for(PFObject* comment in array)
        {
            if(atTop == 1)
            {
             //save the most recent comment
                self.mostRecentComment = comment;
                //NSLog(@"MOST RECENT COMMENT IS: %@", self.mostRecentComment.createdAt);
                //set at top back to zero so it doesn't get called every time in the loop
                atTop = 0;
                //reset the number of new comments to be loaded to zero
                newComments = 0;
            }
            
            //for every element in the array put it in the table data
            //make a comment data type and populate it here
            CommentData* data = [[CommentData alloc] init];
            data.text = comment[@"Content"];
            data.upvotes =  comment[@"Upvotes"];
            data.username = comment[@"User"];
            data.objectId = comment.objectId;
            data.userTeam = comment[@"Team"];//used for flair
            data.reddit = comment[@"reddit"];//if this comment is from reddit or not
            data.numReplies = comment[@"numReplies"];//get the number of replies this comment has
            data.createdAt = [comment createdAt];
            data.redditCreatedAt = comment[@"reddit_date"];
            data.redditId = comment[@"reddit_comment_id"];
            //make the comments gameId be the name of the class
            data.gameId = self.data.gameId;
            [self.tableData addObject:data];
        }
        isLoading = 0;
        int oldoffset = offset;
        offset = [self.tableData count];
        
        //should check if anything is even returned, otherwise there is no need to reload again cus no new data has been added
        [self.feed reloadData];
        
    }
    else
    {
        //NSLog(@"There was a problem %@", error);
        isLoading = 0;
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
    //should do nothing but remove the keyboard
    
}

- (IBAction)valueChanged:(id)sender
{
    //
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            {
                self.tableData = [[NSMutableArray alloc] init];
                PFQuery *getComments = [PFQuery queryWithClassName:self.data.gameId];
                //need to add the filter for gameid
                getComments.limit = 100;
                isLoading = 1;
                [getComments orderByDescending:@"createdAt"];
                //set at top to 1 so we can reset the most recent comment
                atTop = 1;
                [getComments findObjectsInBackgroundWithTarget:self selector:@selector(commentCallback: error:)];
                
                //log the reply action in google
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                      action:@"button_press"  // Event action (required)
                                                                       label:@"viewNewComments"          // Event label
                                                                       value:nil] build]];
                
                /*NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                 [self.feed scrollToRowAtIndexPath:indexPath
                 atScrollPosition:UITableViewScrollPositionTop
                 animated:YES];*/
            }
            break;
        case 1:
            {
                self.tableData = [[NSMutableArray alloc] init];
                NSString* topTable = [NSString stringWithFormat:@"%@_top", self.data.gameId];
                PFQuery *getComments = [PFQuery queryWithClassName:topTable];
                //need to add the filter for gameid
                getComments.limit = 100;
                isLoading = 1;
                [getComments orderByDescending:@"Upvotes"];
                [getComments findObjectsInBackgroundWithTarget:self selector:@selector(commentCallback: error:)];
                
                //log the reply action in google
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                      action:@"button_press"  // Event action (required)
                                                                       label:@"viewTopComments"          // Event label
                                                                       value:nil] build]];
                
                /*NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                 [self.feed scrollToRowAtIndexPath:indexPath
                 atScrollPosition:UITableViewScrollPositionTop
                 animated:YES];*/
            }
            break;
        case 2:
        {
            if([PFUser currentUser] == nil)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You are not logged in" message:@"Log In or Sign Up for an account, it only takes 10 seconds" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                [alert show];
                self.segmentedControl.selectedSegmentIndex = 0;
                [self valueChanged:self.segmentedControl];
                break;
            }
            
            self.tableData = [[NSMutableArray alloc] init];
            PFQuery *getComments = [PFQuery queryWithClassName:self.data.gameId];
            [getComments whereKey:@"User" equalTo:[PFUser currentUser].username];
            isLoading = 1;
            [getComments orderByDescending:@"createdAt"];
            [getComments findObjectsInBackgroundWithTarget:self selector:@selector(commentCallback:error:)];
            
            /*NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.feed scrollToRowAtIndexPath:indexPath
                             atScrollPosition:UITableViewScrollPositionTop
                                     animated:YES];*/
            
            //log the reply action in google
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                  action:@"button_press"  // Event action (required)
                                                                   label:@"viewMyComments"          // Event label
                                                                   value:nil] build]];
        }
        default:
            break;
    }
}

- (IBAction)onComment:(id)sender
{
    //log the reply action in google
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:@"postingComment"          // Event label
                                                           value:nil] build]];
    
    //if not logged in
    if([PFUser currentUser] == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Before you can post.." message:@"Log In or Sign Up for an account, it only takes 10 seconds" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if([self.commentBox.text isEqualToString: @""])
    {
        [self textFieldShouldReturn:self.commentBox];
        return;
    }
    
    else
    {
        //enter this comment data to parse
        PFUser* currentUser = [PFUser currentUser];
        
        PFObject *newComment = [PFObject objectWithClassName:self.data.gameId];
        newComment[@"Content"] = self.commentBox.text;
        newComment[@"GameID"] = self.data.gameId;
        newComment[@"Upvotes"] = [[NSNumber alloc] initWithInt:1];
        newComment[@"User"] = currentUser.username;
        newComment[@"Team"] = currentUser[@"team"];
        newComment[@"numReplies"] = [NSNumber numberWithInt:0];
        [newComment saveInBackground];
        
        [currentUser incrementKey:@"totalUpvotes"];
        [currentUser saveInBackground];
        
        //if there is a gamethread for this game and if the user is signed in then crosspost this too reddit
        if(self.data.redditFullName != nil && [[RKClient sharedClient]isSignedIn])
        {
            [[RKClient sharedClient] submitComment:self.commentBox.text onThingWithFullName:self.data.redditFullName completion:^(NSError *error){
                if(!error)
                {
                    //NSLog(@"It shouldve posted to comments of %@", self.data.redditFullName);
                }
                else
                {
                   // NSLog(@"Couldnt crosspost the comment to reddit game threads");
                }
            }];
        }
        
        //reset the comment box and drop the keyboard
        self.commentBox.text = @"";
        [self.commentBox resignFirstResponder];

        //reload the whole tableview based on segmented control value
        [self valueChanged:self.segmentedControl];
    }
    
   // RKComment* comment = RKComment
}


- (IBAction)onRefresh:(id)sender
{
    //Just call the segmented control method
    [self valueChanged:self.segmentedControl];
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.tableData count] == 0 && isLoading == 1)
    {
        UITableViewCell* cell = [self.feed dequeueReusableCellWithIdentifier:@"LoadingCell"];
        return cell;
    }
    else
    {
        //if indexPath has reached the point right before the end of tableData
        if(indexPath.row + 1  >= [self.tableData count])
        {
            //Get rid of infinite scroll, just show the 100 most recent comments
            
            /*
            PFQuery *getComments = [PFQuery queryWithClassName:self.data.gameId];
            getComments.limit = 50;
            //along with using the offset we need to store the first PFObject and use that objects created at field
            if(self.mostRecentComment.createdAt != nil)
            {
                [getComments whereKey:@"createdAt" greaterThan:self.mostRecentComment.createdAt];
            }
            else
            {
                NSLog(@"most recent comment created at is null for some reason.......");
            }
            
            getComments.skip = offset;
            [getComments orderByDescending:@"createdAt"];
            [getComments findObjectsInBackgroundWithTarget:self selector:@selector(commentCallback:error:)];*/
        }
        
        if(indexPath.row < [self.tableData count])
        {
            CommentTableViewCell* cell = [self.feed dequeueReusableCellWithIdentifier:@"CommentTableViewCell"];
            [cell updateViewWithItem: [self.tableData objectAtIndex: indexPath.row]];
            return cell;
        }
        //show the loading cell again
        else
        {
            return [self.feed dequeueReusableCellWithIdentifier:@"LoadingCell"];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self.tableData count] == 0)
    {
        return 1;
    }
    return [self.tableData count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 133;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
