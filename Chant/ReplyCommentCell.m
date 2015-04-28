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
    self.comment.text = data.reply;
    self.upvotes.text = [data.upvotes stringValue];
    
    if(self.data.userTeam == nil || [self.data.userTeam isEqualToString:@"NBA.png"])
    {
        self.flair.image = [UIImage imageNamed:@"NBA.png"];
        self.username.text = data.username;

    }
    else
    {
        self.flair.image = [[Flairs allFlairs].dict objectForKey:self.data.userTeam];
        NSString* team = [[Flairs allFlairs].teams objectForKey:data.userTeam];
        NSString* usernameText = [NSString stringWithFormat:@"%@(%@)", data.username, team];
        self.username.text = usernameText;
    }
    
    
    //set image background of the reply view
    UIImageView *av = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 171)];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    av.image = [UIImage imageNamed:@"cell.png"];
    self.backgroundView = av;

}

- (IBAction)onFlag:(id)sender
{
    PFObject* flagged = [[PFObject alloc] initWithClassName:@"Flagged"];
    flagged[@"username"] = self.data.username;
    flagged[@"content"] = self.data.reply;
    flagged[@"contentID"] = self.data.objectID;
    flagged[@"table"] = [NSString stringWithFormat:@"%@_replies", self.data.gameID];
    
    [flagged saveInBackground];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Done Flagging" message:@"This reply has been flagged and will be reviewed by our moderators within the next 24hrs" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [alert show];
}

-(IBAction)upvote:(id)sender
{

    
    if([PFUser currentUser] == nil)
    {
        return;
    }
    
    if([[PFUser currentUser].username isEqualToString: self.data.username])
    {
        //NSLog(@"same user");
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* game = [NSString stringWithFormat:@"%@", self.data.gameID];
    //use the reply objectid to be the unique ID
    NSString* key = [NSString stringWithFormat:@"%@", self.data.objectID];
    NSMutableDictionary* upvotedComments = [[defaults objectForKey:game] mutableCopy];
    
    
    if([self.data.username isEqualToString:[PFUser currentUser].username] || [upvotedComments objectForKey:key] != nil)
    {
        //cant upvote your own comment
       // NSLog(@"already upvoted this");
        return;
    }
    
    //add the reply id to the defualts   
    [upvotedComments setObject:[[NSString alloc]init] forKey:key];
    [defaults setObject:upvotedComments forKey:game];
    
    self.data.upvotes = [[NSNumber alloc] initWithInt:[self.data.upvotes intValue] + 1];
    self.upvotes.text =  [self.data.upvotes stringValue];
    
    //add it to the defaults

    //increment the number in parse
    PFQuery* query = [PFQuery queryWithClassName:[NSString stringWithFormat:@"%@_replies", self.data.gameID ]];
    [query getObjectInBackgroundWithId:self.data.objectID block:^(PFObject *thisComment, NSError *error) {
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
    
    PFQuery* upvoteUser = [PFQuery queryWithClassName:@"userData"];
    [upvoteUser whereKey:@"username" equalTo:self.data.username];
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
    [pushQuery whereKey:@"username" equalTo:self.data.username];
    [pushQuery whereKey:@"upvotes" equalTo:@"Yes"];//if the user wants these notificaitons
    NSString* pushAlert = [NSString stringWithFormat:@"%@ upvoted your reply", [PFUser currentUser].username] ;
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
