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
#import "SSKeychain.h"
#import "SSKeychainQuery.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

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
        //self.view.backgroundColor = [UIColor colorWithRed:230.0/255 green:126.0/255.0 blue:34.0/255.0 alpha:1];
        
        self.redditInstructions.textColor = [UIColor colorWithRed:255.0/255 green:100.0/255.0 blue:0.0/255.0 alpha:1];
        self.redditSwitchLabel.textColor = [UIColor colorWithRed:255.0/255 green:100.0/255.0 blue:0.0/255.0 alpha:1];
        self.agreement.textColor = [UIColor colorWithRed:255.0/255 green:100.0/255.0 blue:0.0/255.0 alpha:1];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.redditInstructions.textColor = [UIColor colorWithRed:255.0/255 green:100.0/255.0 blue:0.0/255.0 alpha:1];
    self.redditSwitchLabel.textColor = [UIColor colorWithRed:255.0/255 green:100.0/255.0 blue:0.0/255.0 alpha:1];
    self.agreement.textColor = [UIColor colorWithRed:255.0/255 green:100.0/255.0 blue:0.0/255.0 alpha:1];

    // Do any additional setup after loading the view from its nib.

    //connect with Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"SignUpScreen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];

}

-(IBAction)toggleSwitch:(id)sender
{
    if([self.redditSwitch isOn])
    {
        //NSLog(@"Switch is on");
    }
    else
    {
       // NSLog(@"Switch is off");
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
    
    PFUser *newUser = [PFUser user];

    
    //if the user is saying they are using reddit creds then log them in to check
    if([self.redditSwitch isOn])
    {
        
        [[RKClient sharedClient] signInWithUsername:self.username.text password:self.password.text completion:^(NSError *error) {
            if (!error)
            {
                //NSLog(@"New user successfully connected to reddit");
                [SSKeychain setPassword:self.password.text forService:@"RedditService" account:@"com.chant.keychain"];
                
                //create a new parse user here
                //add functionality to check if the username has already been taken
                
                newUser.username = self.username.text;
                newUser.password = self.password.text;
                newUser.email = self.email.text;
                newUser[@"totalUpvotes"] = [NSNumber numberWithInt:1];
                newUser[@"team"] = [[NSString alloc] initWithFormat:@"NBA"];
                newUser[@"reddit"] = @"true";
                [SSKeychain setPassword:self.password.text forService:self.username.text account:@"com.chant.keychain"];
                
                
                //sign up the user
                [newUser signUpInBackgroundWithBlock:^(BOOL complete, NSError* error){
                    if(!error)
                    {
                        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[ScheduleTableViewController alloc]init]];
                        navController.navigationBar.translucent = NO;
                        
                        //update the installation object
                        PFInstallation* curr = [PFInstallation currentInstallation];
                        [curr setObject:self.username.text forKey:@"username"];
                        [curr saveInBackground];
                        
                        //make a userdata object as well
                        PFObject* userData = [PFObject objectWithClassName:@"userData"];
                        userData[@"totalUpvotes"] = [NSNumber numberWithInt:1];
                        userData[@"username"] = self.username.text;
                        [userData saveInBackground];
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connected with Reddit!" message:@"Your account has successfully been connected with Reddit!!!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alert show];
                        
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
            else
            {
                //NSLog(@"the error is: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not connect with reddit, please make sure you are entering your reddit username and password into the correct fields" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                return;
            }
        }];
   
    }
    else
    {
        //add functionality to check if the username has already been taken
        newUser.username = self.username.text;
        newUser.password = self.password.text;
        newUser.email = self.email.text;
        newUser[@"totalUpvotes"] = [NSNumber numberWithInt:1];
        newUser[@"team"] = [[NSString alloc] initWithFormat:@"NBA"];
        newUser[@"reddit"] = @"false";
        
        //sign up the user
        [newUser signUpInBackgroundWithBlock:^(BOOL complete, NSError* error){
            if(!error)
            {
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[ScheduleTableViewController alloc]init]];
                navController.navigationBar.translucent = NO;
                
                //update the installation object
                PFInstallation* curr = [PFInstallation currentInstallation];
                [curr setObject:self.username.text forKey:@"username"];
                [curr saveInBackground];
                
                //make a userdata object as well
                PFObject* userData = [PFObject objectWithClassName:@"userData"];
                userData[@"totalUpvotes"] = [NSNumber numberWithInt:1];
                userData[@"username"] = self.username.text;
                [userData saveInBackground];
                
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
