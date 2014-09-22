//
//  ProfileViewController.m
//  Chant
//
//  Created by Sudjeev Singh on 9/18/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "ProfileViewController.h"
#import "LoginViewController.h"

@interface ProfileViewController ()

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone)];
    self.navigationItem.title = @"Profile";
    // Do any additional setup after loading the view from its nib.
}

- (void) onDone
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onLogOut:(id)sender
{
    [PFUser logOut];
    PFUser *currentUser = [PFUser currentUser];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc]init]];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
