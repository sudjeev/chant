//
//  StartChatController.m
//  Chant
//
//  Created by Sudjeev Singh on 10/12/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "StartChatController.h"
#import <Parse/Parse.h>

@interface StartChatController ()

@end

@implementation StartChatController

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
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)onCreate:(id)sender
{
    if([self.textField.text isEqualToString:@""])
    {
     //show an alert telling the user to enter a title
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Enter a title for the chat room" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        PFObject* newChat = [PFObject objectWithClassName:@"chatRoom"];
        newChat[@"creator"] = [PFUser currentUser].username;
        newChat[@"title"] = self.textField.text;
        [newChat saveInBackground];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    //establish connection with parse and register a new row in the chat room class
}

- (void) onDone
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
