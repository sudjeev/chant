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


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [super viewDidLoad];
        
        self.commentBox = [[UITextField alloc] init];
        self.commentBox.delegate = self;
        

        self.tableData = [NSMutableArray arrayWithObjects: @"Hello", nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    testObject[@"foo"] = @"bar";
    [testObject saveInBackground];
    
    self.commentBox.borderStyle = UITextBorderStyleLine;
    self.navigationItem.title = @"YO";

    self.tView.delegate = self;
    self.tView.dataSource = self;

    [self.tView registerNib: [UINib nibWithNibName:@"CommentTableViewCell" bundle:nil ] forCellReuseIdentifier:@"CommentCell"];
    
    // Do any additional setup after loading the view from its nib.
    [self.tView reloadData];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if([self.commentBox.text isEqualToString: @""])
    {
        [self.tableData addObject:self.commentBox.text];
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
    
    [self.tableData addObject:self.commentBox.text];
    [self.tView reloadData];
    [self textFieldShouldReturn:self.commentBox];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CommentTableViewCell* cell = [self.tView dequeueReusableCellWithIdentifier:@"CommentCell"];
    [cell updateViewWithItem: [self.tableData objectAtIndex:indexPath.row]];
    return cell;
}


@end
