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
@property (strong, nonatomic) NSMutableArray *friends;

@end

@implementation SelectContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.contactsArray = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    
    CNContactStore *store = [[CNContactStore alloc] init];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
    
        if (!granted) return;
    
        NSPredicate *predicate = [CNContact predicateForContactsMatchingName:@"CT-"];
        NSArray *keys = [NSArray arrayWithObjects:CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey, nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _contactsArray = [NSMutableArray arrayWithArray:[store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:nil]];
            [_myTableView reloadData];
            
            //NSArray *numbers = [[[_contactsArray valueForKey:@"_phoneNumbers"] valueForKey:@"value"] valueForKey:@"digits"];
            NSArray *numbers = [NSArray arrayWithObjects:@"3472252451", @"6174077296", nil];
            
            // Send Parse the phone #
            [PFCloud callFunctionInBackground:@"getCommonContacts" withParameters:@{@"phoneNumbers":numbers} block:^(id  _Nullable object, NSError * _Nullable error) {
                if (error) return;
                
                
            }];

        });
    
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contactsArray.count > 0 ? self.contactsArray.count : 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"contactCell"];
    }

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
