//
//  LiveChatCell.m
//  Chant
//
//  Created by Sudjeev Singh on 10/12/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "LiveChatCell.h"

@implementation LiveChatCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) updateWithChatRoomData:(ChatRoom *)room
{
    self.data = room;
    self.title.text = room.title;
}

@end
