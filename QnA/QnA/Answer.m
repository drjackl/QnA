//
//  Answer.m
//  QnA
//
//  Created by Jack Li on 5/4/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "Answer.h"

@implementation Answer

- (instancetype) initWithText:(NSString*)text voteCount:(int)voteCount answerID:(NSString*)answerID {
    self = [super init];
    if (self) {
        self.text = text;
        self.voteCount = voteCount;
        self.answerID = answerID;
    }
    return self;
}

- (NSString*) description {
    return [NSString stringWithFormat:@"votes: %d, text: %@, answerID: %@", self.voteCount, self.text, self.answerID];
}

@end
