//
//  LoginViewController.h
//  Chant
//
//  Created by Sudjeev Singh on 8/5/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField* username;
@property (strong, nonatomic) IBOutlet UITextField* password;
@property (strong, nonatomic) IBOutlet UIButton* save;
@property (strong, nonatomic) IBOutlet UIButton* signUp;

- (IBAction)onSave:(id)sender;
- (IBAction)toSignUp:(id)sender;
@end
