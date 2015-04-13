//
//  MainViewController.m
//  Chant
//
//  Created by Sudjeev Singh on 7/30/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "MainViewController.h"
#import <Parse/Parse.h>
#import "CommentTableViewCell.h"

@interface MainViewController ()
@property (strong, nonatomic) IBOutlet UITableView* tView;
@end

@implementation MainViewController

static int offset;
static bool isLoading;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [super viewDidLoad];
        self.commentBox = [[UITextField alloc] init];
        self.commentBox.delegate = self;
        self.tableData = [NSMutableArray arrayWithObjects: nil];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    offset = 10;
    
    PFQuery *getComments = [PFQuery queryWithClassName:@"Comments"];
    getComments.limit = 10;
    isLoading = YES;
    [getComments findObjectsInBackgroundWithTarget:self selector:@selector(commentCallback: error:)];
    
    
    self.commentBox.borderStyle = UITextBorderStyleLine;
    self.navigationItem.title = @"Chant";

    self.tView.delegate = self;
    self.tView.dataSource = self;

    [self.tView registerNib: [UINib nibWithNibName:@"CommentTableViewCell" bundle:nil ] forCellReuseIdentifier:@"CommentCell"];
    [self.tView registerNib: [UINib nibWithNibName:@"LoadingCell" bundle:nil ] forCellReuseIdentifier:@"LoadingCell"];
    // Do any additional setup after loading the view from its nib.
    [self.tView reloadData];
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
            isLoading = NO;
        }
        
        [self.tView reloadData];
    
    }
    else
    {
        //NSLog(@"There was a problem %@", error);
        isLoading = NO;
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
        [self.tView reloadData];
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [self.tView reloadData];
        self.commentBox.text = @"";
        [self.commentBox resignFirstResponder];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //put a plus one here so that the loading cell can show at the end of the tableView while parse is sending more data down
    return [self.tableData count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if no data and background thread is still calling
    if(self.tableData.count == 0 && isLoading)
    {
        //need to return a loading cell
        UITableViewCell* cell = [self.tView dequeueReusableCellWithIdentifier:@"LoadingCell"];
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
            offset += 10;
            [getComments findObjectsInBackgroundWithTarget:self selector:@selector(commentCallback:error:)];
        }
        
        if(indexPath.row < self.tableData.count)
        {
            CommentTableViewCell* cell = [self.tView dequeueReusableCellWithIdentifier:@"CommentCell"];
            [cell updateViewWithItem: [self.tableData objectAtIndex: indexPath.row]];
            return cell;
        }
        //show the loading cell again
        else
        {
            return [self.tView dequeueReusableCellWithIdentifier:@"LoadingCell"];
        }
    }
}


@end
