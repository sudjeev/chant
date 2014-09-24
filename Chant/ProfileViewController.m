//
//  ProfileViewController.m
//  Chant
//
//  Created by Sudjeev Singh on 9/18/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "ProfileViewController.h"
#import "LoginViewController.h"
#import <Parse/Parse.h>

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone)];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title = [PFUser currentUser].username;
    
    self.email.text = [PFUser currentUser].email;
    
    self.pickerData =  [[NSArray alloc] initWithObjects: @"Philadelphia 76ers",@"Milwaukee Bucks",@"Chicago Bulls", @"Cleveland Cavaliers", @"Boston Celtics", @"Los Angeles Clippers", @"Memphis Grizzlies",@"Atlanta Hawks", @"Miami Heat", @"Charlotte Hornets", @"Utah Jazz", @"Sacramento Kings", @"New York Knicks", @"Los Angeles Lakers", @"Orlando Magic", @"Dallas Mavericks", @"Brooklyn Nets", @"Denver Nuggets", @"Indiana Pacers", @"New Orleans Pelicans", @"Detroit Pistons", @"Toronto Raptors", @"Houston Rockets", @"San Antonio Spurs", @"Phoenix Suns", @"Oklahoma City Thunder", @"Minnesota Timberwolves", @"Portland Trail Blazers", @"Golden State Warriors", @"Washington Wizards", nil];
    
    NSArray* images = @[[UIImage imageNamed:@"76ers"], [UIImage imageNamed:@"Bucks"],[UIImage imageNamed:@"Bulls"],[UIImage imageNamed:@"Cavaliers"],[UIImage imageNamed:@"Celtics"],[UIImage imageNamed:@"Clippers"],[UIImage imageNamed:@"Grizzlies"],[UIImage imageNamed:@"Hawks"],[UIImage imageNamed:@"Heat"],[UIImage imageNamed:@"Hornets"],[UIImage imageNamed:@"Jazz"],[UIImage imageNamed:@"Kings"],[UIImage imageNamed:@"Knicks"],[UIImage imageNamed:@"Lakers"],[UIImage imageNamed:@"Magic"],[UIImage imageNamed:@"Mavericks"],[UIImage imageNamed:@"Nets"],[UIImage imageNamed:@"Nuggets"],[UIImage imageNamed:@"Pacers"],[UIImage imageNamed:@"Pelicans"],[UIImage imageNamed:@"Pistons"],[UIImage imageNamed:@"Raptors"],[UIImage imageNamed:@"Rockets"],[UIImage imageNamed:@"Spurs"],[UIImage imageNamed:@"Suns"],[UIImage imageNamed:@"Thunder"],[UIImage imageNamed:@"Timberwolves"],[UIImage imageNamed:@"TrailBlazers"],[UIImage imageNamed:@"Warriors"],[UIImage imageNamed:@"Wizards"]];
    
    self.dictionary = [NSDictionary dictionaryWithObjects:images forKeys:self.pickerData];
    
    self.picker.dataSource = self;
    self.picker.delegate = self;
    
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
                    self.logo.image = [self.dictionary objectForKey:object[@"Team"]];
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
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc]init]];
    navController.navigationBar.translucent = NO;
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)onChangeTeam:(id)sender
{
    //unhide the picker
    self.picker.hidden = NO;
    self.save.hidden = NO;
    self.change.hidden = YES;
}

- (IBAction)onSaveTeam:(id)sender
{
    self.picker.hidden = YES;
    
    if(self.selection == nil)
    {
        self.selection = [self.pickerData objectAtIndex:0];
    }
    
    self.logo.image = [self.dictionary objectForKey:self.selection];
    self.change.hidden = NO;
    self.save.hidden = YES;
    
    //update in parse
    
    if([self.picker selectedRowInComponent:0] == -1)
    {
        NSLog(@"Yea this is the problem");
    }
    
    PFQuery* query = [PFQuery queryWithClassName:@"userData"];
    [query whereKey:@"username" equalTo:[PFUser currentUser].username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError* error)
     {
         if(!error)
         {
             for (PFObject* object in objects)
             {
                 object[@"Team"] = self.selection;
                 [object saveInBackground];
             }
         }
         else
         {
             NSLog(@"error looking up user in userData");
         }
     }];


}
//the number of columns in the picker view
- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.pickerData[row];
}

// get the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
    self.selection =  self.pickerData[row];
    
    //need to update it in parse
    //add it to 
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
