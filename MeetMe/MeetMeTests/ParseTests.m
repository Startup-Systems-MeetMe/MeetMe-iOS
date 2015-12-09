//
//  ParseTests.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 09/12/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Parse/Parse.h>

@interface ParseTests : XCTestCase

@end

@implementation ParseTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [Parse setApplicationId:@"CS75y3DfeewpexaaCNLCPh5182ZM1Q8XXAV8XMOF"
                  clientKey:@"P0D3Dp4gPd6kWwHX6mgYfQitzbcqjG0uPCO8s6TO"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expect"];
    
    NSDictionary *params = @{@"calendarOne": @[@[@(0), @(1)], @[@(5), @(15)]],
                             @"calendarTwo": @[@[@(4), @(12)], @[@(17), @(20)]],
                             @"startRange": @(3)};
    [PFCloud callFunctionInBackground:@"testMergeFreeTimes" withParameters:params block:^(id  _Nullable object, NSError * _Nullable error) {
        
        NSArray *array = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@(5), @(12), nil], nil];
        XCTAssertEqualObjects(object, array);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        // Failed
    }];
}

@end
