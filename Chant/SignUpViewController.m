//
//  SignUpViewController.m
//  Chant
//
//  Created by Sudjeev Singh on 8/7/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "SignUpViewController.h"
#import "ScheduleTableViewController.h"
#import "MainViewController.h"
#import <Parse/Parse.h>
#import "RKClient.h"
#import "RKClient+Users.h"
#import "RKClient+Comments.h"
#import "RKClient+Messages.h"



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
        
        self.password.enabled = NO;
        self.password.secureTextEntry = YES;
        self.password.enabled = YES;
        
        self.view.backgroundColor = [UIColor colorWithRed:230.0/255 green:126.0/255.0 blue:34.0/255.0 alpha:1];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(IBAction)toggleSwitch:(id)sender
{
    if([self.redditSwitch isOn])
    {
        NSLog(@"Switch is on");
    }
    else
    {
        NSLog(@"Switch is off");
    }
}

-(IBAction)signUp:(id)sender
{
    if(self.username.text.length == 0 || self.password.text.length == 0 || self.email.text.length == 0 )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter a value for all fields" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    //if the user is saying they are using reddit creds then log them in to check
    if([self.redditSwitch isOn])
    {
        //[[RKClient sharedClient] signInWithUsername:self.username.text password:self.password.text completion:^(NSError *error) {
        
        [[RKClient sharedClient] signInWithUsername:self.username.text password:self.password.text completion:^(NSError *error) {
            if (!error)
            {
                NSLog(@"New user successfully connected to reddit");
            }
            else
            {
                NSLog(@"the error is: %@", error);
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not connect with reddit, please make sure you are entering your reddit username and password into the correct fields" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                return;
            }
        }];
   
    }
    
    //add functionality to check if the username has already been taken
    
    PFUser *newUser = [PFUser user];
    newUser.username = self.username.text;
    newUser.password = self.password.text;
    newUser.email = self.email.text;
    
    [newUser signUpInBackgroundWithBlock:^(BOOL complete, NSError* error){
        if(!error)
        {
          //go to the schdeule controller
            
          //add the user to the other table too
          PFObject *user = [PFObject objectWithClassName:@"userData"];
          user[@"username"] = self.username.text;
            
          if([self.redditSwitch isOn])
          {
              user[@"reddit"] = @"true";
              user[@"redditPassword"] = self.password.text;
              //need to store the value in self.password.text in a different Parse table because
              //parse doesnt allow getters of the password field
              //need to find a way to hash the password before storing it again
              //I also need to check and make sure that the reddit connection is successful here and let the user know
              
          }
          else
          {
              user[@"reddit"] = @"false";
          }
            
          [user saveInBackground];
            
            
            
            
          UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[ScheduleTableViewController alloc]init]];
            navController.navigationBar.translucent = NO;
          [self presentViewController:navController animated:YES completion:nil];
        }
        else
        {
            NSString* errorString = [error userInfo][@"error"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
    }];
    
    
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
