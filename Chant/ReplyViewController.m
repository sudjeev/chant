//
//  ReplyViewController.m
//  Chant
//
//  Created by Sudjeev Singh on 11/11/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//


#import "ReplyViewController.h"
#import "Flairs.h"
#import "RKClient.h"
#import "RKClient+Users.h"
#import "RKClient+Comments.h"
#import "RKClient+Messages.h"
@interface ReplyViewController ()

@end

@implementation ReplyViewController

static int offset;
static int isLoading;
static UIRefreshControl* refresher;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) updateViewWithCommentData:(CommentData *)comment
{
    //set up all the shit right here
    self.myCommentData = comment;
    
        
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.replyView.layer.cornerRadius = 5;
    self.replyView.layer.masksToBounds = YES;
    self.commentView.layer.cornerRadius = 5;
    self.commentView.layer.masksToBounds = YES;
    self.navigationItem.title = @"Replies";

    UIBarButtonItem *flag = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_266_flag.png"] style:UIBarButtonItemStyleDone target:self action:@selector(onFlag)];

    
    
    self.navigationItem.rightBarButtonItem = flag;
    offset = 0;
    
    self.replies = [[NSMutableArray alloc] init];
    
    //Set all original comment elements of the replyView
    self.comment.text = self.myCommentData.text;
    self.upvotes.text = [self.myCommentData.upvotes stringValue];
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //register the cells
    [self.tableView registerNib:[UINib nibWithNibName:@"ReplyCommentCell" bundle:nil] forCellReuseIdentifier:@"ReplyCommentCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LoadingCell" bundle:nil] forCellReuseIdentifier:@"LoadingCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EmptyCell" bundle:nil] forCellReuseIdentifier:@"EmptyCell"];
    
    //implementing the pull to refresh of the table view
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    //refreshControl.backgroundColor = [UIColor colorWithRed:255.0 green:100.0 blue:0.0 alpha:1.0];
    refreshControl.tintColor = [UIColor colorWithRed:243.0/255 green:156.0/255.0 blue:18.0/255.0 alpha:1];
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    refresher = refreshControl;
    [self.tableView addSubview:refreshControl];
    
    if(self.myCommentData.userTeam == nil || [self.myCommentData.userTeam isEqualToString:@"NBA"])
    {
        self.userFlair.image = [UIImage imageNamed:@"NBA.png"];
        self.username.text = self.myCommentData.username;
    }
    else
    {
        self.userFlair.image = [[Flairs allFlairs].dict objectForKey:self.myCommentData.userTeam];
        NSString* team = [[Flairs allFlairs].teams objectForKey:self.myCommentData.userTeam];
        NSString* usernameText = [NSString stringWithFormat:@"%@(%@)", self.myCommentData.username, team];
        self.username.text = usernameText;
    }


    
    NSString* tableName = [NSString stringWithFormat:@"%@_replies", self.myCommentData.gameId];
    //need to get the replies to this comment
    PFQuery* getReplies = [PFQuery queryWithClassName:tableName];
    [getReplies whereKey:@"CommentID" equalTo:self.myCommentData.objectId];
    isLoading = 1;
    getReplies.limit = 50;
    [getReplies orderByDescending:@"createdAt"];
    [getReplies findObjectsInBackgroundWithTarget:self selector:@selector(replyCallback: error:)];
    
    
    //set image background of the reply view
    UIImageView *av = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 171)];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    av.image = [UIImage imageNamed:@"cell.png"];
    [self.replyView addSubview:av];
    [self.replyView sendSubviewToBack:av];
    
    
    //set the screenname
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"ReplyScreen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];

}

- (void)handleRefresh: (id) sender
{
    NSString* tableName = [NSString stringWithFormat:@"%@_replies", self.myCommentData.gameId];
    //need to get the replies to this comment
    PFQuery* getReplies = [PFQuery queryWithClassName:tableName];
    [getReplies whereKey:@"CommentID" equalTo:self.myCommentData.objectId];
    [getReplies orderByDescending:@"createdAt"];
    isLoading = 1;
    getReplies.limit = 50;
    [getReplies findObjectsInBackgroundWithTarget:self selector:@selector(replyCallback: error:)];
    [refresher endRefreshing];
}


-(void)onFlag
{
    //save this comment data in the flag database
    PFObject* flagged = [[PFObject alloc] initWithClassName:@"Flagged"];
    flagged[@"username"]  = self.myCommentData.username;
    flagged[@"content"] = self.myCommentData.text;
    flagged[@"contentID"] = self.myCommentData.objectId;
    flagged[@"table"] = self.myCommentData.gameId;
    
    [flagged saveInBackground];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Flagged" message:@"This comment has been flagged and will be reviewed by our moderators within the next 24hrs" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [alert show];
}

- (IBAction)upvote:(id)sender
{
    if([PFUser currentUser] == nil)
    {
        return;
    }
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* game = [NSString stringWithFormat:@"%@", self.myCommentData.gameId];
    //use the comment objectid to be the unique ID
    NSString* key = [NSString stringWithFormat:@"%@", self.myCommentData.objectId];
    NSMutableDictionary* upvotedComments = [[defaults objectForKey:game] mutableCopy];
    
    
    if([self.myCommentData.username isEqualToString:[PFUser currentUser].username] || [upvotedComments objectForKey:key] != nil)
    {
        //cant upvote your own comment
        //NSLog(@"already upvoted this");
        return;
    }
    
    //if it doesnt already exist in our defaults then we can add it and upvote the comment
    //NSLog(@"first time upvoting");
    [upvotedComments setObject:[[NSString alloc]init] forKey:key];
    
    [defaults setObject:upvotedComments forKey:game];
    
    self.myCommentData.upvotes = [[NSNumber alloc] initWithInt:[self.myCommentData.upvotes intValue] + 1];
    self.upvotes.text =  [self.myCommentData.upvotes stringValue];

    //increment the number in parse
    PFQuery* query = [PFQuery queryWithClassName:self.myCommentData.gameId];
    [query getObjectInBackgroundWithId:self.myCommentData.objectId block:^(PFObject *thisComment, NSError *error) {
        // Do something with the returned PFObject in the gameScore variable.
        if(!error)
        {
            [thisComment incrementKey:@"Upvotes"];
            [thisComment saveInBackground];
        }
        else
        {
           // NSLog(@"%@",[error userInfo][@"error"]);
        }
    }];
    
    //increment the users number
    PFQuery* upvoteUser = [PFQuery queryWithClassName:@"userData"];
    [upvoteUser whereKey:@"username" equalTo:self.myCommentData.username];
    [upvoteUser findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError* error)
     {
         if(!error)
         {
             for (PFObject* object in objects)
             {
                 [object incrementKey:@"totalUpvotes"];
                 [object saveInBackground];
             }
         }
         else
         {
             //NSLog(@"%@",[error userInfo][@"error"]);
         }
     }];
    
    //send a badge push to the user
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"username" equalTo:self.myCommentData.username];
    [pushQuery whereKey:@"upvotes" equalTo:@"Yes"];//if the user wants these notificaitons
    NSString* pushAlert = [NSString stringWithFormat:@"%@ upvoted your comment", [PFUser currentUser].username] ;
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          pushAlert, @"alert",
                          @"Increment", @"badge",
                          nil];
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery]; // Set our Installation query
    [push setData:data];
    [push sendPushInBackground];
    //NSLog(@"the badge update got sent");
    
    //[defaults synchronize];
}

-(void)replyCallback: (NSArray*) array error:(NSError*) error
{
    //reset the array every time
    self.replies = [[NSMutableArray alloc] init];
    
    if(!error)
    {
        
        if([array count] == 0)
        {
            return;
        }
        for(PFObject* object in array)
        {
            //need to push the data to parse before doing the data reload
            //also need to display a loading spinner
            
            ReplyData* newReply = [[ReplyData alloc]init];
            newReply.commentID = object[@"CommentID"];
            newReply.objectID = object.objectId;
            newReply.upvotes = object[@"Upvotes"];
            newReply.username = object[@"Username"];
            newReply.reply = object[@"Reply"];
            newReply.userTeam = object[@"Team"];
            newReply.gameID = object[@"GameID"];
            
            [self.replies addObject:newReply];
        }
        
        isLoading = 0;
        offset = [self.replies count];
        [self.tableView reloadData];
    }
    else
    {
        //NSLog(@"error on reply");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
    
    
}

//Method called when reply button is hit

-(IBAction)onReply:(id)sender
{
    //log the reply action in google
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:@"replyPost"          // Event label
                                                           value:nil] build]];
    
    if([self.replyBox.text isEqualToString:@""])
    {
        return;
        [self.replyBox resignFirstResponder];
    }
    else if([PFUser currentUser] == nil)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Sign up or Log In" message:@"You must have an account to post or reply. It only takes 5 seconds to make one!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        
        //check to see if the user is logged in or not
        
        
        //handle all the logic for storing the comment here
        PFUser *currentUser = [PFUser currentUser];
        
        NSString* tableName = [NSString stringWithFormat:@"%@_replies", self.myCommentData.gameId];
        PFObject *newComment = [PFObject objectWithClassName:tableName];
        newComment[@"Reply"] = self.replyBox.text;
        newComment[@"CommentID"] = self.myCommentData.objectId;
        newComment[@"Upvotes"] = [[NSNumber alloc] initWithInt:1];
        newComment[@"Username"] = currentUser.username;
        newComment[@"Team"] = currentUser[@"team"];
        newComment[@"GameID"] = self.myCommentData.gameId;
        //newComment[@"reddit_comment_id"] = self.myCommentData.redditId; //the id of the comment that was replied to,
        //if the comment is a reddit comment then the python script should do the actual replying
        [newComment saveInBackground];
        
        /*
        //increment the numReplies of the comment
        PFQuery* numRepliesQuery = [[PFQuery alloc] initWithClassName:self.myCommentData.gameId];
        [numRepliesQuery getObjectInBackgroundWithId:self.myCommentData.objectId block:^(PFObject *object, NSError *error) {
            if(!error)
            {
                [object incrementKey:@"numReplies"];
                [object saveInBackground];
            }
            else
            {
               // NSLog(@"error trying to increment numreplies");
            }
        }];*/
        

        
        //cut off the logic here
        if([self.myCommentData.reddit intValue] == 1)
        {
            //check if the current user is logged into reddit
            if([[RKClient sharedClient]isSignedIn])
            {
                NSString* redditReply = [NSString stringWithFormat:@"t1_%@", self.myCommentData.redditId];
                [[RKClient sharedClient] submitComment:self.replyBox.text onThingWithFullName:redditReply completion:^(NSError *error){
                    if(!error)
                    {
                        NSLog(@"It shouldve replied to comments of %@", redditReply);
                    }
                    else
                    {
                         NSLog(@"Couldnt crosspost the reply to reddit game threads comment");
                    }
                }];
            }
            //reset the array of replies
            self.replies = [[NSMutableArray alloc] init];
            
            [refresher beginRefreshing];
            [self handleRefresh:nil];
            
            self.replyBox.text = @"";
            [self.replyBox resignFirstResponder];
            
            return ;
        }
    
        //reset the array of replies
        self.replies = [[NSMutableArray alloc] init];
        
        [refresher beginRefreshing];
        [self handleRefresh:nil];
        
        //Send a message to anyone else who subscribed to this comment thread
        PFPush* push2 = [[PFPush alloc]init];
        [push2 setChannel:self.myCommentData.objectId];
        NSString* pushMessage2 = [NSString stringWithFormat:@"%@ replied to a comment you also replied to: %@", [PFUser currentUser].username, self.replyBox.text];
        [push2 setMessage:pushMessage2];
        [push2 sendPushInBackground];
        
        
        //if im responding to my own comment dont send me a push
        if([self.myCommentData.username isEqualToString:[PFUser currentUser].username])
        {
           // NSLog(@"here");
            //reset the array of replies
            self.replies = [[NSMutableArray alloc] init];
            
            [refresher beginRefreshing];
            [self handleRefresh:nil];
            
            self.replyBox.text = @"";
            [self.replyBox resignFirstResponder];
            return;
        }
        
        
        //send a push the the user
        PFQuery* pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"username" equalTo: self.myCommentData.username];
        [pushQuery whereKey:@"replies" equalTo:@"Yes"];
        PFPush* push = [[PFPush alloc] init];
        [push setQuery:pushQuery];
        NSString* pushAlert = [NSString stringWithFormat:@"%@ replied to your comment: %@", [PFUser currentUser].username, self.replyBox.text];
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              pushAlert, @"alert",
                              @"Increment", @"badge",
                              nil];
        [push setData:data];
        [push sendPushInBackground];
        
        
        
        
        //If this is my first time responding to this then add me as a listener
        PFInstallation* currentInstallation = [PFInstallation currentInstallation];
        
        //if im not subscribed to this channel then subscribe me to it
        if([currentInstallation.channels containsObject:self.myCommentData.objectId] == NO && [PFUser currentUser].username != self.myCommentData.username)
        {
            [currentInstallation addUniqueObject:self.myCommentData.objectId forKey:@"channels"];
            [currentInstallation saveInBackground];
        }
        
    
         self.replyBox.text = @"";
        [self.replyBox resignFirstResponder];
        
    }
}

//TABLEVIEW METHODS
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self.replies count] == 0)
    {
     return 1;
    }
    return [self.replies count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.replies count]==0 && isLoading == 0)
    {
        UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"EmptyCell"];
        return cell;
    }
    else if([self.replies count] == 0 && isLoading == 1)
    {
        //show the loading spinner
        UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
        return cell;
    }
    else
    {
        
        if(indexPath.row < [self.replies count])
        {
            ReplyCommentCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"ReplyCommentCell"];
            [cell updateViewWithItem: [self.replies objectAtIndex: indexPath.row]];
            return cell;
        }
        
    }

    
    return [[UITableViewCell alloc]init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 110;
}

@end
