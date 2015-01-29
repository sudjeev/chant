//
//  CommentViewFeedCell.m
//  Chant
//
//  Created by Sudjeev Singh on 9/15/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "CommentViewFeedCell.h"
#import "GameData.h"


@implementation CommentViewFeedCell

static int offset;
static int isLoading;


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
    
    
    offset = 10;
    self.data = data;
    self.feed.dataSource = self;
    self.feed.delegate = self;
    self.tableData = [[NSMutableArray alloc] init];
    
    PFQuery *getComments = [PFQuery queryWithClassName:@"Comments"];
    [getComments whereKey:@"GameID" equalTo:self.data.gameId];
    //need to add the filter for gameid
    getComments.limit = 10;
    isLoading = 1;
    [getComments orderByDescending:@"createdAt"];
    [getComments findObjectsInBackgroundWithTarget:self selector:@selector(commentCallback: error:)];

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
            //for every element in the array put it in the table data
            //make a comment data type and populate it here
            CommentData* data = [[CommentData alloc] init];
            data.text = comment[@"Content"];
            data.upvotes =  comment[@"Upvotes"];
            data.username = comment[@"User"];
            data.gameId = comment[@"GameID"];
            data.objectId = comment.objectId;
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
    
    if([self.commentBox.text isEqualToString: @""] == NO)
    {
        [textField resignFirstResponder];
        
        PFObject *newComment = [PFObject objectWithClassName:@"Comments"];
        newComment[@"Content"] = self.commentBox.text;
        newComment[@"GameID"] = self.data.gameId;
        newComment[@"Upvotes"] = [[NSNumber alloc] initWithInt:1];
        newComment[@"User"] = [PFUser currentUser].username;
        [newComment saveInBackground];
        
        /*
        CommentData* data = [[CommentData alloc] init];
        data.text = self.commentBox.text;
        data.gameId = self.data.gameId;
        data.upvotes = [[NSNumber alloc ] initWithInt: 1];
        data.username = [PFUser currentUser].username;
        */
        
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
                PFQuery *getComments = [PFQuery queryWithClassName:@"Comments"];
                [getComments whereKey:@"GameID" equalTo:self.data.gameId];
                //need to add the filter for gameid
                getComments.limit = 10;
                isLoading = 1;
                [getComments orderByDescending:@"createdAt"];
                [getComments findObjectsInBackgroundWithTarget:self selector:@selector(commentCallback: error:)];
            }
            break;
        case 1:
            {
                self.tableData = [[NSMutableArray alloc] init];
                PFQuery *getComments = [PFQuery queryWithClassName:@"Comments"];
                [getComments whereKey:@"GameID" equalTo:self.data.gameId];
                //need to add the filter for gameid
                getComments.limit = 10;
                isLoading = 1;
                [getComments orderByDescending:@"Upvotes"];
                [getComments findObjectsInBackgroundWithTarget:self selector:@selector(commentCallback: error:)];
            }
            break;
        case 2:
        {
            if([PFUser currentUser] == nil)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Before you can post.." message:@"Log In or Sign Up for an account, it only takes 30 seconds" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                [alert show];
                self.segmentedControl.selectedSegmentIndex = 0;
                [self valueChanged:self.segmentedControl];
                break;
            }
            
            self.tableData = [[NSMutableArray alloc] init];
            PFQuery *getComments = [PFQuery queryWithClassName:@"Comments"];
            [getComments whereKey:@"GameID" equalTo:self.data.gameId];
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
        PFObject *newComment = [PFObject objectWithClassName:@"Comments"];
        newComment[@"Content"] = self.commentBox.text;
        newComment[@"GameID"] = self.data.gameId;
        newComment[@"Upvotes"] = [[NSNumber alloc] initWithInt:1];
        newComment[@"User"] = [PFUser currentUser].username;
        [newComment saveInBackground];
        
        //this is causing a double comment entry
        /*
        CommentData* data = [[CommentData alloc] init];
        data.text = self.commentBox.text;
        data.gameId = self.data.gameId;
        data.upvotes = [[NSNumber alloc ] initWithInt: 1];
        data.username = [PFUser currentUser].username;
        */
        
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
            PFQuery *getComments = [PFQuery queryWithClassName:@"Comments"];
            [getComments whereKey:@"GameID" equalTo:self.data.gameId];
            getComments.limit = 10;
            getComments.skip = offset;
            [getComments orderByDescending:@"createdAt"];
            [getComments findObjectsInBackgroundWithTarget:self selector:@selector(commentCallback:error:)];
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
