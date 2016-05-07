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

@property (readonly, nonatomic) Firebase* reference;
@property (readonly, nonatomic) Firebase* appReference;
@property (readonly, nonatomic) Firebase* questionsReference;
@property (readonly, nonatomic) Firebase* usersReference;

@property (nonatomic) Firebase* loggedInUserReference;
@property (nonatomic) NSDictionary* answersVotedFor;

@property (nonatomic) NSString* loggedInUserID;

@property (nonatomic) NSArray* questions;
@property (nonatomic) FDataSnapshot* selectedQuestion;

- (NSDictionary*) createPostWithText:(NSString*)text;

@end
