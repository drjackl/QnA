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
        
        self.questions = @[];
    }
    return self;
}

@end
