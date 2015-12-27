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
#import "NSDate+Additions.h"

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

- (void)testEpochTime
{
    NSString *str = @"3/15/2012 9:15 PM";

    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [formatter setTimeZone:gmt];
    
    NSDate *date = [formatter dateFromString:str];
    XCTAssertEqual(date.epochTime, 1331846100000.0);
}

@end
