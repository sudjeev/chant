//
//  LiveChatCell.h
//  Chant
//
//  Created by Sudjeev Singh on 10/12/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatRoom.h"

@interface LiveChatCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel* title;
@property (nonatomic, strong) ChatRoom* data;
-(void) updateWithChatRoomData:(ChatRoom*)room;
@end
