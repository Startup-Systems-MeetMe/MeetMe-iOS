//
//  AdditionsTests.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 03/10/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+Additions.h"

@interface AdditionsTests : XCTestCase

@end

@implementation AdditionsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPhoneNumberParsing
{
    XCTAssertFalse([@"phone-number" isUSPhoneNumber]);
    XCTAssert([@"(212) 123-2345" isUSPhoneNumber]);

    
//    XCTAssertEqual(bH, 8)
}

- (void)testRemovingPhoneFormat
{
    XCTAssert([[@"(212) 123-2345" stringWithoutPhoneFormatting] isEqualToString:@"2121232345"]);
    XCTAssertFalse([[@"(212) 123-2345" stringWithoutPhoneFormatting] isEqualToString:@"212 123-2345"]);
    XCTAssert([[@"+12121232345" stringWithoutPhoneFormatting] isEqualToString:@"2121232345"]);
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
