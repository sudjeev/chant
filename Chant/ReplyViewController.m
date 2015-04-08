//
//  ReplyViewController.m
//  Chant
//
//  Created by Sudjeev Singh on 11/11/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//


#import "ReplyViewController.h"
#import "Flairs.h"

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
    offset = 0;
    
    self.replies = [[NSMutableArray alloc] init];
    
    //Set all original comment elements of the replyView
    self.comment.text = self.myCommentData.text;
    self.username.text = self.myCommentData.username;
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
    
    if(self.myCommentData.userTeam != nil)
    {
        self.userFlair.image = [[Flairs allFlairs].dict objectForKey:self.myCommentData.userTeam];
    }
    else
    {
        self.userFlair.image = [UIImage imageNamed:@"jordan.jpg"];
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

}

- (void)handleRefresh: (id) sender
{
    NSString* tableName = [NSString stringWithFormat:@"%@_replies", self.myCommentData.gameId];
    //need to get the replies to this comment
    PFQuery* getReplies = [PFQuery queryWithClassName:tableName];
    [getReplies whereKey:@"CommentID" equalTo:self.myCommentData.objectId];
    isLoading = 1;
    getReplies.limit = 50;
    [getReplies findObjectsInBackgroundWithTarget:self selector:@selector(replyCallback: error:)];
    [refresher endRefreshing];
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
            
            [self.replies addObject:newReply];
        }
        
        isLoading = 0;
        offset = [self.replies count];
        [self.tableView reloadData];
    }
    else
    {
        NSLog(@"error on reply");
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
    
    if([self.replyBox.text isEqualToString:@""])
    {
        return YES;
    }
    
    NSString* tableName = [NSString stringWithFormat:@"%@_replies", self.myCommentData.gameId];

    
    //handle all the logic for storing the comment here
    PFUser* currentUser = [PFUser currentUser];

    
    PFObject *newComment = [PFObject objectWithClassName:tableName];
    newComment[@"Reply"] = self.replyBox.text;
    newComment[@"CommentID"] = self.myCommentData.objectId;
    newComment[@"Upvotes"] = [[NSNumber alloc] initWithInt:1];
    newComment[@"Username"] = currentUser.username;
    newComment[@"Team"] = currentUser[@"team"];
    [newComment saveInBackground];
    
    //Send a push to the guy who made the original comment
    PFQuery* pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"username" equalTo: self.myCommentData.username];
    PFPush* push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    NSString* pushMessage = [NSString stringWithFormat:@"%@ replied to your comment: %@", [PFUser currentUser].username, self.replyBox.text];
    [push setMessage:pushMessage];
    [push sendPushInBackground];
    
    //Send a message to anyone else who subscribed to this comment thread
    PFPush* push2 = [[PFPush alloc]init];
    [push2 setChannel:self.myCommentData.objectId];
    NSString* pushMessage2 = [NSString stringWithFormat:@"%@ replied to a comment you also replied to: %@", [PFUser currentUser].username, self.replyBox.text];
    [push setMessage:pushMessage2];
    [push sendPushInBackground];
    
    
    //If this is my first time responding to this then add me as a listener
    PFInstallation* currentInstallation = [PFInstallation currentInstallation];
    
    //if im not subscribed to this channel then subscribe me to it
    if([currentInstallation.channels containsObject:self.myCommentData.objectId] == NO && [PFUser currentUser].username != self.myCommentData.username)
    {
        [currentInstallation addUniqueObject:self.myCommentData.objectId forKey:@"channels"];
        [currentInstallation saveEventually];
    }
    
    //reset the replies array
    self.replies = [[NSMutableArray alloc] init];

    [self.tableView reloadData];

    self.replyBox.text = @"";
    //reload the data so the comment shows up
    [self.tableView reloadData];
    
    
    return YES;
    
}

//Method called when reply button is hit

-(IBAction)onReply:(id)sender
{
    if([self.replyBox.text isEqualToString:@""])
    {
        return;
        [self.replyBox resignFirstResponder];
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
        [newComment saveInBackground];
        
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
        
        
        //Send a message to anyone else who subscribed to this comment thread
        PFPush* push2 = [[PFPush alloc]init];
        [push2 setChannel:self.myCommentData.objectId];
        NSString* pushMessage2 = [NSString stringWithFormat:@"%@ replied to a comment you also replied to: %@", [PFUser currentUser].username, self.replyBox.text];
        [push setMessage:pushMessage2];
        [push sendPushInBackground];
        
        
        //If this is my first time responding to this then add me as a listener
        PFInstallation* currentInstallation = [PFInstallation currentInstallation];
        
        //if im not subscribed to this channel then subscribe me to it
        if([currentInstallation.channels containsObject:self.myCommentData.objectId] == NO && [PFUser currentUser].username != self.myCommentData.username)
        {
            [currentInstallation addUniqueObject:self.myCommentData.objectId forKey:@"channels"];
            [currentInstallation saveEventually];
        }
        
        //reset the array of replies
        self.replies = [[NSMutableArray alloc] init];
        
        [refresher beginRefreshing];
        [self handleRefresh:nil];
    
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
        //Do nothing, we are only showing 50 replies per comment at the most
        //if indexPath has reached the point right before the end of tableData
        /*
        if(indexPath.row + 1  >= [self.replies count])
        {
            NSString* tableName = [NSString stringWithFormat:@"%@_replies", self.myCommentData.gameId];
            PFQuery* getReplies = [PFQuery queryWithClassName:tableName];
            [getReplies whereKey:@"CommentID" equalTo:self.myCommentData.objectId];
            isLoading = 1;
            getReplies.limit = 50;
            getReplies.skip = offset;
            [getReplies findObjectsInBackgroundWithTarget:self selector:@selector(replyCallback: error:)];
        }*/
        
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
