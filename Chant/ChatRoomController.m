//
//  ChatRoomController.m
//  Chant
//
//  Created by Sudjeev Singh on 10/13/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "ChatRoomController.h"

@interface ChatRoomController ()

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
    //self.navigationController.navigationBar.backItem.title = @"";
}

- (void) updateViewWithChatRoom: (ChatRoom*) room
{
    //will be called by ChatRoomHome with a chat room object when a row gets selected
    //store this variable
    self.data = room;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
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
