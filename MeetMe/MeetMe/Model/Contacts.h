//
//  Friends.h
//  MeetMe
//
//  Created by Anas Bouzoubaa on 28/11/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Contacts : NSObject

@property (strong, nonatomic) NSMutableArray *phoneContacts;
@property (strong, nonatomic) NSMutableArray *contactsOnRDV;

+ (instancetype)sharedInstance;
- (void)askForContactsAccess:(void(^)(BOOL granted))completion;
- (void)fetchContactsFromPhone:(void(^)(NSArray* phoneContacts))completion;
- (void)fetchContactsFromParse:(void(^)(NSArray* parseContacts))completion;

@end
