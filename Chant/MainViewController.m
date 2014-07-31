//
//  MainViewController.m
//  Chant
//
//  Created by Sudjeev Singh on 7/30/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "MainViewController.h"


@interface MainViewController ()

@end

@implementation MainViewController

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
    
    self.commentBox.text = @"whattup bitch";
    UITableView* tableView = [[UITableView alloc] initWithFrame:self.tView.bounds];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.tView addSubview:tableView];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
