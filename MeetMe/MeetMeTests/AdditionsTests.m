//
//  AdditionsTests.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 03/10/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+Additions.h"
#import "UIImage+Additions.h"

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
}

- (void)testRemovingPhoneFormat
{
    XCTAssert([[@"(212) 123-2345" stringWithoutPhoneFormatting] isEqualToString:@"2121232345"]);
    XCTAssertFalse([[@"(212) 123-2345" stringWithoutPhoneFormatting] isEqualToString:@"212 123-2345"]);
    XCTAssert([[@"+12121232345" stringWithoutPhoneFormatting] isEqualToString:@"2121232345"]);
}

- (void)testRescalingImages
{
    UIImage *image = [UIImage imageNamed:@"default_profile_pic"];
    CGSize size = CGSizeMake(10, 10);
    image = [UIImage imageWithImage:image scaledToSize:size];
    XCTAssertEqual(size.width, image.size.width);
    XCTAssertEqual(size.height, image.size.height);
}

@end
