//
//  User.h
//  MeetMe
//
//  Created by Anas Bouzoubaa on 22/11/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface User : NSObject

@property (assign, nonatomic) NSString *name;
@property (assign, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) UIImage *profileImage;

- (id) initWithName:(NSString*)name andNumber:(NSString*)number andProfileImage:(UIImage*)image;

@end
