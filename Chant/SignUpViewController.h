//
//  SignUpViewController.h
//  Chant
//
//  Created by Sudjeev Singh on 8/7/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField* username;
@property (strong, nonatomic) IBOutlet UITextField* password;
@property (strong, nonatomic) IBOutlet UITextField* repeatPassword;
@property (strong, nonatomic) IBOutlet UITextField* email;


-(IBAction)signUp:(id)sender;
@end
