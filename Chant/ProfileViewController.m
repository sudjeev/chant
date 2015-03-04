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

    
    
    //need to check if the current userData has a team set, if not then use jordan as the default
    
    PFQuery* query = [PFQuery queryWithClassName:@"userData"];
    [query whereKey:@"username" equalTo:[PFUser currentUser].username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError* error)
    {
        if(!error)
        {
            for (PFObject* object in objects)
            {
                if (object[@"Team"] != nil) {
                    self.logo.image = [[Flairs allFlairs].dict objectForKey:object[@"Team"]];
                    self.selection = object[@"Team"];
                }
                else
                {
                    self.logo.image = [UIImage imageNamed:@"jordan.jpg"];
                }
                
                self.totalUpvotes = object[@"totalUpvotes"];
                self.upvotes.text = [self.totalUpvotes stringValue];
            }
        }
        else
        {
            NSLog(@"error looking up user in userData");
        }
    }];
    
    
    
    // Do any additional setup after loading the view from its nib.
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
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
