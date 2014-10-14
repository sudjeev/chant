//
//  StartChatController.h
//  Chant
//
//  Created by Sudjeev Singh on 10/12/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartChatController : UIViewController<UIAlertViewDelegate>
@property (nonatomic, strong) IBOutlet UIButton* create;
@property (nonatomic, strong) IBOutlet UITextField* textField;
- (IBAction)onCreate:(id)sender;
@end
