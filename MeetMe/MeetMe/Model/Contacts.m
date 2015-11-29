//
//  Friends.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 28/11/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "Contacts.h"
#import <Contacts/Contacts.h>
#import "NSString+Additions.h"
#import <Parse/Parse.h>

@interface Contacts ()

@property (strong, nonatomic) CNContactStore *store;
@property (assign, nonatomic) BOOL accessGranted;

@end

@implementation Contacts

@synthesize phoneContacts;
@synthesize contactsOnRDV;

+ (instancetype)sharedInstance
{
    static Contacts *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Contacts alloc] init];
        sharedInstance.phoneContacts = [[NSMutableArray alloc] init];
        sharedInstance.contactsOnRDV = [[NSMutableArray alloc] init];
    });
    return sharedInstance;
}

- (void)askForContactsAccess:(void(^)(BOOL granted))completion
{
    self.store = [[CNContactStore alloc] init];
    [self.store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(_accessGranted = granted);
        });
    }];
}

- (void)fetchContactsFromPhone:(void(^)(NSArray* phoneContacts))completion
{
    if (!_accessGranted) return;
    
    // Match all contacts
    NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:self.store.defaultContainerIdentifier];
    NSArray *keys = [NSArray arrayWithObjects:
                     CNContactGivenNameKey,
                     CNContactFamilyNameKey,
                     CNContactPhoneNumbersKey,
                     CNContactThumbnailImageDataKey, nil];
    
    // Store all contacts
    self.phoneContacts = [NSMutableArray arrayWithArray:[self.store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:nil]];

    // Remove contacts with no name
    NSMutableArray *toDelete = [NSMutableArray array];
    for (id object in self.phoneContacts) {
        if ([[object givenName] length] == 0) {
            [toDelete addObject:object];
        }
    }
    [self.phoneContacts removeObjectsInArray:toDelete];
    
    // Sort them alphabetically
    self.phoneContacts = [NSMutableArray arrayWithArray:[self.phoneContacts sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        return [[a givenName] compare:[b givenName]];
    }]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(self.phoneContacts);
    });
}

- (void)fetchContactsFromParse:(void(^)(NSArray* parseContacts))completion
{
    // Flatten phone numbers first
    // by removing +, (, ), and '1' for US phones
    NSMutableArray *numbers = [[NSMutableArray alloc] init];
    
    for (CNContact *contact in self.phoneContacts) {
        if (contact.phoneNumbers.count > 0) {
            for (CNLabeledValue *labeledValue in contact.phoneNumbers) {
                
                // Add the phone number as a string, without formatting
                CNPhoneNumber *number = [labeledValue value];
                NSString *parsedNum   = [[number stringValue] stringWithoutPhoneFormatting];
                if ([parsedNum length] > 0) {
                    [numbers addObject:parsedNum];
                }
            }
        }
    }
    
    [PFCloud callFunctionInBackground:@"getCommonContacts" withParameters:@{@"phoneNumbers":numbers} block:^(id  _Nullable object, NSError * _Nullable error) {
        
        // TODO: Handle Error
        if (error) return;
        
        // Add contacts in _friends array and reload table
        if ([(NSArray*)object count] > 0) {
            self.contactsOnRDV = [NSMutableArray arrayWithArray:object];
            
            // ... and sort them
            self.contactsOnRDV = [NSMutableArray arrayWithArray:[self.contactsOnRDV sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                return [[a objectForKey:@"name"] compare:[b objectForKey:@"name"]];
            }]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(self.contactsOnRDV);
        });
    }];
}


@end
