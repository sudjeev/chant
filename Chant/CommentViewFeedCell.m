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
    offset = 10;
    self.data = data;
    self.feed.dataSource = self;
    self.feed.delegate = self;
    PFQuery *getComments = [PFQuery queryWithClassName:@"Comments"];
    //need to add the filter for gameid
    getComments.limit = 10;
    isLoading = 1;
    [getComments findObjectsInBackgroundWithTarget:self selector:@selector(commentCallback: error:)];

    
    [self.feed registerNib:[UINib nibWithNibName:@"CommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"CommentTableViewCell"];
    [self.feed registerNib:[UINib nibWithNibName:@"LoadingCell" bundle:nil] forCellReuseIdentifier:@"LoadingCell"];
}


- (void) commentCallback: (NSArray*) array error: (NSError*) error
{
    if(!error)
    {
        //no error was reported
        for(PFObject* comment in array)
        {
            //for every element in the array put it in the table data
            [self.tableData addObject:comment[@"Content"]];
        }
        isLoading = 0;
        offset = [self.tableData count];
        [self.feed reloadData];
        return;
        
    }
    else
    {
        NSLog(@"There was a problem %@", error);
        isLoading = 0;
        return;
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if([self.commentBox.text isEqualToString: @""] == NO)
    {
        PFObject *newComment = [PFObject objectWithClassName:@"Comments"];
        newComment[@"Content"] = self.commentBox.text;
        [newComment saveInBackground];
        
        [self.tableData addObject:self.commentBox.text];
        self.commentBox.text = @"";
        [self.feed reloadData];
    }
    
    return YES;
}

- (IBAction)onComment:(id)sender
{
    if([self.commentBox.text isEqualToString: @""])
    {
        [self textFieldShouldReturn:self.commentBox];
        return;
    }
    
    else
    {
        PFObject *newComment = [PFObject objectWithClassName:@"Comments"];
        newComment[@"Content"] = self.commentBox.text;
        [newComment saveInBackground];
        
        [self.tableData addObject:self.commentBox.text];
        [self.feed reloadData];
        self.commentBox.text = @"";
        [self.commentBox resignFirstResponder];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //need to check if loading is true then we can show the loading cell
    
    //do i need to use a semaphore??
    if(isLoading == 0)
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
            getComments.limit = 10;
            getComments.skip = offset;
            [getComments findObjectsInBackgroundWithTarget:self selector:@selector(commentCallback:error:)];
        }
        
        if(indexPath.row < self.tableData.count)
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
    return [self.tableData count] +1;
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
