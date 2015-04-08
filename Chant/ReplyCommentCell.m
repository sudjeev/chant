//
//  ReplyCommentCell.m
//  Chant
//
//  Created by Sudjeev Singh on 10/24/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "ReplyCommentCell.h"
#import "CommentData.h"
#import "Flairs.h"


@implementation ReplyCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) updateViewWithItem: (ReplyData*) data
{
    self.view.layer.cornerRadius = 5;
    self.view.layer.masksToBounds = YES;
    
    self.data = data;
    self.username.text = data.username;
    self.comment.text = data.reply;
    
    if(self.data.userTeam != nil)
    {
        self.flair.image = [[Flairs allFlairs].dict objectForKey:self.data.userTeam];
    }
    else
    {
        self.flair.image = [UIImage imageNamed:@"jordan.jpg"];
    }
    
    
    //set image background of the reply view
    UIImageView *av = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 171)];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    av.image = [UIImage imageNamed:@"cell.png"];
    self.backgroundView = av;

}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
