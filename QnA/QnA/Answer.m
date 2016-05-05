//
//  Answer.m
//  QnA
//
//  Created by Jack Li on 5/4/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "Answer.h"

@implementation Answer

- (instancetype) initWithText:(NSString*)text voteCount:(int)voteCount uid:(NSString*)uid {
    self = [super init];
    if (self) {
        self.text = text;
        self.voteCount = voteCount;
        self.uid = uid;
    }
    return self;
}

- (NSString*) description {
    return [NSString stringWithFormat:@"votes: %d, text: %@, uid: %@", self.voteCount, self.text, self.uid];
}

@end
