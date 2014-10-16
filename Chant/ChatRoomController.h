//
//  ChatRoomController.h
//  Chant
//
//  Created by Sudjeev Singh on 10/13/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatRoom.h"
#import "CommentData.h"
#import <Parse/Parse.h>


@interface ChatRoomController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) IBOutlet UITextField* textField;
@property (nonatomic, strong) IBOutlet ChatRoom* data;
- (void) updateViewWithChatRoom: (ChatRoom*) room;
@end
