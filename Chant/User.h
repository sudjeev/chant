//
//  User.h
//  Chant
//
//  Created by Sudjeev Singh on 8/27/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* username;
@property (strong, nonatomic) NSString* team;
@property (strong, nonatomic) NSString* upvotes;

@end
