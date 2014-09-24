//
//  ProfileViewController.h
//  Chant
//
//  Created by Sudjeev Singh on 9/18/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ProfileViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>

- (IBAction)onLogOut:(id)sender;
@property (nonatomic, strong) IBOutlet UILabel* username;
@property (nonatomic, strong) IBOutlet UILabel* email;
@property (nonatomic, strong) IBOutlet UILabel* team;
@property (nonatomic, strong) IBOutlet UIPickerView *picker;
@property (nonatomic, strong) IBOutlet UIImageView *logo;
@property (nonatomic, strong) IBOutlet UIButton* change;
@property (nonatomic, strong) IBOutlet UIButton* save;
@property (nonatomic, strong) IBOutlet UILabel* upvotes;

- (IBAction)onPasswordReset:(id)sender;
- (IBAction)onChangeTeam:(id)sender;
- (IBAction)onSaveTeam:(id)sender;

@end
