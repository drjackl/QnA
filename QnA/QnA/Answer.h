//
//  Answer.h
//  QnA
//
//  Created by Jack Li on 5/4/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Answer : NSObject

@property (nonatomic) NSString* text;
@property (nonatomic) int voteCount;
@property (nonatomic) NSString* uid;

- (instancetype) initWithText:(NSString*)text voteCount:(int)voteCount uid:(NSString*)uid;

@end
