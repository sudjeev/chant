//
//  LoginViewController.m
//  Chant
//
//  Created by Sudjeev Singh on 8/5/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "MainViewController.h"
#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "SignUpViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"Log in";
        self.password.secureTextEntry = YES;
        self.view.backgroundColor = [UIColor colorWithRed:41.0/255 green:128.0/255.0 blue:185.0/255.0 alpha:1];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)onSave:(id)sender
{
    [self textFieldShouldReturn:self.username];

    if(self.password.text.length == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Username" message:@"You forgot to enter a username" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if(self.password.text.length == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password" message:@"You forgot to enter a password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    //Do a parse query to see 
    PFObject *user = [PFObject objectWithClassName:@"Users"];
    user[@"UserName"] = self.username.text;
    user[@"Key"] =  self.password.text;
    [user saveInBackground];
    
    //push the mainviewcontroller on
    [self presentViewController:[[MainViewController alloc] init] animated:YES completion:nil];
}

- (IBAction)toSignUp:(id)sender
{
    //pass the signup screen
    [self.navigationController pushViewController:[[SignUpViewController alloc] init] animated:YES];
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

@end
