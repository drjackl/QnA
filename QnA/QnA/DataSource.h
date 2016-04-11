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

@property (nonatomic) NSArray* questions;
@property (nonatomic) FDataSnapshot* selectedQuestion;

@end
