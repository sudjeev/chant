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
    
    PFQuery *getUsers = [PFQuery queryWithClassName:@"User"];
    [getUsers whereKey:@"Username" equalTo:self.username.text];
    [getUsers findObjectsInBackgroundWithTarget:self selector:@selector(checkIfValid:error:)];

    [self.navigationController pushViewController:[[MainViewController alloc] init] animated:YES];
    
    
    //need to put in some sort of delay so this thread in the background dont screw us
    /*if(self.valid ==1 )
    {
        [self.navigationController pushViewController:[[MainViewController alloc] init] animated:YES];
    }
    else
    {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Username and Password did not match" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }*/
    
    //still need to check if you are a user through parse
    
   //self.thisUser.name =
   //save the team
    self.thisUser.username = self.username.text;
    
    
    //push the mainviewcontroller on
    [self.navigationController pushViewController:[[MainViewController alloc] init] animated:YES];
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
