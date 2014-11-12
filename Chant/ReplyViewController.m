//
//  ReplyViewController.m
//  Chant
//
//  Created by Sudjeev Singh on 11/11/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "ReplyViewController.h"

@interface ReplyViewController ()

@end

@implementation ReplyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) updateViewWithCommentData:(CommentData *)comment
{
    //set up all the shit right here
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.replyView.layer.cornerRadius = 5;
    self.replyView.layer.masksToBounds = YES;
    self.commentView.layer.cornerRadius = 5;
    self.commentView.layer.masksToBounds = YES;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
