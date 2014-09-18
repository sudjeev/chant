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
#import "ScheduleTableViewController.h"

@interface LoginViewController ()
@property (nonatomic) NSInteger valid;
@property (nonatomic) NSInteger complete;

@end

@implementation LoginViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"Log in";
        self.password.secureTextEntry = YES;
        self.view.backgroundColor = [UIColor colorWithRed:41.0/255 green:128.0/255.0 blue:185.0/255.0 alpha:1];
        self.thisUser = [[User alloc] init];
        self.valid = 0;
        self.complete = 0;
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

    if(self.username.text.length == 0)
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
    
    
    [PFUser logInWithUsernameInBackground:self.username.text password:self.password.text block: ^(PFUser* user, NSError* error){
        if(user)
        {
            [self.navigationController pushViewController:[[ScheduleTableViewController alloc] init] animated:NO];
        }
        else
        {
            NSString *errorString = [error userInfo][@"error"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            return;

        }
    
    
    }];
    

    
    
    //push the mainviewcontroller on
    //call a method to push this onto a main controller
    
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

-(void)checkIfValid: (NSArray*)results error: (NSError*)error
{
 if(!error)
 {
   for(PFObject* object in results)
   {
       if ([self.password.text isEqualToString:object[@"Password"]] )
       {
           self.valid = 1;
       }
   }
 }
    
    self.complete = 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
