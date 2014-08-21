//
//  CommentTableViewCell.h
//  Chant
//
//  Created by Sudjeev Singh on 8/20/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel* comment;
-(void) updateViewWithItem: (NSString*) comment;
@end
