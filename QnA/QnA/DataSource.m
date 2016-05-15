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
        Firebase* appReference = [self.reference childByAppendingPath:@"web/data"];
        self.questionsReference = [appReference childByAppendingPath:@"questions"];
        self.usersReference = [appReference childByAppendingPath:@"users"];
        
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
    NSString* question1Text = @"Arya Stark hasn’t been seen since her father was killed. Where do you think she is? My money’s on dead. There’s a certain safety in death, wouldn’t you say?";
    NSString* question2Text = @"What do we say to the God of death?";
    NSString* question3Text = @"Which name would you like a girl to speak?";
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
