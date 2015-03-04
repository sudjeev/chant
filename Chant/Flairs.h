//
//  Flairs.h
//  Chant
//
//  Created by Sudjeev Singh on 2/27/15.
//  Copyright (c) 2015 SudjeevSingh. All rights reserved.
//
// The purpose of this class is to centralize all the flairs, I will now just be able to call this
// class for its allFlairs shared instance variable and get any team image I want with calls to dict

#import <Foundation/Foundation.h>

@interface Flairs : NSObject
+ (instancetype) allFlairs;
@property (nonatomic, strong) NSDictionary* dict;
@end
