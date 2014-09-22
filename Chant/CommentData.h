//
//  CommentData.h
//  Chant
//
//  Created by Sudjeev Singh on 9/18/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentData : NSObject
@property (nonatomic, strong) NSString* text;
@property (nonatomic, strong) NSString* username;
@property (nonatomic, strong) NSNumber* upvotes;
@property (nonatomic, strong) NSString* gameId;
@property (nonatomic, strong) NSString* objectId;
@property (nonatomic, assign) BOOL upvoted;
@end
