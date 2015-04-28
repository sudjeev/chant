//
//  SignUpViewController.h
//  Chant
//
//  Created by Sudjeev Singh on 8/7/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController<UITextFieldDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField* username;
@property (strong, nonatomic) IBOutlet UITextField* password;
@property (strong, nonatomic) IBOutlet UITextField* email;
@property (strong, nonatomic) IBOutlet UITextView* redditInstructions;
@property (strong, nonatomic) IBOutlet UITextView* agreement;
@property (strong, nonatomic) IBOutlet UILabel* redditSwitchLabel;

@property (strong, nonatomic) IBOutlet UISwitch* redditSwitch;


- (IBAction)toggleSwitch:(id)sender;
-(IBAction)signUp:(id)sender;
@end
