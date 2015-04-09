//
//  BoxScoreController.h
//  Chant
//
//  Created by Sudjeev Singh on 4/8/15.
//  Copyright (c) 2015 SudjeevSingh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameData.h"


@interface BoxScoreController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView* boxScore;
@property (strong, nonatomic) GameData* gameData;

- (void) updateWithGameData: (GameData*) data;

@end
