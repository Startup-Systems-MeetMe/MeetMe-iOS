//
//  CurrentUser.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 13/10/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "CurrentUser.h"

// Key to save current user in user defaults
NSString * const CURRENT_USER_KEY = @"CURRENT_USER_KEY";

@implementation CurrentUser

@synthesize phoneNumber;
@synthesize name;
@synthesize profileImage;

+ (instancetype)sharedInstance
{
    static CurrentUser *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CurrentUser alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

-(id)init{
    if(self = [super init]){
        phoneNumber = @"";
        name = @"";
        profileImage = [[UIImage alloc] init];
    }
    return self;
}

//------------------------------------------------------------------------------------------
#pragma mark - Properties -
//------------------------------------------------------------------------------------------

- (NSString *)phoneNumber
{
    return phoneNumber;
}

- (NSString *)name
{
    return name;
}

- (UIImage *)profileImage
{
    return profileImage;
}

- (void)setPhoneNumber:(NSString*)phone
{
    phoneNumber = phone;
}

- (void)setProfilePicture:(UIImage*)image
{
    profileImage = image;
}

- (void)setName:(NSString*)username
{
    name = username;
}

//------------------------------------------------------------------------------------------
#pragma mark - Encoding & Saving -
//------------------------------------------------------------------------------------------

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.phoneNumber forKey:@"phoneNumber"];
    [encoder encodeObject:self.profileImage forKey:@"profileImage"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.name         = [decoder decodeObjectForKey:@"name"];
        self.phoneNumber  = [decoder decodeObjectForKey:@"phoneNumber"];
        self.profileImage = [decoder decodeObjectForKey:@"profileImage"];
    }
    return self;
}

- (void)saveToDisk
{
    NSData *encodedObject    = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:CURRENT_USER_KEY];
    [defaults synchronize];
}

- (void)loadCustomObject
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject    = [defaults objectForKey:CURRENT_USER_KEY];
    CurrentUser *user        = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];

    [self setName:user.name];
    [self setPhoneNumber:user.phoneNumber];
    [self setProfileImage:user.profileImage];
}

@end
