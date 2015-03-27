//
//  ChangeFlairController.m
//  Chant
//
//  Created by Sudjeev Singh on 2/12/15.
//  Copyright (c) 2015 SudjeevSingh. All rights reserved.
//

#import "ChangeFlairController.h"
#import <Parse/Parse.h>


@interface ChangeFlairController ()
@property (strong, nonatomic) NSArray* pickerData;
@property (strong, nonatomic) NSString* selection;
@property (strong, nonatomic) NSDictionary* dictionary;
@end

@implementation ChangeFlairController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.teamPicker.dataSource = self;
    self.teamPicker.delegate = self;
    
    // Do any additional setup after loading the view from its nib.
    self.pickerData =  [[NSArray alloc] initWithObjects: @"Philadelphia 76ers",@"Milwaukee Bucks",@"Chicago Bulls", @"Cleveland Cavaliers", @"Boston Celtics", @"Los Angeles Clippers", @"Memphis Grizzlies",@"Atlanta Hawks", @"Miami Heat", @"Charlotte Hornets", @"Utah Jazz", @"Sacramento Kings", @"New York Knicks", @"Los Angeles Lakers", @"Orlando Magic", @"Dallas Mavericks", @"Brooklyn Nets", @"Denver Nuggets", @"Indiana Pacers", @"New Orleans Pelicans", @"Detroit Pistons", @"Toronto Raptors", @"Houston Rockets", @"San Antonio Spurs", @"Phoenix Suns", @"Oklahoma City Thunder", @"Minnesota Timberwolves", @"Portland Trail Blazers", @"Golden State Warriors", @"Washington Wizards", nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)onSave:(id)sender
{
    if(self.selection == nil)
    {
        self.selection = [self.pickerData objectAtIndex:0];
    }
    
    if([self.teamPicker selectedRowInComponent:0] == -1)
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
                 
                 //update the installation object
                 PFInstallation* curr = [PFInstallation currentInstallation];
                 [curr setObject:self.selection forKey:@"team"];
                 [curr saveInBackground];
             }
         }
         else
         {
             NSLog(@"error looking up user in userData");
         }
     }];

    [self dismissViewControllerAnimated:YES completion:nil];
    
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


@end
