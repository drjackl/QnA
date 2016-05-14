//
//  Answer.m
//  QnA
//
//  Created by Jack Li on 5/4/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "Answer.h"

@implementation Answer

- (instancetype) initWithAnswerID:(NSString*)answerID authorID:(NSString*)authorID text:(NSString*)text voteCount:(int)voteCount {
    self = [super init];
    if (self) {
        self.answerID = answerID;
        self.authorID = authorID;
        self.text = text;
        self.voteCount = voteCount;
    }
    return self;
}

- (NSString*) description {
    return [NSString stringWithFormat:@"answerID: %@, authorID: %@, votes: %d, text: %@, ", self.answerID, self.authorID, self.voteCount, self.text];
}

@end
