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


@implementation CommentViewFeedCell

static int offset;
static int isLoading;
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
    
    offset = 10;
    self.data = data;
    self.feed.dataSource = self;
    self.feed.delegate = self;
    self.tableData = [[NSMutableArray alloc] init];
    //initialize mostrecent comment
    self.mostRecentComment = [PFObject objectWithClassName:self.data.gameId];
    
    //Query to get all the comments for this chatroom, by querying the gameId database
    PFQuery *getComments = [PFQuery queryWithClassName:data.gameId];
    getComments.limit = 50;
    isLoading = 1;
    
    //set atTop to 1 as we are at top of tableView
    atTop = 1;
    
    //I should check segmented control before deciding how to sort initially
    [getComments orderByDescending:@"createdAt"];
    [getComments findObjectsInBackgroundWithTarget:self selector:@selector(commentCallback: error:)];

    
    //check if the user is signed into reddit, if not then check with parse to see if he has an account connected with reddit and
    //if he does then log him in
    
    //is user aint signed into reddit but is signed into chant
    if(![[RKClient sharedClient] isSignedIn] && [PFUser currentUser] != nil)
    {
        PFQuery* query = [PFQuery queryWithClassName:@"userData"];
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
                            if([SSKeychain passwordForService:@"RedditService" account:@"com.chant.keychain"] != nil)
                            {
                             NSString* redditPassword = [SSKeychain passwordForService:[PFUser currentUser].username account:@"com.chant.keychain"];

                             [[RKClient sharedClient] signInWithUsername:[PFUser currentUser].username  password:redditPassword completion:^(NSError *error) {
                                 if (!error)
                                 {
                                     NSLog(@"User successfully connected to reddit in comment view");
                                 }
                                 else
                                 {
                                     NSLog(@"Error logging user into reddit from the comments screen");
                                 }
                             }];
                            }
                            else if (object[@"redditPassword"] != nil)
                            {
                                [[RKClient sharedClient] signInWithUsername:[PFUser currentUser].username  password:object[@"redditPassword"] completion:^(NSError *error) {
                                    if (!error)
                                    {
                                        NSLog(@"User successfully connected to reddit in comment view");
                                    }
                                    else
                                    {
                                        NSLog(@"Error logging user into reddit from the comments screen");
                                    }
                                }];
                            }
                     }
                 }
             }
         }];
    }

    
    [self.feed registerNib:[UINib nibWithNibName:@"CommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"CommentTableViewCell"];
    [self.feed registerNib:[UINib nibWithNibName:@"LoadingCell" bundle:nil] forCellReuseIdentifier:@"LoadingCell"];

}


- (void) commentCallback: (NSArray*) array error: (NSError*) error
{

    if(!error)
    {
        //no error was reported
        if([array count] == 0)
        {
            NSLog(@"The query didnt return shit !!!!!!!!!!!!!!!!");
            return;
        }
        
        for(PFObject* comment in array)
        {
            if(atTop == 1)
            {
             //save the most recent comment
                self.mostRecentComment = comment;
                NSLog(@"MOST RECENT COMMENT IS: %@", self.mostRecentComment.createdAt);
                //set at top back to zero so it doesn't get called every time in the loop
                atTop = 0;
            }
            
            //for every element in the array put it in the table data
            //make a comment data type and populate it here
            CommentData* data = [[CommentData alloc] init];
            data.text = comment[@"Content"];
            data.upvotes =  comment[@"Upvotes"];
            data.username = comment[@"User"];
            data.objectId = comment.objectId;
            
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
        NSLog(@"There was a problem %@", error);
        isLoading = 0;
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //if the user isnt logged into his account he shouldnt be allowed to post any content
    if([PFUser currentUser] == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Before you can post.." message:@"Log In or Sign Up for an account, it only takes 30 seconds" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
        [textField resignFirstResponder];
        return YES;
    }
    
    //if the comment box is not empty
    if([self.commentBox.text isEqualToString: @""] == NO)
    {
        //drop the keyboard
        [textField resignFirstResponder];
        
        //need to save this comment id in NSUserDefaults
        
        //make a PFObject for the new comment and save it in parse
        PFObject *newComment = [PFObject objectWithClassName:self.data.gameId];
        newComment[@"Content"] = self.commentBox.text;
        newComment[@"GameID"] = self.data.gameId;
        newComment[@"Upvotes"] = [[NSNumber alloc] initWithInt:1];
        newComment[@"User"] = [PFUser currentUser].username;
        [newComment saveInBackground];
        
        
        //increment my total upvotes by 1 after I post a new comment
        PFQuery* query = [PFQuery queryWithClassName:@"userData"];
        [query whereKey:@"username" equalTo:[PFUser currentUser].username];
        [query findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError* error)
         {
             if(!error)
             {
                 for(PFObject* object in objects)
                 {
                     [object incrementKey:@"totalUpvotes"];
                     [object saveInBackground];
                 }
             }
         }];
        
        
        /*
         //Code for crossposting comment to reddit
         //have an if statement checking if the user is connected to reddit, then confirm that he is logged in, if not then
         //log the user in using their credentials which we will have stored on parse
         //
         //Following this I should make a call to get the redditFullName from parse in case it wasnt there when the chat room was
         //initially made
         //then simply post the comment to reddit from this users account
         
         [[RKClient sharedClient] submitComment:@"testing" onThingWithFullName:@"t3_2ufbks" completion:^(NSError *error){
         if(!error)
         {NSLog(@"It shouldve posted to comments");}
         }];
         */
        
        
        //if there is a gamethread to post to and the user is signed into reddit
        if(self.data.redditFullName != nil && [[RKClient sharedClient]isSignedIn])
        {
            [[RKClient sharedClient] submitComment:self.commentBox.text onThingWithFullName:self.data.redditFullName completion:^(NSError *error){
                if(!error)
                    {
                        NSLog(@"It shouldve posted to comments of %@", self.data.redditFullName);
                    }
                else
                {
                    NSLog(@"Couldnt crosspost the comment to reddit game threads");
                }
            }];
        }
        
        self.commentBox.text = @"";
        
        //throw up a loading spinner
        
        //reload the whole tableview based on segmented control value
        [self valueChanged:self.segmentedControl];
    }
    
    [textField resignFirstResponder];
    
    return YES;
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
                getComments.limit = 50;
                isLoading = 1;
                [getComments orderByDescending:@"createdAt"];
                //set at top to 1 so we can reset the most recent comment
                atTop = 1;
                [getComments findObjectsInBackgroundWithTarget:self selector:@selector(commentCallback: error:)];
            }
            break;
        case 1:
            {
                self.tableData = [[NSMutableArray alloc] init];
                PFQuery *getComments = [PFQuery queryWithClassName:self.data.gameId];
                //need to add the filter for gameid
                getComments.limit = 50;
                isLoading = 1;
                [getComments orderByDescending:@"Upvotes"];
                [getComments findObjectsInBackgroundWithTarget:self selector:@selector(commentCallback: error:)];
            }
            break;
        case 2:
        {
            if([PFUser currentUser] == nil)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You are not logged in" message:@"Log In or Sign Up for an account, it only takes 30 seconds" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
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
        }
        default:
            break;
    }
}

- (IBAction)onComment:(id)sender
{
    //if not logged in
    if([PFUser currentUser] == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Before you can post.." message:@"Log In or Sign Up for an account, it only takes 30 seconds" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
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
        PFObject *newComment = [PFObject objectWithClassName:self.data.gameId];
        newComment[@"Content"] = self.commentBox.text;
        newComment[@"GameID"] = self.data.gameId;
        newComment[@"Upvotes"] = [[NSNumber alloc] initWithInt:1];
        newComment[@"User"] = [PFUser currentUser].username;
        [newComment saveInBackground];
        
        
        //upvote the users totalupvotes by 1
        PFQuery* query = [PFQuery queryWithClassName:@"userData"];
        [query whereKey:@"username" equalTo:[PFUser currentUser].username];
        [query findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError* error)
         {
             if(!error)
             {
                 for(PFObject* object in objects)
                 {
                     [object incrementKey:@"totalUpvotes"];
                     [object saveInBackground];
                 }
             }
         }];
        
        
        //if there is a gamethread for this game and if the user is signed in then crosspost this too reddit
        if(self.data.redditFullName != nil && [[RKClient sharedClient]isSignedIn])
        {
            [[RKClient sharedClient] submitComment:self.commentBox.text onThingWithFullName:self.data.redditFullName completion:^(NSError *error){
                if(!error)
                {NSLog(@"It shouldve posted to comments of %@", self.data.redditFullName);}
                else
                {
                    NSLog(@"Couldnt crosspost the comment to reddit game threads");
                }
            }];
        }
        
        //reset the comment box and drop the keyboard
        self.commentBox.text = @"";
        [self.commentBox resignFirstResponder];

        //reload the whole tableview based on segmented control value
        [self valueChanged:self.segmentedControl];
    }
}


- (IBAction)onRefresh:(id)sender
{
    //Just call the segmented control method
    [self valueChanged:self.segmentedControl];
    /*
    self.tableData = [[NSMutableArray alloc] init];
    [self.feed reloadData];
    //call the query again
    PFQuery *getComments = [PFQuery queryWithClassName:@"Comments"];
    [getComments whereKey:@"GameID" equalTo:self.data.gameId];
    //need to add the filter for gameid
    getComments.limit = 10;
    isLoading = 1;
    [getComments orderByDescending:@"createdAt"];
    [getComments findObjectsInBackgroundWithTarget:self selector:@selector(commentCallback: error:)];
     */
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //need to check if loading is true then we can show the loading cell
    
    //do i need to use a semaphore??
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
            [getComments findObjectsInBackgroundWithTarget:self selector:@selector(commentCallback:error:)];
        }
        
        if(indexPath.row < [self.tableData count])
        {
            NSLog(@"We are at the end of the table view so no more calls");
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
    
    return 110;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

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
