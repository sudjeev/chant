//
//  ReplyData.h
//  Chant
//
//  Created by Sudjeev Singh on 11/21/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReplyData : NSObject
@property (nonatomic, strong) NSString* objectID;
@property (nonatomic, strong) NSString* commentID;
@property (nonatomic, strong) NSString* reply;
@property (nonatomic, strong) NSNumber* upvotes;
@property (nonatomic, strong) NSString* username;

@end
