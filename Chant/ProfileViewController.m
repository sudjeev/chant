//
//  ProfileViewController.m
//  Chant
//
//  Created by Sudjeev Singh on 9/18/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "ProfileViewController.h"
#import "LoginViewController.h"
#import "ScheduleTableViewController.h"
#import <Parse/Parse.h>
#import "ChangeFlairController.h"
#import "Flairs.h"
#import "GAIDictionaryBuilder.h"
#import "GAITracker.h"

@interface ProfileViewController ()

@property (strong, nonatomic) NSArray* pickerData;
@property (strong, nonatomic) NSString* selection;
@property (strong, nonatomic) NSDictionary* dictionary;
@property (strong, nonatomic) NSNumber* totalUpvotes;

@end

@implementation ProfileViewController

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
    
    //connect with Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"ProfileScreen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    self.upvoteView.layer.cornerRadius = 20;
    self.upvoteView.layer.masksToBounds = YES;
    self.upvoteView.backgroundColor = [UIColor colorWithRed:255.0/255 green:100.0/255.0 blue:0.0/255.0 alpha:1];
   // self.logo.layer.cornerRadius = 50;
   // self.logo.clipsToBounds = YES;
    
    
    self.cellView.layer.borderColor = [UIColor colorWithRed:255.0/255 green:100.0/255.0 blue:0.0/255.0 alpha:1].CGColor;
    self.cellView.layer.borderWidth = 2.0f;
    self.cellView.layer.cornerRadius = 30;
    self.cellView.layer.masksToBounds = YES;

    
    self.logoutView.layer.cornerRadius = 15;
    self.logoutView.layer.masksToBounds = YES;
    self.logoutView.backgroundColor = [UIColor colorWithRed:255.0/255 green:100.0/255.0 blue:0.0/255.0 alpha:1];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone)];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255.0/255 green:100.0/255.0 blue:0.0/255.0 alpha:1];
    self.navigationItem.title = @"My Profile";
    
    self.email.text = [PFUser currentUser].email;
    self.username.text = [PFUser currentUser].username;
    self.username.textColor = [UIColor colorWithRed:255.0/255 green:100.0/255.0 blue:0.0/255.0 alpha:1];

    PFInstallation* currentInstallation = [PFInstallation currentInstallation];
    if(currentInstallation != nil)
    {
        if([currentInstallation[@"replies"] isEqualToString:@"Yes"])
        {
            [self.pushReplies setOn:YES];
        }
        else
        {
            [self.pushReplies setOn:NO];
        }
        
        if([currentInstallation[@"upvotes"] isEqualToString:@"Yes"])
        {
            [self.pushUpvotes setOn:YES];
        }
        else
        {
            [self.pushUpvotes setOn:NO];
        }
    }
    
    
    PFUser* currentUser = [PFUser currentUser];
    
    if(currentUser[@"team"] == nil || [currentUser[@"team"] isEqualToString:@"NBA"])
    {
        self.logo.image = [UIImage imageNamed:@"NBA.png"];
        self.team.text = @"NBA";

    }
    else
    {
        self.logo.image = [[Flairs allFlairs].dict objectForKey:currentUser[@"team"]];
        self.selection = currentUser[@"team"];
        self.team.text = [[Flairs allFlairs].teams objectForKey:self.selection];
        //update the installation object to hold the team of the current user
        PFInstallation* curr = [PFInstallation currentInstallation];
        [curr setObject:self.selection forKey:@"team"];
        [curr saveInBackground];
        
    }

    self.upvotes.text = [NSString stringWithFormat:@"0"];

    PFQuery* getTotalUpvotes = [PFQuery queryWithClassName:@"userData"];
    [getTotalUpvotes whereKey:@"username" equalTo:[PFUser currentUser].username];
    [getTotalUpvotes findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError* error)
     {
         if(!error)
         {
             for (PFObject* object in objects)
             {
                 self.totalUpvotes = object[@"totalUpvotes"];
                 self.upvotes.text = [self.totalUpvotes stringValue];


             }
         }
         else
         {
             //NSLog(@"%@",[error userInfo][@"error"]);
         }
     }];
    
    
    [currentUser saveInBackground];
}

- (void) onDone
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)onPasswordReset:(id)sender
{
    [PFUser requestPasswordResetForEmailInBackground:[PFUser currentUser].email];
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Password Reset" message:@"A message has been set to your email to help you reset your password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

- (IBAction)onLogOut:(id)sender
{
    [PFUser logOut];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:[[ScheduleTableViewController alloc]init]];
    navController.navigationBar.translucent = NO;
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)onChangeTeam:(id)sender
{
    //present the change team controller
    //do a parse query and update the team image so it updates faster
    [self.navigationController pushViewController:[[ChangeFlairController alloc] init] animated:YES];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:@"changeFlair"          // Event label
                                                           value:nil] build]];
}

- (IBAction)pushUpvotes:(id)sender
{
    //NSLog(@"pushUpvotes");
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if(currentInstallation != nil)
    {
     if([sender isOn])
     {
         currentInstallation[@"upvotes"] = @"Yes";
         
         //log the reply action in google
         id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
         [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                               action:@"button_press"  // Event action (required)
                                                                label:@"upvotesPushOn"          // Event label
                                                                value:nil] build]];
     }
     else
     {
         currentInstallation[@"upvotes"] = @"No";
         
         id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
         [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                               action:@"button_press"  // Event action (required)
                                                                label:@"upvotesPushOff"          // Event label
                                                                value:nil] build]];
         
     }
    
        [currentInstallation saveEventually];

    }
}
- (IBAction)pushReplies:(id)sender
{
   // NSLog(@"pushReplies");
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if(currentInstallation != nil)
    {
        if([sender isOn])
        {
            currentInstallation[@"replies"] = @"Yes";
            
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                  action:@"button_press"  // Event action (required)
                                                                   label:@"repliesPushOn"          // Event label
                                                                   value:nil] build]];
        }
        else
        {
            currentInstallation[@"replies"] = @"No";
            
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                  action:@"button_press"  // Event action (required)
                                                                   label:@"repliesPushOff"          // Event label
                                                                   value:nil] build]];
        }
        
        [currentInstallation saveEventually];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
