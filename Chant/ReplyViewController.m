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
    self.navigationItem.title = @"Reply";
    
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
    
    /*
    NSArray* keys = [[NSArray alloc] initWithObjects: @"Philadelphia 76ers",@"Milwaukee Bucks",@"Chicago Bulls", @"Cleveland Cavaliers", @"Boston Celtics", @"Los Angeles Clippers", @"Memphis Grizzlies",@"Atlanta Hawks", @"Miami Heat", @"Charlotte Hornets", @"Utah Jazz", @"Sacramento Kings", @"New York Knicks", @"Los Angeles Lakers", @"Orlando Magic", @"Dallas Mavericks", @"Brooklyn Nets", @"Denver Nuggets", @"Indiana Pacers", @"New Orleans Pelicans", @"Detroit Pistons", @"Toronto Raptors", @"Houston Rockets", @"San Antonio Spurs", @"Phoenix Suns", @"Oklahoma City Thunder", @"Minnesota Timberwolves", @"Portland Trail Blazers", @"Golden State Warriors", @"Washington Wizards", nil];
    
    NSArray* images = @[[UIImage imageNamed:@"76ers"], [UIImage imageNamed:@"Bucks"],[UIImage imageNamed:@"Bulls"],[UIImage imageNamed:@"Cavaliers"],[UIImage imageNamed:@"Celtics"],[UIImage imageNamed:@"Clippers"],[UIImage imageNamed:@"Grizzlies"],[UIImage imageNamed:@"Hawks"],[UIImage imageNamed:@"Heat"],[UIImage imageNamed:@"Hornets"],[UIImage imageNamed:@"Jazz"],[UIImage imageNamed:@"Kings"],[UIImage imageNamed:@"Knicks"],[UIImage imageNamed:@"Lakers"],[UIImage imageNamed:@"Magic"],[UIImage imageNamed:@"Mavericks"],[UIImage imageNamed:@"Nets"],[UIImage imageNamed:@"Nuggets"],[UIImage imageNamed:@"Pacers"],[UIImage imageNamed:@"Pelicans"],[UIImage imageNamed:@"Pistons"],[UIImage imageNamed:@"Raptors"],[UIImage imageNamed:@"Rockets"],[UIImage imageNamed:@"Spurs"],[UIImage imageNamed:@"Suns"],[UIImage imageNamed:@"Thunder"],[UIImage imageNamed:@"Timberwolves"],[UIImage imageNamed:@"TrailBlazers"],[UIImage imageNamed:@"Warriors"],[UIImage imageNamed:@"Wizards"]];
    // Do any additional setup after loading the view from its nib.
    self.dictionary = [NSDictionary dictionaryWithObjects:images forKeys:keys];*/
    
    //I should now be able to just use [[Flairs allFlairs].dict objectForKey:object[@"Team"]];
    
    //get this users favorite team
    PFQuery* query = [PFQuery queryWithClassName:@"userData"];
    [query whereKey:@"username" equalTo:self.myCommentData.username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError* error)
     {
         if(!error)
         {
             for (PFObject* object in objects)
             {
                 if (object[@"Team"] != nil) {
                     self.userFlair.image = [[Flairs allFlairs].dict objectForKey:object[@"Team"]];
                 }
                 else
                 {
                     self.userFlair.image = [UIImage imageNamed:@"jordan.jpg"];
                 }
             }
         }
         else
         {
             NSLog(@"error looking up user in userData");
         }
     }];

    //need to get the replies to this comment
    PFQuery* getReplies = [PFQuery queryWithClassName:@"Replies"];
    [getReplies whereKey:@"CommentID" equalTo:self.myCommentData.objectId];
    isLoading = 1;
    getReplies.limit = 10;
    [getReplies findObjectsInBackgroundWithTarget:self selector:@selector(replyCallback: error:)];

}

-(void)replyCallback: (NSArray*) array error:(NSError*) error
{
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
            
            [self.replies addObject:newReply];
        }
        
        isLoading = 0;
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
    
    
    //handle all the logic for storing the comment here
    PFObject *newComment = [PFObject objectWithClassName:@"Replies"];
    newComment[@"Reply"] = self.replyBox.text;
    newComment[@"CommentID"] = self.myCommentData.objectId;
    newComment[@"Upvotes"] = [[NSNumber alloc] initWithInt:1];
    newComment[@"Username"] = [PFUser currentUser].username;
    [newComment saveInBackground];
    
    //send a push the the user
    PFQuery* pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"username" equalTo: self.myCommentData.username];
    PFPush* push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    NSString* pushMessage = [NSString stringWithFormat:@"%@ replied to your comment: %@", [PFUser currentUser].username, self.replyBox.text];
    [push setMessage:pushMessage];
    [push sendPushInBackground];
    
    //reset the replies array
    self.replies = [[NSMutableArray alloc] init];

    
    //now recall the query to get all the comments again
    PFQuery* getReplies = [PFQuery queryWithClassName:@"Replies"];
    [getReplies whereKey:@"CommentID" equalTo:self.myCommentData.objectId];
    isLoading = 1;
    getReplies.limit = 10;
    [getReplies findObjectsInBackgroundWithTarget:self selector:@selector(replyCallback: error:)];
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
        
        //find out how to launch a loading spinner
        
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
        [self.view addSubview: activityIndicator];
        
        activityIndicator.color = [UIColor redColor];
        [activityIndicator startAnimating];
        
        //handle all the logic for storing the comment here
        PFObject *newComment = [PFObject objectWithClassName:@"Replies"];
        newComment[@"Reply"] = self.replyBox.text;
        newComment[@"CommentID"] = self.myCommentData.objectId;
        newComment[@"Upvotes"] = [[NSNumber alloc] initWithInt:1];
        newComment[@"Username"] = [PFUser currentUser].username;
        [newComment saveInBackground];
        
        //send a push the the user
        PFQuery* pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"username" equalTo: self.myCommentData.username];
        PFPush* push = [[PFPush alloc] init];
        [push setQuery:pushQuery];
        NSString* pushMessage = [NSString stringWithFormat:@"%@ replied to your comment: %@", [PFUser currentUser].username, self.replyBox.text];
        [push setMessage:pushMessage];
        [push sendPushInBackground];
        
        //reset the array of replies
        self.replies = [[NSMutableArray alloc] init];
        
        //now recall the query to get all the comments again
        PFQuery* getReplies = [PFQuery queryWithClassName:@"Replies"];
        [getReplies whereKey:@"CommentID" equalTo:self.myCommentData.objectId];
        isLoading = 1;
        getReplies.limit = 10;
        [getReplies findObjectsInBackgroundWithTarget:self selector:@selector(replyCallback: error:)];
        self.replyBox.text = @"";
        [self.replyBox resignFirstResponder];
        
        
        [self.tableView reloadData];
        [activityIndicator stopAnimating];
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
        //if indexPath has reached the point right before the end of tableData
        if(indexPath.row + 1  >= [self.replies count])
        {
            //this is being entered every time if i only have a few comments
            PFQuery *getReplies = [PFQuery queryWithClassName:@"Repleis"];
            [getReplies whereKey:@"GameID" equalTo:self.myCommentData.objectId];
            getReplies.limit = 10;
            getReplies.skip = offset;
            [getReplies orderByDescending:@"createdAt"];
            [getReplies findObjectsInBackgroundWithTarget:self selector:@selector(replyCallback:error:)];
        }
        
        if(indexPath.row < [self.replies count])
        {
            ReplyCommentCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"ReplyCommentCell"];
            [cell updateViewWithItem: [self.replies objectAtIndex: indexPath.row]];
            return cell;
        }
        //show the loading cell again
        else
        {
            UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
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
