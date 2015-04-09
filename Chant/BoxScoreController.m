//
//  BoxScoreController.m
//  Chant
//
//  Created by Sudjeev Singh on 4/8/15.
//  Copyright (c) 2015 SudjeevSingh. All rights reserved.
//

#import "BoxScoreController.h"

@implementation BoxScoreController

static UIActivityIndicatorView *loadingActivity;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Box Score";
    self.boxScore.delegate = self;
    
    NSString *urlAddress = self.gameData.boxScoreURL;
    
    //Create a URL object.
    NSURL *url = [NSURL URLWithString:urlAddress];
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    //Load the request in the UIWebView.
    [self.boxScore loadRequest:requestObj];
    [loadingActivity stopAnimating];
    
}

- (void) updateWithGameData: (GameData*) data
{
    self.gameData = data;
    
    loadingActivity = [[UIActivityIndicatorView alloc]
                       initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    loadingActivity.center=self.view.center;
    [loadingActivity startAnimating];
    [self.boxScore addSubview:loadingActivity];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request   navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error : %@",error);
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"view did start load");
}

@end
