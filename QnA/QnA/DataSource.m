//
//  DataSource.m
//  QnA
//
//  Created by Jack Li on 4/10/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "DataSource.h"
#import <Firebase/Firebase.h>

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
        
        //[self loadBoilerplateData];
        
        self.questions = @[];
    }
    return self;
}

- (NSDictionary*) createPostWithText:(NSString*)text {
    return @{@"text" : text};
}

- (void) loadBoilerplateData {
    NSString* question1Text = @"How much wood can a wood chuck chuck if a woodchuck could chuck would?";
    NSString* question2Text = @"How hard is it to get a job as an iOS Engineer?";
    NSString* question3Text = @"What can I learn/know right now in 10 minutes that will be useful for the rest of my life?";
    //NSString* question4Text = @"Why not?";
    
    NSDictionary* question1 = [self createPostWithText:question1Text];//@{@"text" : question1Text};
    NSDictionary* question2 = [self createPostWithText:question2Text];//@{@"text" : question2Text};
    NSDictionary* question3 = [self createPostWithText:question3Text];//@{@"text" : question3Text};
    //NSDictionary* question4 = @{@"text" : question4Text};
    
    NSDictionary* questions = @{@"question1" : question1,
                                @"question2" : question2,
                                @"question3" : question3};//,
                                //@"question4" : question4};
    
    [self.questionsReference setValue:questions];
}

@end
