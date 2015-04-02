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
    
    PFQuery* query = [PFUser query];
    [query whereKey:@"username" equalTo:data.username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError* error)
     {
         if(!error)
         {
             for (PFObject* object in objects)
             {
                 if (object[@"Team"] != nil) {
                     //self.logo.image = [self.dictionary objectForKey:object[@"Team"]];
                     self.flair.image = [[Flairs allFlairs].dict objectForKey:object[@"Team"]];
                 }
                 else
                 {
                     self.flair.image = [UIImage imageNamed:@"jordan.jpg"];
                 }
             }
         }
         else
         {
             NSLog(@"error looking up user in user");
         }
     }];
    
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
