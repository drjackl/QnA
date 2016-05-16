//
//  DataSource.h
//  QnA
//
//  Created by Jack Li on 4/10/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FDataSnapshot.h>

@interface DataSource : NSObject

+ (instancetype) onlySource;

@property (readonly, nonatomic) Firebase* reference; // for signups and logins
@property (readonly, nonatomic) Firebase* questionsReference;
@property (readonly, nonatomic) Firebase* usersReference;

@property (nonatomic) NSString* loggedInUserID;
@property (nonatomic) Firebase* loggedInUserReference;
@property (nonatomic) NSDictionary* answersVotedFor; // could've been an array, but easier to check for membership

@property (nonatomic) NSArray* questions;
@property (nonatomic) FDataSnapshot* selectedQuestion;

- (NSDictionary*) createPostWithText:(NSString*)text;

- (NSString*) createNameFromEmail:(NSString*)email;
- (NSString*) createFirstNameFromEmail:(NSString*)email;

@end
