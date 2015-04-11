//
//  CommentTableViewCell.m
//  Chant
//
//  Created by Sudjeev Singh on 8/20/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "Flairs.h"

@implementation CommentTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

-(void) updateViewWithItem: (CommentData*) comment
{
    self.commentData = comment;
    self.text.text = nil;
    //make links clickable in the uitextviews
    self.text.dataDetectorTypes = UIDataDetectorTypeLink;
    
    //set text of the replies button
    if([self.commentData.numReplies intValue] > 0)
    {
        self.replies.titleLabel.text = [NSString stringWithFormat:@"(%@)", self.commentData.numReplies];
    }
    
    self.view.layer.cornerRadius = 5;
    self.view.layer.masksToBounds = YES;
    
    if([comment isEqual:nil])
    {
        NSLog(@"dis bitch is empty");
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* game = [NSString stringWithFormat:@"%@", self.commentData.gameId];
    //if I dont have a dictionary for this game then make one and save it with the gameId key
    if([defaults objectForKey:game] == nil)
    {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
        [defaults setObject:dict forKey:game];
        [defaults synchronize];
    }
    
    NSString* key = [NSString stringWithFormat:@"%@", self.commentData.objectId];
    NSMutableDictionary* upvotedComments = [defaults objectForKey:game];
    
    //if the dictionary contains an object for this commentId or if I wrote this comment then show orange
    if([upvotedComments objectForKey:key] != nil || [self.commentData.username isEqual:[PFUser currentUser].username])
    {
     //[self.upvoted setBackgroundImage:[UIImage imageNamed:@"orangehand.png"] forState:UIControlStateNormal];
    }
    
    self.text.text = nil;
    self.text.text = comment.text;
    self.upvotes.text = [comment.upvotes stringValue];
    self.username.text = comment.username;
    
    if(comment.userTeam == nil || [comment.userTeam isEqualToString:@"NBA"] )
    {
        self.logo.image = [UIImage imageNamed:@"nbalogo.png"];
    }
    else
    {
        self.logo.image = [[Flairs allFlairs].dict objectForKey:comment.userTeam];
    }
    
    
    UIImageView *av = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 110)];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    av.image = [UIImage imageNamed:@"cell.png"];
    self.backgroundView = av;
}

-(IBAction)onUpvote:(id)sender
{
    if([PFUser currentUser] == nil)
    {
        return;
    }
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* game = [NSString stringWithFormat:@"%@", self.commentData.gameId];
    //use the comment objectid to be the unique ID
    NSString* key = [NSString stringWithFormat:@"%@", self.commentData.objectId];
    NSMutableDictionary* upvotedComments = [[defaults objectForKey:game] mutableCopy];
    

    if([self.commentData.username isEqualToString:[PFUser currentUser].username] || [upvotedComments objectForKey:key] != nil)
    {
        //cant upvote your own comment
        NSLog(@"already upvoted this");
        return;
    }
    
    //if it doesnt already exist in our defaults then we can add it and upvote the comment
    NSLog(@"first time upvoting");
    [upvotedComments setObject:[[NSString alloc]init] forKey:key];
    
    [defaults setObject:upvotedComments forKey:game];
    //[defaults synchronize];
    
    NSLog(@"got past saving in defaults");
    //[self.upvoted setBackgroundImage:[UIImage imageNamed:@"orangehand.png"] forState:UIControlStateNormal];
    self.commentData.upvotes = [[NSNumber alloc] initWithInt:[self.commentData.upvotes intValue] + 1];
    self.upvotes.text =  [self.commentData.upvotes stringValue];

    
    //incrementing the comments upvotes in the table
    PFQuery* query = [PFQuery queryWithClassName:self.commentData.gameId];
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
    
    
    //cut off the flow here or we will crash the app
    if([self.commentData.reddit intValue] == 1)
    {
        NSLog(@"THIS IS A REDDIT COMMENT");
        return;
    }
    
    //upvoting the users total karma
    PFQuery* upvoteUser = [PFUser query];
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
    
    //send a badge push to the user
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"username" equalTo:self.commentData.username];
    [pushQuery whereKey:@"upvotes" equalTo:@"Yes"];//if the user wants these notificaitons
    NSString* pushAlert = [NSString stringWithFormat:@"%@ upvoted your comment", [PFUser currentUser].username] ;
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          pushAlert, @"alert",
                          @"Increment", @"badge",
                          nil];
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery]; // Set our Installation query
    [push setData:data];
    [push sendPushInBackground];
    NSLog(@"the badge update got sent");

}

- (IBAction)onReply:(id)sender
{
    NSString *notification = @"ReplyNotification";
    NSString *key = @"CommentValue";
    NSDictionary *info = [NSDictionary dictionaryWithObject:self.commentData forKey:key];
    [[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil userInfo:info];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) prepareForReuse
{
    self.text.editable = YES;
    self.text.editable = NO;

}

@end
