//
//  Answer.h
//  QnA
//
//  Created by Jack Li on 5/4/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Answer : NSObject

@property (nonatomic) NSString* answerID;
@property (nonatomic) NSString* authorID;
@property (nonatomic) NSString* text;
@property (nonatomic) int voteCount;

- (instancetype) initWithAnswerID:(NSString*)answerID authorID:(NSString*)authorID text:(NSString*)text voteCount:(int)voteCount;

@end
