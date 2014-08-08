//
//  SignUpViewController.m
//  Chant
//
//  Created by Sudjeev Singh on 8/7/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "SignUpViewController.h"
#import "MainViewController.h"
#import <Parse/Parse.h>


@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"Sign Up";
        
        //this line aint working, supposed to remove text on back buttons
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        self.password.secureTextEntry = YES;
        self.repeatPassword.secureTextEntry = YES;
        self.view.backgroundColor = [UIColor colorWithRed:41.0/255 green:128.0/255.0 blue:185.0/255.0 alpha:1];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(IBAction)signUp:(id)sender
{
    if(self.username.text.length == 0 || self.password.text.length == 0 || self.repeatPassword.text.length == 0 || self.email.text.length == 0 )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter a value for all fields" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    else if (![self.password.text isEqualToString:self.repeatPassword.text])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your passwords do not match" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    //add functionality to check if the username has already been taken
    
    PFObject *user = [PFObject objectWithClassName:@"User"];
    user[@"username"] = self.username.text;
    //need to use SSkeychain
    user[@"password"] =  self.password.text;
    user[@"email"] = self.email.text;
    [user saveInBackground];
    
    [self presentViewController:[[MainViewController alloc] init] animated:YES completion:nil];
    
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
