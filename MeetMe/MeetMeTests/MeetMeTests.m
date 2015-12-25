//
//  MeetMeTests.m
//  MeetMeTests
//
//  Created by Anas Bouzoubaa on 22/09/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CurrentUser.h"
#import "User.h"

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
    [user setProfilePicture:[UIImage imageNamed:@"default_profile_pic"]];
    [user saveToDisk];
    
    
    CurrentUser *anotherUser = [[CurrentUser alloc] init];
    [anotherUser loadCustomObject];
    
    XCTAssertEqualObjects(user.name, anotherUser.name);
    XCTAssertEqualObjects(user.phoneNumber, anotherUser.phoneNumber);
    XCTAssertEqualObjects(user.email, anotherUser.email);
    XCTAssertEqualObjects(user.profileImage, anotherUser.profileImage);
}

- (void)testSingletonInstance
{
    CurrentUser *user = [CurrentUser sharedInstance];
    XCTAssertEqual(user, [CurrentUser sharedInstance]);
}

- (void)testSavingAndLoadingPerformance {
    
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

- (void)testUserClass
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"Anas", @"name",
                                @"2123456789", @"username",
                                [PFFile fileWithData:[NSData new]], @"profilePicture",
                                nil];
    User *user = [[User alloc] initFromDictionary:dictionary];
    
    XCTAssertNotNil(user);
    XCTAssertEqualObjects(user.name, dictionary[@"name"]);
    XCTAssertEqualObjects(user.phoneNumber, dictionary[@"username"]);
    XCTAssertEqualObjects([PFFile fileWithData:[NSData new]], dictionary[@"profilePicture"]);
}

@end
