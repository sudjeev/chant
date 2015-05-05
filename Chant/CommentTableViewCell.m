//
//  CommentTableViewCell.m
//  Chant
//
//  Created by Sudjeev Singh on 8/20/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "Flairs.h"
#import "GAIDictionaryBuilder.h"

@implementation CommentTableViewCell

static int upvoteFlag;

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

    upvoteFlag = 0;
    self.view.layer.cornerRadius = 5;
    self.view.layer.masksToBounds = YES;
    
    if([comment isEqual:nil])
    {
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
        //this is either a user who has not set his team or a reddit comment
        self.logo.image = [UIImage imageNamed:@"NBA.png"];
        self.username.text = comment.username;
    }
    else
    {
        self.logo.image = [[Flairs allFlairs].dict objectForKey:comment.userTeam];
        NSString* team = [[Flairs allFlairs].teams objectForKey:comment.userTeam];
        NSString* usernameText = [NSString stringWithFormat:@"%@(%@)", comment.username, team];
        self.username.text = usernameText;

    }
    
    
    UIImageView *av = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 110)];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    av.image = [UIImage imageNamed:@"cell.png"];
    self.backgroundView = av;
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"mm"];
    
    NSString *stringFromDate = [formatter stringFromDate:comment.redditCreatedAt];

    //NSLog([NSString stringWithFormat:@"CREATED ATTTTTTT  %@", stringFromDate]);
    //NSLog([NSString stringWithFormat:@"FOOKERRRR %@", stringFromDate ]);
    NSTimeInterval interval;
    
    if([comment.reddit intValue] == 1 && comment.redditCreatedAt != nil)
    {
         interval = fabs([comment.redditCreatedAt timeIntervalSinceNow]);
    }
    else
    {
         interval = fabs([comment.createdAt timeIntervalSinceNow]);
    }
    
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    
    if(hours > 0)
    {
     if(hours < 10)
     {
      if(hours ==  1)
      {
          self.timeStamp.text = [NSString stringWithFormat:@"%01ld hour ago", (long)hours];
      }
      else
      {
          self.timeStamp.text = [NSString stringWithFormat:@"%01ld hours ago", (long)hours];
      }
     }
     else
     {
      self.timeStamp.text = [NSString stringWithFormat:@"%02ld hours ago", (long)hours];
     }
    }
    else if(minutes > 0)
    {
        if(minutes > 10)
        {
         self.timeStamp.text = [NSString stringWithFormat:@"%02ld minutes ago", (long)minutes];
        }
        else if(minutes > 1)
        {
         self.timeStamp.text = [NSString stringWithFormat:@"%01ld minutes ago", (long)minutes];
        }
        else
        {
            self.timeStamp.text = [NSString stringWithFormat:@"%01ld minute ago", (long)minutes];
        }
    }
    else
    {
        self.timeStamp.text = @"Just now";
    }
    //self.timeStamp.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    
}


-(IBAction)onFlag:(id)sender
{
    //save this comment data in the flag database
    PFObject* flagged = [[PFObject alloc] initWithClassName:@"Flagged"];
    flagged[@"username"]  = self.commentData.username;
    flagged[@"content"] = self.commentData.text;
    flagged[@"contentID"] = self.commentData.objectId;
    flagged[@"table"] = self.commentData.gameId;
    
    [flagged saveInBackground];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Done Flagging" message:@"This comment has been flagged and will be reviewed by our moderators within the next 24hrs" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [alert show];
}


-(IBAction)onUpvote:(id)sender
{
    upvoteFlag = 1;
    //log the reply action in google
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:@"postingComment"          // Event label
                                                           value:nil] build]];
    
    if([PFUser currentUser] == nil)
    {
        upvoteFlag = 0;
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
        //NSLog(@"already upvoted this");
        return;
    }
    
    //if it doesnt already exist in our defaults then we can add it and upvote the comment
    //NSLog(@"first time upvoting");
    [upvotedComments setObject:[[NSString alloc]init] forKey:key];
    
    [defaults setObject:upvotedComments forKey:game];
    //[defaults synchronize];
    
    //NSLog(@"got past saving in defaults");
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
            //NSLog(@"%@",[error userInfo][@"error"]);
        }
    }];
    
    
    //cut off the flow here or we will crash the app
    if([self.commentData.reddit intValue] == 1)
    {
        //NSLog(@"THIS IS A REDDIT COMMENT");
        return;
    }
    
    //upvoting the users total karma
    
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
            //NSLog(@"%@",[error userInfo][@"error"]);
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
    //NSLog(@"the badge update got sent");

}

- (IBAction)onReply:(id)sender
{

    NSString *notification = @"ReplyNotification";
    NSString *key = @"CommentValue";
    NSDictionary *info = [NSDictionary dictionaryWithObject:self.commentData forKey:key];
    [[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil userInfo:info];
    
    //log the reply action in google
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:@"replyButton"          // Event label
                                                           value:nil] build]];
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
