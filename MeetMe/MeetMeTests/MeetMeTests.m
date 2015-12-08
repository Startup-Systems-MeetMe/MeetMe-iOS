//
//  MeetMeTests.m
//  MeetMeTests
//
//  Created by Anas Bouzoubaa on 22/09/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CurrentUser.h"

@interface MeetMeTests : XCTestCase

@end

@implementation MeetMeTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSavingAndLoadingCurrentUser
{
    CurrentUser *user = [[CurrentUser alloc] init];
    [user setName:@"NAME"];
    [user setPhoneNumber:@"1234567890"];
    [user setEmail:@"abc@xyz.com"];
    [user saveToDisk];
    
    
    CurrentUser *anotherUser = [[CurrentUser alloc] init];
    [anotherUser loadCustomObject];
    
    XCTAssertEqualObjects(user.name, anotherUser.name);
    XCTAssertEqualObjects(user.phoneNumber, anotherUser.phoneNumber);
    XCTAssertEqualObjects(user.email, anotherUser.email);
}

- (void)testPerformanceExample {
    
    // Saving & loading the user should be fast
    [self measureBlock:^{
        CurrentUser *user = [[CurrentUser alloc] init];
        [user setName:@"NAME"];
        [user setPhoneNumber:@"1234567890"];
        [user setEmail:@"abc@xyz.com"];
        [user saveToDisk];
        
        CurrentUser *anotherUser = [[CurrentUser alloc] init];
        [anotherUser loadCustomObject];
    }];
}

@end
