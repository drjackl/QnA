//
//  DataSource.m
//  QnA
//
//  Created by Jack Li on 4/10/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "DataSource.h"
#import <Firebase/Firebase.h>

@interface DataSource ()
// redeclare as readwrite to set for this .m
@property (nonatomic) Firebase* reference;
@property (nonatomic) Firebase* appReference;
@property (nonatomic) Firebase* questionsReference;
@property (nonatomic) Firebase* usersReference;
@end

@implementation DataSource

+ (instancetype) onlySource {
    static dispatch_once_t onceToken;
    static DataSource* source; // normally id
    dispatch_once(&onceToken, ^{
        source = [self new];
    });
    return source;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        self.reference = [[Firebase alloc] initWithUrl:@"https://qna-app.firebaseio.com"];
        self.appReference = [self.reference childByAppendingPath:@"web/data"];
        self.questionsReference = [self.appReference childByAppendingPath:@"questions"];
        self.usersReference = [self.appReference childByAppendingPath:@"users"];
        
        self.loggedInUserID = nil; // this might not be necessary
        
        self.questions = @[];
        
        // uncomment to reset the data to boilerplate
        //[self loadBoilerplateData];
    }
    return self;
}

- (void) setLoggedInUserID:(NSString*)loggedInUserID {
    _loggedInUserID = loggedInUserID;
    
    if (loggedInUserID) {
        self.loggedInUserReference = [self.usersReference childByAppendingPath:loggedInUserID];
        
        // along with setting the loggedInReference above, sync the user's voted-for answers
        Firebase* answersVoteReference = [self.loggedInUserReference childByAppendingPath:@"answers_voted"];
        [answersVoteReference observeEventType:FEventTypeValue withBlock:^(FDataSnapshot* snapshot) {
            NSMutableDictionary* answersVotedFor = [NSMutableDictionary dictionary];
            for (FDataSnapshot* answerIDData in snapshot.children) {
                answersVotedFor[answerIDData.key] = answerIDData.key;
            }
            self.answersVotedFor = answersVotedFor;
        }];
    } else {
        self.loggedInUserReference = nil;
    }
}

- (NSDictionary*) createPostWithText:(NSString*)text {
    return @{@"text" : text,
             @"uid" : self.loggedInUserID ? self.loggedInUserID : [NSNull null]}; // surprised this compiles
}

- (NSString*) createNameFromEmail:(NSString*)email {
    NSRange atSymbolRange = [email rangeOfString:@"@"];
    NSString* username = [email substringToIndex:atSymbolRange.location];
    NSString* domain = [email substringFromIndex:atSymbolRange.location+atSymbolRange.length];
    
    NSString* houseWithDots = [domain substringToIndex:[domain rangeOfString:@"." options:NSBackwardsSearch].location];
    NSString* house = [houseWithDots stringByReplacingOccurrencesOfString:@"." withString:@" "];
    return [username.capitalizedString stringByAppendingFormat:@" of House %@", house.capitalizedString];
}

- (NSString*) createFirstNameFromEmail:(NSString*)email {
    NSString* nameFromEmail = [self createNameFromEmail:email];
    return [nameFromEmail substringToIndex:[nameFromEmail rangeOfString:@" "].location];
}

- (void) loadBoilerplateData {
    NSString* question1Text = @"How much wood would a wood chuck chuck if a woodchuck could chuck wood?";
    NSString* question2Text = @"How hard is it to get a job as an iOS Engineer?";
    NSString* question3Text = @"What can I learn/know right now in 10 minutes that will be useful for the rest of my life?";
    //NSString* question4Text = @"Why not?";
    
    NSDictionary* question1 = [self createPostWithText:question1Text];
    NSDictionary* question2 = [self createPostWithText:question2Text];
    NSDictionary* question3 = [self createPostWithText:question3Text];
    //NSDictionary* question4 = @{@"text" : question4Text};
    
    NSDictionary* questions = @{@"question1" : question1,
                                @"question2" : question2,
                                @"question3" : question3};//,
                                //@"question4" : question4};
    
    [self.questionsReference setValue:questions];
}

@end
