//
//  ChatRoomController.m
//  Chant
//
//  Created by Sudjeev Singh on 10/13/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "ChatRoomController.h"

@interface ChatRoomController ()
@property (nonatomic, strong) NSMutableArray* comments;
//put an isLoading varible here
@end

@implementation ChatRoomController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //Construct a parse query to pull all comments out of a comments table with the specific chat room id
    
    self.navigationItem.title = self.data.title;
    self.comments = [[NSMutableArray alloc] init];
    //self.navigationController.navigationBar.backItem.title = @"";
    
    //need to sort by
    
    PFQuery* getComments = [PFQuery queryWithClassName:@"Comments"];
    [getComments whereKey:@"chatId" equalTo:self.data.objectId];
    [getComments findObjectsInBackgroundWithTarget:self selector:@selector(commentCallBack: error:)];
    
    
    //use self.data to make a call to parse for comments with objectid of the chat room object
}

- (void) updateViewWithChatRoom: (ChatRoom*) room
{
    //will be called by ChatRoomHome with a chat room object when a row gets selected
    //store this variable
    self.data = room;
}

-(void) commentCallBack: (NSArray*) array error: (NSError*) error
{
    if(!error)
    {
        for (PFObject* comment in array)
        {
            //for every comment in the array make an obj for it and add it to the array
            CommentData* data = [[CommentData alloc] init];
            data.gameId = comment[@"chatId"];
            data.text = comment[@"Content"];
            data.upvotes =  comment[@"Upvotes"];
            data.username = comment[@"User"];
            data.objectId = comment.objectId;
            [self.comments addObject:data];
        }
    }
    else
    {
        NSLog(@"Comment Callback error");
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //need to check if the textField is empty, if not then post the comment to the comment table in parse with
    if([textField.text isEqualToString:@""])
    {
        //fuck dat shit
    }
    else
    {
        PFObject* newObject = [PFObject objectWithClassName: @"Comments"];
        newObject[@"chatId"] = self.data.objectId;
        newObject[@"Content"] = textField.text;
        newObject[@"Upvotes"] = [[NSNumber alloc] initWithInt:1];
        newObject[@"User"] = [PFUser currentUser].username;;
        [newObject saveInBackground];
        [self.tableView reloadData];
    }
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[UITableViewCell alloc] init];
}

@end
