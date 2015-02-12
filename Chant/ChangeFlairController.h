//
//  ChangeFlairController.h
//  Chant
//
//  Created by Sudjeev Singh on 2/12/15.
//  Copyright (c) 2015 SudjeevSingh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangeFlairController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) IBOutlet UIPickerView* teamPicker;

- (IBAction)onSave:(id)sender;
@end
