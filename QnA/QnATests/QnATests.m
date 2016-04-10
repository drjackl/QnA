//
//  QnATests.m
//  QnATests
//
//  Created by Jack Li on 4/8/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Firebase.h>

@interface QnATests : XCTestCase

@end

@implementation QnATests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testAddSomeQuestions {
    Firebase* ref = [[Firebase alloc] initWithUrl:@"https://qna-app.firebaseio.com"];
    Firebase* appRef = [ref childByAppendingPath:@"web/data"];
    Firebase* questionsRef = [appRef childByAppendingPath:@"questions"];
    
    NSString* question1 = @"How much wood can a wood chuck chuck if a woodchuck could chuck would?";
    NSString* question2 = @"How hard is it to get a job as an iOS Engineer?";
    NSString* question3 = @"What can I learn/know right now in 10 minutes that will be useful for the rest of my life?";
    
    NSDictionary* questions = @{@"question1" : question1,
                                @"question2" : question2,
                                @"question3" : question3};
    
    [questionsRef setValue:questions];

    XCTAssertTrue(YES);
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
