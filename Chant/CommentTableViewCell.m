//
//  CommentTableViewCell.m
//  Chant
//
//  Created by Sudjeev Singh on 8/20/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "CommentTableViewCell.h"

@implementation CommentTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

-(void) updateViewWithItem: (CommentData*) comment
{
    self.view.layer.cornerRadius = 5;
    self.view.layer.masksToBounds = YES;
    
    if([comment isEqual:nil])
    {
        NSLog(@"dis bitch is empty");
        return;
    }
    
    NSArray* keys = [[NSArray alloc] initWithObjects: @"Philadelphia 76ers",@"Milwaukee Bucks",@"Chicago Bulls", @"Cleveland Cavaliers", @"Boston Celtics", @"Los Angeles Clippers", @"Memphis Grizzlies",@"Atlanta Hawks", @"Miami Heat", @"Charlotte Hornets", @"Utah Jazz", @"Sacramento Kings", @"New York Knicks", @"Los Angeles Lakers", @"Orlando Magic", @"Dallas Mavericks", @"Brooklyn Nets", @"Denver Nuggets", @"Indiana Pacers", @"New Orleans Pelicans", @"Detroit Pistons", @"Toronto Raptors", @"Houston Rockets", @"San Antonio Spurs", @"Phoenix Suns", @"Oklahoma City Thunder", @"Minnesota Timberwolves", @"Portland Trail Blazers", @"Golden State Warriors", @"Washington Wizards", nil];
    
    NSArray* images = @[[UIImage imageNamed:@"76ers"], [UIImage imageNamed:@"Bucks"],[UIImage imageNamed:@"Bulls"],[UIImage imageNamed:@"Cavaliers"],[UIImage imageNamed:@"Celtics"],[UIImage imageNamed:@"Clippers"],[UIImage imageNamed:@"Grizzlies"],[UIImage imageNamed:@"Hawks"],[UIImage imageNamed:@"Heat"],[UIImage imageNamed:@"Hornets"],[UIImage imageNamed:@"Jazz"],[UIImage imageNamed:@"Kings"],[UIImage imageNamed:@"Knicks"],[UIImage imageNamed:@"Lakers"],[UIImage imageNamed:@"Magic"],[UIImage imageNamed:@"Mavericks"],[UIImage imageNamed:@"Nets"],[UIImage imageNamed:@"Nuggets"],[UIImage imageNamed:@"Pacers"],[UIImage imageNamed:@"Pelicans"],[UIImage imageNamed:@"Pistons"],[UIImage imageNamed:@"Raptors"],[UIImage imageNamed:@"Rockets"],[UIImage imageNamed:@"Spurs"],[UIImage imageNamed:@"Suns"],[UIImage imageNamed:@"Thunder"],[UIImage imageNamed:@"Timberwolves"],[UIImage imageNamed:@"TrailBlazers"],[UIImage imageNamed:@"Warriors"],[UIImage imageNamed:@"Wizards"]];
    
    self.dictionary = [NSDictionary dictionaryWithObjects:images forKeys:keys];
    
    self.commentData = comment;
    self.text.text = comment.text;
    self.upvotes.text = [comment.upvotes stringValue];
    self.username.text = comment.username;
    
    
    PFQuery* query = [PFQuery queryWithClassName:@"userData"];
    [query whereKey:@"username" equalTo:self.commentData.username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError* error)
     {
         if(!error)
         {
             for (PFObject* object in objects)
             {
                 if (object[@"Team"] != nil) {
                     self.logo.image = [self.dictionary objectForKey:object[@"Team"]];
                 }
                 else
                 {
                     self.logo.image = [UIImage imageNamed:@"jordan.jpg"];
                 }
             }
         }
         else
         {
             NSLog(@"error looking up user in userData");
         }
     }];
}

-(IBAction)onUpvote:(id)sender
{
    //also need to change the image of the button so it looks upvoted
    //or change the color of the cell
    //we dont need to worry about the case of not have objectID for your own comment because you can upvote your own comment
    
    if([self.commentData.username isEqualToString:[PFUser currentUser].username] || self.commentData.upvoted)
    {
        //cant upvote your own comment
        return;
    }
    
    self.commentData.upvotes = [[NSNumber alloc] initWithInt:[self.commentData.upvotes intValue] + 1];
    self.upvotes.text =  [self.commentData.upvotes stringValue];
    
    PFQuery* query = [PFQuery queryWithClassName:@"Comments"];
    [query getObjectInBackgroundWithId:self.commentData.objectId block:^(PFObject *thisComment, NSError *error) {
        // Do something with the returned PFObject in the gameScore variable.
        if(!error)
        {
            [thisComment incrementKey:@"Upvotes"];
            [thisComment saveInBackground];
        }
        else
        {
            NSLog(@"%@",[error userInfo][@"error"]);
        }
    }];
    
    PFQuery* upvoteUser = [PFQuery queryWithClassName:@"userData"];
    [upvoteUser whereKey:@"username" equalTo:self.commentData.username];
    [upvoteUser findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError* error)
    {
        if(!error)
        {
            for (PFObject* object in objects)
            {
                [object incrementKey:@"totalUpvotes"];
                [object saveInBackground];
            }
        }
        else
        {
            NSLog(@"%@",[error userInfo][@"error"]);
        }
    }];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
