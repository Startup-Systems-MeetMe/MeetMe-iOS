//
//  SelectContactsViewController.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 28/10/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "SelectContactsViewController.h"
#import <Contacts/Contacts.h>
#import <Parse/Parse.h>

@interface SelectContactsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@property (strong, nonatomic) NSMutableArray *contactsArray;
@property (strong, nonatomic) NSMutableArray *notInAppArray;
@property (strong, nonatomic) NSMutableArray *friends;
@property (strong, nonatomic) CNContactStore *store;

@end

@implementation SelectContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.contactsArray = [[NSMutableArray alloc] init];
    self.notInAppArray = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    
    self.store = [[CNContactStore alloc] init];
    [self.store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
    
        if (!granted) return;
        
        [self fetchContacts];
        
    }];
}

- (void)fetchContacts
{
    // Fetch all contacts
    NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:self.store.defaultContainerIdentifier];
    NSArray *keys = [NSArray arrayWithObjects:
                             CNContactGivenNameKey,
                             CNContactFamilyNameKey,
                             CNContactPhoneNumbersKey,
                             CNContactThumbnailImageDataKey, nil];
    
    // Go back to main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // Store all contacts
        _contactsArray = [NSMutableArray arrayWithArray:[self.store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:nil]];
        [_myTableView reloadData];
        
        // Send Parse the phone numbers
        [self pushContactsToParse];
    });
}

- (void) pushContactsToParse
{
    // Flatten phone numbers first
    // by removing +, (, ), and '1' for US phones
    NSMutableArray *numbers = [[NSMutableArray alloc] init];
    for (CNContact *contact in self.contactsArray) {
        if (contact.phoneNumbers.count > 0) {
            for (CNLabeledValue *labeledValue in contact.phoneNumbers) {
                CNPhoneNumber *number = [labeledValue value];
                NSString *parsedNum = [[[number stringValue] componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
                if ([parsedNum characterAtIndex:0] == '1') {
                    parsedNum = [parsedNum substringFromIndex:1];
                }
                [numbers addObject:parsedNum];
            }
        }
    }
    
    NSLog(@"%@", numbers);
    
    [PFCloud callFunctionInBackground:@"getCommonContacts" withParameters:@{@"phoneNumbers":numbers} block:^(id  _Nullable object, NSError * _Nullable error) {
        //if (error) return;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//------------------------------------------------------------------------------------------
#pragma mark - UITableView -
//------------------------------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    return self.contactsArray.count > 0 ? 2 : 1;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return self.contactsArray.count > 0 ? self.contactsArray.count : 2;
    return 10; // Show 100 contacts not in app
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"contactCell"];
    }

    if (indexPath.section == 0) {
        NSArray *names = @[@"Anas", @"Mark"];
        NSArray *phones = @[@"235355435", @"32324325"];
        
        if (self.contactsArray.count == 0) {
            cell.textLabel.text = [names objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [phones objectAtIndex:indexPath.row];
        } else {
            cell.imageView.image = [UIImage imageWithData:[[self.contactsArray objectAtIndex:indexPath.row] valueForKey:@"thumbnailImageData"]];
            cell.textLabel.text = [[self.contactsArray objectAtIndex:indexPath.row] givenName];
            CNPhoneNumber *phone = [(CNPhoneNumber*)[[[self.contactsArray objectAtIndex:0] phoneNumbers] objectAtIndex:0] valueForKey:@"value"];
            cell.detailTextLabel.text = [phone stringValue];
        }
        
    } else {
        cell.imageView.image = nil;
        cell.textLabel.text = [[self.notInAppArray objectAtIndex:indexPath.row] givenName];
        CNPhoneNumber *phone = [(CNPhoneNumber*)[[[self.notInAppArray objectAtIndex:0] phoneNumbers] objectAtIndex:0] valueForKey:@"value"];
        cell.detailTextLabel.text = [phone stringValue];
    }
    
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:15.f]];
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:14.f]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Contacts in Rendez-Vous";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
