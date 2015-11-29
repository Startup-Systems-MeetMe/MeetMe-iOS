//
//  CurrentUser.h
//  MeetMe
//
//  Created by Anas Bouzoubaa on 13/10/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CurrentUser : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) UIImage *profileImage;

+ (instancetype)sharedInstance;
- (void)setProfilePicture:(UIImage*)image;
- (void)setPhoneNumber:(NSString*)phone;
- (void)setName:(NSString*)username;
- (void)saveToDisk;
- (void)loadCustomObject;

@end
